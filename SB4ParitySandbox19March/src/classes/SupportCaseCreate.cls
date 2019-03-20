/* This Class will be called with the POST method of the API call 
 * Primarily using this class to POST a Top-Up Case using the Employee id and various other parameters. 
 * Date: March 2018 
 * Used for Support Model App with Support Model Connector 
 */

@RestResource(urlMapping='/CreateCase/*')
global with sharing class SupportCaseCreate {
    
@HttpGet
    global static String TestingGet(){
      return 'Pass';
  }
    
@HttpPost  
     global static String createNewCase(String EmployeeID,
                                        String PersonalEmail,
                                        String Mobile,
                                        String PreferedMethod,
                                        String Reason,
                                        String OtherReason,
                                        String PaySlipDate,
                                        String Description)
     	{
         	System.debug('Employee_ID__c:' + EmployeeID + ' Personal_Email__c: '+ PersonalEmail + ' MobilePhone:' + Mobile + ' PreferedMethod:' + PreferedMethod + ' Reason:' + Reason + ' PaySlipDate:' + PaySlipDate); 
            try {                               
                //Find the correct record type based on the label set for Top-Up Cases. 
                String RecordTypeName = System.Label.TopUpCaseRecordType;
                System.debug('RecordTypeName:' + RecordTypeName);  
                List<RecordType> Reclist = [Select ID from RecordType where Name = :RecordTypeName Limit 1];                               
                System.debug('RecordTypeID: ' + Reclist[0].Id);
                
                //Find the correct Contact ID to link the new case.
                List<Contact> Contact_list = [Select ID, Name, Email, Personal_Email__c from Contact where Employee_ID__c = :EmployeeID];
                System.debug('Contact ID: ' + Contact_list[0].Id);
                if(Contact_list.size() == 1) 
                {
                    //Try{} -- Add TRY and Catch
                    Case c = new Case();
                    c.ContactId = Contact_list[0].Id;
                    c.Subject = Reason;
                    c.Status = 'Open';
                    c.RecordTypeId = Reclist[0].Id; //c.RecordTypeId = '0120k000000DXAhAAO'; //In Test   ** // c.RecordTypeId = '0120k000000DRgMAAW'; //In Dev 
                    c.SuppliedEmail = PersonalEmail;
                    c.SuppliedPhone = Mobile;
                    c.Preferred_Method_of_Contact__c = PreferedMethod;
                    c.Payslip_Date__c = PaySlipDate;
                    
                    //Reason is based on what is sent from the API POST
                    If (Reason == 'Why am I not eligible to receive Top Up when I used to be?') {
                        c.Reason = 'Eligibility';
                    } 
                    Else If(Reason == 'How did you calculate my Top Up amount?') {
                        c.Reason = 'Payment calculation';
                    }
                    Else If(Reason == 'How was my protected pay rate calculated?'){
                        c.Reason = 'Protected Rate Calculation';
                    }
                    Else If(Reason == 'Other'){
                        c.Reason = 'Other';
                    }
                    Else {
                        c.Reason ='';
                    }  				
                    c.description = OtherReason +'-' + description.normalizeSpace();
                    
                    insert c;
                 
                    return 'CaseCreated';
                }
            }
            Catch (System.CalloutException e){
                System.debug('API POST ERROR:' + e);
            }
            //This message should be diff from previous return because case is getting created in IF flow and controller is being returned from there.
            return 'ApexRestAPI_SupportCaseCreate_POST_Completed';
        }
}