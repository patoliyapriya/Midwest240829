/**
 * This class contains unit tests for validating the behavior of MassUpdateController
 * and triggers.
 */
@isTest
private class MassUpdateSimpleControllerTest {

	@TestSetup
    static void createData(){
		Account acc = new Account(Name='Test Account');
        insert acc;

		List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 1; i <= 30; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 10000,
				AccountId=acc.Id
            );
            opportunities.add(opp);
        }
        insert opportunities;
	}

    static testMethod void singleUpdateTest() {
    	Opportunity o = [Select id From Opportunity Limit 1];
		Account acc = [Select id From Account Limit 1];
    	List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
    	apexpages.currentpage().getparameters().put('id',acc.Id);
    	ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
    	setCtr.setSelected(new Opportunity[]{o});
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
		System.assertEquals(1, controller.getRecordSize());
		
		System.assert(controller.getFieldTypeOptions().size()>1);
		
		system.assertEquals(1, controller.objsToUpdate.size());
		
		String value = '123test';
		controller.fieldName='name';
		controller.valueToUpdate=value;	
		//controller.convertedFieldData = controller.convertUserInputToFieldData();	
		controller.step4();
		controller.step5();
		
		System.assert(o.name==value);
		
	    value ='123';
	    controller.step3();
	    controller.fieldName='amount';
	    controller.valueToUpdate=value;	
	    controller.step4();
	    controller.step5();
	    
	    System.assert(o.amount==decimal.valueOf(value));
	    
/*	    value ='true';
	    controller.fieldName='IsPrivate';
	    controller.step3();
	    controller.valueToUpdate=value;		
	    controller.step4();
	    controller.step5();
	    
	    System.assert(o.IsPrivate); */
	    // make sure no exception from display tips
	    System.assertEquals(controller.getFieldInfoToDisplay()!=null,true);
	    	    
	    value ='2009-4-7';
	    controller.fieldName='CloseDate';
	    controller.valueToUpdate=value;		
	    controller.step4();
	    controller.step5();
	    System.assert(o.CloseDate==Date.valueOf(value));
	    
	    value ='Closed';
	    controller.fieldName='StageName';
	    controller.valueToUpdate=value;		
	    controller.step4();
	    controller.step5();
	    System.assert(o.StageName=='Closed');

		String query = controller.generateQuery(Opportunity.SObjectType, 'AccountId', acc.Id);
		String query2 = controller.generateQuery(Contact.SObjectType, 'AccountId', acc.Id);
		String query3 = controller.generateQuery(Asset.SObjectType, 'AccountId', acc.Id);
		String query4 = controller.generateQuery(Case.SObjectType, 'AccountId', acc.Id);
		String query5 = controller.generateQuery(Campaign.SObjectType, 'AccountId', acc.Id);
		String query6 = controller.generateQuery(Lead.SObjectType, 'AccountId', acc.Id);
		String query7 = controller.generateQuery(Product2.SObjectType, 'AccountId', acc.Id);
		String displayTexField = controller.displayTexField;
		String displayTextArea = controller.displayTextArea;
		String displayCheckBox = controller.displayCheckBox;
		String displayPicklist = controller.displayPicklist;
		List<String> confirmationMessage = controller.confirmationMessage;
		String resultMessage = controller.resultMessage;
    }
    
 /*   static testMethod void massUpdateAsStandardUserTest() {
    	
    	Profile p = [select id from profile where name='Standard User'];
        User u = new User(alias = 'standt', email='standarduser@testorg.com',
          emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
          localesidkey='en_US', profileid = p.Id,
          timezonesidkey='America/Los_Angeles', username='standarduser@test.com');
    	
    	System.runAs(u) {
    	  Opportunity o = new Opportunity();
    	  List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
    	
    	  ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
    	  setCtr.setSelected(new Opportunity[]{o});
          MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
		  System.assertEquals(1, controller.getRecordSize());
		
		  System.assert(controller.getFieldTypeOptions().size()>1);
		
		  system.assertEquals(1, controller.objsToUpdate.size());
		
		  String value = '123test';
		  controller.fieldName='name';
		  controller.valueToUpdate=value;		
		  controller.save();
		
		  System.assert(o.name==value);
		 
    	}
    }  */
    
    static testMethod void linkTest() {
    	Opportunity o = new Opportunity();
    	List<Opportunity> oppList = [SELECT name FROM Opportunity LIMIT 20];
    	
    	ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
    	setCtr.setSelected(new Opportunity[]{o});
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
		
		// verify following exceptions will not cause exception
		System.assert(controller.step1()!=null);
		System.assert(controller.step2()!=null);
        controller.getFieldTypeOptions();
		System.assert(controller.step3()!=null);
		System.assert(controller.step4()!=null);
		System.assert(controller.step5()!=null);
		//System.assert(controller.cancel()!=null);
		
		System.assert(controller.getFieldTypeOptions()!=null);
    }
    
    static testMethod void fieldTest() {
    	
    	List<Opportunity> oppList = new Opportunity[]{};
    	
    	ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.assert(controller.cancel()!=null);
		System.assert(controller.getFieldTypeOptions()==null);
		controller.lexStep1();
		controller.lexStep2();
		controller.lexStep3();
		controller.lexStep4();
		controller.lexStep5();
    }
    
    static testMethod void miscTest() {
    	
    	List<Opportunity> oppList = new Opportunity[]{};
    	Account acc = [Select id From Account Limit 1];
		apexpages.currentpage().getparameters().put('id',acc.Id);
    	ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);

		
		System.assert(controller.getNow(true)!=null);
		System.assert(controller.getNow(false)!=null);
		System.assert(controller.getRecordSize()==0);
		System.assert(controller.getPicklistValues()==null);
		

    }
    /*
    @isTest(SeeAllData=true)
    static void testOpportunityInRelatedList(){
        List<Opportunity> oppList = [SELECT name, AccountId FROM Opportunity LIMIT 20];
        ApexPages.StandardSetController setCtr = new ApexPages.StandardSetController(oppList);
        apexpages.currentpage().getparameters().put('id' , oppList.get(0).AccountId);
        MassUpdateSimpleController controller = new MassUpdateSimpleController(setCtr);
        System.debug('list: ' + oppList);
        
        //System.assert(controller.getFieldTypeOptions().size()>1);
		
		//system.assertEquals(1, controller.objsToUpdate.size());
		
		String value = '123test';
		controller.fieldName='name';
		controller.valueToUpdate=value;	
		//controller.convertedFieldData = controller.convertUserInputToFieldData();	
		controller.lexstep4();
		controller.lexstep5();
		List<Opportunity> selectList = (List<Opportunity>)setCtr.getSelected();
		System.assert(selectList.get(0).name==value);
        System.assert(controller.displayTexField=='true');
		System.assert(controller.displayCheckBox=='false');
        System.assert(controller.displayPicklist=='false');
        System.assert(controller.displayTextArea=='false');
        
         value ='Closed';
        controller.lexstep3();
	    controller.fieldName='StageName';
	    controller.valueToUpdate=value;		
	    controller.lexstep4();
	    controller.lexstep5();
	    System.assert(selectList.get(0).StageName=='Closed');
        System.assert(controller.displayTexField=='false');
		System.assert(controller.displayCheckBox=='false');
        System.assert(controller.displayPicklist=='true');
        System.assert(controller.displayTextArea=='false');
	    
        
    }
    */
}