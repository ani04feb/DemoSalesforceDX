trigger RegulatorManagementTriggerHandler on Regulator_Management__c (before update, before insert) {

    if(Trigger.IsBefore)
    {   
        Set<ID> accntIds = new Set<ID>();
        for(Regulator_Management__c rm : Trigger.New) { // loop through new records to get Account Id
            accntIds.add(rm.Location__c);
        }
        Map<Id, Account> accntMap = new Map<Id, Account>([SELECT Id, Site_Manager__c, Site_Assistant_Manager__c, Regional_Manager__c, Recipient_1__c, Recipient_2__c, Recipient_3__c, Recipient_4__c, Recipient_5__c, Recipient_6__c, Recipient_7__c, Recipient_8__c, Recipient_9__c, Recipient_10__c FROM Account WHERE Id IN :accntIds]);
        for(Regulator_Management__c r: Trigger.New)
        {
            if(Trigger.IsUpdate)
            {
                if(r.Location__c != Trigger.OldMap.get(r.Id).Location__c)
                {
                    r.Site_Manager__c = accntMap.get(r.Location__c).Site_Manager__c;
                    r.Site_Assistant_Manager__c = accntMap.get(r.Location__c).Site_Assistant_Manager__c;
                    r.Regional_Manager__c = accntMap.get(r.Location__c).Regional_Manager__c;
                    r.Recipient_1__c = accntMap.get(r.Location__c).Recipient_1__c;
                    r.Recipient_2__c = accntMap.get(r.Location__c).Recipient_2__c;
                    r.Recipient_3__c = accntMap.get(r.Location__c).Recipient_3__c;
                    r.Recipient_4__c = accntMap.get(r.Location__c).Recipient_4__c;
                    r.Recipient_5__c = accntMap.get(r.Location__c).Recipient_5__c;
                    r.Recipient_6__c = accntMap.get(r.Location__c).Recipient_6__c;
                    r.Recipient_7__c = accntMap.get(r.Location__c).Recipient_7__c;
                    r.Recipient_8__c = accntMap.get(r.Location__c).Recipient_8__c;
                    r.Recipient_9__c = accntMap.get(r.Location__c).Recipient_9__c;
                    r.Recipient_10__c = accntMap.get(r.Location__c).Recipient_10__c;
                }                
            }
            else
            {
                r.Site_Manager__c = accntMap.get(r.Location__c).Site_Manager__c;
                r.Site_Assistant_Manager__c = accntMap.get(r.Location__c).Site_Assistant_Manager__c;
                r.Regional_Manager__c = accntMap.get(r.Location__c).Regional_Manager__c;
                r.Recipient_1__c = accntMap.get(r.Location__c).Recipient_1__c;
                r.Recipient_2__c = accntMap.get(r.Location__c).Recipient_2__c;
                r.Recipient_3__c = accntMap.get(r.Location__c).Recipient_3__c;
                r.Recipient_4__c = accntMap.get(r.Location__c).Recipient_4__c;
                r.Recipient_5__c = accntMap.get(r.Location__c).Recipient_5__c;
                r.Recipient_6__c = accntMap.get(r.Location__c).Recipient_6__c;
                r.Recipient_7__c = accntMap.get(r.Location__c).Recipient_7__c;
                r.Recipient_8__c = accntMap.get(r.Location__c).Recipient_8__c;
                r.Recipient_9__c = accntMap.get(r.Location__c).Recipient_9__c;
                r.Recipient_10__c = accntMap.get(r.Location__c).Recipient_10__c;
            }
        }
    }


    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> ownerIdSet = new Set<Id>();
        List<Regulator_Management__c> rmUpdateList = new List<Regulator_Management__c>();
        //Need to check if there has been a change to the Owner before firing the logic
        for(Regulator_Management__c rm: trigger.new){
            if(rm.Status__c == 'Closed Pending Review' && trigger.oldMap.get(rm.Id).Status__c != 'Closed Pending Review'){
                ownerIdSet.add(rm.OwnerId);
                rmUpdateList.add(rm);
            }
        }
        List<Contact> linkedConList = [SELECT User__r.Id, ReportsTo.Email FROM Contact WHERE User__c IN :ownerIdSet];
        Map<Id, String> conMap = new Map<Id, String>();
        for(Contact c: linkedConList){
            conMap.put(c.User__r.Id, c.ReportsTo.Email);
        }
        for(Regulator_Management__c rm: rmUpdateList){
            rm.Manager_Email__c = conMap.get(rm.OwnerId);
        }
    }
}