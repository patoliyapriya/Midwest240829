jQuery.noConflict();
		
		function declineInvite( id ) {
			jQuery('#invite'+ id ).fadeOut();
			
			declineInviteAF( id );
		}
		
		function acceptInvite( id, name, verb ) {
			// Switch invite text.
			jQuery('#invite'+ id ).html('<span class="ui-icon ui-icon-check"></span> '+ verb +' <a class="record" target="_top" href="/'+ id +'">'+ name +'</a>.<br/>');
			
			acceptInviteAF( id );
		}