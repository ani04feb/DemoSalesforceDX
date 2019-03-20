@isTest
private class InvestigationSharingRecalcBatchTest4 {

    static testmethod void test() {
        Account acc1 = new Account(Name='Test1', Brand__c='Supermarkets');
        insert acc1;
        System.debug('First Account>>>>>>>>>>>>>>>>>'+acc1);
        User u1 = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Contact c1 = new Contact(LastName = 'test1', Email = 'test1@test.com', AccountId = acc1.Id, User__c = u1.Id);
        insert c1;
        System.debug('First Contact>>>>>>>>>>>>>>>>>'+c1);
        User u2 = [SELECT Id FROM User WHERE IsActive = true order by name desc LIMIT 1];
        Contact c2 = new Contact(LastName = 'Site Assistant Mgr', Email = 'test2@test.com', AccountId = acc1.Id, User__c = u2.Id);
        insert c2;
        System.debug('Second Contact>>>>>>>>>>>>>>>>>'+c1);
        acc1.Trading_Manager_Nights__c = c1.Id;
        acc1.Dry_Goods_Manager__c = c2.Id;
        update acc1;
        
        Incident__c incident1 = new Incident__c(Account__c=acc1.Id, Hazard__c=true);
        insert incident1;
        System.debug('First Incident>>>>>>>>>>>>>>>>>'+incident1);
        Investigation__c Investigation1 = new Investigation__c(Investigation_Lead__c=c1.Id, Incident__c=incident1.Id);
        insert Investigation1;
        
        //testShare(Investigation1.Id, c1, c2);
        
        Investigation__c Investigation2 = new Investigation__c(Investigation_Lead__c=c2.Id, Incident__c=incident1.Id);
        insert Investigation2;
        
        //testShare(Investigation2.Id, c2, null);
        
        
        //Change account1's site manager and site assistant manager, recalc and then test shares
        acc1.Trading_Manager_Nights__c = c2.Id;
        acc1.Dry_Goods_Manager__c = c1.Id;
        update acc1;
        
        Test.startTest();
        InvestigationSharingRecalc r = new InvestigationSharingRecalc();
        Database.executeBatch(r);
        Test.stopTest();
        
        //testShare(Investigation1.Id, c2, c1);
        
    }

    //Check shares
    private static void testShare(Id InvestigationId, Contact smContact, Contact samContact) {
      Integer numShares = 1;
        List<Investigation__Share> InvestigationShares = [SELECT AccessLevel,Id,ParentId,RowCause,UserOrGroupId FROM Investigation__Share where ParentId = :InvestigationId];
        Investigation__Share smInvestigationShare;
        Investigation__Share samInvestigationShare;
        
        for (Investigation__Share shr : InvestigationShares) {
          if (shr.RowCause == Schema.Investigation__Share.RowCause.Safety_Users_Supermarket__c) {
            smInvestigationShare = shr;
            samInvestigationShare=shr;
        }
        if (smContact != null) {
          numShares++;
          System.assert(smInvestigationShare != null);
          System.assertEquals('Edit', smInvestigationShare.AccessLevel);
          System.assertEquals(smContact.User__c, smInvestigationShare.UserOrGroupId);
        }

        if (samContact != null) {
          numShares++;
          System.assert(samInvestigationShare != null);
          System.assertEquals('Edit', samInvestigationShare.AccessLevel);
          System.assertEquals(samContact.User__c, samInvestigationShare.UserOrGroupId);
        }
        System.assertEquals(numShares, InvestigationShares.size()); //One owner share + upto 2 more Apex shares
    }
}
}