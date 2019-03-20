@isTest
private class QuickLinksTest {
    private static testMethod void testGetReports() {
        QuickLinks q = new QuickLinks();
        
        Contact c = new Contact(firstName='deepu', lastname='chacko');
        insert c;
        
        Quick_Links__c link = new Quick_Links__c(Name='test', Object__c = 'Contact', Fields__c='Id', Filters__c='xxx', Report_Id__c='yyy', Order__c=1);
        insert link;
        
        system.debug(QuickLinks.getReports('Contact', string.valueof(c.id)));
    }
}