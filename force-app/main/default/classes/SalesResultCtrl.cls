public with sharing class SalesResultCtrl {
    public static final String SAINT_LOUIS = 'Saint Louis';
    public static final String OKLAHOMA = 'Oklahoma';
    public static final String KANSAS_CITY = 'Kansas City';
    public static final String DENVER = 'Denver';
    public static final String TOTAL_DIRECT_SALES_GOAL = 'Total Direct Sales Goal';
    public static final String TOTAL_BUY_RESELL_SALES_GOAL = 'Total Buy Resell Sales Goal';
    public static final String TOTAL_SALES_GOAL = 'Total Sales Goal';
    public static final String TOTAL_DIRECT_COMMISSION_MARGIN_SALES_GOAL = 'Direct/Commission Margin Goal';
    public static final String TOTAL_BUY_RESELL_MARGIN_GOAL = 'Buy Resell Margin Goal';
    public static final String TOTAL_MARGIN_GOAL = 'Total Margin Goal';
    public static Map<String, salesResultResponse> resultNumbersByResultName = new Map<String, salesResultResponse>();
    public static List<Sales_Representative__c> salesEggSplits = new List<Sales_Representative__c> ();
    public class applicationException extends Exception {}

    public SalesResultCtrl() {
    }

    @AuraEnabled(cacheable=true)
    public static List<salesResultResponse> buildSalesResultsWrapper(String selectedSalesRep) {
        Map<Integer, salesResultResponse> responseMap = new Map<Integer, salesResultResponse>();
        List<salesResultResponse> responseWrapper = new List<salesResultResponse>();
        Sales_Rep_Goal__c srGoal = getSalesRepGoals(selectedSalesRep);
        buildActualBooking(selectedSalesRep);
        salesResultResponse totalDirectSalesGoal = buildTotalDirectSales(srGoal);
        //responseWrapper.add(totalDirectSalesGoal);
        responseMap.put(17, totalDirectSalesGoal);
        responseMap.put(18, totalDirectSalesGoal.childResultList[0]);
        responseMap.put(19, totalDirectSalesGoal.childResultList[1]);

        salesResultResponse totalBuyResellGoal = new salesResultResponse();
        totalBuyResellGoal = buildTotalBuyResellGoal(srGoal);
        //responseWrapper.add(totalBuyResellGoal);
        responseMap.put(14, totalBuyResellGoal);
        responseMap.put(15, totalBuyResellGoal.childResultList[0]);
        responseMap.put(16, totalBuyResellGoal.childResultList[1]);

        salesResultResponse totalSaleGoal = new salesResultResponse();
        totalSaleGoal.totalGoalForYear = totalBuyResellGoal.totalGoalForYear + totalDirectSalesGoal.totalGoalForYear;
        buildTotalSaleGoal(totalSaleGoal);
        //responseWrapper.add(totalSaleGoal);
        responseMap.put(11, totalSaleGoal);
        responseMap.put(12, totalSaleGoal.childResultList[0]);
        responseMap.put(13, totalSaleGoal.childResultList[1]);

        salesResultResponse directCommissionMarginGoal = new salesResultResponse();
        directCommissionMarginGoal.totalGoalForYear = (totalDirectSalesGoal.totalGoalForYear * srGoal.Direct_Sales_Percentage__c)/100;
        system.debug('001 totalGoalForYear value :- '+directCommissionMarginGoal);
        buildDirectCommissionMarginGoal(directCommissionMarginGoal);
        //responseWrapper.add(directCommissionMarginGoal);
        responseMap.put(8, directCommissionMarginGoal);
        responseMap.put(9, directCommissionMarginGoal.childResultList[0]);
        responseMap.put(10, directCommissionMarginGoal.childResultList[1]);

        salesResultResponse buyResellMarginGoal = new salesResultResponse();
        buyResellMarginGoal.totalGoalForYear = (totalBuyResellGoal.totalGoalForYear * srGoal.Sales_Margin_Percentage__c)/100;
        buildBuyResellMarginGoal(buyResellMarginGoal);
        //responseWrapper.add(buyResellMarginGoal);
        responseMap.put(5, buyResellMarginGoal);
        responseMap.put(6, buyResellMarginGoal.childResultList[0]);
        responseMap.put(7, buyResellMarginGoal.childResultList[1]);

        salesResultResponse totalMarginGoal = new salesResultResponse();
        totalMarginGoal.totalGoalForYear = buyResellMarginGoal.totalGoalForYear + directCommissionMarginGoal.totalGoalForYear;
        buildTotalMarginGoal(totalMarginGoal);
        //responseWrapper.add(totalMarginGoal);
        
        responseMap.put(2, totalMarginGoal);
        responseMap.put(3, totalMarginGoal.childResultList[0]);
        responseMap.put(4, totalMarginGoal.childResultList[1]);


        list<Integer> ranksList = new list<Integer>();
        ranksList.addAll(responseMap.keySet());
        ranksList.sort();
        
        for(Integer rank : ranksList)
        {
            salesResultResponse result = responseMap.get(rank);    
            responseWrapper.add(result);
        }
        system.debug('responseWrapper=>'+responseWrapper);
        system.debug('responseWrapper=>'+responseWrapper.size());
        
        return responseWrapper;
    }

    public static void buildTotalMarginGoal(salesResultResponse totalMarginGoal) {
        totalMarginGoal.name = 'Total Margin Goal';
        totalMarginGoal.ytdGoal = ((totalMarginGoal.totalGoalForYear * system.now().dayOfYear()) / 365).setScale(2);
        // totalMarginGoal.percentageOfYear = (system.now().dayOfYear() * 100) / 365;
        totalMarginGoal.percentageOfYear = Decimal.valueOf(system.now().dayOfYear()) / 365;
        // totalMarginGoal.percentageOfYear = totalMarginGoal.percentageOfYear.setScale(2);
        totalMarginGoal.actual1MGoal = (totalMarginGoal.totalGoalForYear / 12).setScale(2);
        totalMarginGoal.actual3MGoal = (totalMarginGoal.totalGoalForYear / 4).setScale(2);
        totalMarginGoal.actual6MGoal = (totalMarginGoal.totalGoalForYear / 2).setScale(2);
        totalMarginGoal.actual12MGoal = (totalMarginGoal.totalGoalForYear / 1).setScale(2);
        totalMarginGoal.percentageOfYtdGoal = null;

        salesResultResponse childResult1 = new salesResultResponse();
        childResult1 = resultNumbersByResultName.get(TOTAL_MARGIN_GOAL);
        childResult1.name = 'Total Margin (booked)';
       
        childResult1.percentageOfYtdGoal = childResult1.ytdGoal  / totalMarginGoal.ytdGoal;
        childResult1.percentageOfYtdGoal = childResult1.percentageOfYtdGoal.setScale(2);
        //childResult1.percentageOfYtdGoal = (childResult1.ytdGoal  / totalMarginGoal.ytdGoal);

        salesResultResponse childResult2 = new salesResultResponse();
        childResult2 = constructChildResult2(childResult1);
        childResult1.totalGoalForYear = null;
        childResult1.percentageOfYear = null;


        totalMarginGoal.childResultList = new List<salesResultResponse>{childResult1,childResult2};  
    }

    public static void buildBuyResellMarginGoal(salesResultResponse buyResellMarginGoal) {
        buyResellMarginGoal.name = 'Buy Resell Margin Goal';
        buyResellMarginGoal.ytdGoal = ((buyResellMarginGoal.totalGoalForYear * system.now().dayOfYear()) / 365).setScale(2);
        buyResellMarginGoal.percentageOfYear = Decimal.valueOf(system.now().dayOfYear()) / 365;
        buyResellMarginGoal.percentageOfYear = buyResellMarginGoal.percentageOfYear.setScale(2);
        buyResellMarginGoal.actual1MGoal = (buyResellMarginGoal.totalGoalForYear / 12).setScale(2);
        buyResellMarginGoal.actual3MGoal = (buyResellMarginGoal.totalGoalForYear / 4).setScale(2);
        buyResellMarginGoal.actual6MGoal = (buyResellMarginGoal.totalGoalForYear / 2).setScale(2);
        buyResellMarginGoal.actual12MGoal = (buyResellMarginGoal.totalGoalForYear / 1).setScale(2);
        buyResellMarginGoal.percentageOfYtdGoal = null;

        salesResultResponse childResult1 = new salesResultResponse();
        childResult1 = resultNumbersByResultName.get(TOTAL_BUY_RESELL_MARGIN_GOAL);
        childResult1.name = 'Buy Resell Margin (booked)';
        //childResult1.percentageOfYtdGoal = ((childResult1.ytdGoal * 100) / buyResellMarginGoal.ytdGoal).setScale(2);
        childResult1.percentageOfYtdGoal = childResult1.ytdGoal  / buyResellMarginGoal.ytdGoal;
        childResult1.percentageOfYtdGoal = childResult1.percentageOfYtdGoal.setScale(2);
        childResult1.percentageOfYear = null;
        salesResultResponse childResult2 = new salesResultResponse();
        childResult2 = constructChildResult2(childResult1);
        childResult1.totalGoalForYear = null ;

        buyResellMarginGoal.childResultList = new List<salesResultResponse>{childResult1,childResult2};
    }

    public static void buildDirectCommissionMarginGoal(salesResultResponse directCommissionMarginGoal) {
        directCommissionMarginGoal.name = 'Direct/Commission Margin Goal';
        directCommissionMarginGoal.ytdGoal = ((directCommissionMarginGoal.totalGoalForYear * system.now().dayOfYear()) / 365).setScale(2);
        directCommissionMarginGoal.percentageOfYear = Decimal.valueOf(system.now().dayOfYear()) / 365;
        directCommissionMarginGoal.percentageOfYear = directCommissionMarginGoal.percentageOfYear.setScale(2);
        directCommissionMarginGoal.actual1MGoal = (directCommissionMarginGoal.totalGoalForYear / 12).setScale(2);
        directCommissionMarginGoal.actual3MGoal = (directCommissionMarginGoal.totalGoalForYear / 4).setScale(2);
        directCommissionMarginGoal.actual6MGoal = (directCommissionMarginGoal.totalGoalForYear / 2).setScale(2);
        directCommissionMarginGoal.actual12MGoal = (directCommissionMarginGoal.totalGoalForYear / 1).setScale(2);
        directCommissionMarginGoal.percentageOfYtdGoal = null;

        salesResultResponse childResult1 = new salesResultResponse();
        childResult1 = resultNumbersByResultName.get(TOTAL_DIRECT_COMMISSION_MARGIN_SALES_GOAL);
        childResult1.name = 'Direct/Commission Margin (booked)';
        //childResult1.percentageOfYear = (childResult1.ytdGoal * 100) / directCommissionMarginGoal.totalGoalForYear;
        childResult1.percentageOfYtdGoal = childResult1.ytdGoal  / directCommissionMarginGoal.ytdGoal;
        childResult1.percentageOfYtdGoal = childResult1.percentageOfYtdGoal.setScale(2);
        childResult1.percentageOfYear = null;
        salesResultResponse childResult2 = new salesResultResponse();
        childResult2 = constructChildResult2(childResult1);
        childResult1.totalGoalForYear = null;

        directCommissionMarginGoal.childResultList = new List<salesResultResponse>{childResult1,childResult2};
    }

    public static void buildTotalSaleGoal(salesResultResponse totalSaleGoal) {
        totalSaleGoal.name = 'Total Sales Goal';
        totalSaleGoal.ytdGoal = ((totalSaleGoal.totalGoalForYear * system.now().dayOfYear()) / 365).setScale(2);
        totalSaleGoal.percentageOfYear = Decimal.valueOf(system.now().dayOfYear()) / 365;
        totalSaleGoal.percentageOfYear = totalSaleGoal.percentageOfYear.setScale(2);
        totalSaleGoal.actual1MGoal = (totalSaleGoal.totalGoalForYear / 12).setScale(2);
        totalSaleGoal.actual3MGoal = (totalSaleGoal.totalGoalForYear / 4).setScale(2);
        totalSaleGoal.actual6MGoal = (totalSaleGoal.totalGoalForYear / 2).setScale(2);
        totalSaleGoal.actual12MGoal = (totalSaleGoal.totalGoalForYear / 1).setScale(2);
        totalSaleGoal.percentageOfYtdGoal = null;

        salesResultResponse childResult1 = new salesResultResponse();
        childResult1 = resultNumbersByResultName.get(TOTAL_SALES_GOAL);
        childResult1.name = 'Total Sales (Booked)';
       // childResult1.percentageOfYear = ( childResult1.ytdGoal * 100) /totalSaleGoal.totalGoalForYear;
       
        childResult1.percentageOfYear = childResult1.ytdGoal / totalSaleGoal.totalGoalForYear;
        childResult1.percentageOfYear = childResult1.percentageOfYear.setScale(2);

        childResult1.percentageOfYtdGoal = childResult1.ytdGoal / totalSaleGoal.ytdGoal;
        childResult1.percentageOfYtdGoal = childResult1.percentageOfYtdGoal.setScale(2);

        salesResultResponse childResult2 = new salesResultResponse();
        childResult2 = constructChildResult2(childResult1);
        childResult1.totalGoalForYear =null;
        totalSaleGoal.childResultList = new List<salesResultResponse>{childResult1,childResult2};

        //return totalSaleGoal;
    }

    public static salesResultResponse buildTotalBuyResellGoal(Sales_Rep_Goal__c srGoal) {
        salesResultResponse totalBuyResellGoal = new salesResultResponse();
        totalBuyResellGoal.name = TOTAL_BUY_RESELL_SALES_GOAL;
        totalBuyResellGoal.totalGoalForYear = srGoal.Resell_Sales_Goal__c;
        totalBuyResellGoal.ytdGoal = (srGoal.Resell_Sales_Goal__c * system.now().dayOfYear()) / 365;
        totalBuyResellGoal.ytdGoal = totalBuyResellGoal.ytdGoal .setScale(2);
        totalBuyResellGoal.percentageOfYear = Decimal.valueOf(system.now().dayOfYear()) / 365;
        totalBuyResellGoal.percentageOfYear = totalBuyResellGoal.percentageOfYear.setScale(2);
        totalBuyResellGoal.actual1MGoal = (srGoal.Resell_Sales_Goal__c / 12).setScale(2);
        totalBuyResellGoal.actual3MGoal = (srGoal.Resell_Sales_Goal__c / 4).setScale(2);
        totalBuyResellGoal.actual6MGoal = (srGoal.Resell_Sales_Goal__c / 2).setScale(2);
        totalBuyResellGoal.actual12MGoal = (srGoal.Resell_Sales_Goal__c / 1).setScale(2);
        totalBuyResellGoal.percentageOfYtdGoal = null;



        salesResultResponse childResult1 = new salesResultResponse();
        childResult1 = resultNumbersByResultName.get(TOTAL_BUY_RESELL_SALES_GOAL);
        childResult1.name = 'Total Buy Resell Sales';
       // childResult1.percentageOfYear = (childResult1.ytdGoal * 100) / srGoal.Resell_Sales_Goal__c;
        childResult1.percentageOfYear = childResult1.ytdGoal  / srGoal.Resell_Sales_Goal__c;
        childResult1.percentageOfYear = childResult1.percentageOfYear.setScale(2);

        childResult1.percentageOfYtdGoal = childResult1.ytdGoal  / totalBuyResellGoal.ytdGoal;
        childResult1.percentageOfYtdGoal = childResult1.percentageOfYtdGoal.setScale(2);
        
        salesResultResponse childResult2 = new salesResultResponse();
        childResult2 = constructChildResult2(childResult1);
        childResult1.totalGoalForYear = null;

        totalBuyResellGoal.childResultList = new List<salesResultResponse>{childResult1,childResult2};

        return totalBuyResellGoal;
    }

    public static salesResultResponse buildTotalDirectSales(Sales_Rep_Goal__c srGoal) {

        salesResultResponse totalDirectSalesGoal = new salesResultResponse();
        totalDirectSalesGoal.name = 'Total Direct Sales Goal';
        totalDirectSalesGoal.totalGoalForYear = srGoal.Direct_Sales_Goal__c;
        totalDirectSalesGoal.ytdGoal = (srGoal.Direct_Sales_Goal__c * system.now().dayOfYear()) / 365;
        totalDirectSalesGoal.ytdGoal = totalDirectSalesGoal.ytdGoal.setScale(2);
        totalDirectSalesGoal.percentageOfYear = Decimal.valueOf(system.now().dayOfYear()) / 365;
        totalDirectSalesGoal.percentageOfYear = totalDirectSalesGoal.percentageOfYear.setScale(2);
        totalDirectSalesGoal.actual1MGoal = (srGoal.Direct_Sales_Goal__c / 12).setScale(2);
        totalDirectSalesGoal.actual3MGoal = (srGoal.Direct_Sales_Goal__c / 4).setScale(2);
        totalDirectSalesGoal.actual6MGoal = (srGoal.Direct_Sales_Goal__c / 2).setScale(2);
        totalDirectSalesGoal.actual12MGoal = (srGoal.Direct_Sales_Goal__c / 1).setScale(2);
        totalDirectSalesGoal.percentageOfYtdGoal = null;
        

        salesResultResponse childResult1 = new salesResultResponse();
        childResult1 = resultNumbersByResultName.get(TOTAL_DIRECT_SALES_GOAL);
        childResult1.name = 'Total Direct Sales';
       // childResult1.percentageOfYear = (childResult1.ytdGoal * 100) / srGoal.Direct_Sales_Goal__c;
       childResult1.percentageOfYear = childResult1.ytdGoal  / srGoal.Direct_Sales_Goal__c;
        childResult1.percentageOfYear = childResult1.percentageOfYear.setScale(2);

       // childResult1.percentageOfYtdGoal = (childResult1.ytdGoal * 100) / srGoal.Direct_Sales_Goal__c;
        childResult1.percentageOfYtdGoal = childResult1.ytdGoal / totalDirectSalesGoal.ytdGoal;
        childResult1.percentageOfYtdGoal = childResult1.percentageOfYtdGoal.setScale(2);

        salesResultResponse childResult2 = new salesResultResponse();
        childResult2 = constructChildResult2(childResult1);
        childResult1.totalGoalForYear = null;

        totalDirectSalesGoal.childResultList = new List<salesResultResponse>{childResult1,childResult2};

        return totalDirectSalesGoal;
    }

    public static salesResultResponse constructChildResult2(salesResultResponse childResult1) {
        salesResultResponse childResult2 = new salesResultResponse();
        childResult2.name = 'Monthly Average over period';
        childResult2.ytdGoal = ((365/12) * (childResult1.ytdGoal/system.now().dayOfYear())).setScale(2);
        childResult2.actual1MGoal = childResult1.actual1MGoal;
        childResult2.actual3MGoal = (childResult1.actual3MGoal / 3).setScale(2);
        childResult2.actual6MGoal = (childResult1.actual6MGoal / 6).setScale(2);
        childResult2.actual12MGoal = (childResult1.actual12MGoal / 12).setScale(2);
        // By default null
        childResult2.percentageOfYear = null;
        childResult2.totalGoalForYear = null;
        childResult2.percentageOfYtdGoal = null;
        
        return childResult2;
    }

    public static Sales_Rep_Goal__c getSalesRepGoals(String selectedSalesRep){
        
        Sales_Rep_Goal__c srGoal = null;
        Set<Id> setSalesRepIds = new Set<Id>();
        List<Sales_Rep_Goal__c> lstMarginRevenue = new List<Sales_Rep_Goal__c>();
        if (selectedSalesRep.startsWith('005')) {
            system.debug('selectedSalesRep='+selectedSalesRep);
            lstMarginRevenue = [Select Name,Margin_Goal__c,Monthly_Margin__c,
                                        Revenue_Goal__c,Monthly_Revenue__c,
                                        Direct_Sales_Goal__c,
                                        Resell_Sales_Goal__c,
                                        Direct_Sales_Percentage__c,
                                        Sales_Margin_Percentage__c
                                FROM Sales_Rep_Goal__c
                                WHERE Year__c =:  String.valueOf(System.Today().year())
                                AND Sales_Rep__c =: selectedSalesRep];
            system.debug('sales rep for singal' + lstMarginRevenue);                   

        } else {
            lstMarginRevenue = [Select Name,Margin_Goal__c,Monthly_Margin__c,
                                        Revenue_Goal__c,Monthly_Revenue__c,Direct_Sales_Goal__c,
                                        Resell_Sales_Goal__c,
                                        Direct_Sales_Percentage__c,
                                        Sales_Margin_Percentage__c
                                FROM Sales_Rep_Goal__c
                                WHERE Year__c =:  String.valueOf(System.Today().year())
                                AND Master_Report__c =: selectedSalesRep];
            system.debug('sales rep office level user ' + lstMarginRevenue);                     

        }
        if(lstMarginRevenue.isEmpty()){
            // throw error
            throw new applicationException('sales rep goals are not set for selected user: ' + selectedSalesRep);
        }
    
        srGoal = lstMarginRevenue[0];
        return srGoal;
    }

    public Static void buildActualBooking(string selectedSalesRep) {
        
        Sales_Rep_Goal__c srGoal = getSalesRepGoals(selectedSalesRep);
        AggregateResult actualBooking = null;
        Date startOfTheYear = date.newInstance(Date.today().Year(), 01, 01);
        Date fromDate = Date.today().addMonths(-12);
                                                    
        if (salesEggSplits == null || salesEggSplits.size() == 0) {

            if (selectedSalesRep == 'Midwest Machinery') {
                salesEggSplits = [Select Margin__c,
                                        Revenue__c,
                                        Commision__c,
                                        Opportunity__r.Project__r.CreatedDate,
                                        MarginBooked__c,
                                        BuyResellMarginBooked__c,
                                        DirectCommisionMarginBooked__c,
                                        TotalSalesBooked__c,
                                        TotalBuyResellSales__c,
                                        TotalDirectSales__c
                                FROM Sales_Representative__c
                                WHERE (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                                        OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                                        OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                                        OR Sales_Rep__r.Office_Location__c =: DENVER) 
                                AND Opportunity__r.StageName = 'Closed Won' 
                                AND Opportunity__r.Active_Financial_Quote__c != null 
                                AND Opportunity__c != null
                                AND Opportunity__r.Project__c != null
                                AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true]; 
             System.debug('selected sales rep is midwest' +salesEggSplits);   

            } else if (selectedSalesRep == SAINT_LOUIS 
                        || selectedSalesRep == OKLAHOMA 
                        || selectedSalesRep == KANSAS_CITY 
                        || selectedSalesRep == DENVER) {
                
                salesEggSplits = [Select Margin__c,
                                        Revenue__c,
                                        Commision__c,
                                        Opportunity__r.Project__r.CreatedDate,  
                                        MarginBooked__c,
                                        BuyResellMarginBooked__c,
                                        DirectCommisionMarginBooked__c,
                                        TotalSalesBooked__c,
                                        TotalBuyResellSales__c,
                                        TotalDirectSales__c                                                               
                                FROM Sales_Representative__c
                                WHERE Sales_Rep__r.Office_Location__c = :selectedSalesRep 
                                AND Opportunity__r.StageName = 'Closed Won' 
                                AND Opportunity__r.Active_Financial_Quote__c != null 
                                AND Opportunity__c != null
                                AND Opportunity__r.Project__c != null
                                AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];
             System.debug('selected sales rep else if  saint louis part' +salesEggSplits);                                                             
            } else {
                salesEggSplits = [Select Margin__c,
                                        Revenue__c,
                                        Commision__c,
                                        Opportunity__r.Project__r.CreatedDate, 
                                        MarginBooked__c,
                                        BuyResellMarginBooked__c,
                                        DirectCommisionMarginBooked__c,
                                        TotalSalesBooked__c,
                                        TotalBuyResellSales__c,
                                        TotalDirectSales__c  
                                FROM Sales_Representative__c
                                WHERE Sales_Rep__c = :selectedSalesRep 
                                AND Opportunity__r.StageName = 'Closed Won' 
                                AND Opportunity__r.Active_Financial_Quote__c != null 
                                AND Opportunity__c != null
                                AND Opportunity__r.Project__c != null
                                AND Opportunity__r.Project__r.RemoveFromSalesResult__c != true];
             system.debug('selected sales for particular user' +salesEggSplits);   
            }
                                    
        } 
        if(salesEggSplits.isEmpty()){
            // throw error
            throw new applicationException(' please add the details of Direct Sales Goal & Resell Sales Goal & Sales Margin & Direct Sales Margin % in Sales rep goal for selected user:-' +  srGoal.Name );
        }
        
        salesResultResponse totalDirectSaleResult = new salesResultResponse();
        salesResultResponse totalBuyReSellSales = new salesResultResponse();
        salesResultResponse totalSales = new salesResultResponse();
        salesResultResponse directCommisionMargin = new salesResultResponse();
        salesResultResponse buyResellMargin = new salesResultResponse();
        salesResultResponse totalMargin = new salesResultResponse();
        for (Sales_Representative__c split : salesEggSplits) {
            system.debug('split='+split);
            // results for ytd
            if (split.Opportunity__r.Project__r.CreatedDate >= startOfTheYear && split.Opportunity__r.Project__r.CreatedDate <= Date.today()) {
                if (split.TotalDirectSales__c != 0) {
                    //totalDirectSaleResult.ytdGoal += (split.Opportunity__r.Active_Financial_Quote__r.Total_Project_Margin__c * split.Commision__c) / 100;
                    totalDirectSaleResult.ytdGoal += split.TotalDirectSales__c;                    
                }
                if (split.TotalBuyResellSales__c != 0) {
                    totalBuyReSellSales.ytdGoal += split.TotalBuyResellSales__c ;
                }
                if (split.TotalSalesBooked__c != 0) {
                    totalSales.ytdGoal += split.TotalSalesBooked__c;
                }
                if (split.DirectCommisionMarginBooked__c != 0) {
                    directCommisionMargin.ytdGoal += split.DirectCommisionMarginBooked__c ;
                }
                if (split.BuyResellMarginBooked__c != 0) {
                    buyResellMargin.ytdGoal += split.BuyResellMarginBooked__c ;
                }
                // Decimal localTotalMargin = split.Opportunity__r.Active_Financial_Quote__r.Total_Buy_Resell_Margin__c + split.Opportunity__r.Active_Financial_Quote__r.Commissions_and_Rebates__c;
                if (split.MarginBooked__c != 0)  {
                    totalMargin.ytdGoal += split.MarginBooked__c ;
                }
            }
            // results for last 1 month
            if (split.Opportunity__r.Project__r.CreatedDate <= Date.today() && split.Opportunity__r.Project__r.CreatedDate >= system.now().addMonths(-1)) {
                if (split.TotalDirectSales__c != 0) {
                    totalDirectSaleResult.actual1MGoal += split.TotalDirectSales__c;                    
                }
                if (split.TotalBuyResellSales__c != 0) {
                    totalBuyReSellSales.actual1MGoal += split.TotalBuyResellSales__c ;
                }
                if (split.TotalSalesBooked__c != 0) {
                    totalSales.actual1MGoal += split.TotalSalesBooked__c;
                }
                if (split.DirectCommisionMarginBooked__c != 0) {
                    directCommisionMargin.actual1MGoal += split.DirectCommisionMarginBooked__c;
                }
                if (split.BuyResellMarginBooked__c != 0) {
                    buyResellMargin.actual1MGoal += split.BuyResellMarginBooked__c;
                }
                if (split.MarginBooked__c != 0)  {
                    totalMargin.actual1MGoal += split.MarginBooked__c;
                }
                
            }
            // results for last 3 month
            if (split.Opportunity__r.Project__r.CreatedDate <= Date.today() && split.Opportunity__r.Project__r.CreatedDate >= system.now().addMonths(-3)) {
                if (split.TotalDirectSales__c != 0) {
                    totalDirectSaleResult.actual3MGoal += split.TotalDirectSales__c;                    
                }
                if (split.TotalBuyResellSales__c != 0) {
                    totalBuyReSellSales.actual3MGoal += split.TotalBuyResellSales__c;
                }
                if (split.TotalSalesBooked__c != 0) {
                    totalSales.actual3MGoal += split.TotalSalesBooked__c;
                }
                if (split.DirectCommisionMarginBooked__c != 0) {
                    directCommisionMargin.actual3MGoal += split.DirectCommisionMarginBooked__c;
                }
                if (split.BuyResellMarginBooked__c != 0) {
                    buyResellMargin.actual3MGoal += split.BuyResellMarginBooked__c;
                }
                if (split.MarginBooked__c != 0)  {
                    totalMargin.actual3MGoal += split.MarginBooked__c;
                }
                
            }
            // results for last 6 month
            if (split.Opportunity__r.Project__r.CreatedDate <= Date.today() && split.Opportunity__r.Project__r.CreatedDate >= system.now().addMonths(-6)) {
                if (split.TotalDirectSales__c != 0) {
                    totalDirectSaleResult.actual6MGoal += split.TotalDirectSales__c;              
                }
                if (split.TotalBuyResellSales__c != 0) {
                    totalBuyReSellSales.actual6MGoal += split.TotalBuyResellSales__c;
                }
                if (split.TotalSalesBooked__c != 0) {
                    totalSales.actual6MGoal += split.TotalSalesBooked__c;
                }
                if (split.DirectCommisionMarginBooked__c != 0) {
                    directCommisionMargin.actual6MGoal += (split.DirectCommisionMarginBooked__c);
                }
                if (split.BuyResellMarginBooked__c != 0) {
                    buyResellMargin.actual6MGoal += (split.BuyResellMarginBooked__c) ;
                }
                if (split.MarginBooked__c != 0)  {
                    totalMargin.actual6MGoal += split.MarginBooked__c;
                }
                
            }
            // results for last 12 month
            if (split.Opportunity__r.Project__r.CreatedDate <= Date.today() && split.Opportunity__r.Project__r.CreatedDate >= system.now().addMonths(-12)) {
                if (split.TotalDirectSales__c != 0) {
                    totalDirectSaleResult.actual12MGoal += split.TotalDirectSales__c;                    
                }
                if (split.TotalBuyResellSales__c != 0) {
                    totalBuyReSellSales.actual12MGoal += split.TotalBuyResellSales__c;
                }
                if (split.TotalSalesBooked__c != 0) {
                    totalSales.actual12MGoal += split.TotalSalesBooked__c;
                }
                if (split.DirectCommisionMarginBooked__c != 0) {
                    directCommisionMargin.actual12MGoal += split.DirectCommisionMarginBooked__c;
                }
                if (split.BuyResellMarginBooked__c != 0) {
                    buyResellMargin.actual12MGoal += split.BuyResellMarginBooked__c;
                }
                if (split.MarginBooked__c != 0)  {
                    totalMargin.actual12MGoal += split.MarginBooked__c ;
                }
                
            }

        }
        resultNumbersByResultName.put(TOTAL_DIRECT_SALES_GOAL, totalDirectSaleResult);
        resultNumbersByResultName.put(TOTAL_BUY_RESELL_SALES_GOAL, totalBuyReSellSales);
        resultNumbersByResultName.put(TOTAL_SALES_GOAL, totalSales);
        resultNumbersByResultName.put(TOTAL_DIRECT_COMMISSION_MARGIN_SALES_GOAL, directCommisionMargin);
        resultNumbersByResultName.put(TOTAL_BUY_RESELL_MARGIN_GOAL, buyResellMargin);
        resultNumbersByResultName.put(TOTAL_MARGIN_GOAL, totalMargin);

    }

    public static Set<Id> getSalesRepIds(String selectSalesRep){
    
        Set<Id> setSalesRepIds = new Set<Id>();
        List<Sales_Representative__c > lstSalesRep;
        system.debug('GetSalesRepIds' +selectSalesRep);
        if(selectSalesRep == 'Midwest Machinery'){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c,Sales_Rep__c  
                            FROM Sales_Representative__c 
                            Where (Sales_Rep__r.Office_Location__c =: SAINT_LOUIS
                            OR Sales_Rep__r.Office_Location__c =: OKLAHOMA 
                            OR Sales_Rep__r.Office_Location__c =: KANSAS_CITY 
                            OR Sales_Rep__r.Office_Location__c =: DENVER)];
                            
        }else if(selectSalesRep == SAINT_LOUIS || selectSalesRep == OKLAHOMA || selectSalesRep == KANSAS_CITY || selectSalesRep == DENVER){
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c,Sales_Rep__c  
                            FROM Sales_Representative__c 
                            Where Sales_Rep__r.Office_Location__c =: selectSalesRep];
        }else{
            lstSalesRep =[Select Opportunity__c,Revenue__c,Margin__c,Sales_Rep__c  
                            FROM Sales_Representative__c 
                            Where Sales_Rep__c =: selectSalesRep];
        }
        
        for(Sales_Representative__c  sr : lstSalesRep){
            setSalesRepIds.add(sr.Sales_Rep__c);
        }
        
        return setSalesRepIds;
    }

    @AuraEnabled(cacheable=true)
    public static List<SalesPercentageGoal> getPercentageGoals(String selectedSalesRep) {

        List<SalesPercentageGoal> lstSalesPercentageGoal = new List<SalesPercentageGoal>();
        system.debug('Method getPercentageGoal' +lstSalesPercentageGoal);
        
        Sales_Rep_Goal__c salesRepGoal = getSalesRepGoals(selectedSalesRep);  // before userinfor.getuser();

        if(salesRepGoal.Sales_Margin_Percentage__c != null && salesRepGoal.Direct_Sales_Percentage__c != null){
            SalesPercentageGoal objSalesPercentageGoalMargin = new SalesPercentageGoal();
            objSalesPercentageGoalMargin.percentageName = 'B/R Sales Margin %';
            objSalesPercentageGoalMargin.percentageValue = salesRepGoal.Sales_Margin_Percentage__c / 100;
            // if(objSalesPercentageGoalMargin.percentageValue != 0){
                system.debug('B/R Sales Margin % without divided by hund ' +salesRepGoal.Sales_Margin_Percentage__c );
                lstSalesPercentageGoal.add(objSalesPercentageGoalMargin);
                
            //}

            SalesPercentageGoal objSalesPercentageGoalDirect = new SalesPercentageGoal();
            objSalesPercentageGoalDirect.percentageName = 'Direct Sales Margin %';
            objSalesPercentageGoalDirect.percentageValue = salesRepGoal.Direct_Sales_Percentage__c / 100;
                lstSalesPercentageGoal.add(objSalesPercentageGoalDirect);
                system.debug('salespercentagegoal for direct sales margin ' +objSalesPercentageGoalDirect);
        

            
            // calculate total sales goal
            decimal totalSalesGoal = salesRepGoal.Direct_Sales_Goal__c + salesRepGoal.Resell_Sales_Goal__c;

            // calculate total margin goal
            decimal totalMarginGoal = 0.0;
            decimal buyResellMarginGoal = 0.0;
            decimal directComissionMarginGoal = 0.0;

            buyResellMarginGoal = (salesRepGoal.Resell_Sales_Goal__c * salesRepGoal.Sales_Margin_Percentage__c) / 100;
            directComissionMarginGoal = (salesRepGoal.Direct_Sales_Goal__c * salesRepGoal.Direct_Sales_Percentage__c) / 100;
            totalMarginGoal = buyResellMarginGoal + directComissionMarginGoal;


            // salesResultResponse totalDirectSalesGoal = buildTotalDirectSales(salesRepGoal);

            SalesPercentageGoal objSalesPercentageGoalSales = new SalesPercentageGoal();
            objSalesPercentageGoalSales.percentageName = 'Total Sales Margin %';
            objSalesPercentageGoalSales.percentageValue = totalMarginGoal / totalSalesGoal;
                lstSalesPercentageGoal.add(objSalesPercentageGoalSales);
        
            return lstSalesPercentageGoal;
            
        }else{
             throw new applicationException('please add the details of Sales Margin % & Direct Sales Margin % in Sales rep goal for selected user:- ' + salesRepGoal.Name);
        }
       
    }


    //BackLog V2 on Dashboard 1
    @AuraEnabled(cacheable=true)
    public static List<DashboardBackLog> getDashboardBackLog(String selectedSalesRep){
        List<DashboardBackLog> lstBackLog = new List<DashboardBackLog>();

        Set<Id> setSalesRepId = getSalesRepIds(selectedSalesRep);
        Set<Id> setBillingQuoteId = new Set<Id>();
        Set<Id> activeQuoteId = new Set<Id>();
        Map<Id,List<Decimal>> mapCommision = new Map<Id,List<Decimal>>();
        decimal TotalMargin = 0;
        decimal TotalRevenue = 0;
        decimal YearEndMarginTotal = 0;
        decimal YearEndRevenueTotal = 0;
        decimal lYearDaysMarginTotal = 0;
        decimal lYearDaysRevenueTotal = 0;
        decimal HalfYearMarginTotal = 0;
        decimal HalfYearRevenueTotal = 0;
        decimal ThreeMonthMarginTotal = 0;
        decimal ThreeMonthRevenueTotal = 0;
        decimal OneMonthMarginTotal = 0;
        decimal OneMonthRevenueTotal = 0;

        Date startOfTheYear = date.newInstance(Date.today().Year(), 01, 01);
        Date endDateOfTheYear = startOfTheYear.addYears(1);
       
        //Map for commision
        List<Sales_Representative__c> lstSalesRep = [SELECT Commision__c,Opportunity__c,Opportunity__r.Active_Financial_Quote__c
                                                        FROM Sales_Representative__c
                                                        WHERE Sales_Rep__c IN : setSalesRepId
                                                        AND Opportunity__r.Active_Financial_Quote__c != null
                                                        AND Opportunity__r.Project__r.RemoveFromBacklog__c != true
                                                        AND (NOT Opportunity__r.Name LIKE 'Test%')];
        for (Sales_Representative__c SalesRep : lstSalesRep) {
            if(mapCommision.containsKey(SalesRep.Opportunity__c)) {
                List<decimal> lstCommision = mapCommision.get(SalesRep.Opportunity__c);
                lstCommision.add(SalesRep.Commision__c);
                mapCommision.put(SalesRep.Opportunity__c,lstCommision);
            } else {
                mapCommision.put(SalesRep.Opportunity__c, new List<decimal> { SalesRep.Commision__c });
            }
            activeQuoteId.add(SalesRep.Opportunity__r.Active_Financial_Quote__c);
        }
        //Invoiced Quote Line Item's Id
        List<AcctSeed__Billing_Line__c> lstBillingLine = [SELECT AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c
                                                            FROM AcctSeed__Billing_Line__c
                                                            WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c != null
                                                            AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c IN : activeQuoteId];
        for (AcctSeed__Billing_Line__c BillingLine : lstBillingLine) {
            setBillingQuoteId.add(BillingLine.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c);
        }

        // Quote Line Iteam
        List<Product_Select__c> lstQuoteLineItem = [SELECT Id, CR__c, Quote__r.Opportunity.Id, Sales_Price__c,
                                                             Estimated_Ship_Date__c,Sale_Type__c,Quote__r.ProjectShipDate__c,Margin__c
                                                        FROM Product_Select__c
                                                        WHERE Id NOT IN : setBillingQuoteId
                                                        AND Quote__c IN : activeQuoteId 
                                                        AND Sale_Type__c != null
                                                        AND ((CR__c != null AND CR__c !=0) OR (Sales_Price__c != null AND Sales_Price__c != 0)
                                                        OR (Margin__c != null AND Margin__c != 0))];
                                                        

        for (Product_Select__c QuoteLine : lstQuoteLineItem ) {
            //Master Level 
            if(selectedSalesRep == 'Midwest Machinery'){
                // Total for Master
                if (QuoteLine.Sale_Type__c == 'C/R'){
                    TotalMargin += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                } else {
                    // Line Item Margin $ ={line item sales price} - {line item extended cost} 
                    //TotalMargin += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    TotalMargin += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                }
                if (QuoteLine.Sale_Type__c != 'D/S'){
                    TotalRevenue += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                }
                //Year Total Master
                if (QuoteLine.Estimated_Ship_Date__c < endDateOfTheYear || QuoteLine.Quote__r.ProjectShipDate__c < endDateOfTheYear) {
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        YearEndMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        YearEndMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        YearEndRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //365Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(365)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(365)){
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        lYearDaysMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        lYearDaysMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        lYearDaysRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //180Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(180) || QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(180)){
                
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        HalfYearMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        HalfYearMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        HalfYearRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //90Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(90) || QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(90)){
                  
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        ThreeMonthMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        ThreeMonthMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        ThreeMonthRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //30Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(30) || QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(30)){
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        OneMonthMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        OneMonthMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                      OneMonthRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
            } 
            //office and individual  
            else if (mapCommision.get(QuoteLine.Quote__r.Opportunity.Id) != null) {
                for (decimal commision : mapcommision.get(QuoteLine.Quote__r.Opportunity.Id)){
                    // Total
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        TotalMargin += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                    } else {
                        TotalMargin += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        TotalRevenue += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                    }              
                    //Year Total      
                    if (QuoteLine.Estimated_Ship_Date__c < endDateOfTheYear || QuoteLine.Quote__r.ProjectShipDate__c < endDateOfTheYear) {
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            YearEndMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            YearEndMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            YearEndRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //365Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(365)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(365)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            lYearDaysMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            lYearDaysMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            lYearDaysRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //180Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(180)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(180)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            HalfYearMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            HalfYearMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            HalfYearRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //90Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(90)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(90)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            ThreeMonthMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            ThreeMonthMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            ThreeMonthRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //30Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(30)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(30)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            OneMonthMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            OneMonthMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            OneMonthRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                }
            }
        }
        
        system.debug('Total Margin:- ' + TotalMargin +' Total Revenue:- '+TotalRevenue);
        system.debug('Year Total Margin:- '+YearEndMarginTotal + ' Year Total Revenue:- '+YearEndRevenueTotal);
        DashboardBackLog objTotal = new DashboardBackLog();
        objTotal.TotalMargin = TotalMargin == null ? 0 : TotalMargin;
        objTotal.TotalRevenue = TotalRevenue == null ? 0 : TotalRevenue;
        
        objTotal.YearEndMarginTotal = YearEndMarginTotal == null ? 0 : YearEndMarginTotal;
        objTotal.YearEndRevenueTotal = YearEndRevenueTotal == null ? 0 : YearEndRevenueTotal;
        
        objTotal.lYearDaysMarginTotal = lYearDaysMarginTotal == null ? 0 : lYearDaysMarginTotal;
        objTotal.lYearDaysRevenueTotal = lYearDaysRevenueTotal == null ? 0 : lYearDaysRevenueTotal;
        
        objTotal.HalfYearMarginTotal = HalfYearMarginTotal == null ? 0 : HalfYearMarginTotal;
        objTotal.HalfYearRevenueTotal = HalfYearRevenueTotal == null ? 0 : HalfYearRevenueTotal;
        
        objTotal.ThreeMonthMarginTotal = ThreeMonthMarginTotal == null ? 0 : ThreeMonthMarginTotal;
        objTotal.ThreeMonthRevenueTotal = ThreeMonthRevenueTotal == null ? 0 : ThreeMonthRevenueTotal;
        
        objTotal.OneMonthMarginTotal = OneMonthMarginTotal == null ? 0 : OneMonthMarginTotal;
        objTotal.OneMonthRevenueTotal = OneMonthRevenueTotal == null ? 0 : OneMonthRevenueTotal;
        lstBackLog.add(objTotal);
        
        if(TotalMargin == 0 && TotalRevenue == 0){
            // throw error
            throw new applicationException('Margin & Revenue for project line item not found for selected user: ' + selectedSalesRep);
        }else{
            return lstBackLog;
        }
    }



    // SalesBackLog on Dashboard
    @AuraEnabled(cacheable=true)
    public static List<SalesBackLog> getSalesBackLog(String selectedSalesRep) {
        
        List<SalesBackLog> lstBackLogs = new List<SalesBackLog>();

        Set<Id> setSalesRepId = getSalesRepIds(selectedSalesRep);
        Set<Id> setOpportunityId = new Set<Id>();
        //get sales rep projects.

        List<Sales_Representative__c> lstSalesRep = [SELECT Opportunity__c
                                                        FROM Sales_Representative__c
                                                        WHERE Opportunity__r.Active_Financial_Quote__c != null
                                                        AND Sales_Rep__c =: setSalesRepId];
        
        for (Sales_Representative__c salesRep : lstSalesRep) {
            setOpportunityId.add(salesRep.Opportunity__c);
        }                                                        

        List<Project__c> lstProjects = [SELECT Id, Opportunity__c 
                                            FROM Project__c
                                            WHERE Opportunity__c IN: setOpportunityId
                                            AND Project_Stage__c != 'Archived'];                                                        
        
        setOpportunityId.clear();
        for (Project__c project : lstProjects) {
            setOpportunityId.add(project.Opportunity__c);
        }                                              

        AggregateResult totalSalesBackLog = [SELECT SUM(Sales_Backlog_Total_Percent__c) total
                                                FROM Sales_Representative__c
                                                WHERE Opportunity__r.Active_Financial_Quote__c != null
                                                AND Sales_Rep__c IN: setSalesRepId
                                                AND Opportunity__c IN: setOpportunityId];

        AggregateResult totalMarginBackLog = [SELECT SUM(Margin_Backlog_Total_Percent__c) total
                                                FROM Sales_Representative__c
                                                WHERE Opportunity__r.Active_Financial_Quote__c != null
                                                AND Sales_Rep__c IN: setSalesRepId
                                                AND Opportunity__c IN: setOpportunityId];
        
        
        SalesBackLog objSalesBackLog = new SalesBackLog();
        objSalesBackLog.backLogName = 'Total Sales Backlog(Booked not Invoiced)';
        objSalesBackLog.backLogValue = totalSalesBackLog == null ? 0 : (Decimal) totalSalesBackLog.get('total');
        lstBackLogs.add(objSalesBackLog);

        SalesBackLog ObjMarginBackLog = new SalesBackLog();
        ObjMarginBackLog.backLogName = 'Total Margin Backlog(Booked not Invoiced)';
        ObjMarginBackLog.backLogValue = totalMarginBackLog == null ? 0 : (Decimal) totalMarginBackLog.get('total');
        lstBackLogs.add(ObjMarginBackLog);

        return lstBackLogs;
    
    }
    

    private static Map<Id, Decimal> getTotalCommisionAndRebateOfBilling(Set<Id> quoteIds) {
        Map<Id, Decimal> totalCommision_RebateOfBillingMap = new Map<Id, Decimal>();
        List<AggregateResult> lstCommissionAndRebate = [SELECT SUM(AcctSeed__Total__c) total,
                                                            QuoteId__c q
                                                        FROM AcctSeed__Billing_Line__c
                                                        WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Sale_Type__c = 'C/R'
                                                        AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c =: quoteIds
                                                        GROUP BY QuoteId__c];

        if(!lstCommissionAndRebate.isEmpty()) {
            for (AggregateResult aggResult : lstCommissionAndRebate) {
                Decimal totalCommisionAndRebate = 0;
                Id quoteId = (Id)aggResult.get('AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c');
                if (aggResult.get('total') != null) {
                    totalCommisionAndRebate = (Decimal) aggResult.get('total');
                } 
                totalCommision_RebateOfBillingMap.put(quoteId, totalCommisionAndRebate);
            }
        }
        return totalCommision_RebateOfBillingMap;

    }

    private static Map<Id, Decimal> getTotalBuyResellOfBilling(Set<Id> quoteIds) {
        Map<Id, Decimal> totalBuyResellOfBilling = new map<Id, Decimal>();
        List<AggregateResult> lstBuyAndResell = [SELECT SUM(AcctSeed__Total__c) total,
                                                        QuoteId__c q
                                                FROM AcctSeed__Billing_Line__c
                                                WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Sale_Type__c = 'B/R'
                                                AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c IN: quoteIds
                                                GROUP BY QuoteId__c];
        if(!lstBuyAndResell.isEmpty()) {
            for (AggregateResult aggResult : lstBuyAndResell) {
                Decimal totalBuyAndResell = 0;
                Id quoteId = (Id)aggResult.get('AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c');
                if (aggResult.get('total') != null) {
                    totalBuyAndResell = (Decimal) aggResult.get('total');
                }
                totalBuyResellOfBilling.put(quoteId, totalBuyAndResell);
            }
        }
        return totalBuyResellOfBilling;
    }

    public class salesResultResponse {
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public List<salesResultResponse> childResultList{get;set;}
        @AuraEnabled
        public Decimal totalGoalForYear{get;set;}
        @AuraEnabled
        public Decimal ytdGoal{get;set;}
        @AuraEnabled
        public Decimal percentageOfYear{get;set;}
        @AuraEnabled
        public Decimal percentageOfYtdGoal{get;set;}
        @AuraEnabled
        public Decimal actual1MGoal{get;set;}
        @AuraEnabled
        public Decimal actual3MGoal{get;set;}
        @AuraEnabled
        public Decimal actual6MGoal{get;set;}
        @AuraEnabled
        public Decimal actual12MGoal{get;set;}
        @AuraEnabled
        public Decimal salesResultBGColor{get;set;}
        
        public salesResultResponse(){
            //salesActivitySO = new SalesActivityGoal__c();
            name = '';
            totalGoalForYear = 0;
            ytdGoal = 0;
            percentageOfYear = 0.0;
            percentageOfYtdGoal = 0;
            actual1MGoal = 0;
            actual3MGoal = 0;
            actual6MGoal = 0;
            actual12MGoal = 0;
            childResultList = new List<salesResultResponse>();
            
        }
    }

    public with sharing class SalesPercentageGoal {
        @AuraEnabled public String percentageName {get;set;}
        @AuraEnabled public Decimal percentageValue {get;set;}
    }

    public with sharing class SalesBackLog {
        @AuraEnabled public String backLogName {get;set;}
        @AuraEnabled public Decimal backLogValue {get;set;}
    }
    public with sharing class DashboardBackLog{
        @AuraEnabled public Decimal TotalMargin {get;set;}
        @AuraEnabled public Decimal TotalRevenue {get;set;}
        @AuraEnabled public Decimal YearEndMarginTotal {get;set;}
        @AuraEnabled public Decimal YearEndRevenueTotal {get;set;}
        @AuraEnabled public Decimal lYearDaysMarginTotal {get;set;}
        @AuraEnabled public Decimal lYearDaysRevenueTotal {get;set;}
        @AuraEnabled public Decimal HalfYearMarginTotal {get;set;}
        @AuraEnabled public Decimal HalfYearRevenueTotal {get;set;}
        @AuraEnabled public Decimal ThreeMonthMarginTotal {get;set;}
        @AuraEnabled public Decimal ThreeMonthRevenueTotal {get;set;}
        @AuraEnabled public Decimal OneMonthMarginTotal {get;set;}
        @AuraEnabled public Decimal OneMonthRevenueTotal {get;set;}
    }
    
      public static List<DashboardBackLog> getDashboardBackLog2(String selectedSalesRep){
        List<DashboardBackLog> lstBackLog = new List<DashboardBackLog>();

        Set<Id> setSalesRepId = getSalesRepIds(selectedSalesRep);
        Set<Id> setBillingQuoteId = new Set<Id>();
        Set<Id> activeQuoteId = new Set<Id>();
        Map<Id,List<Decimal>> mapCommision = new Map<Id,List<Decimal>>();
        decimal TotalMargin = 0;
        decimal TotalRevenue = 0;
        decimal YearEndMarginTotal = 0;
        decimal YearEndRevenueTotal = 0;
        decimal lYearDaysMarginTotal = 0;
        decimal lYearDaysRevenueTotal = 0;
        decimal HalfYearMarginTotal = 0;
        decimal HalfYearRevenueTotal = 0;
        decimal ThreeMonthMarginTotal = 0;
        decimal ThreeMonthRevenueTotal = 0;
        decimal OneMonthMarginTotal = 0;
        decimal OneMonthRevenueTotal = 0;

        Date startOfTheYear = date.newInstance(Date.today().Year(), 01, 01);
        Date endDateOfTheYear = startOfTheYear.addYears(1);
       
        //Map for commision
        List<Sales_Representative__c> lstSalesRep = [SELECT Commision__c,Opportunity__c,Opportunity__r.Active_Financial_Quote__c
                                                        FROM Sales_Representative__c
                                                        WHERE Sales_Rep__c IN : setSalesRepId
                                                        AND Opportunity__r.Active_Financial_Quote__c != null
                                                        AND Opportunity__r.Project__r.RemoveFromBacklog__c != true
                                                        AND (NOT Opportunity__r.Name LIKE 'Test%')];
        for (Sales_Representative__c SalesRep : lstSalesRep) {
            if(mapCommision.containsKey(SalesRep.Opportunity__c)) {
                List<decimal> lstCommision = mapCommision.get(SalesRep.Opportunity__c);
                lstCommision.add(SalesRep.Commision__c);
                mapCommision.put(SalesRep.Opportunity__c,lstCommision);
            } else {
                mapCommision.put(SalesRep.Opportunity__c, new List<decimal> { SalesRep.Commision__c });
            }
            activeQuoteId.add(SalesRep.Opportunity__r.Active_Financial_Quote__c);
        }
        //Invoiced Quote Line Item's Id
        List<AcctSeed__Billing_Line__c> lstBillingLine = [SELECT AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c
                                                            FROM AcctSeed__Billing_Line__c
                                                            WHERE AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c != null
                                                            AND AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__r.Quote__c IN : activeQuoteId];
        for (AcctSeed__Billing_Line__c BillingLine : lstBillingLine) {
            setBillingQuoteId.add(BillingLine.AcctSeedERP__Sales_Order_Line__r.Quote_Line_Item__c);
        }

        // Quote Line Iteam
        List<Product_Select__c> lstQuoteLineItem = [SELECT Id, CR__c, Quote__r.Opportunity.Id, Sales_Price__c,
                                                             Estimated_Ship_Date__c,Sale_Type__c,Quote__r.ProjectShipDate__c,Margin__c
                                                        FROM Product_Select__c
                                                        WHERE Id NOT IN : setBillingQuoteId
                                                        AND Quote__c IN : activeQuoteId 
                                                        AND Sale_Type__c != null
                                                        AND ((CR__c != null AND CR__c !=0) OR (Sales_Price__c != null AND Sales_Price__c != 0)
                                                        OR (Margin__c != null AND Margin__c != 0))];
                                                        
                 List<Product_Select__c> QLToUpdate = new  List<Product_Select__c> ();
        for (Product_Select__c QuoteLine : lstQuoteLineItem ) {
            //Master Level 
            if(selectedSalesRep == 'Midwest Machinery'){
                // Total for Master
                if (QuoteLine.Sale_Type__c == 'C/R'){
                    TotalMargin += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                } else {
                    // Line Item Margin $ ={line item sales price} - {line item extended cost} 
                    //TotalMargin += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    TotalMargin += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                }
                if (QuoteLine.Sale_Type__c != 'D/S'){
                    TotalRevenue += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                }
                //Year Total Master
                if (QuoteLine.Estimated_Ship_Date__c < endDateOfTheYear || QuoteLine.Quote__r.ProjectShipDate__c < endDateOfTheYear) {
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        YearEndMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        YearEndMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        YearEndRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //365Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(365)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(365)){
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        lYearDaysMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        lYearDaysMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        lYearDaysRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //180Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(180) || QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(180)){
                
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        HalfYearMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        HalfYearMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        HalfYearRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //90Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(90) || QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(90)){
                  
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        ThreeMonthMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        ThreeMonthMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        ThreeMonthRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
                //30Days Total Master
                if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(30) || QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(30)){
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        OneMonthMarginTotal += QuoteLine.CR__c != null ? QuoteLine.CR__c : 0;
                    } else {
                        OneMonthMarginTotal += QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                      OneMonthRevenueTotal += QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0;
                    }
                }
            } 
            //office and individual  
            else if (mapCommision.get(QuoteLine.Quote__r.Opportunity.Id) != null) {
            Product_Select__c ql = new Product_Select__c(Id = QuoteLine.Id);
            decimal totalCommision = 0;
                for (decimal commision : mapcommision.get(QuoteLine.Quote__r.Opportunity.Id)){
                    totalCommision  = totalCommision  + commision;
                    // Total
                    if (QuoteLine.Sale_Type__c == 'C/R'){
                        TotalMargin += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                    } else {
                        TotalMargin += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                    }
                    if (QuoteLine.Sale_Type__c != 'D/S'){
                        TotalRevenue += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                    }              
                    //Year Total      
                    if (QuoteLine.Estimated_Ship_Date__c < endDateOfTheYear || QuoteLine.Quote__r.ProjectShipDate__c < endDateOfTheYear) {
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            YearEndMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            YearEndMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            YearEndRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                        
                        
                    }
                    //365Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(365)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(365)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            lYearDaysMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            lYearDaysMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            lYearDaysRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //180Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(180)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(180)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            HalfYearMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            HalfYearMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            HalfYearRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //90Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(90)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(90)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            ThreeMonthMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            ThreeMonthMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            ThreeMonthRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                    //30Days Total
                    if (QuoteLine.Estimated_Ship_Date__c <= system.now().addDays(30)|| QuoteLine.Quote__r.ProjectShipDate__c <= system.now().addDays(30)){
                        if (QuoteLine.Sale_Type__c == 'C/R'){
                            OneMonthMarginTotal += (commision * (QuoteLine.CR__c != null ? QuoteLine.CR__c : 0))/100 ;
                        } else {
                            OneMonthMarginTotal += (commision * (QuoteLine.Margin__c != null ? QuoteLine.Margin__c : 0))/100 ;
                        }
                        if (QuoteLine.Sale_Type__c != 'D/S'){
                            OneMonthRevenueTotal += (commision * (QuoteLine.Sales_Price__c != null ? QuoteLine.Sales_Price__c : 0))/100 ;
                        }
                    }
                }
                
                if (QuoteLine.Estimated_Ship_Date__c < endDateOfTheYear || QuoteLine.Quote__r.ProjectShipDate__c < endDateOfTheYear) {
                                    ql.Total_Commision__c  = totalCommision;
                QLToUpdate.add(ql);
                }

            }
        }
        
        system.debug('Total Margin:- ' + TotalMargin +' Total Revenue:- '+TotalRevenue);
        system.debug('Year Total Margin:- '+YearEndMarginTotal + ' Year Total Revenue:- '+YearEndRevenueTotal);
        DashboardBackLog objTotal = new DashboardBackLog();
        objTotal.TotalMargin = TotalMargin == null ? 0 : TotalMargin;
        objTotal.TotalRevenue = TotalRevenue == null ? 0 : TotalRevenue;
        
        objTotal.YearEndMarginTotal = YearEndMarginTotal == null ? 0 : YearEndMarginTotal;
        objTotal.YearEndRevenueTotal = YearEndRevenueTotal == null ? 0 : YearEndRevenueTotal;
        
        objTotal.lYearDaysMarginTotal = lYearDaysMarginTotal == null ? 0 : lYearDaysMarginTotal;
        objTotal.lYearDaysRevenueTotal = lYearDaysRevenueTotal == null ? 0 : lYearDaysRevenueTotal;
        
        objTotal.HalfYearMarginTotal = HalfYearMarginTotal == null ? 0 : HalfYearMarginTotal;
        objTotal.HalfYearRevenueTotal = HalfYearRevenueTotal == null ? 0 : HalfYearRevenueTotal;
        
        objTotal.ThreeMonthMarginTotal = ThreeMonthMarginTotal == null ? 0 : ThreeMonthMarginTotal;
        objTotal.ThreeMonthRevenueTotal = ThreeMonthRevenueTotal == null ? 0 : ThreeMonthRevenueTotal;
        
        objTotal.OneMonthMarginTotal = OneMonthMarginTotal == null ? 0 : OneMonthMarginTotal;
        objTotal.OneMonthRevenueTotal = OneMonthRevenueTotal == null ? 0 : OneMonthRevenueTotal;
        lstBackLog.add(objTotal);
        update QLToUpdate ;
        
        if(TotalMargin == 0 && TotalRevenue == 0){
            // throw error
            throw new applicationException('Margin & Revenue for project line item not found for selected user: ' + selectedSalesRep);
        }else{
            return lstBackLog;
        }
    }
}