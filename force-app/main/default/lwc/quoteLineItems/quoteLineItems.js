import { LightningElement, track, api, wire} from 'lwc';
import { APPLICATION_SCOPE, createMessageContext, publish, subscribe, unsubscribe } from 'lightning/messageService';
import cloneLineItem from '@salesforce/apex/QuoteLineitemsController.cloneLineItem';
import getLineItemDetails from '@salesforce/apex/QuoteLineitemsController.getLineItemDetails';
import getLineItemRowIndex from '@salesforce/apex/QuoteLineitemsController.getLineItemRowIndex';
import updateRowIndex from '@salesforce/apex/QuoteLineitemsController.updateRowIndex';
import updateSubgroup from '@salesforce/apex/QuoteLineitemsController.updateSubgroup';
import checkRecordId from '@salesforce/apex/DeleteModalController.checkRecordId';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { onQuantityChange, onListPriceChange, onMultiplierChange, onMarginPercentageChange, onSalePriceChange, onLbsChange } from 'c/pricingUtil';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import RELEASEPICK_FIELD from '@salesforce/schema/Product_Select__c.Release_pick__c';
import SALETYPE_FIELD from '@salesforce/schema/Product_Select__c.Sale_Type__c';
                 
const EVENT_CONSTANT = {
    SPINNERTOOGLE : 'spinnerToogle',
    RECORDCLONED : 'recordCloned',
    DRAGDROP : 'DragDrop',
    DELETE : 'delete',
    CLONEITEM : 'cloneitem',
    LINEITEMTOOGLE : 'lineitemtoggle',
    LINEITEMCHANGE : 'lineitemchange',
}

const MESSAGE_CONSTANT = {
    ERROR : 'error',
    ERRORPICKLIST : 'Error fetching picklist values: ',
    SUCCESSCLONELINEITEM : 'Quote Line Item Cloned Successfully',
    ERRORCLONELINEITEM : 'An error occured while Cloning the Quote Line Item ',
    DRAGDROPMESSAGE : 'Line item moved successfully'
}

const CLASS_CONSTANT = {
    ADDCOLOR : 'addcolor',
    REMOVECOLOR : 'removecolor',
    TRHOVER : 'tr-hover',
    QUICKSAVE : 'quicksave',
    FROMCLONELINEITEM : 'fromCloneLineItem',
    FROMQUOTELINEITEMDELETE : 'fromQuoteLineItemDelete'
}

export default class QuoteLineItems extends LightningElement {

    @api lineItemWrapper;
    @api quoteDetails;
   
    @track showDeleteModal = false;
    @track rowId;
    @track lineItemDetails;
    @track lineItemType;
    @track subGroupId;
    @track editDescription = false;
    @track description = '';
    @track releasePickListValues = [];
    @track saleTypePickListValues = [];
    subscription = null;
    @track subGroupIdOfdraggedItem;
    @track rowIndexOfdraggedItem;
    @track rowIndexOfdropItem;
    @track groupIdOfdraggedItem;
    @track subGroupIdOfdropItem;
    @track groupIdOfdropItem;
    @track showButton = false;

