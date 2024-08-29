import {LightningElement, wire, api} from 'lwc';
import {publish,MessageContext} from 'lightning/messageService';
import getGenerateDocument from '@salesforce/apex/DesignQuoteHeaderController.getGenerateDocument';
import DESIGN_QUOTE_CHANNEL from '@salesforce/messageChannel/DesignQuoteChannel__c';
import quoteDesigner from "@salesforce/label/c.QuoteDesigner";
import quickSave from '@salesforce/apex/QuoteHeaderController.quickSave';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';

const STYLE_CONSTANT = {
    PADDING10 : 'padding-top:10px',
    PADDING102 : 'padding-top:102px',
    STICKYHEADER : '.myStickyHeader',
    SLDSFIXED : 'slds-is-fixed'
};

const NAV_CONSTANT = {
    BLANK : '_blank',
    SELF : '_self'
};

const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
};

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    ERRORAPEX : 'Error calling Apex method:',
    SUCCESS : 'success',
    SAVEDMSG : 'The record has been saved successfully',
};

export default class DesignQuoteHeader extends LightningElement {

    @api quoteid;
    @api cartWrapper;
    
    @wire(MessageContext)
    messageContext;

    contentPadding = STYLE_CONSTANT.PADDING10;
    label = {quoteDesigner};
    
    renderedCallback() {
        try {
            window.onscroll = () => {
                let stickysection = this.template.querySelector(STYLE_CONSTANT.STICKYHEADER);
                let scrollPosition = window.scrollY;
                let offset = 80;

                if (scrollPosition > offset) {
                    stickysection.classList.add(STYLE_CONSTANT.SLDSFIXED);
                    stickysection.style.marginTop = '125px';
                    this.contentPadding = STYLE_CONSTANT.PADDING102
                } else {
                    stickysection.classList.remove(STYLE_CONSTANT.SLDSFIXED);
                    stickysection.style.marginTop = '';
                    this.contentPadding = STYLE_CONSTANT.PADDING10
                }
            }
        } catch (error) {
            
        }
    }

    generateDocumentFile() {
        this.getGenerateDocument();
    }

    cancelDesignQuote() {
        publish(this.messageContext, DESIGN_QUOTE_CHANNEL, { canceldesignQuoteClicked: true });
    }

    previewDocument(){
        var url = '/apex/generatequotedocument?Id='+this.quoteid;
        window.open(url, NAV_CONSTANT.BLANK);
        return false;
    }

    async getGenerateDocument() {
        try {
            var url = await getGenerateDocument({quoteid:this.quoteid});
            window.open(url,NAV_CONSTANT.SELF);
        }
        catch (error) {
        }
    }

    handleQuickSave() {
        this.saveData();
    }

    handleSaveExit() {
        if(this.saveData()) {
            this.cancelDesignQuote();
            this.showToast(MESSAGE_CONSTANT.SUCCESS, MESSAGE_CONSTANT.SAVEDMSG, MESSAGE_CONSTANT.SUCCESS);
        }
    }

    async saveData() {
        try {
            await quickSave({cartWrapperString : JSON.stringify(this.cartWrapper)}); 
            this.showToast(MESSAGE_CONSTANT.SUCCESS, MESSAGE_CONSTANT.SAVEDMSG, MESSAGE_CONSTANT.SUCCESS);
            return true;
        } catch (error) {
            this.publishSpinnerHandler(false);
            this.showToast(MESSAGE_CONSTANT.ERROR, MESSAGE_CONSTANT.ERRORAPEX + error.body.message, MESSAGE_CONSTANT.ERROR);
            return false;
        }
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    publishSpinnerHandler(isLoading) {
        const message = {
            messageSender: EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend: isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }
}