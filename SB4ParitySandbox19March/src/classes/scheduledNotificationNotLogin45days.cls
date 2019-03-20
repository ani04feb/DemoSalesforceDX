global class scheduledNotificationNotLogin45days implements Schedulable {
   global void execute(SchedulableContext sc) {
      NotificationNotLogin45days b = new NotificationNotLogin45days(); 
      database.executebatch(b);
   }
}