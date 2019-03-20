public class HRSharingCalc
{
 /*-------------------------------------------------------------
    Author:        Lok Jackson
    Company:       Salesforce.com
    Description:   Called via a Trigger to share the HR Case with the relevant HRBP
                    based on the Site and/or Department of the Team Member 
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    static String errorEmailAddress;
    static String missingHRBPEmailAddress;

    public static void insertShare(List<Case__c> caseList, Map<Id, Case__c> caseMap, Map<Id, Account> siteContactMap, Map<String, Department__c> departmentContactMap, Map<Id, Contact> conMap)
    {
        String errorText = '';
        List<Case__Share> caseShrs  = new List<Case__Share>();
        
        Try {
            errorEmailAddress = [SELECT Email_Address__c FROM System_Alert_Email_Address__c WHERE Name = 'Sharing Error Alert'].Email_Address__c;
        }
        Catch (Exception e) {
            errorEmailAddress = null;
        }
        Try {
            missingHRBPEmailAddress = [SELECT Email_Address__c FROM System_Alert_Email_Address__c WHERE Name = 'Missing HRBP'].Email_Address__c;
        }
        Catch (Exception e) {
            missingHRBPEmailAddress = null;
        }
        
        if(Test.isRunningTest())
        {
            missingHRBPEmailAddress = 'test@test.com';
            errorEmailAddress = 'test@test.com';
        }
        Case__Share caseShrHRBP;
        Set<ID> caseHRBPUpdateIds = new set<ID>();
        
        for(Case__c c : caseList)
        {
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
                        if(departmentContactMap.get(departmentKey).HR_Business_Partner_Id__c != null)
                        {
                            if(departmentContactMap.get(departmentKey).HR_Business_Partner__c != c.Contact__c) // don't add HRBP if they are the Team Member
                            {
                                caseShrHRBP = new Case__Share();
                                caseShrHRBP.ParentId = c.Id;
                                caseShrHRBP.UserOrGroupId = departmentContactMap.get(departmentKey).HR_Business_Partner_Id__c;
                                caseShrHRBP.AccessLevel = 'Read';
                                caseShrHRBP.RowCause = Schema.Case__Share.RowCause.HR_Business_Partner__c;
                                caseShrs.add(caseShrHRBP);
                            }
                            caseHRBPUpdateIds.add(c.Id);
                        }
                        else if(missingHRBPEmailAddress != null)
                        {
                            errorText = errorText + 'HRBP is not defined or has no associated User Record for the ' + c.Reporting_Department__c + ' Department of Site ' + siteContactMap.get(siteId).Name + '. Case ' + c.Name + ' has not been assigned to an HRBP.\r\n';
                        }
                    }
                }
                else
                {
                    if(siteContactMap.get(siteId).HR_Business_Partner_Id__c != null)
                    {
                        if(siteContactMap.get(siteId).HR_Business_Partner__c != c.Contact__c) // don't add HRBP if they are the Team Member
                        {
                            caseShrHRBP = new Case__Share();
                            caseShrHRBP.ParentId = c.Id;
                            caseShrHRBP.UserOrGroupId = siteContactMap.get(siteId).HR_Business_Partner_Id__c;
                            caseShrHRBP.AccessLevel = 'Read';
                            caseShrHRBP.RowCause = Schema.Case__Share.RowCause.HR_Business_Partner__c;
                            caseShrs.add(caseShrHRBP);
                        }
                        caseHRBPUpdateIds.add(c.Id);
                    }
                    else if(missingHRBPEmailAddress != null)
                    {
                        errorText = errorText + 'HRBP is not defined or has no associated User Record for Site ' + siteContactMap.get(siteId).Name + '. Case ' + c.Name + ' has not been assigned to an HRBP.\r\n';
                    }
                }
            }
        }
        
        if(errorText!='')
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {missingHRBPEmailAddress}; 
            mail.setToAddresses(toAddresses); 
            mail.setSubject('HR Case Sharing Warning.');
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
        
        List<Case__Share> oldHRBPCaseShrs = [SELECT Id FROM Case__Share WHERE ParentId IN :caseHRBPUpdateIds AND RowCause = :Schema.Case__Share.rowCause.HR_Business_Partner__c]; 
        if(oldHRBPCaseShrs.size() > 0)
            Delete oldHRBPCaseShrs;
        // Insert sharing records and capture save result 
        // The false parameter allows for partial processing if multiple records are passed 
        // into the operation 
        if(caseShrs.size() > 0)
        {
            Database.SaveResult[] lsr = Database.insert(caseShrs,false);
        
            // Create counter
            Integer i=0;
            String error;
        
            // Process the save results
            for(Database.SaveResult sr : lsr)
            {
                if(!sr.isSuccess())
                {
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                
                    // Check if the error is related to a trivial access level
                    // Access levels equal or more permissive than the object's default 
                    // access level are not allowed. 
                    // These sharing records are not required and thus an insert exception is 
                    // acceptable. 
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION  
                                                   &&  err.getMessage().contains('AccessLevel')))
                    {
                        error = error + 'Record Id: ' + caseMap.get(caseShrs[i].ParentId).Id + ', Error: Unable to grant sharing access due to following exception: ' + err.getMessage() + '\r\n';
                    }
                }
                i++;
            }
            if(error != null && errorEmailAddress != null)
            {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {errorEmailAddress}; 
                mail.setToAddresses(toAddresses); 
                mail.setSubject('HR Case Sharing Error.');
                mail.setPlainTextBody(error);
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
        }  
    }
}