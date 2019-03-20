public with sharing class Breadcrumbs {
    /*-------------------------------------------------------------
    Author:        Deepu Chacko
    Company:       Salesforce.com
    Description:   Used to display the progress bar to the user in the Incident Wizard process
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    20-Mar-14   Deepu               Initial Version - Crumbs, highlight of visited, current and next steps
    ------------------------------------------------------------*/
    // List of bread crumbs
    public List<Incident_Nav_Lookup__c> crumbs  {get; set;}     // All the crumbs that may or may not be shown
    public Incident__c inc                      {get; set;}     // Current Incident Record
    public String pageName                      {get; set;}     // Sequence number corresponding to current page
    public Decimal seq                          {get; set;}     // Sequence number corresponding to current page
    
	public Breadcrumbs() {
        // Get the incident id and current page name
        pageName = ApexPages.currentPage().getURL().substringBefore('?').toLowerCase();
        
        // If it is a clone or a new record then there will not be any other crumbs displayed other than Summary and Footer + Coding
        if( (ApexPages.currentPage().getParameters().get('id') == null) 
            || (pageName.contains('/apex/incident_summary') && ApexPages.currentPage().getParameters().get('clone') == '1') ){
                inc = new Incident__c();
        } else {
            // Get the key fields required for checking the validity of crumbs
            List<Schema.FieldSetMember> fields = 
                Schema.SObjectType.Incident__c.fieldSets.Incident_Type.getFields();
                
            // Construct the query with the key fields
            string query = 'SELECT ID ';
            for(Schema.FieldSetMember field : fields)
                query += (', ' + field.getFieldPath());
            query += ' FROM Incident__c WHERE ID = \'' + ApexPages.currentPage().getParameters().get('id') + '\'';
            
            inc = Database.query(query);
        }
        
        // Get all the crumbs
        crumbs = Incident_Nav_Lookup__c.getAll().values();
        crumbs.sort();
        
        // Identify the number for the current page
        string currentDynamicPage = '-1';
        if(ApexPages.currentPage().getParameters().get('type') != null)
            currentDynamicPage = ApexPages.currentPage().getParameters().get('type').toLowerCase().replace(' ', '_');
            
        for(Incident_Nav_Lookup__c c : crumbs){
            if(pageName.contains(c.Page__c.toLowerCase()) || currentDynamicPage.contains(c.Page__c.toLowerCase())){
                seq = c.Sequence__c;
            }
        }
	}
}