import { LightningElement, api, track} from 'lwc';

const EVENT_CONSTANT = {
    HIDEALLQUANTITY : 'hideQuantity',
    HIDEPRODUCTCODE : 'hideCode',
    HIDEALLLINEITEMS : 'hideLine',
    TOGGLECHANGE : 'togglechange',
    HIDEAMOUNT : 'hideAmount',
    ACCORDION : 'accordion'
};

const CHILD_CONSTANT = {
    CHILDDESIGNLINEITEMS : 'c-design-quote-line-items',
    CHILDSUBGROUPHEADER : 'c-design-quote-sub-group-header',
    CHILDSUBGROUPFOOTER : 'c-design-quote-sub-group-footer'
};

export default class DesignQuoteSubGroup extends LightningElement {
    
    @api subGroupWrapper;
    
    @track subGroupHeader;

    connectedCallback() {
        if(this.subGroupWrapper) {
            this.subGroupHeader = JSON.parse(JSON.stringify(this.subGroupWrapper));
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

    handleToggleChange(event) { 
        this.subGroupHeader = event.detail.message;
        let field = event.detail.from;
        let field2 = event.detail.from;
        if(field === 'hideAmount') {
            field2 = 'hidePricing';
        }

        this.subGroupHeader.lineItemDetails = this.template.querySelector(CHILD_CONSTANT.CHILDDESIGNLINEITEMS).subGroupToggle(this.subGroupHeader[field],field2);
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPFOOTER).toggleChanges(this.subGroupHeader);

        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.TOGGLECHANGE, {
            detail: {
                subGroupDetail : this.subGroupHeader
            }
        }));
    }

    handleFooterToggle(event) {
        this.subGroupHeader = event.detail.message;
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.TOGGLECHANGE, {
            detail: {
                subGroupDetail : this.subGroupHeader
            }
        }));
    }

    handleLineItemToggle(event) { 
        if(event.detail.isFrom !== 'pageBreak'){
            let field;
            field = event.detail.isFrom;
            if(event.detail.isFrom === 'hidePricing') {
                field = 'hideAmount';
            }
            this.subGroupHeader[field] = event.detail.message;
        }
        this.subGroupHeader.lineItemDetails = event.detail.value;
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPHEADER).lineItemToggle(this.subGroupHeader);
        this.template.querySelector(CHILD_CONSTANT.CHILDSUBGROUPFOOTER).toggleChanges(this.subGroupHeader);
        
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.TOGGLECHANGE, {
            detail: {
                subGroupDetail : this.subGroupHeader
            }
        }));
    }
}