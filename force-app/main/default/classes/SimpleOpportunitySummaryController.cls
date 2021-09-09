public class SimpleOpportunitySummaryController {
    
     @AuraEnabled
    public static Opportunity getOpportunityDetails(Id recordId){
        Opportunity opp = [SELECT Id,
                           RecordTypeId
                           FROM Opportunity Where Id =: recordId];
        return opp;
    }

}