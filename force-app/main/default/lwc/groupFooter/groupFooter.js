import { LightningElement, api, track} from 'lwc';
import totalHours from "@salesforce/label/c.TotalHours";
import totalExtendedCost from "@salesforce/label/c.TotalExtendedCost";
import total from "@salesforce/label/c.Total";

const CLASS_CONSTANT = {
    FOOTERBG : 'footerbg',
    ADDCOLOR : 'addcolor'
}

export default class GroupFooter extends LightningElement {
    
    @api groupWrapper;
    @api isMarrs;
    @track groupId;
    
    label = {totalHours,
        totalExtendedCost,
        total
    };

    connectedCallback() {
        if (this.groupWrapper) {
            this.groupId = this.groupWrapper.groupId;
        }
    }

    renderedCallback() {
        this.groupToggleChange(this.groupWrapper.alternate);
    }

    @api
    groupToggleChange(checked) {
        const divElement = this.template.querySelector(`[data-footer="${this.groupId}"]`);
        if (checked) {
            if (divElement.classList.contains(CLASS_CONSTANT.FOOTERBG)) {
                divElement.classList.remove(CLASS_CONSTANT.FOOTERBG);
            }
            divElement.classList.add(CLASS_CONSTANT.ADDCOLOR);
        } else {
            if (divElement.classList.contains(CLASS_CONSTANT.ADDCOLOR)) {
                divElement.classList.remove(CLASS_CONSTANT.ADDCOLOR);
            }
            divElement.classList.add(CLASS_CONSTANT.FOOTERBG);
        }
    } 
}