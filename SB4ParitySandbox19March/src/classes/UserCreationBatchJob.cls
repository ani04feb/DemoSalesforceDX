global class UserCreationBatchJob implements Database.Batchable<sObject>{
    /*-------------------------------------------------------------
    Author:        Animesh Kumar Verma
    Company:       Accenture Solutionss Private Ltd
    Description:   Batch class for assigning 2nd licence to all Supermarket stores
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    06-Apr-18   Animesh               Initial Version 
    ------------------------------------------------------------*/
    
    public Database.QueryLocator start(Database.BatchableContext context) {
   
        String query = 'select id,Supermarket_email_address__c,IsSupermarket__c from account where IsSupermarket__c!=null';
        System.debug('Query1*********'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<account> scope) {
        
            //List<UserLicense> LicenceAssigned=[SELECT  UsedLicenses FROM UserLicense where Name='Company Communities'];
            List<id> stAccId=new List<Id>();
            List<Id> fstSet=new List<Id>();
            List<Id> midSet=new List<Id>();
            List<Id> finalSet=new List<Id>();
            List<Id> ssm=new List<Id>();
            List<id> cssm=new List<id>();
            List<id> tmg=new List<id>();
            List<id> tmf=new List<id>();
            List<id> tmn=new List<id>();
            List<id> dm=new List<id>();
            List<id> cdm=new List<id>();
            List<id> dgm=new List<id>();
            List<id> cdgm=new List<id>();
            List<id> dmtl=new List<id>();
            Integer count=0;
            //Getting all the account whose Brand is Supermarket in AccId1
            For(Account acc : scope)
            {
                
              if(acc.Supermarket_email_address__c!=null)
               {
                stAccId.add(acc.id);
               }
            }
            System.debug('@@@@@@@@SupermarketAccount_List'+stAccId );
            System.debug('@@@@@@@@SupermarketAccount_size'+stAccId.size());
           
            //Looping through each and every account to find out the contact eligible for assigning licence
            if(stAccId.size()>0)
                    {
                     for(Account Act:[Select id,brand__c,Active_Licence__c,(SELECT Id,FirstName, LastName ,Federation_ID__c, Account.Name,account.Supermarket_email_address__c ,Position_Description__c,Email, Account_Region_Area__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Employee_ID__c,Team_Member_Status__c,Company_Description__c
                                       FROM contacts where user__c=null) from account where Id IN:stAccId])
                            {
                                        fstSet.clear();
                                        cssm.clear();
                                        ssm.clear();
                                        tmg.clear();
                                        tmf.clear();
                                        tmn.clear();
                                        dm.clear();
                                        cdm.clear();
                                        dgm.clear();
                                        cdgm.clear();
                                        dmtl.clear();
                                        midSet.clear();
                                        
                                        if(Act.Active_Licence__c==1)
                                                {
                                                    count=1;    
                                                }
                                        if(Act.Active_Licence__c==0)
                                                {
                                                    count=0;
                                                }
                                for(Contact c: Act.Contacts)
                                        {

                                            if((c.Position_Description__c =='STORE MANAGER'|| c.Position_Description__c == 'Site Mgr' || c.Position_Description__c == 'caretaking store manager' || c.Position_Description__c == 'csm')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                                                 {
                                                     fstSet.add(c.Id);
                                                    
                                                 }
                                                 
                                            if((c.Position_Description__c =='STORE SUPPORT MANAGER' || c.Position_Description__c =='ssm')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                         
                                                        {
                                                            ssm.add(c.Id);
                                                        }  

                                            if((c.Position_Description__c =='CARETAKING STORE SUPPORT MANAGER' || c.Position_Description__c =='cssm')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                         
                                                        {
                                                            cssm.add(c.Id);
                                                        }  

                                            if((c.Position_Description__c =='TRADING MANAGER GROCERY/DAIRY')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            tmg.add(c.Id);
                                                        }  

                                            if((c.Position_Description__c =='TRADING MANAGER FRESH')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            tmf.add(c.Id);
                                                        }  
                                            if((c.Position_Description__c =='TRADING MANAGER NIGHTS')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            tmn.add(c.Id);
                                                        }   
                                            if((c.Position_Description__c =='DUTY MANAGER')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            dm.add(c.Id);
                                                        }  
                                            if((c.Position_Description__c =='CARETAKING DUTY MANAGER')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            cdm.add(c.Id);
                                                        }  
                                            if((c.Position_Description__c =='DRY GOODS MANAGER')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            dgm.add(c.Id);
                                                        }  
                                            if((c.Position_Description__c =='CARETAKING DRY GOODS MANAGER')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            cdgm.add(c.Id);
                                                        }  
                                            if((c.Position_Description__c =='DMTL')&&(c.Team_Member_Status__c=='Active')&&(c.Company_Description__c.contains('Supermarket')))
                        
                                                        {
                                                            dmtl.add(c.Id);
                                                        }   

                                        } 
                                            if(fstSet.size()>0)
                                                {
                                                midSet.addall(fstSet);
                                                count=count+midSet.size();
                                                System.debug('@@@@@@@@Count SM'+count );
                                                }  
                                            if((count<2)&&(ssm.size()>0))
                                                {
                                                midSet.addall(ssm);
                                                count=count+midSet.size();
                                                System.debug('@@@@@@@@Count SSM'+count );

                                                }   
                                            if((count<2)&&(cssm.size()>0))
                                                    {
                                                    midSet.addall(cssm);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count CSSM'+count );
                                                    }   
                                            if((count<2)&&(tmg.size()>0))
                                                    {
                                                    midSet.addall(tmg);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count TMG'+count );
                                                    }
                                            if((count<2)&&(tmf.size()>0))
                                                    {
                                                    midSet.addall(tmf);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count TMF'+count );
                                                    }
                                            if((count<2)&&(tmn.size()>0))
                                                    {
                                                    midSet.addall(tmn);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count TMN'+count );
                                                    }
                                            if((count<2)&&(dm.size()>0))
                                                    {
                                                    midSet.addall(dm);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count DM'+count );
                                                    }
                                            if((count<2)&&(cdm.size()>0))  
                                                    {
                                                    midSet.addall(cdm);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count CDM'+count );
                                                    }   
                                            if((count<2)&&(dmtl.size()>0))
                                                    {
                                                    midSet.addall(dmtl);
                                                    count=count+midSet.size();
                                                    System.debug('@@@@@@@@Count DMTL'+count );
                                                    }   
             
                                System.debug('@@@@@@@@Mid_List_Size'+midSet.size());  
                                finalSet.addall(midSet);
                            }
                                     
                        System.debug('@@@@@@@@Final_List_Size'+finalSet.size()); 
                    }
                            if(finalSet.size()>0)
                            {
                                {
                                  CreateUserOnContactHandler.createUSer(finalSet);
                                }
                                
                            }

            
      }      
    
     global void finish(Database.BatchableContext BC) {
     
     }
    

}