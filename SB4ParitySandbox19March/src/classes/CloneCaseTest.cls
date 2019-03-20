@isTest
private class CloneCaseTest
{
    private static testMethod void testFieldDefaults() 
    {
        RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
        HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
        insert hrRec;
        Account acc1 = new Account(Name='Test1', Brand__c='Liquorland');
        insert acc1;
        Account acc2 = new Account(Name='Test2', Brand__c='Supermarkets');
        insert acc2;
        Contact con1 = new Contact(LastName='Test1', Gender__c='Male', Account=acc1);
        insert con1;
        Contact con2 = new Contact(LastName='Test2', Gender__c='Female', Account=acc2);
        insert con2;
        Case__c case1 = new Case__c(Account__c=acc1.Id, Site__c=acc2.Id, Contact__c=con1.Id, Caller__c=con2.Id, Case_Type_3__c=hrRec.Id);
        insert case1;
        Case_Witness__c cw = new Case_Witness__c(Case__c = case1.Id, Contact__c = con1.Id);
        insert cw;
        Complainant__c co = new Complainant__c(Case__c = case1.Id, Contact__c = con1.Id);
        insert co;
        ApexPages.StandardController controller = new ApexPages.StandardController(case1);
        CloneCase c = new CloneCase(controller);
        c.saveClone();
    }
}