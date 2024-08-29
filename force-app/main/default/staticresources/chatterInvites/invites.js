jQuery.noConflict();
		
		var otype;
		
		function setFocusOnLoad() {}
		
		function setupAccordion() {
			jQuery('#acc').accordion({ header: 'p', autoHeight: false }); 
		}
		
		function addRecord( id, name, type ) {
			addRecordAF( id, name );
			
			otype = type;

			if( type != '' )
				setTimeout("jQuery('#acc"+ type + "').click();", 700 );
		}
		
		function closeUser( id ) {
			jQuery('#user'+ id ).fadeOut();
			
			removeUserAF( id );
		}
		
		function closeRecord( id ) {
			jQuery('#record'+ id ).fadeOut();
			
			removeRecordAF( id );
		}
		
		function noenter(ev,type)  {
		   	if (window.event && window.event.keyCode == 13 || ev.which == 13) {
		   		if( type == 'search' )
		   			searchRecordsAF();
		   		else if( type == 'addUser' )
		   			addUserAF();
		   			
		       	return false;
		     } else {
		          return true;
		     }
		}