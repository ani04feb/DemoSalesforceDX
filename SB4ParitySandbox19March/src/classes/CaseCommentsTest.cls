@isTest
private class CaseCommentsTest {
    
    private static ApexPages.StandardController stdCtrl;
    private static CaseCommentsController ctrl;
    private static Case__c caseRec;
    
    private static testMethod void testCaseComments() {
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        Blob cryptoKey = Crypto.generateAesKey(256);
        String encodedKey = EncodingUtil.base64encode(cryptoKey);
        System.debug(encodedKey);
        Keystore__c keyStore = new Keystore__c(Name='Case Notes', Key_Value__c = encodedKey);
        insert keyStore;
        caseRec = new Case__c(Case_Type_3__c = hrRec.Id);
        insert caseRec;
        PageReference pageRef = Page.CaseComments;
        Test.setCurrentPage(pageRef);
        stdCtrl = new ApexPages.StandardController(caseRec);
        ctrl = new CaseCommentsController(stdCtrl);
        ctrl.caseRec.New_Notes__c = 'Test';
        ctrl.saveDraft();
        ctrl.saveRecord();
        ctrl.caseRec.New_Notes__c = 'Test2';
        ctrl.saveRecord();
    }
    
}