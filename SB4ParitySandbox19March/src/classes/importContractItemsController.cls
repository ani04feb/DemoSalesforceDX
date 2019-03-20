/**
* @author Jerry Huang
* @date 07/03/2016
*
*
* @description Controller for importContractItems page
* logic to upsert records read in from input excel file
*/
global with sharing class importContractItemsController {
    
   
    public importContractItemsController()
    {
     //constructor
            
    }
    
    /*******************************************************************************************************
    * @description updates or inserts Contract Items with given input values
    */
    
    @RemoteAction
    global static String upsertItem( 
         String sContractName,
         String sColesItemNumber,
         String sDescription ,
         String sNetCost ,
         String sGST ,
         String sVolume ,
         String sVolumeType ,
         String sArtworkCost ,
         String sArtworkSuppliedBy,
         String sIP,
         String sCertReq,
         String sExclRights,
         String sExclTerritory)
    {
        
        Contract__c cont ;
        // valid contract exists
        try{
            
            cont  = [Select Id from Contract__c where Name = :sContractName];
        }catch(Exception e)
        {
            return (sColesItemNumber + ': ERROR : ' + ' Contract "' + sContractName + '" not found!');
        }
        
        try{
            
            Contract_Item__c Item;
            String sAction = 'Insert';
            
            
          
           
            
            // search for item
            
            List<Contract_Item__c> MatchingItems = [SELECT Id from Contract_Item__c where Coles_Item_Number__c = :sColesItemNumber and Contract__c = :cont.Id];
            
            if (MatchingItems.size() > 1)
            {
                return (sContractName + ' : ' + sColesItemNumber + ': ERROR : ' + ' Multiple matching Coles Item Number! ');
            }
            else if (MatchingItems.size() == 1)
            {
                // upsert
                Item = MatchingItems[0];
                sAction = 'Update';
            }
            else
            {
                // insert
                Item = new Contract_Item__c();
                Item.Contract__c = cont.Id;
                
            }
            
            Item.Description_Size__c = sDescription;
            Item.Coles_Item_Number__c = sColesItemNumber;
            Item.Net_Cost__c = (String.isBlank(sNetCost) ? null : Decimal.valueOf(sNetCost));
            Item.GST__c = (sGST.equalsIgnoreCase('Y') ? true: false);
            Item.Volume_Units__c = (String.isBlank(sVolume) ? null : Integer.valueOf(sVolume));
            Item.Volume_Type__c =sVolumeType;
            Item.Artwork_Cost__c = (String.isBlank(sArtworkCost) ? null : Decimal.valueOf(sArtworkCost));
            Item.Artwork_Cost_Supplied_By__c= sArtworkSuppliedBy;
            Item.Intellectual_Proprety__c=(sIP.equalsIgnoreCase('Y')? true: false);
            Item.Certification_Requirement__c=(sCertReq.equalsIgnoreCase('Y')? true: false);
            Item.Exclusivity_Rights__c=(sExclRights.equalsIgnoreCase('Y')? true:false);
            Item.Exclusivity_Rights_Territory__c=sExclTerritory;
            
            
            upsert Item;
               
            
            return sContractName + ' : ' + sColesItemNumber + ' : ' + sAction + ' successful' ;
            
        }
        catch (Exception e)
        {
            System.debug(sContractName + ' : ' + sColesItemNumber + ': ERROR : '  + e.getMessage());
            return sContractName + ' : ' + sColesItemNumber + ': ERROR : ' + e.getMessage();
        }
    }//end upsertItem
    
    
    
    
    

}