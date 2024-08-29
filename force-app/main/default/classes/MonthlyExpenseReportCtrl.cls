public with sharing class MonthlyExpenseReportCtrl {

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

   public static Date startDate;
   public static Date  endDate;
   public static String currentUserName {get;set;}

//Expense Accouting code map
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
   //  TRAVEL_MEAL => '612-01',
    TRAVEL_MEAL => '612-00',
    TRAVEL_MISCELLANEOUS => '612-00',
    UBER_TAXI => '612-00',
    ENTERTAINMENT_COMPANY_EVENT => '611-06'
};

public static Map<String, Integer> monthToNumberMap = new Map<String, Integer>{
   'January' => 1,
   'February' => 2,
   'March' => 3,
   'April' => 4,
   'May' => 5,
   'June' => 6,
   'July' => 7,
   'August' => 8,
   'September' => 9,
   'October' => 10,
   'November' => 11,
   'December' => 12
};

    public MonthlyExpenseReportCtrl() {

    }

    //Default current month full name
    @AuraEnabled(cacheable=true)
    public static String getCurrentMonth(){
       DateTime today = DateTime.now();
       return today.format('MMMM');
    }
    // Default current Year
    @AuraEnabled(cacheable=true)
    public static String getCurrentYear(){
       DateTime today = DateTime.now();
       return today.format('YYYY');
    }

    @AuraEnabled
    public static List<expenseMonthlyReportWrapper> getAllExpensemonthlyReport(String month, String year){
      startDate = null;
      endDate = null;
      if(month == 'All'){
         startDate = Date.newInstance(Integer.valueOf(year), 01, 01);
         endDate = Date.newInstance(Integer.valueOf(year), 12, 31);
      }else{
         startDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month), 01);
         endDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month) + 1, 01);
      }
      
      List<Expense__c> listExpenseMonthly = [SELECT Id,Log_A_Call__c, Expense_Date__c, Log_A_Call__r.Name, 
                                                      Log_A_Call__r.Account_Names__c, Log_A_Call__r.Contact_Names__c,
                                                      Log_A_Call__r.Relationship__c, Log_A_Call__r.Comments__c,
                                                      Log_A_Call__r.Opportunity__r.Opportunity_Number__c,
                                                      Log_A_Call__r.Type_of_Call__c,Expense_Type__c, Expense_Amount__c,
                                                      Payment_Type__c, Log_A_Call__r.Mileage_Traveled__c,
                                                      Log_A_Call__r.Mileage_Type__c,Log_A_Call__r.Mileage_Cost__c,Total_Cost__c 
                                             FROM Expense__c
                                             WHERE Log_A_Call__r.OwnerId =: UserInfo.getUserId()
                                             AND Expense_Date__c >= :startDate
                                             AND Expense_Date__c < :endDate
                                             AND Submit_Request__c = null 
                                             ORDER BY Expense_Date__c];
      
      if(listExpenseMonthly.isEmpty()){
         // throw error
         throw new applicationException('No unsubmitted expense found for the selected month and year.');
      }
      List<expenseMonthlyReportWrapper> lstExpMonthlyRptWrapper  = new  List<expenseMonthlyReportWrapper>();
      //grand total for expense Amount , mileage cost, totalcost..
      expenseMonthlyReportWrapper totalLine = new expenseMonthlyReportWrapper();
      totalLine.expenseAmount = 0;
      totalLine.mileageTraveled = 0;
      totalLine.mileageCost = 0;
      totalLine.totalCost = 0;

      //To avoid duplicate records
      Map<Id,Decimal> mapOfMileage = new Map<Id,Decimal>();
      set<Id> setForMileage = new set<Id>();
      set<Id> setForMileageCost = new Set<Id>();
      set<Id> setForTotalCost = new Set<Id>();

      for(Expense__c exp : listExpenseMonthly) {

         expenseMonthlyReportWrapper objExpMonRptWrapper = new expenseMonthlyReportWrapper();
         objExpMonRptWrapper.id = exp.Id;
         objExpMonRptWrapper.typeOfCall = exp.Log_A_Call__r.Type_of_Call__c;
         objExpMonRptWrapper.expenseDate = exp.Expense_Date__c;
         objExpMonRptWrapper.logACallName = exp.Log_A_Call__r.Name;
         objExpMonRptWrapper.logACallURL = exp.Log_A_Call__c;
         objExpMonRptWrapper.accountNames = exp.Log_A_Call__r.Account_Names__c;
         objExpMonRptWrapper.contactNames = exp.Log_A_Call__r.Contact_Names__c;
         objExpMonRptWrapper.relationship = exp.Log_A_Call__r.Relationship__c;
         objExpMonRptWrapper.comments = exp.Log_A_Call__r.Comments__c;
         objExpMonRptWrapper.opportunityId = exp.Log_A_Call__r.Opportunity__r.Opportunity_Number__c;
         objExpMonRptWrapper.typeOfCall = exp.Log_A_Call__r.Type_of_Call__c;
         objExpMonRptWrapper.expenseType = exp.Expense_Type__c;
         objExpMonRptWrapper.mileageType = exp.Log_A_Call__r.Mileage_Type__c;
         objExpMonRptWrapper.paymentType = exp.Payment_Type__c;

         objExpMonRptWrapper.expenseAmount = exp.Expense_Amount__c;
         if(objExpMonRptWrapper.expenseAmount != null){
            totalLine.expenseAmount += objExpMonRptWrapper.expenseAmount;
         }

         if(!setForMileage.contains(exp.Log_A_Call__c) && exp.Log_A_Call__r.Mileage_Traveled__c != null){
            objExpMonRptWrapper.mileageTraveled = exp.Log_A_Call__r.Mileage_Traveled__c;
            setForMileage.add(exp.Log_A_Call__c);
            totalLine.mileageTraveled += objExpMonRptWrapper.mileageTraveled;
         }
         // if(objExpMonRptWrapper.mileageTraveled != null){
         // //   totalLine.mileageTraveled += objExpMonRptWrapper.mileageTraveled;
         //    mapOfMileage.put(exp.Log_A_Call__c,exp.Log_A_Call__r.Mileage_Traveled__c);
         // }
         
         if(exp.Log_A_Call__r.Mileage_Cost__c != null && exp.Log_A_Call__r.Mileage_Cost__c != 0){
            if(!setForMileageCost.contains(exp.Log_A_Call__c)){
               objExpMonRptWrapper.mileageCost = exp.Log_A_Call__r.Mileage_Cost__c;
               setForMileageCost.add(exp.Log_A_Call__c);
            }
            if(objExpMonRptWrapper.mileageCost != null){
               totalLine.mileageCost += objExpMonRptWrapper.mileageCost;
            }
         }

         if(exp.Total_Cost__c != null && exp.Total_Cost__c != 0){
            // objExpMonRptWrapper.totalCost = exp.Total_Cost__c;
            if(!setForTotalCost.contains(exp.Log_A_Call__c) && exp.Expense_Amount__c != null && objExpMonRptWrapper.mileageCost != null){
               objExpMonRptWrapper.totalCost = exp.Expense_Amount__c + objExpMonRptWrapper.mileageCost;
               setForTotalCost.add(exp.Log_A_Call__c);
            } else if (exp.Expense_Amount__c != null) {
               objExpMonRptWrapper.totalCost = exp.Expense_Amount__c;
            }
            if(objExpMonRptWrapper.totalCost != null){
               totalLine.totalCost += objExpMonRptWrapper.totalCost;
            }
         }

         //accounting code  for Expense Type custom data 
         if(objExpMonRptWrapper.expenseType != null){
            objExpMonRptWrapper.expenseTypeCode = expenseCodeTypeMap.get(objExpMonRptWrapper.expenseType);
         }

         lstExpMonthlyRptWrapper.add(objExpMonRptWrapper);  
      }  
         //addeding totaline to wrapper list
      // for(Id key: mapOfMileage.keySet()){
      //    totalLine.mileageTraveled += mapOfMileage.get(key);
      // } 
      lstExpMonthlyRptWrapper.add(totalLine); 
      return lstExpMonthlyRptWrapper;   
    }

    @AuraEnabled
    public static List<expenseMonthlyReportWrapper> getExpenseAccounting(String month, String year){   

      startDate = null;
      endDate = null;
      if(month == 'All'){
         startDate = Date.newInstance(Integer.valueOf(year), 01, 01);
         endDate = Date.newInstance(Integer.valueOf(year), 12, 31);
      }else{
         startDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month), 01);
         endDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month) + 1, 01);
      }

         //Expense Accounting code 
         List<expenseMonthlyReportWrapper> lstExpenseAccting = new  List<expenseMonthlyReportWrapper>(); 
         
         List<AggregateResult> lstAccountExpense =  [SELECT Expense_Type__c, Payment_Type__c,
                                                     SUM(Expense_Amount__c) expenseTotal
                                                     FROM Expense__c
                                                     WHERE Log_A_Call__r.OwnerId =: UserInfo.getUserId()
                                                     AND Expense_Date__c >= :startDate
                                                     AND Expense_Date__c < :endDate
                                                     AND Submit_Request__c = null 
                                                     GROUP BY Expense_Type__c, Payment_Type__c
                                                     ORDER BY Expense_Type__c ASC];

          List<AggregateResult> lstMileagetotal =  [SELECT Log_A_Call__r.id,
                                                      AVG(Log_A_Call__r.Mileage_Cost__c) milegeCost 
                                                      FROM Expense__c
                                                      WHERE Log_A_Call__r.OwnerId =: UserInfo.getUserId()
                                                      AND Expense_Date__c >= :startDate
                                                      AND Expense_Date__c < :endDate
                                                      AND Submit_Request__c = null 
                                                      GROUP BY Log_A_Call__r.Id];
         
         if(lstAccountExpense.isEmpty()){
            throw new applicationException('No unsubmitted expense accounting found for the selected month and year.');
         }

              //to convert Expense_type to Expense Accouting code
              Map<String, Decimal> expenseTypeCodeTotalMap = new Map<String, Decimal>();
              // 106-02 Company Expense Total Line
              expenseMonthlyReportWrapper objNameWithTotalline = new expenseMonthlyReportWrapper();
              objNameWithTotalline.expenseTypeCode  = '106-02 Accounts Receivable Employee';
              objNameWithTotalline.credit = 0;

              //205-01 Personal Expense + Total MileageCost 
              //from lstAccountExpense(exp amt) + from lstMileagetotal (mile cost)
              expenseMonthlyReportWrapper objPersonalExpMileageCost = new expenseMonthlyReportWrapper();
              objPersonalExpMileageCost.expenseTypeCode  = ' 205-01 Account Payable';
              objPersonalExpMileageCost.credit = 0;

              //610-00 Total Mileagecost line
              expenseMonthlyReportWrapper objTotalMileageCost = new expenseMonthlyReportWrapper();
              objTotalMileageCost.expenseTypeCode  = ' 610-00';
              objTotalMileageCost.debit = 0;

              for(AggregateResult result : lstAccountExpense){
                  String expenseType = (string) result.get('Expense_Type__c');
                  String paymentType = (string) result.get('Payment_Type__c');
                  String expenseTypeCode = expenseCodeTypeMap.get(expenseType);
                  //objTotalMileageCost.debit += (Decimal) result.get('milegecost');
         
                  if(expenseTypeCode != null && expenseTypeCode != '' && result.get('expenseTotal') != null){
                     if(expenseTypeCodeTotalMap.containsKey(expenseTypeCode)){
                        Decimal debitTotal = expenseTypeCodeTotalMap.get(expenseTypeCode);
                        debitTotal += (Decimal) result.get('expenseTotal');
                        expenseTypeCodeTotalMap.put(expenseTypeCode, debitTotal);
                     }else{
                        expenseTypeCodeTotalMap.put(expenseTypeCode, (Decimal) result.get('expenseTotal'));
                     }

                     if(paymentType == 'Company Expense'){
                        objNameWithTotalline.credit += (Decimal) result.get('expenseTotal');
                     }else{
                        objPersonalExpMileageCost.credit += (Decimal) result.get('expenseTotal');
                     }
                    
                     //objPersonalExpMileageCost.credit += (Decimal) result.get('milegeCost');
                  }
              }

              //Adding mileageCost without duplicate of logACall record.
              for(AggregateResult result : lstMileagetotal){
                  objTotalMileageCost.debit += (Decimal) result.get('milegecost');
                  objPersonalExpMileageCost.credit += (Decimal) result.get('milegeCost');
               }
               
              for(String expenseCode : expenseTypeCodeTotalMap.keySet()){
                 //Accounting => debit, credit
                  expenseMonthlyReportWrapper objAcctCodeWrapper = new expenseMonthlyReportWrapper();
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

   @AuraEnabled
   public static void handleSubmitRequest(String selectedIds, String month, String year){
      
      Date submitReqDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month), 01);
      List<String> ids = selectedIds.split(',');
      List<Expense__c> selectedExpenses = [SELECT Submit_Request__c, Expense_Amount__c FROM Expense__c WHERE Id =: ids];
      system.debug('Got selected expenses=>'+selectedExpenses);

      Submit_Request__c newSR = new Submit_Request__c();
      newSR.Submited_Date__c = submitReqDate;
      insert newSR;
      system.debug('insert new SR' +newSR);

      Approver__c recordApporver = [SELECT ApproverId__c, ApproverId__r.Name FROM Approver__c WHERE user__c =: UserInfo.getUserId()];
      newSR.Approver__c = recordApporver.ApproverId__c;
      newSR.FirstApproverName__c = recordApporver.ApproverId__r.Name;
    
      Decimal totalExpenseAmount = 0.0;
      for(Expense__c exp : selectedExpenses){
         exp.Submit_Request__c = newSR.Id;
         if(exp.Expense_Amount__c != null){
            totalExpenseAmount += exp.Expense_Amount__c;
         }
      }
      //related expense record in submit Request.
      update selectedExpenses;

      newSR.Total_Expense_Amount__c = totalExpenseAmount;

      update newSR;

      system.debug('update SR with total' +newSR);

      // Automatic submit approval
      Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
      req1.setComments('Submitting request for expense amount approval.');
      req1.setObjectId(newSR.Id);
      // Submit on behalf of a specific submitter current goes to Brain
      req1.setSubmitterId(UserInfo.getUserId());
      // Submit the approval request for the account 
      Approval.ProcessResult result = Approval.process(req1);
     
      // When User Submit an Expense For Approval - Create a SF Task for the approver. 
      ProcessInstanceWorkitem[] approvalWorkItems = [SELECT Id, ProcessInstance.TargetObjectId, ActorId,
                                                          ProcessInstance.TargetObject.Name
                                                   FROM ProcessInstanceWorkitem 
                                                   WHERE ProcessInstance.TargetObjectId =: newSR.Id];

      if(approvalWorkItems.size() > 0){
         ProcessInstanceWorkitem approvalWorkIteam = approvalWorkItems[0];
         Task taskForApproval = new Task();
         taskForApproval.OwnerId = approvalWorkIteam.ActorId; //userId
         taskForApproval.Approval_Request_Id__c = approvalWorkIteam.Id; //ProcessInstanceWorkitemId
         taskForApproval.SR_Name__c = approvalWorkIteam.ProcessInstance.TargetObject.Name; // SR-Name
         //taskForApproval.WhatId = approvalWorkIteam.ProcessInstance.TargetObjectId;
         taskForApproval.Subject = 'Approver task';
         taskForApproval.ActivityDate = Date.today().addDays(3);
         taskForApproval.Priority = 'Medium';
         insert taskForApproval;
      }

   }

   // display approved records
   @AuraEnabled
   public static List<SubmittedExpenseApproval> getSubmittedExpenseApprovalData(String month, String year){
      startDate = null;
      endDate = null;
      if(month == 'All'){
         startDate = Date.newInstance(Integer.valueOf(year), 01, 01);
         endDate = Date.newInstance(Integer.valueOf(year), 12, 31);
      }else{
         startDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month), 01);
         endDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month) + 1, 01);
      }

      List<SubmittedExpenseApproval> finalSubmittedExpenseApprovalList = new List<SubmittedExpenseApproval>();

      List<Submit_Request__c> lstSubmittedApprovals = [SELECT Owner.Name, Total_Expense_Amount__c,Status__c,CreatedDate  
                                                       FROM Submit_Request__c
                                                       WHERE OwnerId =: UserInfo.getUserId()
                                                       AND Submited_Date__c >= :startDate
                                                       AND Submited_Date__c < :endDate
                                                       AND Total_Expense_Amount__c != null
                                                       ORDER BY CreatedDate desc];

      if(lstSubmittedApprovals.isEmpty()){
         throw new applicationException('No Request is Approved for the selected month and year.');
       }

      if(lstSubmittedApprovals != null && lstSubmittedApprovals.size() > 0){
         // SubmittedExpenseApproval totalLine = new SubmittedExpenseApproval();
            // totalLine.submittedBy = 'Total';
            // totalLine.totalExpenseAmount = 0.0;
            
         SubmittedExpenseApproval totalApproval = new SubmittedExpenseApproval();
            totalApproval.submittedBy = 'Total Approved';
            totalApproval.totalExpenseAmount = 0.0;

         SubmittedExpenseApproval totalRequest = new SubmittedExpenseApproval();
            totalRequest.submittedBy = 'Total Requested';
            totalRequest.totalExpenseAmount = 0.0;
         
         for(Submit_Request__c submittedAppr : lstSubmittedApprovals){
            SubmittedExpenseApproval expApproval = new SubmittedExpenseApproval();
            expApproval.submittedBy = submittedAppr.Owner.Name;
            expApproval.totalExpenseAmount = submittedAppr.Total_Expense_Amount__c;
            expApproval.submitStatus = submittedAppr.Status__c;
            expApproval.createdDate = submittedAppr.CreatedDate;
            finalSubmittedExpenseApprovalList.add(expApproval);

            // totalLine.totalExpenseAmount += expApproval.totalExpenseAmount;
            if(submittedAppr.Status__c == 'Approved'){
               totalApproval.totalExpenseAmount += expApproval.totalExpenseAmount;
            }else if(submittedAppr.Status__c == 'Requested'){
               totalRequest.totalExpenseAmount += expApproval.totalExpenseAmount;
            }

         }       
         // finalSubmittedExpenseApprovalList.add(totalLine);
         finalSubmittedExpenseApprovalList.add(totalApproval);
         finalSubmittedExpenseApprovalList.add(totalRequest);
         return finalSubmittedExpenseApprovalList;
      }else{
         return null;
      }
   }


   @AuraEnabled
   public static List<expenseMonthlyReportWrapper> getSubmittedExpenseList(String month, String year){
      startDate = null;
      endDate = null;
      if(month == 'All'){
         startDate = Date.newInstance(Integer.valueOf(year), 01, 01);
         endDate = Date.newInstance(Integer.valueOf(year), 12, 31);
      }else{
         startDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month), 01);
         endDate = Date.newInstance(Integer.valueOf(year), monthToNumberMap.get(month) + 1, 01);
      }

      List<Expense__c> lstsubmittedExpense  = [SELECT Id, Log_A_Call__c, Log_A_Call__r.Name, Name, 
                                                      Expense_Amount__c, Expense_Date__c
                                               FROM Expense__c 
                                               WHERE Submit_Request__c != null
                                               AND Log_A_Call__r.OwnerId =: UserInfo.getUserId()
                                               AND Expense_Date__c >= :startDate
                                               AND Expense_Date__c < :endDate];
       if(lstsubmittedExpense.isEmpty()){
              throw new applicationException('No unsubmitted expense found for the selected month and year.');
       }

       List<expenseMonthlyReportWrapper> lstSubmittedExpenseWrapper  = new  List<expenseMonthlyReportWrapper>();
       expenseMonthlyReportWrapper totalExpenseAmt = new expenseMonthlyReportWrapper();
       totalExpenseAmt.expenseAmount = 0;
       
       for(Expense__c exp : lstsubmittedExpense) {
            expenseMonthlyReportWrapper objExplistWrapper = new expenseMonthlyReportWrapper();
            objExplistWrapper.expenseDate = exp.Expense_Date__c;
            objExplistWrapper.logACallName = exp.Log_A_Call__r.Name;
            objExplistWrapper.logACallURL = exp.Log_A_Call__c;
            objExplistWrapper.expenseName = exp.Name;
            objExplistWrapper.ExpenseURL = exp.Id; 
            objExplistWrapper.expenseAmount = exp.Expense_Amount__c;
            if(objExplistWrapper.expenseAmount != null){
               totalExpenseAmt.expenseAmount += objExplistWrapper.expenseAmount;
            }
           
            lstSubmittedExpenseWrapper.add(objExplistWrapper); 
       }
       lstSubmittedExpenseWrapper.add(totalExpenseAmt);
       return lstSubmittedExpenseWrapper;
   }
   
   //For inside submit request record page
   @AuraEnabled(cacheable=true)
        public static List<approvalRequestWrapper> ExpenseRelatedList(Id recordId) {   
          ProcessInstanceWorkitem approvalWorkIteam = [SELECT id,Actor.Name,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE id =: recordId];
            List<Expense__c> lstExpenses = [SELECT Id, Name,Expense_Type__c,Expense_Date__c,Payment_Type__c,Expense_Amount__c, Log_A_Call__r.Comments__c,
                                                   Description_Or_Notes_Related_To_Expense__c,
                                                   Log_A_Call__r.Contact_Names__c  , Log_A_Call__r.Account_Names__c , 
                                                   Log_A_Call__r.Opportunity__r.name, Submit_Request__r.Name, Project__r.Name, Project__r.Id
                                            FROM Expense__c 
                                            WHERE Submit_Request__c =:approvalWorkIteam.ProcessInstance.TargetObjectId
                                            ORDER BY Expense_Date__c];
            List<approvalRequestWrapper> lstExpense = new List<approvalRequestWrapper>();
            DEcimal TotalExpenseAmount = 0;
            for(Expense__c expense : lstExpenses) {
               if(expense.Expense_Amount__c != null){
                  TotalExpenseAmount += expense.Expense_Amount__c;
               }
               approvalRequestWrapper expenseRecord = new approvalRequestWrapper();
               expenseRecord.id = expense.Id;
               expenseRecord.Name = expense.Name;
               expenseRecord.paymentType = expense.Payment_Type__c;
               expenseRecord.expenseType = expense.Expense_Type__c;
               expenseRecord.expenseAmount = expense.Expense_Amount__c;
               expenseRecord.expenseDate = expense.Expense_Date__c;
               expenseRecord.expenseDescription = expense.Description_Or_Notes_Related_To_Expense__c;
               expenseRecord.logDescreiption = expense.Log_A_Call__r.Comments__c;
               expenseRecord.contact = expense.Log_A_Call__r.Contact_Names__c;
               expenseRecord.account = expense.Log_A_Call__r.Account_Names__c;
               expenseRecord.opportunity = expense.Log_A_Call__r.Opportunity__r.name;
               expenseRecord.project = expense.Project__r.Name;
               expenseRecord.projectId = expense.Project__r.Id;
               lstExpense.add(expenseRecord);
            }
            approvalRequestWrapper expense = new approvalRequestWrapper();
            expense.expenseAmount = TotalExpenseAmount;
            expense.paymentType = 'Total Expense ';
            lstExpense.add(expense);
            if(lstExpenses.size() > 0) {
                return lstExpense;
            }else {
                return null;
            }
        }


   // Wrapper class for Approval Request
   public class approvalRequestWrapper {
      @AuraEnabled public Id id {get;set;}
      @AuraEnabled public String Name {get;set;}
      @AuraEnabled public String paymentType {get;set;}
      @AuraEnabled public String expenseType {get;set;}
      @AuraEnabled public Decimal expenseAmount {get;set;}
      @AuraEnabled public Date expenseDate {get;set;}
      @AuraEnabled public String expenseDescription {get;set;}
      @AuraEnabled public String logDescreiption {get;set;}
      @AuraEnabled public String contact {get;set;}
      @AuraEnabled public String account {get;set;}
      @AuraEnabled public String opportunity {get;set;}
      @AuraEnabled public String project {get;set;}
      @AuraEnabled public Id projectId {get;set;}
  }


    // wrapper class with @AuraEnabled and {get;set;} properties
    public class expenseMonthlyReportWrapper{
       @AuraEnabled public Id id {get;set;}
       @AuraEnabled public String logACallURL {get;set;}
       @AuraEnabled public String ExpenseURL {get;set;}
       @AuraEnabled public String expenseName {get;set;}
       @AuraEnabled public String expenseType {get;set;}
       @AuraEnabled public Decimal expenseAmount {get;set;}
       @AuraEnabled public String paymentType{get;set;}
       @AuraEnabled public String logACallName {get;set;}
       @AuraEnabled public String typeOfCall {get;set;}
       @AuraEnabled public Date expenseDate {get;set;}
       @AuraEnabled public String accountNames {get;set;}
       @AuraEnabled public String contactNames {get;set;}
       @AuraEnabled public String relationship {get;set;}
       @AuraEnabled public String comments {get;set;}
       @AuraEnabled public String opportunityId {get;set;}
       @AuraEnabled public String mileageType {get;set;}
       @AuraEnabled public Decimal mileageTraveled {get;set;}
       @AuraEnabled public Decimal mileageCost {get;set;}
       @AuraEnabled public Decimal totalCost {get;set;}
       @AuraEnabled public String expenseTypeCode {get;set;} //Accounting Code 171-00
       @AuraEnabled public Decimal debit {get;set;}
       @AuraEnabled public Decimal credit {get;set;}
       @AuraEnabled public Decimal CompanyCardTotal {get;set;}
   }

   public class SubmittedExpenseApproval{
      @AuraEnabled public String submittedBy {get;set;}
      @AuraEnabled public Decimal totalExpenseAmount {get;set;}
      @AuraEnabled public String submitStatus {get;set;}
      @AuraEnabled public DateTime createdDate {get;set;}
   }  
}