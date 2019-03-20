@isTest
private class RegulatorManagementTriggerTest {
    /*-------------------------------------------------------------
    Author:        Rohit Kumar
    Company:       Salesforce
    Description:   This class is responsible for testing the code of 'RegulatorManagementTest' class.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    8-Jul-15     Rohit Kumar            Initial Version
    ------------------------------------------------------------*/

    private static testMethod void testCaseRegulator() {
         
         User  userRecord = [select id from user where profileid='00e90000001VULf' and isActive=true limit 1];
          
         Account accountRecord = (Account) TestUtil.createSobject(1, true, new Map<String, Object>{
                                                                    'Name' => 'Coles',
                                                                    'Brand__c' => 'Liquorland',
                                                                    'Sub_Brand__c' => 'Liquorland'
                                                                  }, 'Account')[0];
         Account accountRecordNew = (Account) TestUtil.createSobject(1, true, new Map<String, Object>{
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
         Regulator_Management__c rm = (Regulator_Management__c) TestUtil.createSobject(1,true, new Map<String,Object>{
                                                                                 'Brand__c' => 'Liquorland',
                                                                                 'Location__c' => accountRecord.Id   
                                                                                  },'Regulator_Management__c')[0];  
        Regulator_Management__c regulator = [Select id,Status__c,Location__c from Regulator_Management__c where Id = : rm.Id];
        regulator.Status__c = 'Closed Pending Review';
        regulator.Location__c = accountRecordNew.Id;
        
        update regulator;
                                                                                
    }

}