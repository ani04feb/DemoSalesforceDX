global class scheduledNotificationNotLogin60days implements Schedulable {
   global void execute(SchedulableContext sc) {
      NotificationNotLogin60days b = new NotificationNotLogin60days(); 
      database.executebatch(b);
   }
}