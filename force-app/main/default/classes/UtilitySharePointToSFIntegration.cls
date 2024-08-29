public class UtilitySharePointToSFIntegration{
    public static Date deploymentDate = date.newinstance(2018, 8, 13);
    public static Date marrsRecordTypeSupportdeploymentDate = date.newinstance(2021, 1, 1);
    public static Boolean quoteBulkInsertContext = false;
    public static Boolean isNewQuote = false;
    public static Boolean isUpdateFromQuoteUI = false;
    Public static final string OPP_EQUIPMENT_RECORDTYPE = 'Equipment';
    Public static final string OPP_PARTS_RECORDTYPE = 'Parts';
    Public static final string OPP_REPAIR_RECORDTYPE = 'General Contracting';
    Public static final string OPP_REPAIR_RECORDTYPE_DEV_Name = 'General_Contracting';
    Public static final string OPP_MARRS_RECORDTYPE = 'MaRRS';
    Public static User currentUser = [SELECT Office_Location__c FROM User WHERE Id = :UserInfo.getUserId()];
    public static Opportunity runTimeOpportunitySobject; 
    public static string midwestGroupId = String.ValueOf(740);
    public static string EPGroupId = String.ValueOf(737);
    public static string editDeltePermissionLevelId = String.ValueOf(1073741929);
    Public Static Map<Id,User> recordIdToUser = new Map<Id,User>([SELECT Id,Office_Location__c FROM User]);
    public static Boolean isCurrentUserFromEngineeredProducts() {
        //System.debug('opportunity in Utility==>'+runTimeOpportunitySobject);
        try { 
                if(currentUser.Office_Location__c.equalsIgnoreCase(DENVER_CITY)) {
                    return true;
                } else {
                    return false;
                }
        } catch(Exception ex) {
            return false;
        }
        
    }

    
    public static Map<Integer,String> getequipmentOpportunityFolders () {
        Map<Integer,String> equipmentTypeOpportunityFolders = new Map<Integer,String>();
        
        return equipmentTypeOpportunityFolders;
    }
    public static Map<Integer,String> equipmentOpportunityFolders { get{
        Map<Integer,String> folderNames = new Map<Integer,String> {
                1  => '01 Engineering Design & Selections',
                2  => '01 Engineering Design & Selections/Manufacturer',
                3  => '02 Plans & Specs',
                4  => '02 Plans & Specs/Plan Date', 
                5  => '02 Plans & Specs/Plan Date/Addendum',
                6  => '02 Plans & Specs/Plan Date/Plans',
                7  => '02 Plans & Specs/Plan Date/Specs',
                8  => '03 Vendor Selections & Pricing',
                9  => '03 Vendor Selections & Pricing/Vendor',
                10 => '04 Correspondence',
                11 => '05 Quotes & Scopes',
                16 => '06 Submittals',
            /*  17 => '06 Submittals/Manufacturer',
                18 => '06 Submittals/Manufacturer/For Record Submittal',
                19 => '06 Submittals/Manufacturer/Submittals',
                20 => '06 Submittals/Manufacturer/Submittals/Aprroved Submittals',
                21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
                22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',*/
                23 => '07 Customer PO',
                24 => '08 Vendor Orders',
                25 => '08 Vendor Orders/Vendor',
                26 => '09 Customer Invoices',
                27 => '10 Add-On Equipment & Services',
                28 => '11 O&Ms - IOMs',
                29 => '12 Startup Warranty',
                30 => '12 Startup Warranty/Pictures',
                31 => '12 Startup Warranty/Schedule',
                32 => '12 Startup Warranty/Startup Reports',
                33 => '13 Project Photos'
            };
            
            if(isCurrentUserFromEngineeredProducts()) {
                // add submittal folders for EP user
                folderNames.put(17,'06 Submittals/Manufacturer');
                folderNames.put(18,'06 Submittals/Manufacturer/For Record Submittal');
                folderNames.put(19,'06 Submittals/Manufacturer/Submittals');
                folderNames.put(20, '06 Submittals/Manufacturer/Submittals/Approved Submittals');
                folderNames.put(21, '06 Submittals/Manufacturer/Submittals/Back Up Info');
                folderNames.put(22, '06 Submittals/Manufacturer/Submittals/Salesforce Submittals');
                folderNames.put(33, '06 Submittals/Submittal Approvals');
            } else {
                // add submittal folders for midwes user
                folderNames.put(17, '06 Submittals/Back Up - Workup info');
                folderNames.put(18, '06 Submittals/Approved Submittals');
            }
            
            return folderNames;
        }
        set{}
    }
    /*public static Map<Integer,String> equipmentOpportunityFolders = new Map<Integer,String> {
            1  => '01 Engineering Design & Selections',
            2  => '01 Engineering Design & Selections/Manufacturer',
            3  => '02 Plans & Specs',
            4  => '02 Plans & Specs/Plan Date', 
            5  => '02 Plans & Specs/Plan Date/Addendum',
            6  => '02 Plans & Specs/Plan Date/Plans',
            7  => '02 Plans & Specs/Plan Date/Specs',
            8  => '03 Vendor Selections & Pricing',
            9  => '03 Vendor Selections & Pricing/Vendor',
            10 => '04 Correspondence',
            11 => '05 Quotes & Scopes',
            16 => '06 Submittals',
            17 => '06 Submittals/Manufacturer',
            18 => '06 Submittals/Manufacturer/For Record Submittal',
            19 => '06 Submittals/Manufacturer/Submittals',
            20 => '06 Submittals/Manufacturer/Submittals/Approved Submittals',
            21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
            22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
            23 => '07 Customer PO',
            24 => '08 Vendor Orders',
            25 => '08 Vendor Orders/Vendor',
            26 => '09 Customer Invoices',
            27 => '10 Add-On Equipment & Services',
            28 => '11 O&Ms - IOMs',
            29 => '12 Startup Warranty',
            30 => '12 Startup Warranty/Pictures',
            31 => '12 Startup Warranty/Schedule',
            32 => '12 Startup Warranty/Startup Reports'
        };*/
     
         /* 
         public static Map<Integer,String> partsOpportunityFolders = new Map<Integer,String> {
             1 => '04 Quotes',
             2 => '07 Vendor Orders'
         };*/
         public static String partsFolderUpdatedOn = '2020-06-04 01:17:54';
         public static Map<Integer,String> partsOpportunityFolders = new Map<Integer,String> {
             1 => '01 Quotes',
             2 => '02 Vendor Orders'
         };
       
    public static Map<Integer,String> repairOpportunityFolders { get{
        Map<Integer,String> folderNames = new Map<Integer,String> {
            1  => '01 Engineering Design & Selections',
            2  => '01 Engineering Design & Selections/Manufacturer',
            3  => '02 Plans & Specs',
            4  => '02 Plans & Specs/Plan Date', 
            5  => '02 Plans & Specs/Plan Date/Addendum',
            6  => '02 Plans & Specs/Plan Date/Plans',
            7  => '02 Plans & Specs/Plan Date/Specs',
            8  => '03 Vendor Selections & Pricing',
            9  => '03 Vendor Selections & Pricing/Vendor',
            10 => '04 Correspondence',
            11 => '05 Quotes & Scopes',
            16 => '06 Submittals',
            17 => '06 Submittals/Manufacturer',
            18 => '06 Submittals/Manufacturer/For Record Submittal',
            19 => '06 Submittals/Manufacturer/Submittals',
            20 => '06 Submittals/Manufacturer/Submittals/Approved Submittals',
            21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
            22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
            23 => '07 Customer PO',
            24 => '08 Vendor Orders',
            25 => '08 Vendor Orders/Vendor',
            26 => '09 Customer Invoices',
            27 => '10 Add-On Equipment & Services',
            28 => '11 O&Ms - IOMs',
            29 => '12 Startup Warranty',
            30 => '12 Startup Warranty/Pictures',
            31 => '12 Startup Warranty/Schedule',
            32 => '12 Startup Warranty/Startup Reports'
          };
        if(isCurrentUserFromEngineeredProducts()) {
            folderNames.put(33, '06 Submittals/Submittal Approvals');
        }
        return folderNames;
    } }
     /*public static Map<Integer,String> repairOpportunityFolders = new Map<Integer,String> {
        1  => '01 Engineering Design & Selections',
        2  => '01 Engineering Design & Selections/Manufacturer',
        3  => '02 Plans & Specs',
        4  => '02 Plans & Specs/Plan Date', 
        5  => '02 Plans & Specs/Plan Date/Addendum',
        6  => '02 Plans & Specs/Plan Date/Plans',
        7  => '02 Plans & Specs/Plan Date/Specs',
        8  => '03 Vendor Selections & Pricing',
        9  => '03 Vendor Selections & Pricing/Vendor',
        10 => '04 Correspondence',
        11 => '05 Quotes & Scopes',
        16 => '06 Submittals',
        17 => '06 Submittals/Manufacturer',
        18 => '06 Submittals/Manufacturer/For Record Submittal',
        19 => '06 Submittals/Manufacturer/Submittals',
        20 => '06 Submittals/Manufacturer/Submittals/Approved Submittals',
        21 => '06 Submittals/Manufacturer/Submittals/Back Up Info',
        22 => '06 Submittals/Manufacturer/Submittals/Salesforce Submittals',
        23 => '07 Customer PO',
        24 => '08 Vendor Orders',
        25 => '08 Vendor Orders/Vendor',
        26 => '09 Customer Invoices',
        27 => '10 Add-On Equipment & Services',
        28 => '11 O&Ms - IOMs',
        29 => '12 Startup Warranty',
        30 => '12 Startup Warranty/Pictures',
        31 => '12 Startup Warranty/Schedule',
        32 => '12 Startup Warranty/Startup Reports'
      };*/
    
    
    public static Map<Integer,String> opportunityFolderNamesMap= new Map<Integer,String>{
        1 =>'01 Section 1 Plans & Specs',
        2 =>'02 Section 2 Selections & Vendor Pricing',
        3 => '03 Section 3 Scopes Quotes Submittals',
        4 => '04 Section 4 Correspondence-Emails', 
        5 => '05 Section 5 Customer PO(s)',
        6 => '06 Section 6 Vendor or Manufacturer POs',
        7 => '07 Section 7 O&Ms - IOMs', 
        8 => '08 Section 8 Customer Invoices',
        9 => '09 Section 11 Startup-Warranty',
        10=> '09 Section 11 Startup-Warranty/Startup',
        11 => '09 Section 11 Startup-Warranty/Warranty',
        12 => '10 Section 10 Photos-Media'
        };
        
    public static Map<Integer,String> quoteFolderNamesMap= new Map<Integer,String>{
            1 =>'01 Scope PDF',
            2 =>'02 Quote PDF',
            3 =>'03 Submittals',
            4 =>'03 Submittals/Approved',
            5 =>'03 Submittals/Submittal Under Construction',
            6 =>'03 Submittals/Submittal For Approval'
    };
    public static final string submittalSubFolder = 'Submittal For Approval';
    public static final string MainFolderClosingPath= '\')/AllItems';
    
    public static string MainFolderOpeningPath = isCurrentUserFromEngineeredProducts() ? 'add(\'Engineered Products/Salesforce/' : 'add(\'Salesforce/Salesforce/';
    //public static string MainFolderOpeningPathEngineered_Products = 'add(\'Engineered Products Salesforce Files/Salesforce/';
    public static string MainFolderOpeningPathEn = 'add(\'Salesforce/Salesforce/';
    public static string RootFolderForFilePath = isCurrentUserFromEngineeredProducts() ? 'Engineered Products/Salesforce/' : 'Salesforce/Salesforce/';
    public static final string DENVER_CITY = 'Denver';
    /*public static final string submittalSubFolder = 'For Approval';
    public static final string MainFolderOpeningPath= 'add(\'Salesforce/Salesforce/';
    
    public static final string RootFolderForFilePath= 'Salesforce/Salesforce/';*/
    public static boolean isCurrentUserExistInGroup(String groupName) {
        List<GroupMember> groupMemberRecord = new List<GroupMember> ();
        try {
             system.debug( 'userID '+UserInfo.getUserId());
             
             groupMemberRecord = [select Id,Group.DeveloperName  FROM GroupMember WHERE
                                            UserOrGroupId = :UserInfo.getUserId() 
                                            AND 
                                            Group.DeveloperName = :groupName];
            system.debug('groupMember rec = '+groupMemberRecord);                           
            if (groupMemberRecord.isEmpty()) {
                return false;       
            } else  {
                return true;    
            }
        } catch(Exception ex) {
            if (groupMemberRecord.isEmpty()) {
                return false;       
            } else {
                return true;    
            }
        }                                   
                   
    }  
    
    
    // method to fetch quote folder name
    public static String fetchQuoteFolderName(Quote quoteRecord) {
        system.debug('quoteRecord inside utility'+quoteRecord);
        /*String quotenumberLastDigits= quoteRecord.QuoteNumber;
        quotenumberLastDigits = quotenumberLastDigits.substringAfter('-');
        
        String quoteName = quoteRecord.Original_Name__c;
        system.debug(quoteName.contains(quoteRecord.Opportunity_Number__c)+'<<< is opp Name in quote');
        if(quoteName.contains(quoteRecord.Opportunity_Number__c)) {
            quoteName  = quoteName.remove(quoteRecord.Opportunity_Number__c+' - ');
            quoteName  = quoteName.remove(quoteRecord.Opportunity_Number__c);
            system.debug(quoteName+'<<quoteName after remove');
        }
        
        String originalQuoteName = quoteRecord.Original_Name__c;
        if(originalQuoteName != null) {
            originalQuoteName = quoteRecord.Original_Name__c.remove(quoteRecord.Opportunity_Number__c+' - ');
        }
        
        system.debug(quoteName);
        String folderName = quoteRecord.Opportunity_Number__c + '.' + 
                            quotenumberLastDigits + ' ' +
                            originalQuoteName;
        
        return folderName;*/
        
        /* New change for implementing quote name */
        String quoteName = quoteRecord.Original_Name__c;
        return quoteName;
        
    }  

    public static String assigneSharepointRootFolder(Opportunity opp) {
        System.debug('opportunity in Utility==>'+opp);
        
        try { 
                //User oppCreatedByUser = [SELECT Office_Location__c FROM User WHERE Id = :opp.CreatedById];
                User oppCreatedByUser = recordIdToUser.get(opp.CreatedById);  
                if(opp != null && opp.RecordType.Name == OPP_MARRS_RECORDTYPE) {
                    if(date.today() > marrsRecordTypeSupportdeploymentDate) {
                        MainFolderOpeningPath = 'add(\'Marrs/Salesforce/';
                        RootFolderForFilePath = 'Marrs/Salesforce/';
                    } else {
                        MainFolderOpeningPath = 'add(\'Salesforce/Salesforce/';
                        RootFolderForFilePath = 'Salesforce/Salesforce/';                        
                    }

                    return oppCreatedByUser.Office_Location__c;

                } else if( opp != null && opp.RecordType.Name == OPP_PARTS_RECORDTYPE)  {
                    if(opp.Office__c == 'Engineered Products') {
                        
                        MainFolderOpeningPath = 'add(\'Engineered Products/Salesforce/';
                        RootFolderForFilePath = 'Engineered Products/Salesforce/';
                        return null;
                    } else {
                        MainFolderOpeningPath = 'add(\'Salesforce/Salesforce/';
                        RootFolderForFilePath = 'Salesforce/Salesforce/';
                        system.System.debug('opp.Office__c==>'+opp.Office__c);
                        if(opp.Office__c == 'Midwest Machinery KC') {
                            return 'Kansas City';
                        } else if(opp.Office__c == 'Midwest Machinery OK') {
                            return 'Oklahoma';
                        } else if(opp.Office__c == 'Midwest Machinery STL') {
                            return 'Saint Louis';
                        }
                    }
                 
                } else if(oppCreatedByUser.Office_Location__c.equalsIgnoreCase(DENVER_CITY)) {
                    MainFolderOpeningPath = 'add(\'Engineered Products/Salesforce/';
                    RootFolderForFilePath = 'Engineered Products/Salesforce/';

                    return null;
                } else {
                    MainFolderOpeningPath = 'add(\'Salesforce/Salesforce/';
                    RootFolderForFilePath = 'Salesforce/Salesforce/';

                    return oppCreatedByUser.Office_Location__c;
                }
        } catch(Exception ex) {
            
        }
        return null;
        
    }

}