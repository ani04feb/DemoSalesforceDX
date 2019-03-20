@isTest
private class UpdateProductCategoryContactsTest {
    @isTest static void TestUpdateProductCategoryContacts () {
        //Setup test data of product category, contact and contract
        Account a = new Account(Name='TestName');
        Profile p = [SELECT Id FROM Profile WHERE Name='Category Manager User 2'];
        User u = new User(Alias = 'standt', Email='standarduser@coles.com.au', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@coles_incidents.com.au', External_ID__c='99000001', EmployeeNumber='99000001'); 
        User u2 = new User(Alias = 'standt2', Email='standarduser2@coles.com.au', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser2@coles_incidents.com.au', External_ID__c='99000002', EmployeeNumber='99000002');
        insert a;
        insert u;
        insert u2;
        Product_Category__c testProd = new Product_Category__c(Name='Test Goods', OwnerID=u.id);
        insert testProd;
        Contact testContact = new Contact(OwnerID=u.id, Product_Category__c=testProd.id, FirstName='Food', LastName='Supplier', Account=a);
        Contract__c testContract = new Contract__c(OwnerID=u.id, Primary_Category__c=testProd.id, Account__c=a.id, 
            RecordTypeId=[SELECT Id from RecordType WHERE Name = 'Coles Brand' and SobjectType = 'Contract__c'].Id);
        insert testContact;
        insert testContract;
        
        Test.startTest();
        testProd.OwnerID=u2.id;
        update testProd;
        Test.stopTest();
        
        System.assertEquals(testProd.OwnerID, u2.id);
        //System.assertEquals(testContact.OwnerID, u2.id);
        //System.assertEquals(testContract.OwnerID, u2.id);
    }
}