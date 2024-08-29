trigger FeedItemTrigger on FeedItem(After Insert, After Update){
    Map<Id, FeedItem> opportunityIdByFeedItem = new Map<Id, FeedItem>();
    
    for(FeedItem fi : trigger.new){
        if(fi.ParentId != null && String.valueOf(fi.ParentId).startswith('006')){
            opportunityIdByFeedItem.put(fi.ParentId, fi);
        }
    }
    
    if(opportunityIdByFeedItem.size() > 0){
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for(Opportunity opp : [Select Id, Name from Opportunity where Id In : opportunityIdByFeedItem.keySet()]){
            FeedItem fi = opportunityIdByFeedItem.get(opp.Id);
            if(fi.Body != null){
                opp.Last_Chatter_Action__c = fi.Body;
            }
            
            DateTime dt = fi.LastModifiedDate;
            Date feedUpdatedDate = date.newinstance(dT.year(), dT.month(), dT.day());
            
            opp.Last_Chatter_Feed_Update__c = feedUpdatedDate;
            
            opportunitiesToUpdate.add(opp);
        }
        
        update opportunitiesToUpdate;
    }
}