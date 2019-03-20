global class IncidentAttachmentHandler implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

    String incidentNum = email.subject;
    Incident__c incident = [SELECT Id FROM Incident__c WHERE Name = :incidentNum LIMIT 1];

    System.debug('====> Incident Id is '+incident.Id);

    if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
      for (integer i = 0 ; i < email.binaryAttachments.size() ; i++) {
        Attachment attachment = new Attachment();
        // attach to the newly created contact record
        attachment.ParentId = incident.Id;
        attachment.Name = email.binaryAttachments[i].filename;
        attachment.Body = email.binaryAttachments[i].body;
        insert attachment;
      }
    }

    return result;

  }
}