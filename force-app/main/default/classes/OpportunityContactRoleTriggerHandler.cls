/******************************************************************* 
* @author: Ankit Jain
* @date: 2021-01-19
* @description: This class is a handler class for OpportunityContactRole Trigger (U-1839)
********************************************************************/
public class OpportunityContactRoleTriggerHandler {
     /******************************************************************* 
* @author: Ankit Jain
* @date: 2021-01-19 
* @description: This method will be called after insertion from OpportunityContactRole Trigger (U-1839)
********************************************************************/
    public static void OnAfterInsert(List<OpportunityContactRole> newOpportunityContactRoles){
        OpportunityContactRoleTriggerHelper.updateCampaignIdtoOpportunity(newOpportunityContactRoles);
    }
}