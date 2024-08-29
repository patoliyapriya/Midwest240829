public with sharing class AdditionDeductionQueryHelper {
    
    public static List<Addition_Deduction__c> getAdditionDeductionByQuoteId(Id quoteId) {

        List<Addition_Deduction__c> lstAddDeduct = new Query(AdditionDeductionConstant.SOBJECT_NAME).
                                                        selectField(ManagedObject.FIELD_NAME_ID).
                                                        selectField(AdditionDeductionConstant.FIELD_NAME_AMOUNT).
                                                        selectField(AdditionDeductionConstant.FIELD_NAME_PRODUCT_DETAILS).
                                                        selectField(AdditionDeductionConstant.FIELD_NAME_PRODUCT_TYPE).
                                                        lookup(AdditionDeductionConstant.FIELD_NAME_QUOTE, quoteId).
                                                        run();
                                                        System.debug('lstAddDeduct11' + lstAddDeduct);
        return lstAddDeduct;

    }

}