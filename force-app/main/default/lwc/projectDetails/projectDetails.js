import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import getData from'@salesforce/apex/ProjectDetails.getData';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveProjectStatus from '@salesforce/apex/ProjectDetails.saveProjectStatus';
import updateEmailSchedules from '@salesforce/apex/ProjectDetails.updateEmailSchedules';
import getCostPosting from '@salesforce/apex/ProjectDetails.getCostPosting';
import deleteCostPosting from '@salesforce/apex/ProjectDetails.deleteCostPosting';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import LINE_ITEM_OBJECT from '@salesforce/schema/Product_Select__c';
import SUBMITTAL_FIELD from '@salesforce/schema/Product_Select__c.Submittals__c';
import WARRANTY_FIELD from '@salesforce/schema/Product_Select__c.Warranty_Type__c';

const columns = [
                    { label: 'Submittal Status',
                        fieldName: 'submittalStatus',
                        type: 'picklistColumn',
                        wrapText: true,
                        editable: true,
                        sortable: true,
                        typeAttributes: {
                            placeholder: 'select',
                            options: { fieldName: 'submittalPicklist' },
                            value: 'submittalStatus',
                        }
                    },
                    { label: 'Tag', fieldName: 'tag', type: 'text', hideDefaultActions: true, sortable: true},
                    { label: 'Hide From Email', editable: true, fieldName: 'hideFromEmail', type: 'boolean', wrapText: true, hideDefaultActions: true, sortable: true},
                    { label: 'Qty', fieldName: 'quantity', type: 'text', hideDefaultActions: true, sortable: true},
                    { label: 'Code', fieldName: 'code', type: 'text', hideDefaultActions: true, sortable: true},
                    // custom richText column
                    { label: "Description", fieldName: "description", type: "richText", hideDefaultActions: true, sortable: true, wrapText: true},
                    //{ label: 'Description', fieldName: 'Descriptions__c', type: 'text', hideDefaultActions: true, sortable: true},
                    { label: 'Release Date', fieldName: 'releaseDate', type: 'date-local', editable: true, hideDefaultActions: true, sortable: true, wrapText: true},
                    { label: 'Est. Ship Date', fieldName: 'estimateShipDate', type: 'date-local', editable: true, hideDefaultActions: true, sortable: true, wrapText: true},
                    { label: 'Act. Ship Date', fieldName: 'actShipDate', type: 'date-local', editable: true, hideDefaultActions: true, sortable: true, wrapText: true},
                    { label: 'Tracking', fieldName: 'tracking', type: 'text', hideDefaultActions: true, sortable: true, editable: true},
                    { label: 'Notes', fieldName: 'stringNote', type: 'text', editable: true, sortable: true, wrapText: true}
                ];

const columnAccountingSeed = [{ label: 'Qty', fieldName: 'quantity', type: 'text', hideDefaultActions: true, sortable: true},
                                { label: 'Code', fieldName: 'code', type: 'text', hideDefaultActions: true, sortable: true},
                                { label: "Description", fieldName: "description", type: "richText", wrapText: true, hideDefaultActions: true, sortable: true},
                                //{ label: 'Description', fieldName: 'description', type: 'text', sortable: true, hideDefaultActions: true},
                                { label: 'SO', fieldName: 'soUrl', type: 'url', sortable: true, hideDefaultActions: true,typeAttributes: {
                                    label: {fieldName: 'soName'},
                                    target: '_blank'
                                }},
                                { label: 'Customer Invoice', fieldName: 'customerInvoiceUrl', type: 'url', sortable: true, hideDefaultActions: true,typeAttributes: {
                                    label: {fieldName: 'customerInvoiceName'},
                                    target: '_blank'
                                }},
                                { label: 'Invoice Amount', fieldName: 'invoiceAmount', type: 'Currency', sortable: true, hideDefaultActions: true},
                                { label: 'Payment Received', fieldName: 'paymentReceivedDate', type: 'date-local', sortable: true, hideDefaultActions: true},
                                { label: 'Amount Paid', fieldName: 'AmountPaid', type: 'Currency', sortable: true, hideDefaultActions: true},
                                { label: 'Vendor PO', fieldName: 'vendorPOUrl', type: 'url', sortable: true, hideDefaultActions: true,typeAttributes: {
                                    label: {fieldName: 'vendorPOName'},
                                    target: '_blank'
                                }}
                            ];

