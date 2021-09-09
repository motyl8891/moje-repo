/****************************************************************
* @author: Shubham Kadam  
* @date: 07/07/2020
* @User Story: U-1989
* @description: This class is a helper class for SalesIdeaTriggerHandler

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
Shubham Kadam			08-07-2020				Initial Version
				
*****************************************************************/
public without sharing class SalesIdeaTriggerHelper {
    
    /****************************************************************
	* @author: Shubham Kadam  
	* @date: 07/07/2020
	* @User Story: U-1989
	* @param: newSalesIdea
	* @description: This method will set the Sales Idea Owner
	****************************************************************/
    public static void setSalesIdeaOwner(List<SDOD_Lead__c> newSalesIdea, Map<Id, SDOD_Lead__c> oldSalesIdeaMap){
        try {
			for(SDOD_Lead__c si: newSalesIdea) {
				String recordTypeName = Schema.SObjectType.SDOD_Lead__c.getRecordTypeInfosById().get(si.recordtypeid).getname();
				if(trigger.isInsert) {
					if(recordTypeName.equalsIgnoreCase(GlobalConstants.AoS) && si.EA__c != null) {
                        si.OwnerId = si.EA__c; }
                    else if(si.LHR__c != null) {
                        si.OwnerId = si.LHR__c; }
				}
				if(trigger.isUpdate) {                    
                    if(recordTypeName.equalsIgnoreCase(GlobalConstants.AoS) && si.EA__c != null) {
                        si.OwnerId = si.EA__c; }
                    else if(si.LHR__c != null && si.LHR__c != oldSalesIdeaMap.get(si.Id).LHR__c) {
                        si.OwnerId = si.LHR__c; }
				}
			}
        } catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesIdeaTriggerHelper, GlobalConstants.setSalesIdeaOwner, 
                                                                       GlobalConstants.SalesIdeaTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
	* @author: Shubham Kadam  
	* @date: 07/07/2020
	* @User Story: U-1989
	* @param: newSalesIdea, oldSalesIdeaMap 
	* @description: This method will set the Opportunity Id in Sales Idea
	****************************************************************/    
   public static void updateOpportunityOnSalesIdea(List<SDOD_Lead__c> newSalesIdea, Map<Id, SDOD_Lead__c> oldSalesIdeaMap){
        try {
			for(SDOD_Lead__c si: newSalesIdea) {
				if(si.Opportunity_ID__c != null && ((trigger.isInsert) || 
				(trigger.isUpdate && si.Opportunity_ID__c != oldSalesIdeaMap.get(si.Id).Opportunity_ID__c))) {
						Opportunity opp = [select Id,Name,OpportunityNumber__c from Opportunity 
											where OpportunityNumber__c =: si.Opportunity_ID__c LIMIT 1];
						si.Opportunity__c = opp	.Id;
				}
                else if(si.Opportunity_ID__c == null) {
                    si.Opportunity__c = null; }
			}
        } catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesIdeaTriggerHelper, GlobalConstants.updateOpportunityOnSalesIdea, 
                                                                       GlobalConstants.SalesIdeaTriggerHelper, true, e)));
        }
    }
}