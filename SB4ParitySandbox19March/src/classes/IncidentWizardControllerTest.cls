@isTest
private class IncidentWizardControllerTest {
    
    private static ApexPages.StandardController stdCtrl;
    private static IncidentWizardController ctrl;
    private static Incident__c inc;
    
    static {
        Account a = new Account(Name='1');
        insert a;
        
        // Create a new incident
        inc = new Incident__c(Hazard__c=true, Account__c=a.id);
        inc.Site_Name__c = 'Test Site';
        inc.Incident_Date_Time__c = date.newinstance((date.today().year() - 1), 1, 1);
        insert inc;
        // Constructor
        stdCtrl = new ApexPages.StandardController(inc);
        
        PageReference pageRef = Page.Incident_Summary;
        Test.setCurrentPage(pageRef);
        ctrl = new IncidentWizardController(stdCtrl);
        
        pageRef = Page.Injury;
        Test.setCurrentPage(pageRef);
        ctrl = new IncidentWizardController(stdCtrl);
        
        pageRef = Page.Footer;
        Test.setCurrentPage(pageRef);
        ctrl = new IncidentWizardController(stdCtrl);
    }

    // Save operation for Incident
    private static testMethod void testSave() {
        PageReference pageRef = Page.Incident_Summary;
        Test.setCurrentPage(pageRef);
        ctrl.save();
    }        
    private static testMethod void testClone() {
        PageReference pageRef = Page.Incident_Summary;
        ApexPages.currentPage().getParameters().put('clone', '1');
        Test.setCurrentPage(pageRef);
        ctrl.cloneActions();
    }

    private static testMethod void testVoidMethods(){
        
        system.debug(ctrl.isTeamMember);
        system.debug(ctrl.isVisitor);
        system.debug(ctrl.isNotTeamMember);
        
        Date d = Date.Today();
        d = d.addDays(-10);
        Contact c = new Contact(LastName = 'Test Contact', BirthDate = d);
        insert c;
        
        // Team Member is a Minor
        inc.Injured_Party_Type__c = 'Team Member';
        inc.Team_Member_Not_Known__c = false;
        inc.Injured_Party__c = c.id;
        update inc;
        system.debug(ctrl.isMinor);
        
        // Incident date time
        inc.Incident_Date_Time__c = date.newinstance((date.today().year() - 1), 1, 1);
        
        update inc;
        system.debug(ctrl.isMinor);
        
        // Non Team Member - DOB
        inc.Injured_Party_Type__c = 'Visitor';
        inc.Injured_Party__c = null;
        inc.date_of_birth__c = d;
        update inc;
        system.debug(ctrl.isMinor);
        
        // Non Team Member - Age Group
        inc.Injured_Party_Type__c = 'Visitor';
        inc.Injured_Party__c = null;
        inc.date_of_birth__c = null;
        inc.Age_Group__c = '<16';
        update inc;
        system.debug(ctrl.isMinor);
        
        // Last catch
        inc.Age_Group__c = null;
        update inc;
        system.debug(ctrl.isMinor);
        
        Account a = new Account(Name = 'Test Account', Brand__c = 'Supermarkets');
        insert a;
        
        inc.Account__c = a.Id;
        update inc;
        
        ctrl.setIncidentRecordType();
        
        ApexPages.currentPage().getParameters().put('RiskSeverity', 'High');
        ctrl.setRiskSeverity();
        
        IncidentWizardController.getAllCauses();
    }
    
    private static testMethod void testUpsert(){
        PageReference pageRef = Page.Footer;
        Test.setCurrentPage(pageRef);
        ctrl = new IncidentWizardController(stdCtrl);
        
        for(Incident_Witness__c i: ctrl.Witnesses){
            i.Witness_Name__c = 'Someone';
            i.Witness_Type__c = 'Something';
        }
        
        Task t = new Task(WhatId = ctrl.incident.id);
        insert t;
        ctrl = new IncidentWizardController(stdCtrl);
        for(IncidentWizardController.clsTask i: ctrl.ActionTasks)
            i.Type = 'Something';
        ctrl.save();
        ctrl.getActionItemTypes();
    }
    
    private static testMethod void testNavigation() {
        createCustomSettings();
        
        // Injury
        inc.Injury_or_Illness__c = true;
        update inc;
        
        PageReference pageRef = Page.Incident_Summary;
        Test.setCurrentPage(pageRef);
        ctrl.setPageName('/apex/incident_summary');
        ctrl.nextPage();
        
        pageRef = Page.Impacted_Person;
        Test.setCurrentPage(pageRef);
        ctrl.setPageName('/apex/impacted_person');
        ctrl.nextPage();
        ctrl.prevPage();
        
        pageRef = Page.Injury;
        Test.setCurrentPage(pageRef);
        Injury__c i = new Injury__c();
        i.Injury_Illness_Type__c = 'Fracture';
        i.Bodily_Location__c = 'Neck';
        i.Position__c = 'Right';
        i.Incident__c = inc.id;
        ctrl.Injuries = new List<Injury__c>();
        ctrl.Injuries.add(i);
        ctrl.setPageName('/apex/injury');
        ctrl.nextPage();
        ctrl.prevPage();
        
        // For remaining pages, Impacted Person will be the page.
        pageRef = Page.Impacted_Person;
        Test.setCurrentPage(pageRef);
        // Other Incident page
        inc.Injury_or_Illness__c = false;
        inc.Other_Incident__c = true;
        update inc;
        ctrl.setPageName('/apex/impacted_person');
        ctrl.nextPage();
        ctrl.prevPage();
        
        // Hazard
        inc.Other_Incident__c = false;
        inc.Hazard__c = true;
        update inc;
        ctrl.nextPage();
        ctrl.prevPage();
        
        inc.Hazard__c = false;
        inc.Regulatory_Compliance__c = true;
        update inc;
        ctrl.nextPage();
        ctrl.prevPage();
        
        inc.Regulatory_Compliance__c = false;
        inc.Near_Miss__c = true;
        update inc;
        ctrl.nextPage();
        ctrl.prevPage();
        
        ApexPages.currentPage().getParameters().put('type', 'Hazard');
        ctrl.nextPage();
        ctrl.prevPage();
        
    }

    private static void createCustomSettings(){
        List<String> pages = new List<String>{'Incident_Summary', 'Impacted_Person', 'Injury', 'Hazard', 'Near_Miss', 'Regulatory_Compliance', 'OtherIncident', 'Footer', 'Coding'};
        List<Incident_Nav_Lookup__c> lst = new List<Incident_Nav_Lookup__c>();
        Integer seq = 1;    
        
        for(string page : pages){
            Incident_Nav_Lookup__c nav = new Incident_Nav_Lookup__c(
                                                Name = string.valueOf(seq) + '_' + page,
                                                Page__c = page,
                                                Sequence__c = seq);
            lst.add(nav);
            seq++;
        }
        insert lst;
    }
}