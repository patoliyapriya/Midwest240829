import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import getOpportunity from '@salesforce/apex/NewQuote.getOpportunity';
import insertQuote from '@salesforce/apex/NewQuote.insertQuote';
import updateQuote from '@salesforce/apex/NewQuote.updateQuote';
import deleteQuote from '@salesforce/apex/NewQuote.deleteQuote';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const protocol = window.location.href ;

var urlObj = new URL(protocol);
var queryParams = new URLSearchParams(urlObj.search);
var oppId = queryParams.get("oppId");

export default class NewQuote extends NavigationMixin(LightningElement) {

    @api recordId;

    @track opp;
    @track qut;
    @track displayQuoteName;
    @track error;
    @track isContinue = false;
    @track quoteId = '';
    @track OppQuoteDetails = {};
    @track updateQuoteName = '';
    @track hasSplitEngineer;
    @track isMaRRsOpportunity;
    @track hasApplicationEngineer;
    @track shouldRender;
    @track shouldNotRenderMarrs;
    @track shouldNotRender;

    connectedCallback() {
        this.recordId = oppId;

        getOpportunity({ oppId: this.recordId })
            .then(result => {
                this.opp = result;
                this.error = undefined;
                this.hasSplitEngineer = this.opp.isSplitEngineer;
                if(this.opp.opportunityRecordtypeName == 'MaRRS') {
                    this.isMaRRsOpportunity = true;
                } else {
                    this.isMaRRsOpportunity = false;
                }

                if(this.opp.opportunityRecordtypeName == 'Equipment' && this.opp.opportunityApplicationEngineer == null) {
                    this.hasApplicationEngineer = false;
                } else {
                    this.hasApplicationEngineer = true;
                }

                this.shouldRender = ((this.hasSplitEngineer && this.hasApplicationEngineer) || this.isMaRRsOpportunity);
                this.shouldNotRenderMarrs = (!this.isMaRRsOpportunity);
                this.shouldNotRender = (!this.hasSplitEngineer || !this.hasApplicationEngineer);
            })
            .catch(error => {
                this.error = error;
                this.opp = undefined;
                console.error("Error retrieving Opportunity: ", error);
            });
    }
    
    get hasOpportunity() {
        return this.opp !== undefined;
    }

    handlechange(event) {
        const field = event.target.dataset.id;
        if (field === 'quoteDate') {
            this.OppQuoteDetails.quoteDate = event.target.value;
        } else if (field === 'quoteBiddingToC') {
            this.OppQuoteDetails.quoteBiddingToC = event.target.value;
        } else if (field === 'quoteSubmittedByC') {
            this.OppQuoteDetails.quoteSubmittedByC = event.target.value;
        } else if (field === 'quotePreparedByUser') {
            this.OppQuoteDetails.quotePreparedByUser = event.target.value;
        } else if (field === 'updateQuoteName') {
            this.updateQuoteName = event.target.value;
        }
    }

    async handleContinue() {
        const now = new Date();
        const formattedDate = now.toLocaleString();
        this.OppQuoteDetails.quoteName = this.opp.opportunityNumber + ' - ' + this.opp.opportunityName + ' - ' + formattedDate;
        this.OppQuoteDetails.qutRecordTypeName = this.opp.opportunityRecordtypeName + ' Quote';
        this.OppQuoteDetails.qutGeneralContractor = this.opp.opportunityGeneralContractor;
        this.OppQuoteDetails.qutConsultingEngineer = this.opp.opportunityConsultingEngineer;
        this.OppQuoteDetails.qutaAttentionToAccount = this.opp.opportunityAccountId;
        this.OppQuoteDetails.oppId = this.opp.opportunityId;
        this.OppQuoteDetails.ShippingName = this.opp.opportunityShippingName;
        this.OppQuoteDetails.SyncOppAddress = this.opp.opportunitySyncQuote;

        await insertQuote({ jsonWrapper: JSON.stringify(this.OppQuoteDetails) })
                        .then(result => {
                            this.qut = result;
                            this.error = undefined;
                            this.displayQuoteName = this.opp.opportunityNumber + '.' + this.qut.QuoteNumber + ' ' + this.opp.opportunityName;
                            this.updateQuoteName = this.displayQuoteName;
                        })
                        .catch(error => {
                            this.error = error;
                            this.opp = undefined;
                            console.error("Error retrieving Opportunity: ", error);
                        });
        this.isContinue = true;
    }

    handleSave() {
        updateQuote({ qutName: this.displayQuoteName, updatedQutName: this.updateQuoteName, quoteId: this.qut.Id})
            .then(() => {
                window.location.replace('/' + this.qut.Id);
                this.clearFields();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            }
        );
    }

    handleCancel() {
        if (this.qut != null && this.qut.Id != null) {
            deleteQuote({ quoteId: this.qut.Id })
            .then(() => {
                window.location.replace('/' + this.opp.opportunityId);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
        else {
            window.location.replace('/' + this.opp.opportunityId);
        }
        
    }

    clearFields() {
        this.quoteName = '';
    }

    hideModalBox() {  
        this.isContinue = false;
    }

}