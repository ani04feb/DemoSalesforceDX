/**
 *  @Modified By Rohit Kumar
 *  @Desc Generic Methods to Create Test Records for any object added
 *  @Date 5-jul-15
 */ 
public class TestUtil { 
 
  public static Project__c createProject(String name) {
    Project__c testProject = new Project__c(Name = name);
    insert testProject;
    return testProject;
  }
  
  public static Work_Product__c createWorkProduct(String name, Id projectId) {
    Work_Product__c testWorkProduct = 
      new Work_Product__c(Name = name, Project__c = projectId);
      
    insert testWorkProduct;
    return testWorkProduct;
  }
  
  public static Iteration__c createIteration(
    String name, Id projectId, String state, Date startDate, Date endDate) {
    
    Iteration__c testIteration = new Iteration__c(
      Name          = name, 
      Project__c    = projectId, 
      State__c      = state, 
      Start_Date__c = startDate, 
      End_Date__c   = endDate);
    
    insert testIteration;
    return testIteration;
  }
  
  public static Iteration__c createIteration(
    String name, Id projectId, String state, Date startDate, Date endDate, Double taskEstimate, Double loaded, Double accepted) {
    
    Iteration__c testIteration = new Iteration__c(
      Name             = name, 
      Project__c       = projectId, 
      State__c         = state, 
      Start_Date__c    = startDate, 
      End_Date__c      = endDate,
      Task_Estimate__c = taskEstimate,
      Accepted__c      = accepted,
      To_Do__c         = loaded);
    
    insert testIteration;
    return testIteration;
  }  
  
  public static SS_Release__c createRelease(String name, Id projectId, Integer toDo, Integer accepted) {
    SS_Release__c testRelease = new SS_Release__c(
      Name = name, Project__c = projectId, To_Do__c = toDo, Accepted__c = accepted);
    insert testRelease;
    return testRelease;
  }
  
  public static RecordType getRecordType(String name, String type) {
    return [SELECT Id FROM RecordType WHERE Name = :name AND SobjectType = :type];
  }
     /**
      * Generic method to insert sobject records.
      * @author Rohit Kumar
      */
    public static List<SObject> createRecords( List<SObject> records, Boolean doInsert, Map<String, Object> attributes ){
        Integer i = 0;
        if( attributes != null ){
            for ( Integer j =0; j < records.size(); j ++ ) {
              Sobject record = records[j];
              for (String key : attributes.keySet()) {
                Object value = attributes.get(key);
                if (value instanceof List<Object>) {
                  object obj =  ((List<Object>) value).get(i);
                  if( obj instanceof Sobject ){
                    Id sObjectId = ((SObject) obj).Id;
                    record.put( key,sObjectId );
                  }
                  else {
                    record.put(key,obj);
                  }
                } else {
                  record.put(key, value);
                }
              }
              i++;
            }
        }
        if (doInsert) {
          insert records;
        }
        return records;
    }
    
    /**
     * Create sobjects
     * Inserts sobject in all scenario for bulk testing.
     *
     * @author Rohit (Salesforce)
     */
    public static List<sobject> createSobject( Integer numToInsert, Boolean doInsert, Map<String, Object> nameValueMap , String sobjType){
        List<Sobject> objList = new List<sobject>();
        for( Integer i=0; i< numToInsert; i++ ){
          Sobject obj = Schema.getGlobalDescribe().get(sobjType).newSObject();
          objList.add( obj );
        }
        return createRecords( objList, doInsert, nameValueMap );
    }
   /** 
    *  Create User
    *  @author Rohit (Salesforce)
    */
    public static User CreatetestConnectionUser(Id profileId)
    { 
      string timestamp = string.ValueOf(System.now());
      timestamp = timestamp.substring(timestamp.length() -2 ,timestamp.length());
        User oUser = new User();
        oUser.Alias = 'Coles';
        oUser.Email = 'coles@colesTest.com';
        oUser.EmployeeNumber = '12345678';
        oUser.External_ID__c = '12345678';
        oUser.FirstName = 'Connection';
        oUser.LastName = 'User';
        oUser.ProfileId = profileId;
        oUser.TimeZoneSidKey = 'America/Los_Angeles';
        oUser.Username = 'Coles'+timestamp+'@colesTest.com';
        oUser.LocaleSidKey = 'en_US';
        oUser.LanguageLocaleKey = 'en_US';
        oUser.EmailEncodingKey = 'ISO-8859-1';
      return oUser;
    }
 
}