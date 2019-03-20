global class zIncidentWizard {
    /*-------------------------------------------------------------
    Author:        Deepu Chacko, Lok Jackson, Kim Davies, Paul Fayle
    Company:       Salesforce.com
    Description:   Main and only controller while traversing the wizard pages
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    26-Mar-14   Deepu               Initial Version - Ported functionality from existing wizard pages
    02-Apr-14   Deepu               Added Investigations & Actions functionality
    05-Jun-14   Lok Jackson         WP3951: Added logic to support Quick Coding and Mechanism search
    27/05/2016  JD & Battleham      Added error message re future date-Time
    06/07/2016  JD & Battleham      Added Incident_date to SOQL query 
    ------------------------------------------------------------*/
    private static final integer CONS_EMPTYROWS = 3;
    private static final integer CONS_MINORAGE = 16;
    private static final integer CONS_WITNESS_EMPTYROWS = 1;
    private static final integer CONS_INJURY_EMPTYROWS = 1;
    
    private ApexPages.standardController controller;        // Used to invoke base class save operations
    
    public Incident__c incident                 {get; set;}
    public Incident_Navigation__c thisPage      {get; set;} // Used by bread allPages and navigation buttons
    public List<Incident_Navigation__c> allPages{get; set;} // Used by bread allPages and navigation buttons
    public String redirectURL                   {get; set;} // Click Next or Prev and you need to know the page to go to
    public List<Injury__c> Injuries             {get; set;} // Injury page to list and save new injuries
    public List<Incident_Witness__c> Witnesses  {get; set;} // Miscellaneous page to list and save new witness
    public List<Incident_Risk_Matrix__c> RiskMatrix      {get; set;} // Miscellaneous page to display help for Risk Matrix Table
    // On a Force.com Site the Task object is not exposed so creating a wrapper class to contain the Task
    // Ref: http://salesforce.stackexchange.com/questions/30727/viewing-and-inserting-a-task-from-force-com-site
    public List<clsTask> ActionTasks            {get; set;} // Miscellaneous page to list and save new immediate action items that are completed tasks
    public List<clsTask> CorrectiveTasks        {get; set;} // Corrective Actions
    public Boolean submissionFlag               {get; set;}
    public String quickCode                     {get; set;}
    public Boolean codingConsoleError           {get; set;}
    public string incidentTime                  {get; set;}
    
    public Boolean isCodingError {
        get { return codingConsoleError; } 
    }

    public zIncidentWizard(ApexPages.StandardController stdController){
        // Instance variables
        controller = stdController;
        incident = (Incident__c)controller.getRecord();
        submissionFlag = false;
        if(ApexPages.currentPage().getParameters().get('selection') != null){
            if(ApexPages.currentPage().getParameters().get('selection')=='Hazard')
                incident.Hazard__c = true;
            else if(ApexPages.currentPage().getParameters().get('selection')=='Injury')
                incident.Injury_or_Illness__c = true;
            else if(ApexPages.currentPage().getParameters().get('selection')=='Other')
                incident.Other_Incident__c = true;
        }
        
        if(ApexPages.currentPage().getUrl().contains('zIncidentSummary')){
            if(incident.Id != null){
                Incident__c i = [SELECT Incident_Date_Time__c, Incident_Date__c FROM Incident__c WHERE Id = :incident.Id];
                //changing from incident to i
                if(i.Incident_Date__c == null && i.Incident_Date_Time__c != null ){
                    System.Debug('>>>>>>>>>>>>>>> ' + i.Incident_Date_Time__c.date());
                    incident.Incident_Date__c = i.Incident_Date_Time__c.date();
                }
                if(incidentTime == null && i.Incident_Date_Time__c != null){
                    System.Debug('>>>>>>>>>>>>>>> ' + i.Incident_Date_Time__c.time());
                    incidentTime = fetchTime(i.Incident_Date_Time__c.time());
                }
                //incident.Incident_Date_Time__c = null;
            }
        }
        
        // Get all the pages
        //allPages = Incident_Navigation__c.getAll().values();
        //allPages.sort();
        allPages = [SELECT Id, Name, Breadcrumb__c, Page__c, Sequence__c FROM Incident_Navigation__c ORDER BY Sequence__c ASC];
        
        // Get the current page record
        String pageName = ApexPages.currentPage().getURL().substringBefore('?').toLowerCase();
        String currentDynamicPage = '-1';
        if(ApexPages.currentPage().getParameters().get('type') != null && ApexPages.currentPage().getParameters().get('type') != '')
            currentDynamicPage = ApexPages.currentPage().getParameters().get('type').toLowerCase().replace(' ', '_');
        
        for(Incident_Navigation__c c : allPages){
            if(pageName.contains(c.Page__c.toLowerCase()) || currentDynamicPage.contains(c.Page__c.toLowerCase())){
                thisPage = c;
            }
        }
        
        // Page specific actions
        if(thisPage == null) thisPage = allPages[0];        // Safety Net, will be removed once all the pages can run w/o errors if a Page is not identified
        if(thisPage.Page__c == 'zInjury') injuryPageInit();
        if(thisPage.Page__c == 'zMiscellaneous') miscellaneousPageInit();
        if(thisPage.Page__c == 'zInvestigationsActions') investigationsActionsInit();
        if(thisPage.Page__c == 'zInvolvedPerson') involvedPersonInit();
        // If this is a clone, copy over all the fields on the original record and blank out a specific set of fields.
        if(thisPage.Page__c == 'zIncidentSummary' && ApexPages.currentPage().getParameters().get('clone') == '1') cloneInit();
    }
    
    private void injuryPageInit(){
        getInjuries();
    }
    private void miscellaneousPageInit(){
        getWitness();
        getTasks();
        // Custom Settings for Risk
        RiskMatrix = Incident_Risk_Matrix__c.getAll().values();
        RiskMatrix.sort();        
    }
    private void investigationsActionsInit(){
        getTasks();
    }
    private void involvedPersonInit(){
        getWitness();
    }
    // Clone requirement is to copy over all the fields from the original and leave out Involed Person and Injuries.
    private void cloneInit(){
        // Do the clone here
        String soql = getCreatableFieldsSOQL('incident__c','id=\'' + incident.id + '\'');
        Incident__c original = (Incident__c)Database.query(soql);
        incident = original.clone(false, true);

        // Clear out Involved Person Information
        incident.Injured_Party_Type__c = null;
        incident.Team_Member_Not_Known__c = false;
        incident.Injured_Party__c = null;
        incident.Occurred_When__c = null;
        incident.Date_of_Birth__c = null;
        incident.Age_Group__c = null;
        incident.Age_Group_Descriptive__c = null;
        incident.Page_2_Complete__c = false;
        
        incident.Pages_Complete__c = null;
        
        set<string> fieldSets = new set<string>{'Person_Details', 'Person_Address', 'Visitor_Details', 'Minor_Details', 'Injury_Page', 'Severity'};
        clearFieldSets(fieldSets);

        // Clear Injury related details
        fieldSets = new set<string>{'Injury_Details', 'First_Aid_Details', 'Referral_Details', 'Injury_Care', 'Resumed_Work', 'Slip_or_Fall'};
        clearFieldSets(fieldSets);
        incident.Page_3_Complete__c = false;
        
        // Clear or Reset fields that impact notifications
        incident.Notification_Workflows_Triggered__c = null;
        incident.Notifications_Sent__c = false;
        incident.Status__c = 'Draft';
    }
    
    public PageReference consoleSave(){
        codingConsoleError = FALSE;
        try {
            update incident;
        } catch(DMLException ex) {
            codingConsoleError = TRUE;
            ApexPages.addMessages(ex);
            return null;
        }
        return null;
    }
    
    // Called on click of previous, next and 'Save & Close'. Uses redirectURL to know where to go after save operation
    public PageReference saveRecord(){
        Boolean isSaveSuccess = true;
        PageReference pg = null;
        // Detect if it is a clone step, if it is copy over all the details except the Injury details and Impacted Person information.
        if(thisPage.Page__c == 'zIncidentSummary' && ApexPages.currentPage().getParameters().get('clone') == '1'){
            // Take the values entered on the UI and apply on to the Incident record to insert.
            sObject userChanges = controller.getRecord();
            
            incident.put('Account__c',          userChanges.get('Account__c'));
            //incident.put('Page_1_Complete__c',  userChanges.get('Page_1_Complete__c'));
            incident.put('RecordTypeId',        userChanges.get('RecordTypeId'));
            
            // Loop through the fields on the UI and update the incident record
            Set<String> fieldSets = new Set<String>{'Incident_Details', 'CCTV_Details', 'Incident_Type'};
            // For each field set
            for(string fieldSet : fieldSets){
                // Get the list of fields.
                List<Schema.FieldSetMember> fields = 
                    Schema.SObjectType.Incident__c.fieldSets.getMap().get(fieldSet).getFields();
                // For each of the field, clear the value
                for(Schema.FieldSetMember field : fields)
                    incident.put(field.getFieldPath(), userChanges.get(field.getFieldPath()));
            }
            
            try { 
                insert incident;
            } catch(Exception ex) {
                ApexPages.addMessages(ex);
                return null;
            }
            
        } else {
            if(incident.Pages_Complete__c == null)
                incident.Pages_Complete__c = incident.Pages_Complete__c + thisPage.Page__c;
            else if(!incident.Pages_Complete__c.contains(thisPage.Page__c))
                incident.Pages_Complete__c = incident.Pages_Complete__c + thisPage.Page__c;
            //Write Date and Time values to DateTime field
            if(thisPage.Page__c == 'zIncidentSummary'){
                 if(incident.Incident_Date__c != null && incidentTime != null )
                     incident.Incident_Date_Time__c = datetime.newInstance(incident.Incident_Date__c.year(), incident.Incident_Date__c.month(), incident.Incident_Date__c.day(), fetchHour(incidentTime), fetchMinute(incidentTime), 0);
                 if(incident.Incident_Date__c != null && incidentTime == null)   
                      incident.Incident_Date_Time__c = datetime.newInstance(incident.Incident_Date__c.year(), incident.Incident_Date__c.month(), incident.Incident_Date__c.day(), 0, 0, 0); 
            }    
                
               
             //If Summary Page Page marked as complete check that incident date/time does not exceed now()
            if(thisPage.Page__c == 'zIncidentSummary'){
                if(incident.Incident_Date_Time__c > Datetime.Now()){
                    ApexPages.Message futuredateMsg = new ApexPages.Message(ApexPages.Severity.Fatal,'Please enter a date/Time less than now');
                    ApexPages.addMessage(futuredateMsg);
                    return null;
                }
            }   
            //If Summary Page Page marked as complete check that incident time has a valid format       
            if(thisPage.Page__c == 'zIncidentSummary'){     
                if(IncidentTime.containsNone(':')) {        
                    ApexPages.Message futuredateMsg = new ApexPages.Message(ApexPages.Severity.Fatal,'Please enter a valid Time format using the time picker');     
                    ApexPages.addMessage(futuredateMsg);        
                    return null;        
                }       
            }   
            
            //If Injury/Illness Page marked as complete check that at least the first injury/illness is populated wih data 
            if(thisPage.Page__c == 'zInjury'){
                if(Injuries[0].Injury_Illness_Type__c==null || Injuries[0].Bodily_Location__c==null || Injuries[0].Position__c==null){
                    ApexPages.Message injuryMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter injury or illness details'); 
                    ApexPages.addMessage(injuryMsg);
                    return null;
                }
                else{
                    //Loop through and find the Primary Injury, then push it into the Injury field on Incident
                    Boolean primary = false;
                    for (Injury__c injury: Injuries){
                        if(injury.Primary__c){
                            incident.Injury_Description__c = injury.Injury_Illness_Type__c + ', ' + injury.Bodily_Location__c + ', ' + injury.Position__c + ', ' + injury.Injury_Illness_Details__c;
                            primary = true;
                        }
                    }
                    // If no Primary set, make it the first injury
                    if(!primary){
                        Injuries[0].Primary__c = true;
                        incident.Injury_Description__c = Injuries[0].Injury_Illness_Type__c + ', ' + Injuries[0].Bodily_Location__c + ', ' + Injuries[0].Position__c + ', ' + Injuries[0].Injury_Illness_Details__c;
                    }
                }
            }
            //If Injury/Illness Page marked as complete check that at least the first injury/illness is populated wih data 
            if(thisPage.Page__c == 'zMiscellaneous'){
                if(!incident.Is_Compliance_Only__c && incident.Risk_Rating__c == null) {
                    ApexPages.Message riskRatingMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select a Risk Rating');
                    ApexPages.addMessage(riskRatingMsg);
                    return null;
                }
            }
            if(thisPage.Page__c == 'zInvestigationsActions'){
            System.Debug('>>>>>>>>>>>>> ' + ActionTasks[0].Action);
                if(ActionTasks[0].Action==null || ActionTasks[0].Action=='' || ActionTasks[0].DateCompleted==''){
                    System.Debug('>>>>>>>>>>>>> IN ERROR HANDLER');
                    ApexPages.Message actionMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter at least 1 Immediate Action');
                    ApexPages.addMessage(actionMsg);
                    return null;
                }
            }
            if(thisPage.Page__c == 'zCoding' || thisPage.Page__c == 'zInvestigationsActions'){
                String currentStatus = [SELECT Status__c FROM Incident__c WHERE Id = :incident.Id].Status__c;
                if(incident.Status__c == 'Closed' && currentStatus != 'Closed') {
                    incident.Closed_By__c = UserInfo.getName(); 
                    incident.Date_Closed__c = Date.Today();
                    List<Task> t = [SELECT Id FROM Task WHERE WhatId = :incident.Id AND isClosed = false];
                    if(t.size() > 0) {
                        incident.Status__c = currentStatus;
                        ApexPages.Message taskErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot Close the Incident as there are Open Actions');
                        ApexPages.addMessage(taskErrorMsg);
                        return null; 
                    }
                }     
            } 
            
            if(thisPage.Page__c == 'zInjury') {
                if(incident.Injury_Code__c == 'F1')
                    incident.Injury_Illness_Severity__c = 'Fatality';
                else if(incident.Injury_Type__c == 'Lost Time Injury')
                    incident.Injury_Illness_Severity__c = 'Lost Time';
                else if(incident.Injury_Type__c == 'Restricted Duties Injury')
                    incident.Injury_Illness_Severity__c = 'Restricted Duties';
                else if(incident.Injury_Type__c == 'Medically Treated Injury')
                    incident.Injury_Illness_Severity__c = 'Medical Treatment';
                else if(incident.Onsite_Type_of_Treatment__c == 'First Aid' || incident.First_Aid_Provided__c == 'Yes')
                    incident.Injury_Illness_Severity__c = 'First Aid';
                else
                    incident.Injury_Illness_Severity__c = 'No Treatment';
            }
              
            try {
                upsert incident;
            } catch(Exception ex) {
                ApexPages.addMessages(ex);
                return null;
            } finally {
                if(submissionFlag)
                    incident.Status__c = 'Draft';
            }
            
            
            if(thisPage.Page__c == 'zInjury') {
                try {
                    upsertInjuries();
                } catch(Exception ex) {
                    ApexPages.addMessages(ex);
                    return null;
                }
            }
            
            if(thisPage.Page__c == 'zMiscellaneous' || thisPage.Page__c == 'zInvolvedPerson'){
                try {
                    upsertWitness();
                } catch(Exception ex) {
                    ApexPages.addMessages(ex);
                    return null;
                }
            }
            if(thisPage.Page__c == 'zMiscellaneous' || thisPage.Page__c == 'zInvestigationsActions'){
                try {
                    upsertActions();
                    upsertCorrectiveActions();
                } catch(Exception ex) {
                    ApexPages.addMessages(ex);
                    return null;
                }
                // LJ 03/07/2015: Check if all Corrective Actions are Closed or none were created
                List<Task> openActions = [SELECT Id FROM Task WHERE WhatId = :incident.Id AND Status <> 'Completed'];
                if(openActions.isEmpty()){
                    incident.All_Actions_Closed__c = true;
                    update incident;    
                }
            }
        }

        if(redirectURL != null && redirectURL != ''){
            pg = new PageReference(redirectURL);
            pg.getParameters().put('id', incident.Id);
            pg.setRedirect(true);
        } else {
            pg = new PageReference('/' + incident.Id);
            pg.setRedirect(true);
        }
        
        return pg;
    }
    private void upsertInjuries()
    {
        List<Injury__c> tempInjuryList = new List<Injury__c>();
        for(Injury__c i: Injuries) {
            if(i.Injury_Illness_Type__c != null){
                tempInjuryList.add(i);
            }
        }
        if(tempInjuryList.size() > 0)
            upsert tempInjuryList;
    }
    private void upsertWitness()
    {
        List<Incident_Witness__c> tempList = new List<Incident_Witness__c>();
        for(Incident_Witness__c i: Witnesses) {
            if(i.Witness_Type__c != null)
            {
                if(i.Witness_Type__c != 'Team Member') i.Contact__c = null;
                tempList.add(i);
            }
        }
        if(tempList.size() > 0)
            upsert tempList;
    }
    
    // Actions gets its own save method.
    public PageReference saveAllActions(){
        try {
            upsertActions();
        } catch(Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        getTasks();
        return null;
    }
    // Corrective Action Upsert Method
    public PageReference saveAllCorrectiveActions(){
        try{
            upsertCorrectiveActions();
        } catch(Exception ex){
            ApexPages.addMessages(Ex);
            return null;
        }
        getTasks();
        return null;
    }
    private void upsertCorrectiveActions(){
        List<Task> tempList = new List<Task>();
        for(clsTask i: CorrectiveTasks){
                Date ActivityDate;
                String subject;
            if(i.Action != ''){
                if(i.ActivityDate == '')
                    ActivityDate = null;
                else 
                    ActivityDate = Date.parse(i.ActivityDate);
                if(i.Subject == '' || i.Subject == null)
                    subject = i.Action;
                else
                    subject = i.Subject;
                    
                tempList.add(new Task(
                    Id = i.Id,
                    WhatId  = i.WhatId,
                    Type    = i.Type,
                    Subject = subject,
                    Status  = i.Status,
                    Action__c = i.Action, 
                    ActivityDate    = ActivityDate,
                    RecordTypeId    = i.RecordTypeId,
                    Job_Number__c   = i.JobNumber,
                    ownerId = i.selectedUser != null ? i.selectedUser : i.OwnerId
                    ));
            }
        }
        
        if(tempList.size() > 0){
            system.debug('**templist'+tempList);
            upsert tempList;
        }
    }
    private void upsertActions()
    {
        List<Task> tempList = new List<Task>();
        for(clsTask i: ActionTasks) {
            if(i.Action != '')
            {
                Date activityDate;
                Date dateCompleted;
                String subject;
                
                /*if(i.ActivityDate == '')
                    activityDate = null;
                else
                    activityDate = Date.parse(i.ActivityDate);
                    */
                if(i.DateCompleted == '')
                    dateCompleted = null;
                else 
                    dateCompleted = Date.parse(i.DateCompleted);
                    
                System.Debug('>>>>>>>> Subject: ' + i.Subject);
                if(i.Subject == '' || i.Subject == null)
                    subject = i.Action;
                else
                    subject = i.Subject;
                    
                tempList.add(new Task(
                    Id = i.Id,
                    WhatId  = i.WhatId,
                    Type    = i.Type,
                    Subject = subject,
                    Status  = i.Status,
                    Action__c = i.Action, 
                    Date_Action_Completed__c = dateCompleted,
                    ActivityDate    = null,
                    RecordTypeId    = i.RecordTypeId,
                    Job_Number__c   = i.JobNumber,
                    ownerId = i.selectedUser != null ? i.selectedUser : i.OwnerId,
                    Completed_By__c = i.CompletedBy // Map Completed By Field
                    ));
            }
        }
        if(tempList.size() > 0){
            system.debug('**templist'+tempList);
            upsert tempList;
        }
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
    
    // Site dictates the brand of Coles which in turn drives all the picklist values shown on the UI
    // So any time the site changes, reflect the right record type to drive the UI
    public void setIncidentRecordType(){
        Schema.DescribeSObjectResult d = Schema.SObjectType.Incident__c; 
        System.Debug('>>>>>>>>>>>>>>>>>>>>' + d);
        Map<String,Schema.RecordTypeInfo> IncidentRecordTypes = d.getRecordTypeInfosByName();
        System.Debug('>>>>>>>>>>>>>>>>>>>>' + IncidentRecordTypes);
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
    // Called whenever the risk selection is made on Miscellaneous page.
    public void setRiskSeverity(){
       incident.Risk_Rating__c = System.currentPagereference().getParameters().get('RiskSeverity');
    }
    // Return all the Agency classifiers to display in the UI
    @RemoteAction
    global static List<Dependent_List_Master__c> getAllCauses(){
        return [SELECT ID, Name, Level_1__c, Level_2__c, Level_3__c
                FROM Dependent_List_Master__c
                WHERE Object__c = 'Incident__c' AND Field__c = 'Agency' AND Active__c = true
                ORDER BY Level_1__c, Level_2__c, Level_3__c];
    } 
    
    // Return all the Mechanism classifiers to display in the UI
    @RemoteAction
    global static List<Dependent_List_Master__c> getAllMechanisms(){
        return [SELECT ID, Name, Level_1__c, Level_2__c
                FROM Dependent_List_Master__c
                WHERE Object__c = 'Incident__c' AND Field__c = 'Mechanism' AND Active__c = true
                ORDER BY Level_1__c, Level_2__c];
    }   
    
    // ---- Getter Methods -----
    public Boolean isAmbulance
    { 
        get { 
            if(incident.Type_of_Emergency_Service__c != null)
                return(incident.Type_of_Emergency_Service__c.contains('Ambulance'));
            else return false;
        } 
    }
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
        get { return (incident.Injured_Party_Type__c != 'Team Member' && incident.Injured_Party_Type__c != null && incident.Injured_Party_Type__c != 'Person(s) Unknown'); } 
    }
      
    public Boolean isMinor{ 
        get {  
            // Basically the logic needs to check either Age Group OR Date of Birth to determine if the Person is under the age of 16.
            // If they are display the Minor Details field set. 
            // Note that in the case of a Team Member Date of Birth is stored against the associated Contact record, otherwise it is stored in the Incident.
            //Date BirthDate = null;
            //String AgeGroup = null;
            String AgeGroupDescriptive = null;
            Boolean retValue = false;
            /*
            if(incident.Injured_Party_Type__c == 'Team Member' && incident.Team_Member_Not_Known__c == false && incident.Injured_Party__c != null){
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
            }*/
            AgeGroupDescriptive = incident.Age_Group_Descriptive__c; //LJ Replaces the prior 2 values for all new incidents
            
            // Check if age group or date of birth is specified
            // LJ Modified to use AgeGroupDescriptive by Default
            if(AgeGroupDescriptive != null){
                retValue = (AgeGroupDescriptive == 'Infant' || AgeGroupDescriptive == 'Toddler' || AgeGroupDescriptive == 'Child' || AgeGroupDescriptive == 'Teenager');
            }
            /*
            else if(BirthDate != null){
                date todaysDate = date.today();
                Long Diff = BirthDate.daysBetween(todaysDate);

                retValue = (Math.floor(diff/365.2425) < CONS_MINORAGE);
            }
            else if(AgeGroup != null){
                retValue = (AgeGroup == '<16');
            }
            */
            
            return retValue;
        }
    }
    // Injury page to list and save injuries    
    private void getInjuries(){
        Injuries = [SELECT ID, Name, Primary__c, Incident__c, Injury_Illness_Type__c, Bodily_Location__c, Injury_Illness_Details__c, Position__c, Team_Member__c
                    FROM Injury__c
                    WHERE Incident__c =: incident.Id];
                    
        // Minimum 3 empty rows, if there is data then there should be at least one empty row.
        integer emptyRows = CONS_INJURY_EMPTYROWS - Injuries.size();
        if(emptyRows <= 0) emptyRows = 1;

        while(emptyRows > 0){
            addNewInjury();
            emptyRows--;
        }
    }
    public void addNewInjury() { Injuries.add(new Injury__c(Incident__c = incident.Id, Team_Member__c = incident.Injured_Party__c)); }
    
    // Witnesses
    private void getWitness(){
        Witnesses = [SELECT ID, Name, Incident__c, Contact__c, 
                            Witness_Email__c, Witness_Name__c, Witness_Phone_No__c, Witness_Type__c
                    FROM Incident_Witness__c
                    WHERE Incident__c =: incident.Id];
                    
        // Minimum 3 empty rows, if there is data then there should be at least one empty row.
        integer emptyRows = CONS_WITNESS_EMPTYROWS - Witnesses.size();
        if(emptyRows <= 0) emptyRows = 1;

        while(emptyRows > 0){
            addNewWitnessRow();
            emptyRows--;
        }
    }
    public void addNewWitnessRow() { Witnesses.add(new Incident_Witness__c(Incident__c = incident.Id)); }
    
    // Immediate Action Tasks
    private void getTasks(){
        ActionTasks = new List<clsTask>();
        Id recTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= 'Immediate_Action' LIMIT 1].Id;
        for(Task t : [SELECT ID, Type, Subject, ActivityDate,Completed_By__c,Date_Action_Completed__c, Status, Description, Action__c, WhatId, RecordTypeId, Job_Number__c, Owner.Name, OwnerId
                    FROM Task
                    WHERE WhatId =: incident.Id AND RecordTypeId = :recTypeId]){
            ActionTasks.add(new clsTask(t));
        }
        integer emptyRows = CONS_EMPTYROWS - ActionTasks.size();
        if(emptyRows <= 0) emptyRows = 1;

        while(emptyRows > 0){
            addNewActionRow();
            emptyRows--;
        }
        
        CorrectiveTasks = new List<clsTask>();
        recTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= 'Corrective_Action' LIMIT 1].Id;
        for(Task t : [SELECT ID, Type, Subject,Completed_By__c,ActivityDate, Status,  Date_Action_Completed__c, Description, Action__c, WhatId, RecordTypeId, Job_Number__c, Owner.Name, OwnerId
                    FROM Task
                    WHERE WhatId =: incident.Id AND RecordTypeId = :recTypeId]){
            CorrectiveTasks.add(new clsTask(t));
        }
        emptyRows = CONS_EMPTYROWS - CorrectiveTasks.size();
        if(emptyRows <= 0) emptyRows = 1;

        while(emptyRows > 0){
            addNewCorrectiveActionRow();
            emptyRows--;
        }
    }
    public void addNewActionRow() { ActionTasks.add(new clsTask(incident.Id, 'Immediate_Action', 'Completed')); }
    public void addNewCorrectiveActionRow() { CorrectiveTasks.add(new clsTask(incident.Id, 'Corrective_Action', 'Not Started')); }
    // On a Force.com Site the Task object is not exposed so creating a wrapper class to contain the Task
    // Ref: http://salesforce.stackexchange.com/questions/30727/viewing-and-inserting-a-task-from-force-com-site
    public class clsTask{
        public Id Id                    {get; set;}
        public String Type              {get; set;}
        public String Subject           {get; set;}
        public String ActivityDate      {get; set;}
        public String DateCompleted     {get; set;}
        public String Status            {get; set;}
        public Id WhatId                {get; set;}
        public Id RecordTypeId          {get; set;}
        public String JobNumber         {get; set;}
        public String OwnerName         {get; set;}
        public String OwnerId           {get; set;}
        public String Action            {get; set;}
        public String Comments          {get; set;}
        // Instance fields
        public String searchTerm        {get; set;}
        public String selectedUser      {get; set;}
        // New Completed By Field 
        public String CompletedBy       {get; set;}
        
        // Called when querying for tasks
        public clsTask(Task t){
            this.Id          = t.Id;
            this.WhatId      = t.WhatId;
            this.Type        = t.Type;
            this.Subject     = t.Subject;
            this.Status      = t.Status;
            if(t.ActivityDate != null)
                this.ActivityDate = t.ActivityDate.format();
            if(t.Date_Action_Completed__c != null)    
                this.DateCompleted = t.Date_Action_Completed__c.format();
            this.RecordTypeId = t.RecordTypeId;
            this.JobNumber    = t.Job_Number__c;
            this.OwnerName    = t.Owner.Name;
            this.OwnerId      = t.OwnerId;
            if(t.Action__c == '')
                this.Action = t.Subject;
            else
                this.Action       = t.Action__c;
            this.Comments     = t.Description;
            this.searchTerm   = t.Owner.Name;  //Initialized search term as Owner Name 
            this.selectedUser = t.OwnerId;    //Initialized selectedUser as OwnerId
            this.CompletedBy  = t.Completed_By__c; // Map Completed By Field
        }
        
        // Called when creating new tasks
        public clsTask(Id incidentId, String recType, String status){
            RecordType rt = [SELECT Name, Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= :recType LIMIT 1];
            Incident__c i = [SELECT Account__r.Site_Manager__r.User__c, Account__r.Site_Manager__r.User__r.Name,Account__r.Site_Manager__r.user__r.isactive, Account__r.Caretaking_Store_Manager__r.user__c,Account__r.Caretaking_Store_Manager__r.User__r.Name,Account__r.Caretaking_Store_Manager__r.user__r.isactive FROM Incident__c WHERE ID =: incidentId];
            this.WhatId      = incidentId;
            this.Type        = '';
            this.Subject     = '';
            this.Status      = status;
            //this.ActivityDate = Date.Today().format();
            this.DateCompleted = null;
            this.ActivityDate = '';
            this.RecordTypeId = rt.Id;
            this.Action = '';
            if((i.Account__r.Site_Manager__r.User__c != null)&&(i.Account__r.Site_Manager__r.user__r.isactive==True)) {
                this.OwnerId   = i.Account__r.Site_Manager__r.User__c;
                this.OwnerName = i.Account__r.Site_Manager__r.User__r.Name;
            } 
            
        
            else if((i.Account__r.Caretaking_Store_Manager__r.User__c != null)&&(i.Account__r.Caretaking_Store_Manager__r.user__r.isactive==True)) {
                this.OwnerId   = i.Account__r.Caretaking_Store_Manager__r.User__c;
                this.OwnerName = i.Account__r.Caretaking_Store_Manager__r.User__r.Name;
            } 
            else
            {
                this.OwnerId   = UserInfo.getUserId();
                this.OwnerName = UserInfo.getName();
            }
            this.selectedUser = this.OwnerId;
            this.searchTerm = this.OwnerName;
            /*if(selectedUser != null){
            this.OwnerId = selectedUser;
            this.OwnerName = searchTerm;
            }*/
        }
    }
    // Action Item Types is a drop down on the front end so getting the values from the object
    public List<SelectOption> getActionItemTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        Schema.DescribeSObjectResult objDescribe = Task.sObjectType.getDescribe();       
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> values = fieldMap.get('Type').getDescribe().getPickListValues();
        List<Task_Dependent_Picklist_Values__c> typeVals = [SELECT Name FROM Task_Dependent_Picklist_Values__c WHERE Field_Name__c = 'Type' and Record_Type__c = 'Immediate_Action'];
        Set<String> valsLookup = new Set<String>();
        for (Task_Dependent_Picklist_Values__c v : typeVals)
            valsLookup.add(v.Name); 
        for (Schema.PicklistEntry a : values) {
            if(valsLookup.contains(a.getLabel())) {
                options.add(new SelectOption(a.getLabel(), a.getValue())); 
            }
        }
        return options;
    }
    
    public List<SelectOption> getQuickCodes() {
        List<SelectOption> qcOptions = new List<SelectOption>();
        qcOptions.add(new SelectOption('', '--None--'));
        List<Quick_Codes__c> qcList = [SELECT Name, Description__c, Agency__c, Mechanism__c FROM Quick_Codes__c ORDER BY Description__c];
        for (Quick_Codes__c qc: qcList) {
            qcOptions.add(new SelectOption(qc.Name, qc.Description__c)); 
        }
        return qcOptions;
    }
    
    public PageReference setValuesFromCode() {
        System.Debug('>>>>>>>> Setting Codes, Quick Code value selected is: ' + quickCode);
        if(quickCode != null) {
            Quick_Codes__c qc = [SELECT Agency__c, Mechanism__c FROM Quick_Codes__c WHERE Name = :quickCode LIMIT 1];
            Try{
                Dependent_List_Master__c agency = [SELECT Level_1__c, Level_2__c FROM Dependent_List_Master__c WHERE Level_3__c = :qc.Agency__c LIMIT 1];
                Dependent_List_Master__c mechanism = [SELECT Level_1__c FROM Dependent_List_Master__c WHERE Level_2__c = :qc.Mechanism__c LIMIT 1];
                incident.Agency_Level_1__c = agency.Level_1__c;
                incident.Agency_Level_2__c = agency.Level_2__c;
                incident.Agency_Level_3__c = qc.Agency__c;
                incident.Mechanism_Level_1__c = mechanism.Level_1__c;
                incident.Mechanism_Level_2__c = qc.Mechanism__c;
            }
            Catch(Exception e)
            {
                ApexPages.Message codingMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to resolve Agency or Mechanism for selected Quick Code, please contact Administrator');
                ApexPages.addMessage(codingMsg);
                return null;
            }
        }
        return null;
    }
    
    // Action Item Types is a drop down on the front end so getting the values from the object
    public List<SelectOption> getActionItemStatuses() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '-- None --'));
        Schema.DescribeSObjectResult objDescribe = Task.sObjectType.getDescribe();       
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap(); 
        List<Schema.PicklistEntry> values = fieldMap.get('Status').getDescribe().getPickListValues();
        List<Task_Dependent_Picklist_Values__c> statusVals = [SELECT Name FROM Task_Dependent_Picklist_Values__c WHERE Field_Name__c = 'Status' and Record_Type__c = 'Immediate_Action'];
        Set<String> valsLookup = new Set<String>();
        for (Task_Dependent_Picklist_Values__c v : statusVals)
            valsLookup.add(v.Name); 
        for (Schema.PicklistEntry a : values) {
            if(valsLookup.contains(a.getLabel())) {
                options.add(new SelectOption(a.getLabel(), a.getValue())); 
            }
        }
        
        return options;
    }
    // Returns a dynamic SOQL statement for the whole object, includes only creatable fields since we will be inserting a cloned result of this query
    // Ref - http://appexchange.salesforce.com/listingDetail?listingId=a0N30000004cbbDEAQ
    public static string getCreatableFieldsSOQL(String objectName, String whereClause){
         
        String selects = '';
         
        if (whereClause == null || whereClause == ''){ return null; }
         
        // Get a map of field name and field token
        Map<String, Schema.SObjectField> fMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        list<string> selectFields = new list<string>();
         
        if (fMap != null){
            for (Schema.SObjectField ft : fMap.values()){ // loop through all field tokens (ft)
                Schema.DescribeFieldResult fd = ft.getDescribe(); // describe each field (fd)
                if (fd.isCreateable()){ // field is creatable
                    selectFields.add(fd.getName());
                }
            }
        }
         
        if (!selectFields.isEmpty()){
            for (string s:selectFields){
                selects += s + ',';
            }
            if (selects.endsWith(',')){selects = selects.substring(0,selects.lastIndexOf(','));}
             
        }
         
        return 'SELECT ' + selects + ' FROM ' + objectName + ' WHERE ' + whereClause;
         
    }
    
    //Create Method to return list of task 
    public list<task> gettasklist(){
        list<task> tasklist = [select id,ownerId,subject from Task limit 50];
        system.debug('**tasklist'+tasklist);
        return tasklist;
    } 
    
     public string eventType {get;set;}   // Contains Value for Radio Box Selected;
     
     public PageReference navigate(){
         PageReference pageNav = new PageReference(Page.zIncidentSummary.getUrl() + '?selection=' + incident.Incident_Type_List__c);
         if(incident.Incident_Type_List__c ==null)
             return null;
         if(incident.Incident_Type_List__c == 'Regulator Management')
             pageNav = new PageReference('/apex/zRegulatoryManagement');    // Modified Page Reference to Point to Custom VF Page instead of Standard Layout
         pageNav.setRedirect(true);
         return pageNav;
     }
      // JS Remoting action called when searching for a User to Assign Task
    @RemoteAction
    global static List<User> searchUser(String searchTerm) {
        List<User> userRecords = Database.query('Select Id, Name from User where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' and IsActive=true');
        return userRecords;
    }
    // Method to return Hours from Incident Time
    public integer fetchHour(string incidentTime){
        
        String [] incidentTimeArray = incidentTime.split(':');
        System.debug('***TimeArray: ' + incidentTimeArray);
        integer hourVal = 0;
        if(incidentTimeArray[0] == '12'){
            incidentTimeArray[0] = '0';
            hourVal=0;
        }
        if(incidentTimeArray[1].Contains('PM')){
            hourVal = Integer.ValueOf(incidentTimeArray[0]) + 12;
        }
        else{
            hourVal = Integer.ValueOf(incidentTimeArray[0]);
        }
         System.debug('***hourVal'+hourVal);
         return hourVal;
    }
   // Method to return Hour from IncidentTime
   public integer fetchMinute( string incidentTime){
        String [] incidentTimeArray = incidentTime.split(':');
        Integer minutesVal = Integer.valueOf(incidentTimeArray[1].Substring(0,2));
        System.debug('***minutes'+minutesVal);
       return minutesVal;
   }
  // Method to fetch time
  public String fetchTime(Time timeValue){
     string timeVal;
     string incidentTime = string.valueOf(timeValue);
     string [] incidentTimeArray = incidentTime.split(':');
     if(Integer.ValueOf(incidentTimeArray[0]) == 12){
          timeVal = string.ValueOf(Integer.ValueOf(incidentTimeArray[0])) + ':'+ incidentTimeArray[1].substring(0,2) + ' PM';
     }
     else if(Integer.ValueOf(incidentTimeArray[0]) > 12 ){
         timeVal = string.ValueOf(Integer.ValueOf(incidentTimeArray[0]) - 12) + ':'+ incidentTimeArray[1].substring(0,2) + ' PM';
     }
     else if( Integer.ValueOf(incidentTimeArray[0]) == 0){
         timeVal = '12'+':'+incidentTimeArray[1].substring(0,2)+' AM';
     }
     else{
         timeVal = string.ValueOf(Integer.ValueOf(incidentTimeArray[0])) + ':'+ incidentTimeArray[1].substring(0,2) + ' AM';
     }
     return timeVal;
  }
  public void resetOtherIncidentCompleted(){
      if(incident.Pages_Complete__c != null && incident.Pages_Complete__c != ''){
          System.Debug('>>>>>>>>>>>> ' + incident.Pages_Complete__c);
          incident.Pages_Complete__c = incident.Pages_Complete__c.remove('zOtherIncident');
          System.Debug('>>>>>>>>>>>> ' + incident.Pages_Complete__c);
      }
  }
}