trigger OpportunityTrigger on Opportunity (after insert, after update,before insert,before update) {
    Set<Id> opportunityIdsToCreateEvents = new Set<Id>();
    RecordType maRRSType = [select Id,Name from RecordType where sObjectType='Opportunity' AND Name='MaRRS']; 

    if (!Test.isRunningTest() && Trigger.isAfter && Trigger.isInsert && !UtilitySharePointToSFIntegration.quoteBulkInsertContext) {
        Database.executeBatch(new createfolderForOpportunity(trigger.New[0].id));
     
    }
    List<Id> accountIds = new List<Id>();
    Map<String, Id> officeNameToLedgerId = new Map<String, Id>();
    if (Trigger.isBefore) {
        /*
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        if(Trigger.isInsert) {
            // update the ledger value based on office of opportunity
            
            ledgers = [SELECT Id,Name FROM AcctSeed__Ledger__c];

            
            for(AcctSeed__Ledger__c ledger : ledgers) {
                if(ledger.Name.equalsIgnoreCase('Maars Logistics')) {
                    officeNameToLedgerId.put('Maars', ledger.Id);
                    continue;
                }
                if(ledger.Name.equalsIgnoreCase('Engineered Products LLC')) {
                    officeNameToLedgerId.put('Engineered Products', ledger.Id);
                    continue;
                }
                officeNameToLedgerId.put(ledger.Name, ledger.Id);
                
            }
        }
        */
        
        
        
        Map<String,Id> ledgerMap = new Map<String,Id>();
        for (AcctSeed__Ledger__c ledger : [SELECT Name,Id FROM AcctSeed__Ledger__c]) {
            ledgerMap.put(ledger.Name, ledger.Id);
        }
        for (Opportunity opp : Trigger.New) {
            String officeName = opp.Office__c;
            String ledgerName = '';
            
            if(!String.isEmpty(officeName)) {
                if(officeName.equalsIgnoreCase('Engineered Products')) {
                    ledgerName = 'Engineered Products LLC';
                } else if(officeName.equalsIgnoreCase('MaRRs')) {
                    ledgerName = 'MaRRS Logistics';
                } else if(officeName.equalsIgnoreCase('Midwest Machinery KC')) {
                    ledgerName = 'Midwest Machinery KC';
                } else if(officeName.equalsIgnoreCase('Midwest Machinery OK')) {
                    ledgerName = 'Midwest Machinery OK';
                } else if(officeName.equalsIgnoreCase('Midwest Machinery STL')) {
                    ledgerName = 'Midwest Machinery STL';
                } else if(officeName.equalsIgnoreCase('Midwest Industrial Builders')) {
                    ledgerName = 'Midwest Industrial Builders';
                }else if(officeName.equalsIgnoreCase('Spark')) {
                    ledgerName = 'Midwest Machinery STL';
                }
            }

            if(!String.isEmpty(ledgerName)) {
                //List<AcctSeed__Ledger__c> lstLedger = [SELECT ID FROM AcctSeed__Ledger__c WHERE Name =: ledgerName];
                if(!ledgerMap.isEmpty() && ledgerMap.containsKey(ledgerName)) {
                    opp.ledger__c = ledgerMap.get(ledgerName);
                }
            }  

            String currentUserProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            if(Trigger.isUpdate && currentUserProfileName != 'System Administrator' &&
                    opp.RecordTypeId == maRRSType.Id &&
                    Trigger.oldMap.get(opp.Id).AccountId != null &&
                    Trigger.newMap.get(opp.Id).AccountId != Trigger.oldMap.get(opp.Id).AccountId) {
                // opp.addError('Account Can not be updated');
                opp.addError('Account cannot be updated. Please contact system administrator to update account.');
            }
            if(Trigger.isUpdate || Trigger.isInsert) {
            
                opp.Name = opp.Name.remove('\'');
                opp.Name = opp.Name.remove('%');
                opp.Name = opp.Name.remove('*');
            }                                                                                                  
            if (Trigger.isInsert) {
                if(opp.RecordTypeId == maRRSType.Id) {
                    if(opp.AccountId == null) {
                        opp.addError('Account Can not be null');
                    } else {
                        system.debug(opp.Account.Name);
                        accountIds.add(opp.AccountId);
                    }
                } 
                /*
                if(opp.Office__c != null) {
                    opp.Ledger__c = officeNameToLedgerId.get(opp.Office__c);
                }
                */
                //opp.OriginalName__c = opp.Name;
                opp.OriginalName__c =  opp.Name.replaceAll('[^a-zA-Z0-9\\s+]', ' ');

               

                
            }
        } 
        /*if(accountIds.isEmpty() == false) {
            Map<Id, Account> accountList = new Map<Id, Account>([SELECT Id,Name FROM Account WHERE Id IN :accountIds]);
            if(Trigger.isInsert) {
                for (Opportunity opp : Trigger.New) {
                    opp.Sharepoint_Account_Name__c = accountList.get(opp.AccountId).Name.replaceAll('[^a-zA-Z0-9\\s+]', ' ');
                }
            }
        }*/
            
    }
     
    
    if (Trigger.isAfter) {
    
    // We need to assign events to public calendars. If multiple calendars has configured,
    // then ae are not sure which opportunity belongs to which calendar. To identify this,
    // we are using the opportunity owner's role. We have configured custom setting, it will store
    // opportunity owners role as well as public calendar id. To get the opportunity owners role
    // we need to get the owner id's.
    Set<Id> opportunityOwnerIds = new Set<Id>();
    Set<Id> updatedOwnerOpportunityIds = new Set<Id>();
    
    for(Opportunity newOpportunity : trigger.new){
        if(newOpportunity.RecordTypeId == maRRSType.Id) {
            continue;
        } 
        if(trigger.isInsert && newOpportunity.Bid_Date__c != null){
            opportunityIdsToCreateEvents.add(newOpportunity.Id);
            opportunityOwnerIds.add(newOpportunity.OwnerId);
        } else if(trigger.isUpdate){
            Opportunity oldOpportunity = trigger.oldMap.get(newOpportunity.Id);
            
            Boolean isUpdateEvents = false;
            if(oldOpportunity.Bid_Date__c != newOpportunity.Bid_Date__c){
                isUpdateEvents = true;
            } else if(oldOpportunity.OwnerId != newOpportunity.OwnerId){
                isUpdateEvents = true;
                updatedOwnerOpportunityIds.add(newOpportunity.Id);
            }
            
            if(isUpdateEvents){
                opportunityIdsToCreateEvents.add(newOpportunity.Id);
                // Owner Id is required to get the role.
                opportunityOwnerIds.add(oldOpportunity.OwnerId);
                opportunityOwnerIds.add(newOpportunity.OwnerId);
            }
        }
    }
    
    if(!opportunityIdsToCreateEvents.isEmpty()){
        // Get opportunity owner's role along with id's
        Map<Id, String> userIdByRole = new Map<Id, String>();
        for(User user : [Select Id, UserRoleId, UserRole.Name from User where Id In : opportunityOwnerIds]){
            userIdByRole.put(user.Id, user.UserRole.Name);
        }
        
        Map<String, Roles_With_Public_Calendars__c> calendarMap = Roles_With_Public_Calendars__c.getAll();
        
        if(calendarMap != null && !calendarMap.isEmpty()){
            // We need to create new event only if there is no existing event to specific opportunity
            // for the specified calendar id. If event exists then update the start date and end date by using bid date.
            Set<Id> publicCalendarIds = new Set<Id>();
            for(Roles_With_Public_Calendars__c calendar : calendarMap.values()){
                publicCalendarIds.add(calendar.Calendar_Id__c);
            }
            
            // Get existing events for given opportunities
            Map<String, List<Event>> opportunityIdByEvents = new Map<String, List<Event>>();
            for(Event ev : [Select Id, OwnerId, StartDateTime, WhatId from Event where OwnerId In : publicCalendarIds and WhatId In : opportunityIdsToCreateEvents]){
                
                String eventOwnerId = ev.OwnerId;
                if(eventOwnerId.length() > 15){
                    eventOwnerId = eventOwnerId.substring(0, 15);
                }
                
                if(!opportunityIdByEvents.containsKey(ev.WhatId+'~'+eventOwnerId)){
                    opportunityIdByEvents.put(ev.WhatId+'~'+eventOwnerId, new List<Event>());
                }
                
                opportunityIdByEvents.get(ev.WhatId+'~'+eventOwnerId).add(ev);
            }
            
            
            // We need to create new events when opportunity is created.
            // We need to update existing event when bid date is chnaged or opportunity owner is chnaged.
            List<Event> events = new List<Event>();
            List<Event> eventsToDelete = new List<Event>();
            
            for(Id oppId : opportunityIdsToCreateEvents){
                Opportunity newOpportunity = trigger.newMap.get(oppId);
                
                // If Opportunity owner is changed, then we can identify existing events based on old owners role.
                Roles_With_Public_Calendars__c calendarWithOldOpportunityOwnerRole = null;
                if(trigger.isUpdate){
                    Opportunity oldOpportunity = trigger.oldMap.get(oppId);
                    
                    // Get Public Calendar Id from custom setting by using opportunity owner's role.
                    String oldOpportunityOwnersRole = userIdByRole.get(oldOpportunity.OwnerId);
                    
                    calendarWithOldOpportunityOwnerRole = calendarMap.get(oldOpportunityOwnersRole);
                }
                
                // Get Public Calendar Id from custom setting by using opportunity owner's role.
                String newOpportunityOwnersRole = userIdByRole.get(newOpportunity.OwnerId);
                
                Roles_With_Public_Calendars__c calendarWithNewOpportunityOwnerRole = calendarMap.get(newOpportunityOwnersRole);
                
                if((trigger.isUpdate && calendarWithOldOpportunityOwnerRole == null) || calendarWithNewOpportunityOwnerRole == null){
                    continue;
                }
                
                List<Event> existingEvents = null;
                if(trigger.isUpdate){
                    String calendarId = calendarWithOldOpportunityOwnerRole.Calendar_Id__c;
                    if(calendarId != null && calendarId.length() > 15){
                        calendarId = calendarId.substring(0, 15);
                    }
                    
                    existingEvents =  opportunityIdByEvents.get(newOpportunity.Id+'~'+calendarId);
                }
                
                // Salesforce is not allowing to change event owner. Due to that we are deleting existing events 
                // and recrating new events when opportunity owner is changed.
                if(existingEvents != null && !existingEvents.isEmpty() && updatedOwnerOpportunityIds.contains(oppId)){
                    eventsToDelete.addAll(existingEvents);
                }
                
                if(existingEvents != null && !existingEvents.isEmpty() && !updatedOwnerOpportunityIds.contains(oppId)){    // update existing events with new bid date.
                    for(Event ev : existingEvents){
                        ev.StartDateTime = newOpportunity.Bid_Date__c;
                        ev.EndDateTime = newOpportunity.Bid_Date__c;
                        
                        // Assign new opportunity owner's calendar id.
                        ev.OwnerId = calendarWithNewOpportunityOwnerRole.Calendar_Id__c;
                        events.add(ev);
                    }
                } else if(existingEvents == null || !existingEvents.isEmpty() || updatedOwnerOpportunityIds.contains(oppId)){    //Create new events.
                    Event ev = new Event();
                    ev.StartDateTime = newOpportunity.Bid_Date__c;
                    ev.EndDateTime = newOpportunity.Bid_Date__c;
                    ev.WhatId = newOpportunity.Id;
                    ev.OwnerId = calendarWithNewOpportunityOwnerRole.Calendar_Id__c;
                    ev.Subject = 'Bid Due';
                    
                    events.add(ev);
                }
            }
            
            if(eventsToDelete != null && !eventsToDelete.isempty()){
                delete eventsToDelete;
            }
            
            if(events != null && !events.isEmpty()){
                upsert events;
            }
        }
    }
    
    }
    
}