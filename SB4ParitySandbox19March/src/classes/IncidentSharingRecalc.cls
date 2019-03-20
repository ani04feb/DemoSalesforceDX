global class IncidentSharingRecalc implements Database.Batchable<sObject> {
 /*-------------------------------------------------------------
    Author:        Lok Jackson
    Company:       Salesforce.com
    Description:   Share Incidents with the Site Manager of the Site where it occurred (runs for all Incidents)
                   This is a batch job that can either be scheduled or executed manually via the Sharing section of the Incident Object
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    03-Apr-15   Shashidhar G.      1. Added share records for Site Assistant Managers also
                (Salesforce        2. Deleted old Site Assistant Manager shares
                 Services India)
    05-Jul-15   Lok Jackson        Added logic to exclude re-sharing records that have been
                                   hidden due to Legal Action
                                   
    26-Feb-18   Animesh Verma       Added logic to include user with other position description to view the incident                   
    ------------------------------------------------------------*/
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id,Account__c, Site_Manager_Id__c,Site_Assistant_Manager_Id__c,Account__r.Caretaking_Duty_Manager_user__c,Account__r.Dry_Goods_Manager_user__c,Account__r.Caretaking_Dry_Goods_Manager_user__c,Trading_Manager_Nights_Id__c,Account__r.DMTL_user__c ,Caretaking_Manager_Id__c,Store_Support_Manager_Id__c, Caretaking_Store_Support_Manager_Id__c, Trading_Manager_Fresh_Id__c,Trading_Manager_Grocery_D_Id__c,Duty_Manager_Id__c,Caretaking_Duty_Manager_Id__c,Dry_Goods_Manager_Id__c, Caretaking_Dry_Goods_Manager_Id__c,DMTL_Id__c,Regional_Manager_Id__c FROM Incident__c WHERE Is_Legal_Advice_Required__c <> 'Yes']);  
      
    }
    private String getNotificationEmailAddress() {
        String emailAddress;
        Try {
            emailAddress = [SELECT Email_Address__c FROM System_Alert_Email_Address__c WHERE Name = 'Sharing Error Alert'].Email_Address__c;
        }
        Catch (Exception e) {
            emailAddress = null;
        }
        if(Test.isRunningTest())
            emailAddress = 'test@test.com';
        return emailAddress;
    }
    
    
    // The executeBatch method is called for each chunk of records returned from start.  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       // Create a map for the chunk of records passed into method.
        Map<ID, Incident__c> incidentMap = new Map<ID, Incident__c>((List<Incident__c>)scope);  
        
        // Create a list of Job__Share objects to be inserted.
        List<Incident__Share> newIncidentShrs = new List<Incident__Share>();
        Set<ID> incidentUpdateIds = new set<ID>();
               
        for(Incident__c i : incidentMap.values()){
            if(i.Site_Manager_Id__c != null)
            {
                Incident__Share incidentSMShr = new Incident__Share();
                incidentSMShr.UserOrGroupId = i.Site_Manager_Id__c;
                incidentSMShr.AccessLevel = 'Edit';
                incidentSMShr.ParentId = i.Id;
                incidentSMShr.RowCause = Schema.Incident__Share.RowCause.Site_Manager__c;
                newIncidentShrs.add(incidentSMShr);
                incidentUpdateIds.add(i.Id);
            }
            
            if(i.Regional_Manager_Id__c != null)
            {
                Incident__Share incidentSMShr = new Incident__Share();
                incidentSMShr.UserOrGroupId = i.Regional_Manager_Id__c;
                incidentSMShr.AccessLevel = 'Edit';
                incidentSMShr.ParentId = i.Id;
                incidentSMShr.RowCause = Schema.Incident__Share.RowCause.Regional_Manager_Lookup__c;
                newIncidentShrs.add(incidentSMShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Site_Assistant_Manager_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Site_Assistant_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Site_Assistant_Manager__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Caretaking_Manager_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Caretaking_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Store_Support_Manager_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Store_Support_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
           if(i.Caretaking_Store_Support_Manager_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Caretaking_Store_Support_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Trading_Manager_Grocery_D_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Trading_Manager_Grocery_D_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Trading_Manager_Fresh_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Trading_Manager_Fresh_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Trading_Manager_Nights_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Trading_Manager_Nights_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Duty_Manager_Id__c != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Duty_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }   
            if(i.Account__r.Caretaking_Duty_Manager_user__c!= null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Account__r.Caretaking_Duty_Manager_user__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }
            if(i.Account__r.Dry_Goods_Manager_user__c!= null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Account__r.Dry_Goods_Manager_user__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }   
            if(i.Account__r.Caretaking_Dry_Goods_Manager_user__c!= null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Account__r.Caretaking_Dry_Goods_Manager_user__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }           
            if(i.Account__r.DMTL_user__c  != null)
            {
                Incident__Share incidentShr = new Incident__Share();
                incidentShr.UserOrGroupId = i.Account__r.DMTL_user__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.ParentId = i.Id;
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                
                newIncidentShrs.add(incidentShr);
                incidentUpdateIds.add(i.Id);
            }               
        }
        
        List<Incident__Share> oldIncidentShrs = [SELECT Id FROM Incident__Share 
                                                  WHERE ParentId IN :incidentUpdateIds 
                                                    AND (RowCause = :Schema.Incident__Share.rowCause.Site_Manager__c OR
                                                         RowCause = :Schema.Incident__Share.rowCause.Site_Assistant_Manager__c OR
                                                         RowCause = :Schema.Incident__Share.rowCause.Safety_User_Extra_Licence__c OR
                                                         RowCause = :Schema.Incident__Share.rowCause.Regional_Manager_Id__c)]; 
        
        try {
            // Delete the existing sharing records.
            // This allows new sharing records to be written from scratch.
            Delete oldIncidentShrs;
            
            // Insert the new sharing records and capture the save result. 
            // The false parameter allows for partial processing if multiple records are 
            // passed into operation. 
            Database.SaveResult[] lsr = Database.insert(newIncidentShrs,false);
            
        } catch(DmlException e) {
            //LJ 9/7/14: Given number of batches and email governor limits disabling the below to prevent the possiblity of it causing the whole batch to fail
            /*
            // Send an email to the Apex job's submitter on failure.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {getNotificationEmailAddress()}; 
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Apex Sharing Recalculation Exception');
            mail.setPlainTextBody('The Apex sharing recalculation threw the following exception: ' + e.getMessage());
            if(!Test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            */
        }
    }
    
    // The finish method is called at the end of a sharing recalculation.
    global void finish(Database.BatchableContext BC){  
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {getNotificationEmailAddress()}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Apex Sharing Recalculation Completed.');
        mail.setPlainTextBody
                      ('The Apex sharing recalculation finished processing');
        if(!Test.isRunningTest())
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}