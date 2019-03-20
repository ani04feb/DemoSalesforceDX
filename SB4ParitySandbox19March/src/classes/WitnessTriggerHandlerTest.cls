@isTest
private class WitnessTriggerHandlerTest 
{
    private static testMethod void testFieldDefaults() 
    {
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        Account acc1 = new Account(Name='Test1', Brand__c='Liquorland');
        insert acc1;
        Contact con1 = new Contact(LastName='Test1', Gender__c='Male', Account=acc1);
        insert con1;
        Case__c case1 = new Case__c(Account__c=acc1.Id, Contact__c=con1.Id, Case_Type_3__c=hrRec.Id);
        insert case1;
        Case_Witness__c w1 = new Case_Witness__c(Case__c = case1.Id, Contact__c = con1.Id);
        insert w1;
        Case_Witness__c testWitness = [SELECT Gender__c FROM Case_Witness__c WHERE Id = :w1.Id];
        System.AssertEquals(testWitness.Gender__c, con1.Gender__c);
    }
}