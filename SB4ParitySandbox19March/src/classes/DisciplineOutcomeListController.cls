/**************************************************
Type:       Controller for Visualforce Page
Purpose:    Used in Component for Disciplinary Outcome of Case’s Team Member
Used By:    DisciplineOutcomeList Visualforce Page
History:
--------------------------------------------------
24-March-2014 Paul Fayle (Salesforce.com)     Created as part of Coles HR
**************************************************/

public with sharing class DisciplineOutcomeListController {
    
    private Case__c caseRec;
    private Case__c caseInfo {get;set;}
    
    public DisciplineOutcomeListController (ApexPages.StandardController controller) {
        caseRec = (Case__c)controller.getRecord();
        caseInfo = [select Id, Contact__c from Case__c where Id=:caseRec.Id];
    }
    
    public List<Case__c> getHRCases() {
        if(caseInfo.Contact__c != null)
            return [SELECT Disciplinary_Outcome__c, Date_Delivered__c FROM Case__c where Contact__c = : CaseInfo.Contact__c AND Id != : CaseInfo.Id AND Disciplinary_Outcome__c != null];
        else return null;
    }
}