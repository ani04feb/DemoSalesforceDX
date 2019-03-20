trigger SignedContracts on Attachment (after insert) {

    Set<id> Account_IdSet = new Set<id>();
    
    for(Attachment att : trigger.new){
        if((att.name.contains('Coles Brand Terms and Conditions'))&&((att.name.contains('SIGNED'))||(att.name.contains('Signed'))||(att.name.contains('signed'))))
        {
            Account_IdSet.add(att.ParentId);
        }
    }
    system.debug('@@@@@AccountIds'+Account_IdSet);
    
    List<Contract__c> ContractList = new List<Contract__c>();

    for( Contract__c co :[Select id ,Signed_CB_T_Cs__c  from Contract__c where Account__c IN : Account_IdSet]){
        co.Signed_CB_T_Cs__c=true;
        ContractList .add(co);
    }

    if(ContractList.size()>0){
        try{
            database.update(ContractList);
        }
        catch(DMLException e){
            system.debug(e);
        }
    }
}