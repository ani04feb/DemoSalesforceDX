public class matterCommentsController {

    public ApexPages.standardController controller {get; set;}
    /*
    public Matter__c matter {get; set;}
    public String notes {get; set;}
    */
    public matterCommentsController(ApexPages.StandardController stdController) {
        controller = stdController;
        //matter = (Matter__c)controller.getRecord();
    }
    /*
    public void saveRecord()
    {
        matter.Matter_Notes__c = Datetime.now().format() + '<br/>' + matter.New_Notes__c + '<br/><br/>' + matter.Matter_Notes__c;
        matter.New_Notes__c = '';
        update matter;
    }  
*/
}