@isTest
private class IncidentAttachmentHandlerTest
{
  
  static testMethod void testInboundEmail() 
  {
  Account acc = new Account(Name='Test', Brand__c = 'Supermarkets');
  insert acc;
  Incident__c incident1 = new Incident__c(Account__c = acc.Id, Hazard__c = true);
  insert incident1;
  
  // create a new email and envelope object
  
  Messaging.InboundEmail email = new Messaging.InboundEmail() ;
  Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

  // setup the data for the email
  email.subject = [SELECT Name from Incident__c WHERE Id = :incident1.Id LIMIT 1].Name;

  // add an attachment
  Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
  attachment.body = blob.valueOf('my attachment text');
  attachment.fileName = 'textfile.txt';
  attachment.mimeTypeSubType = 'text/plain';

  email.binaryAttachments =
    new Messaging.inboundEmail.BinaryAttachment[] { attachment };

  // call the email service class and test it with the data in the testMethod
  IncidentAttachmentHandler emailProcess = new IncidentAttachmentHandler();
  emailProcess.handleInboundEmail(email, env);

  // find the attachment
  Attachment a = [select name from attachment where parentId = :incident1.id];

  System.assertEquals(a.name,'textfile.txt');

  }
}