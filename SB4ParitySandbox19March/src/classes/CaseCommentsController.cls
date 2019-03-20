public class CaseCommentsController {
    /*-------------------------------------------------------------
    Author:        Lok Jackson
    Company:       Salesforce.com
    Description:   Used to handle encryption and decryption of Case Notes, 
                   as well as auto-saving draft notes
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    19-Mar-14   Lok Jackson        Initial Version
    03-Jun-14   Lok Jackson        Added a variable to allow the submit function to block the autosave
                                   while it is processing (part of the fix for WP5241)
    16-Jun-14   Lok Jackson        Added getAttachments to allow the Case_Document VF Page to extract a list of attachments
    22-Jun-14   Lok Jackson        Implemented logic in the saveDraft method to strip html, spaces and line breaks when doing string comparisons
                                   to prevent unnecessary auto-saving (caused when html and line-breaks were formatted differently in the user-entered
                                   version vs the version held in the DB
    ------------------------------------------------------------*/
    
    public ApexPages.standardController controller {get; set;}
    public Case__c caseRec {get; set;}
    public Blob cryptoKey {get; set;}
    public String rawNotes {get; set;}
    public String originalDraftNotes {get; set;}
    public static final String EMPTY_TEXT = '--No Notes Submitted--';
    public Boolean updateInProgress {get; set;}
    
    
    public CaseCommentsController(ApexPages.StandardController stdController) {
        controller = stdController;
        caseRec = (Case__c)controller.getRecord();
        originalDraftNotes = caseRec.New_Notes__c;
        cryptoKey = EncodingUtil.base64decode([SELECT Key_Value__c FROM Keystore__c WHERE Name='Case Notes'].Key_Value__c);
        if(caseRec.Case_Notes__c != null)
            rawNotes = (Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.base64decode(caseRec.Case_Notes__c))).toString();
        else
            rawNotes = EMPTY_TEXT;
        updateInProgress = FALSE;
    }
    public void saveRecord()
    {
        updateInProgress = TRUE;
        String newNotes = caseRec.New_Notes__c;
        caseRec.New_Notes__c = '';
        // Get a copy of the record from the DB as it may have been changed by someone else
        Case__c currentCase = [SELECT Case_Notes__c FROM Case__c WHERE ID = :caseRec.Id LIMIT 1];
        rawNotes = currentCase.Case_Notes__c;
        if (rawNotes != '' && rawNotes != null)
            rawNotes = (Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.base64decode(rawNotes))).toString();
        else
            rawNotes = '';
        rawNotes = Datetime.now().format() + ', ' + UserInfo.getName() + '<br/>' + newNotes + '<br/><br/>' + rawNotes;
        Blob encryptedNotesValue = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(rawNotes));
        caseRec.Case_Notes__c = EncodingUtil.base64encode(encryptedNotesValue);
        Try{
            currentCase.New_Notes__c = caseRec.New_Notes__c;
            currentCase.Case_Notes__c = caseRec.Case_Notes__c;
            update currentCase;
            originalDraftNotes = caseRec.New_Notes__c;
        }
        Catch(DMLException e) {
            caseRec.New_Notes__c = newNotes;
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, e.getMessage());
            apexpages.addmessage(msg);
        }
        Finally{
            updateInProgress = FALSE;
        }
    }
    public void saveDraft()
    {
        System.Debug('>>>>>>>>>>>>>>>>> Updated In Progress is: ' + updateInProgress);
        // only proceed if we have a record in focus and notes aren't currently being submitted
        if(caseRec.Id != null && !updateInProgress) {
            // get a copy of the current record form the database
            Case__c currentCase = [SELECT New_Notes__c, Case_Notes__c FROM Case__c WHERE ID = :caseRec.Id LIMIT 1];
            // if the draft notes are different to what is in the DB AND different from what they were on first entry, auto-save as the user has made a change
            // strip html, line-breaks and spaces first though as these will always differ between user input and db value
            String newNotes = caseRec.New_Notes__c;
            if (newNotes != null)
                newNotes = caseRec.New_Notes__c.stripHtmlTags().remove('\n').remove('\r').remove(' '); 
            String currentNotes = currentCase.New_Notes__c;
            if(currentNotes != null)
                currentNotes = currentCase.New_Notes__c.stripHtmlTags().remove('\n').remove('\r').remove(' ');
            String originalNotes = originalDraftNotes;
            if(originalNotes != null)
                originalNotes = originalDraftNotes.stripHtmlTags().remove('\n').remove('\r').remove(' ');
            System.Debug('>>>>>>>>>>>>>>>>> newNotes: ' + newNotes);
            System.Debug('>>>>>>>>>>>>>>>>> currentNotes: ' + currentNotes);
            System.Debug('>>>>>>>>>>>>>>>>> originalNotes: ' + originalNotes);
            if(newNotes != currentNotes && newNotes != originalNotes) {
                Try{
                    currentCase.New_Notes__c = caseRec.New_Notes__c;
                    update currentCase;
                    originalDraftNotes = caseRec.New_Notes__c;
                    System.Debug('>>>>>>>>>>>>>>>>> Case Updated');
                }
                Catch(DMLException e) {
                    apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error, e.getMessage());
                    apexpages.addmessage(msg);
                }
            }
        } 
    }
    
    // LJ 16/6/14: Added to allow the Case_Document VF Page to get a list of attachments
    public string getAttachments() {
        String attachmentList = '';
        List<Attachment> attList = [SELECT Name FROM Attachment WHERE ParentId = :caseRec.Id];
        if(attList.size() > 0) {
            for(Attachment a: attList) {
                attachmentList = attachmentList + a.Name + '<br/>';
            }
        }
        return attachmentList;
    }
}