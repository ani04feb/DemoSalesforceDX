global class CountActiveUsersBatch implements Database.Batchable<sObject>{
    /*-------------------------------------------------------------
    Author:        Animesh Kumar Verma
    Company:       Accenture Solutionss Private Ltd
    Description:   Batch class for counting number of  license to all Supermarket stores
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    06-Apr-18   Animesh               Initial Version 
    ------------------------------------------------------------*/
    
    public Database.QueryLocator start(Database.BatchableContext context) {
   
        String query = 'select id,IsSupermarket__c,Supermarket_email_address__c from account where IsSupermarket__c!=null';
        System.debug('Query1*********'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<account> scope) {
    
         List<Contact> conList1=new List<Contact>();
         Set<Id> smAccId = new Set<Id>();
         
            For(Account acc : scope)
            {
                
              if(acc.Supermarket_email_address__c!=null)
               {
                smAccId.add(acc.id);
               }
               system.debug('Supermarket Account Ids@@@@'+smAccId);
            }
        system.debug('Supermarket Account List'+smAccId);
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
        Position_Description__c='DMTL') AND   Team_Member_Status__c='active' AND user__r.isactive=true) from account where id In :smAccId];
        system.debug('Supermarket Account List @@@@'+smAccId);
        for(account a :ActUserList )  
            {
               a.Active_Licence__c = a.contacts.size();
            }
         update ActUserList ;
        }

            
     

    
     global void finish(Database.BatchableContext BC) {
     
     }
    

}