global class scheduledtakeOffAdditionalLicBatch  implements Schedulable {
      global void execute(SchedulableContext sc) {
      takeOffAdditionalLicBatch b = new takeOffAdditionalLicBatch(); 
      database.executebatch(b);
   }
}