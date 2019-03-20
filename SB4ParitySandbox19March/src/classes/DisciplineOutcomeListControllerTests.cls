/**************************************************
Type:         Test Class for Disciplinary Outcome Visualforce Page components 
Purpose:    Testing Visualforce controller HR Case
Used By:    DisciplineOutcomeList Visualforce pages and underlying controllers
History:
--------------------------------------------------
24-March-2014 Paul Fayle (Salesforce.com)     Created as part of Coles HR
**************************************************/
@isTest
public class DisciplineOutcomeListControllerTests {

    public static testMethod void DisciplineOutcomeListControllerTests(){
        
        Test.StartTest();  
            RecordType hrRecType = [Select Id From RecordType  Where SobjectType = 'Case__c' and DeveloperName = 'Internal_Referral'];
            HR_Classification__c hrRec = new HR_Classification__c(Name='Test', Case_Record_Type__c=hrRecType.Id, Level_1__c='Test', Level_2__c='Test');
            insert hrRec;
            
            Account newAccount  = new Account();
            newAccount.Name     = 'word' + math.rint(math.random() * 100000);
            insert newAccount;
                        
            Contact newContact  = new Contact();
            newContact.LastName = 'word' + math.rint(math.random() * 100000);
            newContact.FirstName = 'word' + math.rint(math.random() * 100000);                     
            newContact.AccountId = newAccount.Id;            
            insert newContact;        

            Case__c originalCase    = new Case__c();
            originalCase.Contact__c  = newContact.Id;
            originalCase.Caller__c = newContact.Id;
            originalCase.Disciplinary_Outcome__c  = ' First Discipline Warning '; 
            originalCase.Date_Delivered__c = Date.Today() - 10;
            originalCase.Case_Type_3__c = hrRec.Id;
            insert originalCase;

            Case__c newCase    = new Case__c();
            newCase.Contact__c  = newContact.Id;
            newCase.Caller__c = newContact.Id;
            newCase.Disciplinary_Outcome__c  = ' First Discipline Warning '; 
            newCase.Date_Delivered__c = Date.Today() - 10;
            newCase.Case_Type_3__c = hrRec.Id;
            insert newCase;

            ApexPages.StandardController ctr = new ApexPages.StandardController(newCase);
            DisciplineOutcomeListController controller = new DisciplineOutcomeListController (ctr);

            controller.getHRCases();              

            Test.StopTest();
    }
}