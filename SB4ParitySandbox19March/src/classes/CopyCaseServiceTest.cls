@isTest
private class CopyCaseServiceTest {

    static testmethod void test() {
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        Case__c testCase1 = new Case__c(Case_Type_3__c=hrRec.Id);
        insert testCase1;
        Case_Witness__c w = new Case_Witness__c(Case__c = testCase1.Id);
        insert w;
        Complainant__c c = new Complainant__c(Case__c = testCase1.Id);
        insert c;
        Test.startTest();
        CopyCaseService.cloneRec(testCase1.Id);
        Test.stopTest();
    }
}