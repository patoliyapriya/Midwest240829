import { LightningElement, api, track, wire} from 'lwc';
import { publish} from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelLabel from "@salesforce/label/c.CancelButtonLabel";
import createGroupLabel from "@salesforce/label/c.CreateGroup";
import groupNameLabel from "@salesforce/label/c.GroupName";
import subGroupNameLabel from "@salesforce/label/c.SubGroupName";
import createGroup from '@salesforce/apex/NewGroupModalController.createGroup';
import { createMessageContext} from 'lightning/messageService';

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    ERRORGROUPNAME : 'Group Name or Subgroup Name cannot be empty',
    SUCCESSGROUP : 'Group created successfully',
    ERRORCREATINGGROUP : 'An error occurred while creating the group: ',
};

const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCREATED : 'recordCreated',
    HIDEMODAL : 'hidemodal'
};

export default class NewGroupModal extends LightningElement {

    @api quoteid;

    @track groupName;
    @track subGroupName;

    label = {cancelLabel,
        createGroupLabel,
        groupNameLabel,
        subGroupNameLabel    
    };

    messageContext = createMessageContext();

    async CreateGroup() {

        const groupNameInput = this.template.querySelector('.group-name');
        const subGroupNameInput = this.template.querySelector('.subgroup-name');

        if (!this.groupName || !this.subGroupName) {
    
            if (!this.groupName) {
                groupNameInput.setCustomValidity('Complete this field.');
            } else {
                groupNameInput.setCustomValidity('');
            }
            
            if (!this.subGroupName) {
                subGroupNameInput.setCustomValidity('Complete this field.');
            } else {
                subGroupNameInput.setCustomValidity('');
            }
           
            groupNameInput.reportValidity();
            subGroupNameInput.reportValidity();
        } else {
            
            try {
                this.hideModalBox();
                this.publishSpinnerHandler(true);
                await createGroup({quoteId: this.quoteid, groupName: this.groupName, subGroupName: this.subGroupName});
                this.publishGroupCreated(MESSAGE_CONSTANT.SUCCESSGROUP);
                this.groupName = '';
                this.subGroupName = '';
            } catch (error) {
                const toastEvent = new ShowToastEvent({
                    title: MESSAGE_CONSTANT.ERROR,
                    message: MESSAGE_CONSTANT.ERRORCREATINGGROUP + error.body.message,
                    variant: MESSAGE_CONSTANT.ERROR
                });
                this.dispatchEvent(toastEvent);
            }
        } 
    }
    
    publishSpinnerHandler(isLoading) {
        const message = {
            messageSender : EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend : isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    publishGroupCreated(toastMessage) {
        const message = {
            messageSender : EVENT_CONSTANT.RECORDCREATED,
            messageToSend : toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    hideModalBox() {
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.HIDEMODAL, {
        }));
    }

    handleGroupNameChange(event) {
        this.groupName = event.target.value;
    }

    handleSubGroupNameChange(event) {
        this.subGroupName = event.target.value;
    }

    handleCreateGroup() {
        this.CreateGroup();
    }
}