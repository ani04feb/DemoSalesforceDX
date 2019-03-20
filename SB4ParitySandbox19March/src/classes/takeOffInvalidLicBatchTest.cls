@isTest 
public class takeOffInvalidLicBatchTest {

    static testMethod void myUnitTest() {
        Account acc1 = new Account(Name='Test1', Brand__c='Supermarkets');
        //Account acc1 = new Account(Name='Test1', Brand__c='Supermarkets');
        insert acc1;
        System.debug('@@@@@@AccountId'+acc1);

        User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        System.debug('@@@@@@user1'+u1);
        Contact c1 = new Contact(LastName = 'test1', Email = 'test1@test.com', Position_Description__c='Store Manager',AccountId = acc1.Id, User__c = u1.Id);
        insert c1;
        System.debug('@@@@@@Contact1'+c1);
        User u2 = [SELECT Id FROM User WHERE IsActive = true order by name desc LIMIT 1];
        System.debug('@@@@@@user2'+u2);
        Contact c2 = new Contact(LastName = 'test2', Email = 'test2@test.com', Position_Description__c='DMTL ',AccountId = acc1.Id, User__c = u2.Id);
        insert c2;
        System.debug('@@@@@@Contact2'+c2);
        User u3 = [SELECT Id FROM User WHERE IsActive = true order by name asc LIMIT 1];
        System.debug('@@@@@@user3'+u3);
        Contact c3 = new Contact(LastName = 'test3', Email = 'test3@test.com', Position_Description__c='Trading Manager Nights',AccountId = acc1.Id, User__c = u3.Id);
        insert c3;
        acc1.Active_Licence__c=3;
        update acc1;
        System.debug('@@@@@@Contact3'+c3);
        System.debug('@@@@@@Contact3Acc'+c2.account.Active_Licence__c);
        Test.StartTest();
         takeOffInvalidLicBatch  b = new takeOffInvalidLicBatch (); 
         database.executebatch(b);
        Test.StopTest();   

    }
}