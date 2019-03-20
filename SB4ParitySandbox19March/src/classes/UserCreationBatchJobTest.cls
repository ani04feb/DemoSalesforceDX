@isTest
private class UserCreationBatchJobTest
{

static testMethod void userCreationScenario1()
{
    
   Account acc1 = new Account(Name='Test1', Brand__c='Supermarkets');
        insert acc1;
        System.debug('Account Detail@@@@'+acc1);
        Contact c1 = new Contact(LastName = 'test01', Email = 'test01@test.com', AccountId = acc1.Id,Position_Description__c='Store Manager',Federation_ID__c='testsm01',Employee_ID__c='12345001',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c1;
        System.debug('Contact 1 Detail@@@@'+c1);
        Contact c2 = new Contact(LastName = 'test02', Email = 'test02@test.com', AccountId = acc1.Id,Position_Description__c='Caretaking Store Manager',Federation_ID__c='tstcsm02',Employee_ID__c='12345002',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c2;
        System.debug('Contact 2 Detail@@@@'+c2);
        Contact c3 = new Contact(LastName = 'test03', Email = 'test03@test.com', AccountId = acc1.Id,Position_Description__c='Store Support Manager',Federation_ID__c='tstssm03',Employee_ID__c='12345003',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c3;  
        System.debug('Contact 3 Detail@@@@'+c3);        
        Contact c4 = new Contact(LastName = 'test04', Email = 'test04@test.com', AccountId = acc1.Id,Position_Description__c='Caretaking Store Support Manager',Federation_ID__c='tscssm04',Employee_ID__c='12345004',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c4; 
        System.debug('Contact 4 Detail@@@@'+c4);    
        Contact c5 = new Contact(LastName = 'test05', Email = 'test05@test.com', AccountId = acc1.Id,Position_Description__c='Trading Manager Grocery/Dairy',Federation_ID__c='tsttmg05',Employee_ID__c='12345005',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c5; 
        System.debug('Contact 5 Detail@@@@'+c5);        
        test.startTest();
        UserCreationBatchJob b = new UserCreationBatchJob(); 
        database.executebatch(b);
        test.stopTest();
        
    }
    static testMethod void userCreationScenario2()
    {
    
        Account acc2 = new Account(Name='Test2', Brand__c='Supermarkets');
        insert acc2;
        System.debug('Account Detail@@@@'+acc2);
        Contact c1 = new Contact(LastName = 'test11', Email = 'test11@test.com', AccountId = acc2.Id,Position_Description__c='Trading Manager Fresh',Federation_ID__c='tsttmg11',Employee_ID__c='12345011',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c1;
        System.debug('Contact 1 Detail@@@@'+c1);
        Contact c2 = new Contact(LastName = 'test12', Email = 'test12@test.com', AccountId = acc2.Id,Position_Description__c='Trading Manager Nights',Federation_ID__c='tsttmn12',Employee_ID__c='12345012',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c2;
        System.debug('Contact 2 Detail@@@@'+c2);
        Contact c3 = new Contact(LastName = 'test13', Email = 'test13@test.com', AccountId = acc2.Id,Position_Description__c='Duty Manager',Federation_ID__c='testdm13',Employee_ID__c='12345013',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c3;  
        System.debug('Contact 3 Detail@@@@'+c3);        
        Contact c4 = new Contact(LastName = 'test14', Email = 'test14@test.com', AccountId = acc2.Id,Position_Description__c='Caretaking Duty Manager',Federation_ID__c='tstcdm14',Employee_ID__c='12345014',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c4; 
        System.debug('Contact 4 Detail@@@@'+c4);    
        Contact c5 = new Contact(LastName = 'test15', Email = 'test15@test.com', AccountId = acc2.Id,Position_Description__c='Dry Goods Manager',Federation_ID__c='tstdgm15',Employee_ID__c='12345015',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c5; 
        System.debug('Contact 5 Detail@@@@'+c5);        
        test.startTest();
        UserCreationBatchJob b = new UserCreationBatchJob(); 
        database.executebatch(b);
        test.stopTest();
        
    }
    static testMethod void userCreationScenario3()
    {
    
        Account acc3 = new Account(Name='Test3', Brand__c='Supermarkets');
        insert acc3;
        System.debug('Account Detail@@@@'+acc3);
        Contact c1 = new Contact(LastName = 'test21', Email = 'test21@test.com', AccountId = acc3.Id,Position_Description__c='Caretaking Dry Goods Manager',Federation_ID__c='tscdgm21',Employee_ID__c='12345021',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c1;
        System.debug('Contact 1 Detail@@@@'+c1);
        Contact c2 = new Contact(LastName = 'test22', Email = 'test22@test.com', AccountId = acc3.Id,Position_Description__c='DMTL',Federation_ID__c='tsdmtl22',Employee_ID__c='12345022',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c2;
        System.debug('Contact 2 Detail@@@@'+c2);        
        test.startTest();
        UserCreationBatchJob b = new UserCreationBatchJob(); 
        database.executebatch(b);
        test.stopTest();
        
    }
        static testMethod void userCreationScenario4()
    {
    
        Account acc4 = new Account(Name='Test4', Brand__c='Supermarkets');
        insert acc4;
        System.debug('Account Detail@@@@'+acc4);
        Contact c1 = new Contact(LastName = 'test31', Email = 'test31@test.com', AccountId = acc4.Id,Position_Description__c='Store Manager',Federation_ID__c='testsm31',Employee_ID__c='12345031',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c1;
        System.debug('Contact 1 Detail@@@@'+c1);
        Contact c2 = new Contact(LastName = 'test32', Email = 'test32@test.com', AccountId = acc4.Id,Position_Description__c='Store Manager',Federation_ID__c='testsm32',Employee_ID__c='12345032',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c2;
        System.debug('Contact 2 Detail@@@@'+c2);    
        Contact c3 = new Contact(LastName = 'test33', Email = 'test33@test.com', AccountId = acc4.Id,Position_Description__c='Caretaking Store Manager',Federation_ID__c='tstcsm33',Employee_ID__c='12345033',Team_Member_Status__c='Active',Company_Description__c='Supermarkets');
        insert c3;
        System.debug('Contact 3 Detail@@@@'+c3);        
        test.startTest();
        UserCreationBatchJob b = new UserCreationBatchJob(); 
        database.executebatch(b);
        test.stopTest();
        
    }
    
    
  }