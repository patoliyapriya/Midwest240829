public with sharing class newProductModalController {

    @AuraEnabled
    public static List<Product2> getproductType(String manufacturer){
        List<Product2> productType = [SELECT Product_Type__c FROM Product2 WHERE Manufacturer__c= :manufacturer];
        System.debug('productType :' + productType);
        return productType;
    }

    @AuraEnabled
    public static void newProductSave(String productDetail){
     Map<String, Object> productMap = (Map<String, Object>) JSON.deserializeUntyped(productDetail);
    
     Product2 newProduct = new Product2();

        newProduct.Name= (String) productMap.get('productName');
        newProduct.ProductCode = (String) productMap.get('ProductCode');
        newProduct.Manufacturer__c = (String) productMap.get('manufacturer');
        newProduct.Product_Type__c = (String) productMap.get('productType');
        newProduct.Description	 = (String) productMap.get('productSummary');
        newProduct.IsActive = (Boolean) productMap.get('isActive');
        newProduct.Product_Description__c = (String) productMap.get('productDescription');

        String productWeightStr = (String) productMap.get('productWeight');
        if (productWeightStr != null) {
            newProduct.Weight__c = Decimal.valueOf(productWeightStr);
        }

        List<Object> midwestOffices = (List<Object>) productMap.get('midwestGroupOffice');
        if (midwestOffices != null && !midwestOffices.isEmpty()) {
            List<String> midwestOfficesStrings = new List<String>();
            for (Object office : midwestOffices) {
                midwestOfficesStrings.add((String) office);
            }
            String midwestOfficesString = String.join(midwestOfficesStrings, ';');
            newProduct.Midwest_Group_Office__c = midwestOfficesString;
        }
        INSERT newProduct;

        Pricebook2 pb = [  SELECT id
                            FROM Pricebook2
                            WHERE isStandard=true
                            LIMIT 1 ];

         PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.IsActive = true;
        pbe.Product2Id = newProduct.Id;
        String standardPriceStr = (String) productMap.get('standardPrice');
        if (standardPriceStr != null) {
            pbe.UnitPrice = Decimal.valueOf(standardPriceStr);
        }
        INSERT pbe;        
    }

}