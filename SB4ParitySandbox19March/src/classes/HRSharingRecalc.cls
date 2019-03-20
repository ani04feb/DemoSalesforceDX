global class HRSharingRecalc implements Database.Batchable<sObject> {
 /*-------------------------------------------------------------
    Author:        Lok Jackson
    Company:       Salesforce.com
    Description:   Share HR Cases with the HRBP of the Team Member's Site or Site Department
                    (Use Site Department for Above Store Sites)
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    
    ------------------------------------------------------------*/
        
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Account__c, Contact__c, Reporting_Department__c FROM Case__c]);  
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
        Map<ID, Case__c> caseMap = new Map<ID, Case__c>((List<Case__c>)scope);  
        
        // Create a list of Job__Share objects to be inserted.
        List<Case__Share> caseShrs = new List<Case__Share>();
        Case__Share caseShrHRBP;
        Set<ID> caseHRBPUpdateIds = new set<ID>();
        Set<ID> ContactIds = new Set<ID>();
        Set<ID> conAccountIds = new Set<ID>();
        List<Case__c> caseConList = new List<Case__c>([SELECT Case__c.Contact__r.Id, Case__c.Contact__r.AccountId FROM Case__c WHERE Id IN: caseMap.keySet()]);
        for(Case__c caseCon : caseConList)
        {
            ContactIds.add(caseCon.Contact__r.Id);
            conAccountIds.add(caseCon.Contact__r.AccountId);
        }
        Map<Id, Contact> conMap = new Map<Id, Contact>([Select Id, Above_Store__c, Gender__c, AccountId From Contact Where Id In :ContactIds]);
        Map<Id, Account> siteContactMap = NotificationUtilities.GetSiteSharingContacts(conAccountIds);
        Map<String, Department__c> departmentContactMap = NotificationUtilities.GetDepartmentSharingContacts(conAccountIds);       
        for(Case__c c : caseMap.values()){
            if(c.Contact__c != null && conMap.get(c.Contact__c).AccountId != null)
            {
                String siteId = conMap.get(c.Contact__c).AccountId;
                String departmentKey = conMap.get(c.Contact__c).AccountId + c.Reporting_Department__c;
                // Set Notifications

                if(conMap.get(c.Contact__c).Above_Store__c) //Above Store so retrieve Site Manager and HRBP from Department
                {
                    if(departmentContactMap.get(departmentKey) != null) // Ensure lookup to Department is successful before attempting to extract values
                    {    
                        System.Debug('>>>>>>>>>>>>>>>>> Department Notifications');
                        if(departmentContactMap.get(departmentKey).HR_Business_Partner_Id__c != null && c.Contact__c != departmentContactMap.get(departmentKey).HR_Business_Partner__c)
                        {
                            caseShrHRBP = new Case__Share();
                            caseShrHRBP.ParentId = c.Id;
                            caseShrHRBP.UserOrGroupId = departmentContactMap.get(departmentKey).HR_Business_Partner_Id__c;
                            caseShrHRBP.AccessLevel = 'Read';
                            caseShrHRBP.RowCause = Schema.Case__Share.RowCause.HR_Business_Partner__c;
                            caseShrs.add(caseShrHRBP);
                            caseHRBPUpdateIds.add(c.Id);
                        }
                    }
                }
                else
                {
                    if(siteContactMap.get(siteId).HR_Business_Partner_Id__c != null && siteContactMap.get(siteId).HR_Business_Partner__c != c.Contact__c)
                    {
                        caseShrHRBP = new Case__Share();
                        caseShrHRBP.ParentId = c.Id;
                        caseShrHRBP.UserOrGroupId = siteContactMap.get(siteId).HR_Business_Partner_Id__c;
                        caseShrHRBP.AccessLevel = 'Read';
                        caseShrHRBP.RowCause = Schema.Case__Share.RowCause.HR_Business_Partner__c;
                        caseShrs.add(caseShrHRBP);
                        caseHRBPUpdateIds.add(c.Id);
                    }
                }
            }
        }
        
        List<Case__Share> oldHRBPCaseShrs = [SELECT Id FROM Case__Share WHERE ParentId IN :caseHRBPUpdateIds AND RowCause = :Schema.Case__Share.rowCause.HR_Business_Partner__c]; 
        
        try {
           // Delete the existing sharing records.
           // This allows new sharing records to be written from scratch.
            Delete oldHRBPCaseShrs;
            
           // Insert the new sharing records and capture the save result. 
           // The false parameter allows for partial processing if multiple records are 
           // passed into operation. 
           Database.SaveResult[] lsr = Database.insert(caseShrs,false);
        } catch(DmlException e) {
            //LJ 9/7/14: Given number of batches and email governor limits disabling the below to prevent the possiblity of it causing the whole batch to fail
            /*
            // Send an email to the Apex job's submitter on failure.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {getNotificationEmailAddress()}; 
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Apex Sharing Recalculation Exception');
            mail.setPlainTextBody(
              'The Apex sharing recalculation threw the following exception: ' + 
                        e.getMessage());
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
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}