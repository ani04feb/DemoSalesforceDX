public with sharing class CloneCase {
    /*-------------------------------------------------------------
    Author:        Deepu Chacko
    Company:       Salesforce.com
    Description:   When a case is cloned, copy over all the fields except for the ones mentioned in the field set
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    03-Apr-14   Deepu               Initial Version - Use field set to clear fields, save the record and then open in edit
    ------------------------------------------------------------*/
    private Case__c original {get;set;}
    
    public CloneCase(ApexPages.StandardController controller) {
        original = (Case__c)controller.getRecord();
    }
    
    public PageReference saveClone(){
        
        original = Database.query(zIncidentWizard.getCreatableFieldsSOQL('Case__c', 'id=\'' + original.id + '\''));
        sObject clonedCase = original.clone(false, true);
system.debug('before--------');
system.debug(clonedCase);
        // Use the field set to clear the fields on the cloned record.
        for(Schema.FieldSetMember field : 
                SObjectType.Case__c.FieldSets.Clear_on_clone.getFields()){
            clonedCase.put(field.getFieldPath(), (field.getType() == Schema.DisplayType.Boolean ? false : null));
        }
        if(original.Linked_Case__c == null)
            clonedCase.put('Linked_Case__c', original.Id);
system.debug('after--------');
system.debug(clonedCase);
        
        try{
            insert clonedCase;
        }
        catch(exception e){
            ApexPages.addMessages(e);
            return null;
        }
        List<Complainant__c> complainants = Database.query(zIncidentWizard.getCreatableFieldsSOQL('Complainant__c', 'Case__c=\'' + original.id + '\''));
        List<Case_Witness__c> witnesses = Database.query(zIncidentWizard.getCreatableFieldsSOQL('Case_Witness__c', 'Case__c=\'' + original.id + '\''));
        for(Complainant__c c : complainants){
            Complainant__c clonedRec = c.clone(false,true);
            clonedRec.Case__c = clonedCase.Id;
            insert clonedRec;
        }
        for(Case_Witness__c cw : witnesses){
            Case_Witness__c clonedRec = cw.clone(false,true);
            clonedRec.Case__c = clonedCase.Id;
            insert clonedRec;
        }
        PageReference pg = new PageReference('/' + clonedCase.Id + '/e');
        pg.getParameters().put('saveURL', '/' + clonedCase.Id);
        pg.getParameters().put('cancelURL', '/' + clonedCase.Id);
        return pg.setRedirect(true);
    }
}