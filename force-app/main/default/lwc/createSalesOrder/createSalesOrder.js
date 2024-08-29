import { LightningElement, track, wire, api } from 'lwc';
import fetchQuoteWithLineItem from '@salesforce/apex/CreateSalesOrderLWCCtrl.fetchOrderWithLineItems';
import createSalesOrderWithLineItems from '@salesforce/apex/CreateSalesOrderLWCCtrl.createSalesOrderWithLineItems';
import { NavigationMixin } from 'lightning/navigation';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class CreateSalesOrder extends NavigationMixin(LightningElement) {
    @track quoteId = '';
    @api recordId;
    @api isLoading = false;
    @track showToast = false;
    @track showWarning = false;
    @track toastProperties = [];
    @track grandTotal = 0;
    @track orderDisplayData = [];
    @track orderLinesDisplayData =[];
    @track orderLinesDisplayDataNew =[];
    @track OrderLineItemStruct =[];
    @track orderDataMap = new Map();
    @track quoteLabels = new Map([ ['AcctSeedERP__Customer__c', 'Customer'],
                                    ['AcctSeedERP__Opportunity__c', 'Opportunity']
                                ])
    

    connectedCallback(){
        this.quoteId = this.recordId;
    }


    @wire(fetchQuoteWithLineItem, {quoteId: '$quoteId'})
    wiredResult(result) { 
        
        if(result.data) {

            this.grandTotal =  result.data["GrandTotal"];
            console.log('the grandtotal :- '+this.grandTotal);
            this.orderDataMap = result.data["parentData"];
            this.orderLinesDisplayData = result.data["LineItems"];
            let groupToSubGroupsMap = result.data["productGroupDetails"];
            console.log('group details1'+JSON.stringify(groupToSubGroupsMap));

            for(let key of this.quoteLabels.keys()) {
                let fieldValue = this.orderDataMap[key];
                this.orderDisplayData.push({label : this.quoteLabels.get(key), 
                                            fieldAPI : key,
                                            fieldValue : fieldValue });
            }

            
            for(let parent in groupToSubGroupsMap) {
                //console.log('inside loop'+JSON.stringify(groupToSubGroupsMap[key]));
                let childGroups = groupToSubGroupsMap[parent]["childGroupsDetail"];
                let updatedChildGroupDetail = [];
                for(let child in childGroups) {
                    
                    let orderLineItems = childGroups[child]["orderLines"];
                    let updatedOrderLines = [];
                    //console.log('inside child loop'+JSON.stringify(orderLineItems));
                    for(let key in orderLineItems) {
                        //let updatedLineItem = [];
                        let quantity = parseInt(orderLineItems[key]["AcctSeedERP__Quantity_Ordered__c"]);
                        let unitPrice = parseFloat(orderLineItems[key]["AcctSeedERP__Unit_Price__c"]);
                        let total = quantity * unitPrice;
                        //updatedLineItem[key]["total"] = total;
                        updatedOrderLines.push({
                            AcctSeedERP__Quantity_Ordered__c : orderLineItems[key]["AcctSeedERP__Quantity_Ordered__c"], 
                            AcctSeedERP__Unit_Price__c : orderLineItems[key]["AcctSeedERP__Unit_Price__c"],
                            total : total,
                            AcctSeedERP__Product__c: orderLineItems[key]["AcctSeedERP__Product__c"],
                            AcctSeedERP__Comment__c: orderLineItems[key]["AcctSeedERP__Comment__c"]
                        })
                        //console.log('new order lines'+JSON.stringify(updatedLineItem));
                        //updatedOrderLines.push(updatedLineItem);
                    }
                    updatedChildGroupDetail.push({
                        childGrpName : childGroups[child]["childGroupName"],
                        orderLineItems : updatedOrderLines
                    })
                }
                this.OrderLineItemStruct.push({
                        groupName : groupToSubGroupsMap[parent]["groupName"],
                        subGrpdetail : updatedChildGroupDetail
                });
                // console.log('group name pushed :- ' +groupName);
            }
            console.log('final struct'+JSON.stringify(this.OrderLineItemStruct));
            for(let key in this.orderLinesDisplayData) {
                let quantity = parseInt(this.orderLinesDisplayData[key]["AcctSeedERP__Quantity_Ordered__c"]);
                let unitPrice = parseFloat(this.orderLinesDisplayData[key]["AcctSeedERP__Unit_Price__c"]);
                let total = quantity * unitPrice;
                
                this.orderLinesDisplayDataNew.push({
                    AcctSeedERP__Quantity_Ordered__c : this.orderLinesDisplayData[key]["AcctSeedERP__Quantity_Ordered__c"], 
                    AcctSeedERP__Unit_Price__c : this.orderLinesDisplayData[key]["AcctSeedERP__Unit_Price__c"],
                    total : total,
                    AcctSeedERP__Product__c: this.orderLinesDisplayData[key]["AcctSeedERP__Product__c"],
                    AcctSeedERP__Comment__c: this.orderLinesDisplayData[key]["AcctSeedERP__Comment__c"]});

            }

        }
    }



    // updatedComment(event) {
    //     let index = parseInt(event.target.label);
    //     console.log(this.orderLinesDisplayDataNew[index]["AcctSeedERP__Product__c"]);

    //     // update comment value
    //     this.orderLinesDisplayDataNew[index]["AcctSeedERP__Comment__c"] = event.target.value;
    //     console.log('updated data=>'+JSON.stringify(this.orderLinesDisplayDataNew));
    // }

    // updatedComment(event) {
    //     let index = parseInt(event.target.label);
    //     if (!isNaN(index) && Array.isArray(this.orderLinesDisplayDataNew) && index >= 0 && index < this.orderLinesDisplayDataNew.length) {
    //         console.log(this.orderLinesDisplayDataNew[index]["AcctSeedERP__Product__c"]);
    
    //         // update comment value
    //         this.orderLinesDisplayDataNew[index]["AcctSeedERP__Comment__c"] = event.target.value;
    //         console.log('updated data=>'+JSON.stringify(this.orderLinesDisplayDataNew));
    //     }
    // }

    // @api
    // createSalesOrderWithLineItems() {
    //     this.isLoading = true;
        
    //     // extract orderlines
    //     let orderLineItemInputList = []
    //     for(let key in this.OrderLineItemStruct) {
    //         let childData = this.OrderLineItemStruct[key]["subGrpdetail"];
    //         for(let key in childData) {
    //             let orderLineList = childData[key]["orderLineItems"];
    //             for(let orderlineKey in orderLineList) {
    //                 let orderLineItem = orderLineList[orderlineKey];
    //                 orderLineItemInputList.push(orderLineItem);
                    
    //             }
    //         }
            
    //     }
    //     console.log('extracted orderLineItemList2=>'+JSON.stringify(orderLineItemInputList));

    //     createSalesOrderWithLineItems( { orderLines: orderLineItemInputList,
    //                                      salesOrder: this.orderDataMap })
    //         .then(result => {
    //         console.log('inside result data='+JSON.stringify(result));
    //         if(result.isSuccess) {
    //             let url = window.location.origin + '/lightning/r/AcctSeedERP__Sales_Order__c/'+result.orderId+'/view?0.source=alohaHeader';
    //             window.open(url, '_blank');
    //         } else {
    //             console.log('inside the error block');
    //             this.isLoading = false;
    //             this.showErrorToast(result.errorMesage);
    //         }
    //         console.log('closing the component');
    //         })
    //         .catch(error => {
    //             console.log('inside error='+JSON.stringify(error));
    //             this.isLoading = false;
    //             this.showErrorToast(JSON.stringify(error.body));
    //             //this.error = error;
    //         });
    // }

    showErrorToast(error) {
        
        this.toastProperties = [];
        this.toastProperties.push({
            type : 'slds-notify slds-notify_toast slds-theme_error',
            message : error
        })
        this.showToast = true;
    }

    closeToast() {
        console.log('inside toast close');
        this.toastProperties = [];
        this.showToast = false;
    }
    // Navigate to View Account Page
    navigateBackToQuotePage() {
        let url = window.location.origin + '/lightning/r/Quote/'+this.quoteId+'/view?0.source=alohaHeader';
        window.location.href = url;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.quoteId,
                objectApiName: 'Quote',
                actionName: 'view'
            },
        });
    }

}