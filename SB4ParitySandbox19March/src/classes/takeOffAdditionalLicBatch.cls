global class takeOffAdditionalLicBatch implements Database.Batchable<sObject>{
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query ='Select id,user__c,account.IsSupermarket__c,Position_Description__c,account.Active_Licence__c from contact where user__c!=NULL and account.IsSupermarket__c!=null and account.Active_Licence__c>2';

        System.debug('Query *********'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Contact> scope) {
    System.debug('Scope@@@@@@@@'+scope);
       List<Id> uList=new List<Id>();
        for(Contact Cn : scope){
            if((Cn.Position_Description__c!='Store Manager' )&&(Cn.Position_Description__c!='Site Mgr')&&(Cn.Position_Description__c!='Caretaking Store Manager')&&(Cn.Position_Description__c!='csm'))
            uList.add(Cn.user__c);
            
        }
        System.debug('UserList1 *********'+uList);
        //List<Contact>CbList=[Select id,user__c,Position_Description__c,account.Active_Licence__c from contact where user__c IN:uList and (Position_Description__c!='Store Manager' AND Position_Description__c!='Caretaking Store Manager' AND Position_Description__c!='Night Store Manager')];
        List<User> userList=[Select id,isActive from user where id IN:uList];
        System.debug('UserList2 *********'+userList);
        for(User us:userList)
        {
            us.isActive=false;
        }
        if(userList.size() > 0){
                       Update userList;
                            }
    }
    
     global void finish(Database.BatchableContext BC) {
     
     }
    

}