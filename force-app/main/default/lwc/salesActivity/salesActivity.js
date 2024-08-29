import { LightningElement, wire, track,api } from 'lwc';
import fetchSalesActivityData from'@salesforce/apex/SalesActivityCtrl.buildSalesActivityWrapper';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";
import userId from '@salesforce/user/Id';

export default class SalesActivity extends LightningElement {
    @api tableHeader;
    dynamicYearHeader = new Date().getFullYear();
    @track columns = [
        { label: 'Sales Activty', fieldName: 'activityName', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'PTS', fieldName: 'points', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: `${this.dynamicYearHeader} goal`, fieldName: 'activityGoal', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'YTD Goal', fieldName: 'ytdGoal', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: 'YTD Actual', fieldName: 'ytdActual', type: 'Decimal', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: '% Of YTD Goal', fieldName: 'PercentageOfYtdGoal', hideDefaultActions: true, type:'percent', cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: '1M', fieldName: 'lastOneMotnh', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: '3M', fieldName: 'lastThreeMotnh', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: '6M', fieldName: 'lastSixMotnh', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }},
        { label: '12M', fieldName: 'lastTwelveMonth', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'BGColor'}
        }}
    ];
    @track salesActivityResponse;
    receivedMessage
    subscription = null;
    @track errormessage;
    @api isLoading = false;
    
    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }
    connectedCallback() {
        console.log('in side of connected call back of SalesActivity');
        this.fethInitialData(userId);
        this.subscribeToMessageChannel();
    }
    fethInitialData(selectedUserId) {
        fetchSalesActivityData({salesRep : selectedUserId})
        .then((data) => {  
            data = JSON.parse(JSON.stringify(data));
            //console.log('data==>'+data);
            data[data.length-1].BGColor = 'blackRow';
            this.salesActivityResponse = data;
            this.isLoading = false;
        })
        .catch(error => {
            this.salesActivityResponse = null;
            //console.log('error='+JSON.stringify(error));
            //console.log('error='+error.body.message);
            this.errormessage = error.body.message;
            this.isLoading = false;
        });
    }
    //2.subscribe message from channel
    @wire(MessageContext)
    MessageContext;
    //3.Handling 
    subscribeToMessageChannel() {
        //console.log("in handle subscribe");
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
            //.log('new user found in Sales Activity');
            this.fethInitialData(message.newUserId);
        }
    } 
}