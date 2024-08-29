import { LightningElement, api, track, wire} from 'lwc';
import { publish, MessageContext} from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSubGroupLabel from "@salesforce/label/c.CreateSubGroupLabel";
import subGroupNameLabel from "@salesforce/label/c.SubGroupName";
import cancelLabel from "@salesforce/label/c.CancelButtonLabel";
import createSubGroup from '@salesforce/apex/NewSubGroupModalController.createSubGroup';
import { createMessageContext} from 'lightning/messageService';

const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCREATED : 'recordCreated',
    HIDEMODAL : 'hidemodal'
};

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    ERRORSUBGROUPNAME : 'Subgroup Name cannot be empty',
    SUCCESSSUBGROUP : 'Sub Group created successfully',
    ERRORCREATINGSUBGROUP : 'An error occurred while creating the Subgroup: ',
};

export default class NewSubGroupModal extends LightningElement {
    
    @api groupid;
    @api quoteid;
    
    @track subGroupName;

    label = {createSubGroupLabel,
        subGroupNameLabel,
        cancelLabel
    };

    messageContext = createMessageContext();

    async CreateSubGroup() {
        const subGroupNameInput = this.template.querySelector('.subgroup-name');

        if (!this.subGroupName) {
                subGroupNameInput.setCustomValidity('Complete this field.');
            subGroupNameInput.reportValidity();
        } else {
            try {
                this.hideModalBox();
                this.publishHandler(true);
                await createSubGroup({quoteId: this.quoteid, groupId: this.groupid, subGroupName: this.subGroupName});
                this.publishSubGroupCreated(MESSAGE_CONSTANT.SUCCESSSUBGROUP);
                this.subGroupName = '';
            } catch (error) {
                const toastEvent = new ShowToastEvent({
                    title: MESSAGE_CONSTANT.ERROR,
                    message: MESSAGE_CONSTANT.ERRORCREATINGSUBGROUP + error.body.message,
                    variant: MESSAGE_CONSTANT.ERROR
                });
                this.dispatchEvent(toastEvent);
            }
        }
    }

    publishHandler(isLoading){
        const message = {
            messageSender : EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend : isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    publishSubGroupCreated(toastMessage) {
        const message = {
            messageSender : EVENT_CONSTANT.RECORDCREATED,
            messageToSend : toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    hideModalBox() {
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.HIDEMODAL));
    }

    handleSubGroupNameChange(event) {
        this.subGroupName = event.target.value;
    }

    handleCreateSubGroup() {
        this.CreateSubGroup();
    }
}