trigger HRCaseTriggerHandler on Case__c (before update, before insert, after update, after insert) 
{
    Set<Id> AccountIds = new Set<Id>();
    List<Case__c> CaseAccModList = new List<Case__c>();
    Set<Id> ContactIds = new Set<Id>();
    List<Case__c> CaseConModList = new List<Case__c>();
    Set<Id> caseTypeIds = new Set<Id>();
    List<Case__c> caseTypeModList = new List<Case__c>();
    List<Case__c> caseShareList = new List<Case__c>();
    Blob cryptoKey;
    Boolean beforeTriggerCalled = false;
    
    if(!Test.IsRunningTest())
        cryptoKey = EncodingUtil.base64decode([SELECT Key_Value__c FROM Keystore__c WHERE Name='Case Notes'].Key_Value__c);
    for(Case__c c: Trigger.New)
    {
        if(Trigger.IsUpdate && Trigger.IsBefore)
        {
            if(c.Last_Activity__c != Trigger.OldMap.get(c.Id).Last_Activity__c && cryptoKey != null && !TriggerUtilities.HRBeforeTriggerCalled) // avoid running multiple times in same context
            {
                String rawNotes = null;
                if(c.Case_Notes__c!=null) {
                    rawNotes = (Crypto.decryptWithManagedIV('AES256', cryptoKey, EncodingUtil.base64decode(c.Case_Notes__c))).toString();
                    rawNotes = Datetime.now().format() + ', ' + UserInfo.getName() + '<br/>' + c.Last_Activity__c + '<br/><br/>' + rawNotes;
                }
                else {
                    rawNotes = Datetime.now().format() + ', ' + UserInfo.getName() + '<br/>' + c.Last_Activity__c;
                }
                Blob encryptedNotesValue = Crypto.encryptWithManagedIV('AES256', cryptoKey, Blob.valueOf(rawNotes));
                c.Case_Notes__c = EncodingUtil.base64encode(encryptedNotesValue);
            }
            if(c.Caller_Date_of_Birth__c != Trigger.OldMap.get(c.Id).Caller_Date_of_Birth__c)
            {
                if(c.Caller_Date_of_Birth__c == null)
                    c.Caller_Age_Range__c = null;
                else
                    c.Caller_Age_Range__c = AgeRange.calculateAgeRange(c.Caller_Date_of_Birth__c, 'Case__c');
            }
            if(c.Date_of_Birth__c != Trigger.OldMap.get(c.Id).Date_of_Birth__c)
            {
                if(c.Date_of_Birth__c == null)
                    c.Age_Range__c = null;
                else
                    c.Age_Range__c = AgeRange.calculateAgeRange(c.Date_of_Birth__c, 'Case__c');
            }
            if(c.Site__c != Trigger.OldMap.get(c.Id).Site__c || c.Account__c != Trigger.OldMap.get(c.Id).Account__c)
            {
                AccountIds.add(c.Site__c);
                AccountIds.add(c.Account__c);
                CaseAccModList.add(c);
            }
            if(c.Contact__c != Trigger.OldMap.get(c.Id).Contact__c || c.Caller__c != Trigger.OldMap.get(c.Id).Caller__c || c.Reporting_Department__c != Trigger.OldMap.get(c.Id).Reporting_Department__c)
            {
                ContactIds.add(c.Contact__c);
                ContactIds.add(c.Caller__c);
                CaseConModList.add(c);
            }
            if(c.Case_Type_3__c != Trigger.OldMap.get(c.Id).Case_Type_3__c)
            {
                caseTypeIds.add(c.Case_Type_3__c);
                caseTypeModList.add(c);
            }
        }
        else if(Trigger.IsInsert && Trigger.IsBefore)
        {
            if(c.Caller_Date_of_Birth__c != null)
            {
                c.Caller_Age_Range__c = AgeRange.calculateAgeRange(c.Caller_Date_of_Birth__c, 'Case__c');
            }
            AccountIds.add(c.Site__c);
            AccountIds.add(c.Account__c);
            CaseAccModList.add(c);
            ContactIds.add(c.Contact__c);
            ContactIds.add(c.Caller__c);
            CaseConModList.add(c);
            caseTypeIds.add(c.Case_Type_3__c);
            caseTypeModList.add(c);
        }
        else if(Trigger.IsInsert && Trigger.IsAfter || (Trigger.IsUpdate && Trigger.IsAfter && (c.Contact__c != Trigger.OldMap.get(c.Id).Contact__c || c.Reporting_Department__c != Trigger.OldMap.get(c.Id).Reporting_Department__c)))
        {
            ContactIds.add(c.Contact__c);
            caseShareList.add(c);
        }
    }
    if(CaseAccModList.size() > 0)
    {
        Map<Id, Account> acctMap = new Map<Id, Account>([Select Id, Brand__c, Sub_Brand__c, Above_Store__c From Account Where Id In :AccountIds]);
        
        for(Case__c cl: CaseAccModList)
        {
            if(Trigger.IsInsert)
            {
                // If not above store, automatically set Team Member Brand (otherwise user will set manually)
                if(cl.Account__c != null && !acctMap.get(cl.Account__c).Above_Store__c) 
                    cl.Brand__c = acctMap.get(cl.Account__c).Brand__c;
                
                // If not above store, automatically set Caller Brand (otherwise user will set manually)
                if(cl.Site__c != null && !acctMap.get(cl.Site__c).Above_Store__c) 
                    cl.Caller_Brand__c = acctMap.get(cl.Site__c).Brand__c;
            }
            else
            {
                // If Update and Team Member Site has changed
                if(cl.Account__c != Trigger.OldMap.get(cl.Id).Account__c)
                {
                    // If Site hasn't been cleared
                    if(cl.Account__c != null)
                    {
                        // If not above store set Brand based on the new Site
                        if(!acctMap.get(cl.Account__c).Above_Store__c) 
                        {
                            cl.Brand__c = acctMap.get(cl.Account__c).Brand__c;
                            cl.Reporting_Department__c = null; // blank out Reporting Department as only relevant to Above store
                        }
                    }
                    // Blank out fields if Account field has been cleared
                    else
                    {
                        cl.Brand__c = null;
                        cl.Reporting_Department__c = null;
                    }
                }
                // If Update and Caller Site has changed
                if(cl.Site__c != Trigger.OldMap.get(cl.Id).Site__c)
                {
                    // If Site hasn't been cleared
                    if(cl.Site__c != null)
                    { 
                        // If not above store set Brand based on the new Site
                        if(!acctMap.get(cl.Site__c).Above_Store__c)
                        {
                            cl.Caller_Brand__c = acctMap.get(cl.Site__c).Brand__c;
                            cl.Caller_Reporting_Department__c = null; // blank out Reporting Department as only relevant to Above store
                        }
                    }
                    // Blank out fields if Account field has been cleared
                    else
                    {
                        cl.Caller_Brand__c = null;
                        cl.Caller_Reporting_Department__c = null;
                    }
                }
            }
        }    
    }
    if(CaseConModList.size() > 0)
    {
        Map<Id, Contact> conMap = new Map<Id, Contact>([Select Id, Above_Store__c, Gender__c, AccountId From Contact Where Id In :ContactIds]);
        List<Contact> conAccounts = conMap.values();
        Set<Id> conAccountIds = new Set<Id>();
        for(Contact conAcct: conAccounts)
        {
            conAccountIds.Add(conAcct.AccountId);
        }
        ID anonAccntId;
        Try{
            anonAccntId = [SELECT Id FROM Account WHERE Name = 'Anonymous Account' LIMIT 1].Id;
        }
        Catch (Exception e) {
            anonAccntId = null;
        }
        // Retrieve Notification Recipients based on Team Member's Site
        Map<Id, Account> siteNotificationMap = NotificationUtilities.GetSiteNotifications(conAccountIds);
        Map<String, Department__c> departmentNotificationMap = NotificationUtilities.GetDepartmentNotifications(conAccountIds);
        Map<Id, Contact> contactEmailMap = NotificationUtilities.GetNotificationRecipients(siteNotificationMap.values(), departmentNotificationMap.values());

        for(Case__c caseCon: CaseConModList)
        {
            if(Trigger.IsInsert)
            {
                NotificationUtilities.setNotificationRecipents(caseCon, conMap, siteNotificationMap, departmentNotificationMap, contactEmailMap);
                if(caseCon.Contact__c != null) 
                    caseCon.Gender__c = conMap.get(caseCon.Contact__c).Gender__c;
                if(caseCon.Caller__c != null) 
                caseCon.Caller_Gender__c = conMap.get(caseCon.Caller__c).Gender__c;     
            }
            
            if(Trigger.IsUpdate && caseCon.Contact__c != Trigger.OldMap.get(caseCon.Id).Contact__c)
            {
                NotificationUtilities.setNotificationRecipents(caseCon, conMap, siteNotificationMap, departmentNotificationMap, contactEmailMap);
                if(caseCon.Contact__c != null) 
                    caseCon.Gender__c = conMap.get(caseCon.Contact__c).Gender__c;
                else
                    caseCon.Gender__c = null;
                if(caseCon.Account__c == null)
                    caseCon.Account__c = conMap.get(caseCon.Contact__c).AccountId;
            }
            else if(Trigger.IsUpdate && caseCon.Reporting_Department__c != Trigger.OldMap.get(caseCon.Id).Reporting_Department__c && caseCon.Contact__c != null)
            {
                if(conMap.get(caseCon.Contact__c).Above_Store__c)
                {
                    NotificationUtilities.setNotificationRecipents(caseCon, conMap, siteNotificationMap, departmentNotificationMap, contactEmailMap);
                }
            }
            
            if(Trigger.IsUpdate && caseCon.Caller__c != Trigger.OldMap.get(caseCon.Id).Caller__c)
            {
                if(caseCon.Caller__c != null) 
                    caseCon.Caller_Gender__c = conMap.get(caseCon.Caller__c).Gender__c;
                else 
                    caseCon.Caller_Gender__c = null;
                if(caseCon.Site__c == null || caseCon.Site__c == anonAccntId)
                    caseCon.Site__c = conMap.get(caseCon.Caller__c).AccountId;
            }
        }    
    }
    if(caseTypeModList.size() > 0)
    {
        Map<Id, HR_Classification__c> caseTypeMap = new Map<Id, HR_Classification__c>([Select Id, Case_Record_Type__c, Default_Priority__c, Follow_up_Default__c, Advisory_Legal_Counsel__c, Apprenticeships__c, Corporate_Affairs__c, Customer_Social_Media__c, Employee_Relations__c, Group_Investigations__c, Head_of_Advisory__c, HR_Business_Partner__c, Operations_Leadership__c, Payroll_Operations__c, Regional_Manager__c, Safety__c, Site_Manager__c, Total_Loss__c, Wesfarmers_Legal__c, Other__c, Other_Notification__c, Policy_Owner__c, Police__c From HR_Classification__c Where Id In :caseTypeIds]);
        
        for(Case__c ct: CaseTypeModList)
        {
            if(Trigger.IsInsert || ct.Case_Type_3__c != Trigger.OldMap.get(ct.Id).Case_Type_3__c)
            {
                if(ct.Case_Type_3__c != null) 
                {
                    ct.RecordTypeId = caseTypeMap.get(ct.Case_Type_3__c).Case_Record_Type__c;
                    ct.Priority__c = caseTypeMap.get(ct.Case_Type_3__c).Default_Priority__c;
                    ct.Advisory_Legal_Counsel__c = caseTypeMap.get(ct.Case_Type_3__c).Advisory_Legal_Counsel__c;
                    ct.Apprenticeships__c = caseTypeMap.get(ct.Case_Type_3__c).Apprenticeships__c;
                    ct.Corporate_Affairs__c = caseTypeMap.get(ct.Case_Type_3__c).Corporate_Affairs__c;
                    ct.Customer_Social_Media__c = caseTypeMap.get(ct.Case_Type_3__c).Customer_Social_Media__c;
                    ct.Employee_Relations__c = caseTypeMap.get(ct.Case_Type_3__c).Employee_Relations__c;
                    ct.Group_Investigations__c = caseTypeMap.get(ct.Case_Type_3__c).Group_Investigations__c;
                    ct.Head_of_Advisory__c = caseTypeMap.get(ct.Case_Type_3__c).Head_of_Advisory__c;
                    ct.HR_Business_Partner__c = caseTypeMap.get(ct.Case_Type_3__c).HR_Business_Partner__c;
                    ct.Operations_Leadership__c = caseTypeMap.get(ct.Case_Type_3__c).Operations_Leadership__c;
                    ct.Payroll_Operations__c = caseTypeMap.get(ct.Case_Type_3__c).Payroll_Operations__c;
                    ct.Regional_Manager__c = caseTypeMap.get(ct.Case_Type_3__c).Regional_Manager__c;
                    ct.Safety__c = caseTypeMap.get(ct.Case_Type_3__c).Safety__c;
                    ct.Site_Manager_Notify__c = caseTypeMap.get(ct.Case_Type_3__c).Site_Manager__c;
                    ct.Total_Loss__c = caseTypeMap.get(ct.Case_Type_3__c).Total_Loss__c;
                    ct.Wesfarmers_Legal__c = caseTypeMap.get(ct.Case_Type_3__c).Wesfarmers_Legal__c;
                    ct.Other_Notification_Check__c = caseTypeMap.get(ct.Case_Type_3__c).Other__c;
                    ct.Other__c = caseTypeMap.get(ct.Case_Type_3__c).Other_Notification__c;
                    ct.Policy_Owner__c = caseTypeMap.get(ct.Case_Type_3__c).Policy_Owner__c;
                    ct.Police__c = caseTypeMap.get(ct.Case_Type_3__c).Police__c;
                }
            }
        }    
    }
    // Only run if not the Migration User
    if(caseShareList.size() > 0 && userinfo.getName() != 'Migration' && userinfo.getName() != null)
    {
        Map<Id, Contact> conMap = new Map<Id, Contact>([Select Id, Above_Store__c, Gender__c, AccountId From Contact Where Id In :ContactIds]);
        List<Contact> conAccounts = conMap.values();
        Set<Id> conAccountIds = new Set<Id>();
        for(Contact conAcct: conAccounts)
        {
            conAccountIds.Add(conAcct.AccountId);
        }
        Map<Id, Account> siteContactMap = NotificationUtilities.GetSiteSharingContacts(conAccountIds);
        Map<String, Department__c> departmentContactMap = NotificationUtilities.GetDepartmentSharingContacts(conAccountIds);
        HRSharingCalc.insertShare(caseShareList, Trigger.NewMap, siteContactMap, departmentContactMap, conMap);
    }
    TriggerUtilities.setHRBeforeTriggerCalled(); // Update static variable to track that the before trigger has been executed
}