public class CustomerReportingGroupApproverHelper
{
    /**
     * Method that updates Opportunity CRG KAM and CRG CU Head based on CRG object
     * @param  mapCRGApprovers CRG Approver Map
     * @return List of Opportunities
     */
    public static List <Opportunity> updateOpptyCRGUsers(Map<Id, CRGApprovers> mapCRGApprovers)
    {
        Set<String> opptyStages = new Set<String>
        {
            GlobalConstants.oppStg4,
            GlobalConstants.oppStg3,
            GlobalConstants.oppStg3,
            GlobalConstants.oppStg3
        };
        
        Map<Id, CRGApprovers> accCRGApprovers = new Map<Id, CRGApprovers>();
        for (Account acc : [SELECT Id, CustomerReportingGroup__c
                            FROM Account
                            WHERE CustomerReportingGroup__c IN: mapCRGApprovers.keySet()])
                            {
                                accCRGApprovers.put(acc.Id, mapCRGApprovers.get(acc.CustomerReportingGroup__c));
                            }
        
        List <Opportunity> opptyList = [SELECT Id, AccountId
                                        FROM Opportunity
                                        WHERE StageName IN: opptyStages AND AccountId IN: accCRGApprovers.keySet()];
                                        
        for (Opportunity opp : opptyList)
        {
            opp.KAM__c = accCRGApprovers.get(opp.AccountId).CRGAccountPrimaryKAM;
            opp.CU_Head__c = accCRGApprovers.get(opp.AccountId).CRGAccountCUHead;
        }
        return opptyList;
    }
}