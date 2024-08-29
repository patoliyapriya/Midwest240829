// Jonathan Hersh - jhersh@salesforce.com - 9/19/2010
public with sharing class ciuserPhoto {
    public ID uID           { get; set; }
    public integer height   { get; set; }
    public integer width    { get; set; }
    public string photoStr  { get; set; }
    public string photoURL  { get {
        if( photoStr != null )
            return photoStr;
            
        if( photoURL == null )
            photoURL = calcPhotoUrl();
        
        return photoURL;
    } set; }
    
    public ciuserphoto() {}
    
    public string calcphotoURL() {          
        sObject ob;
        
        string obName = ( ('' + uID).substring(0,3) == Schema.sObjectType.User.getKeyPrefix() ? 
            'User' : 'CollaborationGroup' );

        try { 
            ob = Database.query('select id, fullphotourl, smallphotourl '+
            ' from '+ obName +
            ' where id = \''+ uID +'\'' );
        } catch( Exception e ) {}
            
        if( ob == null )
            return '';
            
        if( height > 64 || width > 64 )
            return (string) ob.get('fullphotourl');

        return (string) ob.get('smallphotourl');
    }
    
    public static testmethod void runTest() {
        ciuserPhoto up = new ciuserPhoto();
        up.uID = userinfo.getuserid();
        up.height = 32;
        up.width = 32;
        
        system.assertNotEquals( null, up.photoURL );
    }
}