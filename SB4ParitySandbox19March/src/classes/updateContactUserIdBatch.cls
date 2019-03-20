global class updateContactUserIdBatch implements Database.Batchable<sObject>{
    
    
    public Database.QueryLocator start(Database.BatchableContext context) {
   String dt =  string.valueof(System.today());
    String dt1=dt+'T00:00:00z';
        String query = 'Select id,username from user where CreatedDate = LAST_N_DAYS:1000';
        System.debug('Query *********'+System.Now());
        System.debug('Query *********'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<User> scope) {
    System.debug('Scope@@@@@@@@'+scope);
        List<Contact> conList = new List<Contact>();
        Map<String , Id> federationMap = new Map<String , Id>();
        List<String> FederationList = new List<String>();
        
        for(User us : scope){
            String federationId = us.Username.split('@',2)[0];
            federationMap.put(federationId , us.id);
            System.debug('federationMap *********'+federationMap);
            FederationList.add(federationId);
            System.debug('FederationList *********'+FederationList);
        }
        
        if(FederationList.size() > 0){
            conList = [Select id, User__c, Federation_ID__c from Contact where User__c=null AND Team_Member_Status__c='Active' AND Federation_ID__c IN: FederationList];
            System.debug('conList *********'+conList);
        }
        
        for(Contact con : conList){
            if(federationMap.containsKey(con.Federation_ID__c)){
                con.User__c = federationMap.get(con.Federation_ID__c);
            }
        }
        
        if(conList.size() > 0 )
       {
 
                       Update conList;

        }
    }
    
     global void finish(Database.BatchableContext BC) {
     
     }
    

}