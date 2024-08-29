({
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        if(pageReference && pageReference.state.c__quoteId){
            component.set("v.quoteId", pageReference.state.c__quoteId);
        }
    }
})