import { LightningElement, api, track} from 'lwc';
import { publish} from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import confirmDeleteLabel from "@salesforce/label/c.ConfirmDelete";
import cancelLabel from "@salesforce/label/c.CancelButtonLabel";
import deleteLabel from "@salesforce/label/c.DeleteLabel";
import deleteRecord from '@salesforce/apex/DeleteModalController.deleteRecord';
import checkRecordId from '@salesforce/apex/DeleteModalController.checkRecordId';
import { createMessageContext} from 'lightning/messageService';
import getLineItemDetails from '@salesforce/apex/QuoteLineitemsController.getLineItemDetails';
import getLineItemRowIndex from '@salesforce/apex/QuoteLineitemsController.getLineItemRowIndex';
import rowIndexUpdate from '@salesforce/apex/QuoteLineitemsController.rowIndexUpdate';
import getGroupDetails from '@salesforce/apex/SubgroupHeaderController.getGroupDetails';
import getsubGroupRowIndex from '@salesforce/apex/SubgroupHeaderController.getsubGroupRowIndex';
import subGrouprowIndexUpdate from '@salesforce/apex/SubgroupHeaderController.subGrouprowIndexUpdate';

const CLASS_CONSTANT = {
    HIDEDELETEMODAL : 'hidedeletemodal',
};

const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDDELETED : 'recordDeleted',
};

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    DELETESUCCESS : ' deleted successfully',
    ERRORMESSAGE : 'An error occurred while Deleting: ',
};

export default class DeleteModal extends LightningElement {

    @api recordId;
    @api isFrom;

    @track checkId;
    @track deletedItemSubGroup;
    @track rowIndexOfItem;

    messageContext = createMessageContext();

    label = {confirmDeleteLabel,
        deleteLabel,
        cancelLabel
    };

    async DeleteRecord() {
        try {
            this.hideDeleteModalBox();
            this.publishHandler(true);
        //     await deleteRecord({recordId: this.recordId});
        //     this.publishRecordDeleted(this.isFrom + MESSAGE_CONSTANT.DELETESUCCESS);
        // } 
        this.checkId = await checkRecordId({recordId: this.recordId});
            
            if(this.checkId === 'lineitemId') {
                this.deletedItemSubGroup = await getLineItemDetails({lineItemId : this.recordId});
                this.rowIndexOfItem = await getLineItemRowIndex({lineItemId : this.recordId});
                await rowIndexUpdate({ subGroupId: this.deletedItemSubGroup, rowIndex: this.rowIndexOfItem});
            
                await deleteRecord({recordId: this.recordId});
            }
            else if(this.checkId === 'subGroupId') {

                this.deletedItemGroup = await getGroupDetails({ subgroupId: this.recordId });
                this.rowIndexOfItem = await getsubGroupRowIndex({subgroupId : this.recordId});
                await subGrouprowIndexUpdate({ subGroupId: this.deletedItemGroup, rowIndex: this.rowIndexOfItem});

                await deleteRecord({recordId: this.recordId});
            }
            else if(this.checkId === 'groupId') {
                await deleteRecord({recordId: this.recordId});
            }
            else {
                await deleteRecord({recordId: this.recordId});
            }

            

            this.publishRecordDeleted(this.isFrom + MESSAGE_CONSTANT.DELETESUCCESS);

            

        } catch (error) {
        
            const toastEvent = new ShowToastEvent({
                title: MESSAGE_CONSTANT.ERROR,
                message: MESSAGE_CONSTANT.ERRORMESSAGE + error.body.message,
                variant: MESSAGE_CONSTANT.ERROR
            });
            this.dispatchEvent(toastEvent);
        }
    }

    publishHandler(isLoading) {
        const message = {
            messageSender : EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend : isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    publishRecordDeleted(toastMessage) {
        const message = {
            messageSender : EVENT_CONSTANT.RECORDDELETED,
            messageToSend : toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    hideDeleteModalBox() {
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.HIDEDELETEMODAL));
    }

    handleDelete() {
        this.DeleteRecord();
    }
}