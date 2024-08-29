import {LightningElement, api, track, wire} from 'lwc';
import {subscribe, MessageContext, createMessageContext,unsubscribe, APPLICATION_SCOPE } from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCartWrapper from '@salesforce/apex/QuoteController.getCartWrapper';
import DESIGN_QUOTE_CHANNEL from '@salesforce/messageChannel/DesignQuoteChannel__c';
import { calculateQuotePrice, calculateMarrsQuotePrice } from 'c/pricingUtil';

const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCREATED : 'recordCreated',
    RECORDDELETED : 'recordDeleted',
    RECORDCLONED : 'recordCloned',
    ADDPRODUCT : 'productAdder',
    DRAGDROP : 'DragDrop',
    DRAGDROPLINEITEM: 'dragDropLineItem',
    RETURNLINEITEM: 'returnLineItem'
};

const MESSAGE_CONSTANT = {
    SUCCESS : 'success',
    ERRORAPEX : 'Error calling Apex method:'
};

const protocol = window.location.href ;

var urlObj = new URL(protocol);
var queryParams = new URLSearchParams(urlObj.search);
var quoteI = queryParams.get("quoteId");

export default class QuoteContainer extends LightningElement {

    @api quoteId;
    
    @track isMarrs;
    @track cartWrapper;
    @track isLoading = false;
    @track isLoadFromGroupCreate = false;
    @track showDesignQuoteDetail = false;

    subscription;

    @wire(MessageContext)
    messageContext;

    connectedCallback() {
        this.quoteId = quoteI;
        this.subscribeToQuoteChannel();
        this.subscribeToDesignChannel();
        this.loadCartWrapper();
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    subscribeToQuoteChannel() {
        this.subscription = subscribe(
            this.messageContext,
            QUOTE_TOOL_CHANNEL,
            (message) => this.handleMessage(message),
            {scope: APPLICATION_SCOPE}
        );
    }

    subscribeToDesignChannel() {
        this.subscription = subscribe(
            this.messageContext,
            DESIGN_QUOTE_CHANNEL,
            () => this.hideDesignQuote()
        );
    }

    handleMessage(message) {
        if(message.messageSender === EVENT_CONSTANT.SPINNERTOOGLE) {
            this.isLoading = message.messageToSend;
        } else if(message.messageSender === EVENT_CONSTANT.RECORDCREATED || 
                message.messageSender === EVENT_CONSTANT.RECORDDELETED || 
                message.messageSender === EVENT_CONSTANT.RECORDCLONED ||
                message.messageSender === EVENT_CONSTANT.ADDPRODUCT ||
                message.messageSender === EVENT_CONSTANT.DRAGDROP) {
            this.handleReloadCartWrapper(message.messageToSend);
        } 
    }

    hideDesignQuote() {
        this.showDesignQuoteDetail = false;
    }

    async loadCartWrapper(message) {
        try {
            this.isLoading = true;
            const response = await getCartWrapper({ quoteId: this.quoteId });
            this.isLoading = false;
            this.cartWrapper = response;
            
            this.isMarrs = response.isMarrs;
    
            console.log("cartwrapper is:" +JSON.stringify(this.cartWrapper));
            if (this.isLoadFromGroupCreate) {
                const toastEvent = new ShowToastEvent({
                    title: MESSAGE_CONSTANT.SUCCESS,
                    message: message,
                    variant: MESSAGE_CONSTANT.SUCCESS,
                });
                this.dispatchEvent(toastEvent);
            }
            this.cartWrapper = calculateQuotePrice(this.cartWrapper);
        } catch (error) {
            this.isLoading = false;
            console.error(MESSAGE_CONSTANT.ERRORAPEX, error);
        }
    }

    handleReloadCartWrapper(toastMessage) {
        this.isLoadFromGroupCreate = true;
        this.cartWrapper = '';
        this.loadCartWrapper(toastMessage);
    }

    handleDeleteRecord(event) {
        const toastEvent = new ShowToastEvent({
            title: MESSAGE_CONSTANT.SUCCESS,
            message: event.detail.message,
            variant: MESSAGE_CONSTANT.SUCCESS,
        });
        this.dispatchEvent(toastEvent);
    }

    handleDesignQuote() {
        this.showDesignQuoteDetail = true;
    }

    //fetch group wrapper details from quote group for toggle
    handleQuoteGroupToggle(event) {
        this.replaceElementByGroupId(event.detail.message);
        this.cartWrapper = calculateQuotePrice(this.cartWrapper);
    }

    handleMarrsQuoteGroup(event) {
        this.replaceElementByGroupId(event.detail.message);
        this.cartWrapper = calculateMarrsQuotePrice(this.cartWrapper);
    }

    replaceElementByGroupId(newValue) {  
        const index = this.cartWrapper.groupDetails.findIndex(item => item.groupId === newValue.groupId);
        if (index !== -1) {
            this.cartWrapper.groupDetails[index] = newValue;
        }
    }
}