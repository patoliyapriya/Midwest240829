trigger chatter_answers_question_escalation_to_case_trigger on Question (after update) {
    for (Question q: Trigger.new) {
        try {
            if (q.Priority == 'high' && (q.Cases == null || q.Cases.size() == 0) && Trigger.oldMap.get(q.id).Priority != 'high') {
                q = [select Id, Title, Body, CommunityId, createdById, createdBy.AccountId, createdBy.ContactId
                        from Question 
                        where Id = :q.Id];
                Case newCase = new Case(Origin='Chatter Answers', OwnerId=q.CreatedById, QuestionId=q.Id, CommunityId=q.CommunityId,
                                             Subject=q.Title, Description = (q.Body == null? null: q.Body.stripHtmlTags()), 
                                             AccountId=q.CreatedBy.AccountId, ContactId=q.CreatedBy.ContactId);
                insert newCase;
            }
        } catch (Exception e) {

            chatter_answers_question_trigger_helper.sendMail(new String[] { Site.getAdminEmail() }, 'Case Escalation exception in site ' + Site.getName(), 'Case Escalation on Question having ID: ' + q.Id + ' has failed with the following message: ' + e.getMessage() + '\n\nStacktrace: ' + e.getStacktraceString());

            // //In case you have issues with code coverage for this section, you can move this to a separate helper class method which can be tested separately
            // Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            // mail.setReplyTo('no-reply@salesforce.com');
            // mail.setSenderDisplayName('Salesforce Chatter Answers User');

            // // The default sender is the portal user causing this trigger to run, to change this, set an organization-wide address for
            // // the portal user profile, and set the ID in the following line.
            // // mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
            // mail.setToAddresses(new String[] { Site.getAdminEmail() });
            // mail.setSubject('Case Escalation exception in site ' + Site.getName());
            // mail.setPlainTextBody('Case Escalation on Question having ID: ' + q.Id + ' has failed with the following message: ' + e.getMessage() + '\n\nStacktrace: ' + e.getStacktraceString());
            // Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}