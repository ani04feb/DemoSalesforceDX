/** 
 *  Test Class for zreg.regulatoryManagement
 */
 @isTest
 private class zregulatoryManagementTest{
     
   /*-------------------------------------------------------------
    Author:         Rohit Kumar
    Company:        Salesforce
    Description:   This class is responsible for testing the code of 'zreg.regulatoryManagementTest' class.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    09-Jul-15    Rohit              Initial Version
    ------------------------------------------------------------*/
    Static User userRecord ;
    Static Account accountRecord;
    Static Contact contactRecord;
    static void setupData(){
        // Create User
          userRecord = [select id from user where profileid='00e90000001VULf' and isActive=true limit 1];

        // Create Account
         accountRecord = (Account) TestUtil.createSobject(1, true, new Map<String, Object>{
                                                                    'Name' => 'Coles',
                                                                    'Brand__c' => 'Liquorland',
                                                                    'Sub_Brand__c' => 'Liquorland'
                                                                  }, 'Account')[0];
        // Create Contact
        contactRecord =(Contact) TestUtil.CreateSobject(1,true,new Map<String,Object>{
                                                                        'LastName' => 'Adam',
                                                                        'AccountId' => accountRecord.Id,
                                                                        'User__c' => userRecord.id
                                                                        }, 'Contact')[0];
                System.debug('***con'+contactRecord.User__c);
    }  
    
   // Test Method for reg.regulatory Management controller class
    static testMethod void Testregulatory(){
        setupData();
        PageReference pr = new PageReference('/apex/zreg.regulatoryManagement');
        Test.setCurrentPage(pr);
        // Define ontroller reference
        zregulatoryManagement reg= new zregulatoryManagement();
        
        reg.regulatory.Brand__c = 'Liquorland';
        reg.regulatory.Location__c = accountRecord.id;
        reg.regulatory.Site_Manager__c = contactRecord.id;
        reg.regulatory.Site_Assistant_Manager__c = contactRecord.id;
        reg.regulatory.Reporting_Person__c = contactRecord.id;
        reg.regulatory.Date_of_Contact__c = Date.Today() ;
        reg.regulatory.Reason_for_Contact_Visit__c = 'Annual Food Inspection' ;
        reg.regulatory.Compliance_Category__c = 'Chain of Responsibility' ;
        reg.regulatory.Other_Reason_for_Contact_Visit__c = 'Test' ;
        reg.regulatory.Description_of_Contact__c = 'Test' ;
        reg.regulatory.regulatory_Body__c = 'Test';
        reg.regulatory.Phone__c = '123445678' ;
        reg.regulatory.Name_of_Inspector__c = '12';
        reg.regulatory.Email__c = 'test@test.com';
        reg.regulatory.Issues_Identified__c = 'Yes';
        reg.regulatory.Non_Compliance_Details__c = 'Test' ;
        reg.regulatory.Paperwork_Left__c = 'Yes';
        reg.regulatory.Notice_Type__c = 'NMI Non-Compliance Notice' ;
        reg.regulatory.Reference_Number__c = 'reference' ;
        reg.regulatory.Outcome_Type__c = 'Court Order' ;
        reg.regulatory.Description_of_Findings__c = 'Test' ;
        reg.regulatory.Reportable_to_the_Board__c = 'Yes' ;
        // reg.regulatory.Report__c = 'Test' ;
        
        // Create Task Immediate
        reg.getActionItemTypes();
        reg.getActionItemStatuses();
        zregulatoryManagement.searchUser('rohit');
        
        list<zregulatoryManagement.clsTask> recordList = new list<zregulatoryManagement.clsTask>();
        zregulatoryManagement.clsTask record = new zregulatoryManagement.clsTask();
        
        //reg.addImmediateCorrectiveActionRow();
        //reg.addNewCorrectiveActionRow();
    
        reg.ImmediateTasks[0].Type = 'test';
        reg.ImmediateTasks[0].Subject = 'testSubject';
        reg.ImmediateTasks[0].ActivityDate = Date.today().format();
        reg.ImmediateTasks[0].DateCompleted = Date.today().format();
        reg.ImmediateTasks[0].Status = 'Completed';
        reg.ImmediateTasks[0].JobNumber = '1234';
        reg.ImmediateTasks[0].OwnerName = 'Rohit Kumar';
        reg.ImmediateTasks[0].Action  = 'ActionTest';
        reg.ImmediateTasks[0].Comments = 'CommentsTest';
        reg.ImmediateTasks[0].searchTerm = 'Rohit';
        reg.ImmediateTasks[0].selectedUser = userRecord.id;
        reg.ImmediateTasks[0].CompletedBy = 'rohit kumar';
        
        //Corrective Action
        reg.CorrectiveTasks[0].Type = 'test';
        reg.CorrectiveTasks[0].Subject = 'testSubject';
        reg.CorrectiveTasks[0].ActivityDate = Date.today().format();
        reg.CorrectiveTasks[0].DateCompleted = Date.today().format();
        reg.CorrectiveTasks[0].Status = 'Completed';
        reg.CorrectiveTasks[0].JobNumber = '1234';
        reg.CorrectiveTasks[0].OwnerName = 'Rohit Kumar';
        reg.CorrectiveTasks[0].Action  = 'ActionTest';
        reg.CorrectiveTasks[0].Comments = 'CommentsTest';
        reg.CorrectiveTasks[0].searchTerm = 'Rohit';
        reg.CorrectiveTasks[0].selectedUser = userRecord.id;
        reg.CorrectiveTasks[0].CompletedBy = 'rohit kumar';
        
        // Save Method
        reg.save() ;
        
        reg.cancel();
        
        
    }
    // Test Method for reg.regulatory Management controller class
    static testMethod void TestregulatorySecondTestCase(){
        setupData();
        PageReference pr = new PageReference('/apex/zreg.regulatoryManagement');
        Test.setCurrentPage(pr);
        // Define ontroller reference
        zregulatoryManagement reg= new zregulatoryManagement();
        
        reg.regulatory.Brand__c = 'Liquorland';
        reg.regulatory.Location__c = accountRecord.id;
        reg.regulatory.Regional_Manager__c = contactRecord.id;
        reg.regulatory.Reporting_Person__c = contactRecord.id;
        reg.regulatory.Date_of_Contact__c = Date.Today() ;
        reg.regulatory.Reason_for_Contact_Visit__c = 'Annual Food Inspection' ;
        reg.regulatory.Compliance_Category__c = 'Chain of Responsibility' ;
        reg.regulatory.Other_Reason_for_Contact_Visit__c = 'Test' ;
        reg.regulatory.Description_of_Contact__c = 'Test' ;
        reg.regulatory.regulatory_Body__c = 'Test';
        reg.regulatory.Phone__c = '123445678' ;
        reg.regulatory.Name_of_Inspector__c = '12';
        reg.regulatory.Email__c = 'test@test.com';
        reg.regulatory.Issues_Identified__c = 'Yes';
        reg.regulatory.Non_Compliance_Details__c = 'Test' ;
        reg.regulatory.Paperwork_Left__c = 'Yes';
        reg.regulatory.Notice_Type__c = 'NMI Non-Compliance Notice' ;
        reg.regulatory.Reference_Number__c = 'reference' ;
        reg.regulatory.Outcome_Type__c = 'Court Order' ;
        reg.regulatory.Description_of_Findings__c = 'Test' ;
        reg.regulatory.Reportable_to_the_Board__c = 'Yes' ;
        // reg.regulatory.Report__c = 'Test' ;
        
        // Create Task Immediate
        reg.getActionItemTypes();
        reg.getActionItemStatuses();
        zregulatoryManagement.searchUser('rohit');
        
        list<zregulatoryManagement.clsTask> recordList = new list<zregulatoryManagement.clsTask>();
        zregulatoryManagement.clsTask record = new zregulatoryManagement.clsTask();
        
        //reg.addImmediateCorrectiveActionRow();
        //reg.addNewCorrectiveActionRow();
    
        reg.ImmediateTasks[0].Type = 'test';
        reg.ImmediateTasks[0].Subject = 'testSubject';
        reg.ImmediateTasks[0].ActivityDate = Date.today().format();
        reg.ImmediateTasks[0].DateCompleted = Date.today().format();
        reg.ImmediateTasks[0].Status = 'Completed';
        reg.ImmediateTasks[0].JobNumber = '1234';
        reg.ImmediateTasks[0].OwnerName = 'Rohit Kumar';
        reg.ImmediateTasks[0].Action  = 'ActionTest';
        reg.ImmediateTasks[0].Comments = 'CommentsTest';
        reg.ImmediateTasks[0].searchTerm = 'Rohit';
        reg.ImmediateTasks[0].selectedUser = userRecord.id;
        reg.ImmediateTasks[0].CompletedBy = 'rohit kumar';
        
        //Corrective Action
        reg.CorrectiveTasks[0].Type = 'test';
        reg.CorrectiveTasks[0].Subject = 'testSubject';
        reg.CorrectiveTasks[0].ActivityDate = Date.today().format();
        reg.CorrectiveTasks[0].DateCompleted = Date.today().format();
        reg.CorrectiveTasks[0].Status = 'Completed';
        reg.CorrectiveTasks[0].JobNumber = '1234';
        reg.CorrectiveTasks[0].OwnerName = 'Rohit Kumar';
        reg.CorrectiveTasks[0].Action  = 'ActionTest';
        reg.CorrectiveTasks[0].Comments = 'CommentsTest';
        reg.CorrectiveTasks[0].searchTerm = 'Rohit';
        reg.CorrectiveTasks[0].selectedUser = userRecord.id;
        reg.CorrectiveTasks[0].CompletedBy = 'rohit kumar';
        
        // Save Method
        reg.save() ;
        
        reg.cancel();
        
        
    }
    // Test Method for reg.regulatory Management controller class
    static testMethod void TestregulatoryThirdTestCase(){
        setupData();
        PageReference pr = new PageReference('/apex/zreg.regulatoryManagement');
        Test.setCurrentPage(pr);
        // Define ontroller reference
        zregulatoryManagement reg= new zregulatoryManagement();
        
        reg.regulatory.Brand__c = 'Liquorland';
        reg.regulatory.Location__c = accountRecord.id;
        reg.regulatory.Site_Manager__c = contactRecord.id;
        reg.regulatory.Site_Assistant_Manager__c = contactRecord.id;
        reg.regulatory.Reporting_Person__c = contactRecord.id;
        reg.regulatory.Date_of_Contact__c = Date.Today() ;
        reg.regulatory.Reason_for_Contact_Visit__c = 'Annual Food Inspection' ;
        reg.regulatory.Compliance_Category__c = 'Chain of Responsibility' ;
        reg.regulatory.Other_Reason_for_Contact_Visit__c = 'Test' ;
        reg.regulatory.Description_of_Contact__c = 'Test' ;
        reg.regulatory.regulatory_Body__c = 'Test';
        reg.regulatory.Phone__c = '123445678' ;
        reg.regulatory.Name_of_Inspector__c = '12';
        reg.regulatory.Email__c = 'test@test.com';
        reg.regulatory.Issues_Identified__c = 'Yes';
        reg.regulatory.Non_Compliance_Details__c = 'Test' ;
        reg.regulatory.Paperwork_Left__c = 'Yes';
        reg.regulatory.Notice_Type__c = 'NMI Non-Compliance Notice' ;
        reg.regulatory.Reference_Number__c = 'reference' ;
        reg.regulatory.Outcome_Type__c = 'Court Order' ;
        reg.regulatory.Description_of_Findings__c = 'Test' ;
        reg.regulatory.Reportable_to_the_Board__c = 'Yes' ;
        // reg.regulatory.Report__c = 'Test' ;
        
        // Create Task Immediate
        reg.getActionItemTypes();
        reg.getActionItemStatuses();
        zregulatoryManagement.searchUser('rohit');
        
        list<zregulatoryManagement.clsTask> recordList = new list<zregulatoryManagement.clsTask>();
        zregulatoryManagement.clsTask record = new zregulatoryManagement.clsTask();
        // Save Method
        reg.save() ;
        
        reg.cancel();
    }
      // Test Method for reg.regulatory Management controller class
    static testMethod void TestregulatoryFourthTestCase(){
        setupData();
        PageReference pr = new PageReference('/apex/zreg.regulatoryManagement');
        Test.setCurrentPage(pr);
        // Define ontroller reference
        zregulatoryManagement reg= new zregulatoryManagement();
        
        reg.regulatory.Brand__c = 'Liquorland';
        reg.regulatory.Location__c = accountRecord.id;
        reg.regulatory.Regional_Manager__c = contactRecord.id;
        reg.regulatory.Reporting_Person__c = contactRecord.id;
        reg.regulatory.Date_of_Contact__c = Date.Today() ;
        reg.regulatory.Reason_for_Contact_Visit__c = 'Annual Food Inspection' ;
        reg.regulatory.Compliance_Category__c = 'Chain of Responsibility' ;
        reg.regulatory.Other_Reason_for_Contact_Visit__c = 'Test' ;
        reg.regulatory.Description_of_Contact__c = 'Test' ;
        reg.regulatory.regulatory_Body__c = 'Test';
        reg.regulatory.Phone__c = '123445678' ;
        reg.regulatory.Name_of_Inspector__c = '12';
        reg.regulatory.Email__c = 'test@test.com';
        reg.regulatory.Issues_Identified__c = 'Yes';
        reg.regulatory.Non_Compliance_Details__c = 'Test' ;
        reg.regulatory.Paperwork_Left__c = 'Yes';
        reg.regulatory.Notice_Type__c = 'NMI Non-Compliance Notice' ;
        reg.regulatory.Reference_Number__c = 'reference' ;
        reg.regulatory.Outcome_Type__c = 'Court Order' ;
        reg.regulatory.Description_of_Findings__c = 'Test' ;
        reg.regulatory.Reportable_to_the_Board__c = 'Yes' ;
        // reg.regulatory.Report__c = 'Test' ;
        
        // Create Task Immediate
        reg.getActionItemTypes();
        reg.getActionItemStatuses();
        zregulatoryManagement.searchUser('rohit');
        
        list<zregulatoryManagement.clsTask> recordList = new list<zregulatoryManagement.clsTask>();
        zregulatoryManagement.clsTask record = new zregulatoryManagement.clsTask();
        
        //reg.addImmediateCorrectiveActionRow();
        //reg.addNewCorrectiveActionRow();
    
        reg.ImmediateTasks[0].Type = 'test';
        reg.ImmediateTasks[0].Subject = 'testSubject';
        reg.ImmediateTasks[0].ActivityDate = Date.today().format();
        reg.ImmediateTasks[0].DateCompleted = Date.today().format();
        reg.ImmediateTasks[0].Status = 'Completed';
        reg.ImmediateTasks[0].JobNumber = '1234';
        reg.ImmediateTasks[0].OwnerName = 'Rohit Kumar';
        reg.ImmediateTasks[0].Action  = 'ActionTest';
        reg.ImmediateTasks[0].Comments = 'CommentsTest';
        reg.ImmediateTasks[0].searchTerm = 'Rohit';
        reg.ImmediateTasks[0].selectedUser = userRecord.id;
        reg.ImmediateTasks[0].CompletedBy = 'rohit kumar';
        
        //Corrective Action
        reg.CorrectiveTasks[0].Type = 'test';
        reg.CorrectiveTasks[0].Subject = 'testSubject';
        reg.CorrectiveTasks[0].ActivityDate = '';
        reg.CorrectiveTasks[0].DateCompleted = '';
        reg.CorrectiveTasks[0].Status = 'Completed';
        reg.CorrectiveTasks[0].JobNumber = '1234';
        reg.CorrectiveTasks[0].OwnerName = 'Rohit Kumar';
        reg.CorrectiveTasks[0].Action  = 'ActionTest';
        reg.CorrectiveTasks[0].Comments = 'CommentsTest';
        reg.CorrectiveTasks[0].searchTerm = 'Rohit';
        reg.CorrectiveTasks[0].selectedUser = userRecord.id;
        reg.CorrectiveTasks[0].CompletedBy = 'rohit kumar';
        
        // Save Method
        reg.save() ;
        
        reg.cancel();
        
        
    }
 }