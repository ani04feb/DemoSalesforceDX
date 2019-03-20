@isTest
private class CreateUserOnContactHandlerTest
{

    static testMethod void Contactuserupdate1(){
    User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
    List<id> Uid=new List<Id>();
    Contact Con=new Contact();
    Con.Company_Description__c='Supermarket';
    Con.Position_Description__c='Store Support Manager';
    Con.Employee_ID__c='8875670986';
    Con.FirstName='Ftest15';
    Con.LastName='Ltest15';
    Con.Team_Member_Status__c='Active';
    //Con.Federation_ID__c=u1.federationidentifier;
    Con.User__c=u1.Id;
    Con.AccountId='0016F00001fiaH4QAI';
    insert Con; 
    Uid.add(Con.User__c);
    test.startTest();
    Con.Team_Member_Status__c='Terminated';
    update Con;
    //CreateUserOnContactHandler.updateUSer(Uid);
    test.stopTest();
    }
    
    static testMethod void Contactuserupdate2(){
    User u2= [SELECT Id FROM User WHERE IsActive = false LIMIT 1];
    List<id> Uid=new List<Id>();
    Contact Con=new Contact();
    Con.Company_Description__c='Supermarket';
    Con.Position_Description__c='Caretaking Store Support Manager';
    Con.Employee_ID__c='8875670987';
    Con.FirstName='Ftest16';
    Con.LastName='Ltest16';
    Con.Team_Member_Status__c='Terminated';
    Con.Federation_ID__c='tutasa16';
    Con.AccountId='0016F00001fiaH4QAI';
    Con.User__c=u2.Id;
    insert Con; 
    Uid.add(Con.User__c);
    test.startTest();
    Con.Team_Member_Status__c='Active';
    update Con;
    //CreateUserOnContactHandler.ActivateConUserList(Uid);
    test.stopTest();
    }
    static testMethod void TakeAccountLicence(){
    Account acc=new Account();
    acc.Id='0016F00001fiaH4QAI';
    test.startTest();
    acc.Store_Closed_Date__c=date.parse('21/07/2017');
    update acc;
    test.stopTest();
    }
    /*
   static testMethod void ChangeRole(){
        Account acc1 = new Account(Name='Test1', Brand__c='Supermarkets');
        insert acc1;
        User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        User u2= [SELECT Id FROM User WHERE IsActive = true order by name desc LIMIT 1 ];
        Contact c1 = new Contact(LastName = 'test1', Email = 'test1@test.com', AccountId = acc1.Id,User__c=u1.Id,Position_Description__c='Caretaking Store Manager');
        insert c1;
        Account acc2 = new Account(Name='Test2', Brand__c='Supermarkets');
        insert acc2;
        Contact c2 = new Contact(LastName = 'Site Assistant Mgr', Email = 'test2@test.com', AccountId = acc2.Id,User__c=u2.Id,Position_Description__c='Caretaking Store Manager');
        insert c2;
    test.startTest();
        c2.AccountId = acc1.Id;
        c1.AccountId = acc2.Id;
        update c2;
        update c1;
    test.stopTest();
    }
    */

}