Global Class NotificationUtilities
{

    public static Map<Id, Account> GetSiteNotifications(Set<Id> acctIds) {
        Map<Id, Account> siteNotificationMap = new Map<Id, Account>([SELECT Id, Above_Store__c, Advisory_Legal_Counsel__c, Apprenticeships__c, Corporate_Affairs__c, Customer_Social_Media__c, Employee_Relations__c, Group_Investigations__c, Head_of_Advisory__c, HR_Business_Partner__c, Operations_Leadership__c, Payroll_Operations__c, Regional_Manager__c, Safety__c, Site_Manager__c, Total_Loss__c, Wesfarmers_Legal__c FROM Account WHERE Id IN :acctIds]);
        System.Debug('>>>>>>>>Get Notifications>>>>>>>>');
        return siteNotificationMap;
    }
    
    public static Map<Id, Account> GetSiteSharingContacts(Set<Id> acctIds) {
        Map<Id, Account> siteContactsMap = new Map<Id, Account>([SELECT Id, Name, Site_Manager_Id__c, HR_Business_Partner_Id__c, HR_Business_Partner__c FROM Account WHERE Id IN :acctIds]);
        return siteContactsMap;
    }
    
    public static Map<String, Department__c> GetDepartmentNotifications(Set<Id> acctIds) {
        Map<String, Department__c> departmentNotificationMap = new Map<String, Department__c>();
        List<Department__c> deptList = new List<Department__c>([SELECT Id, Department__c, Account__c, Advisory_Legal_Counsel__c, Apprenticeships__c, Corporate_Affairs__c, Customer_Social_Media__c, Employee_Relations__c, Group_Investigations__c, Head_of_Advisory__c, HR_Business_Partner__c, Operations_Leadership__c, Payroll_Operations__c, Regional_Manager__c, Safety__c, Site_Manager__c, Total_Loss__c, Wesfarmers_Legal__c FROM Department__c WHERE Account__c IN :acctIds]);
        for(Department__c d :deptList)
        {
            departmentNotificationMap.put(d.Account__c+d.Department__c, d);
        }
        return departmentNotificationMap;
    }
    
    public static Map<String, Department__c> GetDepartmentSharingContacts(Set<Id> acctIds) {
        Map<String, Department__c> departmentContactMap = new Map<String, Department__c>();
        List<Department__c> deptList = new List<Department__c>([SELECT Id, Account__c, Department__c, Site_Manager_Id__c, HR_Business_Partner_Id__c, HR_Business_Partner__c FROM Department__c WHERE Account__c IN :acctIds]);
        for(Department__c d :deptList)
        {
            departmentContactMap.put(d.Account__c+d.Department__c, d);
        }
        return departmentContactMap;
    }
    
    public static Map<Id, Contact> GetNotificationRecipients(List<Account> acctList, List<Department__c> deptList)
    {
        Set<Id> conIds = new Set<Id>();
        System.Debug('>>>>>>>>Getting Recipients>>>>>>>>Dsize:' + deptList.size().format() + 'Asize:' + acctList.size().format());
        for(Account a: acctList)
        {
            conIds.Add(a.Advisory_Legal_Counsel__c);
            conIds.Add(a.Apprenticeships__c);
            conIds.Add(a.Corporate_Affairs__c);
            conIds.Add(a.Customer_Social_Media__c);
            conIds.Add(a.Employee_Relations__c);
            conIds.Add(a.Group_Investigations__c);
            conIds.Add(a.Head_of_Advisory__c);
            conIds.Add(a.HR_Business_Partner__c);
            conIds.Add(a.Operations_Leadership__c);
            conIds.Add(a.Payroll_Operations__c);
            conIds.Add(a.Regional_Manager__c);
            conIds.Add(a.Safety__c);
            conIds.Add(a.Site_Manager__c);
            conIds.Add(a.Total_Loss__c);
            conIds.Add(a.Wesfarmers_Legal__c);
        }
        for(Department__c d: deptList)
        {
            conIds.Add(d.Advisory_Legal_Counsel__c);
            conIds.Add(d.Apprenticeships__c);
            conIds.Add(d.Corporate_Affairs__c);
            conIds.Add(d.Customer_Social_Media__c);
            conIds.Add(d.Employee_Relations__c);
            conIds.Add(d.Group_Investigations__c);
            conIds.Add(d.Head_of_Advisory__c);
            conIds.Add(d.HR_Business_Partner__c);
            conIds.Add(d.Operations_Leadership__c);
            conIds.Add(d.Payroll_Operations__c);
            conIds.Add(d.Regional_Manager__c);
            conIds.Add(d.Safety__c);
            conIds.Add(d.Site_Manager__c);
            conIds.Add(d.Total_Loss__c);
            conIds.Add(d.Wesfarmers_Legal__c);
        }
        Map<Id, Contact> conMap = new Map<Id, Contact>([SELECT Id, Name, Email FROM Contact WHERE Id IN :conIds]);
        return conMap;
    }
    
    public static void setNotificationRecipents(Case__c c, Map<Id, Contact> conMap, Map<Id, Account> siteNotificationMap, Map<String, Department__c> departmentNotificationMap, Map<Id, Contact> contactEmailMap)
    {
        if(c.Contact__c != null && conMap.get(c.Contact__c).AccountId != null)
        {
            String notificationSiteId = conMap.get(c.Contact__c).AccountId;
            String notificationDepartmentKey = conMap.get(c.Contact__c).AccountId + c.Reporting_Department__c;
            // Set Notifications

            if(siteNotificationMap.get((conMap.get(c.Contact__c).AccountId)).Above_Store__c) //Above Store so retrieve notifications from Department
            {
                if(departmentNotificationMap.get(notificationDepartmentKey) != null) // Ensure lookup to Department is successful before attempting to extract values
                {    
                    System.Debug('>>>>>>>>>>>>>>>>> Department Notifications');
                    if(departmentNotificationMap.get(notificationDepartmentKey).Apprenticeships__c != null)
                        c.Apprenticeships_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Apprenticeships__c).Email;
                    else c.Apprenticeships_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Corporate_Affairs__c != null)
                        c.Corporate_Affairs_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Corporate_Affairs__c).Email;
                    else c.Corporate_Affairs_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Customer_Social_Media__c != null)
                        c.Customer_Social_Media_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Customer_Social_Media__c).Email;
                    else c.Customer_Social_Media_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Employee_Relations__c != null)
                        c.Employee_Relations_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Employee_Relations__c).Email;
                    else c.Employee_Relations_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Group_Investigations__c != null)
                        c.Group_Investigations_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Group_Investigations__c).Email;
                    else c.Group_Investigations_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Operations_Leadership__c != null)
                        c.Operations_Leadership_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Operations_Leadership__c).Email;
                    else c.Operations_Leadership_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Payroll_Operations__c != null)
                        c.Payroll_Operations_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Payroll_Operations__c).Email;
                    else c.Payroll_Operations_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Safety__c != null)
                        c.Safety_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Safety__c).Email;
                    else c.Safety_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Total_Loss__c != null)
                        c.Total_Loss_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Total_Loss__c).Email;
                    else c.Total_Loss_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Wesfarmers_Legal__c != null)
                        c.Westfarmers_Legal_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Wesfarmers_Legal__c).Email;
                    else c.Westfarmers_Legal_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Advisory_Legal_Counsel__c != null)
                        c.Advisory_Legal_Counsel_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Advisory_Legal_Counsel__c).Email;
                    else c.Advisory_Legal_Counsel_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).Head_of_Advisory__c != null)
                        c.Head_of_Advisory_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Head_of_Advisory__c).Email;
                    else c.Head_of_Advisory_Email__c = null;
                    if(departmentNotificationMap.get(notificationDepartmentKey).HR_Business_Partner__c != null) {
                        c.HR_Business_Partner_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).HR_Business_Partner__c).Email;
                        c.Site_HR_Business_Partner__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).HR_Business_Partner__c).Name;
                    }
                    else {
                        c.HR_Business_Partner_Email__c = null;
                        c.Site_HR_Business_Partner__c = null;
                    }
                    if(departmentNotificationMap.get(notificationDepartmentKey).Regional_Manager__c != null) {
                        c.Regional_Manager_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Regional_Manager__c).Email;
                        c.Site_Regional_Manager__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Regional_Manager__c).Name;
                    }
                    else {
                        c.Regional_Manager_Email__c = null;
                        c.Site_Regional_Manager__c = null;
                    }
                    if(departmentNotificationMap.get(notificationDepartmentKey).Site_Manager__c != null) {
                        c.Site_Manager_Email__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Site_Manager__c).Email;
                        c.Site_Manager__c = contactEmailMap.get(departmentNotificationMap.get(notificationDepartmentKey).Site_Manager__c).Name;
                    }
                    else {
                        c.Site_Manager_Email__c = null;
                        c.Site_Manager__c = null;
                    }
                }
                else // Department lookup has failed (Reporting Department on Case does not exist against the selected Site
                {
                    c.Apprenticeships_Email__c = null;
                    c.Corporate_Affairs_Email__c = null;
                    c.Customer_Social_Media_Email__c = null;
                    c.Employee_Relations_Email__c = null;
                    c.Group_Investigations_Email__c = null;
                    c.Operations_Leadership_Email__c = null;
                    c.Payroll_Operations_Email__c = null;
                    c.Safety_Email__c = null;
                    c.Total_Loss_Email__c = null;
                    c.Westfarmers_Legal_Email__c = null;
                    c.Advisory_Legal_Counsel_Email__c = null;
                    c.Head_of_Advisory_Email__c = null;
                    c.HR_Business_Partner_Email__c = null;
                    c.Site_HR_Business_Partner__c = null;
                    c.Regional_Manager_Email__c = null;
                    c.Site_Regional_Manager__c = null;
                    c.Site_Manager_Email__c = null;
                    c.Site_Manager__c = null;
                }
            }
            else //Retail so get Notifications direct from Site
            {
                System.Debug('>>>>>>>>>>>>>>>>> Site Notifications');
                if(siteNotificationMap.get(notificationSiteId).Apprenticeships__c != null)
                    c.Apprenticeships_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Apprenticeships__c).Email;
                else c.Apprenticeships_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Corporate_Affairs__c != null)
                    c.Corporate_Affairs_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Corporate_Affairs__c).Email;
                else c.Corporate_Affairs_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Customer_Social_Media__c != null)
                    c.Customer_Social_Media_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Customer_Social_Media__c).Email;
                else c.Customer_Social_Media_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Employee_Relations__c != null)
                    c.Employee_Relations_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Employee_Relations__c).Email;
                else c.Employee_Relations_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Group_Investigations__c != null)
                    c.Group_Investigations_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Group_Investigations__c).Email;
                else c.Group_Investigations_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Operations_Leadership__c != null)
                    c.Operations_Leadership_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Operations_Leadership__c).Email;
                else c.Operations_Leadership_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Payroll_Operations__c != null)
                    c.Payroll_Operations_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Payroll_Operations__c).Email;
                else c.Payroll_Operations_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Safety__c != null)
                    c.Safety_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Safety__c).Email;
                else c.Safety_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Total_Loss__c != null)
                    c.Total_Loss_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Total_Loss__c).Email;
                else c.Total_Loss_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Wesfarmers_Legal__c != null)
                    c.Westfarmers_Legal_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Wesfarmers_Legal__c).Email;
                else c.Westfarmers_Legal_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Advisory_Legal_Counsel__c != null)
                    c.Advisory_Legal_Counsel_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Advisory_Legal_Counsel__c).Email;
                else c.Advisory_Legal_Counsel_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).Head_of_Advisory__c != null)
                    c.Head_of_Advisory_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Head_of_Advisory__c).Email;
                else c.Head_of_Advisory_Email__c = null;
                if(siteNotificationMap.get(notificationSiteId).HR_Business_Partner__c != null) {
                    c.HR_Business_Partner_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).HR_Business_Partner__c).Email;
                    c.Site_HR_Business_Partner__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).HR_Business_Partner__c).Name;
                }
                else {
                    c.HR_Business_Partner_Email__c = null;
                    c.Site_HR_Business_Partner__c = null;
                }
                if(siteNotificationMap.get(notificationSiteId).Regional_Manager__c != null) {
                    c.Regional_Manager_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Regional_Manager__c).Email;
                    c.Site_Regional_Manager__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Regional_Manager__c).Name;
                }
                else {
                    c.Regional_Manager_Email__c = null;
                    c.Site_Regional_Manager__c = null;
                }
                if(siteNotificationMap.get(notificationSiteId).Site_Manager__c != null) {
                    c.Site_Manager_Email__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Site_Manager__c).Email;
                    c.Site_Manager__c = contactEmailMap.get(siteNotificationMap.get(notificationSiteId).Site_Manager__c).Name;
                }
                else {
                    c.Site_Manager_Email__c = null;
                    c.Site_Manager__c = null;
                }
            }             
        }
        else {
            c.Apprenticeships_Email__c = null;
            c.Corporate_Affairs_Email__c = null;
            c.Customer_Social_Media_Email__c = null;
            c.Employee_Relations_Email__c = null;
            c.Group_Investigations_Email__c = null;
            c.Operations_Leadership_Email__c = null;
            c.Payroll_Operations_Email__c = null;
            c.Safety_Email__c = null;
            c.Total_Loss_Email__c = null;
            c.Westfarmers_Legal_Email__c = null;
            c.Advisory_Legal_Counsel_Email__c = null;
            c.Head_of_Advisory_Email__c = null;
            c.HR_Business_Partner_Email__c = null;
            c.Site_HR_Business_Partner__c = null;
            c.Regional_Manager_Email__c = null;
            c.Site_Regional_Manager__c = null;
            c.Site_Manager_Email__c = null;
            c.Site_Manager__c = null;
        }
    }
    
}