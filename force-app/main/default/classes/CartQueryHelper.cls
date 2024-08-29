public with sharing class CartQueryHelper {
    
    public static Quote getQuote(Id quoteId) {
        system.debug('quoteId in CartQueryHelper=>'+quoteId);
        Quote quote = [SELECT 
                            Id, 
                            Hide_Price_Per__c,
                            Total_Extended_Cost__c,
                            Total_Base_Bid_Total__c,
                            QuoteNumber,Name,
                            Hide_Total_Extended_Cost__c,
                            Hide_Total_Base_Bid_Total__c,
                            Hide_All_Tags__c,
                            Hide_All_Product_Code__c,
                            Commissions_and_Rebates__c,
                            Total_Buy_Resell_Margin__c,
                            Total_Buy_Resell_Margin_Percentage__c,
                            Total_Project_Margin__c,
                            Total_Project_Margin_Percentage__c,
                            Total_Direct_Sell_Price__c,
                            Total_Buy_Resell_Price__c,
                            Total_Buy_Resell_Extended_Cost__c,
                            Quantity_Total__c,
                            Opportunity.Active_Financial_Quote__c,
                            Opportunity.Sync_Quote__c,
                            Attention_to_Account__c,
                            Opportunity.AccountId,
                            Opportunity.Account.Is_Taxable__c,
                            Opportunity.Name,
                            Opportunity.Ledger__c,
                            OpportunityId,
                            Opportunity.Office__c,
                            RecordType.Name    
                    FROM Quote
                    WHERE Id =: quoteId];

        return quote;
    }

    public static List<AcctSeedERP__Sales_Order_Line__c> getAccountingSeedLineItemsForPMTool(Id quoteId) {
        List<AcctSeedERP__Sales_Order_Line__c> lstQuoteLineItems = [SELECT Id,
                                                                        Quote_Line_Item__r.Quantity__c,
                                                                        Quote_Line_Item__r.Product_Code__c,
                                                                        Quote_Line_Item__r.Descriptions__c,
                                                                        AcctSeedERP__Sales_Order__c,
                                                                        Quote_Line_Item__r.Release_Date__c,
                                                                        Quote_Line_Item__r.Payment_Received__c,
                                                                        AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Name,
                                                                        AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.AcctSeedERP__Vendor__c
                                                                        FROM AcctSeedERP__Sales_Order_Line__c
                                                                        WHERE Quote_Line_Item__r.Quote__c =: quoteId];
        
        return lstQuoteLineItems;
    }

    public static Map<Id, Product_Group__c> getSubGroupWithQuoteLineItems(Id quoteId) {
        Map<Id, Product_Group__c> mapParentGroup = new Map<Id, Product_Group__c>([SELECT
                                                                                        Id,
                                                                                        Name,
                                                                                        Parent_Product_Group__r.Name,
                                                                                        Parent_Product_Group__c,
                                                                                        Total_Line_Items__c,
                                                                                        Total_Sub_Groups__c,
                                                                                        Hide_Pricing__c,
                                                                                        Total_Extended_Cost__c,
                                                                                        Hide_Base_Bid_Total__c,
                                                                                        Total_Group_Extended_Cost__c,
                                                                                        Index__c,
                                                                                        Hide_Code__c,
                                                                                        Hide_Amount__c,
                                                                                        Hide_Line__c,
                                                                                        Quantity_Total__c,
                                                                                        Grand_Quantity_Total__c,
                                                                                        Hide_Quantity__c,
                                                                                        Release_Number__c,
                                                                                        Total_Freight__c,
                                                                                        Total_Group_Freight__c,
                                                                                        Page_Break__c,Alternate__c, 
                                                                                        Is_Section_Closed__c,
                                                                                            (SELECT 
                                                                                                Id,
                                                                                                Descriptions__c,
                                                                                                Family__c,
                                                                                                Freight__c,
                                                                                                List_Price__c,
                                                                                                Margin_Percentage__c,
                                                                                                Multiplier__c,
                                                                                                Original_Product_Name__c,
                                                                                                Product_Code__c,
                                                                                                Product_Group__c,
                                                                                                Product_Name__c,
                                                                                                Quantity__c,
                                                                                                Quote__c,
                                                                                                Sales_Price__c,
                                                                                                Total_Price__c,
                                                                                                T_LBS__c,
                                                                                                LBS__c,
                                                                                                Tag__c,
                                                                                                Extended_Cost__c,
                                                                                                Hide_Pricing__c,
                                                                                                Hide_Line__c,
                                                                                                Unit_Cost__c,
                                                                                                Hide_Code__c,
                                                                                                Row_Index__c,
                                                                                                Unique_Index__c,
                                                                                                Page_Break__c,
                                                                                                Alternate__c,
                                                                                                Is_Freight_Override__c,
                                                                                                Release_pick__c,
                                                                                                Sale_Type__c,CR__c,
                                                                                                Hide_Quantity__c,
                                                                                                Manufacturer__c,
                                                                                                Is_SalePrice_Override__c,
                                                                                                Product_Type__c,
                                                                                                ProductId__c,
                                                                                                Submittals__c,
                                                                                                Hide_Line_On_Email_Startup__c,
                                                                                                Serial_Number__c,
                                                                                                IOM_Completed__c,
                                                                                                Schedule_Startup_Date__c,
                                                                                                Completed_Startup_Date__c,
                                                                                                Warranty_Term__c,
                                                                                                Warranty_Type__c,
                                                                                                Warranty_Parts_Covered__c,
                                                                                                Warranty_Start_Date__c,
                                                                                                Warranty_End_Date__c,
                                                                                                SalesOrderId__c,
                                                                                                SalesOrderId__r.Name,
                                                                                                SalesOrderId__r.Sales_Order_Number__c,
                                                                                                Payment_Received__c,
                                                                                                Description__c,
                                                                                                Release_Date__c,
                                                                                                Estimated_Ship_Date__c,
                                                                                                Act_Ship__c,
                                                                                                Tracking_Number__c,
                                                                                                Note__c,
                                                                                                Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__c,
                                                                                                Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Name,
                                                                                                Sales_Order_Line__r.AcctSeedERP__Purchase_Order_Line__r.AcctSeedERP__Purchase_Order__r.Purchase_Order_Number__c
                                                                                            FROM Quote_Line_Items__r
                                                                                            ORDER BY Row_Index__c ASC)
                                                                                    FROM Product_Group__c 
                                                                                    WHERE Quote__c =: quoteId
                                                                                    AND Parent_Product_Group__c != null
                                                                                    ORDER BY Parent_Product_Group__c,Index__c ASC]);
    
        return mapParentGroup;
    }

    public static Map<Id, Product_Group__c> getParentGroups(Id quoteId) {
        Map<Id, Product_Group__c> mapParentGroup = new Map<Id, Product_Group__c>([SELECT 
                                                                                    Id,
                                                                                    Name,
                                                                                    Total_Line_Items__c,
                                                                                    Total_Sub_Groups__c,
                                                                                    Hide_Pricing__c,
                                                                                    Total_Extended_Cost__c,
                                                                                    Hide_Base_Bid_Total__c,
                                                                                    Total_Group_Extended_Cost__c,
                                                                                    Index__c,
                                                                                    Grand_Quantity_Total__c,
                                                                                    Total_Group_Freight__c,
                                                                                    Page_Break__c,
                                                                                    Alternate__c,
                                                                                    Is_Section_Closed__c,
                                                                                    (SELECT 
                                                                                        Id,
                                                                                        Name,
                                                                                        Parent_Product_Group__r.Name,
                                                                                        Parent_Product_Group__c,
                                                                                        Total_Line_Items__c,
                                                                                        Total_Sub_Groups__c,
                                                                                        Hide_Pricing__c,
                                                                                        Total_Extended_Cost__c,
                                                                                        Hide_Base_Bid_Total__c,
                                                                                        Total_Group_Extended_Cost__c,
                                                                                        Index__c,
                                                                                        Hide_Code__c,
                                                                                        Hide_Amount__c,
                                                                                        Hide_Line__c,
                                                                                        Quantity_Total__c,
                                                                                        Grand_Quantity_Total__c,
                                                                                        Hide_Quantity__c,
                                                                                        Release_Number__c,
                                                                                        Total_Freight__c,
                                                                                        Total_Group_Freight__c,
                                                                                        Page_Break__c,Alternate__c, 
                                                                                        Is_Section_Closed__c
                                                                                    FROM ProductGroups__r
                                                                                    ORDER BY Index__c ASC)
                                                                                FROM Product_Group__c
                                                                                WHERE Quote__c =: quoteId
                                                                                AND Parent_Product_Group__c = NULL
                                                                                ORDER BY Index__c ASC]);

        return mapParentGroup;
    }

    public static Opportunity getOpportunity(Id quoteId) {
        Opportunity opp = [SELECT 
                                Id,
                                Total_Base_Bid_Total_Quote__c,
                                Total_Extended_Cost_Quote__c,
                                Total_Project_Margin__c
                            FROM Opportunity
                            WHERE Sync_Quote__c =: quoteId
                            LIMIT 1];
        return opp;
    }

    public static List<Product_Group__c> getGroupsAndSubGroups(Id quoteId) {
        List<Product_Group__c> lstGroupsAndSubGroups = [SELECT 
                                                            Id,
                                                            Index__c,
                                                            Unique_Index__c,
                                                            (SELECT Id,
                                                                    Index__c,
                                                                    Unique_Index__c
                                                            FROM ProductGroups__r)
                                                        FROM Product_Group__c
                                                        WHERE Quote__c =:quoteId];
        return lstGroupsAndSubGroups;
    }

    public static Integer getTotalGroups(Id quoteId) {
        AggregateResult totalGroups = [SELECT count(Id) cnt
                                        FROM Product_Group__c 
                                        WHERE Quote__c =:quoteId 
                                        AND Parent_Product_Group__c = NULL];
        return (Integer)totalGroups.get('cnt');
    }

    public static Integer getTotalSubGroups(Id groupId) {
        AggregateResult totalSubGroups = [SELECT count(Id) cnt
                                            FROM Product_Group__c 
                                            WHERE Parent_Product_Group__c =:groupId];
        return (Integer)totalSubGroups.get('cnt');
    }
    
    public static Product_Group__c getGroupToClone(Id groupId) {
        Product_Group__c grp = [SELECT
                                    Id,
                                    Name,
                                    Total_Freight__c,
                                    Total_Extended_Cost__c,
                                    Total_Line_Items__c,
                                    Parent_Product_Group__c,
                                    Alternate__c,
                                    Index__c,
                                    Unique_Index__c,
                                    Quote__c,
                                    Is_Section_Closed__c
                                FROM Product_Group__c
                                WHERE Id =: groupId];
        return grp;
    }

    public static Product_Group__c getSubGroupToClone(Id subGroupId) {
        Product_Group__c subGroup = [SELECT
                                        Id,
                                        Name,
                                        Total_Freight__c,
                                        Total_Extended_Cost__c,
                                        Total_Line_Items__c,
                                        Alternate__c,
                                        Parent_Product_Group__c,
                                        Index__c,
                                        Unique_Index__c,
                                        Quote__c,
                                        Is_Section_Closed__c,
                                        (SELECT 
                                            Id,
                                            Sale_Type__c,
                                            Tag__c,
                                            Product_Name__c,
                                            Original_Product_Name__c,
                                            Product_Code__c,
                                            Alternate__c,
                                            Descriptions__c,
                                            Quantity__c,
                                            List_Price__c,
                                            Multiplier__c,
                                            Unit_Cost__c,
                                            Freight__c,
                                            Extended_Cost__c,
                                            Margin_Percentage__c,
                                            Sales_Price__c,
                                            CR__c,
                                            Family__c,
                                            Manufacturer__c,
                                            Product_Type__c,
                                            Row_Index__c,
                                            Unique_Index__c,
                                            Is_SalePrice_Override__c
                                        FROM Quote_Line_Items__r)
                                    FROM Product_Group__c
                                    WHERE Id =:subGroupId];
        return subGroup;
    }

    public static List<Product_Group__c> getGroupsToReOrder(Integer groupIndex) {
        List<Product_Group__c> lstGroupsToReOrder = [SELECT
                                                            Id,
                                                            Index__c,
                                                            Unique_Index__c
                                                        FROM Product_Group__c
                                                        WHERE Index__c > :groupIndex
                                                        AND Parent_Product_Group__c = NULL];
        return lstGroupsToReOrder;
    }

    public static List<Product_Select__c> getLineItemsToReOrder(Id subGroupId, Integer lineItemIndex) {
        List<Product_Select__c> lstLineItemsToReOrder = [SELECT
                                                            Id,
                                                            Row_Index__c,
                                                            Unique_Index__c
                                                        FROM Product_Select__c
                                                        WHERE Row_Index__c > :lineItemIndex
                                                        And Product_Group__c =: subGroupId];
        return lstLineItemsToReOrder;
    }

    public static List<Product_Select__c> getLineItemsToReOrder(Id subGroupId, Id lineItemId) {
        List<Product_Select__c> lstLineItemsToReOrder = [SELECT
                                                            Id,
                                                            Row_Index__c,
                                                            Unique_Index__c
                                                        FROM Product_Select__c
                                                        WHERE Id !=: lineItemId
                                                        And Product_Group__c =: subGroupId];
        return lstLineItemsToReOrder;
    }

    public static List<Product_Group__c> getSubGroupsToReOrder(Id groupId, Integer subGroupIndex) {
        List<Product_Group__c> lstSubGroupsToReOrder = [SELECT
                                                            Id,
                                                            Index__c
                                                        FROM Product_Group__c
                                                        WHERE Index__c > :subGroupIndex
                                                        And Parent_Product_Group__c =: groupId];
        return lstSubGroupsToReOrder;
    }

    public static List<Product_Group__c> getSubGroupsToReOrder(Id groupId, Id subGroupId) {
        List<Product_Group__c> lstSubGroupsToReOrder = [SELECT
                                                            Id,
                                                            Index__c
                                                        FROM Product_Group__c
                                                        WHERE Id !=: subGroupId
                                                        And Parent_Product_Group__c =: groupId];
        return lstSubGroupsToReOrder;
    }

    public static List<Product_Group__c> getGroupsToReOrder(Id groupId, Id quoteId) {
        List<Product_Group__c> lstGroupsToReOrder = [SELECT
                                                            Id,
                                                            Index__c
                                                        FROM Product_Group__c
                                                        WHERE Id !=: groupId
                                                        And Quote__c =: quoteId];
        return lstGroupsToReOrder;
    }

    public static List<Product_Group__c> getSubGroupsToClone(Id groupId) {
        List<Product_Group__c> lstSubGroups = [SELECT
                                                    Id,
                                                    Name,
                                                    Total_Freight__c,
                                                    Total_Extended_Cost__c,
                                                    Total_Line_Items__c,
                                                    Alternate__c,
                                                    Parent_Product_Group__c,
                                                    Quote__c,
                                                    Is_Section_Closed__c,
                                                    (SELECT 
                                                        Id,
                                                        Sale_Type__c,
                                                        Tag__c,
                                                        Product_Name__c,
                                                        Original_Product_Name__c,
                                                        Product_Code__c,
                                                        Alternate__c,
                                                        Descriptions__c,
                                                        Quantity__c,
                                                        List_Price__c,
                                                        Multiplier__c,
                                                        Unit_Cost__c,
                                                        Freight__c,
                                                        Extended_Cost__c,
                                                        Margin_Percentage__c,
                                                        Sales_Price__c,
                                                        CR__c,
                                                        Family__c,
                                                        Manufacturer__c,
                                                        Product_Type__c,
                                                        Row_Index__c,
                                                        Unique_Index__c,
                                                        Is_SalePrice_Override__c
                                                    FROM Quote_Line_Items__r)
                                                FROM Product_Group__c
                                                WHERE Parent_Product_Group__c =: groupId];
    
        return lstSubGroups;
    }

    public static Product_Select__c getLineItemToClone(Id lineItemId) {
        Product_Select__c lineItem = [SELECT 
                                            Id,
                                            Sale_Type__c,
                                            Tag__c,
                                            Product_Name__c,
                                            Original_Product_Name__c,
                                            Product_Code__c,
                                            Alternate__c,
                                            Descriptions__c,
                                            Quantity__c,
                                            List_Price__c,
                                            Multiplier__c,
                                            Unit_Cost__c,
                                            Freight__c,
                                            Extended_Cost__c,
                                            Margin_Percentage__c,
                                            Sales_Price__c,
                                            CR__c,
                                            Family__c,
                                            Manufacturer__c,
                                            Product_Type__c,
                                            Row_Index__c,
                                            Unique_Index__c,
                                            Is_SalePrice_Override__c
                                        FROM Product_Select__c
                                        WHERE Id =: lineItemId];
        return lineItem;
    }

    public static Integer getTotalLineItems(Id subGroupId) {
        AggregateResult totalLineItems = [SELECT count(Id) cnt 
                                            FROM Product_Select__c 
                                            WHERE Product_Group__c =: subGroupId];
        return (Integer) totalLineItems.get('cnt');
    }

    
}