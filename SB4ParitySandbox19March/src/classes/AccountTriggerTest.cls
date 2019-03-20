@isTest
private class AccountTriggerTest {
    static testMethod void test() {
        Account a = new Account(Name='TestName1');
        insert a;
        a = [SELECT Name, Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        a.Name = 'TestName2';
        update a;
        TriggerUtilities.resetAccountBeforeTriggerCalled();
        a = [SELECT Name, Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        Account testAccnt = [SELECT Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        System.AssertEquals(testAccnt.Previous_Site_Names__c,'TestName1');
        a.Name = 'TestName3';
        update a;
        TriggerUtilities.resetAccountBeforeTriggerCalled();
        a = [SELECT Name, Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        testAccnt = [SELECT Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        System.Debug('a.Name: ' + a.Name + ', a.Previous_Site_Names__c: ' + a.Previous_Site_Names__c);
        System.Debug('testAccnt.Previous_Site_Names__c: ' + testAccnt.Previous_Site_Names__c);
        System.AssertEquals(testAccnt.Previous_Site_Names__c,'TestName2,TestName1');
        a.Previous_Site_Names__c = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa,aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
        update a;
        TriggerUtilities.resetAccountBeforeTriggerCalled();
        a = [SELECT Name, Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        a.Name = 'TestName4';
        update a;
        testAccnt = [SELECT Previous_Site_Names__c FROM Account WHERE Id = :a.Id];
        System.AssertEquals(testAccnt.Previous_Site_Names__c,'TestName3,aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
    }
}