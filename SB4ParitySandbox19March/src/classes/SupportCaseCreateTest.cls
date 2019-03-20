@isTest
private class SupportCaseCreateTest {
	private static final String testEmpId = '00999999';
    private static string testrun;
	static testMethod void CaseTest (){
		List<Contact> TestContact = [Select ID, Email from Contact where employee_ID__c = :testEmpid limit 1];
        //Testing start 
        Test.startTest();
		testrun = SupportCaseCreate.createNewCase(testEmpId,TestContact[0].Email,'0412345678','Email','Test','Test','Test','Test Description');
		//Checkpoint for successfully execution or above method
		Case tempCase = [Select Contact.Employee_ID__c from case limit 1];
		System.assertEquals(testEmpId, tempCase.Contact.Employee_ID__c);
        Test.stopTest();
	}
	
	/****************  TestSetup method will create Data ****************/
	@TestSetup
	static void anyRandomNameToSetupTestData(){
			Contact temp = new Contact();
			//If the employee_ID__c is unique, the test value should also be unique against values in other contact records
			//temp.employee_ID__c = '00999999'; or use below line
			temp.employee_ID__c = testEmpId;
			//required fields
			temp.LastName = 'Test Surname';
			temp.Email = 'testing@example.com';
			temp.FirstName = 'Test FirstName';
			insert temp;
			//now query in test-method will work.
	}
}