const columnsStartup = [{ label: 'Product', fieldName: 'productName', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true},
                        { label: 'Tag', fieldName: 'tag', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true, editable: true},
                        { label: 'Hide From Email', editable: true, fieldName: 'hideFromEmail', type: 'boolean', wrapText: true, hideDefaultActions: true, sortable: true},
                        { label: 'Code', fieldName: 'code', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true},
                        { label: 'Serial Number', fieldName: 'serialNumber', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true, editable: true},
                        { label: 'IOM Complete', editable: true, fieldName: 'iomComplete', type: 'boolean', wrapText: true, hideDefaultActions: true, sortable: true},
                        { label: 'Startup Scheduled', fieldName: 'startupSchedule', type: 'date-local', wrapText: true, hideDefaultActions: true, sortable: true, editable: true},
                        { label: 'Startup Completed', editable: true, fieldName: 'startupCompleted', type: 'date-local', wrapText: true, hideDefaultActions: true, sortable: true},
                        { label: 'Warranty', editable: true, fieldName: 'warranty', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true},
                        // { label: 'Warranty Type', fieldName: 'warrantyType', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true, editable: true},
                        { label: 'Warranty Type',
                        fieldName: 'warrantyType',
                        type: 'picklistColumn',
                        wrapText: true,
                        editable: true,
                        sortable: true,
                        typeAttributes: {
                            placeholder: 'select',
                            options: { fieldName: 'warrantyPicklist' },
                            value: 'warrantyType',
                        }
                        },
                        { label: 'Parts Covered', fieldName: 'partsCovered', type: 'text', wrapText: true, hideDefaultActions: true, sortable: true, editable: true},
                        { label: 'Warranty Start', editable: true, fieldName: 'warrantyStart', type: 'date-local', wrapText: true, hideDefaultActions: true, sortable: true},
                        { label: 'Warranty End', editable: true, fieldName: 'warrantyEnd', type: 'date-local', wrapText: true, hideDefaultActions: true, sortable: true}
                        ];

const columnLabourCostPosting = [{ label: 'Labor Posting', fieldName: '', type: 'text', hideDefaultActions: true},
                                { label: 'HRS', fieldName: 'Quantity__c', type: 'number', hideDefaultActions: true},
                                { label: 'HOURLY COST', fieldName: 'Unit_Cost__c', type: 'currency', hideDefaultActions: true},
                                { label: 'TOTAL COST', fieldName: 'Total_Cost__c', type: 'currency', hideDefaultActions: true},
                                { label: 'DESCRIPTION', fieldName: 'Description__c', type: 'text', hideDefaultActions: true}];
                            
const columnOtherCostPosting = [{ label: 'Labor Posting', fieldName: '', type: 'text', hideDefaultActions: true},
                                { label: 'HRS', fieldName: 'Quantity__c', type: 'number', hideDefaultActions: true},
                                { label: 'HOURLY COST', fieldName: 'Unit_Cost__c', type: 'currency', hideDefaultActions: true},
                                { label: 'TOTAL COST', fieldName: 'Total_Cost__c', type: 'currency', hideDefaultActions: true},
                                { label: 'DESCRIPTION', fieldName: 'Description__c', type: 'text', hideDefaultActions: true}];

export default class ProjectDetails extends NavigationMixin(LightningElement) {
    
    activeSections = ['A', 'B', 'C', 'D', 'E','parentGroup','BB2'];

    @api recordId;
    @track sharePointURL;  

    @track lstProjectStatus = [];
    @track lstAccounting = [];
    @track lstStartUpWarranty = [];
    
    @track lstSalesAndPurchaseOrders = [];
    @track lstScheduleTo = new Array();
    
    draftValuesProjectStatus = [];
    draftValuesStartUpWarranty = [];
    lstParentGroup = [];
    lstSubGroup = [];
    
    costPostingId;

    grandTotalSO = 0;
    grandTotalPO = 0;
    grandTotalIC = 0;
    grandTotalCost = 0;
    grandTotalMargin = 0;
    grandTotalMarginPercentage = 0;
    totalLabourJE = 0;
    totalLabourJEDebit = 0;
    totalLabourJECredit = 0;
    totalOtherJE = 0;
    totalOtherJEDebit = 0;
    totalOtherJECredit = 0;

    groupsubGroupMap = [];
    wrapperData;

   

    @track isSchedulePopupOpen = false;
    @track isSendEmailPopup = false;
    
    @track isLaborCostingPopupOpen = false;
    @track isOtherCostPostingPopupOpen = false;

    @track columns = columns;
    @track columnsStartup = columnsStartup;
    @track columnAccountingSeed = columnAccountingSeed;

    @track columnLabourPosting = columnLabourCostPosting;
    @track columnOtherPosting = columnOtherCostPosting;

    @track totalLaborCost;
    @track lstLaborPosting;

    @track totalOtherCost;
    @track lstOtherPosting;

    @track journalEntryList;
    @track journalEntryOtherList;
    @track inventoryCostList;
    lstGroupWrapper;

    @track activeFinancialQuote = new Object();

 
    defaultSortDirection = 'asc';
    
    sortDirectionProjectStatus = 'asc';
    sortedByProjectStatus;

    sortDirectionAccounting = 'asc';
    sortedByAccounting;

    sortDirectionStartUp = 'asc';
    sortedByStartUp;

    wiredProductLineItems = [];
    sendEvery = 'Monday';
    scheduleEndDate = '';
    emailschedulesToBeDeleted = new Array();

    totalInvoiceAmount;
    totalAmountPaid;
    lastSavedData;
    privateChildren = {}; //used to get the datatable picklist as private childern of customDatatable
    isComponentLoaded = false;

