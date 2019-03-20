@isTest
public class zHazardTest {

    public static testMethod void testHazardController() {
        Risk_Assessment__c ra = new Risk_Assessment__c();
        insert ra;
    
        PageReference pageRef = Page.zHazard;
        Test.setCurrentPage(pageRef);
      
        ApexPages.StandardController stdController = new ApexPages.StandardController(new Hazard__c(Risk_Assessment__c = ra.Id));
        zHazard hazardController = new zHazard(stdController);
        
        hazardController.hazard.Comments__c = 'zzz';
        hazardController.hazard.Control_Options__c = 'zzz';
        hazardController.hazard.Control_Options_to_be_Implemented__c = 'zzz';
        hazardController.hazard.Current_Controls__c = 'zzz';
        hazardController.hazard.Immediate_Controls_Implemented__c = 'zzz';
        hazardController.hazard.Key_Steps__c = 'zzz';
        hazardController.hazard.Potential_Issues__c = 'zzz';
        hazardController.hazard.Risk_Rating_if_Actions__c = 'Low';
        hazardController.hazard.Risk_Rating__c = 'Low';
        hazardController.hazard.Current_Risk_Rating_Category__c = '4D';
        hazardController.hazard.Risk_Rating_Category__c = '4D';
        hazardController.hazard.Current_Risk_Rating_Acceptable__c = 'Yes';
        
        pageRef = hazardController.saveNew();
        
        hazardController.hazard.Comments__c = 'zzz';
        hazardController.hazard.Control_Options__c = 'zzz';
        hazardController.hazard.Control_Options_to_be_Implemented__c = 'zzz';
        hazardController.hazard.Current_Controls__c = 'zzz';
        hazardController.hazard.Immediate_Controls_Implemented__c = 'zzz';
        hazardController.hazard.Key_Steps__c = 'zzz';
        hazardController.hazard.Potential_Issues__c = 'zzz';
        hazardController.hazard.Risk_Rating_if_Actions__c = 'Low';
        hazardController.hazard.Risk_Rating__c = 'Low';
        hazardController.hazard.Current_Risk_Rating_Category__c = '4D';
        hazardController.hazard.Risk_Rating_Category__c = '4D';
        hazardController.hazard.Current_Risk_Rating_Acceptable__c = 'Yes';
        
        pageRef = hazardController.saveRec();
        
        System.assertEquals('/' + ra.Id, pageRef.getUrl());
        
    }
}