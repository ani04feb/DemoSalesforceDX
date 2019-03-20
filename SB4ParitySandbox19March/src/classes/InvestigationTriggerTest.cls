@isTest
private class InvestigationTriggerTest {
  /*-------------------------------------------------------------
    Author:        Rohit Kumar
    Company:       Salesforce
    Description:   This class is responsible for testing the code of 'InvestigationTriggerTest' class.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    8-Jul-15     Rohit Kumar            Initial Version
    ------------------------------------------------------------*/

    private static testMethod void testCaseInvestigationTrigger() {
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
         Investigation__c investigation = (Investigation__c) TestUtil.createSobject(1,true, new Map<String,Object>{
                                                                                 'Investigation_Lead__c' => contactRecord.Id  
                                                                                 },'Investigation__c') [0];    
        Investigation__c invest = [Select id,Status__c from Investigation__c where Id = : investigation.Id];
        invest.Status__c = 'Closed Pending Review';
        update invest;                                                                        
    }

}