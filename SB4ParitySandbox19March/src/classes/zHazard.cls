public with sharing class zHazard {

	private final Hazard__c hazard;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public zHazard(ApexPages.StandardController stdController) {
        this.hazard = (Hazard__c)stdController.getRecord();
        if(ApexPages.currentPage().getParameters().get('Risk_Assessment__c') != null){
            hazard.Risk_Assessment__c = ApexPages.currentPage().getParameters().get('Risk_Assessment__c');
        }

    }

    public PageReference saveRec() {
        try { 
            upsert hazard; 
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        String riskAssessId = [SELECT Risk_Assessment__c FROM Hazard__c WHERE Id = :hazard.Id LIMIT 1].Risk_Assessment__c;
        PageReference riskPage = new PageReference('/' + riskAssessId);
        return riskPage;        
    }

    public PageReference saveNew() {
        try { 
            upsert hazard; 
        } 
        catch(System.DMLException e) {
            ApexPages.addMessages(e);
            return null;
        }
        String riskAssessId = [SELECT Risk_Assessment__c FROM Hazard__c WHERE Id = :hazard.Id LIMIT 1].Risk_Assessment__c;
        PageReference newHazard = new PageReference('/apex/zHazard?retURL=%2F' + riskAssessId);
        newHazard.setRedirect(true);
        newHazard.getParameters().put('Risk_Assessment__c', riskAssessId);
        return newHazard;        
    }  

}