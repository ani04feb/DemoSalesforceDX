trigger AssignRoletoUser on Contact (after update) {

  List<id> LstCont = new List<id>();
  List<id> FinalCont = new List<id>();

if(trigger.isUpdate){
  for (Contact c : Trigger.new) {
      if(c.accountid != Trigger.OldMap.get(c.Id).accountid) {
       LstCont.add(c.id); 
    } 
  }
  List<Contact> FinalLstCont=[Select id from contact where (Position_Description__c='Caretaking Store Manager' OR Position_Description__c='Store Manager' OR Position_Description__c='Store Manager' OR Position_Description__c='Store Support Manager' OR Position_Description__c='Caretaking Store Support Manager' OR Position_Description__c='Trading Manager Nights 'OR Position_Description__c='Store Support Manager' OR Position_Description__c='Caretaking Store Support Manager' OR Position_Description__c='Trading Manager Fresh' OR Position_Description__c='Trading Manager Grocery/Dairy' OR Position_Description__c='Duty Manager' OR Position_Description__c='Caretaking Duty Manager' OR Position_Description__c='Dry Goods Manager' OR Position_Description__c='Caretaking Dry Goods Manager' OR Position_Description__c='DMTL') AND account.brand__c='Supermarkets' AND id IN:LstCont];
  System.debug('@@@@@@@@@@@@@@@TrigeerListCont'+LstCont);
  for(Contact cn:FinalLstCont)
  {
  FinalCont.add(cn.id);
  }
  if(FinalCont.size()>0)
  CreateUserOnContactHandler.updateUserRole(FinalCont);
}
  }