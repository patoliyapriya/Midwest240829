import { LightningElement, wire, track } from 'lwc';
import getDashboardBackLog from'@salesforce/apex/SalesResultCtrl.getDashboardBackLog';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";
import userId from '@salesforce/user/Id';

export default class DashboardBackLog extends LightningElement {
    @track DashboardBackLog = [];
    @track errormessage;
    @track isLoading = false;
    @track dashboardBack;
    subscription = null;
    TotalMargin = 0;
    TotalRevenue = 0;
    YearEndMarginTotal = 0;
    YearEndRevenueTotal = 0;
    lYearMarginTotal = 0;
    lYearRevenueTotal = 0;
    HalfYearMarginTotal = 0;    
    HalfYearRevenueTotal = 0;
    ThreeMonthMarginTotal = 0;
    ThreeMonthRevenueTotal = 0;
    OneMonthMarginTotal = 0;
    OneMonthRevenueTotal = 0;

    connectedCallback() {
        this.fethInitialData(userId);
        this.subscribeToMessageChannel();
    }

    fethInitialData(selectedUserId) {
        getDashboardBackLog({selectedSalesRep : selectedUserId})
        .then((data) => {
            console.log('In then got data=>'+ JSON.stringify(data));
            
            this.TotalMargin = data[0].TotalMargin;
            this.TotalRevenue = data[0].TotalRevenue;
            this.YearEndMarginTotal = data[0].YearEndMarginTotal;
            this.YearEndRevenueTotal = data[0].YearEndRevenueTotal;
            this.lYearMarginTotal = data[0].lYearDaysMarginTotal;
            this.lYearRevenueTotal = data[0].lYearDaysRevenueTotal;
            this.HalfYearMarginTotal = data[0].HalfYearMarginTotal;
            this.HalfYearRevenueTotal = data[0].HalfYearRevenueTotal;
            this.ThreeMonthMarginTotal = data[0].ThreeMonthMarginTotal;
            this.ThreeMonthRevenueTotal = data[0].ThreeMonthRevenueTotal;
            this.OneMonthMarginTotal = data[0].OneMonthMarginTotal;
            this.OneMonthRevenueTotal = data[0].OneMonthRevenueTotal;

            this.dashboardBack = data;
        
            this.isLoading = false;
        })
        .catch(error => {
            this.dashboardBack = null;
            this.errormessage = error.body.message;
            this.isLoading = false;
        });
    }

    //2.subscribe message from channel
    @wire(MessageContext)
    MessageContext;

    subscribeToMessageChannel() {
        if (this.subscription) {
            return;
        }
    
        //4. Subscribing to the message channel
        this.subscription = subscribe(
                            this.MessageContext,
                                DASHBORAD_CHANNEL,
                                (message) => this.handleMessage(message),
                                { scope : APPLICATION_SCOPE }
                            );
    }

    handleMessage(message) {
        this.isLoading = true;
        this.receivedMessage = message ? JSON.stringify(message, null, "\t") : "no message";
        if (message.newUserId) {
            this.fethInitialData(message.newUserId);
        }
    }
}