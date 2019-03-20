@isTest
private class TestNotificationUtilitiesClass {

    static testmethod void test() {
        //Insert Site to link all Contacts to
        Account site = new Account(Name = 'Test Site', Above_Store__c = false);
        insert site;
        //Insert Contacts to act as notification recipients
        List<Contact> notificationList = new List<Contact>();
        //Lookup some user records to associate to the Notification Contacts
        List<User> users = [SELECT Id FROM User WHERE IsActive = true LIMIT 15];
        for(Integer i=0; i<15; i++)
        {
            String testName = 'Test' + i.format();
            Contact c = new Contact(LastName = testName, Email = testName + '@test.com', AccountId = site.Id, User__c = users[i].Id);
            notificationList.add(c);
        }
        insert notificationList;
        //Create test Contact
        Contact testCon = new Contact(LastName = 'target', AccountId = site.Id, Cost_Centre__c = '111111');
        insert testCon;
        //Update Site with Notification Recipients
        site.Apprenticeships__c = notificationList[0].Id;
        site.Corporate_Affairs__c = notificationList[1].Id;
        site.Customer_Social_Media__c = notificationList[2].Id;
        site.Employee_Relations__c = notificationList[3].Id;
        site.Group_Investigations__c = notificationList[4].Id;
        site.Operations_Leadership__c = notificationList[5].Id;
        site.Payroll_Operations__c = notificationList[6].Id;
        site.Safety__c = notificationList[7].Id;
        site.Total_Loss__c = notificationList[8].Id;
        site.Wesfarmers_Legal__c = notificationList[9].Id;
        site.Advisory_Legal_Counsel__c = notificationList[10].Id;
        site.Head_of_Advisory__c = notificationList[11].Id;
        site.HR_Business_Partner__c = notificationList[12].Id;
        site.Regional_Manager__c = notificationList[13].Id;
        site.Site_Manager__c = notificationList[14].Id;
        update site;
        //Add Department
        Department__c department = new Department__c();
        department.Name = '111111';
        department.Department__c = 'HR';
        department.Account__c = site.Id;
        department.Apprenticeships__c = notificationList[14].Id;
        department.Corporate_Affairs__c = notificationList[13].Id;
        department.Customer_Social_Media__c = notificationList[12].Id;
        department.Employee_Relations__c = notificationList[11].Id;
        department.Group_Investigations__c = notificationList[10].Id;
        department.Operations_Leadership__c = notificationList[9].Id;
        department.Payroll_Operations__c = notificationList[8].Id;
        department.Safety__c = notificationList[7].Id;
        department.Total_Loss__c = notificationList[6].Id;
        department.Wesfarmers_Legal__c = notificationList[5].Id;
        department.Advisory_Legal_Counsel__c = notificationList[4].Id;
        department.Head_of_Advisory__c = notificationList[3].Id;
        department.HR_Business_Partner__c = notificationList[2].Id;
        department.Regional_Manager__c = notificationList[1].Id;
        department.Site_Manager__c = notificationList[0].Id;
        insert department;
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
        caseType.Advisory_Legal_Counsel__c = true;
        caseType.Apprenticeships__c = true;
        caseType.Corporate_Affairs__c = true;
        caseType.Customer_Social_Media__c = true;
        caseType.Employee_Relations__c = true;
        caseType.Group_Investigations__c = true;
        caseType.Head_of_Advisory__c = true;
        caseType.HR_Business_Partner__c = true;
        caseType.Operations_Leadership__c = true;
        caseType.Payroll_Operations__c = true;
        caseType.Regional_Manager__c = true;
        caseType.Safety__c = true;
        caseType.Site_Manager__c = true;
        caseType.Total_Loss__c = true;
        caseType.Wesfarmers_Legal__c = true;
        caseType.Other__c = true;
        caseType.Other_Notification__c = 'test';
        caseType.Policy_Owner__c = true;
        caseType.Police__c = true;
        insert caseType;
        
        Test.startTest();
        Case__c c1 = new Case__c(Case_Type_3__c=caseType.Id, Contact__c = testCon.Id, Caller__c = testCon.Id);
        insert c1;
        //test Above Store notifications
        site.Above_Store__c = true;
        update site;
        Case__c c2 = new Case__c(Case_Type_3__c=caseType.Id, Reporting_Department__c='HR', Caller_Reporting_Department__c='HR', Contact__c = testCon.Id, Caller__c = testCon.Id);
        insert c2;
        c2.Reporting_Department__c = 'Operations';
        update c2;
        notificationList[2].User__c = null;
        update notificationList[2];
        notificationList[0].User__c = null;
        update notificationList[0];
        c2.Reporting_Department__c = 'HR';
        update c2;
        Case__c c3 = new Case__c(Case_Type_3__c=caseType.Id, Caller__c = testCon.Id, Caller_Reporting_Department__c='HR');
        insert c3;
        site.Above_Store__c = false;
        site.Apprenticeships__c = null;
        site.Corporate_Affairs__c = null;
        site.Customer_Social_Media__c = null;
        site.Employee_Relations__c = null;
        site.Group_Investigations__c = null;
        site.Operations_Leadership__c = null;
        site.Payroll_Operations__c = null;
        site.Safety__c = null;
        site.Total_Loss__c = null;
        site.Wesfarmers_Legal__c = null;
        site.Advisory_Legal_Counsel__c = null;
        site.Head_of_Advisory__c = null;
        site.HR_Business_Partner__c = null;
        site.Regional_Manager__c = null;
        site.Site_Manager__c = null;
        update site;
        c3.Contact__c = testCon.Id;
        update c3;
        Test.stopTest();
        
    }
}