trigger EventRelatedToNames on Event (before insert) {  
    List<String> toBeUpdateEvent = new List<String>();
    for(Event evt : trigger.new){
        if(evt.WhatId != null && String.valueOf(evt.WhatId).startsWith('006')){
          toBeUpdateEvent.add(evt.WhatId);
        }
    }
    if(toBeUpdateEvent.size() > 0){
        Map<Id, Opportunity> mapOpp = new Map<Id, Opportunity>([SELECT Name, Opportunity_Number__c FROM Opportunity
                                                                WHERE Id IN : toBeUpdateEvent]);
        if(mapOpp != null && mapOpp.keySet().size() > 0){
            for(Event evt : trigger.new){
                if(evt.WhatId != null && String.valueOf(evt.WhatId).startsWith('006')){
                    Opportunity opp = mapOpp.get(evt.WhatId);
                    evt.Opportunity_Name__c = opp.Name;
                    evt.OpportunityNumber__c  = opp.Opportunity_Number__c;

                    system.debug('Updated opp name for Id: '+evt.WhatId+' to '+evt.Opportunity_Name__c);
                }
            }
        }
    }
}