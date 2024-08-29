import { LightningElement, track, api} from 'lwc';

const EVENT_CONSTANT = {
    LINEITEMCHANGE : 'lineitemchange'
}
let ids = new Set();

export default class CreateSalesOrderLineItems extends LightningElement {

    @api lineItemWrapper;
    @api quoteDetails;

    @track rowId;
    @track lineItemDetails;
    @track subGroupId;


    connectedCallback() {
        this.lineItemDetails = JSON.parse(JSON.stringify(this.lineItemWrapper));
    }

    handleLineItems(event) {
        if (event.target.checked) {
            ids.add(event.target.dataset.id);
        } else {
            ids.delete(event.target.dataset.id);
        }
        console.log('Ids::::::::::::::::::', ids);
        this.dispatchEvent(new CustomEvent(EVENT_CONSTANT.LINEITEMCHANGE, {
            detail: {
                selectedId : ids
            },
            bubbles: true,
            composed: true
        }));
    }
}