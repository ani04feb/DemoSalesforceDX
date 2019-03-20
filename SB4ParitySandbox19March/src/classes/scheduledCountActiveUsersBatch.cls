global class scheduledCountActiveUsersBatch implements Schedulable {
   global void execute(SchedulableContext sc) {
      CountActiveUsersBatch b = new CountActiveUsersBatch(); 
      database.executebatch(b);
   }
}