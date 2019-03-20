trigger ContractCategoryTriggerHandler on Contract_Category__c (before insert, before update, after delete, after insert, after update) {
  	List<Contract__c> contracts = new List<Contract__c>();

  	if(Trigger.isBefore) {
  		Map<ID, Contract__c> mapct = new Map<ID, Contract__c>(); 
  		List<Id> listctIds = new List<Id>();

  		for (Contract_Category__c cc : Trigger.new) {
    		listctIds.add(cc.Contract__c);
  		}
  		
  		mapct = new Map<Id, Contract__c>([SELECT Id, Primary_Category__c,(SELECT Id, Primary__c, Product_Category__c FROM Contract_Categories__r) FROM Contract__c WHERE Id IN :listctIds]);

  		for (Contract_Category__c cc : Trigger.new){
     		Contract__c parentct = mapct.get(cc.Contract__c);
     		if(cc.Primary__c == TRUE && parentct.Primary_Category__c != null && parentct.Primary_Category__c != cc.Product_Category__c) {
      			cc.AddError('A different category is already set as the Primary');
			}
  		}	
  	}
	else { //start of isAfter
  		if(!Trigger.IsDelete) {  
    		for(Contract_Category__c cc : Trigger.New) {
      			if(cc.Primary__c && ( Trigger.IsInsert || !Trigger.OldMap.get(cc.Id).Primary__c)) {
        			Contract__c ct = new Contract__c(Id=cc.Contract__c);
        			ct.Primary_Category__c = cc.Product_Category__c;
        			ct.Primary_Sub_Category__c = cc.Product_Sub_Category__c;
        			contracts.add(ct);
      			} else if(!cc.Primary__c && Trigger.IsUpdate && Trigger.OldMap.get(cc.Id).Primary__c) {        
          			Contract__c ct = new Contract__c(Id=cc.Contract__c);
          			ct.Primary_Category__c = null;
          			ct.Primary_Sub_Category__c = null;
          			contracts.add(ct);
      			}
    		}  
    
  		} else if(Trigger.IsDelete) {
    		for(Contract_Category__c cc : Trigger.Old) {
      			if(cc.Primary__c) {
        			Contract__c ct = new Contract__c(Id=cc.Contract__c);
        			ct.Primary_Category__c = null;
        			ct.Primary_Sub_Category__c = null;
        			contracts.add(ct);
      			}
    		}
  		}

  		update(contracts);
	}
}