import { LightningElement, track, api} from 'lwc';
import cloneLineItem from '@salesforce/apex/QuoteLineitemsController.cloneLineItem';
import getLineItemDetails from '@salesforce/apex/QuoteLineitemsController.getLineItemDetails';
import getLineItemRowIndex from '@salesforce/apex/QuoteLineitemsController.getLineItemRowIndex';
import updateRowIndex from '@salesforce/apex/QuoteLineitemsController.updateRowIndex';
import updateSubgroup from '@salesforce/apex/QuoteLineitemsController.updateSubgroup';
import checkRecordId from '@salesforce/apex/DeleteModalController.checkRecordId';
import { createMessageContext, publish } from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
                 
const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCLONED : 'recordCloned',
    MARRSLINEITEMCHANGE : 'marrslineitemchange',
    DRAGDROP : 'DragDrop'
}

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    SUCCESSCLONELINEITEM : 'Quote Line Item Cloned Successfully',
    ERRORCLONELINEITEM : 'An error occured while Cloning the Quote Line Item ',
    DRAGDROPMESSAGE : 'Line item moved successfully'
}

export default class MarrsQuoteLineItems extends LightningElement {

    @api lineItemWrapper;
    @api quoteDetails;

    @track showDeleteModal = false;
    @track rowId;
    @track lineItemDetails;
    @track subGroupId;
    @track editDescription = false;
    @track description = '';
    @track subGroupIdOfdraggedItem;
    @track rowIndexOfdraggedItem;
    @track rowIndexOfdropItem;
    @track groupIdOfdraggedItem;
    @track subGroupIdOfdropItem;
    @track groupIdOfdropItem;
    @track checkId;

    messageContext = createMessageContext();
    
    connectedCallback() {
        this.lineItemDetails = JSON.parse(JSON.stringify(this.lineItemWrapper));
    }

    handleDragStart(event) {
        event.dataTransfer.setData('text', event.target.dataset.id);
        this.addScrollEventListeners();
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    async handleDrop(event) {

        this.removeScrollEventListeners();
        const draggedItemId = event.dataTransfer.getData('text');
        const dropItemRow = event.target.closest('tr');
        const dropItemId = dropItemRow ? dropItemRow.dataset.id : null;
        this.checkId = await checkRecordId({recordId: draggedItemId});
        // const draggedIndex = this.lineItemDetails.findIndex(lineItem => lineItem.lineItemId === draggedItemId);
        // const dropIndex = this.lineItemDetails.findIndex(lineItem => lineItem.lineItemId === dropItemId);
        if(draggedItemId != dropItemId && this.checkId === 'lineitemId') {
            this.publishSpinnerHandler(true);
            this.subGroupIdOfdraggedItem = await getLineItemDetails({lineItemId : draggedItemId});
            this.rowIndexOfdraggedItem = await getLineItemRowIndex({lineItemId : draggedItemId});
            this.rowIndexOfdropItem = await getLineItemRowIndex({lineItemId : dropItemId});
            this.subGroupIdOfdropItem = await getLineItemDetails({lineItemId : dropItemId});
            
            await updateRowIndex({ rowIndex: this.rowIndexOfdropItem, DropsubGroupId: this.subGroupIdOfdropItem, draggedSubGroupId: this.subGroupIdOfdraggedItem, DraggedrowIndex: this.rowIndexOfdraggedItem});
            await updateSubgroup({ lineItemId: draggedItemId, DropsubGroupId: this.subGroupIdOfdropItem, draggedSubGroupId: this.subGroupIdOfdraggedItem, newindex: this.rowIndexOfdropItem});
            // this.publishSpinnerHandler(false);
            this.dragAndDrop(MESSAGE_CONSTANT.DRAGDROPMESSAGE);
            // window.location.reload();     
        }       
    }

    dragAndDrop(toastMessage) {
        const message = {
            messageSender: EVENT_CONSTANT.DRAGDROP,
            messageToSend: toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }
    
    addScrollEventListeners() {
        document.addEventListener('drag', this.handleDragScroll.bind(this));
    }
    
    removeScrollEventListeners() {
        document.removeEventListener('drag', this.handleDragScroll.bind(this));
    }
    
    handleDragScroll(event) {
        const scrollThreshold = 70; // Threshold in pixels from the edge to start scrolling
        const scrollAmount = 10; // Amount in pixels to scroll
        const topOffset = 120;
    
        const windowHeight = window.innerHeight;
        const mouseY = event.clientY;
    
        if (mouseY < scrollThreshold + topOffset) {
            // Scroll up
            window.scrollBy(0, -scrollAmount);
        } else if (mouseY > windowHeight - scrollThreshold) {
            // Scroll down
            window.scrollBy(0, scrollAmount);
        }
    }

    handleShowDeleteModal(event) {
        this.showDeleteModal = true;
        this.rowId = event.target.dataset.id;
    }

    handleHideDeleteModal() {
        this.showDeleteModal = false;
    }

    handleChange(event) {
        const field = event.target.dataset.name;
        const id = event.target.dataset.id;
        let lineItemChange = [];
        this.lineItemDetails = this.lineItemDetails.map((lineItem) => {
            const lineItemDetail = { ...lineItem };
            if (lineItemDetail.lineItemId === id) {
                if (field === 'salePrice') {
                    if (event.target.value == '') {
                        lineItemDetail[field] = 0;
                    } else {
                        lineItemDetail[field] = parseFloat(event.target.value);
                    }
                } else {
                        lineItemDetail[field] = event.target.value;   
                }
                lineItemChange = lineItemDetail;
            }
            return lineItemDetail;
        });

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.MARRSLINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }

    showRichTextModal(event) {
        this.editDescription = true;
        this.rowId = event.target.dataset.id;
        this.description = this.lineItemDetails.find(item => item.lineItemId === event.target.dataset.id).description;
    }

    handleDescriptionChange(event) {
        this.lineItemDetails.find(item => item.lineItemId === this.rowId).description = event.detail.message;
        this.editDescription = false;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.MARRSLINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }

    hideRichTextModal() {
        this.editDescription = false;
    }

    handleInputChange(event) {
        let input = event.target.value;
        if (!isNaN(input)) {
            
            let parts = input.toString().split('.');
            if (parts.length > 1 && parts[1].length > 2) {
               
                parts[1] = parts[1].slice(0, 2);
                input = parseFloat(parts.join('.'));
            }
          
            event.target.value = input;
            }
    }

    async cloneLineItem() {
        try {
            this.publishSpinnerHandler(true);
            await cloneLineItem({lineItemId : this.rowId, subGroupId : this.subGroupId});
            this.publishCloneLineItemCreated(MESSAGE_CONSTANT.SUCCESSCLONELINEITEM);
        }
        catch (error) {
            const toastEvent = new ShowToastEvent({
                title: MESSAGE_CONSTANT.ERROR,
                message: MESSAGE_CONSTANT.ERRORCLONELINEITEM + error.body.message,
                variant: MESSAGE_CONSTANT.ERROR
            });
            this.dispatchEvent(toastEvent); 
        }
    }

    handleCloneLineItem(event) {
        this.rowId = event.target.dataset.id;
        this.subGroupId = event.target.dataset.subgroupid;
        this.cloneLineItem();
    }

    publishSpinnerHandler(isLoading) {
        const message = {
            messageSender: EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend: isLoading
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    publishCloneLineItemCreated(toastMessage) {
        const message = {
            messageSender: EVENT_CONSTANT.RECORDCLONED,
            messageToSend: toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }
}