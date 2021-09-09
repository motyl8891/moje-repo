public class CustomerUnitApproverHelper {
    /**
     * Method that updates Opportunity GCU head and GCU Commercial Head based on GCU object
     * @param  mapGCUApprovers GCU Approver Map
     * @return                 List of Opportunities
     */
    public static List <Opportunity> updateOpptyGCUUsers(Map<Id, GCUApprovers> mapGCUApprovers) {
        Set<String> opptyStages = new Set<String> {
            '4. Negotiate and Close',
            '3. Create Proposal',
            '2. Define Customer Value',
            '1. Qualify Opportunity'
        };

        Map<Id, GCUApprovers> crgGCUApprovers = new Map<Id, GCUApprovers>();
        for (CustomerReportingGroup__c crg : [SELECT Id, GlobalCustomerUnit__c
                                              FROM CustomerReportingGroup__c
                                              WHERE GlobalCustomerUnit__c IN: mapGCUApprovers.keySet()]) {
            crgGCUApprovers.put(crg.Id, mapGCUApprovers.get(crg.GlobalCustomerUnit__c));
        }

        Map<Id, GCUApprovers> accGCUApprovers = new Map<Id, GCUApprovers>();
        for (Account acc : [SELECT Id, CustomerReportingGroup__c
                            FROM Account
                            WHERE CustomerReportingGroup__c IN : crgGCUApprovers.keySet()]) {
            accGCUApprovers.put(acc.Id, crgGCUApprovers.get(acc.CustomerReportingGroup__c));
        }

        List <Opportunity> opptyList = [SELECT Id, AccountId
                                        FROM Opportunity
                                        where StageName IN: opptyStages AND AccountId IN: accGCUApprovers.keySet()];

        for (Opportunity opp : opptyList) {
            opp.GCU_Commercial_Head__c = accGCUApprovers.get(opp.AccountId).GCUCommercialHead;
            opp.GCU_Head__c = accGCUApprovers.get(opp.AccountId).GCUHead;
        }
        return opptyList;
    }
}