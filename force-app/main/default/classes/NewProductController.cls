public with sharing class NewProductController{
    
    public Product2 newProduct{get;set;}
    public String stadardPrice{get;set;}
    
    public NewProductController(Apexpages.StandardController stdCon){
        newProduct = new Product2();
        newProduct.IsActive = true;
    }
    
    public void insertProduct(){
        
       insert newProduct;
       
    }
    
    
    public PageReference save(){
        
        if(String.isEmpty(stadardPrice)){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error: Standard Price is Required.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        insertProduct();
        
        Pricebook2 pb = [  SELECT id
                  FROM Pricebook2
                  WHERE isStandard=true
                  LIMIT 1
               ];
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pb.Id;
        pbe.IsActive = true;
        pbe.Product2Id = newProduct.Id;
        pbe.UnitPrice =  Decimal.valueOf(stadardPrice);
        insert pbe; 
        
        return RedirectBacktoProductListPage();
                
    }
    
    public PageReference RedirectBacktoProductListPage(){
        PageReference pr = new PageReference('/01t/o');
        pr.setRedirect(true);
        return pr;
    }
    
}