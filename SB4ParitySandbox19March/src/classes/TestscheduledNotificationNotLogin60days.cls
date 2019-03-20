@isTest
private class TestscheduledNotificationNotLogin60days {

   // CRON expression: midnight on May 12.
   // Because this is a test, job executes
   // immediately after Test.stopTest().
   public static String CRON_EXP = '0 0 0 12 5 ? 2024';

   static testmethod void test() {
      Test.startTest();

      // Schedule the test job
      String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new scheduledNotificationNotLogin60days());
         
      // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2024-05-12 00:00:00', 
         String.valueOf(ct.NextFireTime));
      
      // TODO: Insert code here Verify the scheduled job hasn't run yet.
      
      Test.stopTest();

      // TODO: Now that the scheduled job has executed after Test.stopTest(),
      // verify that the records have been updated as expected.
      

   }
}