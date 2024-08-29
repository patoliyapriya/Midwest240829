import { LightningElement, track, wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getData from '@salesforce/apex/ProjectDetails.getData';
import getProjectCommissionDetails from '@salesforce/apex/ProjectDetails.getProjectCommissionDetails';

export default class ProjectCommission extends LightningElement {

    wiredProjectCommissionResult;
    tabValue;
    grandTotalPO = 0;
    grandTotalIC = 0;
    opportunityName;
    opportunityNumber;
    ledger;

    @track isLoading = true;
    @track showCommissionTable;
    @track archived;
    @track totalBooking = 0;
    @track companyBookingAmount = 0;
    @track totalCogs = 0;
    @track totalMargin = 0;
    @track invoicedAmount = 0;
    @track invoicePercentage = 0;
    @track amountPaid = 0;
    @track amountInvoicedPaidOn = 0;
    @track companyBookingsPaidOn = 0;
    @track totalLabourJEDebit = 0;
    @track totalOtherJEDebit = 0;
    @track totalLabourJECredit = 0;
    @track totalOtherJECredit = 0;
    @track totalLabourJE = 0;
    @track totalOtherJE = 0;

    @api recordId;
    @api grandTotalCost = 0;
    @track totalOtherCost;
    @track lstOtherPosting;
    @track journalEntryList;
    @track journalEntryOtherList;
    @track inventoryCostList;

    @track tableData = [];
    @track salesEngSplitList = [];

    handleRefresh() {
        console.log('Inside Refresh');
        refreshApex(this.wiredProjectCommissionResult);
    }

    handleExport() {
        this.handleExtractData();
        console.log('the data in table is ' + this.tableData);
        let csvContent = '';

    // Get the table headers
    const headersRowData = [];
    const headerRow = Array.from(this.template.querySelectorAll('table thead tr'));

    headerRow.forEach(header => {
        const headers = Array.from(header.querySelectorAll('th')).map(header => {
            const colspan = header.getAttribute('colspan') || 1;
            return {
                text: header.innerText,
                colspan: parseInt(colspan)
            };
        });
        headersRowData.push(headers);
    })

    headersRowData.forEach(headerRowData => {
        headerRowData.forEach(header => {
            for (let i = 0; i < header.colspan; i++) {
                csvContent += header.text + ',';
            }
        });
        csvContent += '\n';
    });



    // Construct the CSV header row


    // Get the table data rows
    const dataRows = Array.from(this.template.querySelectorAll('table tbody tr'));

    // Construct the CSV data rows
    dataRows.forEach(row => {
        const rowData = Array.from(row.querySelectorAll('td')).map(cell => {
            const formattedNumber = cell.querySelector('lightning-formatted-number');
            return formattedNumber ? formattedNumber.value : cell.innerText;
        });
        csvContent += rowData.join(',') + '\n';
    });

    // Create a Blob and download link
    const blob = new Blob([csvContent], { type: 'application/octet-stream' });
    const filename = 'table_data.csv';
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('download', filename);
    link.click();
    }

    handleExtractData() {
        const tableElement = this.template.querySelector('table');
        const rows = tableElement.querySelectorAll('tr');

        const extractedData = [];
        for (let i = 1; i < rows.length; i++) { // Start from index 1 to skip the header row
            const cells = rows[i].querySelectorAll('td');
            const rowData = [];

            for (let j = 0; j < cells.length; j++) {
                rowData.push(cells[j].innerText);
            }

            extractedData.push(rowData);
        }

        this.tableData = extractedData;
    }


    @wire(getData, { projectId: '$recordId' }) projectDetailsWrapper(result) {
        if (result.data) {
            let objProjectDetails = result.data;
            this.totalOtherCost = objProjectDetails.otherPosting.totalCost;
            this.lstOtherPosting = objProjectDetails.otherPosting.lstCostPosting;
            this.journalEntryList = objProjectDetails.lstJournalEntry;
            this.journalEntryOtherList = objProjectDetails.lstOtherJournalEntry;

            if (objProjectDetails.lstJournalEntry.length > 0) {
                for (let i = 0; i < objProjectDetails.lstJournalEntry.length; i++) {
                    if (objProjectDetails.lstJournalEntry[i].debit) {
                        this.totalLabourJEDebit += objProjectDetails.lstJournalEntry[i].debit;
                    } else {
                        this.totalLabourJECredit += objProjectDetails.lstJournalEntry[i].credit;
                    }
                }
                this.totalLabourJE = this.totalLabourJEDebit - this.totalLabourJECredit;
            }

            //Journal Entry ProjectPostingType = Other Posting Record
            if (objProjectDetails.lstOtherJournalEntry.length > 0) {
                for (let i = 0; i < objProjectDetails.lstOtherJournalEntry.length; i++) {
                    if (objProjectDetails.lstOtherJournalEntry[i].debit) {
                        this.totalOtherJEDebit += objProjectDetails.lstOtherJournalEntry[i].debit;
                    } else {
                        this.totalOtherJECredit += objProjectDetails.lstOtherJournalEntry[i].credit;
                    }
                }
                this.totalOtherJE = this.totalOtherJEDebit - this.totalOtherJECredit;
            }

            if (objProjectDetails.lstSOAndPODetails) {
                let lstSalesAndPO = new Array();

                let gtSO = 0;
                let gtPO = 0;
                let gtIC = 0;

                for (let i = 0; i < objProjectDetails.lstSOAndPODetails.length; i++) {
                    let so = Object.assign({}, objProjectDetails.lstSOAndPODetails[i]);
                    so.Name = (so.Sales_Order_Number__c != null && so.Sales_Order_Number__c != '')
                        ? so.Sales_Order_Number__c
                        : so.Name;

                    so.soUrl = '/' + so.Id;
                    let totalPO = 0;
                    let totalIC = 0;

                    if (so.Purchase_Orders__r) {
                        let lstPO = new Array();
                        for (let j = 0; j < so.Purchase_Orders__r.length; j++) {
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
                    if (objProjectDetails.lstInventoryCostWithSO) {
                        let lstInverCost = new Array();
                        for (let i = 0; i < objProjectDetails.lstInventoryCostWithSO.length; i++) {
                            let icw = Object.assign({}, objProjectDetails.lstInventoryCostWithSO[i]);
                            if (icw.salesOrderID == so.Id) {
                                for (let j = 0; j < icw.inventoryCostList.length; j++) {
                                    let ic = Object.assign({}, icw.inventoryCostList[j]);
                                    ic.icUrl = '/' + ic.Id;
                                    totalIC += ic.AcctSeed__Unit_Cost__c;
                                    gtIC += ic.AcctSeed__Unit_Cost__c;
                                    lstInverCost.push(ic);
                                }
                            }
                        }
                        so.invCost = lstInverCost;
                    }

                    so.poTotal = totalPO.toFixed(2);
                    so.icTotal = totalIC.toFixed(2);
                    so.poAndICTotal = parseFloat(so.poTotal) + parseFloat(so.icTotal);
                    // before (so.AcctSeedERP__Total__c - so.poTotal)
                    so.margin = (so.AcctSeedERP__Total__c - so.poAndICTotal).toFixed(2);
                    if (so.margin != 0 && so.AcctSeedERP__Total__c != 0) {
                        so.marginPercentage = 100 - ((so.poAndICTotal * 100) / so.AcctSeedERP__Total__c);
                        so.marginPercentage = so.marginPercentage.toFixed(2);
                    } else {
                        so.marginPercentage = 0;
                    }

                    gtSO += so.AcctSeedERP__Total__c;
                    lstSalesAndPO.push(so);
                }
                this.lstSalesAndPurchaseOrders = lstSalesAndPO;
                // this.grandTotalSO = gtSO.toFixed(2);
                this.grandTotalPO = gtPO.toFixed(2);
                this.grandTotalIC = gtIC.toFixed(2);

                this.grandTotalCost = this.totalLabourJE + this.totalOtherJE + parseFloat(this.grandTotalPO) + parseFloat(this.grandTotalIC);
                // this.grandTotalMargin =  this.grandTotalSO - this.grandTotalCost; 
                // if(gtSO != null && gtSO != 0){
                //     this.grandTotalMarginPercentage = ((this.grandTotalMargin * 100)/ this.grandTotalSO);
                // }else{
                //     this.grandTotalMarginPercentage = 0;
                // }
                // this.grandTotalMarginPercentage = this.grandTotalMarginPercentage.toFixed(2);
            }
            // this.syncQuoteId = objProjectDetails.syncQuoteId;
            // this.activeFinancialQuoteId = objProjectDetails.activeFinancialQuoteId;

        }
    }

    @wire(getProjectCommissionDetails, { projectId: '$recordId', grandTotalCost: '$grandTotalCost' }) projectCommissionDetailsWrapper(result) {
        this.wiredProjectCommissionResult = result;
        if (result.data) {
            let objProjectCommission = result.data;
            console.log('the data is ' + objProjectCommission);
            this.showCommissionTable = objProjectCommission.showCommissionTable;
            this.opportunityName = objProjectCommission.opportunityName;
            this.opportunityNumber = objProjectCommission.opportunityNumber;
            this.ledger = objProjectCommission.ledger;
            this.totalBooking = objProjectCommission.totalBooking;
            this.companyBookingAmount = objProjectCommission.companyBookingAmount;
            this.totalCogs = objProjectCommission.totalCogs;
            this.totalMargin = objProjectCommission.totalMargin;
            this.invoicedAmount = objProjectCommission.invoicedAmount;
            this.invoicePercentage = objProjectCommission.invoicePercentage;
            this.amountPaid = objProjectCommission.amountPaid;
            this.amountInvoicedPaidOn = objProjectCommission.amountInvoicedPaidOn;
            this.companyBookingsPaidOn = objProjectCommission.companyBookingsPaidOn;
            this.salesEngSplitList = objProjectCommission.salesEngSplitList;
            this.archived = objProjectCommission.archived;
            this.isLoading = false; 
        }
    }
}