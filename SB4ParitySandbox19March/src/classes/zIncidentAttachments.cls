public with sharing class zIncidentAttachments {
    /*-------------------------------------------------------------
    Author:        Deepu Chacko, Lok Jackson, Kim Davies, Paul Fayle
    Company:       Salesforce.com
    Description:   Provides ability to upload an attachment on Force.com Site and Internal Pages for an Incident
    Inputs:        Incident Id
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    30-Mar-14   Deepu               Initial Version - Force.com Site (Attachment), Others (FeedItem)
    ------------------------------------------------------------*/

	private Incident__c inc;
	private static final string CONS_HTTP = 'http://';
	
	public Boolean isSite               {get; set;}
	public List<IncidentFile> Files     {get; set;}

	public zIncidentAttachments(ApexPages.StandardController ctrl) {
		inc = (Incident__c) ctrl.getRecord();
		
		// Check if the logged in user is a Site user.
		Id siteProfileId = [SELECT Id FROM Profile WHERE Name='Coles Safety Profile' LIMIT 1][0].Id;
		isSite = (Userinfo.getProfileId() == siteProfileId);

    	Files = new List<IncidentFile>();	
		getFiles();
	}
	
	private void getFiles(){
        for(incident__c i : 
                [select id,
                    (select id, title, body, createddate, createdby.name from Notes order by createddate desc),
                    (select id, Name, Description, createddate, createdby.name from Attachments order by createddate desc),
                    (select id, parentid, type, title, LinkUrl, body, relatedrecordid, createddate, createdby.name from Feeds where type='ContentPost' or type = 'LinkPost' order by createddate desc)
                 from incident__c
                 where id =: inc.id]){
                     
            // Prioritize Feed Items above other things while displaying
            for(Incident__Feed f : i.Feeds)
                Files.add(new IncidentFile(f.relatedrecordid, f.type, f.title, f.body, f.LinkUrl, f.createddate, f.createdby.name));
            
            for(Attachment a : i.Attachments)
                Files.add(new IncidentFile(a.Id, 'Attachment', a.Name, a.Description, a.createddate, a.createdby.name));
            
            for(Note n : i.Notes)
                Files.add(new IncidentFile(n.Id, 'Link', n.title, n.Body, n.createddate, n.createdby.name));
        }	    
	}
	
	// For Sites, Files are stored in Attachments
    public Attachment File {
        get {
            if (File == null)
                File = new Attachment();
            return File;
        }
        set;
    }
    
	// For Sites, Links are stored in Notes with the Link Name in the Title and Link URL in the Body
    public Note Link {
        get {
            if (Link == null)
                Link = new Note(Body = CONS_HTTP);
            return Link;
        }
        set;
    }
    
    // Upload function can be called either from console or vf or site.
    // Force.com Site does not have access to create a FeedItem record so will be using attachments as a backup
    public PageReference upload()
    {   
        if(File.Name != null){
            try{
                File.ParentId = inc.Id;
                insert File;
            } catch (DMLException e){
                ApexPages.addMessages(e);
                return null;
            }
            // If there are already files then add to the starting of the list so it shows up at the top for the user.
            IncidentFile f = new IncidentFile(File.Id, 'Attachment', File.Name, File.Description, System.now(), UserInfo.getName());
            if(Files.size() > 0) Files.add(0, f); else Files.add(f);
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'File was uploaded successfully.'));
            File = new Attachment();    // Ready for next file.
        }
        
        // If either of the fields are filled in then ask the user to fill both
        Link.Body = Link.Body.replace(CONS_HTTP, '');   // Easier for validation, we'll add it later
        if((Link.Title != '' && Link.Body == '') || (Link.Title == '' && Link.Body != ''))
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Both the fields, Link Name and a valid URL are required to add a link.'));
        
        // Save only if both is filled in
        if(Link.Title != '' && Link.Body != ''){
            // Make sure there is a http (allows https) in the front.
            if(!Link.Body.startsWith('http')) Link.Body = 'http://' + Link.Body;

            try{
                Link.ParentId = inc.Id;
                insert Link;
            } catch (DMLException e){
                ApexPages.addMessages(e);
                return null;
            }
            // If there are already files then add to the starting of the list so it shows up at the top for the user.
            IncidentFile f = new IncidentFile(Link.Id, 'Link', Link.title, Link.Body, System.now(), UserInfo.getName());
            if(Files.size() > 0) Files.add(0, f); else Files.add(f);
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Link was saved successfully.'));
            Link = new Note(Body = CONS_HTTP);
        }
        return new PageReference('/apex/zincidentattachments?1=1&id=' + inc.id);
    }        

	
	// Wrapper class to display information from Attachments (Note-Link, Attachment) as well as from Feeds (File and Links)
	public class IncidentFile{
	    public String Id     {get; set;}
	    public String Name   {get; set;}
	    public String Link   {get; set;}
	    public String Description   {get; set;}
	    public String Type   {get; set;}    // Link or Attachment
	    public String Who    {get; set;}
	    public String CreatedOn   {get; set;}
	    
	    // Add a feed item (link or file)
	    public IncidentFile(String p_id, String p_type, String p_title, String p_body, String p_url, DateTime p_createddate, String p_createdby){
	        this.Id             = p_id;
	        this.Name           = p_title;
	        this.Link           = (p_type == 'ContentPost' ? ('/' + p_id) : p_url);
	        this.Description    = p_body;
	        this.Type           = (p_type == 'ContentPost' ? 'Feed Attachment' : 'Feed Link');
	        this.Who            = p_createdby;
	        this.CreatedOn      = p_createddate.format();
	    }
	    
	    // Add an attachment or note
	    public IncidentFile(String p_id, String p_type, String p_name, String p_description, DateTime p_createddate, String p_createdby){
	        this.Id             = p_id;
	        this.Name           = p_name;
	        this.Link           = (p_type == 'Attachment' ? ('/' + p_id) : p_description);
	        this.Description    = (p_type == 'Attachment' ? p_description : '');
	        this.Type           = p_type;
	        this.Who            = p_createdby;
	        this.CreatedOn      = p_createddate.format();
	    }
	}

}