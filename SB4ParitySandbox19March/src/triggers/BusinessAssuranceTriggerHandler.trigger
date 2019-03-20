trigger BusinessAssuranceTriggerHandler on Business_Assurance__c (before update) {
    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> ownerIdSet = new Set<Id>();
        List<Business_Assurance__c> baUpdateList = new List<Business_Assurance__c>();
        //Need to check if there has been a change to the Owner before firing the logic
        for(Business_Assurance__c ba: trigger.new){
            if(ba.Status__c == 'Closed Pending Review' && trigger.oldMap.get(ba.Id).Status__c != 'Closed Pending Review'){
                ownerIdSet.add(ba.OwnerId);
                baUpdateList.add(ba);
            }
        }
        List<Contact> linkedConList = [SELECT User__r.Id, ReportsTo.Email FROM Contact WHERE User__c IN :ownerIdSet];
        Map<Id, String> conMap = new Map<Id, String>();
        for(Contact c: linkedConList){
            conMap.put(c.User__r.Id, c.ReportsTo.Email);
        }
        for(Business_Assurance__c ba: baUpdateList){
            ba.Manager_Email__c = conMap.get(ba.OwnerId);
        }
    }
}