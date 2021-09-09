public class FrameOpportunitySummaryController {

    @AuraEnabled
    public static Opportunity getOpportunityDetails(Id recordId){
        
        Opportunity opp = [SELECT Id,
                           RecordTypeId,
                           Overall_Score__c,
                           Risk_Score__c,
                           Winnability_Scores__c,
                           Deliverability_Score__c
                           FROM Opportunity Where Id =: recordId];
        return opp;
    }
}