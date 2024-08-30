import { LightningElement, track, api } from 'lwc';
import cloneSubGroup from '@salesforce/apex/SubgroupHeaderController.cloneSubGroup';
import getLineItemDetails from '@salesforce/apex/QuoteLineitemsController.getLineItemDetails';
import getLineItemRowIndex from '@salesforce/apex/QuoteLineitemsController.getLineItemRowIndex';
import getGroupDetails from '@salesforce/apex/SubgroupHeaderController.getGroupDetails';
import updateGroup from '@salesforce/apex/SubgroupHeaderController.updateGroup';
import updateSubGroup from '@salesforce/apex/SubgroupHeaderController.updateSubGroup';
import getsubGroupRowIndex from '@salesforce/apex/SubgroupHeaderController.getsubGroupRowIndex';
import updateRowIndex from '@salesforce/apex/SubgroupHeaderController.updateRowIndex';
import updateLineItemRowIndex from '@salesforce/apex/SubgroupHeaderController.updateLineItemRowIndex';
import checkRecordId from '@salesforce/apex/DeleteModalController.checkRecordId';
import { createMessageContext, publish } from 'lightning/messageService';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import multiplier from "@salesforce/label/c.Multiplier";
import marginPercent from "@salesforce/label/c.MarginPercentage";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    SUCCESSCLONESUBGROUP : 'Sub Group Cloned Successfully',
    ERRORCLONESUBGROUP : 'An error occured while cloning the sub group ',
    DRAGDROPMESSAGE : 'Sub Group moved successfully'
}

const EVENT_CONSTANT = {
    ACCORDION : 'accordion',
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCLONED : 'recordCloned',
    MULTIPLIERCHANGE : 'multiplierchange',
    MARGINCHANGE : 'marginchange',
    SUBGROUPNAMECHANGE : 'subgroupnamechange',
    SUBGROUPTOGGLE : 'subgrouptoggle',
    DRAGDROP : 'DragDrop',
    DETAILCHANGE : 'detailchange',
};

const CLASS_CONSTANT = {
    EDITINPUT : '.edit-input',
    ADDCOLOR : 'addcolor',
    HEADERBG : 'headerbg',
    QUICKSAVE : 'quicksave',
    FROMSUBGROUPHEADER : 'fromSubGroupHeader'
};

export default class SubGroupHeader extends LightningElement {

    @api subGroupWrapper;
    @api quoteDetails;
    @api isMarrs;
    
    @track subGroupDetails;
    @track editFirstName = false;
    @track showButton = false;
    @track showDeleteModal = false;
    @track showNegotiationCalculator = false;
    @track addProducts = false;
    @track groupIdOfdraggedItem;
    @track groupIdOfdropItem;
    @track rowIndexOfdraggedItem;
    @track rowIndexOfdropItem;
    @track subGroupIdOfdraggedItem;
    @track rowIndexOfdraggedLineItem;
    @track newProducts = false;
    @track isOpen = true;

    oldMultiplier = '';
    oldMargin = '';

    label = {
        multiplier,
        marginPercent
    };
    
    messageContext = createMessageContext();

    connectedCallback() {
        this.subGroupDetails = JSON.parse(JSON.stringify(this.subGroupWrapper));
    }

    handleDragStart(event) {
        event.dataTransfer.setData('text', event.target.dataset.id);
        this.addScrollEventListeners();
    }

    async handleDragOver(event) {
        event.preventDefault();
    }

    async handleDrop(event) {
        this.removeScrollEventListeners();

        const draggedItemId = event.dataTransfer.getData('text');
        // console.log('draggedLineItem=========>'+draggedItemId);
        const dropItemRow = event.target.closest('.dragClass');
        const dropItemId = dropItemRow ? dropItemRow.dataset.id : null;
        // console.log('dropLineItem=========>'+dropItemId);
        this.checkId = await checkRecordId({recordId: draggedItemId});

        if(draggedItemId != dropItemId && this.checkId === 'subGroupId') {
            this.publishHandler(true);
            this.groupIdOfdropItem = await getGroupDetails({ subgroupId: dropItemId });
            this.groupIdOfdraggedItem = await getGroupDetails({subgroupId : draggedItemId});
            this.rowIndexOfdropItem = await getsubGroupRowIndex({subgroupId : dropItemId});
            this.rowIndexOfdraggedItem = await getsubGroupRowIndex({subgroupId : draggedItemId});
        
            await updateRowIndex({ rowIndex: this.rowIndexOfdropItem, DropGroupId: this.groupIdOfdropItem, draggedGroupId: this.groupIdOfdraggedItem, DraggedrowIndex: this.rowIndexOfdraggedItem});
    
            await updateGroup({ dropGroupId: this.groupIdOfdropItem, draggedSubGroupId: draggedItemId, newindex: this.rowIndexOfdropItem});
    
            this.dragAndDrop(MESSAGE_CONSTANT.DRAGDROPMESSAGE);
            // window.location.reload();
        }
        else if(this.checkId === 'lineitemId') {
            this.subGroupIdOfdraggedItem = await getLineItemDetails({lineItemId : draggedItemId});
            if(this.subGroupIdOfdraggedItem != dropItemId) {
                this.publishHandler(true);
                this.rowIndexOfdraggedLineItem = await getLineItemRowIndex({lineItemId : draggedItemId});
                await updateLineItemRowIndex({ draggedSubGroupId: this.subGroupIdOfdraggedItem, DraggedrowIndex: this.rowIndexOfdraggedLineItem});
                await updateSubGroup({ dropSubGroupId: dropItemId, draggedLineItemId: draggedItemId });
                this.dragAndDrop(MESSAGE_CONSTANT.DRAGDROPMESSAGE);
            }
        }
    }

