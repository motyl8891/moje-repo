public class OpportunityLwcController {
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getOpps(string searchKey){
        Secondary_Approval__c sa=[select id,Opportunity__c from Secondary_Approval__c where id=:searchKey];
        Opportunity opp=[SELECT Id, Trade_Classifications__c,AdditionalInformation__c,Purpose__c,toLabel(UseCase__c),Primary_Proposal__r.Name,Primary_Proposal__r.Proposal_Id__c,Primary_Proposal__r.Version__c,OpportunityNumber__c FROM Opportunity WHERE id = :sa.Opportunity__c];
        Map<String,String> oppFields=new Map<String,String>();
        oppFields.put('Opportunity Number:', opp.OpportunityNumber__c!=null?opp.OpportunityNumber__c:'');
        oppFields.put('Additional Information:', opp.AdditionalInformation__c!=null?opp.AdditionalInformation__c:'');
        oppFields.put('Use Cases:', opp.UseCase__c!=null?opp.UseCase__c:'');
        oppFields.put('Purposes:', opp.Purpose__c!=null?opp.Purpose__c:'');
        oppFields.put('Trade Classification:', opp.Trade_Classifications__c!=null?opp.Trade_Classifications__c:'');
        oppFields.put('Proposal Name:', opp.Primary_Proposal__r.Name!=null?opp.Primary_Proposal__r.Name:'');
        oppFields.put('Proposal ID:', opp.Primary_Proposal__r.Proposal_Id__c!=null?opp.Primary_Proposal__r.Proposal_Id__c:'');
        oppFields.put('Proposal Version:', opp.Primary_Proposal__r.Version__c!=null?opp.Primary_Proposal__r.Version__c:'');
        return oppFields;
    }
     /****************************************************************
* @author: Shubham Jagatap
* @date: 10-12-2020
* @User Story: U-2389
* @description: Used in LWC component "SecApp_AcceptOrEscalate"
*****************************************************************/   
     @AuraEnabled
    public static void UpdateSecondaryApproval(String SecApprovalId, String EscalationComments, Boolean isAccepted)
    {	Secondary_Approval__c SARecord = [SELECT Id,EscalationComments__c,Approval_Rejection_Reason__c from Secondary_Approval__c where Id=:SecApprovalId LIMIT 1];
     	
        try{
            if(isAccepted==true){
                SARecord.Approval_Status__c = GlobalConstants.COMPLETED;
                if(SARecord.Approval_Rejection_Reason__c == GlobalConstants.APPROVED){
                    SARecord.Approval_Rejection_Reason__c = GlobalConstants.ACCEPTED_APPROVAL;
                }
                else if(SARecord.Approval_Rejection_Reason__c == GlobalConstants.Approvedwithcondition){
                    SARecord.Approval_Rejection_Reason__c = GlobalConstants.AcceptedApprovalwithconditions;
                }
                else if(SARecord.Approval_Rejection_Reason__c == GlobalConstants.DismissedbySBteam){
                    SARecord.Approval_Rejection_Reason__c = GlobalConstants.AcceptedDismissal;
                }
                update SARecord;
            }
            else if(isAccepted==false){
                SARecord.Approval_Status__c = GlobalConstants.Pending;
                SARecord.EscalationComments__c = EscalationComments;
                SARecord.Approval_Rejection_Reason__c = GlobalConstants.Submittedformanualapproval;
                update SARecord;
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.OpportunityLwcController, 
                                                  GlobalConstants.UpdateSecondaryApproval, GlobalConstants.OpportunityLwcController, true, e));
        }
    }
}