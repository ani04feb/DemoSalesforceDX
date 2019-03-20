trigger RiskAssessmentTriggerHandler on Risk_Assessment__c (before update) {
    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> ownerIdSet = new Set<Id>();
        List<Risk_Assessment__c> raUpdateList = new List<Risk_Assessment__c>();
        //Need to check if there has been a change to the Owner before firing the logic
        for(Risk_Assessment__c ra: trigger.new){
            if(ra.Status__c == 'Closed Pending Review' && trigger.oldMap.get(ra.Id).Status__c != 'Closed Pending Review'){
                ownerIdSet.add(ra.OwnerId);
                raUpdateList.add(ra);
            }
        }
        List<Contact> linkedConList = [SELECT User__r.Id, ReportsTo.Email FROM Contact WHERE User__c IN :ownerIdSet];
        Map<Id, String> conMap = new Map<Id, String>();
        for(Contact c: linkedConList){
            conMap.put(c.User__r.Id, c.ReportsTo.Email);
        }
        for(Risk_Assessment__c ra: raUpdateList){
            ra.Manager_Email__c = conMap.get(ra.OwnerId);
        }
    }
}