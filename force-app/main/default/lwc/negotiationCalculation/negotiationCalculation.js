import { LightningElement,api,track } from 'lwc';
import { calculateSubGroupPrice,calculateOnChangeSubGroupPrice}  from 'c/pricingUtil';

const CLASS_CONSTANT = {
    HIDEADDPRODUCT : 'hideaddproduct',
};

const EVENT_CONSTANT = {
    DETAILCHANGE : 'detailchange',
};

export default class NegotiationCalculation extends LightningElement {
    @api subGrpWrapper;
    @track subGroupHeader;
    @track subGroupHeaderDetails;
    @track changedValue;
    @track projectMarginPercent = '';
    @track changedMarginPercentage = '';
    @track projectMargin = '';
    @track subGroupTotal ='';

    connectedCallback() {
        this.subGroupHeaderDetails = JSON.parse(JSON.stringify(this.subGrpWrapper));
        console.log(this.subGroupHeaderDetails);
        this.subGroupHeader = calculateSubGroupPrice(this.subGroupHeaderDetails);
    }

    renderedCallback() {
        
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.HIDEADDPRODUCT));
    }

    acceptChanges(event) {
        this.subGroupHeaderDetails.lineItemDetails.forEach((element) => {

            element.marginPercentage = this.projectMarginPercent;

        });
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.DETAILCHANGE, {
            detail: {
                subGroupHeaderDetails : this.subGroupHeaderDetails
            }
        }));
        this.dispatchEvent(new CustomEvent(CLASS_CONSTANT.HIDEADDPRODUCT));
    }

    handleChange(event) {
        const field = event.target.dataset.name;
        this.changedValue = event.target.value;
        if(event.target.value != 0) {            
            this.subGroupHeaderDetails = calculateOnChangeSubGroupPrice(this.subGroupHeaderDetails, this.changedValue, field);
            this.changedMarginPercentage = `${this.subGroupHeaderDetails.projectMarginPercent}%`;
            this.projectMarginPercent = this.subGroupHeaderDetails.projectMarginPercent;
            this.projectMargin = this.subGroupHeaderDetails.projectMargin;
            this.subGroupTotal = this.subGroupHeaderDetails.subGroupTotal;
        }
        else {
            this.subGroupTotal = '';
            this.projectMarginPercent = '';
            this.projectMargin = '';
            this.changedMarginPercentage = '';
        }   
    }
}