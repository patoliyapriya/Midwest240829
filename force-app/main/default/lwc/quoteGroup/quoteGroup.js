import { LightningElement, api, track } from 'lwc';
import { calculateGroupPrice, calculateMarrsGroupPrice } from 'c/pricingUtil';

const CHILD_CONSTANT = {
    CHILDSUBGROUP : 'c-quote-sub-group',
    CHILDGROUPFOOTER : 'c-group-footer',
    CHILDGROUPHEADER : 'c-group-header',
    QUOTEGROUPTOGGLE : 'quotegrouptoggle',
    MARRSQUOTEGROUP : 'marrsquotegroup',
}

export default class QuoteGroup extends LightningElement {
    
    @api groupWrapper;
    @api itemDetails;
    @track groupDetails;

    @api quoteid;
    @api quoteDetails;
    @api isMarrs;

    connectedCallback() {
        this.groupDetails = JSON.parse(JSON.stringify(this.groupWrapper));
    }

    renderedCallback() {
        this.groupDetails = calculateGroupPrice(this.groupDetails);
        this.sendEventToQuoteContainer();
    }

    handleAccordianChange(event){
        this.groupDetails = event.detail.groupDetails;
    }

    handleSubGroupAccordion(event) {
        this.replaceElementBySubgroupId(event.detail.subGroupDetails);
        this.template.querySelector(CHILD_CONSTANT.CHILDGROUPHEADER).groupAccordion(this.groupDetails);
    }

    //fetch group wrapper details from quote header & pass to quote Container for toggle
    handleGroupToggle(event) { 
        this.groupDetails = JSON.parse(JSON.stringify(event.detail.message));

        const childComponents = this.template.querySelectorAll(CHILD_CONSTANT.CHILDSUBGROUP);   
        childComponents.forEach(childComponent => {
            childComponent.groupToggleChange(this.groupDetails.alternate);
        });
        this.template.querySelector(CHILD_CONSTANT.CHILDGROUPFOOTER).groupToggleChange(this.groupDetails);
        
        //calculate group price here
        this.groupDetails = calculateGroupPrice(this.groupDetails);
        this.sendEventToQuoteContainer();
    }   

    handelAllsubGroupChecked(event) {
        //Replace subgroup element received from Child
        this.replaceElementBySubgroupId(event.detail.subGroupDetail);
    
        if(event.detail.from == 'allcode') {
            this.groupDetails.alternate = this.isAllsubGroupAlternate(this.groupDetails.subGroupDetails);
            this.template.querySelector(CHILD_CONSTANT.CHILDGROUPHEADER).uncheckToggle(this.groupDetails);
            this.template.querySelector(CHILD_CONSTANT.CHILDGROUPFOOTER).groupToggleChange(this.groupDetails.alternate);
        } 

        //calculate group price here
        this.groupDetails = calculateGroupPrice(this.groupDetails);
        this.sendEventToQuoteContainer();        
    }

    handleMarrsSubGroup(event) {
        this.replaceElementBySubgroupId(event.detail.subGroupDetail);
        this.groupDetails = calculateMarrsGroupPrice(this.groupDetails);
        this.template.querySelector(CHILD_CONSTANT.CHILDGROUPHEADER).marrsDetail(this.groupDetails);

        this.dispatchEvent(new CustomEvent(CHILD_CONSTANT.MARRSQUOTEGROUP, {
            detail: {
                message : this.groupDetails
            }
        }));  
    }

    replaceElementBySubgroupId(newValue) {  
        const index = this.groupDetails.subGroupDetails.findIndex(item => item.subGroupId === newValue.subGroupId);
        if (index !== -1) {
            this.groupDetails.subGroupDetails[index] = newValue;
        }
    }

    isAllsubGroupAlternate(allSubGroup) {
        return allSubGroup.every(item => item.alternate === true);
    }

    //fetch group wrapper details from quote header & pass to quote Container
    handleGroupNameChange(event) {
        this.groupDetails = event.detail.message;
        this.sendEventToQuoteContainer();
    }

    sendEventToQuoteContainer() {
        this.dispatchEvent(new CustomEvent(CHILD_CONSTANT.QUOTEGROUPTOGGLE, {
            detail: {
                message : this.groupDetails
            }
        }));
    }
}