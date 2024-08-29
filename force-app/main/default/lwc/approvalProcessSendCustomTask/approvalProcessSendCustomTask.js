import { LightningElement, wire, api, track  } from 'lwc';
import setTaskForSecondApproval from '@salesforce/apex/ApprovalProcSendCustomTaskCtrl.setTaskForSecondApproval';


export default class ApprovalProcessSendCustomTask extends LightningElement {
    @api recordId;
    
    connectedCallback() {
        //To get update id for (processinstanceworkItem id) to send task for final approval

        console.log('inside the connectedCallBack of ApprovalProcessSendCustomTask  =>'+this.recordId);
        setTaskForSecondApproval({recordId: this.recordId})
        .then(result => {}).catch(error => {})

    }
}