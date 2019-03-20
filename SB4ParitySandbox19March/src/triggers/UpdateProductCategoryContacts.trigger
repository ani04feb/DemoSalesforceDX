trigger UpdateProductCategoryContacts on Product_Category__c (after update) {

    set<Id> prodIds = new set<Id>();
    map<Id, Product_Category__c> mapProductCategory = new map<Id, Product_Category__c>();
    list<Contact> listContact = new list<Contact>();
    list<Contract__c> listContract = new list<Contract__c>();
    
    for(Product_Category__c prod : trigger.new) {
        prodIds.add(prod.Id);
        mapProductCategory.put(prod.Id, prod);
    }
    
    listContact = [SELECT OwnerID, Product_Category__c FROM Contact WHERE Product_Category__c IN : prodIds];
    
    if(listContact.size() > 0) {
        for(Contact con : listContact) {
            con.OwnerID = mapProductCategory.get(con.Product_Category__c).OwnerID;
        }
        update listContact;
    }
    
    listContract = [SELECT OwnerID, Primary_Category__c FROM Contract__c WHERE Primary_Category__c IN : prodIds];
    
    if(listContract.size() > 0) {
        for(Contract__c con : listContract) {
            con.OwnerID = mapProductCategory.get(con.Primary_Category__c).OwnerID;
        }
        update listContract;
    }
}