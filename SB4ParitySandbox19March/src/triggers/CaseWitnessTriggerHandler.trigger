trigger CaseWitnessTriggerHandler on Case_Witness__c (before insert, before update) {
    Set<Id> conIds = new Set<Id>();
    for(Case_Witness__c w :Trigger.New) {
        if(w.Contact__c!=null)
            conIds.Add(w.Contact__c);
    }
    if(conIds.size()>0) {
        Map<Id,Contact> conMap = new Map<Id,Contact>([SELECT Gender__c FROM Contact WHERE Id IN :conIds]);
        for(Case_Witness__c wUpdate :Trigger.New) {
            wUpdate.Gender__c = conMap.get(wUpdate.Contact__c).Gender__c;
        }
    }
}