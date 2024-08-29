import { LightningElement, track, wire, api } from 'lwc';
import getPercentageGoals from'@salesforce/apex/SalesResultCtrl.getPercentageGoals';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import userId from '@salesforce/user/Id';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";

/*
const columns = [
    { label: 'Type', fieldName: 'percentageName', hideDefaultActions: true, },
    { label: 'All Projects', fieldName: 'percentageValue', hideDefaultActions: true,type: 'percent'  }
];
*/

export default class SalesPercentageGoal extends LightningElement {
    
    //columns = columns;
    //@track salesPercentageGoals = [];
    @track SalesPercentageGoal;
    receivedMessage
    subscription = null;
    @track errormessage;
    @api isLoading = false;

    brSalesMargin = 0;
    directSalesMargin = 0;
    totalSalesMargin = 0;

    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }
    connectedCallback() {
        //console.log('in side of connected call back of SalesResult')
        this.subscribeToMessageChannel();
        this.fethInitialData(userId);
    }
    fethInitialData(selectedUserId) {
        getPercentageGoals({selectedSalesRep : selectedUserId})
        .then((data) =>{
            console.log('Got Data from Ctrl : '+data[0].percentageValue);

            this.brSalesMargin = data[0].percentageValue;
            this.directSalesMargin = data[1].percentageValue;
            this.totalSalesMargin = data[2].percentageValue;

            this.SalesPercentageGoal = data;
            this.isLoading = false;

            console.log('data from percentage goal==>'+data);
            
        })
        .catch(error => {
            this.SalesPercentageGoal = null;
            console.log('error form sales %' + error.body.message);
            this.errormessage = error.body.message;
            this.isLoading = false;
        
        });
    }

    // @wire(getPercentageGoals) getGoals(result) {    
    //     if(result.data) {
    //         this.brSalesMargin = result.data[0].percentageValue
    //         this.directSalesMargin = result.data[1].percentageValue
    //         this.totalSalesMargin = result.data[2].percentageValue;

    //         console.log('data from wire property' + result.data.percentageValue); 
    //         //this.salesPercentageGoals = result.data;
    //     }  
  
    // }

    // subscribe message from channel
    @wire(MessageContext)
    MessageContext;

    subscribeToMessageChannel() {
        console.log(" sales % in handle subscribe");
        if(this.subscription){
            return;
        }
         //4. Subscribing to the message channel
         this.subscription = subscribe(
            this.MessageContext,
                DASHBORAD_CHANNEL,
                (message) => this.handleMessage(message),
                {scope: APPLICATION_SCOPE}
            );
    }
    handleMessage(message){
        this.isLoading = true;
        this.receivedMessage = message ? JSON.stringify(message, null, "\t") : "no message";
        if (message.newUserId) {
            console.log('new user found in SalespercentageGoal: newUserId: '+message.newUserId);
            this.fethInitialData(message.newUserId);
        }
    } 
}