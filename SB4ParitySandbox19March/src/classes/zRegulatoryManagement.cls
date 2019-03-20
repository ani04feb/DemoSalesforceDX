global class zRegulatoryManagement {

    public zRegulatoryManagement(ApexPages.StandardController controller) {

    }


    public String regulatorTime { get; set; }

    public String Regulator { get; set; }
    /*-------------------------------------------------------------
    Author:        Rohit Kumar, Lok Jackson
    Company:       Salesforce.com
    Description:   Controller Class for Maintaining Regulatory Management Class
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    private static final integer CONS_EMPTYROWS = 3;
    
    public Regulator_Management__c regulatory       {get; set;}
    public list<clsTask> CorrectiveTasks            {get; set;} // Corrective Actions
    public list<clsTask> ImmediateTasks             {get; set;} // Immediate Actions
    public static id accId                          {get; set;}
    public zRegulatoryManagement(){
        
        regulatory =  new Regulator_Management__c();
        getTasks(); // Initiate Task Method 
    }
    /**
     *  Method required to redefine Constructor for Corrective Task to default Assigned To based on location value
     */
    public void reInforceCorrectiveAction(){
        system.debug('**re'+regulatory.location__c);
        accId = regulatory.location__c;
        CorrectiveTasks.clear();
        //CorrectiveTasks = new List<clsTask>();
        addNewCorrectiveActionRow();
        
    }
    /** 
     *  Method to handle save of records
     * This would insert parent object and then if its succesful would handle insertion for associated Task
     */
    public pageReference save(){
        
         PageReference pageNav; 
        try{ 
            
            if(ImmediateTasks[0].Action==null || ImmediateTasks[0].Action=='' || ImmediateTasks[0].DateCompleted==''){
                ApexPages.Message actionMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter at least 1 Immediate Action');
                ApexPages.addMessage(actionMsg);
                return null;
            }
            
            system.debug('***H'+regulatory);
            upsert regulatory;
            addShares();
            createCorrectiveTask(regulatory.id,CorrectiveTasks);
            createImmediateTask(regulatory.id,ImmediateTasks);
            pageNav = new PageReference('/apex/zRegulatoryManagementSubmission');
            pageNav.setRedirect(true);
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
        
        return pageNav;
    }
   public void createImmediateTask(Id regulatoryId,list<clsTask> ImmediateTaskList){
       
       Id recTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= 'Immediate_Action' LIMIT 1].Id;
       createTask(regulatoryId,recTypeId,'Immediate',ImmediateTaskList);
   }  
   public void createCorrectiveTask(Id regulatoryId,list<clsTask> CorrectiveTaskList){
       
       Id recTypeId = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= 'Corrective_Action' LIMIT 1].Id;
       createTask(regulatoryId,recTypeId,'Corrective',CorrectiveTaskList);
       
   }
   public void addShares(){
       List<Regulator_Management__Share> rmShrs  = new List<Regulator_Management__Share>();
       Regulator_Management__Share rmShr;
       Regulator_Management__c rm = [SELECT Site_Manager__c,Site_Manager__r.User__c, Site_Assistant_Manager__r.User__c, Regional_Manager__r.User__c FROM Regulator_Management__c WHERE Id = :regulatory.Id LIMIT 1];
       System.debug('**reg'+rm.Site_Manager__c);
       if(rm.Site_Manager__r.User__c != null){
           rmShr = new Regulator_Management__Share();
           rmShr.ParentId = rm.Id;
           rmShr.UserOrGroupId = rm.Site_Manager__r.User__c;
           rmShr.AccessLevel = 'Edit';
           rmShr.RowCause = Schema.Regulator_Management__Share.RowCause.Site_Manager__c;
           rmShrs.add(rmShr);
       }
       if(rm.Site_Assistant_Manager__r.User__c != null){
           rmShr = new Regulator_Management__Share();
           rmShr.ParentId = rm.Id;
           rmShr.UserOrGroupId = rm.Site_Assistant_Manager__r.User__c;
           rmShr.AccessLevel = 'Edit';
           rmShr.RowCause = Schema.Regulator_Management__Share.RowCause.Site_Assistant_Manager__c;
           rmShrs.add(rmShr); 
       }
       // If we don't have a Site Manager or Assistant Site Manager to share with, share with Regional Manager
       if(rm.Regional_Manager__r.User__c != null){
           rmShr = new Regulator_Management__Share();
           rmShr.ParentId = rm.Id;
           rmShr.UserOrGroupId = rm.Regional_Manager__r.User__c;
           rmShr.AccessLevel = 'Edit';
           rmShr.RowCause = Schema.Regulator_Management__Share.RowCause.Regional_Manager__c;
           rmShrs.add(rmShr);
       }
       if(rmShrs.size() > 0)
           insert rmShrs;
   }
  /**
   * Method to create Task
   */
   public void createTask(id regulatoryId,id recTypeId,String recName,list<clsTask> taskList){
     
     Regulator_Management__c rm = [Select Location__r.Site_Manager__r.User__c,Id from Regulator_Management__c where Id = : regulatory.Id ];  
     Id ownerId = rm.Location__r.Site_Manager__r.User__c;
     if(ownerId == null)
         ownerId = UserInfo.getUserId();
     List<Task> tempList = new List<Task>();
     System.debug('***task'+taskList);
        for(clsTask i: taskList) {
            if(i.Action != '')      // This is the default value on the Type picklist
            {   
                if(recName == 'Corrective' && i.Status == null)
                    i.Status = 'Not Started';
                tempList.add(new Task(
                    WhatId             = regulatoryId,
                    Type               = i.Type,
                    Subject            = i.Action,
                    Status             = recName == 'Corrective' ?i.Status:'Completed',
                    Action__c          = i.Action,
                    ActivityDate       = recName == 'Corrective'? Date.parse(i.ActivityDate): null,
                    Date_Action_Completed__c  = recName == 'Immediate'? Date.parse(i.DateCompleted): null,
                    RecordTypeId       = recTypeId,
                    Job_Number__c      = i.JobNumber,
                    OwnerId            = recName == 'Immediate'?ownerId:i.selectedUser,
                    Completed_By__c    = i.CompletedBy));
            }
        }
        if(tempList.size() > 0)
            insert tempList;
   }
  /**
   *  Cancel method to redirect to first page
   */
  public pageReference cancel(){
      pageReference pageNav = new PageReference('/apex/zIncidentSelection');
      return pageNav;
  }
  /**
   *  Methods to manage Corrective Task
   */
    private void getTasks(){
        CorrectiveTasks = new List<clsTask>();
        ImmediateTasks   = new List<clsTask>();
        addNewCorrectiveActionRow();
        addImmediateCorrectiveActionRow();
        
    }
    /**
     * Methods to manage Immediate Tasks
     */ 
    public void addImmediateCorrectiveActionRow(){
        ImmediateTasks.add(new clsTask());
    }
    public void addNewCorrectiveActionRow() { 
        system.debug('CorrectiveTasks=='+CorrectiveTasks);
        accId = regulatory.location__c;
        CorrectiveTasks.add(new clsTask()); 
        system.debug('**action'+CorrectiveTasks.size());
        //return null;
    }
        // On a Force.com Site the Task object is not exposed so creating a wrapper class to contain the Task
    // Ref: http://salesforce.stackexchange.com/questions/30727/viewing-and-inserting-a-task-from-force-com-site
    public class clsTask{ 
        public String Type              {get; set;}
        public String Subject           {get; set;}
        public String ActivityDate      {get; set;}
        public string DateCompleted     {get; set;}
        public String Status            {get; set;}
        public String JobNumber         {get; set;}
        public String OwnerName         {get; set;}
        public String Action            {get; set;}
        public String Comments          {get; set;}
        // Instance fields
        public String searchTerm        {get; set;}
        public String selectedUser      {get; set;}
        // New field to mark Completed By
        public String CompletedBy       {get;set;}
        //  Blank Constructor
        public clsTask(){
            System.debug('**act'+accId);
            //accId = regulatory.location__c;
            if(accId  != null){
                list<Account> acc = [select Site_Manager__c,Site_Manager__r.User__r.Name,Site_Manager_Id__c from Account where Id = : accId ];
                if(acc.size() > 0 ){
                    if(acc[0].Site_Manager__c != null && acc[0].Site_Manager_Id__c != null){
                    searchTerm = acc[0].Site_Manager__r.User__r.Name ;
                    selectedUser = acc[0].Site_Manager_Id__c;
                    System.debug('**act'+selectedUser+'**'+acc[0].Site_Manager_Id__c);
                 }
                
                }
                
            }
            //DateCompleted = System.now().format();
            //ActivityDate = Date.today().format();
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
       // JS Remoting action called when searching for a User to Assign Task
    @RemoteAction
    global static List<User> searchUser(String searchTerm) {
        List<User> userRecords = Database.query('Select Id, Name from User where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\' and IsActive=true');
        return userRecords;
    }
}