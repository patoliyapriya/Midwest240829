import { LightningElement, track, wire,api} from 'lwc';
import getApprovalComments from "@salesforce/apex/ApprovalRequestPagectrl.getApprovalComments";

export default class ApprovalComments extends LightningElement {
    
    @api recordId;
    @track submitterName;
    @track submitterComment;
    @track submittedDate;
    @track submitterUrl;
    @track submitterAvtar;

    @track approverName;
    @track approverComment;
    @track approvedDate;
    @track approverUrl;
    @track approverAvtar;

    @wire(getApprovalComments, { recordId: "$recordId" })
    wiredGetApprovalist(value) {
        let approvalHistory;
        if (value.data) {
            console.log('final result :- '+JSON.stringify(value.data));
            approvalHistory = value.data;

            for (var i = 0; i < approvalHistory.length; i++) {   
                if(approvalHistory[i].status == 'Started'){
                    this.submitterName = approvalHistory[i].userName;
                    this.submitterComment = approvalHistory[i].userComment;
                    this.submittedDate = approvalHistory[i].createdDate;
                    this.submitterAvtar = approvalHistory[i].avtar;
                    this.submitterUrl = '/lightning/r/User/' +approvalHistory[i].userId +'/view'
                } else if (approvalHistory[i].status == 'Approved'){
                    this.approverName = approvalHistory[i].userName;
                    this.approverComment = approvalHistory[i].userComment;
                    this.approvedDate = approvalHistory[i].createdDate;
                    this.approverAvtar = approvalHistory[i].avtar;
                    this.approverUrl = '/lightning/r/User/' +approvalHistory[i].userId +'/view'
                }
            }
            
        } else if (value.error) {
            displayToastErrorQuery(this, ShowToastEvent);
        }
    }
}