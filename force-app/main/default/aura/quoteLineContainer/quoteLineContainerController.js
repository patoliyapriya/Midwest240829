({
    doInit : function(component, event, helper) {
        console.log(component.get("v.pageReference").state.quoteid);
        component.set("v.quoteId", component.get("v.pageReference").state.quoteid);
    },
    onPageReferenceChanged: function(cmp, event, helper){
        $A.get ('e.force:refreshView').fire ();
    }
})