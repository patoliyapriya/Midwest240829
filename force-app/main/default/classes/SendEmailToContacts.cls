public class SendEmailToContacts{
    
    public List<ContactWrapper> lstContacts{get;set;}
    public Id accountId{get;set;}
    
    public SendEmailToContacts(Apexpages.StandardController stdCon){
        
        accountId = stdCon.getId();
        
        lstContacts = new List<ContactWrapper>();
        
        for(Contact con : [Select Id,Name,Email From Contact Where accountId =: stdCon.getId()]){
        
            lstContacts.add(new ContactWrapper(con,false));
        
        }
        
    }
    
    public PageReference redirectBackToAccount(){
        PageReference pr = new PageReference('/' + accountId);
        pr.setRedirect(true);
        return pr;
    }
    
    public class ContactWrapper{
        
        public Contact contact{get;set;}
        public Boolean isSelect{get;set;}
        
        public ContactWrapper(Contact con, Boolean isSelect){
            this.contact = con;
            this.isSelect = isSelect;
        }
        
    }
    
}