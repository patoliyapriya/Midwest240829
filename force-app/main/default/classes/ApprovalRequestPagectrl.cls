public with sharing class ApprovalRequestPagectrl {

        // Expense types
    public static final String BUILDING_REPAIR_MAINTENENCE = 'Building Repair/Maintenance';
    public static final String CONSTRUCTION_VEHICLE_EXPENSES = 'Construction Vehicles expense/fuel';
    public static final String DONATIONS = 'Donations';
    public static final String EDUCATION_TRAINING = 'Education/Training';
    public static final String ENTERTAINMENT_CUSTOMERS = 'Entertainment w/ Customers';
    public static final String ENTERTAINMENT_EMPLOYEE = 'Entertainment w/Employee';
    public static final String ENTERTAINMENT_VENDORS = 'Entertainment w/Vendors';
    public static final String FUEL = 'Fuel';
    public static final String JOB_RELEATED_MATERIALS = 'Job-Related Materials/Expenses';
    public static final String MARKETING_ADVERTISING = 'Marketing/Advertising';
    public static final String MEALS_CUSTOMERS = 'Meals w/customers';
    public static final String MEAL_EMPLOYEES = 'Meal w/Employees';
    public static final String MEAL_VENDOR = 'Meal w/Vendor';
    public static final String MILEAGE_SALES_EXEC = 'Mileage - Sales Executives';
    public static final String OFFICE_BREAK_ROOM_SUPPLIES = 'Office/Break Room Supplies';
    public static final String OFFICE_EQUIPMENT_COMPUTERS = 'Office Equipment/Computers';
    public static final String PARKING = 'Parking';
    public static final String PERSONAL_CAR_MILEAGE = 'Personal Car Mileage';
    public static final String POSTAGE_SHIPPING = 'Postage/Shipping';
    public static final String PROFESSIONAL_SUB_DUES = 'Professional Subscription/Dues';
    public static final String PROMOTIONAL_SHOWS = 'Promotional shows/Products';
    public static final String PUBLIC_TRANSPORTATION = 'Public Transportation';
    public static final String SEMINAR_COURSE_FEES_CONFERENCE = 'Seminar/Course fees/Conference';
    public static final String TOLLS = 'Tolls';
    public static final String TRAVEL_AIRFARE = 'Travel - Airfare';
    public static final String TRAVEL_CAR_RENTAL = 'Travel - Car Rental';
    public static final String TRAVEL_HOTEL = 'Travel - Hotel';
    public static final String TRAVEL_MEAL = 'Travel - Meal';
    public static final String TRAVEL_MISCELLANEOUS = 'Travel - Miscellaneous';
    public static final String UBER_TAXI = 'Uber/Taxi';
    public static final String ENTERTAINMENT_COMPANY_EVENT = 'Entertainment - Company Event';
    public class applicationException extends Exception {}

    public static Map<String , String> expenseCodeTypeMap = new Map<String, String>{
        BUILDING_REPAIR_MAINTENENCE => '747-01',
        CONSTRUCTION_VEHICLE_EXPENSES => '516-00',
        DONATIONS => '750-01',
        EDUCATION_TRAINING => '625-00',
        ENTERTAINMENT_CUSTOMERS => '611-05',
        ENTERTAINMENT_EMPLOYEE => '611-04',
        ENTERTAINMENT_VENDORS => '611-05',
        FUEL => '516-00',
        JOB_RELEATED_MATERIALS => '451-00',
        MARKETING_ADVERTISING => '620-01',
        MEALS_CUSTOMERS => '611-02',
        MEAL_EMPLOYEES => '611-00',
        MEAL_VENDOR => '611-03',
        MILEAGE_SALES_EXEC => '610-00',
        OFFICE_BREAK_ROOM_SUPPLIES => '730-00',
        OFFICE_EQUIPMENT_COMPUTERS => '171-00',
        PARKING => '612-00',
        PERSONAL_CAR_MILEAGE => '610-00',
        POSTAGE_SHIPPING => '731-00',
        PROFESSIONAL_SUB_DUES => '616-00',
        PROMOTIONAL_SHOWS => '620-04',
        SEMINAR_COURSE_FEES_CONFERENCE => '715-06',
        TOLLS => '612-00',
        TRAVEL_AIRFARE => '612-00',
        TRAVEL_CAR_RENTAL => '612-00',
        TRAVEL_HOTEL => '612-00',
        TRAVEL_MEAL => '612-01',
        TRAVEL_MISCELLANEOUS => '612-00',
        UBER_TAXI => '612-00',
        ENTERTAINMENT_COMPANY_EVENT => '611-06'
    };
    
    @AuraEnabled(cacheable=true)
    public static List<approvalRequestPageWrapper> expenseAccounting(Id recordId){

        ProcessInstanceWorkitem approvalWorkIteam = [SELECT id,Actor.Name,ProcessInstance.TargetObjectId 
                                                        FROM ProcessInstanceWorkitem 
                                                        WHERE id =: recordId];

        List<approvalRequestPageWrapper> lstExpenseAccting = new  List<approvalRequestPageWrapper>(); 

        List<AggregateResult> lstAccountExpense = [SELECT Expense_Type__c, Payment_Type__c,
                                                        SUM(Expense_Amount__c) expenseTotal
                                                        FROM Expense__c
                                                        WHERE Submit_Request__c =:approvalWorkIteam.ProcessInstance.TargetObjectId
                                                        GROUP BY Expense_Type__c, Payment_Type__c
                                                        ORDER BY Expense_Type__c ASC];

        List<AggregateResult> lstMileagetotal =  [SELECT Log_A_Call__r.id,
                                                      AVG(Log_A_Call__r.Mileage_Cost__c) milegeCost 
                                                      FROM Expense__c
                                                      WHERE Submit_Request__c =:approvalWorkIteam.ProcessInstance.TargetObjectId
                                                      GROUP BY Log_A_Call__r.Id];
        if(lstAccountExpense.isEmpty()){
            throw new applicationException('No unsubmitted expense accounting found for the selected month and year.');
        }

        //to convert Expense_type to Expense Accouting code
        Map<String, Decimal> expenseTypeCodeTotalMap = new Map<String, Decimal>();
        // Company Expense Total Line
        approvalRequestPageWrapper objNameWithTotalline = new approvalRequestPageWrapper();
        objNameWithTotalline.expenseTypeCode  = '106-02 Accounts Receivable Employee';
        objNameWithTotalline.credit = 0;

        // Personal Expense + Total MileageCost Total Line
        approvalRequestPageWrapper objPersonalExpMileageCost = new approvalRequestPageWrapper();
        objPersonalExpMileageCost.expenseTypeCode  = ' 205-01 Account Payable';
        objPersonalExpMileageCost.credit = 0;

        //Total Milegecost
        approvalRequestPageWrapper objTotalMileageCost = new approvalRequestPageWrapper();
        objTotalMileageCost.expenseTypeCode  = ' 610-00';
        objTotalMileageCost.debit = 0;

        for(AggregateResult result : lstAccountExpense){
            String expenseType = (string) result.get('Expense_Type__c');
            String paymentType = (string) result.get('Payment_Type__c');
            String expenseTypeCode = expenseCodeTypeMap.get(expenseType);
            
            if(expenseTypeCode != null && expenseTypeCode != '' && result.get('expenseTotal') != null){
                if(expenseTypeCodeTotalMap.containsKey(expenseTypeCode)){
                    Decimal debitTotal = expenseTypeCodeTotalMap.get(expenseTypeCode);
                    debitTotal += (Decimal) result.get('expenseTotal');
                    expenseTypeCodeTotalMap.put(expenseTypeCode, debitTotal);
                }else{
                    expenseTypeCodeTotalMap.put(expenseTypeCode, (Decimal) result.get('expenseTotal'));
                }

                
                if(paymentType  == 'Company Expense'){
                    objNameWithTotalline.credit += (Decimal) result.get('expenseTotal');
                }else{
                    objPersonalExpMileageCost.credit += (Decimal) result.get('expenseTotal');
                }
            }
        }

        for(AggregateResult result : lstMileagetotal){
            objTotalMileageCost.debit += (Decimal) result.get('milegecost');
            objPersonalExpMileageCost.credit += (Decimal) result.get('milegeCost');
         }
        
        for(String expenseCode : expenseTypeCodeTotalMap.keySet()){

            //Accounting => debit, credit
            approvalRequestPageWrapper objAcctCodeWrapper = new approvalRequestPageWrapper();
            objAcctCodeWrapper.expenseTypeCode = expenseCode;
            objAcctCodeWrapper.debit = expenseTypeCodeTotalMap.get(expenseCode);
            lstExpenseAccting.add(objAcctCodeWrapper);
        }
        if(objTotalMileageCost.debit != 0){
            lstExpenseAccting.add(objTotalMileageCost);
        }
        lstExpenseAccting.add(objNameWithTotalline);
        lstExpenseAccting.add(objPersonalExpMileageCost);
        
        return lstExpenseAccting;
    }

    @AuraEnabled(cacheable=true)
    public static List<SubmittedExpenseApproval> submittedExpenseList(Id recordId){

        List<SubmittedExpenseApproval> finalSubmittedExpenseApprovalList = new List<SubmittedExpenseApproval>();

        ProcessInstanceWorkitem approvalWorkIteam = [SELECT id,Actor.Name,ProcessInstance.TargetObjectId,CreatedById  
                                                        FROM ProcessInstanceWorkitem 
                                                        WHERE id =: recordId];

        ProcessInstance lstHistory = [SELECT Id,SubmittedById, 
                                             (SELECT ID, StepStatus, Comments, TargetObjectId,ActorId, CreatedDate, Actor.Name 
                                                FROM StepsAndWorkitems order by CreatedDate)   
                                        FROM ProcessInstance 
                                        WHERE TargetObjectId =:approvalWorkIteam.ProcessInstance.TargetObjectId 
                                        ORDER BY CreatedDate];

        Submit_Request__c submittedApprovals = [SELECT Total_Expense_Amount__c
                                                    FROM Submit_Request__c
                                                    WHERE Id =: approvalWorkIteam.ProcessInstance.TargetObjectId
                                                    AND Total_Expense_Amount__c != null];
        
        if(lstHistory == null){
            throw new applicationException('No history found for this approval request.');
        }

        if(lstHistory != null){

            SubmittedExpenseApproval totalRequest = new SubmittedExpenseApproval();
                totalRequest.approver = 'Total Requested';
                totalRequest.totalExpenseAmount = submittedApprovals.Total_Expense_Amount__c;
            
            for(ProcessInstanceHistory history : lstHistory.StepsAndWorkitems){
                SubmittedExpenseApproval expApproval = new SubmittedExpenseApproval();
                expApproval.approver = history.Actor.Name;
                expApproval.totalExpenseAmount = submittedApprovals.Total_Expense_Amount__c;
                expApproval.submitStatus = history.StepStatus;
                finalSubmittedExpenseApprovalList.add(expApproval);
            }       

            finalSubmittedExpenseApprovalList.add(totalRequest);
            return finalSubmittedExpenseApprovalList;

        }else{
            return null;
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<ApprovalHistoryRecords> getApprovalComments(String recordId){  
        
        ProcessInstanceWorkitem approvalWorkIteam = [SELECT id,ProcessInstance.TargetObjectId  from ProcessInstanceWorkitem where id =: recordId];
        ProcessInstance processInstances = [SELECT Id,SubmittedById, (SELECT ID, StepStatus, Comments, TargetObjectId,ActorId, CreatedDate, Actor.Name 
                                                                        FROM StepsAndWorkitems order by IsPending DESC, CreatedDate DESC )   
                                            FROM ProcessInstance 
                                            WHERE TargetObjectId =:approvalWorkIteam.ProcessInstance.TargetObjectId order by CreatedDate DESC];

        List<ApprovalHistoryRecords> finalResult = new List<ApprovalHistoryRecords>();                                                                   
        for(ProcessInstanceHistory histroryRecord : processInstances.StepsAndWorkitems){
            if(histroryRecord.Comments != null){
                User userRecord = [select id, SmallPhotoUrl from User where id =: histroryRecord.ActorId];
                ApprovalHistoryRecords submitterRecord = new ApprovalHistoryRecords();
                submitterRecord.userName = histroryRecord.Actor.Name;
                submitterRecord.userId = histroryRecord.ActorId;
                submitterRecord.userComment = histroryRecord.Comments;
                submitterRecord.createdDate = histroryRecord.CreatedDate;
                submitterRecord.status = histroryRecord.StepStatus;
                submitterRecord.avtar = userRecord.SmallPhotoUrl;
                finalResult.add(submitterRecord);
            }
        }
        if(finalResult.size() > 0){
            system.debug('final result :- '+finalResult);
            return finalResult;
        }  else {
            return null;
        }                                                         
    }

    public class approvalRequestPageWrapper{
        @AuraEnabled public String expenseTypeCode {get;set;}
        @AuraEnabled public Decimal debit {get;set;}
        @AuraEnabled public Decimal credit {get;set;}
    }
    public class SubmittedExpenseApproval{
        @AuraEnabled public String approver {get;set;}
        @AuraEnabled public Decimal totalExpenseAmount {get;set;}
        @AuraEnabled public String submitStatus {get;set;}
    } 
    public class ApprovalHistoryRecords{
        @AuraEnabled public String userName;
        @AuraEnabled public Id userId;
        @AuraEnabled public string status;
        @AuraEnabled public string avtar;
        @AuraEnabled public string userComment; 
        @AuraEnabled public DateTime createdDate;
    }
}