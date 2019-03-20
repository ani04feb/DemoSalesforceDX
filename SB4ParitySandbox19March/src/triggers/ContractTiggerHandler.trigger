trigger ContractTiggerHandler on Contract__c(before update,after update) {
    Set<Id> ownerIdSet = new Set<Id>();
    Set<Id> BCmId=new Set<Id>();
    List<Contract__c> iUpdateList = new List<Contract__c>();
    if(trigger.isUpdate && trigger.isBefore )
        {

                    //Need to check if there has been a change to the Owner before firing the logic
                    for(Contract__c i: trigger.new){
                        if(i.OwnerId!=null){
                            ownerIdSet.add(i.OwnerId);
                            iUpdateList.add(i);
                        }
                    }
                    List<Contact> linkedConList = [SELECT User__r.Id, ReportsTo.id FROM Contact WHERE User__c IN :ownerIdSet];
                    Map<Id, string> conMap = new Map<Id, string>();
                    for(Contact c: linkedConList){
                        conMap.put(c.User__r.Id, c.ReportsTo.id);
                        BCmId.add(c.ReportsTo.id);
                    }
                    for(Contract__c i: iUpdateList){
                        i.Business_Category_Manager__c = conMap.get(i.OwnerId);
                    }
                    List<Contact> linkedConList2 = [SELECT Id, ReportsTo.id FROM Contact WHERE id IN :BCmId];
                    Map<Id, Id> bcmMapgm= new Map<Id, Id>();
                    for(Contact c: linkedConList2){
                        bcmMapgm.put(c.Id, c.ReportsTo.id);
                    }
                    for(Contract__c i: iUpdateList){
                        i.General_Manager__c = bcmMapgm.get(i.Business_Category_Manager__c);
                    }
            
        }

  


}