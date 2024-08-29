import { LightningElement, wire, track,api } from 'lwc';
import userId from '@salesforce/user/Id';
import fetchSalesResultsData from'@salesforce/apex/SalesResultCtrl.buildSalesResultsWrapper';
import SalesDashboardStyle from '@salesforce/resourceUrl/SalesDashboardStyle';
import { loadStyle } from 'lightning/platformResourceLoader';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";

export default class SalesResults extends LightningElement {
    @api tableHeader;
    dynamicYearHeader = new Date().getFullYear();
    @track columns = [
        { label: 'Sales Results', fieldName: 'name', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        } },
        { label: `${this.dynamicYearHeader} goal`, fieldName: 'totalGoalForYear',type: 'currency', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: 'YTD', fieldName: 'ytdGoal',type: 'currency', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: '% of Year', fieldName: 'percentageOfYear',hideDefaultActions: true, type: 'percent', cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: '% YTD', fieldName: 'percentageOfYtdGoal', hideDefaultActions: true, type: 'percent', cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: '1M', fieldName: 'actual1MGoal',type: 'currency', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: '3M', fieldName: 'actual3MGoal',type: 'currency', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: '6M', fieldName: 'actual6MGoal',type: 'currency', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }},
        { label: '12M', fieldName: 'actual12MGoal',type: 'currency', hideDefaultActions: true, cellAttributes: {
            class: {fieldName: 'salesResultBGColor'}
        }}
    ];
    @track salesResults;
    receivedMessage
    subscription = null;
    @track errormessage;
    @api isLoading = false;
    
    renderedCallback() {
        loadStyle(this, SalesDashboardStyle);
    }
    connectedCallback() {
        //console.log('in side of connected call back of SalesResult');
         this.fethInitialData(userId);
        this.subscribeToMessageChannel();
    }
    fethInitialData(selectedUserId){
        fetchSalesResultsData({selectedSalesRep : selectedUserId})
        .then((data) => {
            //console.log('data>'+data);
            data = JSON.parse(JSON.stringify(data));
            for (var i=0; i<data.length; i++) {
                if (i == 0 || i == 3 || i == 6 || i == 9 || i == 12 || i == 15) {
                    //Object.assign({}, data[i], {salesResultBGColor:'slds-icon-custom-custom9'})
                    data[i].salesResultBGColor = 'blueRow slds-no-row-hover';
                }
            }
            this.salesResults = data;
            this.isLoading = false;
            //console.log('salesActivityResults2>'+JSON.stringify(this.salesResults));
        })
        .catch(error => {
            this.salesResults = null;
            //console.log('error='+JSON.stringify(error));
            //console.log('error='+error.body.message);
            this.errormessage = error.body.message;
            this.isLoading = false;
        });
    }
     // subscribe message from channel
    @wire(MessageContext)
    MessageContext;
    subscribeToMessageChannel() {
        //console.log("in handle subscribe");
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
            // console.log('new user found in salesResults');
            this.fethInitialData(message.newUserId);
        }
    } 
}