global class IncidentWizardController 
{
    public ApexPages.standardController controller {get; set;}
    public Incident__c incident {get; set;}
    public String recordId;
    public List<Injury__c> Injuries             {get; set;}                     // Footer
    public List<Incident_Witness__c> Witnesses  {get; set;}                     // Footer
    public List<Incident_Risk_Matrix__c> RiskMatrix      {get; set;}            // Footer                            // Footer
    
    private static final integer CONS_EMPTYROWS = 3;
    private static final integer CONS_MINORAGE = 16;
    private string pageName;
    private string siteProfileId;
    private string communityProfileId;
    
    public Boolean isTeamMember
    { 
        get { return (incident.Injured_Party_Type__c == 'Team Member'); } 
    }
    public Boolean isVisitor
    { 
        get { return (incident.Injured_Party_Type__c == 'Contractor' || incident.Injured_Party_Type__c == 'Visitor' || incident.Injured_Party_Type__c == 'Regulator'); } 
    }
    public Boolean isNotTeamMember
    { 
        get { return (incident.Injured_Party_Type__c != 'Team Member' && incident.Injured_Party_Type__c != null); } 
    }
    public Boolean isMinor
    { 
        get {  
            // Basically the logic needs to check either Age Group OR Date of Birth to determine if the Person is under the age of 16.
            // If they are display the Minor Details field set. 
            // Note that in the case of a Team Member Date of Birth is stored against the associated Contact record, otherwise it is stored in the Incident.
            Date BirthDate = null;
            String AgeGroup = null;
            Boolean retValue = false;
            
            if(isTeamMember && incident.Team_Member_Not_Known__c == false && incident.Injured_Party__c != null){
                Contact c = [SELECT Birthdate
                                FROM Contact
                                WHERE Id =:incident.Injured_Party__c];
                if(c != null && c.Birthdate != null){
                    BirthDate = c.Birthdate;
                }
            } 
            else {
                BirthDate = incident.date_of_birth__c;
                AgeGroup = incident.Age_Group__c;
            }
            
            // Check if age group or date of birth is specified
            if(BirthDate != null){
                date todaysDate = date.today();
                Long Diff = BirthDate.daysBetween(todaysDate);

                retValue = (Math.floor(diff/365.2425) < CONS_MINORAGE);
            }
            else if(AgeGroup != null){
                retValue = (AgeGroup == '<16');
            }
            return retValue;
        }
    }
    // Called from test class to set the current page
    public void setPageName(string val){
        if(val == null)
            val = ApexPages.currentPage().getURL().substringBefore('?').toLowerCase();
        pageName = val;
    }

    public IncidentWizardController(ApexPages.StandardController stdController) 
    {
        integer emptyRows;
        
        controller = stdController;
        incident = (Incident__c)controller.getRecord();
        
        setPageName(null);
        
        siteProfileId = [SELECT Id FROM Profile WHERE Name='Coles Safety Profile' LIMIT 1][0].Id;
        communityProfileId = [SELECT Id FROM Profile WHERE Name='Safety Community User' LIMIT 1][0].Id;
        
        // List of injuries
        if(pageName.contains('injury')) {
            Injuries = [SELECT ID, Name, Incident__c, Injury_Illness_Type__c, Bodily_Location__c, Injury_Illness_Details__c, Position__c
                        FROM Injury__c
                        WHERE Incident__c =: incident.Id];
                        
            // Minimum 3 empty rows, if there is data then there should be at least one empty row.
            emptyRows = CONS_EMPTYROWS - Injuries.size();
            if(emptyRows <= 0) emptyRows = 1;
    
            while(emptyRows > 0){
                addNewRow();
                emptyRows--;
            }
        }
        
        // If it is the footer page then get the list of witness
        if(pageName.contains('/footer')){
            // Witness
            Witnesses = [SELECT ID, Name, Incident__c, Contact__c, 
                                Witness_Email__c, Witness_Name__c, Witness_Phone_No__c, Witness_Type__c
                        FROM Incident_Witness__c
                        WHERE Incident__c =: incident.Id];
            emptyRows = CONS_EMPTYROWS - Witnesses.size();
            if(emptyRows <= 0) emptyRows = 1;
    
            while(emptyRows > 0){
                addNewWitnessRow();
                emptyRows--;
            }

            ActionTasks = new List<clsTask>();
            for(Task t : [SELECT ID, Type, Subject, ActivityDate, Status, WhatId, RecordTypeId
                        FROM Task
                        WHERE WhatId =: incident.Id]){
                ActionTasks.add(new clsTask(t));
            }
            emptyRows = CONS_EMPTYROWS - ActionTasks.size();
            if(emptyRows <= 0) emptyRows = 1;
    
            while(emptyRows > 0){
                addNewActionRow();
                emptyRows--;
            }
            
            // Custom Settings for Risk
            RiskMatrix = Incident_Risk_Matrix__c.getAll().values();
            RiskMatrix.sort();
        }
    }

    public PageReference save() 
    {
        // Detect if it is a clone step, if it is copy over all the details except the Injury details and Impacted Person information.
        if(pageName.contains('/incident_summary') && ApexPages.currentPage().getParameters().get('clone') == '1'){
            cloneActions();
        }

        controller.save();
        
        incident = (Incident__c)controller.getRecord();
        
        if(pageName.contains('/injury')){
            upsertInjuries();
        }
            
        if(pageName.contains('/footer')){
            upsertWitness();
            upsertActions();
        }
        return null;   
    }
    
    // Called from constructur to reset fields specifically during a clone operation
    public void cloneActions(){
        // When a case is being cloned, you need to copy over everything like Regulatory, Compliance, Near Miss everything 
        // except the Impacted Person and Injuries. So the approach will be query all the fields on the incident record being cloned
        // and then clear out the ones like Person and Injuries
        sObject original;
        List<String> originalFields = new List<String>();
        string query = 'SELECT ID ';
        Map<String, Schema.SObjectField> incFields = Schema.SObjectType.Incident__c.fields.getMap();
        for(String f : incFields.KeySet()){
            Schema.DescribeFieldResult incField = incFields.get(f).getDescribe();
            if(incField.isAccessible() && 
                incField.isCreateable() &&
                incField.isCustom() &&
                !incField.isAutoNumber() &&
                !incField.isCalculated() ){
                    query += ', ' + incField.getName();
                    originalFields.add(incField.getName());
                }
        }
        query += ' FROM Incident__c WHERE Id =\'' + incident.id + '\'';
        original = Database.query(query);
        
        // Set the original values onto the new record and clear out the ones u dont want. While setting make sure you are not 
        // overwriting the existing values
        sObject obj = incident;
        for(string f : originalFields){
            // Any fields entered on the UI will not be null on the incident record so dont over write those
            if(obj.get(f) == null)
                obj.put(f, original.get(f));
        }
        incident = (Incident__c)obj;
   
        // Clear Impacted Person Information, use the field sets displayed on the UI to clear out the fields
        incident.Injured_Party_Type__c = null;
        incident.Team_Member_Not_Known__c = false;
        incident.Injured_Party__c = null;
        incident.Occurred_When__c = null;
        incident.Date_of_Birth__c = null;
        incident.Age_Group__c = null;
        
        set<string> fieldSets = new set<string>{'Person_Details', 'Person_Address', 'Visitor_Details', 'Minor_Details'};
        clearFieldSets(fieldSets);
        
        // Clear Injuries
        Injuries = null;
        fieldSets = new set<string>{'Injury_Details', 'First_Aid_Details', 'Referral_Details', 'Injury_Care', 'Resumed_Work', 'Slip_or_Fall'};
        clearFieldSets(fieldSets);
    }
    
    // Given a set of field sets, clear the values in it
    private void clearFieldSets(set<string> fieldSets){
        sObject obj = incident;
        // For each field set
        for(string fieldSet : fieldSets){
            // Get the list of fields.
            List<Schema.FieldSetMember> fields = 
                Schema.SObjectType.Incident__c.fieldSets.getMap().get(fieldSet).getFields();
            // For each of the field, clear the value
            for(Schema.FieldSetMember field : fields)
                obj.put(field.getFieldPath(), (field.getType() == Schema.DisplayType.Boolean ? false : null));
        }
        incident = (Incident__c)obj;
    }
    
    public void setRiskSeverity(){
        incident.Risk_Rating__c = System.currentPagereference().getParameters().get('RiskSeverity');
    }
    
    public void setIncidentRecordType(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Incident__c; 
        Map<String,Schema.RecordTypeInfo> IncidentRecordTypes = d.getRecordTypeInfosByName();

        if(incident.Account__c != null){
            Account site = [SELECT ID, Brand__c
                            FROM Account
                            WHERE ID =: incident.Account__c];
            if(site != null && site.Brand__c != null){
                Schema.RecordTypeInfo rt = IncidentRecordTypes.get(site.Brand__c);
                if(rt != null)
                    incident.RecordTypeId = rt.getRecordTypeId();
            }
        }
    }
    
    public void addNewRow(){
        Injuries.add(new Injury__c(Incident__c = incident.Id));
    }
    public void addNewWitnessRow(){
        Witnesses.add(new Incident_Witness__c(Incident__c = incident.Id));
    }
    public void addNewActionRow(){
        ActionTasks.add(new clsTask(incident.Id));
    }
    
    public void upsertInjuries()
    {
        if(pageName.contains('injury') && Injuries.size() > 0) {
            List<Injury__c> tempInjuryList = new List<Injury__c>();
            for(Injury__c i: Injuries) {
                if(i.Injury_Illness_Type__c != null)
                {
                    tempInjuryList.add(i);
                }
            }
            if(tempInjuryList.size() > 0) {
                upsert tempInjuryList;
            }
        }
    }
    public void upsertWitness()
    {
        if(pageName.contains('footer') && Witnesses.size() > 0) {
            List<Incident_Witness__c> tempList = new List<Incident_Witness__c>();
            for(Incident_Witness__c i: Witnesses) {
                if(i.Witness_Type__c != null)
                {
                    if(i.Witness_Type__c != 'Team Member') i.Contact__c = null;
                    tempList.add(i);
                }
            }
            if(tempList.size() > 0) {
                upsert tempList;
            }
        }
    }
    public void upsertActions()
    {
        // Tasks could either be created or updated.
        if(pageName.contains('footer') && ActionTasks.size() > 0) {
            List<Task> tempList = new List<Task>();
            for(clsTask i: ActionTasks) {
                if(i.Type != '-- None --')      // This is the default value on the Type picklist
                {
                    tempList.add(new Task(
                        Id = i.Id,
                        WhatId  = i.WhatId,
                        Type    = i.Type,
                        Subject = i.Subject,
                        Status = i.Status,
                        ActivityDate = i.ActivityDate,
                        RecordTypeId = i.RecordTypeId));
                }
            }
            if(tempList.size() > 0) {
                upsert tempList;
            }
        }
    }
    
    public PageReference newIncident()
    {
        PageReference retPage = new PageReference('/colesservice1/Incident_Summary');
        return retPage;
    }

    // Depending on the selected Incident Type, route it to the appropriate page
    public PageReference nextPage()
    {
        String navPage;
        String currentDynamicPage = 'novalue';
        
        List<Incident_Nav_Lookup__c> navList = Incident_Nav_Lookup__c.getAll().values();
        PageReference gotoPage;
        
        if(incident.Submit__c)
        {
            incident.Status__c = 'Submitted';
        }

        if(incident.Id!=null) {
            Try {
                update incident;
            }
            Catch (DMLException ex) {
                ApexPages.addMessages(ex);
                return null;
            }
        }
        
        else {
            Try {
                insert incident;
            }
            Catch (DMLException ex) {
                ApexPages.addMessages(ex);
                return null;  
            }
        }
        
        save();
        
        navList.sort();
        
        if(ApexPages.currentPage().getParameters().get('type') != null) {
            currentDynamicPage = ApexPages.currentPage().getParameters().get('type').toLowerCase().replace(' ', '_');
        }
        Decimal pageNum = 0;

        for(Incident_Nav_Lookup__c n :navList)
        {
            if(pageName.contains(n.Page__c.toLowerCase()) || currentDynamicPage.contains(n.Page__c.toLowerCase()))
            {
                pageNum = n.Sequence__c;
            }
            if(pageNum!=0 && n.Sequence__c>pageNum)
            {
                if(incident.Injury_or_Illness__c && n.Page__c=='Impacted_Person') {
                    gotoPage = Page.Impacted_Person;
                }
                else if(incident.Type__c == 'Car Wash' && n.Page__c=='Impacted_Person') {
                    gotoPage = Page.Impacted_Person;
                }
                else if(incident.Injury_or_Illness__c && n.Page__c=='Injury') {
                    gotoPage = Page.Injury;
                }
                else if(incident.Other_Incident__c && n.Page__c=='OtherIncident') {
                    gotoPage = Page.OtherIncident;
                }
                else if(incident.Hazard__c && n.Page__c== 'Hazard'){
                    gotoPage = Page.Dynamic;
                    gotoPage.getParameters().put('type', 'Hazard');
                }
                else if(incident.Regulatory_Compliance__c && n.Page__c== 'Regulatory_Compliance'){
                    gotoPage = Page.Dynamic;
                    gotoPage.getParameters().put('type', 'Regulatory Compliance');
                }
                else if(incident.Near_Miss__c && n.Page__c== 'Near_Miss'){
                    gotoPage = Page.Dynamic;
                    gotoPage.getParameters().put('type', 'Near Miss');
                }
                else if(n.Page__c == 'Footer'){
                    gotoPage = Page.Footer;
                }
                else if(n.Page__c == 'Coding'){
                    if(Userinfo.getProfileId() == siteProfileId)
                        gotoPage = new Pagereference('/colesservice1/SubmissionPage');
                    else if(Userinfo.getProfileId() == communityProfileId)
                        gotoPage = new Pagereference('/' + incident.id);
                    else
                        gotoPage = Page.Coding;
                }
            }
            
            if (gotoPage != null) {
                break;
            }
        }
        
        if (gotoPage == null) {
            gotoPage = new Pagereference('/' + incident.id);
        }
        
        else {
            gotoPage.setRedirect(true);
            gotoPage.getParameters().put('id', incident.Id);
            gotoPage.getParameters().put('retURL', '/' + incident.Id);
        }        
        
        return gotoPage;
    }
    
    public PageReference prevPage()
    {
        // Use the current page to find the sequence number in the custom setting. 
        // From there subtract 1 of the sequence and check if the resulting page is relevant to this incident.
        List<Incident_Nav_Lookup__c> navList = Incident_Nav_Lookup__c.getAll().values();
        PageReference gotoPage;
        String currentPage = ApexPages.currentPage().getURL().substringBefore('?').toLowerCase();
        String currentDynamicPage = 'novalue';
        Decimal pageNum = 0;
        
        navList.sort();
        
        // Find the current seq
        if(ApexPages.currentPage().getParameters().get('type') != null) {
            currentDynamicPage = ApexPages.currentPage().getParameters().get('type').toLowerCase().replace(' ', '_');
        }
        
        for(integer count = navList.size()-1; count >=0; count--)
        {
            Incident_Nav_Lookup__c n = navList[count];

            if(pageName.contains(n.Page__c.toLowerCase()) || currentDynamicPage.contains(n.Page__c.toLowerCase())){
                pageNum = n.Sequence__c;
            }
            // Once the page is found
            if(pageNum != 0 && n.Sequence__c < pageNum){
                if(n.Page__c == 'Footer'){
                    gotoPage = Page.Footer;
                }
                else if(n.Page__c == 'Coding'){
                    gotoPage = Page.Coding;
                }
                else if(incident.Near_Miss__c && n.Page__c== 'Near_Miss'){
                    gotoPage = Page.Dynamic;
                    gotoPage.getParameters().put('type', 'Near Miss');
                }
                else if(incident.Regulatory_Compliance__c && n.Page__c== 'Regulatory_Compliance'){
                    gotoPage = Page.Dynamic;
                    gotoPage.getParameters().put('type', 'Regulatory Compliance');
                }
                else if(incident.Hazard__c && n.Page__c== 'Hazard'){
                    gotoPage = Page.Dynamic;
                    gotoPage.getParameters().put('type', 'Hazard');
                }
                else if(incident.Type__c == 'Car Wash' && n.Page__c=='Impacted_Person') {
                    gotoPage = Page.Impacted_Person;
                }
                else if(incident.Other_Incident__c && n.Page__c=='OtherIncident') {
                    gotoPage = Page.OtherIncident;
                }
                else if(incident.Injury_or_Illness__c && n.Page__c=='Injury') {
                    gotoPage = Page.Injury;
                }
                else if(incident.Injury_or_Illness__c && n.Page__c=='Impacted_Person') {
                    gotoPage = Page.Impacted_Person;
                }
                if(n.Page__c == 'Incident_Summary'){
                    gotoPage = Page.Incident_Summary;
                }
            }
            if (gotoPage != null)
                break;
        }

        gotoPage.setRedirect(true);
        gotoPage.getParameters().put('id', incident.Id);
        gotoPage.getParameters().put('retURL', '/' + incident.Id);
        return gotoPage;
    }
    // Return all the classifiers to display in the UI
    @RemoteAction
    global static List<Dependent_List_Master__c> getAllCauses(){
        return [SELECT ID, Name, Level_1__c, Level_2__c, Level_3__c
                FROM Dependent_List_Master__c
                WHERE Object__c = 'Incident__c' AND Field__c = 'Agency' AND Active__c = true
                ORDER BY Level_1__c, Level_2__c, Level_3__c];
    }    
    
    // On a Force.com Site the Task object is not exposed so creating a wrapper class to contain the Task
    // Ref: http://salesforce.stackexchange.com/questions/30727/viewing-and-inserting-a-task-from-force-com-site
    public List<clsTask> ActionTasks                   {get; set;}                     // Footer
    public class clsTask{
        public Id Id                    {get; set;}
        public string Type              {get; set;}
        public string Subject           {get; set;}
        public date ActivityDate        {get; set;}
        public string Status            {get; set;}
        public Id WhatId                {get; set;}
        public Id RecordTypeId          {get; set;}
        
        // Called when querying for tasks
        public clsTask(Task t){
            this.Id          = t.Id;
            this.WhatId      = t.WhatId;
            this.Type        = t.Type;
            this.Subject     = t.Subject;
            this.Status      = t.Status;
            this.ActivityDate = t.ActivityDate;
            this.RecordTypeId = t.RecordTypeId;
        }
        
        // Called when creating new tasks
        public clsTask(Id incidentId){
            RecordType rt = [SELECT Name, Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName='Immediate_Action' LIMIT 1];
            
            this.WhatId      = incidentId;
            this.Type        = '';
            this.Subject     = null;
            this.Status      = 'Completed';
            this.ActivityDate = null;
            this.RecordTypeId = rt.Id;
        }
    }
    
    public List<SelectOption> getActionItemTypes() {
        list<SelectOption> options = new list<SelectOption>();
        options.add(new SelectOption('-- None --', ''));
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = Task.sObjectType.getDescribe();       
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values = fieldMap.get('Type').getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){ 
            options.add(new SelectOption(a.getLabel(), a.getValue())); 
        }
        return options;
    }    
}