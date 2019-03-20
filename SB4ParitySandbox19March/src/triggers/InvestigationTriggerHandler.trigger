trigger InvestigationTriggerHandler on Investigation__c (before update) {
    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> ownerIdSet = new Set<Id>();
        List<Investigation__c> iUpdateList = new List<Investigation__c>();
        //Need to check if there has been a change to the Owner before firing the logic
        for(Investigation__c i: trigger.new){
            if(i.Status__c == 'Closed Pending Review' && trigger.oldMap.get(i.Id).Status__c != 'Closed Pending Review'){
                ownerIdSet.add(i.OwnerId);
                iUpdateList.add(i);
            }
        }
        List<Contact> linkedConList = [SELECT User__r.Id, ReportsTo.Email FROM Contact WHERE User__c IN :ownerIdSet];
        Map<Id, String> conMap = new Map<Id, String>();
        for(Contact c: linkedConList){
            conMap.put(c.User__r.Id, c.ReportsTo.Email);
        }
        for(Investigation__c i: iUpdateList){
            i.Manager_Email__c = conMap.get(i.OwnerId);
        }
    }
}