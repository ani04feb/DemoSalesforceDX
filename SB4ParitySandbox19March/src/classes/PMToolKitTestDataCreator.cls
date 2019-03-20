public with sharing class PMToolKitTestDataCreator {

    public static void dataCreator() {
        
        RecordType MyRT;
        
        //Creating test program
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Program' AND SobjectType = 'Project__c'];
        Project__c TestProgram = new Project__c();
        TestProgram.Name = 'Unit Test Program';
        TestProgram.State__c = 'Open';
        TestProgram.RecordTypeId = MyRT.Id;
        insert TestProgram;
       
        //Creating test project
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Project' AND SobjectType = 'Project__c']; 
        Project__c TestProject = new Project__c();
        TestProject.Name = 'Unit Test Project';
        TestProject.State__c = 'Open';
        TestProject.RecordTypeId = MyRT.Id;
        TestProject.Program__c = TestProgram.Id;
        insert TestProject;
        
        //Creating test release
        SS_Release__c TestRelease = new SS_Release__c();
        TestRelease.Name = 'Unit Test Release';
        TestRelease.State__c = 'Active';
        TestRelease.Start_date__c = date.newInstance(2013,5,30);
        TestRelease.Release_date__c = date.newInstance(2014,5,30);
        TestRelease.Project__c = TestProject.ID;
        insert TestRelease;
        
        //Creating test iteration #1
        Iteration__c TestIteration = new Iteration__c();
        TestIteration.Name = 'Unit Test Iteration';
        TestIteration.State__c = 'Active';
        TestIteration.Start_date__c = date.newInstance(2013,5,30);
        TestIteration.End_date__c = date.newInstance(2013,6,30);
        TestIteration.Project__c = TestProject.ID;
        insert TestIteration;
        
        //Creating test iteration #2
        Iteration__c TestIteration2 = new Iteration__c();
        TestIteration2.Name = 'Unit Test Iteration 2';
        TestIteration2.State__c = 'Active';
        TestIteration2.Start_date__c = date.newInstance(2013,5,30);
        TestIteration2.End_date__c = date.newInstance(2013,6,30);
        TestIteration2.Project__c = TestProject.ID;
        insert TestIteration2;
        
        //Creating test parent work product
        myRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Parent User Story' AND SobjectType = 'Work_Product__c'];
        Work_Product__c TestParentWP = new Work_Product__c();
        TestParentWP.name = 'Test User Story Parent';
        TestParentWP.RecordTypeID = myRT.id;
        TestParentWP.Project__c = testProject.id;
        insert TestParentWP;
        
        //Creating test work product #1
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'User Story' AND SobjectType = 'Work_Product__c'];
        Work_Product__c Test_US1 = new Work_Product__c();
        Test_US1.Name = 'Test User Story 1';
        Test_US1.RecordTypeId = MyRT.Id;
        Test_US1.Project__c = TestProject.Id;  
        Test_US1.Iteration__c = TestIteration.id;
        Test_US1.SS_release__c = TestRelease.id;    
        insert Test_US1;
        
        //Creating test work product #2
        Work_Product__c Test_US2 = new Work_Product__c();
        Test_US2.Name = 'Test User Story 2';
        Test_US2.RecordTypeId = MyRT.Id;
        Test_US2.Project__c = TestProject.Id;
        Test_US2.Iteration__c = TestIteration.id;
        Test_US2.SS_release__c = TestRelease.id;  
        insert Test_US2;
      
      	//Creating test defect
        MyRT = [SELECT Id, Name FROM RecordType WHERE Name = 'Defect' AND SobjectType = 'Work_Product__c'];
        Work_Product__c Test_Defect1 = new Work_Product__c();
        Test_Defect1.Name = 'Test Defect 1';
        Test_Defect1.RecordTypeId = MyRT.Id;
        Test_Defect1.Project__c = TestProject.Id;
        Test_Defect1.Description__c = 'Terrible Defect.';
        Test_Defect1.Priority__c = '4 - Low';
        Test_Defect1.Severity__c = '4 - Cosmetic';
        Test_Defect1.Type__c = 'Bug';
        Test_Defect1.Defect_State__c = 'Open';
        Test_Defect1.Steps_to_Reproduce__c = 'Steps to reproduce.';
        insert Test_Defect1;
    }


}