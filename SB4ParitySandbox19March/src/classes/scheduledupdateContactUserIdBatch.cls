global class scheduledupdateContactUserIdBatch  implements Schedulable {
   global void execute(SchedulableContext sc) {
      updateContactUserIdBatch b = new updateContactUserIdBatch (); 
      database.executebatch(b);
   }
}