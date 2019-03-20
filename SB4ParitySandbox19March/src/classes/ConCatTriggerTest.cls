/***************
 *	Name:			ConCatTriggerTest
 *	Description:	Test Class for Contact Category Trigger logic
 * 	History:
 *	---------------
 *	16.04.2015	Richard Enojas (Salesforce)		Created, PrimaryTest()
 ***************/

@isTest
public with sharing class ConCatTriggerTest {

    static testMethod void PrimaryTest() {
        // TO DO: implement unit test
        
        RecordType accrec = [Select Id from RecordType where SObjectType = 'Account' and Name = 'Supplier'];
        RecordType conrec = [Select Id from RecordType where SObjectType = 'Contract__c' and Name = 'Supplier Agreement'];
	
		//create Account
		Account acc = new Account();
    	acc.Name = 'Test Account';
    	acc.RecordTypeId = accrec.Id;
		
		insert acc;
		
		//create Contract
		Contract__c con = new Contract__c();
		con.Name = 'Test Contract';
		con.Account__c = acc.Id;
		
		insert con;
		
		
		//create Product Category
		Product_Category__c pcat1 = new Product_Category__c();
		pcat1.Name = 'Test Category 1';
		
		Product_Category__c pcat2 = new Product_Category__c();
		pcat2.Name = 'Test Category 2';
		
		insert pcat1;
		insert pcat2;
		
		//create junction record in Contract Category
		Contract_Category__c ccat1 = new Contract_Category__c();
		ccat1.Contract__c = con.Id;
		ccat1.Product_Category__c = pcat1.Id;
		ccat1.Primary__c = true;
		
		insert ccat1;
		
		//un-set primary
		ccat1.Primary__c = false;
		update ccat1;
		
		//create another junction record and set it as primary
		Contract_Category__c ccat2 = new Contract_Category__c();
		ccat2.Contract__c = con.Id;
		ccat2.Product_Category__c = pcat2.Id;
		ccat2.Primary__c = true;
		
		insert ccat2;
		
		//delete junction record
		delete ccat2;
		
		system.assertEquals(null, con.Primary_Category__c);
	}
}