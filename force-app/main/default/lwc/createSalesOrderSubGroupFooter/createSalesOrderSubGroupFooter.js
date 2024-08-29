import { LightningElement, api, track } from 'lwc';
import SalePriceTotal from "@salesforce/label/c.SalePriceTotal";

export default class CreateSalesOrderSubGroupFooter extends LightningElement {
    
    @api subGroupWrapper;
    
    label = {SalePriceTotal}; 
}