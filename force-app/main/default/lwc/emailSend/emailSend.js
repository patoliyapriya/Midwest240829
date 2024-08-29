import { LightningElement, api, wire, track } from 'lwc';
import SendEmail from'@salesforce/apex/EmailSendController.sendMailMethod';
import sendMail from'@salesforce/apex/EmailSendController.sendMail';
import getPreviewURLForProject from'@salesforce/apex/EmailSendController.getPreviewURLForProject';
import getemailWrapper from'@salesforce/apex/EmailSendController.prepareEmailData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class EmailSendController extends LightningElement {
    @api recordId;
    @track sendEmailErrorMessage;
    //@track emailWrapperTrk;
    @track newEmailWrapper;
    @track emailWrapperInoutData;
    @track ToContactIds = [];
    @track fromAddressIdTrack;
    //@track PreviewURLForProject= 'https://midwest--quoting--c.cs124.content.force.com/email/templaterenderer?id=00X61000000lIp8EAE&related_to_id=a0r3J000000Ri0HQAS&base_href=https%3A%2F%2Fmidwest--Quoting--c.cs124.content.force.com&preview_frame=contentFrame&render_type=REPLACED_HTML_BODY';

    //@wire(getPreviewURLForProject, {projectId:'$recordId'}) PreviewURLForProject;
    @wire(getemailWrapper, {projectId:'$recordId'}) emailWrapperTrk({error, data}) {
        if(data) {
            
            console.log('emailWrapper=>'+JSON.stringify(data));
            this.newEmailWrapper = data;
            this.emailWrapperInoutData = Object.assign({}, this.newEmailWrapper[0]);
            console.log('emailWrapperInoutData=>'+JSON.stringify(this.emailWrapperInoutData));
        }
        if(error)
            console.log(error);
    }
    get options() {
        //this.fromAddressIdTrack =  this.emailWrapperInoutData.orgWideFromAddressId;
        console.log('from=>'+this.emailWrapperInoutData.fromAddress);
        console.log('from2=>'+this.emailWrapperInoutData.orgWideFromAddress);
        return [
                { label: this.emailWrapperInoutData.fromAddress, value: this.emailWrapperInoutData.fromAddressId },
                { label: this.emailWrapperInoutData.orgWideFromAddress, value: this.emailWrapperInoutData.orgWideFromAddressId },
               ];
    }
    /*
    @wire(getPreviewURLForProject, {projectId:'$recordId'}) PreviewURLForProject({error, data}) {
        if(data) {
            console.log('data of email url=>'+data);
            console.log('data of email url=>'+JSON.stringify(data));
            this.PreviewURLForProject = data;
        }
        if(error)
            console.log(error);
    }*/

    connectedCallback() {
        console.log('inside the connected call back of send email=>'+this.recordId);
        
      }  
      

    
    handleChange(event) {
        const field = event.target.name;
        console.log('field=>'+field);
        console.log('value=>'+event.target.value);
        if (field === 'ccAddress') {
            this.emailWrapperInoutData.ccAddress = event.target.value;
        } else if (field === 'BccAddress') {
            this.emailWrapperInoutData.bccAddress = event.target.value;
        } else if (field === 'Subject') {
            this.emailWrapperInoutData.Subject = event.target.value;
        }  else if (field === 'From') {
            this.fromAddressIdTrack = event.target.value;
        }  
        console.log('this.emailWrapperInoutData='+JSON.stringify(this.emailWrapperInoutData));
    }

    @api SendEmailJS() {
        this.emailWrapperInoutData.contactIdList = this.ToContactIds;
        this.emailWrapperInoutData.projectId = this.recordId;
        this.emailWrapperInoutData.fromAddressId = this.fromAddressIdTrack;
        console.log('this.emailWrapper=>'+JSON.stringify(this.emailWrapperInoutData));
        //const input = this.emailWrapperInoutData;
        
        sendMail( { emailWrapperString: this.emailWrapperInoutData}).then(result => {   
            const toastEvnt = new ShowToastEvent( {
                title: 'Email successfully sent',
                message: 'success',
                variant: 'success'
                });
                this.dispatchEvent (toastEvnt);
        }).catch(error => {
            console.log('inside error='+JSON.stringify(error));
            this.sendEmailErrorMessage= JSON.stringify(error);
            const selectedEvent = new CustomEvent("sendEmailFailed", {
                detail: this.sendEmailErrorMessage
              });
          
              // Dispatches the event.
              this.dispatchEvent(selectedEvent);
            const toastEvnt = new ShowToastEvent( {
                title: this.sendEmailErrorMessage,
                message: 'Error',
                variant: 'error'
                });
                this.dispatchEvent (toastEvnt);

                
            
        });

    }

    @track selectedItemsToDisplay = ''; //to display items in comma-delimited way
    @track values = []; //stores the labels in this array
    @track isItemExists = false; //flag to check if message can be displayed

    //captures the retrieve event propagated from lookup component
    selectItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);        
    }

    //captures the remove event propagated from lookup component
    deleteItemEventHandler(event){
        let args = JSON.parse(JSON.stringify(event.detail.arrItems));
        this.displayItem(args);
    }

    //displays the items in comma-delimited way
    displayItem(args){
        this.values = []; //initialize first
        this.ToContactIds = [];
        args.map(element=>{
            this.ToContactIds.push(element.value);
            this.values.push(element.label);
        });

        this.isItemExists = (args.length>0);
        this.selectedItemsToDisplay = this.values.join(', ');
        
        console.log('selected contact=>'+this.ToContactIds);
    }

    
}