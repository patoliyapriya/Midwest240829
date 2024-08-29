({
    init : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        console.log('JSON'+ JSON.stringify(pageReference));
        component.set("v.quoteId", pageReference.state.quoteid);  
    }
})