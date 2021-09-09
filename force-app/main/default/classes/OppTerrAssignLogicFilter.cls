/*******************************************************************
* @author: Igors Kreknins
* @date: 2018-06-27
* @description: This is a class for Opportunity Territory Assignment
********************************************************************/
global class OppTerrAssignLogicFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter {

    global OppTerrAssignLogicFilter() {}

    List<Opportunity> updatedOpportunities = new List<Opportunity>();

    /****************************************************************
    * @author: Igors Kreknins
    * @date: 2018-06-27
    * @param: opportunityIds
    * @return: OppIdTerritoryIdResult
    * @description: Get mapping of opportunity to territory2Id
    *****************************************************************/
    public Map<Id, Id> getOpportunityTerritory2Assignments(List<Id> opportunityIds) {

        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();

        // Get the active territory model Id
        Id activeModelId = getActiveModelId();

        if (activeModelId != null) {
            List<Opportunity> opportunities = [SELECT Id, AccountId, Territory2Id, Restricted_Opportunity__c, Global_Frame__c
                                               FROM Opportunity
                                               WHERE Id IN :opportunityIds];

            OppIdTerritoryIdResult = assignOpptyTerritory(opportunities, activeModelId);
             for (Opportunity newOppty : opportunities ) {
              newOppty.Territory2Id = OppIdTerritoryIdResult.get(newOppty.Id);
           }
        }

        return OppIdTerritoryIdResult;
        
    }
    
    /**
     * Method that find Territory for certain List of Opportunities
     * @param  opportunities Opportunity Map
     * @return               Map with key Opportunity Id and value Terrirtory Id
     */
    global Map<Id, Id> getUpdatedOpportunityTerritory(List<Opportunity> opportunities) {
        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();
        // Get the active territory model Id
        Id activeModelId = getActiveModelId();

        if (activeModelId != null) {
            OppIdTerritoryIdResult = assignOpptyTerritory(opportunities, activeModelId);
        }
        return OppIdTerritoryIdResult;
    }
    
    /**
     * Method that assigns correct Territory to Opportunity
     * @param  opportunities List of Opportunitys
     * @param  activeModelId Terrirtory Model State
     * @return               Map with key Opportunity Id and value Terrirtory Id
     */
    private Map<Id, Id> assignOpptyTerritory(List<Opportunity> opportunities, Id activeModelId) {

        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : opportunities) {
            // Create set of parent accountIds
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();
        Map<Id, Territory2Priority> accountMaxPriorityTerritory = getAccountMaxPriorityTerritory(activeModelId, accountIds);
        Map<Id, Territory2Priority> accountMinPriorityTerritory = getAccountMinPriorityTerritory(activeModelId, accountIds);

        for (Opportunity opp : opportunities) {
            Territory2Priority tp = new Territory2Priority();
            // If Opportunity = Restricted, then do not assign a territory
            if (opp.Restricted_Opportunity__c == true) {
                OppIdTerritoryIdResult.put(opp.Id, null);
            } else {
                // ELSE, if Opportunity.GlobalFrame = True, then assign to the highest priority territory (Global Customer Unit - Local)
               /* if (opp.Global_Frame__c == true) {
                   // tp = accountMaxPriorityTerritory.get(opp.AccountId);
                    // Assign highest priority territory if there is only 1.
                    if((tp != null) && (tp.moreTerritoriesAtPriority == false)){
                     //   OppIdTerritoryIdResult.put(opp.Id, tp.territory2Id);
                    } else {
                     //   OppIdTerritoryIdResult.put(opp.Id, null);
                    }
                } else {*/
                    // ELSE, assign to the lowest priority territory (Customer Reporting Group)
                    tp = accountMinPriorityTerritory.get(opp.AccountId);
                    // Assign lowest priority territory if there is only 1.
                    if ((tp != null) && (tp.moreTerritoriesAtPriority == false)) {
                        OppIdTerritoryIdResult.put(opp.Id, tp.territory2Id);
                    } else {
                        OppIdTerritoryIdResult.put(opp.Id, null);
                    }
                }
           // }
        }
        return OppIdTerritoryIdResult;
    }


    /****************************************************************
    * @author: Igors Kreknins
    * @date: 2018-08-27
    * @return: activeModelId
    * @description: This method will get Active Model Id from Territory2Model
    *****************************************************************/
    private Id getActiveModelId() {
        List<Territory2Model> models = [SELECT Id FROM Territory2Model WHERE State = :GlobalConstants.Active];
        Id activeModelId = null;
        if (models.size() == 1) {
            activeModelId = models.get(0).Id;
        }
        return activeModelId;
    }


    /****************************************************************
    * @author: Igors Kreknins
    * @date: 2018-08-27
    * @param: activeModelId
    * @param: accountIds
    * @return: accountMaxPriorityTerritory
    * @description: This method will get Active Model Id from Territory2Model
    *****************************************************************/
    private Map<Id, Territory2Priority> getAccountMaxPriorityTerritory(Id activeModelId, Set<Id> accountIds) {
        Map<Id, Territory2Priority> accountMaxPriorityTerritory = new Map<Id, Territory2Priority>();
        for (ObjectTerritory2Association ota : [SELECT ObjectId, Territory2Id, Territory2.Territory2Type.Priority FROM ObjectTerritory2Association WHERE objectId IN :accountIds AND Territory2.Territory2ModelId = :activeModelId]) {
            Territory2Priority tp = accountMaxPriorityTerritory.get(ota.ObjectId);
            if ((tp == null) || (ota.Territory2.Territory2Type.Priority > tp.priority)) {
                // If this is the first territory examined for account or it has greater priority than current highest priority territory, then set this as new highest priority territory.
                tp = new Territory2Priority(ota.Territory2Id, ota.Territory2.Territory2Type.priority, false);
            } else if (ota.Territory2.Territory2Type.priority == tp.priority) {
                // The priority of current highest territory is same as this, so set moreTerritoriesAtPriority to indicate multiple highest priority territories seen so far.
                tp.moreTerritoriesAtPriority = true;
            }
            accountMaxPriorityTerritory.put(ota.ObjectId, tp);
        }
        return accountMaxPriorityTerritory;
    }

    /****************************************************************
    * @author: Igors Kreknins
    * @date: 2018-08-27
    * @param: activeModelId
    * @param: accountIds
    * @return: accountMinPriorityTerritory
    * @description: This method will get Active Model Id from Territory2Model
    *****************************************************************/
    private Map<Id, Territory2Priority> getAccountMinPriorityTerritory(Id activeModelId, Set<Id> accountIds) {
        Map<Id, Territory2Priority> accountMinPriorityTerritory = new Map<Id, Territory2Priority>();
        for (ObjectTerritory2Association ota : [SELECT ObjectId, Territory2Id, Territory2.Territory2Type.Priority FROM ObjectTerritory2Association WHERE objectId IN :accountIds AND Territory2.Territory2ModelId = :activeModelId]) {
            Territory2Priority tp = accountMinPriorityTerritory.get(ota.ObjectId);
            if ((tp == null) || (ota.Territory2.Territory2Type.Priority < tp.priority)) {
                // If this is the first territory examined for account or it has greater priority than current highest priority territory, then set this as new highest priority territory.
                tp = new Territory2Priority(ota.Territory2Id, ota.Territory2.Territory2Type.priority, false);
            } else if (ota.Territory2.Territory2Type.priority == tp.priority) {
                // The priority of current highest territory is same as this, so set moreTerritoriesAtPriority to indicate multiple highest priority territories seen so far.
                tp.moreTerritoriesAtPriority = true;
            }
            accountMinPriorityTerritory.put(ota.ObjectId, tp);
        }
        return accountMinPriorityTerritory;
    }


    /****************************************************************
    * @author: Igors Kreknins
    * @date: 2018-08-27
    * @description: Helper class to help capture territory2Id, its priority,
    * and whether there are more territories with same priority assigned to the account
    *****************************************************************/
    private class Territory2Priority {
        public Id territory2Id { get; set; }
        public Integer priority { get; set; }
        public Boolean moreTerritoriesAtPriority { get; set; }

        private Territory2Priority() {}

        Territory2Priority(Id territory2Id, Integer priority, Boolean moreTerritoriesAtPriority) {
            this.territory2Id = territory2Id;
            this.priority = priority;
            this.moreTerritoriesAtPriority = moreTerritoriesAtPriority;
        }
    }
}