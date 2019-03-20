/**
* @author       :Ranjan Kumar Jha
* @date         :20/10/2016
* @description  :This is test class for Apex Class to deploy ColesReqController Apex Class in Production

   --------------------------------------------------------------------------
*/

@isTest (SeeAllData=true)
public class ColesReqController_Test
    {
       Static User userRecord ;
        Static Account accountRecord;
        Static Contact contactRecord;
        public String filename ;
        public String imageURL;
        static void setupData()
        {
            // Create User
              userRecord = [select id from user where profileid='00e90000001VULf' and isActive=true limit 1];
            // Create Account
             accountRecord = (Account) TestUtil.createSobject(1, true, new Map<String, Object>{
                                                                        'Name' => 'Coles',
                                                                        'Brand__c' => 'Liquorland',
                                                                        'Sub_Brand__c' => 'Liquorland'
                                                                      }, 'Account')[0];
                                                                      
            
            // Create Contact
            //public static id RecordTypeId= contactRecordTypeMap.get('Team_Member').getrecordtypeid();
            RecordType RecType = [Select Id From RecordType  Where SobjectType = 'Contact' and DeveloperName = 'Team_Member'];
            contactRecord =(Contact) TestUtil.CreateSobject(1,true,new Map<String,Object>{
                                                                            'LastName' => 'Adam',
                                                                            'AccountId' => accountRecord.Id,
                                                                            'User__c' => userRecord.id,
                                                                             'Team_Member_Status__c' => 'Active',
                                                                             'RecordTypeId' => RecType.Id
                                                                            }, 'Contact')[0];
                    System.debug('***con'+contactRecord.User__c);
         } 
         
         //Map <String,Schema.RecordTypeInfo> recordTypesrequest = Request__c.sObjectType.getDescribe().getRecordTypeInfosByName();
         //Id RecTypeIdinadj = recordTypesrequest.get('Team_Member').getRecordTypeId();
         //public static id RecordTypeId= caseRecordTypeMap.get('Team_Member').getrecordtypeid();
         //contactRecord.RecordTypeId = 'Team_Member';

    // Test Method for ColesReqController controller class
     static testMethod void TestColesReqController1()
     {
        setupData();
        PageReference pr = new PageReference('/apex/ManageReq');
        Test.setCurrentPage(pr);
        String  imageURL;
        
        // Define controller reference
        Request__c req = new Request__c();
         req.Application_Name__c='Safety';
         req.Category__c='Request';
         req.Description__c='desc';
         req.Priority__c='Low';
         req.Requester_s_Name__c=contactRecord.id;
         req.Request_Type__c='Others';
         req.Solution__c='timepass';
         req.Status__c='Open';
         //req.RecordTypeId=RecTypeIdinadj;
         insert req;
         imageURL ='https://www.royalcanin.com/products/cat/adult' ;
         
         
          Apexpages.StandardController sc = new Apexpages.StandardController(req);
        ColesReqController request = new ColesReqController(sc);    
        PageReference pageRef = Page.colesReqMessage;
        //PageReference pageRefReq = Page.colesReqMessage;
        request.save();
            
         
         
         Attachment attach=new Attachment();    
        Blob b = Blob.valueOf('Test Data');  
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=req.id;
        System.debug('@@@@@@@@@@attachment'+ attach.id);
        try{
        insert attach; }
        catch(Exception e){}
        request.save();
    
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:req.id];
        System.assertEquals(1, attachments.size());
        
         //req.save();
         // Define ontroller reference
       
       
        Test.setCurrentPage(pageRef);
        //Test.setCurrentPage(pageRefReq);
        //pageRefReq.getParameters().put('id','Display' );
        
        
        
        
        
        
        
        request.save();
        request.saveNreturn();
       
      }
      
      
      
     }