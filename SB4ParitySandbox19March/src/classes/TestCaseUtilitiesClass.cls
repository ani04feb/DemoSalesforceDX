@isTest
private class TestCaseUtilitiesClass {

    static testmethod void test() {
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        Blob cryptoKey = Crypto.generateAesKey(256);
        String encodedKey = EncodingUtil.base64encode(cryptoKey);
        System.debug(encodedKey);
        Keystore__c keyStore = new Keystore__c(Name='Case Notes', Key_Value__c = encodedKey);
        insert keyStore;
        Case__c testCase1 = new Case__c(New_Notes__c='Test Notes 1', Case_Type_3__c=hrRec.Id);
        insert testCase1;
        Test.startTest();
        CaseUtilities.SubmitCase(testCase1.Id);
        Test.stopTest();
    }
}