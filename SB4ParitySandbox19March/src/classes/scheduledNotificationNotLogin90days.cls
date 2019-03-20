global class scheduledNotificationNotLogin90days implements Schedulable {
   global void execute(SchedulableContext sc) {
      NotificationNotLogin90days b = new NotificationNotLogin90days(); 
      database.executebatch(b);
   }
}