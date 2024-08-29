import { LightningElement, api} from 'lwc';
import extendedCostLabel from "@salesforce/label/c.ExtendedCostLabel";
import directSellPriceLabel from "@salesforce/label/c.DirectSellPrice";
import buyResellAndPTPrice from "@salesforce/label/c.BuyResellAndPtPrice";
import buyResellAndPTMarginPercent from "@salesforce/label/c.BuyResellAndPtMarginPercent";
import buyResellAndPTMargin from "@salesforce/label/c.BuyResellAndPtMargin";
import commissionAndRebates from "@salesforce/label/c.CommissionAndRebates";
import projectMarginPercent from "@salesforce/label/c.ProjectMarginPercent";
import projectMargin from "@salesforce/label/c.ProjectMargin";
import sellPrice from "@salesforce/label/c.SellPrice";

export default class QuoteFooter extends LightningElement {
    
    @api quoteDetails;
    @api isMarrs;
    




        // const field = [
        //     'extendedCost'
        // ];

        // this.quoteDetail.forEach((element) => {
        //     if(element[field] === undefined) {
        //         element[field] = 0;
        //     }
        // });

        // if(this.quoteDetail.extendedCost == undefined) {
        //     this.quoteDetail.extendedCost = 0;
        // } 
        // if(this.quoteDetail.directSellPrice == undefined) {
        //     this.quoteDetail.directSellPrice = 0;
        // } 
        // if(this.quoteDetail.buyResellPrice == undefined) {
        //     this.quoteDetail.buyResellPrice = 0;
        // } 
        // if(this.quoteDetail.buyResellMargin == undefined) {
        //     this.quoteDetail.buyResellMargin = 0;
        // } 
        // if(this.quoteDetail.buyResellMarginPercent == undefined) {
        //     this.quoteDetail.buyResellMarginPercent = 0;
        // } 
        // if(this.quoteDetail.projectMargin == undefined) {
        //     this.quoteDetail.projectMargin = 0;
        // } 
        // if(this.quoteDetail.projectMarginPercent == undefined) {
        //     this.quoteDetail.projectMarginPercent = 0;
        // } 
        // if(this.quoteDetail.sellPrice == undefined) {
        //     this.quoteDetail.sellPrice = 0;
        // }  
        
    
    
    label = {extendedCostLabel,
        directSellPriceLabel,
        buyResellAndPTPrice,
        buyResellAndPTMarginPercent,
        buyResellAndPTMargin,
        commissionAndRebates,
        projectMarginPercent,
        projectMargin,
        sellPrice
    };
}