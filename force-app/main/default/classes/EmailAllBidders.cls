global class EmailAllBidders{

    webservice static String SendEmail(Id oppId) { 
        
        String strEmail = '';
        system.debug('oppId---'+oppId);
        List<Bidder_Detail__c> lstBiddersName = [Select Bid_Contact__r.Email From Bidder_Detail__c
                                                WHERE Opportunity__c =: oppId
                                                AND Bid_Contact__c != null
                                                AND Bid_Contact__r.Email != ''
                                                AND Won_Lost_Bidding__c != 'Not Bidding'
                                                AND Won_Lost_Bidding__c != 'Lost'];
        system.debug('oppId---'+lstBiddersName);
        for(Bidder_Detail__c bd : lstBiddersName){
        	if(!strEmail.contains(bd.Bid_Contact__r.Email)){
        		strEmail = strEmail + bd.Bid_Contact__r.Email + ';';
        	}
        }
        
        return strEmail;
        
    }
    
}