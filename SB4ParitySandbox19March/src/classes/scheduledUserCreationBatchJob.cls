global class scheduledUserCreationBatchJob implements Schedulable {
   global void execute(SchedulableContext sc) {
      UserCreationBatchJob b = new UserCreationBatchJob(); 
      database.executebatch(b);
   }
}