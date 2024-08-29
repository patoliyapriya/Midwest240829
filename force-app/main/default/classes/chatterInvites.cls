// Jonathan Hersh - jhersh@salesforce.com - 9/3/2010
public with sharing class chatterInvites {  
    // Searching for new records
    public record[] results         { get; set; }
    public string obType            { get; set; }
    public string obName            { get; set; }
    public recordSet[] toFollow     { get; set; }
    public string recID             { get; set; }
    public string recName           { get; set; }
    public integer recordSize       { get; set; }
    
    // Inviting users and groups
    public Task invitee             { get; set; } // using task just for the owner lookup
    public string groupID           { get; set; }
    public string userID            { get; set; }
    public User[] invitees          { get; set; }
    public Set<ID> inviteeIDs       { get; set; }
    public string roleID            { get; set; }
    public string profileID         { get; set; }
    
    public string errMsg            { get; set; }
    public string alertMsg          { get; set; }
    
    // Responding to invitations
    public userInvite[] pInvites    { get; set; }
    public Map<string,string> prefixes = getSobjectPrefixes();
    
    public boolean isTest           { get; set; }
    
    public chatterInvites() {       
        toFollow = new recordSet[] {};
        results = new record[] {};
        obType = 'User';
        invitee = new Task();
        invitees = new User[] {};
        inviteeIDs = new Set<ID> ();
        recordSize = 0;
        isTest = false;
        pInvites = new userInvite[] {};
        alertMsg = '';
        errMsg = '';
    }
    
    // Declines an invite, deleting it from the system.
    public void declineInvite() {
        if( recID == null || recID == '' )
            return;
            
        Chatter_Invite__c[] toDel = [select id
            from Chatter_Invite__c
            where record_id__c = :recID
            and ownerid = :userinfo.getuserid()];
            
        try {
            delete toDel;           
        } catch( Exception e ) {}
        
        // Recalc invites
        calcInvites();
    }
    
    // Accepts an invite (iff we don't already follow it) and deletes it from the system.
    public void acceptInvite() {
        if( recID == null || recID == '' )
            return;
            
        Chatter_Invite__c[] toDel = [select id
            from Chatter_Invite__c
            where record_id__c = :recID
            and ownerid = :userinfo.getuserid()];
            
        // Is this a group we're being asked to join, or a record we're being asked to follow?
        string ob = prefixes.get( recID.substring( 0, 3 ) ).split(':').get(1);
        
        if( ob == 'Chatter Group' ) {
            CollaborationGroupMember[] cgms = [select id
                from CollaborationGroupMember
                where memberid = :userinfo.getuserid()
                and collaborationgroupid = :recID];
                
            if( !cgms.isEmpty() )
                return;
        } else {
            EntitySubscription[] doesFollow = [select id
                from EntitySubscription
                where subscriberid = :userinfo.getuserid()
                and parentid = :recID limit 1000];
                
            if( !doesFollow.isEmpty() )
                return;
        }
            
        try {
            delete toDel;
            
            if( ob == 'Chatter Group' )
                insert new CollaborationGroupMember( memberid = userinfo.getuserid(),
                    collaborationgroupid = recID );
            else
                insert new EntitySubscription( subscriberid = userinfo.getuserid(), parentid = recID );
        } catch( Exception e ) {}
    }
    
    // Calculates invitations for the running user, in the process removing any duplicates
    // as well as invitations for records we already follow or groups we're already members of
    // or invitations to follow ourselves
    public void calcInvites() {
        Chatter_Invite__c[] myInvites = [select id, ownerid, sender__c, record_id__c, sender__r.name
            from Chatter_Invite__c
            where ownerid = :userinfo.getuserid()
            order by sender__r.lastname asc limit :( isTest ? 5 : 1000 )];
        
        Chatter_Invite__c[] toDelete = new Chatter_Invite__c[] {};
        Map<string,Chatter_Invite__c> inviteMap = new Map<string,Chatter_Invite__c> ();
        Map<string,string[]> sObjectMap = new Map<string,string[]> ();
        Map<string,string> sObjectNames = new Map<string,string> ();
        pInvites = new userInvite[] {};
        
        if( myInvites.isEmpty() )
            return;
        
        // Delete duplicate invites as well as invites to follow ourself
        for( Chatter_Invite__c cs : myInvites )
            if( inviteMap.containsKey( cs.record_id__c ) || cs.record_id__c == userinfo.getuserid() )
                toDelete.add( cs ); 
            else        
                inviteMap.put( cs.record_id__c,  cs );
                
        // Delete invites for groups we are already members of
        CollaborationGroupMember[] myGroups = [select id, collaborationgroupid
            from CollaborationGroupMember
            where memberid = :userinfo.getuserid()
            and collaborationgroupid IN :inviteMap.keySet()];
        
        for( CollaborationGroupMember cgm : myGroups )
            if( inviteMap.containsKey( cgm.collaborationgroupid ) ) {
                toDelete.add( inviteMap.get( cgm.collaborationgroupid ) );
                inviteMap.remove( cgm.collaborationgroupid );
            }
        
        // Delete invites for records we already follow
        EntitySubscription[] weFollow = [select id, parentid
            from EntitySubscription
            where subscriberid = :userinfo.getuserid()
            and parentid IN :inviteMap.keySet() limit 1000];
            
        for( EntitySubscription es : weFollow )
            if( inviteMap.containsKey( es.parentid ) ) {
                toDelete.add( inviteMap.get( es.parentid ) );
                inviteMap.remove( es.parentid );
            }
        
        // Group the objects we've been invited to based on sObject type
        for( string oID : inviteMap.keySet() ) {
            // What object is this an invite for?
            if( !prefixes.containsKey( oID.substring( 0, 3 ) ) )
                continue;
                
            string ob = prefixes.get( oID.substring( 0, 3 ) ).split(':').get(0);
            
            if( !sObjectMap.containsKey( ob ) )
                sObjectMap.put( ob, new string[] { oID } );
            else
                sObjectMap.get( ob ).add( oID );            
        }
        
        // Query for all the names of the objects we've been invited to
        for( string sOb : sObjectMap.keySet() ) {
            string[] IDs = sObjectMap.get( sOb );
            
            string query = 'select id, '+ ( sOb == 'Case' ? 'casenumber ' : 'name ' )+
                            'from '+ sOb +
                            ' where id IN :IDs ';
            
            // Only follow active users
            if( sOb == 'User' )
                query += ' and isactive = true and usertype = \'Standard\' ';   
                
            // Only show invites for public groups
            if( sOb == 'CollaborationGroup' )
                query += ' and collaborationtype = \'Public\' ';        
            
            try {               
                sObject[] results = Database.query( query );
                
                for( sObject result : results )
                    sObjectNames.put( string.valueof(result.get('id')), 
                        string.valueof(( sOb == 'Case' ? result.get('casenumber') : result.get('name') )) );
            } catch( Exception e ) {}
        }
        
        // Assemble invites based on the person who sent the invite
        Map<string, recordSet[]> mInvites = new Map<string, recordSet[]> ();
        
        for( Chatter_Invite__c cs : inviteMap.values() ) {
            // What object is this an invite for?
            string ob = prefixes.get( cs.record_id__c.substring( 0, 3 ) ).split(':').get(1);
            
            // Unique ID:Name key
            string key = cs.sender__c + ':' + cs.sender__r.name;
            
            // If we don't have a name for this record, skip it and delete.
            if( !sObjectNames.containsKey( cs.record_id__c ) ) {
                toDelete.add( cs );
                continue;
            }
            
            if( !mInvites.containsKey( key ) ) {
                // Add a new entry for invites from this user
                recordSet[] rs = new recordSet[] {};
                recordSet newRS = new recordSet( ob );
                newRS.records.add( new record( cs.record_id__c, sObjectNames.get( cs.record_id__c ) ) );
                
                rs.add( newRS );
                mInvites.put( key, rs );                
            } else {
                // Do we have invites for this object yet for this user?
                boolean hasOb = false;
                    
                for( recordSet rs : mInvites.get( key ) ) {                 
                    if( rs.obType == ob ) {
                        hasOb = true;
                        rs.records.add( new record( cs.record_id__c, sObjectNames.get( cs.record_id__c ) ) );
                        break;
                    }
                }
                
                if( !hasOb ) {
                    recordSet newRS = new recordSet( ob );
                    newRS.records.add( new record( cs.record_id__c, sObjectNames.get( cs.record_id__c ) ) );
                    
                    recordSet[] existingRS = mInvites.get( key );
                    existingRS.add( newRS );
                    
                    mInvites.put( key, existingRS );
                }
            }
        }
        
        // Sort our invites based on sender.        
        for( string key : mInvites.keySet() ) {
            userInvite ui = new userInvite();
            ui.inviterID = key.split(':').get(0);
            ui.inviterName = key.split(':').get(1);
                
            ui.invites = mInvites.get( key );
            
            pInvites.add( ui );
        }
        
        // Press red button.    
        if( !toDelete.isEmpty() ) {
            try {
                delete toDelete;
            } catch( Exception e ) {}
        }
    }
    
    // Sends an invite for every selected record to every selected user
    // Duplicate invites are handled later, when the user view his invites
    public void sendInvites() {
        if( invitees == null || invitees.isEmpty() || toFollow == null || toFollow.isEmpty() )
            return;
            
        alertMsg = '';
        errMsg = '';
            
        Chatter_Invite__c[] suggests = new Chatter_Invite__c[] {};
        
        for( recordSet rs : toFollow )
            for( record r : rs.records )
                for( User u : invitees )
                    if( r.recID != u.id )
                        suggests.add( new Chatter_Invite__c( sender__c = userinfo.getuserid(),
                            record_id__c = r.recID,
                            ownerid = u.id ) );
                        
        try {
            upsert suggests;
            // Even though we may not send this many due to invites for people to follow themselves, we'll exaggerate
            alertMsg = 'Sent a total of '+ ( invitees.size() * recordSize ) +' invitation' + ( invitees.size() * recordSize != 1 ? 's' : '' ) +
                ' to '+ invitees.size() + ( invitees.size() != 1 ? ' people' : ' person' ) + ' for '+ recordSize +' record'+ ( recordSize != 1 ? 's' : '' ) +
                ( invitees.size() > 1 ? ' each' : '' ) + '.';
                
            // Wipe invitees
            //invitees = new User[] {};
            //inviteeIDs = new Set<ID> ();
        } catch( Exception e ) {
            errMsg = e.getMessage();
        }
    }
    
    // Reset search results
    public void resetSearch() {
        obName = '';
        results = new record[] {};
        errMsg = '';
        alertMsg = '';
    }
    
    // Reset invitees
    public void resetInvitees() {
        invitees = new User[] {};
        inviteeIDs = new Set<ID> ();
    }
    
    // Reset records to follow
    public void resetRecords() {
        toFollow = new recordSet[] {};
        recordSize = 0;
        errMsg = '';
        alertMsg = '';
    }
    
    // Add a new record to the record list
    public void addRecord() {
        if( recID == null || recID == '' || recName == null || recName == '' || obType == null )
            return;
        
        boolean foundType = false;
        
        for( recordSet rs : toFollow )
            if( rs.obType == obType ) {
                // We already have at least one record of this type. Make sure it's not a duplicate
                foundType = true;
                boolean foundRecord = false;
                
                for( record r : rs.records )
                    if( recID == r.recID ) {
                        foundRecord = true;
                        break;
                    }
                    
                if( !foundRecord ) {
                    rs.records.add( new record( recID, recName ) );
                    recordSize++;
                }
                
                break;
            }
            
        if( !foundType ) {
            recordSet rs = new recordSet( obType );
            rs.records.add( new record( recID, recName ) );
            
            recordSize++;
            
            toFollow.add( rs );
        }
    }
    
    // Add this user to our recipient list
    public void addUser() {
        if( invitee.ownerid == null || invitee.ownerid == userinfo.getuserid() )
            return;
            
        if( inviteeIDs.contains( invitee.ownerid ) )
            return;
            
        User[] u = [select id, name, smallphotourl
            from User
            where id = :invitee.ownerid
            and isactive = true];
            
        addUsers( u );
        
        invitee.ownerid = null;
    }
    
    public void addUsers( User[] users ) {
        if( users == null || users.isEmpty() )
            return;
            
        for( User u : users )
            if( !inviteeIDs.contains( u.id ) ) {
                inviteeIDs.add( u.id );
                invitees.add( u );
            }
    }
    
    // Remove a user from the recipient list
    public void removeUser() {
        if( userID == null || userID == '' )
            return;
            
        inviteeIDs.remove( userID );
        
        User[] unew = new User[] {};
        
        for( User u : invitees )
            if( u.id != userID )
                unew.add( u );
                
        invitees = unew;
    }
    
    // Remove a record from the to follow list 
    public void removeRecord() {
        if( recID == null || recID == '' )
            return;
            
        recordSet[] newRS = new recordSet[] {};
        recordSize = 0;
            
        for( recordSet rs : toFollow ) {
            recordSet cloneRS = new recordSet( rs.obType );
            
            for( record r : rs.records )
                if( r.recID != recID ) {
                    cloneRS.records.add( new record( r.recID, r.recName ) );
                    recordSize++;
                }
            
            if( !cloneRS.records.isEmpty() )
                newRS.add( cloneRS );
        }
        
        toFollow = newRS;
    }
    
    // Add all the members of a group to our recipient list
    public void addGroup() {
        if( groupID == null || groupID == '' )
            return;
            
        CollaborationGroupMember[] cgms = [select memberid
            from CollaborationGroupMember
            where collaborationgroupid = :groupID
            and memberid NOT IN :inviteeIDs
            limit :( isTest ? 5 : 1000 )];
            
        ID[] toAdd = new ID[] {};
            
        for( CollaborationGroupMember cgm : cgms ) {
            if( inviteeIDs.contains( cgm.memberid ) || cgm.memberid == Userinfo.getuserid() )
                continue;
                
            toAdd.add( cgm.memberid );
        }
        
        if( toAdd.isEmpty() )
            return;
        
        User[] newUsers = [select id, name, smallphotourl
            from User
            where id IN :toAdd
            and id <> :userinfo.getuserid()
            and isactive = true
            order by lastname asc];
            
        addUsers( newUsers );
    }
    
    // Adds the members of a role to our list
    public void addRole() {
        if( roleID == null || roleID == '' )
            return;
            
        User[] us = [select id, name, smallphotourl
            from User
            where userroleid = :roleID
            and id <> :userinfo.getuserid()
            and id NOT IN :inviteeIDs
            and isactive = true
            limit :( isTest ? 5 : 1000 )];
            
        addUsers( us );     
    }
    
    // Adds the members of a profile to our list
    public void addProfile() {
        if( profileID == null || profileID == '' )
            return;
            
        User[] us = [select id, name, smallphotourl
            from User
            where profileid = :profileID
            and id <> :userinfo.getuserid()
            and id NOT IN :inviteeIDs
            and isactive = true
            limit :( isTest ? 5 : 1000 )];
            
        addUsers( us );     
    }
    
    public void searchRecords() {
        results = new List<record>();
        string sosl;
        
        errMsg = '';
        alertMsg = '';
        
        if( obName == null || obName == '' ) {
            errMsg = 'Please enter a search term.';
            return; 
        }
        
        if( obType == 'Chatter Group' )
            obType = 'CollaborationGroup';
        
        if( obType == 'Case' ) 
            sosl = 'FIND \'' + String.escapeSingleQuotes(obName) + '*\' IN ALL FIELDS RETURNING '+ String.escapeSingleQuotes(obType) + ' (id, CaseNumber, Subject)';
        else {
            sosl = 'FIND \'' + String.escapeSingleQuotes(obName) +
                     '*\' IN ALL FIELDS RETURNING '+ String.escapeSingleQuotes(obType) +
                     ' (id, ' +
                ( obType == 'Solution' ? 'solutionname' : 'name ' );
            
            if( obType == 'User' )
                sosl += ' WHERE isactive=true and usertype=\'Standard\' ';
            else if( obType == 'CollaborationGroup' )
                sosl += ' WHERE collaborationtype=\'Public\' '; 
                    
            sosl += ' )';
        }
            
        try {
            List<List<SObject>> searchresults = Search.query(sosl);
            List<SObject> objectresults = searchresults[0];

            for(SObject so:objectresults) {
                record sr = new record();
                //cases don't have 'Name' fields
                if(obType == 'Case') {
                    sr.recID = (String)so.get('Id');
                    sr.recName = (String)so.get('CaseNumber') + ': ' + (String)so.get('Subject');
                } else {                
                    sr.recID = (String)so.get('Id');
                    sr.recName = (String)so.get('Name');   
                }                 

                results.add(sr);
            }
        }
        catch(Exception ex) {
            errMsg = ex.getMessage();          
        }
        
        if( obType == 'CollaborationGroup' )
            obType = 'Chatter Group';
    }
    
    // Calculate 3-letter prefixes for objects in this org
    // so we can decode IDs that are passed to us
    public Map<string,string> getsObjectPrefixes() {
        Map<string,string> ret = new Map<string,string> ();
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        for( string s : gd.keySet() ) {
            Schema.Sobjecttype ob = gd.get( s );
            Schema.Describesobjectresult sob = ob.getDescribe();
            
            if( sob.getKeyPrefix() == null )
                continue;
                
            if( !sob.isFeedEnabled() )
                continue;
            
            ret.put( sob.getKeyPrefix(), sob.getName() + ':' + sob.getLabel() );
        }
    
        return ret;
    }
  
    // Build a list of all chatter-enabled objects
    public SelectOption[] getChatterObjects() {
        SelectOption[] so = new SelectOption[] {};
        
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Map<string,string> chatterObs = new Map<string,string> ();
    
        for( string s : gd.keySet() ) {
            Schema.Sobjecttype ob = gd.get( s );
            Schema.Describesobjectresult sob = ob.getDescribe();
                
            if( !sob.isFeedEnabled() )
                continue;
    
            chatterObs.put( sob.getLabel(), sob.getName() );
        }
    
        string[] names = new string[] {};
        names.addAll( chatterObs.keySet() );
        names.sort();
    
        for( string s : names )
            so.add( new SelectOption( chatterObs.get(s), s ) );
        
        return so;
  }
  
  // Build a list of my groups
  public SelectOption[] getMyGroups() {
    SelectOption[] so = new SelectOption[] {};
    
    so.add( new SelectOption('','-- Invite one of My Groups --'));
    
    CollaborationGroupMember[] cgms = [select collaborationgroupid, collaborationgroup.name
        from CollaborationGroupMember
        where memberid = :userinfo.getuserid()
        order by collaborationgroup.name asc limit :( isTest ? 5 : 200)];
    
    for( CollaborationGroupMember cgm : cgms )
        so.add( new SelectOption( cgm.collaborationgroupid, cgm.collaborationgroup.name ) );
    
    return so;  
  }
  
  // List of profiles to invites
  public SelectOption[] getProfiles() {
    SelectOption[] so = new SelectOption[] {};
    
    so.add( new SelectOption('','-- Invite a Profile --'));
    
    Profile[] ps = [select id, name
        from Profile
        where usertype = 'Standard'
        order by name asc limit :( isTest ? 5 : 400 )];
    
    for( Profile p : ps )
        so.add( new SelectOption( p.id, p.name ) );
    
    return so;      
  }
  
  // List of profiles to invites
  public SelectOption[] getRoles() {
    SelectOption[] so = new SelectOption[] {};
    
    so.add( new SelectOption('','-- Invite a Role --'));
    
    UserRole[] rs = [select id, name
        from UserRole
        where portaltype = 'None'
        order by name asc limit :( isTest ? 5 : 400)];
    
    for( UserRole r : rs )
        so.add( new SelectOption( r.id, r.name ) );
    
    return so;      
  }
  
  public class userInvite {
    public recordSet[] invites          { get; set; }
    public string inviterID             { get; set; }  
    public string inviterName           { get; set; }   
  }
  
  public class recordSet {
    public string obType                { get; set; }
    public record[] records             { get; set; }
    
    public recordSet( string s ) {
        obType = s;
        records = new record[] {};
    }
  }
  
  public class record {
        public string recID                 { get; set; }
        public string recName               { get; set; }
        
        public record() {}
        public record( string rid, string rname ) {
            recID = rid;
            recName = rname;
        }
  }
  
  public static testmethod void runTest() {
    chatterInvites cs = new chatterInvites();
    cs.isTest = true;
    
    // Static functions
    cs.resetSearch();
    cs.getMyGroups();
    cs.getProfiles();
    cs.getRoles();
    cs.getChatterObjects();
    cs.getsObjectPrefixes();
    cs.resetInvitees();
    cs.resetSearch();
    cs.resetRecords();
    cs.addRole();
    cs.addRecord();
    cs.addUser();
    cs.removeUser();
    cs.removeRecord();
    cs.addGroup();
    cs.addProfile();
    cs.searchRecords();
    cs.sendInvites();
    cs.declineInvite();
    cs.acceptInvite();
    cs.addUsers(new User[]{});
    
    // Search for ourselves
    cs.obName = userinfo.getLastName();
    cs.obType = 'User';
    Test.setFixedSearchResults( new ID[] { userinfo.getuserid() } );
    cs.searchRecords();
    
    system.assertEquals( false, cs.results.isEmpty() );
    
    // Add ourselves to the record list
    cs.recID = userinfo.getuserid();
    cs.recName = userinfo.getName();
    cs.obType = 'User';
    cs.addRecord();
    
    system.assertEquals( 1, cs.recordSize );
    
    // Remove ourselves
    cs.removeRecord();
    
    system.assertEquals( 0, cs.recordSize );
    
    // Add ourselves again
    cs.addRecord();
    
    // Add a new user
    Profile p = [select id from profile where name='Standard User']; 
    UserRole ur = [select Id from UserRole LIMIT 1];
    User u = new User(alias = 'standt', email='standarduser@kwutang.demo', 
                        emailencodingkey='UTF-8', lastname='Testing1', firstname='Testing', languagelocalekey='en_US', 
                        localesidkey='en_US', profileid = p.Id, UserRoleId = ur.Id,
                        timezonesidkey='America/Los_Angeles', username='standarduser@kwutang.demo1');   
        
    try {
        insert u;
    } catch( Exception e ) {}
    
    system.assertNotEquals( null, u.id );
    
    // Invite this user to follow us
    cs.invitee.OwnerId = u.id;
    cs.addUser();
    
    system.assertEquals( 1, cs.invitees.size() );
    
    cs.sendInvites();
    // Remove him again
    cs.userID = u.id;
    cs.removeUser();
    
    system.assertEquals( 0, cs.invitees.size() );
    
    // Add him by profile
    cs.profileID = p.id;
    cs.addProfile();
    
    system.assertEquals( true, cs.invitees.size() > 0 );

    cs.roleID = ur.Id;
    system.assertEquals( true, cs.roleID != null);
    cs.addRole();
    
    // Remove him again
    cs.removeUser();
    Chatter_Invite__c[] css;
    system.runAs( u ) {
    // Add a group that includes him
    CollaborationGroup cg = new CollaborationGroup( name = 'lala', ownerid = u.id, collaborationtype = 'Public' );
    insert cg;
    
    cs.groupID = cg.id;
    cs.addGroup();
    
    //system.assertEquals( true, cs.invitees.size() > 0 );
    
    cs.addRecord();
    // Send the invites
    cs.sendInvites();
    cs.declineInvite();
    
    css = [select id
        from Chatter_Invite__c
        where ownerid = :u.id
        and record_id__c = :userinfo.getuserid()];
        
    //system.assertEquals( true, css.size() > 0 );
    
    // Get his invite
    
        cs.calcInvites();
        
        //system.assertEquals( false, cs.pInvites.isEmpty() );
        
        // Decline the invite
        cs.recID = userinfo.getuserid();
        cs.declineInvite();
        
        css = [select id
            from Chatter_Invite__c
            where ownerid = :u.id
            and record_id__c = :userinfo.getuserid()];
            
        //system.assertEquals( true, css.isEmpty() );
   
    
    // Add the invite back in again
    insert new Chatter_Invite__c( ownerid = u.id,
            record_id__c = userinfo.getuserid(),
            sender__c = userinfo.getuserid() );
    
          
        // Accept the invite
        cs.calcInvites();
        cs.recID = userinfo.getuserid();
        cs.acceptInvite();
        
        css = [select id
            from Chatter_Invite__c
            where ownerid = :u.id
            and record_id__c = :userinfo.getuserid()];
            
        //system.assertEquals( true, css.isEmpty() );

        Profile[] profil = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
			
        User[] adminUser = [SELECT Id, Firstname, Lastname FROM User WHERE IsActive = true and ProfileId =: profil[0].Id LIMIT 1];

        insert new Chatter_Invite__c( ownerid = u.id,
            record_id__c = adminUser[0].Id,
            sender__c = userinfo.getuserid() );

        cs.calcInvites();
        cs.recID = userinfo.getuserid();
        cs.acceptInvite();
    }
  }
}