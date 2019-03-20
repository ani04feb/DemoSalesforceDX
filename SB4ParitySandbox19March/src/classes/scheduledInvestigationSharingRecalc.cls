global class scheduledInvestigationSharingRecalc implements Schedulable {
   global void execute(SchedulableContext sc) {
      InvestigationSharingRecalc b = new InvestigationSharingRecalc(); 
      database.executebatch(b);
   }
}