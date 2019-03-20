public class InjuryEditController {

    public Injury__c injury { get; set; }
    public String incidentId { get; set; }
    private ApexPages.standardController controller; 
    
    public InjuryEditController(ApexPages.StandardController stdController) {
        controller = stdController;
        injury = (Injury__c)controller.getRecord();
        incidentId = [SELECT Id FROM Incident__c WHERE Id = :injury.Incident__c LIMIT 1].Id;
    }
    
    public PageReference redirectToWizard() {
        PageReference pg = page.zInjury;
        pg.getParameters().put('Id', incidentId);
        return pg;
    }
}