    @track submittalPicklist;
    @track warrantyPicklist;

    @wire(getObjectInfo, { objectApiName: LINE_ITEM_OBJECT })
    objectInfo;
 
    //fetch submittalPicklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: SUBMITTAL_FIELD
    })wireSubmittalPickList({ error, data }) {
        if (data) {
            this.submittalPicklist = data.values;
            console.log('the picklist value is ' + this.submittalPicklist);
        } else if (error) {
            console.log(error);
        }
    }

    //fetch warrantyPicklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: WARRANTY_FIELD
    })wireWarrantyPickList({ error, data }) {
        if (data) {
            this.warrantyPicklist = data.values;
            console.log('the picklist value is ' + this.warrantyPicklist);
        } else if (error) {
            console.log(error);
        }
    }

    renderedCallback() {
        if (!this.isComponentLoaded) {
            /* Add Click event listener to listen to window click to reset the picklist selection 
            to text view if context is out of sync*/
            window.addEventListener('click', (evt) => {
                console.log('in renderCallback handlewindowonclick');
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
            
        }
    }

    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    /*
    connectedCallback() {
        this.loadJson();
    }
    
    }
    loadJson() {
        getData({ projectId: this.recordId })
            .then(result => {
    */
    @wire(getData, {projectId:'$recordId' , pickList: '$submittalPicklist'}) projectDetailsWrapper(result) {    
        if(result.data) {
            let objProjectDetails = result.data;
            this.wrapperData = result.data;
            this.wiredProductLineItems = result;
            this.sharePointURL = objProjectDetails.sharePointUrl;
            this.scheduleEndDate = objProjectDetails.Schedule_End_Date__c;
            this.sendEvery = objProjectDetails.Schedule_On__c;

            this.lstProjectStatus = objProjectDetails.lstQuoteLineItems;
            this.lastSavedData = this.lstProjectStatus;
        
            this.lstAccounting = objProjectDetails.lstAccountingLineItem;
            this.totalInvoiceAmount = objProjectDetails.totalInvoiceAmount;
            this.totalAmountPaid = objProjectDetails.totalAmountPaid;

            this.lstStartUpWarranty = objProjectDetails.lstQuoteLineItems;
            
            this.totalLaborCost = objProjectDetails.laborPosting.totalCost;
            this.lstLaborPosting = objProjectDetails.laborPosting.lstCostPosting;

            this.totalOtherCost = objProjectDetails.otherPosting.totalCost;
            this.lstOtherPosting = objProjectDetails.otherPosting.lstCostPosting;
            
            this.activeFinancialQuote = objProjectDetails.activeFinancialQuote;

            this.journalEntryList = objProjectDetails.lstJournalEntry;

            this.journalEntryOtherList = objProjectDetails.lstOtherJournalEntry;
            this.lstGroupWrapper = JSON.parse(JSON.stringify(objProjectDetails.lstGroupWrapper));
            this.lstGroupWrapper.forEach( grpwrp => {
                grpwrp.subGroupList.forEach( subgrp =>{
                    subgrp.lstQuoteLineItems.forEach( lstItems => {
                        lstItems.submittalPicklist = this.submittalPicklist;
                        lstItems.warrantyPicklist = this.warrantyPicklist;
                    })
                })
            }

            )
            console.log('List of group Wrapper is ' + this.lstGroupWrapper);
        

            //Journal Entry ProjectPostingType = Labor Posting Records
            if(objProjectDetails.lstJournalEntry.length > 0){  
                for(let i = 0; i < objProjectDetails.lstJournalEntry.length; i++) {
                    if(objProjectDetails.lstJournalEntry[i].debit){
                        this.totalLabourJEDebit += objProjectDetails.lstJournalEntry[i].debit;
                    }else{
                        this.totalLabourJECredit += objProjectDetails.lstJournalEntry[i].credit;
                    }
                }
                this.totalLabourJE = this.totalLabourJEDebit - this.totalLabourJECredit;
                console.log('total Labor labour:- '+ this.totalLabourJE);
            }
            
            //Journal Entry ProjectPostingType = Other Posting Record
            if(objProjectDetails.lstOtherJournalEntry.length > 0){  
                for(let i = 0; i < objProjectDetails.lstOtherJournalEntry.length; i++) {
                    if(objProjectDetails.lstOtherJournalEntry[i].debit){
                        this.totalOtherJEDebit += objProjectDetails.lstOtherJournalEntry[i].debit;
                    }else{
                        this.totalOtherJECredit += objProjectDetails.lstOtherJournalEntry[i].credit;
                    }
                }
                this.totalOtherJE = this.totalOtherJEDebit - this.totalOtherJECredit;
                console.log('total Other labour:- '+ this.totalOtherJE);
            }

            //So/Po/Ic
            if(objProjectDetails.lstSOAndPODetails) {
                let lstSalesAndPO = new Array();

                let gtSO = 0;
                let gtPO = 0;
                let gtIC = 0;

                for(let i = 0; i < objProjectDetails.lstSOAndPODetails.length; i++) {
                    let so = Object.assign({}, objProjectDetails.lstSOAndPODetails[i]);
                    so.Name = (so.Sales_Order_Number__c != null && so.Sales_Order_Number__c != '')
                                ? so.Sales_Order_Number__c
                                : so.Name;

                    console.log('po-list---'+so.Purchase_Orders__r);
                    so.soUrl = '/' + so.Id;
                    let totalPO = 0;
                    let totalIC = 0;
                    
                    if(so.Purchase_Orders__r) {
                        let lstPO = new Array();
                        
                        for(let j = 0; j < so.Purchase_Orders__r.length; j++) {
                            let po = Object.assign({}, so.Purchase_Orders__r[j]);
                            po.Name = (po.Purchase_Order_Number__c != null && po.Purchase_Order_Number__c != '')
                                        ? po.Purchase_Order_Number__c
                                        : po.Name;
                            po.poUrl = '/' + po.Id;
                            lstPO.push(po);
                            totalPO += po.AcctSeedERP__Total__c;
                            gtPO += po.AcctSeedERP__Total__c;
                        }
                        so.Purchase_Orders__r = lstPO;
                    }
            
                    //InventoryCost under SO/PO.
                    if(objProjectDetails.lstInventoryCostWithSO){
                        let lstInverCost = new Array();
                        for(let i=0; i< objProjectDetails.lstInventoryCostWithSO.length; i++){
                            let icw =  Object.assign({}, objProjectDetails.lstInventoryCostWithSO[i]);
                            if(icw.salesOrderID == so.Id){
                                for(let j=0 ; j < icw.inventoryCostList.length ; j++){
                                    let ic = Object.assign({}, icw.inventoryCostList[j]);
                                    ic.icUrl = '/' + ic.Id;
                                    totalIC += ic.AcctSeed__Unit_Cost__c;
                                    gtIC += ic.AcctSeed__Unit_Cost__c;
                                    console.log('Total for inv cost :- '+gtIC);
                                    lstInverCost.push(ic);
                                }
                            }
                        }
                        so.invCost = lstInverCost;
                    }
                   
                    so.poTotal = totalPO.toFixed(2);
                    so.icTotal = totalIC.toFixed(2);
                    so.poAndICTotal = parseFloat(so.poTotal) + parseFloat(so.icTotal);
                    console.log('Totals for Po+Ic :- ' +so.poAndICTotal);  

                    so.margin = (so.AcctSeedERP__Total__c - so.poAndICTotal).toFixed(2);
                    if(so.margin != 0 && so.AcctSeedERP__Total__c != 0) {
                        so.marginPercentage = 100 - ((so.poAndICTotal * 100)/so.AcctSeedERP__Total__c);
                        so.marginPercentage = so.marginPercentage.toFixed(2);
                    } else {
                        so.marginPercentage = 0;
                    }
                    
                    gtSO += so.AcctSeedERP__Total__c;
                    lstSalesAndPO.push(so);
                }
                this.lstSalesAndPurchaseOrders = lstSalesAndPO;
                this.grandTotalSO = gtSO.toFixed(2);
                this.grandTotalPO = gtPO.toFixed(2); 
                this.grandTotalIC = gtIC.toFixed(2);
                
                //Grand totals of Total Cost
                this.grandTotalCost = this.totalLabourJE + this.totalOtherJE + parseFloat(this.grandTotalPO) + parseFloat(this.grandTotalIC); 
                this.grandTotalMargin =  this.grandTotalSO - this.grandTotalCost; 

                if(gtSO != null && gtSO != 0){
                    this.grandTotalMarginPercentage = ((this.grandTotalMargin * 100)/ this.grandTotalSO);
                }else{
                    this.grandTotalMarginPercentage = 0;
                }
                this.grandTotalMarginPercentage = this.grandTotalMarginPercentage.toFixed(2);
                
            }

            if(objProjectDetails.lstScheduleTo) {
                let newListScheduleTo = new Array();

                for(let index = 0; index < objProjectDetails.lstScheduleTo.length; index++) {
                    let sch = Object.assign({}, objProjectDetails.lstScheduleTo[index]);
                    let isUservalue = false;
                    let isLastvalue = false;
                    if(sch.Schedule_Type__c == 'User') {
                        isUservalue = true;
                        sch.isUser = true;
                    } else {
                        sch.isUser = false;
                    }

                    if(index == (objProjectDetails.lstScheduleTo.length -1)) {
                        isLastvalue = true;
                        sch.isLast = true;
                        sch.lenght = objProjectDetails.lstScheduleTo.length;
                    }

                    //newListScheduleTo.push(sch);
                    newListScheduleTo.push({
                        Schedule_Type__c : sch.Schedule_Type__c, 
                        isUser:isUservalue,
                        isLast:isLastvalue,
                        Contact__c:sch.Contact__c,
                        User__c:sch.User__c,
                        indx : index,
                        Id:sch.Id,
                        //id:sch.Id,
                        Project__c:this.recordId
                    })

                }

                this.lstScheduleTo = newListScheduleTo;
            }

            this.syncQuoteId = objProjectDetails.syncQuoteId;
            this.activeFinancialQuoteId = objProjectDetails.activeFinancialQuoteId;
        }         
        
    }
    
    handleChangeRecipientType(event) {
        console.log('value=>'+this.lstScheduleTo[event.target.name].isUser);
        console.log('value=>'+this.lstScheduleTo[event.target.name]["isUser"]);
        console.log(event.target.value);
        console.log(event.target.name);
        this.lstScheduleTo[event.target.name].Schedule_Type__c = event.target.value;
        if(event.target.value == 'User') {
            this.lstScheduleTo[event.target.name].isUser = true;
        } else {
            this.lstScheduleTo[event.target.name].isUser = false;
        }
        
    }

    openSchedulePopup() {
        this.isSchedulePopupOpen = true;
        console.log('size=>'+this.lstScheduleTo.length);
        if(this.lstScheduleTo.length == 0) {
            this.lstScheduleTo.push({Schedule_Type__c: '',
            Contact__c:null,
            User__c:null,
            isLast:true,
            isUser:true,
            Project__c : this.recordId});

        }

    }   

    closeSchedulePopup() {
        this.isSchedulePopupOpen = false;
    }

    handleNewLaborPosting(event) {
        this.costPostingId = null;
        this.isLaborCostingPopupOpen = true;
    }

    saveLaborPosting(event) {

    }

    handleNewOtherPosting(event) {
        this.costPostingId = null;
        this.isOtherCostPostingPopupOpen = true;
    }

    closeLaborCostingModal() {
        this.isLaborCostingPopupOpen = false;
    }

    closeOtherCostingModal() {
        this.isOtherCostPostingPopupOpen = false;
    }

    handleSubmit(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Type__c = 'Other';
        fields.Project__c = this.recordId;
        this.template.querySelector(".otherPosting").submit(fields);
        this.isOtherCostPostingPopupOpen = false;
    }

    handleSubmitLaborPosting(event) {
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Type__c = 'Labor';
        fields.Project__c = this.recordId;
        this.template.querySelector(".laborPosting").submit(fields);
        this.isLaborCostingPopupOpen = false;

    }

    handleSuccessLaborPosting() {
        getCostPosting({type: 'Labor', projectId: this.recordId}).then( result => {
            this.totalLaborCost = result.totalCost; 
            this.lstLaborPosting = [...result.lstCostPosting];
            this.grandTotalCost = this.totalLaborCost + this.totalOtherCost + parseFloat(this.grandTotalPO); // GrandTotal
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Labor cost posting created successfully.',
                    variant: 'success'
                })
            ); 
        });
    }

    handleSuccessOtherPosting() {
        getCostPosting({type: 'Other', projectId: this.recordId}).then( result => {
            this.totalOtherCost = result.totalCost; 
            this.lstOtherPosting = [...result.lstCostPosting];
            this.grandTotalCost = this.totalLaborCost + this.totalOtherCost + parseFloat(this.grandTotalPO); // GrandTotal
            //when ever grandTotalCost change it effect grand Marign and Margin % also need to update
            this.grandTotalMargin =  this.grandTotalSO - this.grandTotalCost;  
            this.grandTotalMarginPercentage = ((this.grandTotalMargin * 100)/ this.grandTotalSO).toFixed(2);
          
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Other cost posting created successfully.',
                    variant: 'success'
                })
            );
        });
    }   

    handleEditLaborPosting(event) {
        this.isLaborCostingPopupOpen = true;
        this.costPostingId = event.currentTarget.dataset.id;
        
    }

    handleEditOtherPosting(event) {
        this.isOtherCostPostingPopupOpen = true;
        this.costPostingId = event.currentTarget.dataset.id;
    }

    handleDeleteOtherPosting(event) {

        let costId = event.currentTarget.dataset.id;

        deleteCostPosting({type: 'Other', costId: costId, projectId: this.recordId}).then( result => {
            this.totalOtherCost = result.totalCost;
            this.lstOtherPosting = [...result.lstCostPosting];
            this.grandTotalCost = this.totalLaborCost + this.totalOtherCost + parseFloat(this.grandTotalPO); //GrandTotal
            this.grandTotalMargin =  this.grandTotalSO - this.grandTotalCost; 
            this.grandTotalMarginPercentage = ((this.grandTotalMargin * 100)/ this.grandTotalSO).toFixed(2);
             
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Cost posting deleted successfully.',
                    variant: 'success'
                })
            );
        });
    }

    handleDeleteLaborPosting(event) {
        let costId = event.currentTarget.dataset.id;

        deleteCostPosting({type: 'Labor', costId: costId, projectId: this.recordId}).then( result => {
            this.totalLaborCost = result.totalCost; 
            this.lstLaborPosting = [...result.lstCostPosting];
            this.grandTotalCost = this.totalLaborCost + this.totalOtherCost + parseFloat(this.grandTotalPO); //Grandtotal
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Cost posting deleted successfully.',
                    variant: 'success'
                })
            );
        });
    } 

    onSortProjectStatus(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.lstProjectStatus];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.lstProjectStatus = cloneData;
        this.sortDirectionProjectStatus = sortDirection;
        this.sortedByProjectStatus = sortedBy;
    }

    onSortAccounting(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.lstAccounting];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.lstAccounting = cloneData;
        this.sortDirectionAccounting = sortDirection;
        this.sortedByAccounting = sortedBy;
    }

    onSortStartUp(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.lstStartUpWarranty];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.lstStartUpWarranty = cloneData;
        this.sortDirectionStartUp = sortDirection;
        this.sortedByStartUp = sortedBy;
    }

    // Used to sort the 'Age' column
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    viewRecord(event) {
        alert(event.target.value);
        // Navigate to Account record page
        this[NavigationMixin.Navigate]({
            
            type: 'standard__recordPage',
            attributes: {
                "recordId": event.target.value,
                "objectApiName": "AcctSeedERP__Sales_Order__c",
                "actionName": "view"
            },
        });
    }

    async handleSaveProjectStatus(event) {

        const updatedFields = event.detail.draftValues;
        console.log('result save---'+JSON.stringify(updatedFields));
 
        let lstUpdatedRecords = new Array();

        for(let i=0; i < updatedFields.length; i++) {
            let updatedRecord = updatedFields[i];
            console.log('The updateREcord is ' + JSON.stringify(updatedRecord));
            if(updatedRecord.releaseDate !== undefined && updatedRecord.releaseDate !== null && updatedRecord.releaseDate !== '') {
                updatedRecord.Release_Date__c = updatedRecord.releaseDate.slice(0,10);
            } else if(updatedRecord.releaseDate === null || updateRecord.releaseDate === '') {
                updatedRecord.Release_Date__c = null;
            }
            if(updatedRecord.estimateShipDate !== undefined && updatedRecord.estimateShipDate !== null && updatedRecord.estimateShipDate !== '') {
                updatedRecord.Estimated_Ship_Date__c = updatedRecord.estimateShipDate.slice(0,10);
            } else if(updatedRecord.estimateShipDate === null || updatedRecord.estimateShipDate === '') {
                updatedRecord.Estimated_Ship_Date__c = null;
            }
            if(updatedRecord.actShipDate !== undefined && updatedRecord.actShipDate !== null && updatedRecord.actShipDate !== '') {
                updatedRecord.Act_Ship__c = updatedRecord.actShipDate.slice(0,10);
            } else if(updatedRecord.actShipDate === null || updatedRecord.actShipDate === '') {
                updatedRecord.Act_Ship__c = null;
            }
            if(updatedRecord.hideFromEmail !== undefined && updatedRecord.hideFromEmail !== null) {
                updatedRecord.Hide_Line_On_Email_Startup__c = updatedRecord.hideFromEmail;
            }
            if(updatedRecord.tracking !== undefined && updatedRecord.tracking !== null) {
                updatedRecord.Tracking_Number__c = updatedRecord.tracking;
            }
            if(updatedRecord.stringNote !== undefined && updatedRecord.stringNote !== null) {
                updatedRecord.Note__c = updatedRecord.stringNote;
            }
            if(updatedRecord.submittalStatus !== undefined && updatedRecord.submittalStatus !== null) {
                updatedRecord.Submittals__c = updatedRecord.submittalStatus;
            }
            
            lstUpdatedRecords.push(updatedRecord);
        }
        console.log('result save-11--'+JSON.stringify(lstUpdatedRecords));
        await saveProjectStatus( { data: lstUpdatedRecords } )
        .then( result => {

            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Project updated successfully.',
                    variant: 'success'
                })
            );
            
            refreshApex( this.wiredProductLineItems ).then( () => {
                this.draftValuesProjectStatus = [];
            });        

        }).catch( error => {

            console.log( 'Error is ' + JSON.stringify( error ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something went wrong, please contact your admin.',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        });

    }

    async handleSaveStartup(event) {

        const updatedFields = event.detail.draftValues;

        let lstUpdatedRecords = new Array();

        for(let i=0; i < updatedFields.length; i++) {
            let updatedRecord = updatedFields[i];

            if(updatedRecord.startupSchedule !== undefined && updatedRecord.startupSchedule !== null && updatedRecord.startupSchedule !== '') {
                updatedRecord.Schedule_Startup_Date__c = updatedRecord.startupSchedule.slice(0,10);
            } else if(updatedRecord.startupSchedule === null || updatedRecord.startupSchedule === '') {
                updatedRecord.Schedule_Startup_Date__c = null;
            }
            if(updatedRecord.startupCompleted !== undefined && updatedRecord.startupCompleted !== null && updatedRecord.startupCompleted !== '') {
                updatedRecord.Completed_Startup_Date__c = updatedRecord.startupCompleted.slice(0,10);
            } else if(updatedRecord.startupCompleted === null || updatedRecord.startupCompleted === '') {
                updatedRecord.Completed_Startup_Date__c = null;
            }
            if(updatedRecord.warrantyStart !== undefined && updatedRecord.warrantyStart !== null && updatedRecord.warrantyStart !== '') {
                updatedRecord.Warranty_Start_Date__c = updatedRecord.warrantyStart.slice(0,10);
            } else if(updatedRecord.warrantyStart === null || updatedRecord.warrantyStart === '') {
                updatedRecord.Warranty_Start_Date__c = null;
            }
            if(updatedRecord.warrantyEnd !== undefined && updatedRecord.warrantyEnd !== null && updatedRecord.warrantyEnd !== '') {
                updatedRecord.Warranty_End_Date__c = updatedRecord.warrantyEnd.slice(0,10);
            } else if(updatedRecord.warrantyEnd === null || updatedRecord.warrantyEnd === '') {
                updatedRecord.Warranty_End_Date__c = null;
            }
            if(updatedRecord.hideFromEmail !== undefined && updatedRecord.hideFromEmail !== null) {
                updatedRecord.Hide_Line_On_Email_Startup__c = updatedRecord.hideFromEmail;
            }
            if(updatedRecord.tag !== undefined && updatedRecord.tag !== null) {
                updatedRecord.Tag__c = updatedRecord.tag;
            }
            if(updatedRecord.serialNumber !== undefined && updatedRecord.serialNumber !== null) {
                updatedRecord.Serial_Number__c = updatedRecord.serialNumber;
            }
            if(updatedRecord.iomComplete !== undefined && updatedRecord.iomComplete !== null) {
                updatedRecord.IOM_Completed__c = updatedRecord.iomComplete;
            }
            if(updatedRecord.warranty !== undefined && updatedRecord.warranty !== null) {
                updatedRecord.Warranty_Term__c = updatedRecord.warranty;
            }
            if(updatedRecord.warrantyType !== undefined && updatedRecord.warrantyType !== null) {
                updatedRecord.Warranty_Type__c = updatedRecord.warrantyType;
            }
            if(updatedRecord.partsCovered !== undefined && updatedRecord.partsCovered !== null) {
                updatedRecord.Warranty_Parts_Covered__c = updatedRecord.partsCovered;
            }
            lstUpdatedRecords.push(updatedRecord);
        }

        await saveProjectStatus( { data: lstUpdatedRecords } )
        .then( result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Project updated successfully.',
                    variant: 'success'
                })
            );
            
            refreshApex( this.wiredProductLineItems ).then( () => {
                this.draftValuesStartUpWarranty = [];
            });        

        }).catch( error => {

            console.log( 'Error is ' + JSON.stringify( error ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something went wrong, please contact your admin.',
                    message: error.body.message,
                    variant: 'error'
                })
            );

        });

    }

    handleSuccessProjectSave(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Project updated successfully.',
                variant: 'success'
            })
        );
    }

    onAddUser(event) {
        console.log('this.lstScheduleTo=>'+this.lstScheduleTo[event.target.value].isLast);
        this.lstScheduleTo[event.target.value].isLast = false;
        this.lstScheduleTo.push({Schedule_Type__c: 'User',
                                Contact__c:null,
                                User__c:null,
                                isLast:true,
                                isUser:true,
                                Project__c:this.recordId,
                                indx:this.lstScheduleTo.length});
    }

    onDeleteUser(event) {

        if(this.lstScheduleTo.length > 1) {
            
            let indexToRemove = event.target.value;
            
            if(this.lstScheduleTo[indexToRemove].Id != '' && typeof this.lstScheduleTo[indexToRemove].Id !== "undefined") {
                this.emailschedulesToBeDeleted.push({
                    Id: this.lstScheduleTo[indexToRemove].Id
                })
            }
            
            this.lstScheduleTo.splice(indexToRemove,1);    
            
            let lastIndex = this.lstScheduleTo.length - 1; 
            this.lstScheduleTo[lastIndex].isLast = true;
        }
        console.log(this.emailschedulesToBeDeleted);
    }

    GoToSharePointFolder() {
        window.open(this.sharePointURL,'_blank');
    }

    
    saveEmailSchedules(event) {
        console.log('save=>'+JSON.stringify(this.lstScheduleTo));
        console.log('sendEvery'+ this.sendEvery);
        console.log('schedule'+this.scheduleEndDate);
        console.log('emailschedulesToBeDeleted=>'+this.emailschedulesToBeDeleted);
        let projectObj = {
            Id:this.recordId,
            Schedule_End_Date__c:this.scheduleEndDate,
            Schedule_On__c: this.sendEvery
        }
        
        updateEmailSchedules( { project: projectObj, emailSchedules: this.lstScheduleTo, emailScheduleToDelete:this.emailschedulesToBeDeleted}).then(result => {   
            const toastEvnt = new ShowToastEvent( {
                title: 'Email schedules updated',
                message: 'success',
                variant: 'success'
                });
                this.dispatchEvent (toastEvnt);
                this.emailschedulesToBeDeleted = [];
        }).catch(error => {
            console.log('inside error='+JSON.stringify(error));
        });
        
    }

    openSendEmailPopup() {
        this.isSendEmailPopup = true;
    }

    closeSendEmailPopup() {
        this.isSendEmailPopup = false;
    }

    sendEmail() {
        console.log('call send email methd');
        let error = '';
        error = this.template.querySelector("c-email-Send").SendEmailJS(); 
        //this.closeSendEmailPopup();
    }

    updateDataValues(updateItem) {
        let copyData = [... this.lstProjectStatus];
        copyData.forEach(item => {
            if (item.id === updateItem.id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.lstProjectStatus = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValuesProjectStatus];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.id === updateItem.id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValuesProjectStatus = [...copyDraftValues];
        } else {
            this.draftValuesProjectStatus = [...copyDraftValues, updateItem];
        }
        console.log('inside updateDraftVAlues ' + this.draftValuesProjectStatus);
    }

    //listener handler to get the context and data
    //updates datatable
    picklistChanged(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem = { Id: dataRecieved.context, Submittals__c: dataRecieved.value };
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    /*
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        this.updateDraftValues(event.detail.draftValues[0]);
    }
    */

    get ScheduleEmailUserType() {
        return [
            { label: 'User', value: 'User' },
            { label: 'Contact', value: 'Contact' }
        ];
    }

    handleChangeScheduleTypeChage(event) {
        console.log('index'+event.target.name);
        console.log('di='+event.target.dataset.index);
        console.log('field being updated'+event.target.fieldName);
        console.log('new value'+event.target.value);
        let index = event.target.dataset.index;
        if(event.target.fieldName == 'Schedule_Type__c') {
            console.log('inside change type');
            this.lstScheduleTo[index].Schedule_Type__c = event.target.value;
            if(event.target.value == 'User') {
                this.lstScheduleTo[index].isUser = true;
                this.lstScheduleTo[index].Contact__c = null;
            } else {
                this.lstScheduleTo[index].isUser = false;
                this.lstScheduleTo[index].User__c = null;
            }
        } else if(event.target.fieldName == 'User__c') {

            this.lstScheduleTo[index].User__c = event.target.value;
        } else if(event.target.fieldName == 'Contact__c') {

            this.lstScheduleTo[index].Contact__c = event.target.value;

        } else if (event.target.fieldName == 'Schedule_End_Date__c') {
            this.scheduleEndDate = event.target.value;
        } else if (event.target.fieldName == 'Schedule_On__c') {
            this.sendEvery = event.target.value;
        }
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-datatable-picklist', context);
    }

    //create object value of datatable picklist markup to allow to call callback function with window click event listener
    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    // Event to register the datatable picklist mark up.
    handleItemRegister(event) {
        event.stopPropagation(); //stops the window click to propagate to allow to register of markup.
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    handleChange(event) {
        event.preventDefault();
        this.accountId = event.target.value;
        this.showSpinner = true;
    }

    handleCancel(event) {
        event.preventDefault();
        this.lstProjectStatus = JSON.parse(JSON.stringify(this.lastSavedData));
        this.handleWindowOnclick('reset');
        // this.draftValues = [];
        this.draftValuesProjectStatus = [];
    }
	
	handleCellChange(event) {
        event.preventDefault();
        console.log('Inside cell change ');
        this.updateDraftValues(event.detail.draftValues[0]);
        
    }

    handleBlur(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('Inside handleblur ' + JSON.stringify(dataRecieved));
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Submittal Status':
                updatedItem = {
                    Id: dataRecieved.context,
                    Submittals__c: dataRecieved.value
                };
                break;
        }
    }

    //Captures the changed picklist value and updates the records list variable.
    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        console.log('Inside handle change ' + dataRecieved);
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Submittal Status':
                updatedItem = {
                    Id: dataRecieved.context,
                    Submittals__c: dataRecieved.value
                };
                // Set the cell edit class to edited to mark it as value changed.
                this.setClassesOnData(
                    dataRecieved.context,
                    'stageClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    
    handleEdit(event) {
        event.preventDefault();
        console.log('inside handleEdit');
        let dataRecieved = event.detail.data;
        console.log('dataRecieve in ' + JSON.stringify(dataRecieved));
        // this.template.querySelector('.slds-popover_edit');
        this.template.querySelector("c-my-Custom-Data-Table").focus();
        this.handleWindowOnclick(dataRecieved.context);
        switch (dataRecieved.label) {
            case 'Submittal Status':
                this.setClassesOnData(
                    dataRecieved.context,
                    'stageClass',
                    'slds-cell-edit'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        };
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.lstProjectStatus = JSON.parse(JSON.stringify(this.lstProjectStatus));
        this.lstProjectStatus.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }
}