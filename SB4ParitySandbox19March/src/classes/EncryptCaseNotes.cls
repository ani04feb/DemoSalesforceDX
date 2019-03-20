global class EncryptCaseNotes implements Database.Batchable<sObject>{
   global final String Query;
   global final Blob Key;

   global EncryptCaseNotes(String q, Blob k){
             Query=q; Key=k;
   }

   global Database.QueryLocator start(Database.BatchableContext BC){
       System.Debug('>>>>>>>>>>>>>>>> Query is: ' + Query);
      return Database.getQueryLocator(Query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Case__c> cases = new List<Case__c>();
       for(sObject s : scope){
           Case__c c = (Case__c)s;
           if(c.Case_Notes__c != null) {
               Blob encryptedNotesValue = Crypto.encryptWithManagedIV('AES256', Key, Blob.valueOf(c.Case_Notes__c));
               c.Case_Notes__c = EncodingUtil.base64encode(encryptedNotesValue);
               cases.add(c);
           }
       }
       update cases;
   }

   global void finish(Database.BatchableContext BC){

   }

}