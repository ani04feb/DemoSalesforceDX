//This Trigger will fire after insert, update, delete and undelete
trigger trgConCatProductNamdandDescription on Contract_Item__c (after insert, after update, after delete, after undelete) {


List<Contract_Item__c> ContractItemslist = (Trigger.isInsert|| Trigger.isUnDelete) ? Trigger.new : Trigger.old;

//to store Contract Ids
List<Id> contrctectIds = new List<Id>();

//Loop through the Records to store the contrctect Id values from the Contract_Item__c
for (Contract_Item__c con_item : ContractItemslist) {
contrctectIds.add(con_item.Contract__c);
}

List<Contract__c> ContractList = [select id, (select id,Name , Description_Size__c from Contract_Line_Items__r)from Contract__c where id in :contrctectIds];

//Loop through the List and store the Child Records as a String of values in Long Text Area Field i.e Products_Contract_Item__c

for (Contract__c contrct : ContractList) {

if(contrct.Contract_Line_Items__r.size() > 0)
{
contrct.Products_Contract_Item__c = string.valueOf(contrct.Contract_Line_Items__r[0].Description_Size__c);

for(integer i=1;i < contrct.Contract_Line_Items__r.size();i++)
{
contrct.Products_Contract_Item__c = contrct.Products_Contract_Item__c + '; ' + string.valueOf(contrct.Contract_Line_Items__r[i].Description_Size__c);
}
}
else
contrct.Products_Contract_Item__c = null;

}

//update the List
update ContractList;


}