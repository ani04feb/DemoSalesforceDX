global class InvestigationSharingRecalc implements Database.Batchable<sObject> {
 /*-------------------------------------------------------------
    Author:        Animesh
    Company:       Accenture Solutions Private Ltd.
    Description:   Share Investigation with all the  Manager of the Site where it occurred (runs for all Investigation)
                   This is a batch job that can either be scheduled or executed manually via the Sharing section of the Investigation Object
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    06-Apr-18   Animesh             First Version                  
    ------------------------------------------------------------*/
    global Database.QueryLocator start(Database.BatchableContext BC){
    return Database.getQueryLocator([SELECT Id,Site_Manager_Id__c,Caretaking_Manager_Id__c,Store_Support_Manager_Id__c, Caretaking_Store_Support_Manager_Id__c, Trading_Manager_Fresh_Id__c,Trading_Manager_Grocery_D_Id__c,Trading_Manager_Nights_Id__c,Duty_Manager_Id__c,Caretaking_Duty_Manager_Id__c,Dry_Goods_Manager_Id__c, Caretaking_Dry_Goods_Manager_Id__c,DMTL_Id__c,Regional_Manager_Id__c FROM Investigation__c]);
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
        Map<ID, Investigation__c> investigationMap = new Map<ID, Investigation__c>((List<Investigation__c>)scope);  
        
        // Create a list of Job__Share objects to be inserted.
        List<Investigation__Share> newInvestigationShrs = new List<Investigation__Share>();
        Set<ID> investigationUpdateIds = new set<ID>();
               
        for(Investigation__c i : investigationMap.values()){
            if(i.Site_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Site_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            
            if(i.Regional_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Regional_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            /*
            if(i.Site_Assistant_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Site_Assistant_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            } */
            if(i.Caretaking_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Caretaking_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            if(i.Store_Support_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Store_Support_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
           if(i.Caretaking_Store_Support_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Caretaking_Store_Support_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            if(i.Trading_Manager_Grocery_D_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Trading_Manager_Grocery_D_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            if(i.Trading_Manager_Fresh_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Trading_Manager_Fresh_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            if(i.Trading_Manager_Nights_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Trading_Manager_Nights_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            if(i.Duty_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Duty_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }   
            if(i.Caretaking_Duty_Manager_Id__c != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Caretaking_Duty_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }
            if(i.Dry_Goods_Manager_Id__c!= null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Dry_Goods_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }   
            if(i.Caretaking_Dry_Goods_Manager_Id__c!= null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Caretaking_Dry_Goods_Manager_Id__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }           
            /*if(i.Account__r.DMTL_user__c  != null)
            {
                Investigation__Share InvestigationSMShr = new Investigation__Share();
                InvestigationSMShr.UserOrGroupId = i.Account__r.DMTL_user__c;
                InvestigationSMShr.AccessLevel = 'Edit';
                InvestigationSMShr.ParentId = i.Id;
                InvestigationSMShr.RowCause = Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c;
                
                newInvestigationShrs.add(InvestigationSMShr);
                investigationUpdateIds.add(i.Id);
            }  */    

                System.Debug('List of Incident Ids >>>>>>>>>>>>>>> ' +investigationUpdateIds);
        }
        
        List<Investigation__Share> oldInvestigationShrs = [SELECT Id FROM Investigation__Share 
                                                  WHERE ParentId IN :investigationUpdateIds 
                                                    AND RowCause = :Schema.Investigation__Share.rowCause.Safety_Users_Supermarket__c]; 
        
        try {
            // Delete the existing sharing records.
            // This allows new sharing records to be written from scratch.
            Delete oldInvestigationShrs;
            
            // Insert the new sharing records and capture the save result. 
            // The false parameter allows for partial processing if multiple records are 
            // passed into operation. 
            Database.SaveResult[] lsr = Database.insert(newInvestigationShrs,false);
            
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