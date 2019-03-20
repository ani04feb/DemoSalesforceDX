@isTest
private class InjuryEditTest {
    
    private static ApexPages.StandardController stdCtrl;
    private static InjuryEditController ctrl;
    
    private static testMethod void testEditInjuries() {
        Account testSite = new Account(Name = 'Test', Brand__c = 'Supermarkets');
        insert testSite;
        Incident__c incidentRec = new Incident__c(Account__c = testSite.Id, Injury_or_Illness__c = true);
        insert incidentRec;
        Injury__c injuryRec = new Injury__c(Incident__c = incidentRec.Id);
        PageReference pageRef = Page.EditInjuries;
        Test.setCurrentPage(pageRef);
        stdCtrl = new ApexPages.StandardController(injuryRec);
        ctrl = new InjuryEditController(stdCtrl);
        ctrl.redirectToWizard();
    }
    
}