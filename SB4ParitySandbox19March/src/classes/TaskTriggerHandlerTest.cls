@isTest
private class TaskTriggerHandlerTest 
{
    private static testMethod void testStatusUpdate() 
    {
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Account acc1 = new Account(Name='Test1', Brand__c='Liquorland');
        insert acc1;
        Contact c = new Contact(FirstName = 'Test', LastName = 'Test', AccountId = acc1.Id, User__c = u.Id);
        insert c;
        acc1.Site_Manager__c = c.Id;
        update acc1;
        
        Risk_Assessment__c ra = new Risk_Assessment__c(Brand__c='Liquorland', Location__c = acc1.Id);
        Regulator_Management__c rm = new Regulator_Management__c(Brand__c='Liquorland', Location__c = acc1.Id);
        Investigation__c inv = new Investigation__c();
        Business_Assurance__c ba = new Business_Assurance__c(Brand__c='Liquorland', Location__c = acc1.Id, Date_of_Audit__c = Date.Today());
        
        insert ra;
        insert rm;
        insert inv;
        insert ba;
        
        Id correctiveActionId = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= 'Corrective_Action' LIMIT 1].Id;
        Task t1 = new Task(recordTypeId = correctiveActionId, whatId = ra.Id, Subject = 'Test1');
        Task t2_1 = new Task(recordTypeId = correctiveActionId, whatId = rm.Id, Subject = 'Test2_1');
        Task t2_2 = new Task(recordTypeId = correctiveActionId, whatId = rm.Id, Subject = 'Test2_2');
        Task t3 = new Task(recordTypeId = correctiveActionId, whatId = inv.Id, Subject = 'Test3');
        Task t4 = new Task(recordTypeId = correctiveActionId, whatId = ba.Id, Subject = 'Test4');
        
        insert t1;
        insert t2_1;
        insert t2_2;
        insert t3;
        insert t4;
        
        t1.Status = 'Completed';
        update t1;
        System.AssertEquals('Closed Pending Review', [SELECT Status__c FROM Risk_Assessment__c WHERE Id = :ra.Id LIMIT 1].Status__c);
        
        t2_1.Status = 'Completed';
        update t2_1;
        System.AssertEquals('Open', [SELECT Status__c FROM Regulator_Management__c WHERE Id = :rm.Id LIMIT 1].Status__c);
        
        t2_2.Status = 'Completed';
        update t2_2;
        System.AssertEquals('Closed Pending Review', [SELECT Status__c FROM Regulator_Management__c WHERE Id = :rm.Id LIMIT 1].Status__c);        

        t3.Status = 'Completed';
        update t3;
        System.AssertEquals('Closed Pending Review', [SELECT Status__c FROM Investigation__c WHERE Id = :inv.Id LIMIT 1].Status__c);
        
        t4.Status = 'Completed';
        update t4;
        System.AssertEquals('Closed Pending Review', [SELECT Status__c FROM Business_Assurance__c WHERE Id = :ba.Id LIMIT 1].Status__c);

    }
}