/**
* @author Jerry Huang
* @date 07/03/2016
*
*
* @description Controller for exportContractItems page
* logic to query Contract Items
*/

public class exportContractItemsController {
    
    public List<ExportItem> ExportItemList {get;set;}
    
    public class ExportItem{
        public String Contract_Name {get;set;}
        public String Coles_Item_Number {get;set;}
        public String Description_Size {get;set;}
        public String Net_Cost {get;set;}
        public String GST { get;set;}
        public String Volume_Units {get;set;}
        public String Volume_Type {get;set;}
        public String Artwork_Cost {get;set;}
        public String Artwork_Cost_Supplied_By {get;set;}
        public String Intellectual_Proprety {get;set;}
        public String Certification_Requirement {get;set;}
        public String Exclusivity_Rights {get;set;}
    public String Exclusivity_Rights_Territory {get;set;}
    }
    
    public Id ContractId {get;set;}
    
   /*******************************************************************************************************
    * @description constructor to query contract items for exporting
    */
    public exportContractItemsController()
    {
        ContractId = ApexPages.currentPage().getParameters().get('id');
        ExportItemList = new List<ExportItem>();
        for (Contract_Item__c item : [Select Contract__r.Name, Coles_Item_Number__c, Description_Size__c,Net_Cost__c, GST__c,Volume_Units__c,
                                      Volume_Type__c, Artwork_Cost__c, Artwork_Cost_Supplied_By__c,
                                      Intellectual_Proprety__c, Certification_Requirement__c,
                                      Exclusivity_Rights__c, Exclusivity_Rights_Territory__c
                                      from Contract_Item__c WHERE Contract__c = :ContractId])
        {
            
            ExportItem eItem = new ExportItem();
            eItem.Contract_Name = item.Contract__r.Name;
            eItem.Coles_Item_Number = item.Coles_Item_Number__c;
            eItem.Description_Size = item.Description_Size__c;
            eItem.Net_Cost = (item.Net_Cost__c > 0? item.Net_Cost__c.toPlainString(): '');
            
            eItem.GST = (item.GST__c ?'Y':'N');
            
            eItem.Volume_Units = (item.Volume_Units__c > 0 ? item.Volume_Units__c.toPlainString(): '');
            eItem.Volume_Type = item.Volume_Type__c;
            eItem.Artwork_Cost = (item.Artwork_Cost__c > 0 ? item.Artwork_Cost__c.toPlainString(): '');
            eItem.Artwork_Cost_Supplied_By = item.Artwork_Cost_Supplied_By__c;
            eItem.Intellectual_Proprety = (item.Intellectual_Proprety__c ?'Y':'N');
            eItem.Certification_Requirement = (item.Certification_Requirement__c ?'Y':'N');
            eItem.Exclusivity_Rights = (item.Exclusivity_Rights__c ?'Y':'N');
            eItem.Exclusivity_Rights_Territory = item.Exclusivity_Rights_Territory__c;
            
            ExportItemList.add(eItem);
        }
    }
    
    

}