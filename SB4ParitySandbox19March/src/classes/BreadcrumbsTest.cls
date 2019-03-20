@isTest
private class BreadcrumbsTest {

	private static testMethod void testConstructor() {
	    createCustomSettings();
	    
	    Account a = new Account(Name='1');
	    insert a;
	    
	    Incident__c inc = new Incident__c(Hazard__c=true, Account__c=a.id);
	    insert inc;
	    
        PageReference pageRef = Page.Dynamic;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', inc.id);
	    
		Breadcrumbs ctrl = new Breadcrumbs();
		System.assertNotEquals(null, ctrl);
	}
	private static void createCustomSettings(){
	    List<String> pages = new List<String>{'Incident_Summary', 'Impacted_Person', 'Injury', 'Hazard', 'Near_Miss', 'Regulatory_Compliance', 'OtherIncident', 'Footer', 'Coding'};
	    List<Incident_Nav_Lookup__c> lst = new List<Incident_Nav_Lookup__c>();
        Integer seq = 1;	
        
	    for(string page : pages){
    	    Incident_Nav_Lookup__c nav = new Incident_Nav_Lookup__c(
    	                                        Name = string.valueOf(seq) + '_' + page,
    	                                        Page__c = page,
    	                                        Sequence__c = seq);
    	    lst.add(nav);
    	    seq++;
	    }
	    insert lst;
	}

}