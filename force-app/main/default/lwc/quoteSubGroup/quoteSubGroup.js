import { LightningElement, api, track } from 'lwc';
import { calculateSubGroupPrice, calculateMarrsSubGroupPrice}  from 'c/pricingUtil';

const EVENT_CONSTANT = {
    ALLSUBGROUPCHECKED :'allsubgroupchecked',
    MARRSSUBGROUP : 'marrssubgroup',
    ACCORDION : 'accordion'
}

const CHILD_CONSTANT = {
    CHILDLINEITEM : 'c-quote-line-items',
    CHILDSUBGROUPFOOTER : 'c-sub-group-footer',
    CHILDSUBGROUPHEADER : 'c-sub-group-header',
};

export default class QuoteSubGroup extends LightningElement {

    @api subGroupWrapper;
    @api quoteDetails;
    @api groupWrapper;
    @api isMarrs;
    
    @track subGroupHeader;

    connectedCallback() {
        this.subGroupHeader = JSON.parse(JSON.stringify(this.subGroupWrapper));
    }

    renderedCallback() {
        if(this.isMarrs == true) {
            this.subGroupHeader = calculateMarrsSubGroupPrice(this.subGroupHeader);
            this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.MARRSSUBGROUP, {
            detail: {
                subGroupDetail : this.subGroupHeader
            }
        }));
        }
        else {
            this.subGroupHeader = calculateSubGroupPrice(this.subGroupHeader);
            this.dispatchToQuoteGroup('notallcode');
        } 
    }
    
    handleAccordianChange(event){
        this.subGroupHeader = event.detail.subGroupDetails;

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ACCORDION, {
            detail: {
                subGroupDetails : this.subGroupHeader
            }
        }));
    }

    handleMultiplierChange(event) {
        this.template.querySelector(CHILD_CONSTANT.CHILDLINEITEM).updateDataWithMultiplier(event.detail.message);
    }

    handleMarginChange(event) {
        this.template.querySelector(CHILD_CONSTANT.CHILDLINEITEM).updateDataWithMargin(event.detail.message);
    }

    dispatchToQuoteGroup(message) {
        //custom event to parent to change group toggle and pass the details if or not all selected line item
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.ALLSUBGROUPCHECKED, {
            detail: {
                subGroupDetail : this.subGroupHeader,
                from : message
            }
        }));
    }

    //handling subgroupheader custom event - When User Updates Toggle of Subheader
    handleSubGroupToggle(event) {
        this.subGroupHeader = event.detail.message;
        //Child line item toggle change
        this.subGroupHeader.lineItemDetails = this.template.querySelector(CHILD_CONSTANT.CHILDLINEITEM).subGroupToggleChange(this.subGroupHeader.alternate);
      
        //when toggle is on, prize will be calculate at sub group level
        this.subGroupHeader = calculateSubGroupPrice(this.subGroupHeader);

        //Child footer calculateion change on sub header toggle change
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPFOOTER).groupToggleChange(this.subGroupHeader.alternate);
        
        this.dispatchToQuoteGroup('allcode');
    }

    //coming from quote group
    @api
    groupToggleChange(checked) {
        //Change Sub Header Toggle based on all Line Item selection
        this.subGroupHeader.alternate = checked;
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPHEADER).groupToggleChange(this.subGroupHeader);
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPFOOTER).groupToggleChange(checked);
        this.subGroupHeader.lineItemDetails = this.template.querySelector(CHILD_CONSTANT.CHILDLINEITEM).subGroupToggleChange(checked);

        //Child footer calculateion change on sub header toggle change
        this.subGroupHeader = calculateSubGroupPrice(this.subGroupHeader);
         
        this.dispatchToQuoteGroup('notallcode');
    }
    
    //coming from line item - When User Toggles Line Item
    handleLineItemToggle(event) { 
        
        //Change Sub Header Toggle based on all Line Item selection
        this.subGroupHeader.alternate = event.detail.message;
        this.subGroupHeader.lineItemDetails = event.detail.lineItems;

        //Call Sub Header Toggle method
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPHEADER).groupToggleChange(this.subGroupHeader);
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPFOOTER).groupToggleChange(event.detail.message);

        // CalculateSubGroupPrice mehtods
        this.subGroupHeader = calculateSubGroupPrice(this.subGroupHeader);

        this.dispatchToQuoteGroup('allcode');
    }

    handleLineItemChange(event) {
        this.subGroupHeader.lineItemDetails = event.detail.lineItems;
        // calculate the pricing at line item level
        this.subGroupHeader = calculateSubGroupPrice(this.subGroupHeader);

        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPHEADER).subGroupAccordion(this.subGroupHeader);
        
        //dispatch event
        this.dispatchToQuoteGroup('allcode');
    }

    handleMarrsLineItemChange(event) {
        this.subGroupHeader.lineItemDetails = event.detail.lineItems;
        this.subGroupHeader = calculateMarrsSubGroupPrice(this.subGroupHeader);

        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPHEADER).subGroupAccordion(this.subGroupHeader);

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.MARRSSUBGROUP, {
            detail: {
                subGroupDetail : this.subGroupHeader
            }
        }));
    }

    handleSubGroupNameChange(event) {
        this.subGroupHeader = event.detail.message;
        this.dispatchToQuoteGroup('allcode');
    }

    handleDetailChange(event) {
        this.subGroupHeader = event.detail.subGroupHeaderDetails;
        console.log('this.subGroupDetails' + JSON.stringify(this.subGroupHeader));
        this.template.querySelector(CHILD_CONSTANT.CHILDLINEITEM).updatedLineItemData(this.subGroupHeader);
    }
}