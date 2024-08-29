import { LightningElement, track, wire, api } from 'lwc';
import getSalesBackLog from'@salesforce/apex/SalesResultCtrl.getSalesBackLog';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";
import userId from '@salesforce/user/Id';

const columns = [
    { label: 'Type', fieldName: 'backLogName', hideDefaultActions: true},
    { label: 'All Projects', fieldName: 'backLogValue', hideDefaultActions: true, type: 'currency' }
];
export default class SalesBackLog extends LightningElement {
    columns = columns;
    @track salesBackLog = [];
    @track errormessage;
    @track isLoading = false;
    subscription = null;
    salesBacklog = 0;
    marginBacklog = 0;

    /*
    @wire(getSalesBackLog) getGoals(result) {    
        if(result.data) {
            this.salesBackLog = result.data[0].backLogValue;
            this.marginBacklog = result.data[1].backLogValue;
        }
    }
    */
    connectedCallback() {
        this.fethInitialData(userId);
        this.subscribeToMessageChannel();
    }

    fethInitialData(selectedUserId) {
        getSalesBackLog({selectedSalesRep : selectedUserId})
        .then((data) => {
            console.log('In then got data=>'+ JSON.stringify(data));
            
            this.salesBackLog = data[0].backLogValue;
            this.marginBacklog = data[1].backLogValue;
            
            this.isLoading = false;
        })
        .catch(error => {
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