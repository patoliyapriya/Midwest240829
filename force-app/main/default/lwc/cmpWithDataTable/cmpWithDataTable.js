import { LightningElement } from "lwc";

/**
 * A component that uses new datatable
 */
export default class cmpWithDatatable extends LightningElement {
    columns = [
        // standard text column
        { label: "Text Column", fieldName: "textCol", wrapText: true , editable: true},
        
        // custom richText column
        { label: "Rich Text", fieldName: "richTextCol", type: "richText", wrapText: true }
    ];

    tableData = [{
        textCol: "Text",
        richTextCol: "<h3>Rich Text</h3>"
    }];
}