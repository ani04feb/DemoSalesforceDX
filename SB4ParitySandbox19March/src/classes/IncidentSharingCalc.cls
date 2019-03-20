public class IncidentSharingCalc
{
   /*-------------------------------------------------------------
    Author:        Lok Jackson
    Company:       Salesforce.com
    Description:   Called via a Trigger to share the Incident with the relevant Site Manager
                    based on location of the Incident 
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    03-Apr-15   Shashidhar G.      1. Added share records for Site Assistant Managers also
                (Salesforce        2. Added method to delete old shares.
                 Services India)
    05-Jul-15   Lok Jackson        Added logic to exclude sharing records that have been hidden
                                   due to Legal Action
    ------------------------------------------------------------*/
    static String errorEmailAddress;
    static String missingSiteManagerEmailAddress;

    public static void deleteOldShares(List<Id> updatedIncidentIds) 
    {
        List<Incident__Share> oldIncidentShrs = [SELECT Id FROM Incident__Share 
                                                  WHERE ParentId IN :updatedIncidentIds 
                                                    AND (RowCause = :Schema.Incident__Share.rowCause.Site_Manager__c OR
                                                         RowCause = :Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c OR
                                                         RowCause = :Schema.Incident__Share.rowCause.Regional_Manager_Lookup__c OR
                                                         RowCause = :Schema.Incident__Share.rowCause.Site_Assistant_Manager__c)]; 
                
        // Delete the existing sharing records.
        // This allows new sharing records to be written from scratch.
        try {
            Delete oldIncidentShrs;
        } catch (DmlException e) {
            System.debug('>>>> Exception while deleting old Incident Shares: ' + e.getMessage());
        }
    }


    public static void insertShare(List<Incident__c> incidentList, Map<Id, Incident__c> incidentMap)
    {
        String errorText = '';
        List<Incident__Share> incidentShrs  = new List<Incident__Share>();
        Incident__Share incidentShr;
        
        Try {
            errorEmailAddress = [SELECT Email_Address__c FROM System_Alert_Email_Address__c WHERE Name = 'Sharing Error Alert'].Email_Address__c;
        }
        Catch (Exception e) {
            errorEmailAddress = null;
        }
        Try {
            missingSiteManagerEmailAddress = [SELECT Email_Address__c FROM System_Alert_Email_Address__c WHERE Name = 'Missing Site Manager Safety'].Email_Address__c;
        }
        Catch (Exception e) {
            missingSiteManagerEmailAddress = null;
        }
        if(Test.isRunningTest()) {
            missingSiteManagerEmailAddress = 'test@test.com';
            errorEmailAddress = 'test@test.com';
        }
        
        for(Incident__c inc : incidentList)
        {
            Boolean noShareAdded = true;
            if(inc.Site_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Site_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Site_Manager__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(inc.Regional_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Regional_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Regional_Manager_Lookup__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(inc.Caretaking_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Caretaking_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }

            if(inc.Store_Support_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Store_Support_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(inc.Caretaking_Store_Support_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Caretaking_Store_Support_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(inc.Trading_Manager_Grocery_D_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Trading_Manager_Grocery_D_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(inc.Trading_Manager_Fresh_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Trading_Manager_Fresh_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
           if(inc.Trading_Manager_Nights_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Trading_Manager_Nights_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }

            if(inc.Duty_Manager_Id__c!= null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Duty_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
           if(inc.Caretaking_Duty_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Caretaking_Duty_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
           if(inc.Dry_Goods_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Dry_Goods_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
           if(inc.Caretaking_Dry_Goods_Manager_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Caretaking_Dry_Goods_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
           if(inc.DMTL_Id__c != null && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.DMTL_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(inc.Site_Assistant_Manager_Id__c != null  && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                incidentShr = new Incident__Share();
                incidentShr.ParentId = inc.Id;
                incidentShr.UserOrGroupId = inc.Site_Assistant_Manager_Id__c;
                incidentShr.AccessLevel = 'Edit';
                incidentShr.RowCause = Schema.Incident__Share.RowCause.Safety_User_Extra_Licence__c;
                incidentShrs.add(incidentShr);
                
                noShareAdded = false;
            }
            if(noShareAdded && missingSiteManagerEmailAddress != null  && inc.Is_Legal_Advice_Required__c != 'Yes')
            {
                errorText = errorText + 'Both Site Manager and Site Assistant Manager are not defined or have no associated User Record for Site ' + inc.Account__c + '. Incident ' + inc.Name + ' has not been assigned to either Site Manager or Site Assistant Manager.\r\n';
            }
        }
        
        if (errorText != '')
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {missingSiteManagerEmailAddress}; 
            mail.setToAddresses(toAddresses); 
            mail.setSubject('Safety Incident Sharing Warning.');
            mail.setPlainTextBody(errorText);
            if(!Test.isRunningTest()) {
                Try{
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
                Catch(Exception e){
                    // Error occurs if Deliverability settings are restricted (which is the default for sandboxes) so handle gracefully
                    System.Debug(e.getMessage());
                }
            }
        }
        
        if(incidentShrs.size() > 0)
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        {
            Database.SaveResult[] lsr = Database.insert(incidentShrs,false);

            Integer i=0;
            String error;
            
            // Process the save results
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                
                    // Check if the error is related to a trivial access level
                    // Access levels equal or more permissive than the object's default 
                    // access level are not allowed. 
                    // These sharing records are not required and thus an insert exception is 
                    // acceptable. 
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                                   &&  err.getMessage().contains('AccessLevel'))){
                        error = error + 'Record Id: ' + incidentMap.get(incidentShrs[i].ParentId) + ', Error: Unable to grant sharing access due to following exception: ' + err.getMessage() + '\r\n';
                    }
                }
                i++;
            }
            if(error != null && errorEmailAddress != null)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {errorEmailAddress}; 
                mail.setToAddresses(toAddresses); 
                mail.setSubject('Safety Incident Sharing Error.');
                mail.setPlainTextBody(error);
                if(!Test.isRunningTest()){
                    Try{
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    }
                    Catch(Exception e){
                        // Error occurs if Deliverability settings are restricted (which is the default for sandboxes) so handle gracefully
                        System.Debug(e.getMessage());
                    }
                }
            } 
        }   
    }
}