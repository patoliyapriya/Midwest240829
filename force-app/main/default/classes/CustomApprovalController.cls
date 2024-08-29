public with sharing class CustomApprovalController {

    @AuraEnabled(cacheable=true)
    public static ApproverDetailsWrapper getApprovers() {

        ApproverDetailsWrapper objApproverDetailsWrapper = new ApproverDetailsWrapper();

        List<Approver__c> lstApproverRecords = [SELECT Id,
                                                        User__c, 
                                                        ApproverId__c
                                                FROM Approver__c
                                                ORDER BY CreatedDate];

        if (lstApproverRecords.isEmpty()) {
            objApproverDetailsWrapper.lstApprover = new List<ApproverWrapper>();
    
            SubmitterWrapper subWrapper = new SubmitterWrapper();
            subWrapper.recordId = null;
            subWrapper.submitterId = null;
            subWrapper.isAdd = true;
            subWrapper.isDelete = false;

            ApproverWrapper wrapper = new ApproverWrapper();
            wrapper.approverId = null;
            wrapper.lstSubmitter = new List<SubmitterWrapper>();
            wrapper.lstSubmitter.add(subWrapper);

            objApproverDetailsWrapper.lstApprover.add(wrapper);

        } else {

            Map<Id, ApproverWrapper> mapApprover = new Map<Id, ApproverWrapper>();
            for (Approver__c approver : lstApproverRecords) {
                if (!mapApprover.containsKey(approver.ApproverId__c)) {                                 
                    ApproverWrapper wrapper = new ApproverWrapper();
                    wrapper.approverId = approver.ApproverId__c;
                    wrapper.lstSubmitter = new List<SubmitterWrapper>();
                    if (approver.User__c != null) {
                        SubmitterWrapper subWrapper = new SubmitterWrapper();
                        subWrapper.recordId = approver.Id;
                        subWrapper.submitterId = approver.User__c;
                        subWrapper.isAdd = false;
                        subWrapper.isDelete = true;
                        wrapper.lstSubmitter.add(subWrapper);   
                    }else{
                        wrapper.recordId = approver.Id;
                    }
                    mapApprover.put(approver.ApproverId__c, wrapper);
                } else {
                    ApproverWrapper wrapper = mapApprover.get(approver.ApproverId__c);
                    if (approver.User__c != null) {
                        SubmitterWrapper subWrapper = new SubmitterWrapper();
                        subWrapper.recordId = approver.Id;
                        subWrapper.submitterId = approver.User__c;
                        subWrapper.isAdd = false;
                        subWrapper.isDelete = true;
                        wrapper.lstSubmitter.add(subWrapper);
                    } else {
                        wrapper.recordId = approver.Id;
                    }
                    mapApprover.put(approver.ApproverId__c, wrapper);
                }
            }

            objApproverDetailsWrapper.lstApprover = new List<ApproverWrapper>();
            for(Id id : mapApprover.keySet()){
                objApproverDetailsWrapper.lstApprover.add(mapApprover.get(id));
            }

            for (ApproverWrapper objApproverWrapper : objApproverDetailsWrapper.lstApprover) {
                Integer submitterLength = objApproverWrapper.lstSubmitter.size();
                if (submitterLength == 1) {
                    objApproverWrapper.lstSubmitter[0].isAdd = true;
                    objApproverWrapper.lstSubmitter[0].isDelete = false;
                } else {
                    objApproverWrapper.lstSubmitter[submitterLength - 1].isAdd = true;
                    objApproverWrapper.lstSubmitter[submitterLength - 1].isDelete = true;
                }
            }
        }    
        return objApproverDetailsWrapper;   
    }

    @AuraEnabled
    public static ApproverDetailsWrapper saveApproverDetails(String jsonWrapper) {
        ApproverDetailsWrapper approverDetails = (ApproverDetailsWrapper) JSON.deserialize(jsonWrapper, ApproverDetailsWrapper.class);
        List<Approver__c> lstApproverToUpdate = new List<Approver__c>();

        for (ApproverWrapper objApproverWrapper : approverDetails.lstApprover) {
            Approver__c objApprover = new Approver__c();
            objApprover.Id = objApproverWrapper.recordId;
            objApprover.ApproverId__c = objApproverWrapper.approverId;
            lstApproverToUpdate.add(objApprover);

            for (SubmitterWrapper objSubmitterWrapper : objApproverWrapper.lstSubmitter) {
                Approver__c objSubmitter = new Approver__c();
                objSubmitter.ApproverId__c = objApproverWrapper.approverId;
                objSubmitter.Id = objSubmitterWrapper.recordId;
                objSubmitter.User__c = objSubmitterWrapper.submitterId;
                lstApproverToUpdate.add(objSubmitter);
            }
        }

        if (!lstApproverToUpdate.isEmpty()) {
            upsert lstApproverToUpdate;
        }

        return getApprovers();
    }
    
    @AuraEnabled
    public static ApproverDetailsWrapper deleteSubmitter(Id recordId) {
        delete [SELECT Id FROM Approver__c WHERE ID = :recordId];
        return getApprovers();
    }

    @AuraEnabled
    public static ApproverDetailsWrapper deleteApprover(Id recordId) {
        delete [SELECT Id FROM Approver__c WHERE ApproverId__c = :recordId];
        return getApprovers();
    }

    public class ApproverDetailsWrapper {
        @AuraEnabled public List<ApproverWrapper> lstApprover {get;set;}
    }

    public class ApproverWrapper {
        @AuraEnabled public ID approverId {get;set;}
        @AuraEnabled public ID recordId {get;set;}
        @AuraEnabled public List<SubmitterWrapper> lstSubmitter {get;set;}
    }

    public class SubmitterWrapper {
        @AuraEnabled public ID recordId {get;set;}
        @AuraEnabled public ID submitterId {get;set;}
        @AuraEnabled public Boolean isAdd {get;set;}
        @AuraEnabled public Boolean isDelete {get;set;}
    }
}