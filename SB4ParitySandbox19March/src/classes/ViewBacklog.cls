/**
* @author       Kim Roth        
* @date         06/11/2013
* @description  This Class is the controller extension class for Visualforce Page "ViewBacklog".
*
*   -----------------------------------------------------------------------------
*   Developer               Date                Description
*   -----------------------------------------------------------------------------
*   
*   Kim Roth                06/11/2013          Initial version                                             
*/

global with sharing class ViewBacklog {

    public List<Work_Product__c> releaseBacklogList {get;set;}
    public List<Work_Product__c> iterationBacklogList {get;set;}
    public List<Work_Product__c> productBacklogList {get;set;}
    public List<Iteration__c> iterationList {get;set;}
    public List<SS_Release__c> releaseList {get;set;}
    public List<Project__c> projectList {get;set;}
    public Id selectedProjectId {get;set;}
    
    /**
    * @author       Kim Roth
    * @date         06/11/2013
    * @description  Method that creates lists for iteration, product and release backlog
    * @param        <none> 
    * @return       <none>
    */  
    public ViewBacklog() { 
    	
    	RecordType parentUserStoryRecordType = [SELECT id FROM RecordType WHERE name = 'Parent User Story' AND sobjectType = 'Work_Product__c'];   
    	    
        selectedProjectId = ApexPages.currentPage().getParameters().get('project');
        if(selectedProjectId == null){
            selectedProjectId = getItems()[0].getValue();
        }
        
        //query for iterations
        iterationList = [select id, name, state__c, start_date__c, end_date__c from iteration__c where project__c = :selectedProjectId order by start_date__c desc];
        
        //query for releases
        releaseList = [select id, name, start_date__c, release_date__c from ss_release__c where project__c = :selectedProjectId order by start_date__c desc];        
        
        //query for release backlog
        releaseBacklogList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, iteration__r.Name, ss_release__r.Name, rank__c, recordtypeid, is_defect__c 
                              from Work_Product__c 
                              where Project__c = :selectedProjectId AND ss_release__c <> NULL and iteration__c = NULL and recordtypeid <> :parentUserStoryRecordType.id
                              order by rank__c asc]; //release is not null
        
        //query for iteration backlog
        
        iterationBacklogList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, iteration__r.Name, ss_release__r.Name, rank__c, is_defect__c 
                                from Work_Product__c 
                                where Project__c = :selectedProjectId AND iteration__c <> NULL and recordtypeid <> :parentUserStoryRecordType.id
                                order by rank__c asc]; // iteration is not null                             
        
        //query for product backlog
        productBacklogList = [select id, name, work_product_id__c, plan_estimate__c, iteration__c, iteration__r.Name, ss_release__r.Name, rank__c, is_defect__c 
                              from Work_Product__c 
                              where Project__c = :selectedProjectId AND iteration__c = NULL and ss_release__c = NULL and recordtypeid <> :parentUserStoryRecordType.id
                              order by rank__c asc];
    }

    @RemoteAction
    global static void updateWorkProductRank(List<Id> toIds,   String toRelease,   String toIteration,   Boolean toAscending, 
                                             List<Id> fromIds, String fromRelease, String fromIteration, Boolean fromAscending) {
      
    	List<Work_Product__c> workProducts = new List<Work_Product__c>();
      Integer count = 0;
    	toRelease     = String.isEmpty(toRelease)     ? null : toRelease;
    	toIteration   = String.isEmpty(toIteration)   ? null : toIteration;
      fromRelease   = String.isEmpty(fromRelease)   ? null : fromRelease;
    	fromIteration = String.isEmpty(fromIteration) ? null : fromIteration;
      
    	for(Id wpId : toIds) {
      		workProducts.add(new Work_Product__c(
        		Id            = wpId,
        		Rank__c       = toAscending ? count : toIds.size() - count - 1,
        		Iteration__c  = toIteration,
        		SS_Release__c = toRelease
      		));
          
          count++;
    	}
      
      if(toRelease != fromRelease || toIteration != fromIteration) {
        count = 0;
        for(Id wpId : fromIds) {
        		workProducts.add(new Work_Product__c(
          		Id            = wpId,
          		Rank__c       = fromAscending ? count : fromIds.size() - count - 1,
          		Iteration__c  = fromIteration,
          		SS_Release__c = fromRelease
        		));
            
            count++;
      	}
      }

    	update workProducts;
      
    }
     
    /**
    * @author       Kim Roth
    * @date         06/25/2013
    * @description  Method to return select options for each project
    * @param        <none>
    * @return       options - List of select options
    */  
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        List<Project__c> projectList = new List<Project__c>();
        RecordType projectRT = new RecordType();
        
        projectRT = [select id FROM RecordType WHERE name = 'Project' AND sObjectType = 'Project__c'];
        projectList = [select id, name from Project__c where recordTypeID =: projectRT.id ORDER BY name];
        
        for(Project__c project : projectList){
            options.add(new SelectOption(project.id, project.name));
        }
        return options;
    }
    
    
    public PageReference selectProject() {
        // Send the user to the backlog page for the selected project
        PageReference projectBacklogPage = Page.ViewBacklog;
        projectBacklogPage.getParameters().put('project', selectedProjectId);        
        projectBacklogPage.setRedirect(true);
        return projectBacklogPage;
    }
    
    
}