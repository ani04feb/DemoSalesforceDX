@isTest
private class MatterTriggerHandlerTest 
{
/*
    private static testMethod void testFieldDefaults() 
    {
        Account acc1 = new Account(Name='Test1', Brand__c='Liquorland');
        insert acc1;
        Account acc2 = new Account(Name='Test2', Brand__c='Supermarkets');
        insert acc2;
        Case__c case1 = new Case__c(Account__c=acc1.Id);
        insert case1;
        Matter__c matter1 = new Matter__c(Account__c=acc1.Id, Case__c=case1.Id);
        insert matter1;
        System.AssertEquals(acc1.Brand__c, [select Brand__c from Matter__c where Id = :matter1.Id].Brand__c);
        matter1.Account__c = acc2.Id;
        update matter1;
        System.AssertEquals(acc2.Brand__c, [select Brand__c from Matter__c where Id = :matter1.Id].Brand__c);
        matter1.Account__c = null;
        update matter1;
        System.AssertEquals(null, [select Brand__c from Matter__c where Id = :matter1.Id].Brand__c);
    }
*/
}