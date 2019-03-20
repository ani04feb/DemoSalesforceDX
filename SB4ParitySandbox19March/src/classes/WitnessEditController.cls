public class WitnessEditController {

    public Incident_Witness__c witness { get; set; }
    public String incidentId { get; set; }
    private ApexPages.standardController controller; 
    
    public WitnessEditController(ApexPages.StandardController stdController) {
        controller = stdController;
        witness = (Incident_Witness__c)controller.getRecord();
        incidentId = [SELECT Id FROM Incident__c WHERE Id = :witness.Incident__c LIMIT 1].Id;
    }
    
    public PageReference redirectToWizard() {
        PageReference pg = page.zMiscellaneous;
        pg.getParameters().put('Id', incidentId);
        return pg;
    }
}