({
    handleInit: function(component, event, helper) {
        // Get the URL parameters
        var urlParams = helper.getUrlParameters();
        
        // Access and use the parameters as needed
        var quoteId = urlParams.c__quoteId;
        component.set("v.quoteId", quoteId);
        // Your additional initialization logic here
    }
})