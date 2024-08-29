import { LightningElement, track, api } from 'lwc';
import cloneGroup from '@salesforce/apex/GroupHeaderController.cloneGroup';
import { createMessageContext, publish } from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MESSAGE_CONSTANT = {
    GROUPCLONESUCCESS : 'Group Cloned Successfully',
    ERROR : 'error',
    GROUPCLONEERROR : 'An error occured while cloning the group '
}

const EVENT_CONSTANT = {
    ACCORDION : 'accordion',
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCLONE : 'recordCloned'
};

const CLASS_CONSTANT = {
    EDITINPUT : '.edit-input',
    ADDCOLOR : 'addcolor',
    HEADERBG : 'headerbg',
    GROUPTOGGLE : 'grouptoggle',
    GROUPNAMECHANGE : 'groupnamechange',
    QUICKSAVE : 'quicksave',
    FROMGROUPHEADER : 'fromGroupHeader'
};

export default class GroupHeader extends LightningElement {

    @api groupWrapper;
    @api quoteid;
    @api isMarrs;

    @track editFirstName = false;
    @track showButton = false;
    @track showModal = false;
    @track showDeleteModal = false;
    @track groupDetails;

    messageContext = createMessageContext();

    connectedCallback() { 
            this.isOpen = this.groupWrapper.isOpen;
            this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
    }

    renderedCallback() {
        if (this.groupDetails) {
            this.changeSelectionStyle(this.groupDetails.alternate);
        }
    }

    handleFirstNameEdit() {
        this.editFirstName = true;
        setTimeout(() => {
            const inputElement = this.template.querySelector(CLASS_CONSTANT.EDITINPUT);
            if (inputElement) {
                inputElement.focus();
            }
        },100);
    }

    handleFirstNameChange(event) {
        this.groupDetails.groupName = event.target.value;
    }

    @api
    groupAccordion(groupDetail) {
        this.groupDetails = groupDetail;
    }
    
    //Group Name Change Then dispatch event to Quote Group
    handleUpdateFirstName(event) {
        this.editFirstName = false;
        this.groupDetails = JSON.parse(JSON.stringify(this.groupDetails)); 
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.GROUPNAMECHANGE, {
            detail: {
                message : this.groupDetails
            }
        }));
    }

    handleShowButton() {
        this.showButton = true;
    }

    handleHideButton() {
        this.showButton = false;
    }

    handleNewSubGroup() {
        const message = {
            messageSender : CLASS_CONSTANT.FROMGROUPHEADER,
            messageToSend : CLASS_CONSTANT.QUICKSAVE,
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
        this.showModal = true;
    }

    handleHideModal() {
        this.showModal = false;
    }

    handleHideDeleteModal() {
        this.showDeleteModal = false;
    }

    handleShowDeleteModal() {
        const message = {
            messageSender : CLASS_CONSTANT.FROMGROUPHEADER,
            messageToSend : CLASS_CONSTANT.QUICKSAVE,
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
        this.showDeleteModal = true;
    }

    handleAccordion() {
        this.groupDetails.isOpen = !(this.groupDetails.isOpen);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                groupDetails : this.groupDetails
            }
        }))
    }

    async cloneGroup() {
        try
        {
            //this.publishSpinnerHandler(true);
            await cloneGroup({groupId : this.groupDetails.groupId, quoteId : this.quoteid});
            this.publishCloneGroupCreated(MESSAGE_CONSTANT.GROUPCLONESUCCESS);            
        }
        catch (error){
            const toastEvent = new ShowToastEvent({
                title: MESSAGE_CONSTANT.ERROR,
                message: MESSAGE_CONSTANT.GROUPCLONEERROR + error.body.message,
                variant: MESSAGE_CONSTANT.ERROR
            }); 
            this.dispatchEvent(toastEvent); 
        }
    } 

    handleCloneGroup() {
        const message = {
            messageSender : CLASS_CONSTANT.FROMGROUPHEADER,
            messageToSend : CLASS_CONSTANT.QUICKSAVE,
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);

        this.cloneGroup();
    }

    // publishSpinnerHandler(isLoading) {
    //     const message={
    //         messageSender : EVENT_CONSTANT.SPINNERTOOGLE,
    //         messageToSend : isLoading
    //     }
    //     publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    // }

    publishCloneGroupCreated(toastMessage) {
        const message={
            messageSender : EVENT_CONSTANT.RECORDCLONE,
            messageToSend : toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    handleToggleChange(event) { 
        //Toggle value change then dispatch event to Quote Group
        this.changeSelectionStyle(event.detail.checked);
        this.groupDetails.alternate = event.target.checked;
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.GROUPTOGGLE, {
            detail: {
                message: this.groupDetails
            }
        }));
    }

    @api
    uncheckToggle(groupChanges) {
        this.groupDetails = groupChanges;
        this.changeSelectionStyle(this.groupDetails.alternate);
    }

    @api
    marrsDetail(marrsGroupChanges) {
        this.groupDetails = marrsGroupChanges;
    }

    changeSelectionStyle(isAlternate) {
        const element = this.template.querySelector(`[data-header="${this.groupDetails.groupId}"]`);
        if (isAlternate) {
            if (element.classList.contains(CLASS_CONSTANT.HEADERBG)) {
                element.classList.remove(CLASS_CONSTANT.HEADERBG);
            }
            element.classList.add(CLASS_CONSTANT.ADDCOLOR);
        } else {
            if (element.classList.contains(CLASS_CONSTANT.ADDCOLOR)) {
                element.classList.remove(CLASS_CONSTANT.ADDCOLOR);
            }
            element.classList.add(CLASS_CONSTANT.HEADERBG);
        }
    }

}