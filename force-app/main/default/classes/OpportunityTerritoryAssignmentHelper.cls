/**
 * Opportunity Territory Assignment Helper class for Opportunity Trigger Handler
 */
public without sharing class OpportunityTerritoryAssignmentHelper {

    /**
     * Method that updates Opportunity Territory Assignment based on Global Frame and Restriced Opportunity values
     * @param newOpportunities    Opportunitys what were changed
     * @param oldOpportunitiesMap Opportunity before it was changed
     */
    public static void updateOpptyTerritoryAssignment(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        Try{
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Opportunity newOppty : newOpportunities) {
            Opportunity oldOppty = oldOpportunitiesMap.get(newOppty.Id);
            if (newOppty.Global_Frame__c != oldOppty.Global_Frame__c ||
                    newOppty.Restricted_Opportunity__c != oldOppty.Restricted_Opportunity__c) {
                opportunities.add(newOppty);
            }
        }
        Map<Id, Id> opptyTerritoryMap = new Map<Id, Id>();
        if (opportunities.size() != 0) {
            OppTerrAssignLogicFilter oppTerrAssignLogicFilter = new OppTerrAssignLogicFilter();
            opptyTerritoryMap = oppTerrAssignLogicFilter.getUpdatedOpportunityTerritory(opportunities);
       
        for (Opportunity newOppty : newOpportunities) {
            if (opportunities.contains(newOppty)) {
            newOppty.Territory2Id = opptyTerritoryMap.get(newOppty.Id);
          }
        }
      }
            }catch(Exception e){	}
    }
    
  }