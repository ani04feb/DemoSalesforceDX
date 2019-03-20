/**
* @author       Sumeet Kumar
* @date         09/16/2016
* @description  This is controller to support Request module of Salesforce.
It allows users to save records and add attachment.
*    --------------------------------------------------------------------------
*    Developer                  Date                Description
*    --------------------------------------------------------------------------
*/
public class ColesReqController {
    public String imageURL{get;set;}
    private ApexPages.StandardController controller;
    public String filename {get; set;}
    public Blob filebody {get; set;}
    public String filename2 {get; set;}
    public Blob filebody2 {get; set;}
    public String filename3 {get; set;}
    public Blob filebody3 {get; set;}
    public ColesReqController(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    public PageReference save() {
        return null;
    }
    public PageReference saveNreturn() {
        if(controller.save() != null) {
            
            if(filename != null){
            insert new Attachment(Name = filename, Body = filebody, ParentId = controller.getId());}
            if(filename2 != null){
            insert new Attachment(Name = filename2, Body = filebody2, ParentId = controller.getId());}
            if(filename3 != null){
            insert new Attachment(Name = filename3, Body = filebody3, ParentId = controller.getId());}
            
            PageReference requestPage = Page.colesReqMessage;
            requestPage.setRedirect(true);
            requestPage.getParameters().put('id',controller.getId());
            return requestPage;
        }  return null;
        
    }
    
}