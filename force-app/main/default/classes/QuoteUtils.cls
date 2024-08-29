public with sharing class QuoteUtils {
    
    public static Boolean isActiveFinancialQuote(Id quoteId) {
        List<Opportunity> lstActiveFinancialQuoteOpp = [SELECT Id 
                                                            FROM Opportunity 
                                                            WHERE Active_Financial_Quote__c =:quoteId];
        if(!lstActiveFinancialQuoteOpp.isEmpty()) {
            return true;
        }
        
        return false;
    }

    public static Product_Group__c cloneGroup(Product_Group__c grp) {
        Product_Group__c cloneGroup = new Product_Group__c();
        cloneGroup.Name = grp.Name;
        cloneGroup.Total_Freight__c = grp.Total_Freight__c;
        cloneGroup.Total_Extended_Cost__c = grp.Total_Extended_Cost__c;
        cloneGroup.Total_Line_Items__c = grp.Total_Line_Items__c;
        cloneGroup.Alternate__c = grp.Alternate__c;
        cloneGroup.Quote__c = grp.Quote__c;
        cloneGroup.Is_Section_Closed__c = grp.Is_Section_Closed__c;
        if(grp.Parent_Product_Group__c == null) {
            cloneGroup.Index__c = CartQueryHelper.getTotalGroups(grp.Quote__c) + 1;
        }
        cloneGroup.External_Id__c = generateExternalId();
        return cloneGroup;
    }

    public static Product_Select__c cloneLineItem(Product_Select__c lineItem) {
        Product_Select__c cloneLineItem = new Product_Select__c();
        cloneLineItem.Sale_Type__c = lineItem.Sale_Type__c;
        cloneLineItem.Tag__c = lineItem.Tag__c;
        cloneLineItem.Product_Name__c = lineItem.Product_Name__c;
        cloneLineItem.Original_Product_Name__c = lineItem.Original_Product_Name__c;
        cloneLineItem.Product_Code__c = lineItem.Product_Code__c;
        cloneLineItem.Alternate__c = lineItem.Alternate__c;
        cloneLineItem.Descriptions__c = lineItem.Descriptions__c;
        cloneLineItem.Quantity__c = lineItem.Quantity__c;
        cloneLineItem.List_Price__c = lineItem.List_Price__c;
        cloneLineItem.Multiplier__c = lineItem.Multiplier__c;
        cloneLineItem.Unit_Cost__c = lineItem.Unit_Cost__c;
        cloneLineItem.Freight__c = lineItem.Freight__c;
        cloneLineItem.Extended_Cost__c = lineItem.Extended_Cost__c;
        cloneLineItem.Margin_Percentage__c = lineItem.Margin_Percentage__c;
        cloneLineItem.Sales_Price__c = lineItem.Sales_Price__c;
        cloneLineItem.CR__c = lineItem.CR__c;
        cloneLineItem.Family__c = lineItem.Family__c;
        cloneLineItem.Manufacturer__c = lineItem.Manufacturer__c;
        cloneLineItem.Product_Type__c = lineItem.Product_Type__c;
        cloneLineItem.Is_SalePrice_Override__c = lineItem.Is_SalePrice_Override__c;
        return cloneLineItem;
    }

    public static String generateExternalId(){
        String hashString = Math.round(Math.random()*1000) + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash);
        return hexDigest;
    }

}