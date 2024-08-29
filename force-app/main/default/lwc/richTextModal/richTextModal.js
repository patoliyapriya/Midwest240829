import { LightningElement, api, track } from 'lwc';

const EVENT_CONSTANTS = {
    HIDEDELETEMODAL : 'hidedeletemodal',
    SAVEDESCRIPTION : 'savedescription'
};

export default class RichTextModal extends LightningElement {

    @api value;

    @track newValue;

    handleCancel() {
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANTS.HIDEDELETEMODAL));
    }

    handleChange(event) {
        this.newValue = event.target.value;
    }

    handleSave() {
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANTS.SAVEDESCRIPTION, {
            detail: {
                message: this.newValue
            }
        }));
    }
}