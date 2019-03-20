global class CaseUtilities { 
    webService static void SubmitCase(String caseRecId) {
        Case__c caseRec = [SELECT Notifications_Sent__c FROM Case__c WHERE Id = :caseRecId LIMIT 1];
        caseRec.Notifications_Sent__c = true;
        update caseRec;
    }
}