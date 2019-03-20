global class scheduledIncidentSharingRecalc implements Schedulable {
   global void execute(SchedulableContext sc) {
      IncidentSharingRecalc b = new IncidentSharingRecalc(); 
      database.executebatch(b);
   }
}