public with sharing class SharePointIntermidiateController {
    public Id opportunityId {get;set;}
    public String type = '';
     
    public SharePointIntermidiateController () {
       opportunityId = apexpages.currentpage().getparameters().get('id');
       type = apexpages.currentpage().getparameters().get('type');
       
    }
    
    
    public SharePointIntermidiateController (ApexPages.StandardController controller) {
        //opportunityId = controller.getId();
    }
    
    public PageReference openSharepointFolder() {
        if(type == 'createFolder') {
            sharePointPageUrl.createFolderInSharepoint(opportunityId);
            String url = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Opportunity/'+opportunityId+'/view?0.source=alohaHeader';
            PageReference pageRef = new PageReference(url);
            pageRef.setRedirect(true);
            
            return pageRef;
        } else {
            String sharePointFolderURL = sharePointPageUrl.fetchSharePointPageUrl(opportunityId );
            PageReference pageRef = new PageReference(sharePointFolderURL);
            pageRef.setRedirect(true);
            
            return pageRef;
        }

    }
}