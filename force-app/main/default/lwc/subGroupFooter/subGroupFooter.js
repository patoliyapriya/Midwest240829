import { LightningElement, api, track } from 'lwc';
import totalHours from "@salesforce/label/c.Total_Hours";
import totalExtendedCost from "@salesforce/label/c.Total_Extended_Cost";
import total from "@salesforce/label/c.Total";

const COLOR_CONST = {
    ADDCOLOR : 'addcolor',
    FOOTERBG : 'footerbg'
}

export default class SubGroupFooter extends LightningElement {
    
    @api subGroupWrapper;
    @api isMarrs;
    
    label = {totalHours,
        totalExtendedCost,
        total
    }; 

    @track subGroupId;

    connectedCallback() {
        if (this.subGroupWrapper) {
            this.subGroupId = this.subGroupWrapper.subGroupId;
        }
    }

    renderedCallback() {
        this.groupToggleChange(this.subGroupWrapper.alternate);
    }

    @api
    groupToggleChange(checked) {
        const divElement = this.template.querySelector(`[data-footer="${this.subGroupId}"]`);
        if (checked) {
            if (divElement.classList.contains(COLOR_CONST.FOOTERBG)) {
                divElement.classList.remove(COLOR_CONST.FOOTERBG);
            }
            divElement.classList.add(COLOR_CONST.ADDCOLOR);
        } else {
            if (divElement.classList.contains(COLOR_CONST.ADDCOLOR)) {
                divElement.classList.remove(COLOR_CONST.ADDCOLOR);
            }
            divElement.classList.add(COLOR_CONST.FOOTERBG);
        }
    } 
}