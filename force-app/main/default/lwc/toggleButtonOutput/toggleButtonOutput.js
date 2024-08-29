import { LightningElement, api, wire } from 'lwc';
import QUOTE_TOOL_CHANNEL from '@salesforce/messageChannel/quoteTool__c';
import { MessageContext, publish } from 'lightning/messageService';

const CHECK_CONST = {
    HIDEQUANTITY : 'hideQuantity',
    HIDECODE : 'hideCode',
    HIDEPRICING : 'hidePricing',
    HIDELINE : 'hideLine'
}

export default class ToggleButtonOutput extends LightningElement {
    @api checked = false;
    @api buttonDisabled = false;
    @api rowId;
    @api fieldName;

    @wire(MessageContext)
    messageContext;

    handleToggle(event) { 
        let message;
        if(this.fieldName == CHECK_CONST.HIDEQUANTITY) {
            message={
                messageSender : CHECK_CONST.HIDEQUANTITY,
                messageToSend : event.target.checked,
                messageRowId : this.rowId
            };
        } else if (this.fieldName == CHECK_CONST.HIDECODE) {
            message={
                messageSender : CHECK_CONST.HIDECODE,
                messageToSend : event.target.checked,
                messageRowId : this.rowId
            };
        } else if(this.fieldName == CHECK_CONST.HIDEPRICING) {
            message={
                messageSender : CHECK_CONST.HIDEPRICING,
                messageToSend : event.target.checked,
                messageRowId : this.rowId
            };
        } else {
            message={
                messageSender : CHECK_CONST.HIDELINE,
                messageToSend : event.target.checked,
                messageRowId : this.rowId
            };
        }
        publish(this.messageContext, QUOTE_TOOL_CHANNEL, message);
    }
}