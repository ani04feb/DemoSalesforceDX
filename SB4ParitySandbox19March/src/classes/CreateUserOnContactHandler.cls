/*
---------------------------------------------------------------------------------------------------------------
* @author       Animesh Kumar Verma
---------------------------------------
* @description  Controller class for Contact which performs all the below actions. 
*               -Automatic different users creation when new contact gets created based on Position description
*               -Activate/Deactivate user based on Contact Status
*               -Activate/Deactivate user based on Contact Status
*
*    -----------------------------------------------------------------------------------------------------------
*/


Global class CreateUserOnContactHandler {
    List<User> us =new List<User>();
    list<User> existinguser =[select id , name , username from User ];
    Map<String , Id> roleMap = new Map<String , Id>();
    //Creating Users when meeting the criteria mentioned in PrioritizeNCreateUSer class
    //@future
    public static void createUSer(List<id> conList){
        List<User> us =new List<User>();
        list<User> existinguser =[select id , name , username from User ];
        Map<String , Id> roleMap = new Map<String , Id>();
    
        
        for(UserRole ur : [SELECT Id,Name FROM UserRole WHERE Name LIKE '%Supermarkets%']){
            roleMap.put(ur.Name , ur.Id);
        }
             for(Contact c:[SELECT Id,FirstName, LastName , Federation_ID__c, Account.Name,account.active_licence__c,account.Supermarket_email_address__c ,Position_Description__c,Email, Account_Region_Area__c,MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,Employee_ID__c,Team_Member_Status__c,Company_Description__c
                                   FROM contact Where Id IN: conList]) 
             {
                    User u=new User();      
                    u.FirstName=c.FirstName;
                    u.lastname=c.lastname;
                    system.debug('Account Email Address:'+c.account.Supermarket_email_address__c);
                    u.Email=c.account.Supermarket_email_address__c;      
                    // u.Username=c.account.Supermarket_email_address__c;  
                   //u.Username= c.Federation_ID__c+'@coles.com.au';//c.account.Supermarket_email_address__c;
                    u.Username=c.Federation_ID__c+'@coles_incident.com.au';
                    String roleName = 'Supermarkets '+c.Account_Region_Area__c+' Region/Area Site Managers';
                    if(roleMap.containsKey(roleName))
                    u.UserRoleId = roleMap.get(roleName);           
                    System.debug('@@@@@@@'+ u.Username);
                    
                    u.CommunityNickname=c.FirstName+c.LastName;
                   // u.alias=c.FirstName;    
                    u.alias=c.Federation_ID__c;
                    /*Mapping address fields */
                    u.street=c.MailingStreet;
                    u.city=c.MailingCity;
                    u.postalcode=c.MailingPostalCode;
                    u.country=c.MailingCountry;
                    /* end*/
                    u.FederationIdentifier=c.Federation_ID__c;
                    u.Coles_Id__c=c.Federation_ID__c;
                    u.EmployeeNumber=c.Employee_ID__c;
                    u.External_ID__c=c.Employee_ID__c;
                    u.TimeZoneSidKey = 'Australia/Sydney';
                    //for ex'Australia/Sydney'   
                    u.LocaleSidKey = 'en_US'; 
                    //for ex 'en_GB'       
                    u.EmailEncodingKey = 'ISO-8859-1';
                    //for ex'ISO-8859-1';    
                    u.ProfileId = '00e90000001dUfE';
                    u.Group__c = 'Supermarket';
                    u.LanguageLocaleKey = 'en_US '; //for ex 'en_AU'           
                    Database.DMLOptions dmo = new Database.DMLOptions();     
                    dmo.EmailHeader.triggerUserEmail = false;   /* Disabling so that user did not receive any mails after user creation--- Updated on 21/2/2018 */ 
                    u.setOptions(dmo);
                    //u.id = '005p0000001WPI4';
                    us.add(u);  
                
             }
            
        CreateUserOnContactHandlerBoolen.contactFlag = false;
        if(us.size()>0)
        {
            System.debug('User Created**********'+us[0].Name);
            insert us;
        }
    }

    //Deactivating Users when Contact status is inactive
    @future
    public static void updateUSer(List<Id> userIdList){
        List<User> userList = new List<User>();
        for(Id userId : userIdList){
            User u = new User(ID = userID , isActive = false);
            userList.add(u);
        }
        
        update userList;
    }
     //Activating Users when Team Member Status is Active
         @future
        public static void ActivateConUserList(List<Id> userIdList){
        List<User> userList = new List<User>();
        for(Id userId : userIdList){
            User u = new User(ID = userID , isActive = true);
            userList.add(u);
        }
        
        update userList;
    }
    //Updates user role when Account is getting changed
    @future   
       public static void updateUserRole(List<id> conList){
       
        List<String> FedId=new List<String>();
         for(Contact cn:[SELECT Id,Federation_ID__c,Account_Region_Area__c FROM contact Where Id IN: conList])
         {
             FedId.add(cn.Federation_ID__c);
         }
         System.debug('@@@@@@@@Federation List@@@@'+FedId);
        //list<User> ListUsr =[select id , username,federationidentifier  from User where federationidentifier In :conList.Federation_ID__c];
        list<User> ListUser =[select id , username,federationidentifier from User where federationidentifier In : FedId];
        System.debug('@@@@@@@@UserList@@@@'+ListUser );
        Map<String , Id> roleMap = new Map<String , Id>();
    
        
        for(UserRole ur : [SELECT Id,Name FROM UserRole WHERE Name LIKE '%Supermarkets%']){
            roleMap.put(ur.Name , ur.Id);
            }
            
            for(Contact c:[SELECT Id,Federation_ID__c,Account_Region_Area__c,account.Supermarket_email_address__c FROM contact Where Id IN: conList]) 
            {
            System.debug('@@@@@Email Adresss'+c.account.Supermarket_email_address__c);  
            for(User u:ListUser)     
            {
             String roleName = 'Supermarkets '+c.Account_Region_Area__c+' Region/Area Site Managers';
             if(roleMap.containsKey(roleName))
             u.UserRoleId = roleMap.get(roleName); 
             u.Email = c.account.Supermarket_email_address__c; 
             System.debug('@@@@@ user Email Adresss assigned'+u.Email);
             update u;  
             }
            }
 }

 
}