global class RecallSDREmailClass implements Messaging.InboundEmailHandler{
    
    global static Messaging.InboundEmailResult handleInboundEmail(
        Messaging.inboundEmail email,
        Messaging.InboundEnvelope env
    ) {   
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        try{
		    String str=email.plainTextBody;
			String[] str1=str.split('\n');
			List<Sales_Decision_Maker__c> sdmList;
			List<ProcessInstanceWorkItem> approvals; 
            sdmList = [Select Id, Approval_Status__c,Actual_Approver__c,Conditions_Notes__c,Sales_Decision_Record__c,Sales_Decision_Record__r.Sales_Decision_Approval_Status__c from Sales_Decision_Maker__c
                       where Sales_Decision_Record__c = :str1[0] 
                       AND(Sales_Decision_Record__r.Sales_Decision_Approval_Status__c=: GlobalConstants.APPROVALSONGOING 
                           OR Sales_Decision_Record__r.Sales_Decision_Approval_Status__c=: GlobalConstants.In_Progress)
                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            approvals = [SELECT Id, ProcessInstance.TargetObjectId, CreatedById
                         FROM ProcessInstanceWorkitem 
                         WHERE ProcessInstance.TargetObjectId =: sdmList 
                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
             RecallSdmApprovals.recallAllSdmApprovalstwo(sdmList, approvals);
          //  return result;
        }
        catch(Exception e) {
            System.debug('Exception  : '+e);
        }
        return null;
    }
    
}