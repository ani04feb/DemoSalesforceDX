trigger DeactivateUseronLOA on Contact (after update) {

  List<id> LstActCont = new List<id>();
  List<id> LstDeActCont = new List<id>();

if(trigger.isUpdate){
  for (Contact c : Trigger.new) {
       if(Trigger.OldMap.get(c.Id).on_LOA__c!= c.on_LOA__c && c.on_LOA__c== True) {
       LstDeActCont.add(c.User__c);
    } 
    else if(Trigger.OldMap.get(c.Id).on_LOA__c!= c.on_LOA__c && c.on_LOA__c== False)
    {
       LstActCont.add(c.User__c); 
    }
  }
  System.debug('@@@@@@@@@@@@@@@TriggerListCont'+LstActCont );
  System.debug('@@@@@@@@@@@@@@@TriggerLstDeActCont '+LstDeActCont );
  if(LstDeActCont .size()>0)
  {
  CreateUserOnContactHandler.updateUSer(LstDeActCont);
  }
  if(LstActCont.size()>0)
  {
  CreateUserOnContactHandler.ActivateConUserList(LstActCont);
  }
}
  }