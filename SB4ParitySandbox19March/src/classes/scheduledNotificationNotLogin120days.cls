global class scheduledNotificationNotLogin120days implements Schedulable {
   global void execute(SchedulableContext sc) {
      NotificationNotLogin120days b = new NotificationNotLogin120days(); 
      database.executebatch(b);
   }
}