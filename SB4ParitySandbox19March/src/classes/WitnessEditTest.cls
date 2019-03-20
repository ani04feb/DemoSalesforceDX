@isTest
private class WitnessEditTest {
    
    private static ApexPages.StandardController stdCtrl;
    private static WitnessEditController ctrl;
    
    private static testMethod void testEditInjuries() {
        Account testSite = new Account(Name = 'Test', Brand__c = 'Supermarkets');
        insert testSite;
        Incident__c incidentRec = new Incident__c(Account__c = testSite.Id, Injury_or_Illness__c = true);
        insert incidentRec;
        Incident_Witness__c witnessRec = new Incident_Witness__c(Incident__c = incidentRec.Id);
        PageReference pageRef = Page.EditWitnesses;
        Test.setCurrentPage(pageRef);
        stdCtrl = new ApexPages.StandardController(witnessRec);
        ctrl = new WitnessEditController(stdCtrl);
        ctrl.redirectToWizard();
    }
    
}