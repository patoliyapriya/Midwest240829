public with sharing class ExpenseReportController {

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

    // Expenese Codes
    Map<String, List<String>> expenseTypeCodeMap = new Map<String, List<String>>{
        '171-00' => new List<String>{OFFICE_EQUIPMENT_COMPUTERS},
        '451-00' => new List<String>{JOB_RELEATED_MATERIALS},
        '516-00' => new List<String>{CONSTRUCTION_VEHICLE_EXPENSES, FUEL},
        // '610-00' => new List<String>{MILEAGE_SALES_EXEC, PERSONAL_CAR_MILEAGE},
        '611-00' => new List<String>{MEAL_EMPLOYEES, MEALS_CUSTOMERS,MEAL_VENDOR},
        '611-01' => new List<String>{ENTERTAINMENT_EMPLOYEE, ENTERTAINMENT_CUSTOMERS, ENTERTAINMENT_VENDORS, ENTERTAINMENT_COMPANY_EVENT},
        '612-00' => new List<String>{TRAVEL_AIRFARE, TRAVEL_CAR_RENTAL, TRAVEL_HOTEL, TRAVEL_MISCELLANEOUS, PARKING, TOLLS, UBER_TAXI, TRAVEL_MEAL},
        // '612-01' => new List<String>{TRAVEL_MEAL},
        '616-00' => new List<String>{PROFESSIONAL_SUB_DUES},
        '620-01' => new List<String>{MARKETING_ADVERTISING},
        '620-04' => new List<String>{PROMOTIONAL_SHOWS},
        '625-00' => new List<String>{EDUCATION_TRAINING},
        '715-06' => new List<String>{SEMINAR_COURSE_FEES_CONFERENCE},
        '730-00' => new List<String>{OFFICE_BREAK_ROOM_SUPPLIES},
        '731-00' => new List<String>{POSTAGE_SHIPPING},
        '747-01' => new List<String>{BUILDING_REPAIR_MAINTENENCE},
        '750-01' => new List<String>{DONATIONS}
    };

    public List<ExpenseReportWrapper> lstExpenseReport {get;set;}
    public List<ExpenseReportWrapper> lstExpenseMiles {get;set;}
    public List<ExpenseReportWrapper> lstExpenseTotal {get;set;}
    public String currentUserName {get;set;}
    public String checkToUserName {get;set;}

    public ExpenseReportController() {
        currentUserName = UserInfo.getFirstName() +' '+UserInfo.getLastName();
        
        Map<String, ExpenseReportWrapper> mapExpenseType = new Map<String, ExpenseReportWrapper>();

        List<AggregateResult> lstExpense = [SELECT Expense_Type__c, Payment_Type__c, SUM(Expense_Amount__c) expenseTotal, CALENDAR_MONTH(Expense_Date__c) monthNum
                                            FROM Expense__c
                                            WHERE Expense_Date__c = THIS_YEAR
                                            AND Log_A_Call__r.OwnerId =: UserInfo.getUserId()
                                            GROUP BY Expense_Type__c, Payment_Type__c, CALENDAR_MONTH(Expense_Date__c)
                                            ORDER BY Expense_Type__c, CALENDAR_MONTH(Expense_Date__c) ASC];
        
        ExpenseReportWrapper objExpenseTotal = new ExpenseReportWrapper();
        objExpenseTotal.expenseType = 'TOTAL EXPENSES';

        for(AggregateResult result : lstExpense) {

            String expenseType = (String) result.get('Expense_Type__c');
            String paymentType = (String) result.get('Payment_Type__c');

            if(!mapExpenseType.containsKey(expenseType)) {
                ExpenseReportWrapper objExpenseReportWrapper = new ExpenseReportWrapper();
                objExpenseReportWrapper.expenseType = expenseType;
                mapExpenseType.put(expenseType, objExpenseReportWrapper);
            }

            ExpenseReportWrapper objExpense = mapExpenseType.get(expenseType);
            switch on (Integer) result.get('monthNum') {
                when 1 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountJanuary.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountJanuary.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountJanuary.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountJanuary.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 2 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountFebruary.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountFebruary.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountFebruary.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountFebruary.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 3 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountMarch.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountMarch.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountMarch.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountMarch.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 4 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountApril.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountApril.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountApril.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountApril.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 5 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountMay.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountMay.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountMay.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountMay.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 6 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountJune.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountJune.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountJune.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountJune.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 7 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountJuly.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountJuly.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountJuly.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountJuly.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 8 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountAugust.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountAugust.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountAugust.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountAugust.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 9 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountSeptember.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountSeptember.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountSeptember.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountSeptember.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 10 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountOctober.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountOctober.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountOctober.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountOctober.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
                when 11 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountNovember.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountNovember.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountNovember.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountNovember.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }                    
                }
                when 12 {
                    if (result.get('expenseTotal') != null) {
                        if(paymentType == 'Company Expense') {
                            objExpense.expenseAmountDecember.companyAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountDecember.totalCompanyAmount += (Decimal) result.get('expenseTotal');
                        } else {
                            objExpense.expenseAmountDecember.personalCardAmount = (Decimal) result.get('expenseTotal');
                            objExpenseTotal.expenseAmountDecember.totalPersonalCardAmount += (Decimal) result.get('expenseTotal');
                        }
                    }
                }
            }
        }             
        
        lstExpenseReport = mapExpenseType.values();

        lstExpenseReport.add(objExpenseTotal);

        //total miles
        lstExpenseMiles = new List<ExpenseReportWrapper>();

        List<AggregateResult> lstMileage = [SELECT SUM(Mileage_Traveled__c) totalMileage, SUM(Mileage_Cost__c) totalRembsmet, CALENDAR_MONTH(Event_Date__c) monthNum
                                            FROM LogACall__c
                                            WHERE Event_Date__c = THIS_YEAR
                                            AND OwnerId =: UserInfo.getUserId()
                                            GROUP BY CALENDAR_MONTH(Event_Date__c)
                                            ORDER BY CALENDAR_MONTH(Event_Date__c) ASC];

        ExpenseReportWrapper objTotalMiles = new ExpenseReportWrapper();
        objTotalMiles.expenseType = 'TOTAL MILES';

        ExpenseReportWrapper objMileageReimbursment = new ExpenseReportWrapper();
        objMileageReimbursment.expenseType = 'MILEAGE REIMBURSMENT';
        
        for(AggregateResult result : lstMileage) {
            
            switch on (Integer) result.get('monthNum') {
                //if(result.get('total')! = null)
                when 1 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountJanuary.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountJanuary.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }
                }
                when 2 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountFebruary.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountFebruary.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }
                    
                }
                when 3 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountMarch.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountMarch.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }
                    
                }
                when 4 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountApril.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountApril.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }
                    //objTotalMiles.expenseAmountApril.totalMiles = result.get('totalMileage') != null ? (Decimal) result.get('totalMileage') : 0;
                    
                }
                when 5 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountMay.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountMay.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }   
                }
                when 6 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountJune.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountJune.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }    
                }
                when 7 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountJuly.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountJuly.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }    
                }
                when 8 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountAugust.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountAugust.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }    
                }
                when 9 {
                    if(result.get('totalMileage') != null){
                      objTotalMiles.expenseAmountSeptember.totalMiles = (Decimal) result.get('totalMileage');
                      objMileageReimbursment.expenseAmountSeptember.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }  
                }
                when 10 {
                    if(result.get('totalMileage') != null){
                      objTotalMiles.expenseAmountOctober.totalMiles = (Decimal) result.get('totalMileage');
                      objMileageReimbursment.expenseAmountOctober.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }  
                }
                when 11 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountNovember.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountNovember.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }    
                }
                when 12 {
                    if(result.get('totalMileage') != null){
                        objTotalMiles.expenseAmountDecember.totalMiles = (Decimal) result.get('totalMileage');
                        objMileageReimbursment.expenseAmountDecember.mileageReimbursment = (Decimal) result.get('totalRembsmet');
                    }    
                }
            }
        }
        
        lstExpenseMiles.add(objTotalMiles);

        lstExpenseMiles.add(objMileageReimbursment);

        Decimal january610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountJanuary.mileageReimbursment;
        Decimal february610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountFebruary.mileageReimbursment;
        Decimal march610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountMarch.mileageReimbursment;
        Decimal april610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountApril.mileageReimbursment;
        Decimal may610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountMay.mileageReimbursment;
        Decimal june610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountJune.mileageReimbursment;
        Decimal july610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountJuly.mileageReimbursment;
        Decimal august610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountAugust.mileageReimbursment;
        Decimal september610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountSeptember.mileageReimbursment;
        Decimal october610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountOctober.mileageReimbursment;
        Decimal november610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountNovember.mileageReimbursment;
        Decimal december610 = lstExpenseMiles[(lstExpenseMiles.size() - 1)].expenseAmountDecember.mileageReimbursment;

       //FOR ACCOUNTING USE ONLY need Total 

        lstExpenseTotal = new List<ExpenseReportWrapper>();
        List<AggregateResult> lstAcctExpense = [SELECT SUM(Expense_Amount__c) expenseTotal, CALENDAR_MONTH(Expense_Date__c) monthNum,
                                                 SUM(Log_A_Call__r.Mileage_Cost__c) totalRembsmet, Expense_Type__c
                                                FROM Expense__c WHERE Log_A_Call__r.OwnerId =: UserInfo.getUserId()
                                                GROUP BY CALENDAR_MONTH(Expense_Date__c), Expense_Type__c 
                                                ORDER BY CALENDAR_MONTH(Expense_Date__c) ASC];

        ExpenseReportWrapper objTotalExpenseReportWrapper = new ExpenseReportWrapper();
        objTotalExpenseReportWrapper.expenseCode = currentUserName;

        for(String expenseCode : expenseTypeCodeMap.keySet()){
            // 516-00
            List<String> expenseTypesForThisCode = expenseTypeCodeMap.get(expenseCode);

            ExpenseReportWrapper objExpReportWrapper = new ExpenseReportWrapper();
            objExpReportWrapper.expenseCode = expenseCode;

            for(AggregateResult result : lstAcctExpense){
                String expenseType = (String) result.get('Expense_Type__c');
                if(expenseTypesForThisCode.contains(expenseType)){
                    switch on (Integer) result.get('monthNum') {
                        when 1 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountJanuary.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountJanuary.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 2 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountFebruary.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountFebruary.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 3 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountMarch.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountMarch.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 4 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountApril.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountApril.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 5 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountMay.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountMay.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 6 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountJune.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountJune.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 7 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountJuly.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountJuly.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 8 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountAugust.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountAugust.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 9 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountSeptember.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountSeptember.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 10 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountOctober.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountOctober.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 11 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountNovember.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountNovember.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                        when 12 {
                            if (result.get('expenseTotal') != null) {
                                if(result.get('Expense_Type__c') != 'Mileage - Sales Executives' || result.get('Expense_Type__c') != 'Personal Car Mileage'){
                                    objExpReportWrapper.expenseAmountDecember.debit += (Decimal) result.get('expenseTotal');
                                    objTotalExpenseReportWrapper.expenseAmountDecember.credit += (Decimal) result.get('expenseTotal');
                                }
                            }
                        }
                    }
                }
            }


            lstExpenseTotal.add(objExpReportWrapper);
        }
        lstExpenseTotal.add(objTotalExpenseReportWrapper); 

        lstExpenseTotal[0].expenseAmountJanuary.sixZeroOne = january610;
        lstExpenseTotal[0].expenseAmountFebruary.sixZeroOne = february610;
        lstExpenseTotal[0].expenseAmountMarch.sixZeroOne = march610;
        lstExpenseTotal[0].expenseAmountMay.sixZeroOne = may610;
        lstExpenseTotal[0].expenseAmountApril.sixZeroOne = april610;
        lstExpenseTotal[0].expenseAmountJune.sixZeroOne = june610;
        lstExpenseTotal[0].expenseAmountJuly.sixZeroOne = july610;
        lstExpenseTotal[0].expenseAmountAugust.sixZeroOne = august610;
        lstExpenseTotal[0].expenseAmountSeptember.sixZeroOne = september610;
        lstExpenseTotal[0].expenseAmountOctober.sixZeroOne = october610;
        lstExpenseTotal[0].expenseAmountNovember.sixZeroOne = november610;
        lstExpenseTotal[0].expenseAmountDecember.sixZeroOne = december610;

        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountJanuary.credit += january610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountFebruary.credit += february610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountMarch.credit += march610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountMay.credit += may610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountApril.credit += april610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountJune.credit += june610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountJuly.credit += july610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountAugust.credit += august610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountSeptember.credit += september610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountOctober.credit += october610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountNovember.credit += november610;
        lstExpenseTotal[lstExpenseTotal.size() - 1].expenseAmountDecember.credit += december610;

        ExpenseReportWrapper ObjlstExpenseGrandTotal = new ExpenseReportWrapper();
        checkToUserName = 'Check to '+currentUserName;
        ObjlstExpenseGrandTotal.expenseCode = checkToUserName;

        //set to null because debit by default set to zero.
        ObjlstExpenseGrandTotal.expenseAmountJanuary.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountFebruary.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountMarch.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountApril.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountMay.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountJune.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountJuly.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountAugust.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountSeptember.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountOctober.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountNovember.debit = null;
        ObjlstExpenseGrandTotal.expenseAmountDecember.debit = null;
        

        ObjlstExpenseGrandTotal.expenseAmountJanuary.credit = objTotalExpenseReportWrapper.expenseAmountJanuary.credit - objExpenseTotal.expenseAmountJanuary.totalCompanyAmount;  
        ObjlstExpenseGrandTotal.expenseAmountFebruary.credit = objTotalExpenseReportWrapper.expenseAmountFebruary.credit - objExpenseTotal.expenseAmountFebruary.totalCompanyAmount;
        ObjlstExpenseGrandTotal.expenseAmountMarch.credit = objTotalExpenseReportWrapper.expenseAmountMarch.credit - objExpenseTotal.expenseAmountMarch.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountApril.credit = objTotalExpenseReportWrapper.expenseAmountApril.credit - objExpenseTotal.expenseAmountApril.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountMay.credit = objTotalExpenseReportWrapper.expenseAmountMay.credit - objExpenseTotal.expenseAmountMay.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountJune.credit = objTotalExpenseReportWrapper.expenseAmountJune.credit - objExpenseTotal.expenseAmountJune.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountJuly.credit = objTotalExpenseReportWrapper.expenseAmountJuly.credit - objExpenseTotal.expenseAmountJuly.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountAugust.credit = objTotalExpenseReportWrapper.expenseAmountAugust.credit - objExpenseTotal.expenseAmountAugust.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountSeptember.credit = objTotalExpenseReportWrapper.expenseAmountSeptember.credit - objExpenseTotal.expenseAmountSeptember.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountOctober.credit = objTotalExpenseReportWrapper.expenseAmountOctober.credit - objExpenseTotal.expenseAmountOctober.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountNovember.credit = objTotalExpenseReportWrapper.expenseAmountNovember.credit - objExpenseTotal.expenseAmountNovember.totalCompanyAmount; 
        ObjlstExpenseGrandTotal.expenseAmountDecember.credit = objTotalExpenseReportWrapper.expenseAmountDecember.credit - objExpenseTotal.expenseAmountDecember.totalCompanyAmount; 

        lstExpenseTotal.add(ObjlstExpenseGrandTotal);
    }   

    public List<String> getExpenseType() {

        List<String> lstExpenseType = new List<String>();

        String objectName = 'Expense__c';
        String fieldName ='Expense_Type__c';
        
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            lstExpenseType.add(pickListVal.getLabel());
        }   

        return lstExpenseType;
    }

    public with sharing class ExpenseReportWrapper {
        public String expenseCode {get;set;} // = 171-00, 616-00, 516-00
        public String expenseType {get;set;} // = fuel --> jan,feb,march data will in expenseReportWrapper
        public ExpenseAmount expenseAmountJanuary {get;set;}
        public ExpenseAmount expenseAmountFebruary {get;set;}
        public ExpenseAmount expenseAmountMarch {get;set;}
        public ExpenseAmount expenseAmountApril {get;set;}
        public ExpenseAmount expenseAmountMay {get;set;}
        public ExpenseAmount expenseAmountJune {get;set;}
        public ExpenseAmount expenseAmountJuly {get;set;}
        public ExpenseAmount expenseAmountAugust {get;set;}
        public ExpenseAmount expenseAmountSeptember {get;set;}
        public ExpenseAmount expenseAmountOctober {get;set;}
        public ExpenseAmount expenseAmountNovember {get;set;}
        public ExpenseAmount expenseAmountDecember {get;set;}

        public ExpenseReportWrapper() {
            expenseAmountJanuary = new expenseAmount();
            expenseAmountFebruary = new expenseAmount();
            expenseAmountMarch = new expenseAmount();
            expenseAmountApril = new expenseAmount();
            expenseAmountMay = new expenseAmount();
            expenseAmountJune = new expenseAmount();
            expenseAmountJuly = new expenseAmount();
            expenseAmountAugust = new expenseAmount();
            expenseAmountSeptember = new expenseAmount();
            expenseAmountOctober = new expenseAmount();
            expenseAmountNovember = new expenseAmount();
            expenseAmountDecember = new expenseAmount();
        }
    }

    public with sharing class ExpenseAmount {
        public Decimal companyAmount {get;set;}
        public Decimal personalCardAmount {get;set;}
        public Decimal totalMiles {get;set;}
        public Decimal totalPersonalCardAmount {get;set;}
        public Decimal totalCompanyAmount {get;set;}
        public Decimal mileageReimbursment {get;set;}
        public Decimal otherReimbursement {get;set;}
        public Decimal totalReimbursement {get;set;}

        public Decimal debit {get;set;}
        public Decimal credit {get;set;}

        public Decimal sixZeroOne {get;set;}

        public ExpenseAmount() {
            companyAmount = 0;
            personalCardAmount = 0;
            totalMiles = 0;
            totalPersonalCardAmount = 0;
            totalCompanyAmount = 0;
            mileageReimbursment = 0;
            otherReimbursement = 0;
            totalReimbursement = 0;

            debit = 0;
            credit = 0;
            sixZeroOne = 0;
        }
    }

}