    dragAndDrop(toastMessage) {
        const message = {
            messageSender: EVENT_CONSTANT.DRAGDROP,
            messageToSend: toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    publishHandler(isLoading) {
        const message = {
            messageSender : EVENT_CONSTANT.SPINNERTOOGLE,
            messageToSend : isLoading
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

    renderedCallback() {
        if (this.subGroupWrapper) {
            this.setAllSelectionStyle(this.subGroupDetails.alternate);
        }
    } 

    handleshownewproduct(){
        this.addProducts = false;
        this.newProducts = true;
    }
    handleHideNewProduct(){
        this.addProducts = true;
        this.newProducts = false;
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
        this.subGroupDetails.subGroupName = event.target.value;
    }
    
    handleUpdateFirstName(event) {
        this.editFirstName = false;
        this.subGroupDetails = JSON.parse(JSON.stringify(this.subGroupDetails));
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.SUBGROUPNAMECHANGE, {
            detail: {
                message : this.subGroupDetails
            }
        }));
    }

    handleShowButton() {
        this.showButton = true;
    }
    
    handleHideButton() {
        this.showButton = false;
    }

    handleHideDeleteModal() {
        this.showDeleteModal = false;
    }

    handleShowDeleteModal() {
        this.showDeleteModal = true;

        const message = {
            messageSender : CLASS_CONSTANT.FROMSUBGROUPHEADER,
            messageToSend : CLASS_CONSTANT.QUICKSAVE,
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    handleSubGroupAccordion() {
        this.subGroupDetails.isOpen = !(this.subGroupDetails.isOpen);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                subGroupDetails : this.subGroupDetails
            }
        }));
    }

    @api
    subGroupAccordion(subGroupDetail) {
        this.subGroupDetails = subGroupDetail;
    }

    handleShowAddProduct() {
        const message = {
            messageSender : CLASS_CONSTANT.FROMSUBGROUPHEADER,
            messageToSend : CLASS_CONSTANT.QUICKSAVE, 
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
        this.addProducts = true;
    }

    handleHideAddProduct() {
        this.addProducts = false;
    }

    async cloneSubGroup() {
        try {
            await cloneSubGroup({recordId : this.subGroupDetails.subGroupId, groupId : this.subGroupDetails.groupId});
            this.publishCloneSubGroupCreated(MESSAGE_CONSTANT.SUCCESSCLONESUBGROUP);            
            
        } catch (error){
            const toastEvent = new ShowToastEvent({
                title: MESSAGE_CONSTANT.ERROR,
                message: MESSAGE_CONSTANT.ERRORCLONESUBGROUP + error.body.message,
                variant: MESSAGE_CONSTANT.ERROR
            }); 
            this.dispatchEvent(toastEvent); 
        }
    }

    handleCloneSubGroup() {
        const message = {
            messageSender : CLASS_CONSTANT.FROMSUBGROUPHEADER,
            messageToSend : CLASS_CONSTANT.QUICKSAVE,
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);

        this.cloneSubGroup();
    }

    publishCloneSubGroupCreated(toastMessage) {
        const message = {
            messageSender : EVENT_CONSTANT.RECORDCLONED,
            messageToSend : toastMessage
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    handleNegotiationCalculator() {
        this.showNegotiationCalculator = true;
    }
    
    handleHideNegotiationCalculation() {
        this.showNegotiationCalculator = false;
    }

    handleMultiplierChange(event) {
        if (this.oldMultiplier === event.target.value) {
            return;
        }
        this.oldMultiplier = event.target.value;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.MULTIPLIERCHANGE, {
            detail: {
                message: event.target.value
            }
        }));
    }

    handleMarginChange(event) {
        if (this.oldMargin === event.target.value) {
            return;
        }
        this.oldMargin = event.target.value;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.MARGINCHANGE, {
            detail: {
                message: event.target.value
            }
        }));
    }

    handleToggleChange(event) { 
        this.setAllSelectionStyle(event.target.checked);
        this.subGroupDetails.alternate = event.target.checked;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.SUBGROUPTOGGLE, {
            detail: {
                message : this.subGroupDetails
            }
        }));
    }

    @api
    groupToggleChange(subGroupChange) {
        this.subGroupDetails = subGroupChange;
        this.setAllSelectionStyle(this.subGroupDetails.alternate);      
    }

    setAllSelectionStyle(isAllSelected) {
           let divElement = this.template.querySelector(`[data-header="${this.subGroupDetails.subGroupId}"]`);
           if (isAllSelected) {
                if (divElement.classList.contains(CLASS_CONSTANT.HEADERBG)) {
                    divElement.classList.remove(CLASS_CONSTANT.HEADERBG);
                }
                divElement.classList.add(CLASS_CONSTANT.ADDCOLOR);
           } else {
                if (divElement.classList.contains(CLASS_CONSTANT.ADDCOLOR)) {
                    divElement.classList.remove(CLASS_CONSTANT.ADDCOLOR);
                }
                divElement.classList.add(CLASS_CONSTANT.HEADERBG);
           }       
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

    handleDetailChange(event) {
        this.subGroupDetails = event.detail.subGroupHeaderDetails;
        // console.log('this.subGroupDetails11' + JSON.stringify(this.subGroupDetails));
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.DETAILCHANGE, {
            detail: {
                subGroupHeaderDetails : this.subGroupDetails
            }
        }));
    }
}