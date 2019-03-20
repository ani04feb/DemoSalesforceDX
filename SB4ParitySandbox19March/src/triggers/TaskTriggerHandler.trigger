trigger TaskTriggerHandler on Task (after update) {
    if(Trigger.IsAfter && Trigger.IsUpdate){
        Id correctiveActionId = [SELECT Id FROM RecordType WHERE SobjectType='Task' AND DeveloperName= 'Corrective_Action' LIMIT 1].Id;
        Set<Id> parentRecordIds = new Set<Id>();
        for(Task t: Trigger.New){
            if(t.RecordTypeId == correctiveActionId && t.Status == 'Completed'){
                parentRecordIds.add(t.WhatId);
            }
        }
        if(!parentRecordIds.isEmpty()){
            List<Task> openActions = [SELECT WhatId FROM Task WHERE WhatId IN :parentRecordIds AND RecordTypeId = :correctiveActionId AND Status <> 'Completed'];
            Set<Id> openParentIds = new Set<Id>();
            for(Task ot : openActions){
                openParentIds.add(ot.WhatId);
            }
            parentRecordIds.removeAll(openParentIds);
            if(!parentRecordIds.isEmpty()){
                String incPrefix = Schema.SObjectType.Incident__c.getKeyPrefix();
                String invPrefix = Schema.SObjectType.Investigation__c.getKeyPrefix();
                String busAssurancePrefix = Schema.SObjectType.Business_Assurance__c.getKeyPrefix();
                String regManPrefix = Schema.SObjectType.Regulator_Management__c.getKeyPrefix();
                String riskPrefix = Schema.SObjectType.Risk_Assessment__c.getKeyPrefix();
                Map<String,Set<Id>> objTypeRecMap = new Map<String,Set<Id>>();
                //List<Business_Assurance__c> busAssuranceList = new List<Business_Assurance__c>();
                for(Id wId : parentRecordIds){
                    String objPrefix = String.valueOf(wId).left(3);
                    Set<Id> tempSet = new Set<Id>();
                    if(objTypeRecMap.get(objPrefix)==null){
                        tempSet.add(wId);
                    }
                    else{ 
                        tempSet = objTypeRecMap.get(objPrefix);
                        tempSet.add(wId);
                    }
                    objTypeRecMap.put(objPrefix, tempSet);
                }
                if(objTypeRecMap.get(busAssurancePrefix)!=null){
                    List<Business_Assurance__c> baList = [SELECT Status__c FROM Business_Assurance__c WHERE Id IN :objTypeRecMap.get(busAssurancePrefix)];
                    for(Business_Assurance__c ba: baList){
                        ba.Status__c = 'Closed Pending Review';
                    }
                    update baList;
                }
                if(objTypeRecMap.get(incPrefix)!=null){
                    List<Incident__c> incList = [SELECT All_Actions_Closed__c FROM Incident__c WHERE Id IN :objTypeRecMap.get(incPrefix)];
                    for(Incident__c i: incList){
                        i.All_Actions_Closed__c = true;
                    }
                    update incList;
                }
                if(objTypeRecMap.get(riskPrefix)!=null){
                    List<Risk_Assessment__c> raList = [SELECT Status__c FROM Risk_Assessment__c WHERE Id IN :objTypeRecMap.get(riskPrefix)];
                    for(Risk_Assessment__c ra: raList){
                        ra.Status__c = 'Closed Pending Review';
                    }
                    update raList;
                }
                if(objTypeRecMap.get(regManPrefix)!=null){
                    List<Regulator_Management__c> rmList = [SELECT Status__c FROM Regulator_Management__c WHERE Id IN :objTypeRecMap.get(regManPrefix)];
                    for(Regulator_Management__c rm: rmList){
                        rm.Status__c = 'Closed Pending Review';
                    }
                    update rmList;
                }
                if(objTypeRecMap.get(invPrefix)!=null){
                    List<Investigation__c> invList = [SELECT Status__c FROM Investigation__c WHERE Id IN :objTypeRecMap.get(invPrefix)];
                    for(Investigation__c inv: invList){
                        inv.Status__c = 'Closed Pending Review';
                    }
                    update invList;
                }
            }
        }
    }
}