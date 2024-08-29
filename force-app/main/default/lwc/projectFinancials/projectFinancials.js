import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getData from '@salesforce/apex/ProjectDetails.getData';
import getProjectFinancialDetails from '@salesforce/apex/ProjectDetails.getProjectFinancialDetails';
import getCostPosting from '@salesforce/apex/ProjectDetails.getCostPosting';


export default class ProjectDetails extends LightningElement {

    @api recordId;

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

    opportunityName;
    opportunityNumber;
    ledger;
    projectManager;
    finalInvoicedPercentage = 0;
    commissionInvoiced = 0;
    brInvoiced = 0;
    deffered = 0;
    expensesToAccrue = 0;
    costToBeExpensed = 0;
    amountUnderBilled = 0;
    moveExpensesToWip = 0;
    wiredProjectFinancialResult;


    @track lstSalesAndPurchaseOrders = [];

    @track asSoldQuote = new Object();
    @track activeFinancialQuote = new Object();

    @track total = new Object();
    @track salesEngSplitList = [];
    @track showCommissionTable;
    @track totalOtherCost;
    @track lstOtherPosting;
    @track journalEntryList;
    @track journalEntryOtherList;
    @track inventoryCostList;

    handleRefresh() {
        console.log('Inside Refresh');
        refreshApex(this.wiredProjectFinancialResult);
    }

    handleExport() {
        this.handleExtractData();
        console.log('the data in table is ' + this.tableData);
        let csvContent = '';

        // Get the table headers
        const headersRowData = [];
        const headerRow = Array.from(this.template.querySelectorAll('table[data-id="expTbl"] thead tr'));

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
        const dataRows = Array.from(this.template.querySelectorAll('table[data-id="expTbl"] tbody tr'));

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
        console.log('Inside handle Extract');
        const tableElement = this.template.querySelector('[data-id="expTbl"]');
        console.log('After ' + tableElement);
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


    @wire(getProjectFinancialDetails, { projectId: '$recordId', grandTotalCost: '$grandTotalCost' }) projectFinancialDetailsWrapper(result) {
        this.wiredProjectFinancialResult = result;
        if (result.data) {
            let objProjectFinancial = result.data;
            this.showCommissionTable = objProjectFinancial.showCommissionTable;
            this.asSoldQuote = objProjectFinancial.asSoldQuote;
            this.activeFinancialQuote = objProjectFinancial.activeFinancialQuote;

            this.total.finalSalesDirect = objProjectFinancial.finalSalesDirect;

            this.total.totalInvoicedCR = objProjectFinancial.finalInvoicedCommisionAndRebate;
            this.total.totalInvoicedBR = objProjectFinancial.finalInvoicedBuyResell;
            this.total.totalInvoiced = objProjectFinancial.finalInvoiced;

            this.total.revenueCommisionAndRebate = objProjectFinancial.finalRevenueCommissionRebate;
            this.total.revenueBuyResell = objProjectFinancial.finalRevenueBuyResell;
            //this.revenueBuyResell = objProjectFinancial.activeFinancialQuote.salesBuyReSell - this.total.totalInvoicedBR;
            this.total.totalRevenue = objProjectFinancial.finalRevenueSales;

            this.total.marginCommisionAndRebate = objProjectFinancial.finalMarginCommissionRebate;
            this.total.marginBuyResell = objProjectFinancial.finalMarginBuyResell;
            this.total.totalMargin = objProjectFinancial.finalMargin;

            this.salesEngSplitList = objProjectFinancial.salesEngSplitList;

            this.opportunityName = objProjectFinancial.opportunityName;
            this.opportunityNumber = objProjectFinancial.opportunityNumber;
            this.ledger = objProjectFinancial.ledger;
            this.projectManager = objProjectFinancial.projectManager;
            this.finalInvoicedPercentage = objProjectFinancial.finalInvoicedPercentage;
            this.commissionInvoiced = objProjectFinancial.commissionInvoiced;
            this.brInvoiced = objProjectFinancial.brInvoiced;
            this.costToBeExpensed = objProjectFinancial.costToBeExpensed;
            this.amountUnderBilled = objProjectFinancial.amountUnderBilled;
            this.moveExpensesToWip = objProjectFinancial.moveExpensesToWip;
            this.deffered = objProjectFinancial.deffered;
            this.expensesToAccrue = objProjectFinancial.expensesToAccrue;
        }
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
                this.grandTotalSO = gtSO.toFixed(2);
                this.grandTotalPO = gtPO.toFixed(2);
                this.grandTotalIC = gtIC.toFixed(2);

                this.grandTotalCost = this.totalLabourJE + this.totalOtherJE + parseFloat(this.grandTotalPO) + parseFloat(this.grandTotalIC);
                this.grandTotalMargin = this.grandTotalSO - this.grandTotalCost;
                if (gtSO != null && gtSO != 0) {
                    this.grandTotalMarginPercentage = ((this.grandTotalMargin * 100) / this.grandTotalSO);
                } else {
                    this.grandTotalMarginPercentage = 0;
                }
                this.grandTotalMarginPercentage = this.grandTotalMarginPercentage.toFixed(2);
            }
            this.syncQuoteId = objProjectDetails.syncQuoteId;
            this.activeFinancialQuoteId = objProjectDetails.activeFinancialQuoteId;

        }

    }

}