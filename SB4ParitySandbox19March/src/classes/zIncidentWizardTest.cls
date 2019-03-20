@IsTest
private class zIncidentWizardTest
{
    /*-------------------------------------------------------------
    Author:        Saikat Dutta
    Company:       Tech Mahindra
    Description:   This class is responsible for testing the code of 'zIncidentWizard' class.
    Inputs:        None
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    28-Mar-14   Saikat              Initial Version
    10-Jul-15   Rohit Kumar         Updated Test CLass Code
    ------------------------------------------------------------*/
    
    static testMethod void testIncidentWizard()
    {
        
        Test.StartTest();            
        
        //
        List<Incident_Navigation__c> lstIN = new List<Incident_Navigation__c>();
        Incident_Navigation__c objIN = new Incident_Navigation__c(
                                    Name = '1_Incident_Summary',
                                    Breadcrumb__c = 'Incident Summary',
                                    Page__c = 'zIncidentSummary',
                                    Sequence__c = 1
                                    );
        lstIN.add(objIN);
        objIN = new Incident_Navigation__c(
                                    Name = '2_Involved_Person',
                                    Breadcrumb__c = 'Involved Person',
                                    Page__c = 'zInvolvedPerson',
                                    Sequence__c = 2
                                    );
        lstIN.add(objIN);
        objIN = new Incident_Navigation__c(
                                    Name = '3_Injury',
                                    Breadcrumb__c = 'Injury',
                                    Page__c = 'zInjury',
                                    Sequence__c = 3
                                    );
        lstIN.add(objIN);
        objIN = new Incident_Navigation__c(
                                    Name = '8_Miscellaneous',
                                    Breadcrumb__c = 'Miscellaneous',
                                    Page__c = 'zMiscellaneous',
                                    Sequence__c = 8
                                    );
        lstIN.add(objIN);
        INSERT lstIN;
        
        System.AssertEquals(lstIN.size(), 4);
        
        String incidentId = createIncident();
        System.Assert(incidentId != null);
        Incident__c objInc = [SELECT Id, Account__c,
                                         Injured_Party__c,
                                         Injured_Party_Type__c,
                                         Team_Member_Not_Known__c,
                                         Page_3_Complete__c,
                                         Pages_Complete__c
                                         FROM Incident__c
                                         WHERE Id =: incidentId LIMIT 1];
       ApexPages.StandardController controller = new ApexPages.StandardController(objInc);
       Boolean flag = false;        
       {
            PageReference pr = new PageReference('/apex/zInjury');
            Test.setCurrentPage(pr);     
            
            ApexPages.currentPage().getParameters().put('type', 'Hazard');    
            ApexPages.currentPage().getParameters().put('clone', '');                  
            
            zIncidentWizard objIW = new zIncidentWizard(controller);  
            objIW.saveRecord();         
        }
        {
            PageReference pr = new PageReference('/apex/zMiscellaneous');
            Test.setCurrentPage(pr);     
            
            ApexPages.currentPage().getParameters().put('type', 'Hazard');    
            ApexPages.currentPage().getParameters().put('clone', '');
            ApexPages.currentPage().getParameters().put('RiskSeverity', 'Test Rev');                  
                        
            zIncidentWizard objIW = new zIncidentWizard(controller); 
            objIW.redirectURL = '/apex/zMiscellaneous';
            objIW.saveRecord();
            objIW.setIncidentRecordType(); 
            objIW.setRiskSeverity();  
            flag = objIW.isTeamMember; 
            flag = objIW.isVisitor; 
            flag = objIW.isNotTeamMember;  
            flag = objIW.isMinor;  
            List<SelectOption> objSO = new List<SelectOption>();
            objSO = objIW.getActionItemTypes();    
            System.Assert(objIW != null); 
        }
        {
            PageReference pr = new PageReference('/apex/zIncidentSummary');
            Test.setCurrentPage(pr);     
            
            ApexPages.currentPage().getParameters().put('type', 'Hazard');    
            ApexPages.currentPage().getParameters().put('clone', '1');                  
            
            objInc.Team_Member_Not_Known__c = true;
            UPDATE objInc;
            
            zIncidentWizard objIW = new zIncidentWizard(controller);
            objIW.saveRecord();
            flag = objIW.isMinor;
        }
        {
            PageReference pr = new PageReference('/apex/zIncidentSummary');
            Test.setCurrentPage(pr);     
            
            ApexPages.currentPage().getParameters().put('type', 'Hazard');    
            ApexPages.currentPage().getParameters().put('clone', '');                  
            
            zIncidentWizard objIW = new zIncidentWizard(controller); 
            objIW.saveRecord();          
        }        
        
        Test.StopTest(); 
    }
    
    private static String createIncident()
    {
        //
        Account objAcc = new Account(Name = 'SFDC Ltd.', Brand__c = 'SFDC');
        INSERT objAcc;
        
        //
        Contact objCon = new Contact(
                            LastName = 'test LN',
                            AccountId = objAcc.Id,
                            Birthdate = Date.Today()
                            );
        INSERT objCon;
        
        //
        Incident__c objInc = new Incident__c(
                                Account__c = objAcc.Id,
                                Incident_Date_Time__c = DateTime.now(),
                                Injury_or_Illness__c = True,
                                Injured_Party__c = objCon.Id,
                                Injured_Party_Type__c = 'Team Member',
                                Team_Member_Not_Known__c = false,
                                cause_category__C='test',
                                Cause_Sub_Category__c='test',
                                Type_of_Treatment__c='tes'
                                );
        INSERT objInc;    
        
        //
        Injury__c objInj = new Injury__c(
                           Incident__c =  objInc.Id,
                           Injury_Illness_Type__c = 'Burn',
                           Bodily_Location__c = 'Neck (L/R)',
                           Injury_Illness_Details__c = 'test',
                           Position__c = 'Team_Member__c',
                           Team_Member__c = objCon.Id
                           );
        INSERT objInj;
        
        //
        Task objTask = new Task(
                        Type = 'Call',
                        Subject = 'Test Task',
                        Status = 'In Progress',
                        WhatId = objInc.Id
                        );
        INSERT objTask;                
        
        RETURN objInc.Id;                    
    }
}