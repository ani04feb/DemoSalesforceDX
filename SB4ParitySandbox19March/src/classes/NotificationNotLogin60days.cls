global class NotificationNotLogin60days implements Database.Batchable<sObject>{
        /*-------------------------------------------------------------
        Author:        Animesh Kumar Verma
        Company:       Accenture Solutionss Private Ltd
        Description:   Batch class for sending email when lastlogin date is less than 60 days
        Inputs:        None
        History
        <Date>      <Authors Name>     <Brief Description of Change>
        18-Aug-18   Animesh               Initial Version 
        ------------------------------------------------------------*/
        
        public Database.QueryLocator start(Database.BatchableContext context) {
       
            //String query = 'select id,federationidentifier from user where federationidentifier!=null and contact_status__c=null';
            //System.debug('Query1*********'+query);
            return Database.getQueryLocator([select id,name,email,group__c from user where federationidentifier!=null and isActive=true and lastlogindate!=LAST_N_DAYS:60 and lastlogindate=LAST_N_DAYS:90 and userrole.name in('Category Manager','Business Category Manager')]);
        }
        
        global void execute(Database.BatchableContext context, List<user> scope) {
                    list<Id> lstUsersparity = new list<Id>();
                    system.debug('@@@@@@@listofusers'+scope);
                    OrgWideEmailAddress owa = [select id,DisplayName, Address from OrgWideEmailAddress where DisplayName like '%salesforce%'];
                        System.debug('OrgWide Email@@@'+owa);
                    EmailTemplate templateId = [select Id,subject,HtmlValue,Body from EmailTemplate where name = 'BU not Login into SFDC'];
                        System.debug('Email@@@ Template'+templateId);
                     String[] ccAddresses = new String[] {'PARITYActivityCompliance@coles.com.au'};   
                    List<Messaging.SingleEmailMessage> emailmessageList = new List<Messaging.SingleEmailMessage>(); 
                    for(User ur: scope)
                    {
                        if(ur.email!=null)
                        {
                            lstUsersparity.add(ur.Id);
                        }
                    }    
                        system.debug('@@@@@@@ParityUserlist'+lstUsersparity);

                    List<String> toAddresses = new List<String>();
                    //mail.setSubject('Safety Corrective Action Due Today');// Set Subject

                        

                    if(lstUsersparity.size()>0)
                        {
                            for(user u : [SELECT id,name,email FROM user where id in:lstUsersparity])
                            {
                                toAddresses.clear();
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage ();
                                //Replacing content of HTML body 
                                String htmlBody = templateId.HtmlValue;
                                htmlBody = htmlBody.replace('{!User.Name}',u.name);
                                htmlBody = htmlBody.replace('45','60');
                                toAddresses.add(u.email);
                                System.debug('Email@@@ Toaddress'+toAddresses);
                                mail.setccAddresses(ccAddresses);// Set up cc address
                                mail.setToAddresses(toAddresses);// Set up to address
                                mail.setReplyTo('noreplysalesforce@coles.com.au');// Set Reply TO addresses
                                mail.setSaveAsActivity(false);
                                mail.setOrgWideEmailAddressId(owa.id);// Set Orgwide email address
                                mail.setTemplateID(templateId.Id);// Set Template ID
                                //mail.setTargetObjectId(Userinfo.getUserId());
                                mail.setHtmlBody(htmlBody);
                                mail.setSubject('Salesforce/PARITY Log In Reminder');// Set Subject
                                emailmessageList.add(mail);
                            }
                            //Messaging.SendEmail(new Messaging.SingleEmailMessage[] {mail});
                            if(emailmessageList.size()>0)
                                {
                                 Messaging.sendEmail(emailmessageList,false);   
                                }
                            
                        }
                       
                    
        }
         global void finish(Database.BatchableContext BC) {
         
         }
        

    }