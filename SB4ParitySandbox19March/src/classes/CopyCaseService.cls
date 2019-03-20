global with sharing class CopyCaseService {
    /*-------------------------------------------------------------
    Author:        Lok Jackson
    Company:       Salesforce.com
    Description:   Custom clone service used to copy over all the fields except for the ones mentioned in the field set.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    03/06/2014  Lok                Updated to ensure the new owner is set to the current user (not the owner of the case being cloned). Also
                                   added attachments to the Clone process as per WP4935
    ------------------------------------------------------------*/
    
    webservice static string cloneRec(string caseId){
        
        Case__c original = Database.query(zIncidentWizard.getCreatableFieldsSOQL('Case__c', 'id=\'' + caseId + '\''));
        sObject clonedCase = original.clone(false, true);
        // Use the field set to clear the fields on the cloned record.
        for(Schema.FieldSetMember field : 
                SObjectType.Case__c.FieldSets.Clear_on_clone.getFields()){
            clonedCase.put(field.getFieldPath(), (field.getType() == Schema.DisplayType.Boolean ? false : null));
        }
        clonedCase.put('OwnerId', UserInfo.getUserId());
        clonedCase.put('Status__c', 'Open');
        if(original.Linked_Case__c == null)
            clonedCase.put('Linked_Case__c', original.Id);     
        insert clonedCase;

        List<Attachment> attachments = [select id, name, body from Attachment where ParentId = :original.Id];
        List<Complainant__c> complainants = Database.query(zIncidentWizard.getCreatableFieldsSOQL('Complainant__c', 'Case__c=\'' + original.id + '\''));
        List<Case_Witness__c> witnesses = Database.query(zIncidentWizard.getCreatableFieldsSOQL('Case_Witness__c', 'Case__c=\'' + original.id + '\''));
        for(Attachment a : attachments){
            Attachment clonedAtt = a.clone();
            clonedAtt.ParentId = clonedCase.Id;
            insert clonedAtt;
        }
        for(Complainant__c c : complainants){
            Complainant__c clonedRec = c.clone();
            clonedRec.Case__c = clonedCase.Id;
            clonedRec.Contact__c = c.Contact__c;
            insert clonedRec;
        }
        for(Case_Witness__c cw : witnesses){
            Case_Witness__c clonedRec = cw.clone();
            clonedRec.Case__c = clonedCase.Id;
            clonedRec.Contact__c = cw.Contact__c;
            insert clonedRec;
        }        

        return clonedCase.Id;
    }

}