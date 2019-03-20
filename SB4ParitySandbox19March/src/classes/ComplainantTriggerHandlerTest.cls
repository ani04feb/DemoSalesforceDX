@isTest
private class ComplainantTriggerHandlerTest 
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
        Complainant__c comp1 = new Complainant__c(Case__c = case1.Id, Contact__c = con1.Id);
        insert comp1;
        Complainant__c testComp = [SELECT Gender__c FROM Complainant__c WHERE Id = :comp1.Id];
        System.AssertEquals(testComp.Gender__c, con1.Gender__c);
    }
}