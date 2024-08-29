public with sharing class GroupWrapper {

    public Product_Group__c grp {get;set;}
    public List<SubGroup> lstSubGroups {get;set;}

    public GroupWrapper() {
        grp = new Product_Group__c();
        grp.Name = '';
        lstSubGroups = new List<SubGroup>(); 
    }

    public GroupWrapper(Product_Group__c grp) {
        this.grp = grp;
        lstSubGroups = new List<SubGroup>();
    }

}