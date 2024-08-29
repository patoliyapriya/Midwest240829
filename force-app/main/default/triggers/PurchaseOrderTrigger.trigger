trigger PurchaseOrderTrigger on AcctSeedERP__Purchase_Order__c (before insert) {
    
    if(trigger.new[0] != null) {
        system.debug('purchaseorder trigger');
        SystemUtil.generateCustomAutoNumber(trigger.new);

    }
    
    

}