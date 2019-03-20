/*-------------------------------------------------------------
Author:        Lok Jackson
Company:       Salesforce.com
Description:   Trigger to set Incident fields from Account and also 
               to invoke IncidentSharingCalc.insertShare to create
               incident sharing records. 
Inputs:        None
History
<Date>      <Authors Name>     <Brief Description of Change>
03-Apr-15   Shashidhar G.      1. Set Site Assistant Managers field on Incident from Account
            (Salesforce        2. Added code to delete old shares when Incident account is changed
             Services India)
05-Jul-15   Lok Jackson        Added logic to remove sharing from records that have been
                               hidden due to Legal Action and assign to current user
------------------------------------------------------------*/
trigger IncidentTriggerHandler on Incident__c (before update, before insert, after insert, after update) 
{
  // Only run if not the Migration User
  if(userinfo.getName() != 'Migration' && userinfo.getName() != null){
    if(Trigger.IsBefore)
    {   
        Set<ID> accntIds = new Set<ID>();
        for(Incident__c incident : Trigger.New) { // loop through new records to get Account Id
            accntIds.add(incident.Account__c);
        }
        Map<Id, Account> accntMap = new Map<Id, Account>([SELECT Id, Site_Manager__c, Site_Assistant_Manager__c, Regional_Manager__c, Recipient_1__c, Recipient_2__c, Recipient_3__c, Recipient_4__c, Recipient_5__c, Recipient_6__c, Recipient_7__c, Recipient_8__c, Recipient_9__c, Recipient_10__c FROM Account WHERE Id IN :accntIds]);
        for(Incident__c i: Trigger.New)
        {
            if(Trigger.IsUpdate)
            {
                // LJ 05/07/2015: If updated to Legal Action Required, Assign directly to Safety User who has updated the record
                if(Trigger.OldMap.get(i.Id).Is_Legal_Advice_Required__c != i.Is_Legal_Advice_Required__c && i.Is_Legal_Advice_Required__c == 'Yes'){
                    i.OwnerId = userInfo.getUserId();
                }
                if(i.Date_of_Birth__c != Trigger.OldMap.get(i.Id).Date_of_Birth__c)
                {
                    i.Age_Group__c = AgeRange.calculateAgeRange(i.Date_of_Birth__c, 'Incident__c');
                }
                if(i.Account__c != Trigger.OldMap.get(i.Id).Account__c)
                {
                    i.Site_Manager_Lookup__c = accntMap.get(i.Account__c).Site_Manager__c;
                    i.Site_Assistant_Manager__c = accntMap.get(i.Account__c).Site_Assistant_Manager__c;
                    i.Regional_Manager_Lookup__c = accntMap.get(i.Account__c).Regional_Manager__c;
                    i.Recipient_1__c = accntMap.get(i.Account__c).Recipient_1__c;
                    i.Recipient_2__c = accntMap.get(i.Account__c).Recipient_2__c;
                    i.Recipient_3__c = accntMap.get(i.Account__c).Recipient_3__c;
                    i.Recipient_4__c = accntMap.get(i.Account__c).Recipient_4__c;
                    i.Recipient_5__c = accntMap.get(i.Account__c).Recipient_5__c;
                    i.Recipient_6__c = accntMap.get(i.Account__c).Recipient_6__c;
                    i.Recipient_7__c = accntMap.get(i.Account__c).Recipient_7__c;
                    i.Recipient_8__c = accntMap.get(i.Account__c).Recipient_8__c;
                    i.Recipient_9__c = accntMap.get(i.Account__c).Recipient_9__c;
                    i.Recipient_10__c = accntMap.get(i.Account__c).Recipient_10__c;
                }                
            }
            else
            {
                if(i.Date_of_Birth__c != null)
                {
                    i.Age_Group__c = AgeRange.calculateAgeRange(i.Date_of_Birth__c, 'Incident__c');
                }
                i.Site_Manager_Lookup__c = accntMap.get(i.Account__c).Site_Manager__c;
                i.Site_Assistant_Manager__c = accntMap.get(i.Account__c).Site_Assistant_Manager__c;
                i.Regional_Manager_Lookup__c = accntMap.get(i.Account__c).Regional_Manager__c;
                i.Recipient_1__c = accntMap.get(i.Account__c).Recipient_1__c;
                i.Recipient_2__c = accntMap.get(i.Account__c).Recipient_2__c;
                i.Recipient_3__c = accntMap.get(i.Account__c).Recipient_3__c;
                i.Recipient_4__c = accntMap.get(i.Account__c).Recipient_4__c;
                i.Recipient_5__c = accntMap.get(i.Account__c).Recipient_5__c;
                i.Recipient_6__c = accntMap.get(i.Account__c).Recipient_6__c;
                i.Recipient_7__c = accntMap.get(i.Account__c).Recipient_7__c;
                i.Recipient_8__c = accntMap.get(i.Account__c).Recipient_8__c;
                i.Recipient_9__c = accntMap.get(i.Account__c).Recipient_9__c;
                i.Recipient_10__c = accntMap.get(i.Account__c).Recipient_10__c;
            }
        }
    }
    //Calculate Sharing if new record
    else if(Trigger.IsInsert && Trigger.IsAfter) 
    {
        IncidentSharingCalc.insertShare(Trigger.New, Trigger.NewMap);
    }
    else if(Trigger.IsUpdate && Trigger.IsAfter) 
    {
        List<Incident__c> iList = new List<Incident__c>();
        List<Id> updatedIncidentIDs = new List<Id>();
        
        for(Incident__c i : Trigger.New)
        {
            // LJ 05/07/2015: Added condition to cater for removing shares from Site Managers where Legal Advice Required has been set to 'Yes'
            if(Trigger.OldMap.get(i.Id).Account__c != i.Account__c || (Trigger.OldMap.get(i.Id).Is_Legal_Advice_Required__c != i.Is_Legal_Advice_Required__c && i.Is_Legal_Advice_Required__c == 'Yes'))
            {
                iList.add(i);
                updatedIncidentIDs.add(i.Id);
            }
        }
        
        if (iList.size() > 0)
        {
            IncidentSharingCalc.deleteOldShares(updatedIncidentIDs);
            IncidentSharingCalc.insertShare(iList, Trigger.NewMap);
        }
    }
  }
}