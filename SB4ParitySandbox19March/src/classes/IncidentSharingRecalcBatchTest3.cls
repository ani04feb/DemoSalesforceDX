@isTest
private class IncidentSharingRecalcBatchTest3{

    static testmethod void test() {
        Account acc1 = new Account(Name='Test1', Brand__c='Supermarkets');
        insert acc1;
        User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Contact c1 = new Contact(LastName = 'test1', Email = 'test1@test.com', AccountId = acc1.Id, User__c = u1.Id);
        insert c1;
        User u2 = [SELECT Id FROM User WHERE IsActive = true order by name desc LIMIT 1];
        Contact c2 = new Contact(LastName = 'Site Assistant Mgr', Email = 'test2@test.com', AccountId = acc1.Id, User__c = u2.Id);
        insert c2;
        acc1.Trading_Manager_Fresh__c = c1.Id;
        acc1.Trading_Manager_Grocery__c = c2.Id;
        update acc1;
        
        Account acc2 = new Account(Name='Test2', Brand__c='Supermarkets');
        insert acc2;
        c2.AccountId = acc2.Id;
        update c2;
        acc2.Trading_Manager_Fresh__c = c2.Id;
        update acc2;
        
        Incident__c incident1 = new Incident__c(Account__c=acc1.Id, Hazard__c=true);
        insert incident1;
        //testShare(incident1.Id, c1, c2);
        
        Incident__c incident2 = new Incident__c(Account__c=acc2.Id, Hazard__c=true);
        insert incident2;
        //testShare(incident2.Id, c2, null);
        
        //Change account1's site manager and site assistant manager, recalc and then test shares
        acc1.Trading_Manager_Fresh__c = c2.Id;
        acc1.Trading_Manager_Grocery__c = c1.Id;
        update acc1;
        
        Test.startTest();
        IncidentSharingRecalc r = new IncidentSharingRecalc();
        Database.executeBatch(r);
        Test.stopTest();
        
       // testShare(incident1.Id, c2, c1);
        
    }


 
   
}