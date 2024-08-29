public with sharing class chatter_answers_question_trigger_helper {

    public static void sendMail(List<String> toAddresses, String siteName, String body){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setReplyTo('no-reply@salesforce.com');
        mail.setSenderDisplayName('Salesforce Chatter Answers User');

        // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
        // the portal user profile, and set the ID in the following line.
        // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
        mail.setToAddresses(toAddresses);
        mail.setSubject(siteName);
        mail.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}