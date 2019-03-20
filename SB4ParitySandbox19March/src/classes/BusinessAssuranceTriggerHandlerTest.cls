@isTest
private class BusinessAssuranceTriggerHandlerTest {
    /*-------------------------------------------------------------
    Author:        Rohit Kumar
    Company:       Salesforce
    Description:   This class is responsible for testing the code of 'BusinessAssuranceTriggerHandler' class.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    8-Jul-15     Rohit Kumar            Initial Version
    ------------------------------------------------------------*/
    private static testMethod void testCaseAssurance() {
         // Create User
        User  userRecord =[select id from user where profileid='00e90000001VULf' and isActive=true limit 1] ;
        Account accountRecord = (Account) TestUtil.createSobject(1, true, new Map<String, Object>{
                                                                    'Name' => 'Coles',
                                                                    'Brand__c' => 'Liquorland',
                                                                    'Sub_Brand__c' => 'Liquorland'
                                                                  }, 'Account')[0];
         Contact contactRecordReports = (Contact) TestUtil.createSobject(1,true, new Map<String,Object>{
                                                                               'LastName' => 'Adam',
                                                                                'AccountId' => accountRecord.Id,
                                                                                'User__c' => userRecord.Id,
                                                                                'Email' => 'test@test.com'
                                                                                },'Contact')[0]; 
                                                                  
         Contact contactRecord = (Contact) TestUtil.createSobject(1,true, new Map<String,Object>{
                                                                               'LastName' => 'Adam',
                                                                                'AccountId' => accountRecord.Id,
                                                                                'User__c' => UserInfo.getUserId()
                                                                                },'Contact')[0]; 
                                                                                
                                                                   
        Business_Assurance__c businessAssurance = (Business_Assurance__c) TestUtil.createSobject(1,true, new Map<String,Object>{
                                                                                                'Location__c' => accountRecord.id,
                                                                                                'Brand__c' => 'Liquorland',
                                                                                                'Date_of_Audit__c' => Date.Today(),
                                                                                                'Type_of_Activity__c' => 'SISAP',
                                                                                                'Key_Findings_Summary__c' => 'Key',
                                                                                                'Non_Conformances__c' => 5,
                                                                                                'Observations__c' => 6,
                                                                                                'Findings__c' => 6,
                                                                                                'Status__c' => 'Closed'
                                                                                                        },'Business_Assurance__c')[0];
                                                                                                        
       Business_Assurance__c buss = [Select Id,status__c from Business_Assurance__c where id = : businessAssurance.id];
       buss.status__c='Closed Pending Review';
       update buss;
    }

}