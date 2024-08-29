import LightningDatatable from "lightning/datatable";
import richTextColumnType from "./richTextColumnType.html";
import longTextColumnType from "./longText.html";
import picklistColumn from './picklistColumn.html';
import pickliststatic from './picklistStatic.html';
import toggleButtonColumnType from './toggleButton.html';

export default class MyCustomDatatable extends LightningDatatable {
    static customTypes={
        richText: {
            template: richTextColumnType,
            standardCellLayout: true
        },
        longText: {
            template: longTextColumnType,
            standardCellLayout: true
        },
        picklistColumn: {
            template: pickliststatic,
            editTemplate: picklistColumn,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        },
        toggleButton: {
            template: toggleButtonColumnType,
            standardCellLayout: true,
            typeAttributes: ['buttonDisabled', 'rowId', 'field'],
        }
    }

}