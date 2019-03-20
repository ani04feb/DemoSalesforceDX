global class scheduledHRSharingRecalc implements Schedulable {
   global void execute(SchedulableContext sc) {
      HRSharingRecalc b = new HRSharingRecalc(); 
      database.executebatch(b);
   }
}