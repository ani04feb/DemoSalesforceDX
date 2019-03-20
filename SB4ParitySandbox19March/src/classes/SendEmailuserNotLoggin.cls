global class SendEmailuserNotLoggin implements Database.Batchable<sObject>{
        /*-------------------------------------------------------------
        Author:        Animesh Kumar Verma
        Company:       Accenture Solutionss Private Ltd
        Description:   Batch class for sending email when lastlogin date is less than 180 days
        Inputs:        None
        History
        <Date>      <Authors Name>     <Brief Description of Change>
        18-Aug-18   Animesh               Initial Version 
        ------------------------------------------------------------*/
        
        public Database.QueryLocator start(Database.BatchableContext context) {
       
            //String query = 'select id,federationidentifier from user where federationidentifier!=null and contact_status__c=null';
            //System.debug('Query1*********'+query);
            return Database.getQueryLocator([select id,name,email,group__c from user where federationidentifier!=null and isActive=true and lastlogindate!=LAST_N_DAYS:180 and group__c='Merchandise' limit 100]);
        }
        
        global void execute(Database.BatchableContext context, List<user> scope) {
                    list<Id> lstUsersparity = new list<Id>();
                   // List<Id> lstUserSupermarket=new list<Id>();
                    system.debug('@@@@@@@listofusers'+scope);
                    for(User ur: scope)
                    {
                        if(ur.email!=null)
                        {
                            lstUsersparity.add(ur.Id);
                        }
                    }    
                        system.debug('@@@@@@@ParityUserlist'+lstUsersparity);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName like '%salesforce%'];
                        System.debug('OrgWide Email@@@'+owa);
                        EmailTemplate templateId = [select Id, Subject, HtmlValue, Body from EmailTemplate where name = 'UserNotLoginToSystem'];
                        System.debug('Email@@@ Template'+templateId);
                        List<String> toAddresses = new List<String>();
                        //Replacing content of HTML body 
                        String[] ccAddresses = new String[] {'animeshkumar.verma@coles.com.au'};
                        String htmlBody = templateId.HtmlValue;
                        if(lstUsersparity.size()>0)
                        {
                        for(user u : [SELECT id,email FROM user where id in:lstUsersparity]){
                            toAddresses.add(u.email);
                        }
                        System.debug('Email@@@ Toaddress'+toAddresses);
                        mail.setccAddresses(ccAddresses);
                        mail.setToAddresses(toAddresses);    // Set the TO addresses
                        mail.setReplyTo('noreplysalesforce@coles.com.au');// Set Reply TO addresses
                        mail.setTemplateID(templateId.Id);// Set Template ID
                        mail.setTargetObjectId(Userinfo.getUserId());
                        //mail.setSubject('Safety Corrective Action Due Today');// Set Subject

                        mail.setSaveAsActivity(false);
                        mail.setOrgWideEmailAddressId(owa.id);
                        Messaging.SendEmail(new Messaging.SingleEmailMessage[] {mail});
                        }
                       
                    
        }
         global void finish(Database.BatchableContext BC) {
         
         }
        

    }