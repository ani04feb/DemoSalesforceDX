trigger ComplaintTriggerHandler on Complainant__c (before insert, before update) {
    Set<Id> conIds = new Set<Id>();
    for(Complainant__c c :Trigger.New) {
        if(c.Contact__c!=null)
            conIds.Add(c.Contact__c);
    }
    if(conIds.size()>0) {
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Gender__c FROM Contact WHERE Id IN :conIds]);
        for(Complainant__c cUpdate :Trigger.New) {
            cUpdate.Gender__c = conMap.get(cUpdate.Contact__c).Gender__c;
        }
    }
}