import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getData from '@salesforce/apex/CustomApprovalController.getApprovers';
import saveApprovers from '@salesforce/apex/CustomApprovalController.saveApproverDetails';
import deleteApprover from '@salesforce/apex/CustomApprovalController.deleteApprover';
import deleteSubmitter from '@salesforce/apex/CustomApprovalController.deleteSubmitter';

export default class customApprovalProcess extends LightningElement {

    @track lstApprover = [];
    @track isLoading = false;
    @track refreshArray = [];


    @wire(getData)
    approverRecordWapper({ data, error }) {
        if (data) {
            this.lstApprover = JSON.parse(JSON.stringify(data.lstApprover));
        }
    }

    addApprover() {
        this.lstApprover.push({
            approverId: null,
            recordId: null,
            lstSubmitter: [{
                recordId: null,
                submitterId: null,
                isDelete: false,
                isAdd: true
            }]
        });
    }

    async removeApprover(event) {
        this.isLoading = true;
        let approverIndexKey = event.target.dataset.index;
        let deletedApproverId = this.lstApprover[approverIndexKey].approverId;

        if (deletedApproverId) {
            let approverData = await deleteApprover({recordId:deletedApproverId});
            if (approverData) {
                this.lstApprover = JSON.parse(JSON.stringify(approverData.lstApprover));
            }
        } else {
            this.lstApprover.splice(approverIndexKey, 1);
        }
        
        const toastEvnt = new ShowToastEvent({
            title: 'Delete',
            message: 'Record deleted successfully.',
            variant: 'success'
        });
        this.dispatchEvent(toastEvnt);
        this.isLoading = false;
    }

    handleChangeApprover(event) {
        let approverId = event.target.value;
        let index = event.target.dataset.index;
        this.lstApprover[index].approverId = approverId;
    }

    addSubmitter(event) {
        let approverIndex = event.target.dataset.approverindex;
        let submitterIndex = event.target.dataset.submitterindex;
        this.lstApprover[approverIndex].lstSubmitter[submitterIndex].isAdd = false;
        this.lstApprover[approverIndex].lstSubmitter[submitterIndex].isDelete = true;
        this.lstApprover[approverIndex].lstSubmitter.push({
            submitterId: null,
            isDelete: true,
            isAdd: true
        });
        //this.lstApprover = [...this.lstApprover];
    }

    async removeSubmitter(event) {
        this.isLoading = true;
        let approverIndex = event.target.dataset.approverindex;
        let submitterIndex = parseInt(event.target.dataset.submitterindex);
        let deletedSubmitterId = this.lstApprover[approverIndex].lstSubmitter[submitterIndex].recordId;
        if (deletedSubmitterId) {
            if (deletedSubmitterId) {
                let approverData = await deleteSubmitter({recordId:deletedSubmitterId});
                if (approverData) {
                    this.lstApprover = JSON.parse(JSON.stringify(approverData.lstApprover));
                }
            }
        } else {
            this.lstApprover[approverIndex].lstSubmitter.splice(submitterIndex, 1);
        }
        
        if (this.lstApprover[approverIndex].lstSubmitter.length == 1) {
            this.lstApprover[approverIndex].lstSubmitter[0].isDelete = false;
            this.lstApprover[approverIndex].lstSubmitter[0].isAdd = true;
        } else if (submitterIndex === this.lstApprover[approverIndex].lstSubmitter.length) {
            this.lstApprover[approverIndex].lstSubmitter[submitterIndex - 1].isDelete = true;
            this.lstApprover[approverIndex].lstSubmitter[submitterIndex - 1].isAdd = true;
        }
        //this.lstApprover = [...this.lstApprover];

        const toastEvnt = new ShowToastEvent({
            title: 'Delete',
            message: 'Record deleted successfully.',
            variant: 'success'
        });
        this.dispatchEvent(toastEvnt);
        this.isLoading = false;
    }

    handleChangeSubmitter(event) {
        let submitterId = event.target.value;
        let approverIndex = event.target.dataset.approverindex;
        let submitterIndex = event.target.dataset.submitterindex;
        this.lstApprover[approverIndex].lstSubmitter[submitterIndex].submitterId = submitterId;
    }

    validateApprovers() {
        let isSuccess = true;
        let setSubmitter = [];
        let setApprover = [];
        this.isLoading = true;
        this.lstApprover.forEach(approver => {

            if (!approver.approverId) {
                const toastEvnt = new ShowToastEvent({
                    title: 'Required Approver',
                    message: 'Please fill approver details.',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvnt);
                this.isLoading = false;
                isSuccess = false;
            }

            if (setApprover.includes(approver.approverId)) {
                const toastEvnt = new ShowToastEvent({
                    title: 'Duplicate Approver',
                    message: 'Please select unique approver',
                    variant: 'error'
                });
                this.dispatchEvent(toastEvnt);
                this.isLoading = false;
                isSuccess = false;
            } else {
                if (approver.approverId) {
                    setApprover.push(approver.approverId);
                }
            }

            approver.lstSubmitter.forEach(submitter => {

                if (!submitter.submitterId) {
                    const toastEvnt = new ShowToastEvent({
                        title: 'Required submitter',
                        message: 'Please fill submitter details.',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvnt);
                    this.isLoading = false;
                    isSuccess = false;
                }

                if (setSubmitter.includes(submitter.submitterId)) {
                    const toastEvnt = new ShowToastEvent({
                        title: 'Duplicate Submitter',
                        message: 'Please select unique approver for each submitter.',
                        variant: 'error'
                    });
                    this.dispatchEvent(toastEvnt);
                    this.isLoading = false;
                    isSuccess = false;
                } else {
                    if (submitter.submitterId) {
                        setSubmitter.push(submitter.submitterId);
                    }
                }
            })
        })
        return isSuccess;
    }

    async saveApprover(event) {
        this.isLoading = true;
        let approverDetails = { lstApprover: [], lstApproverToDelete: [] };
        approverDetails.lstApprover = this.lstApprover;

        if (this.validateApprovers()) {
            
            let approverData = await saveApprovers({jsonWrapper: JSON.stringify(approverDetails)});
            if (approverData) {
                this.lstApprover = JSON.parse(JSON.stringify(approverData.lstApprover));
            }
            
            const toastEvnt = new ShowToastEvent({
                title: 'Approver Records updated.',
                message: 'Success',
                variant: 'Success'
            });
            this.dispatchEvent(toastEvnt);
        }

        this.isLoading = false;
        
    }
}