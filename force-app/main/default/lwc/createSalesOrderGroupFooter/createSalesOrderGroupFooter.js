import { LightningElement, api, track } from 'lwc';
import SalePriceTotal from "@salesforce/label/c.SalePriceTotal";

export default class CreateSalesOrderGroupFooter extends LightningElement {
    
    @api groupWrapper;
    
    label = {SalePriceTotal}; 

}