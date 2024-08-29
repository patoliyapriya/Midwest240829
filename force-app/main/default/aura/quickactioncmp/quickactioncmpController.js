({
    navigateToLC : function(component, event, helper) {
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__RedirectToQuoteTool'
            },
            state: {
                c__quoteId: component.get("v.recordId")
            }
        };
        component.set("v.pageReference", pageReference);
        const navService = component.find('navService');
        const pageRef = component.get('v.pageReference');
        const handleUrl = (url) => {
           
            window.open(url,"_self");
            window.document.title = 'abc';
        };
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageRef).then(handleUrl, handleError);
        window.document.title = 'abc';

    } 
})