trigger CountActiveUsers on Contact (after insert,after update,after delete) {

  List<Contact> contacts1 = Trigger.isdelete ? trigger.old : trigger.new;
  Set<Id> accountIds = new Set<Id>();

  for (Contact c : contacts1) {
     if (c.accountid != null) {
       accountIds.add(c.accountid);
    } 
  }

list<account> ActUserList = [select Active_Licence__c, (select id from contacts where (Position_Description__c='Store Manager' OR 
        Position_Description__c='Caretaking Store Manager' OR 
        Position_Description__c='Store Support Manager' OR 
        Position_Description__c='Caretaking Store Support Manager' OR 
        Position_Description__c='Trading Manager Grocery/Dairy' OR 
        Position_Description__c='Trading Manager Fresh' OR 
        Position_Description__c='Trading Manager Nights' OR 
        Position_Description__c='Duty Manager' OR 
        Position_Description__c='Caretaking Duty Manager' OR 
        Position_Description__c='Dry Goods Manager' OR 
        Position_Description__c='Caretaking Dry Goods Manager' OR 
        Position_Description__c='SSM' OR 
        Position_Description__c='CSM' OR 
        Position_Description__c='DMTL') AND   Team_Member_Status__c='active' AND user__r.isactive=true) from account where id In :accountIds];

 for(account a :ActUserList )  {
   a.Active_Licence__c = a.contacts.size();
 }
 update ActUserList ;
}