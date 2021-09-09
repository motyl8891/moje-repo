/****************************************************************
* @author:  
* @date: 
* @User Story: 
* @description: This class is a handler class for SalesTeamTrigger 
*****************************************************************/
public without sharing class SalesTeamTriggerHandler {
    
    /****************************************************************
* @author:  
* @date: 
* @User Story: 
* @description: This method will handle before insert operation 
*****************************************************************/
    Public void onBeforeInsert(List<Opportunity_Sales_Team__c> newOpportunity_Sales_Team)
    {
        SalesTeamTriggerHelper.setPrimaryFlagBeforeInsert(newOpportunity_Sales_Team);
    }
    
    /****************************************************************
* @author:  
* @date: 
* @User Story: 
* @description: This method will handle after insert operation 
*****************************************************************/
    Public void onAfterInsert(List<Opportunity_Sales_Team__c> newOpportunity_Sales_Team)
    {
        SalesTeamTriggerHelper.onInsertUpdatePrimary(newOpportunity_Sales_Team);
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Opportunity_Sales_Team__c ost : newOpportunity_Sales_Team) {
            oppSetID.add(ost.Opportunity__c); 
        }
        if(!oppSetID.isEmpty()) { 
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID); 
        }
    }
    
    /****************************************************************
* @author:  
* @date: 
* @User Story: 
* @description: This method will handle before update operation 
*****************************************************************/
    Public void onBeforeUpdate(List<Opportunity_Sales_Team__c> newOSTList, Map<ID, Opportunity_Sales_Team__c> oldOSTMap)
    {
        SalesTeamTriggerHelper.onUpdatePrimary(newOSTList, oldOSTMap);            
    }
    
    /****************************************************************
* @author:  
* @date: 
* @User Story: 
* @description: This method will handle after update operation 
*****************************************************************/
    Public void onAfterUpdate(List<Opportunity_Sales_Team__c> newOSTList, Map<ID, Opportunity_Sales_Team__c> oldOSTMap)
    {
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Opportunity_Sales_Team__c ost : newOSTList) {
            oppSetID.add(ost.Opportunity__c); 
        }
        if(!oppSetID.isEmpty()) { 
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID); 
        }
    }
    
    /****************************************************************
* @author:  
* @date: 
* @User Story: 
* @description: This method will handle after delete operation 
*****************************************************************/
    Public void onAfterDelete(List<Opportunity_Sales_Team__c> oldOSTList)
    {
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Opportunity_Sales_Team__c ost : oldOSTList) {
            oppSetID.add(ost.Opportunity__c); 
        }
        if(!oppSetID.isEmpty()) { 
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID); 
        }
    }
}