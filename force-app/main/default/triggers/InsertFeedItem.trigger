trigger InsertFeedItem on Visit_Report__c (after insert) {
    
    List<User> lstUser = [Select Id From User Where Id != :UserInfo.getuserid() And IsActive = true];
    
    List<FeedItem> lstInsertFeedItem = new List<FeedItem>();
    
    List<EntitySubscription> lstSub = new List<EntitySubscription>();
    
    for(Visit_Report__c vr : trigger.new){
        
        Account acc = [Select Name From Account Where Id =: vr.Account__c];
        Contact cont = [Select Name From Contact Where Id =: vr.Contact__c];
        
        FeedItem post = new FeedItem();
        post.ParentId = vr.Id;
        post.Body = 'I created a visit report titled ' + vr.Name  + ' with the goal of ' + vr.Goal_of_the_visit__c + ' with ' + cont.Name + ' for ' + acc.Name + '. Comments are ' + vr.Comments__c;
        post.status = 'Published';
        lstInsertFeedItem.add(post);
        
        for(User u : lstUser){
            EntitySubscription objSub = new EntitySubscription();
            objSub.ParentId = vr.Id;
            objSub.SubscriberId = u.Id;
            lstSub.add(objSub);
        }
        
    }
    
    if(lstInsertFeedItem.size() > 0){
        insert lstInsertFeedItem;
        //insert lstSub;
    }
    
    
}