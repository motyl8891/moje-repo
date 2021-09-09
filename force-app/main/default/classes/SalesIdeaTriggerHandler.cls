/****************************************************************
* @author: Shubham Kadam  
* @date: 07/07/2020
* @User Story: U-1989
* @description: This class will handle SalesIdeaTrigger
*****************************************************************/
public without sharing class SalesIdeaTriggerHandler {
    /****************************************************************
* @author: Shubham Kadam  
* @date: 07/07/2020
* @User Story: U-1989
* @description: This method will be called from SalesIdeaTrigger on before insert
*****************************************************************/
    public static void OnBeforeInsert(List<SDOD_Lead__c> newSalesIdea){
        SalesIdeaTriggerHelper.updateOpportunityOnSalesIdea(newSalesIdea, null);
        SalesIdeaTriggerHelper.setSalesIdeaOwner(newSalesIdea, null);
    }
    
    /****************************************************************
* @author: Shubham Kadam  
* @date: 07/07/2020
* @User Story: U-1989 
* @description: This method will be called from SalesIdeaTrigger on before update
*****************************************************************/
    public static void OnBeforeUpdate(List<SDOD_Lead__c> newSalesIdea, List<SDOD_Lead__c> oldSalesIdea, Map<ID, SDOD_Lead__c> newSalesIdeaMap,
                                      Map<ID, SDOD_Lead__c> oldSalesIdeaMap){
                                          SalesIdeaTriggerHelper.setSalesIdeaOwner(newSalesIdea, oldSalesIdeaMap);
                                          SalesIdeaTriggerHelper.updateOpportunityOnSalesIdea(newSalesIdea, oldSalesIdeaMap);
                                      } 
    
}