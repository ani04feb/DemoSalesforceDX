@istest(seealldata=true)
private class SignedContractsTest
{
public static testMethod void test1()
{
User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
Account acc=[select id,name from account where RMS_Number__c!=null limit 1];
    Contract__c cont=new Contract__c();
    cont.recordtypeid='012900000009h4g';
    cont.ownerid=u1.Id;
    cont.Account__c=acc.Id;
    cont.Name='Contract1';
    cont.Signed_CB_T_Cs__c=false;
    insert cont;
    
    try{
    Attachment attachment = new Attachment(Name='Coles Brand Terms and Conditions(Signed)',body=blob.valueof('b'),parentId=acc.Id);
    test.startTest();
    insert attachment;
    test.stopTest();
    }
    catch(Exception e){
            System.debug('An exception occurred: ' + e.getMessage());

    }
}
}