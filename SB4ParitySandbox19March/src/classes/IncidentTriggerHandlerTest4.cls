@isTest
private class IncidentTriggerHandlerTest4
{
    private static testMethod void testFieldDefaults() 
    {
        Account acc1 = new Account(Name='Test1', Brand__c='Liquorland');
        insert acc1;
        System.debug('@@@@@@@@@@@@@@@@@@@'+acc1);
        Contact c1 = new Contact(LastName = 'test1', Email = 'test1@test.com', AccountId = acc1.Id, User__c = [SELECT Id FROM User WHERE IsActive = true LIMIT 1].Id);
        insert c1;
        System.debug('@@@@@@@@@@@@@@@@@@@'+c1);
        Contact c2 = new Contact(LastName = 'test2', Email = 'test2@test.com', AccountId = acc1.Id, User__c = [SELECT Id FROM User WHERE IsActive = true order by name desc LIMIT 1].Id);
        insert c2;
        System.debug('@@@@@@@@@@@@@@@@@@@'+c2);
        acc1.Duty_Manager__c = c1.Id;
        acc1.Caretaking_Duty_Manager__c = c2.Id;
        update acc1;
        Incident__c incident1 = new Incident__c(Account__c=acc1.Id, Date_of_Birth__c = date.newinstance((date.today().year() - 18), 1, 1), Hazard__c=true,Age_Group__c='16-24');
        insert incident1;
        System.debug('@@@@@@@@@@@@@@@@@@@'+incident1);
        System.AssertEquals('16-24', [select Age_Group__c from Incident__c where Id = :incident1.Id].Age_Group__c);
        incident1.Date_of_Birth__c = date.newinstance((date.today().year() - 16), 1, 1);
        update incident1;
        //System.AssertEquals('<16', [select Age_Group__c from Incident__c where Id = :incident1.Id].Age_Group__c);
        incident1.Date_of_Birth__c = date.newinstance((date.today().year() - 30), 1, 1);
        update incident1;
        //System.AssertEquals('25-34', [select Age_Group__c from Incident__c where Id = :incident1.Id].Age_Group__c);
        incident1.Date_of_Birth__c = date.newinstance((date.today().year() - 40), 1, 1);
        update incident1;
        //System.AssertEquals('35-44', [select Age_Group__c from Incident__c where Id = :incident1.Id].Age_Group__c);
        incident1.Date_of_Birth__c = date.newinstance((date.today().year() - 70), 1, 1);
        update incident1;
        //System.AssertEquals('65+', [select Age_Group__c from Incident__c where Id = :incident1.Id].Age_Group__c);
        
        //Test initial shares
       testShare(incident1.Id, c1, c2);
        
        //Swap site manager and site assistant manager and test shares again
        Account acc2 = new Account(Name='Test2', Brand__c='Liquorland', Duty_Manager__c=c2.Id, Caretaking_Duty_Manager__c=c1.Id);
        insert acc2;
        
        incident1.Account__c = acc2.Id;
        update incident1;
        
        //Test new shares
        testShare(incident1.Id, c2, c1); //Order of contacts is reversed
        
        c1.User__c = null;
        update c1;
        c2.User__c = null;
        update c2;
        incident1.Account__c = acc1.Id;
        update incident1;
    }
    
    //Check shares
    private static void testShare(Id incidentId, Contact smContact, Contact samContact) {
        List<Incident__Share> incidentShares = [SELECT AccessLevel,Id,ParentId,RowCause,UserOrGroupId FROM Incident__Share where ParentId = :incidentId];
        System.debug('@@@@@@@@@@@@@@@@@@@'+incidentShares);
        //System.assertEquals(1, incidentShares.size()); //One owner share and 2 Apex shares
        Incident__Share smIncidentShare;
        Incident__Share samIncidentShare;
       /*
        for (Incident__Share shr : incidentShares) {
          if (shr.RowCause == Schema.Incident__Share.RowCause.Duty_Manager__c) {
            smIncidentShare = shr;
          } else if (shr.RowCause == Schema.Incident__Share.RowCause.Caretaking_Duty_Manager__c) {
            samIncidentShare = shr;
          }
        }*/
       // System.assert(smIncidentShare != null);
       // System.assert(samIncidentShare != null);

      //  System.assertEquals('Edit', smIncidentShare.AccessLevel);
       // System.assertEquals('Edit', samIncidentShare.AccessLevel);
       // System.assertEquals(smContact.User__c, smIncidentShare.UserOrGroupId);
       //System.assertEquals(samContact.User__c, samIncidentShare.UserOrGroupId);
    }
}