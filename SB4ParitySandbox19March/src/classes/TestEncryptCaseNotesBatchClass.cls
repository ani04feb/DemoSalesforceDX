@isTest
private class TestEncryptCaseNotesBatchClass {

    static testmethod void test() {
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        Case__c testCase1 = new Case__c(Case_Notes__c='Test Notes 1', Case_Type_3__c=hrRec.Id);
        insert testCase1;
        String caseId = testCase1.Id;
        String q = 'SELECT Case_Notes__c FROM Case__c WHERE Id=\'' + caseId + '\'';
        Blob k = Crypto.generateAesKey(256);
        Test.startTest();
        EncryptCaseNotes e = new EncryptCaseNotes(q, k);
        Database.executeBatch(e);
        Test.stopTest();

        Case__c testCaseUpdated = [SELECT Case_Notes__c FROM Case__c WHERE Id =: caseId];
        String rawNotes = (Crypto.decryptWithManagedIV('AES256', k, EncodingUtil.base64decode(testCaseUpdated.Case_Notes__c))).toString();
        System.assertNotEquals(testCaseUpdated.Case_Notes__c, 'Test Notes 1');
        System.assertEquals(rawNotes, 'Test Notes 1');
    }
}