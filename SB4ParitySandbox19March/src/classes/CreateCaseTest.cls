@isTest
private class CreateCaseTest {
   
    private static ApexPages.StandardController stdCtrl;
    private static CreateCase ctrl;
    private static Account accountRec;
    private static Contact contactRec;
    private static Contact teamMemberRec;
    private static HR_Classification__c hrRec;
    
    private static testMethod void testConstructor() {
        accountRec = new Account(Name='Test');
        insert accountRec;
        contactRec = new Contact(LastName='Test', Account=accountRec);
        insert contactRec;
        teamMemberRec = new Contact(LastName='TestTM', Account=accountRec);
        insert teamMemberRec;
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        PageReference pageRef = Page.CreateCase;
        Test.setCurrentPage(pageRef);
        stdCtrl = new ApexPages.StandardController(contactRec);
        ctrl = new CreateCase(stdCtrl);
        ctrl.caseRec.Contact__c = teamMemberRec.Id;
        ctrl.Classifier = hrRec;
        ctrl.setContactRecord();
        pageRef = ctrl.saveCase();
        Test.setCurrentPage(pageRef);
        stdCtrl = new ApexPages.StandardController(contactRec);
        ctrl = new CreateCase(stdCtrl);
        ctrl.Classifier = hrRec;
        pageRef = ctrl.saveCase();
    }

}