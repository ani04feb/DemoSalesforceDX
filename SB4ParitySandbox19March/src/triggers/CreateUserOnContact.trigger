trigger CreateUserOnContact on Contact (after update)
{
    List<Id> conIdList = new List<Id>();
    List<Id> deActivateConUserList = new List<Id>();
    List<Id> ActivateConUserList = new List<Id>();

    if(trigger.isUpdate)
    {
            List<Id> conIdList = new List<Id>();
            for(Contact con : Trigger.new){
                if(con.Team_Member_Status__c == 'Terminated' || con.Team_Member_Status__c == 'Inactive')
                 {
                     deActivateConUserList.add(con.User__c);
        
                 }
                 if(((trigger.oldMap.get(con.id).Team_Member_Status__c =='Terminated')||(trigger.oldMap.get(con.id).Team_Member_Status__c =='Inactive'))  && (trigger.newMap.get(con.id).Team_Member_Status__c =='Active' ))
                    {
                        ActivateConUserList.add(con.User__c);    
                    }
   
            }
            System.debug('@@@@@@@@'+deActivateConUserList.size());
            System.debug('@@@@@@@@'+ActivateConUserList.size());
            if(deActivateConUserList.size() > 0)
                    CreateUserOnContactHandler.updateUSer(deActivateConUserList);
                
            if(ActivateConUserList.size() > 0)
                    CreateUserOnContactHandler.ActivateConUserList(ActivateConUserList);
            System.debug('@@@@@@@@'+conIdList.size());
  
    }
}