global class QuickLinks {
    /*-------------------------------------------------------------
    Author:        Deepu Chacko
    Company:       Salesforce.com
    Description:   Displays data relevant to current tab in Console. Identify the type of record being shown (contact, case, matter)
                    Retrieve Quick Links configured for the particular object and run the reports specified in the Quick Links custom setting
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    16-Mar-14   Deepu               Initial Version - Detect Object Type, Custom Setting based Reports
    01-Apr-14   Deepu               Complainant reports should be run for all the complainants on the current case
    ------------------------------------------------------------*/
    
    public QuickLinks(){ }

    // Based on the given object type, fetch the quick links relevant to the object
    @RemoteAction
    global static qLinks getReports(string objectType, string objectId){
        
        qLinks retValue = new qLinks();
        objectType = string.escapeSingleQuotes(objectType);
        set<string> fields = new set<string>{'Id'};
        string query;
        
        // Get a list of reports used by this page
        retValue.QuickLinks = [SELECT Name, Object__c, Fields__c, Filters__c, Report_Id__c, Colour__c 
                FROM Quick_Links__c 
                WHERE Object__c =: objectType
                ORDER BY Order__c ASC];
                
        // For certain reports there could be a comma separated list of fields so ensure there are no duplicates
        for(Quick_Links__c q : retValue.QuickLinks){
            if(q.Fields__c != null){
                for(string f : q.Fields__c.split(',')){
                    fields.add(f);
                }
            }
        }
        
        // Form the query to retrieve the fields used by the filter fields
        query = 'SELECT isDeleted ';
        for(string f : fields)
            query += (', ' + f);
        query = query + ' FROM ' + objectType + ' WHERE Id =\'' + objectId + '\'';
        
        // If the object is case then fetch the list of complainants
        if(objectType == 'Case__c'){
            retValue.Complainants = [SELECT Contact__c
                                        FROM Complainant__c
                                        WHERE Case__c =: objectId];
        }
        retValue.sObj = Database.query(query);
        
        // Pass the given object and id so it can be used by the callback functions
        retValue.objectType = objectType;
        retValue.objectId = objectId;
        
        return retValue;
    }
    
    global class qLinks {
        global List<Quick_Links__c> QuickLinks;
        global List<Complainant__c> Complainants;
        global sObject sObj;
        global string objectType;
        global string objectId;
    }
}