@isTest
private class NotificationNotLogintest
{
    static testMethod void notificationfor45days()
    {
           
        test.startTest();
            NotificationNotLogin45days b = new NotificationNotLogin45days();
            database.executebatch(b);
        test.stopTest();
        
    }   
    static testMethod void notificationfor60days()
    {
           
        test.startTest();
            NotificationNotLogin60days b = new NotificationNotLogin60days();
            database.executebatch(b);
        test.stopTest();
        
    } 
    static testMethod void notificationfor90days()
    {
           
        test.startTest();
            NotificationNotLogin90days b = new NotificationNotLogin90days();
            database.executebatch(b);
        test.stopTest();
        
    } 
    static testMethod void notificationfor120days()
    {
           
        test.startTest();
            NotificationNotLogin120days b = new NotificationNotLogin120days();
            database.executebatch(b);
        test.stopTest();
        
    }                   
  }