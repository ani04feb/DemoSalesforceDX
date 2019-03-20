trigger AccountTriggerHandler on Account (before update) {
// Handler for all Account Trigger Logic
    for(Account a : trigger.new) {
        if(Trigger.isBefore && Trigger.isUpdate) {
            // Check whether Account Name has changed, and if so set Previous Site Name appropriately
            String oldName = trigger.oldMap.get(a.Id).Name;
            System.Debug('Old Name: ' + oldName + ', New Name: ' + a.Name);
            Boolean isTriggerCalled = TriggerUtilities.AccountBeforeTriggerCalled; // Use this to prevent recursive calls that can result from Workflow field updates
            System.Debug('Recursive Trigger Call: ' + isTriggerCalled);
            if(oldName != a.Name && !isTriggerCalled) {
                TriggerUtilities.setAccountBeforeTriggerCalled(); 
                String pastSites = a.Previous_Site_Names__c;
                if(pastSites == null){
                    a.Previous_Site_Names__c = oldName;
                }
                else {
                    pastSites = oldName + ',' + pastSites;
                    if(pastSites.length() < 256) {
                        a.Previous_Site_Names__c = pastSites;    
                    }
                    else {
                        while(pastSites.length() > 255)
                        {
                            if(pastSites.lastIndexOf(',') > 0) {
                                pastSites = pastSites.left(pastSites.lastIndexOf(','));
                            }
                            else {
                                pastSites = oldName;
                                break;
                            }
                        }
                        a.Previous_Site_Names__c = pastSites; 
                    }
                }
                System.Debug('Updated Value of Previous Site Names: ' + a.Previous_Site_Names__c);
            }
        }
    }
}