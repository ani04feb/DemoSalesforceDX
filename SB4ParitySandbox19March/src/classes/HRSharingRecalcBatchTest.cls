@isTest
private class HRSharingRecalcBatchTest {

    static testmethod void test() {
        //Insert Site to link all Contacts to
        Account site1 = new Account(Name = 'Test Site 1', Above_Store__c = false);
        insert site1;
        Account site2 = new Account(Name = 'Test Site 2', Above_Store__c = true);
        insert site2;
        Account site3 = new Account(Name = 'Test Site 3', Above_Store__c = false);
        insert site3;
        Account site4 = new Account(Name = 'Test Site 4', Above_Store__c = true);
        insert site4;
        //Insert Contacts to act as notification recipients
        List<Contact> notificationList = new List<Contact>();
        //Lookup some user records to associate to the Notification Contacts
        List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 2];
        Contact c1 = new Contact(LastName = 'testName1', Email = 'test1@test.com', AccountId = site1.Id, User__c = users[0].Id);
        insert c1;
        Contact c2 = new Contact(LastName = 'testName2', Email = 'test2@test.com', AccountId = site2.Id);
        insert c2;
        Contact c3 = new Contact(LastName = 'testName3', Email = 'test3@test.com', AccountId = site3.Id, User__c = users[1].Id);
        insert c3;
        Contact c4 = new Contact(LastName = 'testName4', Email = 'test4@test.com', AccountId = site4.Id);
        insert c4;
        insert notificationList;
        //Create test Contact
        Contact testCon1 = new Contact(LastName = 'test1', AccountId = site1.Id);
        insert testCon1;
        Contact testCon2 = new Contact(LastName = 'test2', AccountId = site2.Id);
        insert testCon2;
        Contact testCon3 = new Contact(LastName = 'test3', AccountId = site3.Id);
        insert testCon3;
        Contact testCon4 = new Contact(LastName = 'test4', AccountId = site4.Id);
        insert testCon4;
        //Update Site with Notification Recipients
        site1.HR_Business_Partner__c = c1.Id;
        site1.Site_Manager__c = c1.Id;
        update site1;
        site3.HR_Business_Partner__c = c2.Id;
        site3.Site_Manager__c = c2.Id;
        update site3;
        //Add Department
        Department__c department1 = new Department__c();
        department1.Name = '111111';
        department1.Department__c = 'HR';
        department1.Account__c = site2.Id;
        department1.HR_Business_Partner__c = c3.Id;
        department1.Site_Manager__c = c3.Id;
        insert department1;
        Department__c department2 = new Department__c();
        department2.Name = '222222';
        department2.Department__c = 'IT';
        department2.Account__c = site4.Id;
        department2.HR_Business_Partner__c = c4.Id;
        department2.Site_Manager__c = c4.Id;
        insert department2;
        //Add HR Classification and set notification defaults
        Schema.DescribeSObjectResult R = Case__c.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        String caseRecTypeId = RT[0].getRecordTypeId() ;
        HR_Classification__c caseType = new HR_Classification__c();
        caseType.Level_1__c = 'Referral';
        caseType.Level_1__c = 'Career';
        caseType.Name = 'Test';
        caseType.Case_Record_Type__c = caseRecTypeId;
        caseType.Default_Priority__c = '3';
        caseType.Follow_up_Default__c = 2;
        insert caseType;
        
        Case__c case1 = new Case__c(Case_Type_3__c=caseType.Id, Contact__c = testCon1.Id, Caller__c = testCon1.Id);
        insert case1;
        Case__c case2 = new Case__c(Case_Type_3__c=caseType.Id, Contact__c = testCon2.Id, Caller__c = testCon1.Id, Reporting_Department__c = 'HR');
        insert case2;
        Case__c case3 = new Case__c(Case_Type_3__c=caseType.Id, Contact__c = testCon3.Id, Caller__c = testCon1.Id);
        insert case3;
        Case__c case4 = new Case__c(Case_Type_3__c=caseType.Id, Contact__c = testCon4.Id, Caller__c = testCon1.Id, Reporting_Department__c = 'IT');
        insert case4;

        Test.startTest();
        HRSharingRecalc HRBatch = new HRSharingRecalc();
        Database.executeBatch(HRBatch);
        Test.stopTest();
    }
}