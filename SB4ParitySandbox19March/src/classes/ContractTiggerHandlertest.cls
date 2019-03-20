@isTest(SeeAllData=true)
private class ContractTiggerHandlertest{

static testMethod void getBCMandGM(){
    Account acc=[select id,name from account where RMS_Number__c!=null limit 1];
    User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
    
    Contact Con1=new Contact();
    Con1.FirstName='GeneralManger';
    Con1.LastName='test1';
    con1.accountid=acc.Id;
    insert Con1;
    system.debug('@@@@@Contact1' +Con1);
    
    Contact Con2=new Contact();
    Con2.FirstName='BCM';
    Con2.LastName='test2';
    Con2.accountid=acc.Id;
    Con2.ReportsToid =Con1.Id;
    insert Con2;
    system.debug('@@@@@Contact2' +Con2);
    
    Contact Con3=new Contact();
    Con3.FirstName='Owner';
    Con3.LastName='test3';
    Con3.accountid=acc.Id;
    Con3.ReportsToid=Con2.Id;
    Con3.User__c=u1.Id;
    insert Con3;
    system.debug('@@@@@Contact3' +Con3);
    
    Contract__c cont=new Contract__c();
    cont.recordtypeid='012900000009h4g';
    cont.ownerid=u1.Id;
    cont.Account__c=acc.Id;
    cont.Name='Contract1';
    //cont.Commencement_Date__c='29/06/2019';
    //cont.Expiry_Date__c='29/06/2025';
    
    test.startTest();
    insert cont;
    test.stopTest();
}

}