    messageContext = createMessageContext();

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: RELEASEPICK_FIELD,
    })
    getPicklistValuesForRelease({ data, error }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.releasePickListValues = [...data.values];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '012000000000000AAA',
        fieldApiName: SALETYPE_FIELD,
    })
    getPicklistValuesForSaleType({ data, error }) {
        if (error) {
            console.log(error);
        } else if (data) {
            this.saleTypePickListValues = [...data.values];
        }
    }

    connectedCallback() {
        this.lineItemDetails = JSON.parse(JSON.stringify(this.lineItemWrapper));
        

        this.subscription = subscribe(
            this.messageContext,
            QUOTE_TOOL_CHANNEL,
            (message) => this.handleMessage(message),
            {scope: APPLICATION_SCOPE}
        );
    }
    async handleDragStart(event) {
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
        
        if(draggedItemId != dropItemId && this.checkId === 'lineitemId') {
            this.publishSpinnerHandler(true);
            this.subGroupIdOfdraggedItem = await getLineItemDetails({lineItemId : draggedItemId});
            this.rowIndexOfdraggedItem = await getLineItemRowIndex({lineItemId : draggedItemId});
            this.rowIndexOfdropItem = await getLineItemRowIndex({lineItemId : dropItemId});
            this.subGroupIdOfdropItem = await getLineItemDetails({lineItemId : dropItemId});
            
            await updateRowIndex({ rowIndex: this.rowIndexOfdropItem, DropsubGroupId: this.subGroupIdOfdropItem, draggedSubGroupId: this.subGroupIdOfdraggedItem, DraggedrowIndex: this.rowIndexOfdraggedItem});
            await updateSubgroup({ lineItemId: draggedItemId, DropsubGroupId: this.subGroupIdOfdropItem, draggedSubGroupId: this.subGroupIdOfdraggedItem, newindex: this.rowIndexOfdropItem}); 
            this.dragAndDrop(MESSAGE_CONSTANT.DRAGDROPMESSAGE);
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

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleMessage(message) {
        if(message.messageSender === 'doCloneLineItem') {
            if(this.rowId != null && this.subGroupId!= null) {
                this.cloneLineItem();
            }
        }
    }

    renderedCallback() {
        this.lineItemDetails.forEach((element) => {
            if (element.saleType === 'B/R' || element.saleType === 'LAB') {
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="salePriceLock"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="cr"]`)?.classList.add('displayNone');
            } else if (element.saleType === 'D/S') {
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="marginPercentage"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="salePrice"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="cr"]`)?.classList.add('displayNone');
            } else if (element.saleType === 'C/R') {
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="listPrice"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="multiplier"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="marginPercentage"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="salePrice"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="salePriceLock"]`)?.classList.add('displayNone');
            } else {
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="marginPercentage"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="salePriceLock"]`)?.classList.add('displayNone');
                this.template.querySelector(`[data-id="${element.lineItemId}"][data-name="cr"]`)?.classList.add('displayNone');
            }
            this.setAllSelectionStyle(element.alternate, element);
        });

        this.updateTransition();
    }

    updateTransition() {
        const container = this.template.querySelector('.smooth-transition');
        if (container) {
            if (this.lineItemDetails) {
                requestAnimationFrame(() => {
                    container.classList.add('open');
                });
            } else {
                container.classList.remove('open');
            }
        }
    }

    handleChange(event) {
        const field = event.target.dataset.name;
        const id = event.target.dataset.id;
        let lineItemChange = [];
        this.lineItemDetails = this.lineItemDetails.map((lineItem) => {
            const lineItemDetail = { ...lineItem };
            if (lineItemDetail.lineItemId === id) {
                if (field === 'listPrice' ||  field === 'salePrice' || field === 'marginPercentage' || field === 'cr' || field === 'lbs') {
                    if (event.target.value == '') {
                        lineItemDetail[field] = 0;
                    } else {
                        lineItemDetail[field] = parseFloat(event.target.value);
                    }
                } else if (field === 'quantity' || field === 'multiplier') {
                    if (event.target.value == '') {
                        lineItemDetail[field] = 0;
                    } else {
                        lineItemDetail[field] = parseInt(event.target.value);
                    }
                } else {
                        lineItemDetail[field] = event.target.value;   
                }
                lineItemChange = lineItemDetail;
            }
            return lineItemDetail;
        });

        this.calculateLineItemLevel(lineItemChange, field);

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }
    
    calculateLineItemLevel(lineItemChange, field) {
        //CalculatePrice And update the line line ITem Details
        let updatedLineItem;
        switch(field) {
            case 'quantity':
                updatedLineItem = onQuantityChange(lineItemChange);
                break;
            case 'listPrice':
                updatedLineItem = onListPriceChange(lineItemChange);
                break;
            case 'multiplier':
                updatedLineItem = onMultiplierChange(lineItemChange);
                break;
            case 'marginPercentage':
                updatedLineItem = onMarginPercentageChange(lineItemChange);
                break;
            case 'salePrice':
                updatedLineItem = onSalePriceChange(lineItemChange);
                break;
            case 'lbs' :
                updatedLineItem = onLbsChange(lineItemChange);
                break;
            default:
                updatedLineItem = lineItemChange;
                break;                 
        }

        // Find the index of the updated line item in the lineItemDetails array
        const index = this.lineItemDetails.findIndex(item => item.lineItemId === updatedLineItem.lineItemId);

        // Replace the line item at the found index with the updated line item
        if (index !== -1) {
            this.lineItemDetails[index] = updatedLineItem;
        }
    }

    handleHeaderReleaseChange(event) {
        this.lineItemDetails.forEach((element) => {
            element.releasepick = event.target.value;
        });

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }

    handleSaleTypeChange(event) {
        const saleType = event.detail.value;
        const lineItemId = event.target.dataset.id;
        let lineItemChange = [];
        let field = null;
        this.lineItemDetails = this.lineItemDetails.map((lineItem) => {
            const lineItemDetail = { ...lineItem };
            if (lineItemDetail.lineItemId === lineItemId) {
                lineItemDetail[event.target.dataset.name] = event.target.value;

                if (saleType == 'B/R' || saleType == 'LAB') {
                    lineItemDetail.cr = 0;
                } else if (saleType == 'D/S') {
                    lineItemDetail.cr = 0;
                    lineItemDetail.marginPercentage = 0;
                    field = 'marginPercentage';
                } else if(saleType == 'C/R') {
                    lineItemDetail.listPrice = 0;
                    lineItemDetail.multiplier = 0;
                    lineItemDetail.marginPercentage = 0;
                    lineItemDetail.unitCost = 0;
                    lineItemDetail.extendedCost = 0;
                    lineItemDetail.salePrice = 0; 
                } else {
                    lineItemDetail.cr = 0;
                    lineItemDetail.marginPercentage = 0;
                    field = 'marginPercentage';
                }
                lineItemChange = lineItemDetail;
            }
            return lineItemDetail;
        });

        if(field != null) {
            this.calculateLineItemLevel(lineItemChange, field);
        }        
    
        const toggleClass = (selector, className, add) => {
            const element = this.template.querySelector(selector);
            if (element) {
                if (add) {
                    element.classList.add(className);
                } else {
                    element.classList.remove(className);
                }
            }
        };
    
        if (saleType == 'B/R' || saleType == 'LAB') {
            toggleClass(`[data-id="${lineItemId}"][data-name="listPrice"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="multiplier"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="marginPercentage"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePriceLock"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePrice"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="cr"]`, 'displayNone', true);
        } else if (saleType == 'D/S') {
            toggleClass(`[data-id="${lineItemId}"][data-name="listPrice"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="multiplier"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="marginPercentage"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePrice"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePriceLock"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="cr"]`, 'displayNone', true);
        } else if (saleType == 'C/R') {
            toggleClass(`[data-id="${lineItemId}"][data-name="listPrice"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="multiplier"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="marginPercentage"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePrice"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePriceLock"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="cr"]`, 'displayNone', false);
        } else {
            toggleClass(`[data-id="${lineItemId}"][data-name="listPrice"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="multiplier"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="marginPercentage"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePriceLock"]`, 'displayNone', true);
            toggleClass(`[data-id="${lineItemId}"][data-name="salePrice"]`, 'displayNone', false);
            toggleClass(`[data-id="${lineItemId}"][data-name="cr"]`, 'displayNone', true);
        }

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }

    handleShowDeleteModal(event) {
        this.showDeleteModal = true;
        this.rowId = event.target.dataset.id;

        const message = {
            messageSender : CLASS_CONSTANT.FROMQUOTELINEITEMDELETE,
            messageToSend : CLASS_CONSTANT.QUICKSAVE
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }

    handleHideDeleteModal() {
        this.showDeleteModal = false;
    }

    async cloneLineItem() {
        try {
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
        const message = {
            messageSender : CLASS_CONSTANT.FROMCLONELINEITEM,
            messageToSend : CLASS_CONSTANT.QUICKSAVE,
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
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

    @api
    updateDataWithMultiplier(multiplier) {
        this.lineItemDetails.forEach((element,index) => {
            element.multiplier = multiplier;
            //call Multiplier Method from PricingUtil
            element = onMultiplierChange(element);
        });
        // Send dispatch event 
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }

    @api
    updateDataWithMargin(margin) {
        this.lineItemDetails.forEach((element,index) => {
            element.marginPercentage = margin;

            //call margin method from pricingUtil 
            element = onMarginPercentageChange(element);
        });

        // Send dispatch event 
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
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
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
    }

    hideRichTextModal() {
        this.editDescription = false;
    }

    handleAlternateChange(event) { 
    
        this.lineItemDetails.forEach((element,index) => {
            if(element.lineItemId === event.target.dataset.id) {
                element.alternate = event.target.checked;
            }
        });

        let closestTR = event.target.closest('tr');
        if(event.target.checked) {
            closestTR.classList.remove(CLASS_CONSTANT.REMOVECOLOR);
            closestTR.classList.add(CLASS_CONSTANT.ADDCOLOR, CLASS_CONSTANT.TRHOVER);
        } else {
            closestTR.classList.remove(CLASS_CONSTANT.ADDCOLOR, CLASS_CONSTANT.TRHOVER);
            closestTR.classList.add(CLASS_CONSTANT.REMOVECOLOR);
        }

       
        let checkAllLineItemAlternate =  this.isAllLineItemAlternate(this.lineItemDetails);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMTOOGLE, {
            detail: {
                lineItems : this.lineItemDetails,
                message : checkAllLineItemAlternate,
                subGroupId : this.lineItemDetails[0].subGroupId
            }
        }));
    }

    isAllLineItemAlternate(allLineItems) {
        return allLineItems.every((element) => {
            return element.alternate;
        });
    }
    
 
    @api
    subGroupToggleChange(checked){
        
        this.lineItemDetails = this.lineItemDetails.map((element, index) => {
            const updatedElement = { ...element };
            updatedElement.alternate = checked;
            this.setAllSelectionStyle(checked, element);    
            return updatedElement;
        });

        return this.lineItemDetails;
    }

    @api
    updatedLineItemData(subGroupDetail) {
        this.lineItemDetails = subGroupDetail.lineItemDetails;
        this.lineItemDetails.forEach((lineitem) => {
            this.calculateLineItemLevel(lineitem, 'marginPercentage');
        }); 
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                lineItems : this.lineItemDetails
            }
        }));
        console.log('this.lineItemDetails' + JSON.stringify(this.lineItemDetails));
    }

    setAllSelectionStyle(isAllSelected, element) {
            let closestTR = this.template.querySelector(`[data-tr="${element.lineItemId}"]`);            
        if(isAllSelected) {
                closestTR.classList.remove(CLASS_CONSTANT.REMOVECOLOR);
                closestTR.classList.add(CLASS_CONSTANT.ADDCOLOR, CLASS_CONSTANT.TRHOVER);
            }else {
                closestTR.classList.remove(CLASS_CONSTANT.ADDCOLOR, CLASS_CONSTANT.TRHOVER);
                closestTR.classList.add(CLASS_CONSTANT.REMOVECOLOR);
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

    handleShowButton() {
        this.showButton = true;
    }
    
    handleHideButton() {
        this.showButton = false;
    }
}