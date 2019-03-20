@isTest
private class zIncidentAttachmentsTest {

	private static testMethod void testConstructor() {
		// Cover Upload for Attachments
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(new Incident__c());
        Incident__c  inc= new Incident__c();
         
		zIncidentAttachments ctrl = new zIncidentAttachments(stdCtrl);
         
        // Covering for Note   
        ctrl.Link.Title = 'Test For Notes';
        ctrl.Link.Body = 'https://www.notesDesription.com';
        ctrl.Link.ParentId = inc.Id;
        
        // Covering for Attachmnet 
        ctrl.File.Name = 'Test For Attachment';
        ctrl.File.Description = 'Test For Attachment Description';
        ctrl.File.ParentId = inc.Id;
     
        zIncidentAttachments.IncidentFile incidentFileForNotesTest = 
            new zIncidentAttachments.IncidentFile(ctrl.Link.ParentId, 'Note', ctrl.Link.title, ctrl.Link.Body, System.now(), UserInfo.getName());
    
        zIncidentAttachments.IncidentFile incidentFileForFeedTest = 
            new zIncidentAttachments.IncidentFile(ctrl.Link.ParentId, 'Feed', 'Test For Feed/Link', 'Test for Feed/Link Body', 'https://www.google.com',System.now(), UserInfo.getName());    
      
          
        zIncidentAttachments.IncidentFile incidentFileForAttachmentTest = 
            new zIncidentAttachments.IncidentFile(ctrl.File.ParentId, 'Attachment', ctrl.File.Name, ctrl.File.Description, System.now(), UserInfo.getName());
        
        ctrl.upload();
        
        // Cover Upload for Links
        ApexPages.StandardController stdCtrl2 = new ApexPages.StandardController(new Incident__c());
        zIncidentAttachments ctrl2 = new zIncidentAttachments(stdCtrl2);
         // Covering for Note   
        ctrl2.Link.Title = 'Test For Notes';
        ctrl2.Link.Body = 'https://www.notesDesription.com';
        ctrl2.Link.ParentId = inc.Id;
        ctrl2.upload();
        
        // Cover Upload for IF Link Clause
        ApexPages.StandardController stdCtrl3 = new ApexPages.StandardController(new Incident__c());
        zIncidentAttachments ctrl3 = new zIncidentAttachments(stdCtrl3);
         // Covering for Note   
        ctrl3.Link.Title = 'If Title is not blank and Body is';
        ctrl3.Link.Body = '';
        ctrl3.upload();
		
	}

}