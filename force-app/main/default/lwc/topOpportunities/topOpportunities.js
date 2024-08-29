import { LightningElement, wire, track,api } from 'lwc';
import fethcOpportunityWrapper from'@salesforce/apex/TopOpportunitiesController.buildOpporunityWrapper';
import { NavigationMixin } from 'lightning/navigation';
import userId from '@salesforce/user/Id';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import DASHBORAD_CHANNEL from "@salesforce/messageChannel/SelectedUser__c";
//const TARGET_NEGOTIATING = 'TARGET/NEGOTIATING';
//const POST_BID = 'POST BID';
//const BIDDING = 'BIDDING';
//const LEAD_DD_BUDGET = 'LEAD,DD/BUDGET';
const SAINT_LOUIS = 'Saint Louis';
const OKLAHOMA = 'Oklahoma';
const KANSAS_CITY = 'Kansas City';
const DENVER = 'Denver';

const columns = [
    { label: 'Opp Number', fieldName: 'OpportunityUrl', hideDefaultActions: true, type: 'url',
    typeAttributes: {
        label: {fieldName: 'Opportunity_Number__c'},
        target : '_blank'
    }},
    { label: 'Opportunity Name', fieldName: 'OpportunityName', hideDefaultActions: true },
    { label: 'Owner', fieldName: 'Owner', hideDefaultActions: true },
    { label: 'SE Margin', fieldName: 'SEMargin', type: 'Decimal', hideDefaultActions: true,type: 'currency' },
    { label: 'SE Revenue', fieldName: 'SERevenue', type: 'Decimal', hideDefaultActions: true,type: 'currency' },
    { label: 'SE Prjct. Margin', fieldName: 'Total_Project_Margin__c', type: 'double', hideDefaultActions: true,type: 'currency'},
    { label: 'SE Prjct. Revenue', fieldName: 'TotalRevenue', hideDefaultActions: true,type: 'currency'},
    { label: 'Est. Close Date', fieldName: 'CloseDate', type: 'date', hideDefaultActions: true },
    { label: 'Est. Ship Date', fieldName: 'Ship_Date__c', type: 'date', hideDefaultActions: true },
    { label: 'Prob %', fieldName: 'Probability', hideDefaultActions: true},
    { label: 'Bidders', fieldName: 'Bidders', hideDefaultActions: true },
    { label: 'Description', fieldName: 'Description', hideDefaultActions: true},
    { label: 'Last Chatter Action', fieldName: 'lastChatterAction', hideDefaultActions: true}
];

export default class TopOpportunities extends NavigationMixin(LightningElement) {

    @api stageName;
    @api tableHeader;
    @api isLoading = false;
    @api salesRep = userId;
    @track recordId;
    @track TobBidOppList;
    title;
    columns = columns;


    connectedCallback() {
        fethcOpportunityWrapper({stageName : this.stageName, selectedUserId : userId}).then((data) => {
            data = JSON.parse(JSON.stringify(data));
            console.log('fetch opp data',data );
            this.formateWrapperData(data);
        });
        
        this.title = "Top " +"10 "+ this.stageName +" Opportunities";
        console.log('custom title == ' +this.title);
        this.subscribeToMessageChannel();
    }


    receivedMessage
    subscription = null;
    //2.subscribe message from channel
    @wire(MessageContext)
    MessageContext;
    
    //3.Handling 
    subscribeToMessageChannel() {
      console.log("in handle subscribe opp");
        if (this.subscription) {
            return;
        }
    
        //4. Subscribing to the message channel
        this.subscription = subscribe(
                            this.MessageContext,
                                DASHBORAD_CHANNEL,
                                (message) => this.handleMessage(message),
                                { scope : APPLICATION_SCOPE }
                            );
       // console.log('handleMessage is' +this.hange));
    }
    
    handleMessage(message) {
        this.isLoading = true;
        this.receivedMessage = message ? JSON.stringify(message, null, "\t") : "no message";
        if (message.newUserId) {
           // console.log('message.newUserId in top opp='+message.newUserId);
            this.salesRep = message.newUserId;
            fethcOpportunityWrapper({stageName : this.stageName, selectedUserId : message.newUserId}).then((data) => {

                data = JSON.parse(JSON.stringify(data));
                console.log(' top opp data for =' +data);
                this.formateWrapperData(data);
                //navigateToWebPage();   
            });
            
        }
        //this.isLoading = false;
    }
    /*
    @wire(fethcOpportunityWrapper, {stageName : this.stageName}) opportunityWrapperDetails({error, data}) {
        if(data) {
            console.log('response=>'+JSON.stringify(data));
            this.formateWrapperData(data);
        }
        if(error) {
            console.log('Error =>'+error);
        }
            
    } 
    */
    
    formateWrapperData(opportunityWrapperResult){
        console.log('Inside formateWrapperData');
        let baseUrl = 'https://'+location.host+'/';
        //window.open(url, "_blank");
        this.TobBidOppList = opportunityWrapperResult.map((elem) => ({
            
            ...{
                'OpportunityUrl' : baseUrl + elem.opportunity.Id,
                'Opportunity_Number__c' : elem.opportunity.Opportunity_Number__c,
                'OpportunityName' : elem.opportunity.Name,
                'Owner' : elem.opportunity.Owner.Name,
                'SEMargin' : elem.margin,
                'SERevenue' : elem.revenue,
                'Total_Project_Margin__c' : elem.opportunity.Total_Project_Margin__c,
                'TotalRevenue' :  elem.opportunity.Total_Base_Bid_Total_Quote__c,
                'CloseDate' : elem.opportunity.CloseDate,
                'Ship_Date__c' : elem.opportunity.Ship_Date__c,
                'Probability' : elem.opportunity.Probability,
                'Bidders': elem.opportunity.Bidders__c,
                'Description':elem.opportunity.Description,
                'lastChatterAction': elem.lastChatterAction
            }
        })); 
        this.isLoading = false;
       //console.log('TobBidOppList='+JSON.stringify(this.TobBidOppList));    
    } 
    //Onclick on title open topOpportunitiesByStageName
    navigateToWebPage() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/TopOpportunitiesByStageName?stageName=' +this.stageName+'&selectSalesRep='+this.salesRep
                
            }
        }).then(vfURL => {
        window.open(vfURL);
        });
        //console.log(' url stage name' +this.stageName + 'slectedSalesRep' +this.salesRep)
    }
}