global with sharing class CreateCase {
    /*-------------------------------------------------------------
    Author:        Deepu Chako, Lok Jackson
    Company:       Salesforce.com
    Description:   Controller for Create Case VF Page displayed as a component in the HR Console.
                    This allows users to capture basic information about a case and have Quick Links
                    automatically display before actually creating the case record.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    03-Jun-14   Lok Jackson        Added the ability to copy Caller details into Team Member (WP4137)
    ------------------------------------------------------------*/

    public String prevCaseId                        {get; set;}
    public HR_Classification__c Classifier          {get; set;}
    public Case__c prevCase                         {get; set;}
    public Contact ContactRecord                    {get; set;}
    public Case__c caseRec                          {get; set;}
    public ApexPages.standardController controller  {get; set;}
    public Contact caller                           {get; set;}
    
    public CreateCase(ApexPages.standardController ctrl) {
        controller = ctrl;
        caller = (Contact)controller.getRecord();
        init();
    }
    
    public void init(){
        Classifier = new HR_Classification__c();        // Need this for LCase Type Search

        prevCaseId = ApexPages.currentPage().getParameters().get('CaseId');
        if(prevCaseId==null || prevCaseId=='')
        {
            caseRec = new Case__c();                       // Need this for Team Member and Notes
            if(caller != null) caseRec.Caller__c = caller.Id;
        }
        else
        {
            prevCase = [SELECT Name, Case_Type_3__c, Caller__c, Case_Notes__c, Id FROM Case__c WHERE Id = :prevCaseId];
            caseRec = new Case__c(Case_Type_3__c=prevCase.Case_Type_3__c, New_Notes__c=prevCase.Case_Notes__c, Caller__c=prevCase.Caller__c);
        }
    }
    
    // WP4137: Copy Caller Details into Team Member details (used when person is calling about themselves)
    public void copyCaller(){
        caseRec.Contact__c = caseRec.Caller__c;
        caseRec.Brand__c = caseRec.Caller_Brand__c;
        caseRec.Reporting_Department__c = caseRec.Caller_Reporting_Department__c;
        setContactRecord();
    }
    
    // Called to save the case record
    public pageReference saveCase(){
        PageReference pg = null;
        Try {
            HR_Classification__c h = [SELECT ID, Case_Record_Type__c, Default_Priority__c
                                    FROM HR_Classification__c
                                    WHERE Name =:Classifier.Name
                                    LIMIT 1];
            caseRec.Case_Type_3__c = h.Id;
            caseRec.RecordTypeId = h.Case_Record_Type__c;
            caseRec.Priority__c = h.Default_Priority__c;
        }
        Catch (Exception e) {
            apexpages.Message msg = new Apexpages.Message(ApexPages.Severity.Error,'Please select a valid Case Type');
            apexpages.addmessage(msg);
            return null;
        }
        List<Account> accountList = [SELECT Id FROM Account WHERE Id IN(SELECT AccountId FROM Contact WHERE Id = :caseRec.Contact__c) LIMIT 1];
        List<Account> siteList = [SELECT Id FROM Account WHERE Id IN(SELECT AccountId FROM Contact WHERE Id = :caseRec.Caller__c) LIMIT 1];
        if(accountList.size()>0)
            caseRec.Account__c=accountList[0].Id;
        if(siteList.size()>0)
            caseRec.Site__c=siteList[0].Id;
        Try {
            insert caseRec;
        }
        Catch (DMLException e) {
            return null;
        }
        prevCaseId=caseRec.Id;
        pg = new PageReference('/apex/CreateCase?Id=' + caller.Id + '&CaseId=' + prevCaseId);
        pg.setRedirect(true);
        return pg;
    }

    // Called once a team member is selected in the UI
    public void setContactRecord(){
        ContactRecord = null;
        if(caseRec.Contact__c != null){
            ContactRecord = [SELECT ID, Account.Name, Above_Store__c, Name, Email, Indicators__c, Work_Indicators__c, Name_Position_Emp_Type__c, Known_As_Name__c, Phone__c, Site_State__c, Hire_Date__c, Position__c, Is_Apprentice_Trainee__c, Position_Description__c, Under_18__c, Cost_Centre_Description__c
                                FROM Contact
                                WHERE Id = :caseRec.Contact__c];
        }
    }   
    // Return all the classifiers to display in the UI
    @RemoteAction
    global static List<HR_Classification__c> getAllClassifiers(){
        return [SELECT ID, Name, Level_1__c, Level_2__c
                FROM HR_Classification__c
                ORDER BY Level_1__c, Level_2__c];
    }

}