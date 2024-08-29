import {api, track} from "lwc";
import { LightningElement} from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import cancelLabel from "@salesforce/label/c.CancelButtonLabel";
import newGroupLabel from "@salesforce/label/c.NewGroup";
import quickSave from '@salesforce/apex/QuoteHeaderController.quickSave';
import { APPLICATION_SCOPE, createMessageContext, publish, subscribe, unsubscribe } from "lightning/messageService";
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const NAV_CONSTANT = {
    STANDARDRECORDPAGE : 'standard__recordPage',
    VIEW : 'view'
}

const EVENT_CONSTANT = {
    DESIGNQUOTECLICK : 'designquoteclick',
    SPINNERTOOGLE : 'spinnerToogle',
}

const STYLE_CONSTANT = {
    PADDING10 : 'padding-top:10px',
    PADDING102 : 'padding-top:102px',
    STICKYHEADER : '.myStickyHeader',
    SLDSFIXED : 'slds-is-fixed'
};

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    ERRORAPEX : 'Error calling Apex method:',
    SUCCESS : 'success',
    SAVEDMSG : 'The record has been saved successfully',
};

const CLASS_CONSTANT = {
    DOCLONELINEITEM : 'doCloneLineItem',
    DOMARRSCLONELINEITEM : 'doMarrsCloneLineItem'
};

export default class QuoteHeader extends NavigationMixin(LightningElement) {

    @api quoteid;
    @api cartWrapper;
    @api isMarrs;

    @track showModal = false;

    subscription = null;
    contentPadding = STYLE_CONSTANT.PADDING10;
    label = {cancelLabel, newGroupLabel};

    messageContext = createMessageContext();

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            QUOTE_TOOL_CHANNEL,
            (message) => this.handleMessage(message),
            {scope: APPLICATION_SCOPE}
        );
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

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
    
    handleMessage(message) {
        if(message.messageToSend === 'quicksave') {
            this.saveData(message.messageSender);
        }
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: NAV_CONSTANT.STANDARDRECORDPAGE,
            attributes: {
                recordId: this.quoteid,
                actionName: NAV_CONSTANT.VIEW
            }
        });
    }

    handleNewGroup() {
        if (this.saveData('newGroup')) {
        this.showModal = true;
        }
    }

    handleHideModal() {
        this.showModal = false;
    }

    handleDesignQuote() {
        if (this.saveData('designQuote')) {
            const event = new CustomEvent(EVENT_CONSTANT.DESIGNQUOTECLICK);
            this.dispatchEvent(event);
        }
    }

    async saveData(messageFrom) {
        try {

            if(messageFrom === 'normalQuickSave' || messageFrom === 'normalQuickSaveExit') {
                this.publishSpinnerHandler(true);
            }

            await quickSave({cartWrapperString : JSON.stringify(this.cartWrapper)}).then((result) => {
                if(messageFrom === 'fromCloneLineItem') {
                    const message = {
                        messageSender : CLASS_CONSTANT.DOCLONELINEITEM
                    }
                    publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
                }

                if(messageFrom === 'fromMarrsCloneLineItem') {
                    const message = {
                        messageSender : CLASS_CONSTANT.DOMARRSCLONELINEITEM
                    }
                    publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
                }
            });

            if(messageFrom === 'normalQuickSave' || messageFrom === 'normalQuickSaveExit') {
                this.publishSpinnerHandler(false);
                this.showToast(MESSAGE_CONSTANT.SUCCESS, MESSAGE_CONSTANT.SAVEDMSG, MESSAGE_CONSTANT.SUCCESS);    
            }
            return true;
        } catch (error) {
            this.publishSpinnerHandler(false);
            this.showToast(MESSAGE_CONSTANT.ERROR, MESSAGE_CONSTANT.ERRORAPEX + error.body.message, MESSAGE_CONSTANT.ERROR);
            return false;
        }
    }

    publishSpinnerHandler(isLoading) {
        const message = {
            messageSender: EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend: isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    handleQuickSave() {
        this.validateBeforeSave('normalQuickSave');
    }

    handleSaveExit() {
        if (this.validateBeforeSave('normalQuickSaveExit')) {
            this.handleCancel();
        }
    }

    validateBeforeSave(msg) {
        let flag = true; 
        this.cartWrapper.groupDetails.forEach(element => {
             if(element.groupName == '' || element.groupName == null){
                flag = false;
                return false;
             } else {
                element.subGroupDetails.forEach(element => {
                    if(element.subGroupName == '' || element.subGroupName == null) {
                        flag = false;
                        return false;
                    }
                });
             }
        });

        if(flag == false) {
            alert('Group/SubGroup Name is must');
        } else {
            this.saveData(msg);
            if(msg == 'normalQuickSaveExit') {
                return true;
            }
        }
    }

    previewDocument(){
        var url = '/apex/MarrsQuotePdf?Id='+this.quoteid;
        window.open(url, NAV_CONSTANT.BLANK);
        return false;
    }
    
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}