global class takeOffInvalidLicBatch implements Database.Batchable<sObject>{
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        String query ='Select id,user__c,Position_Description__c,account.Active_Licence__c,account.brand__c from contact where user__c!=NULL ';

        System.debug('Query *********'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Contact> scope) {
    System.debug('Scope@@@@@@@@'+scope);
       List<Id> uList=new List<Id>();
       for(Contact Cn : scope){
        if((Cn.account.brand__c=='Supermarkets')&&(Cn.Position_Description__c!='Store Manager' )&&(Cn.Position_Description__c!='Caretaking Store Manager' )&&(Cn.Position_Description__c!='Store Support Manager')&&(Cn.Position_Description__c!='Caretaking Store Support Manager')&&(Cn.Position_Description__c!='Trading Manager Grocery/Dairy')&&(Cn.Position_Description__c!='Trading Manager Fresh')&&(Cn.Position_Description__c!='Trading Manager Nights')&&(Cn.Position_Description__c!='Duty Manager')&&(Cn.Position_Description__c!='Caretaking Duty Manager')&&(Cn.Position_Description__c!='Dry Goods Manager')&&(Cn.Position_Description__c!='Caretaking Dry Goods Manager')&&(Cn.Position_Description__c!='DMTL'))
            uList.add(Cn.user__c);
        }
        System.debug('UserList1 *********'+uList);
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