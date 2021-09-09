/****************************************************************
* @author: Anukriti 
* @date: 20-01-2020
* @User Story: U-1578
* @description: This class is a handler class for SalesDecisionMakerTrigger 
*****************************************************************/
public without sharing class SalesDecisionMakerHandler {
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will handle before insert operation 
*****************************************************************/
    public static void onBeforeInsert(List<Sales_Decision_Maker__c> newSDMList) {
        SalesDecisonMakerHelper.restrictDuplicateApprover(newSDMList,null,true); 
    }
    
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will handle before update operation 
*****************************************************************/
    public static void onBeforeUpdate(List<Sales_Decision_Maker__c> newSDMList, List<Sales_Decision_Maker__c> oldSDMList, 
                                      Map<ID, Sales_Decision_Maker__c> newSDMMap , Map<ID, Sales_Decision_Maker__c> oldSDMMap) 
    {
        SalesDecisonMakerHelper.restrictDuplicateApprover(newSDMList,oldSDMMap,false);           
    }
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will handle before delete operation 
*****************************************************************/
    public static void onBeforeDelete(List<Sales_Decision_Maker__c> oldSDMList) {
        SalesDecisonMakerHelper.restrictDeletionOfAutoSDM(oldSDMList);            
    }
    
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will handle after delete operation 
*****************************************************************/
    public static void onAfterDelete(List<Sales_Decision_Maker__c> oldSDMList) {
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Sales_Decision_Maker__c sdm : oldSDMList){
            oppSetID.add(sdm.Opportunity_Id__c); 
        }
        if(!oppSetID.isEmpty()) {
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
        }
    }
    
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will handle after update operation 
*****************************************************************/
    public static void onAfterUpdate(List<Sales_Decision_Maker__c> newSDMList, List<Sales_Decision_Maker__c> oldSDMList, 
                                     Map<ID, Sales_Decision_Maker__c> newSDMMap , Map<ID, Sales_Decision_Maker__c> oldSDMMap )
    {
        //SalesDecisonMakerHelper.reCalculateReadySDR(newSDMList, oldSDMMap);
        SalesDecisonMakerHelper.updateSalesDecisionApprovalStatus(newSDMList, oldSDMMap);
        SalesDecisonMakerHelper.updateSDRAllConditionsNotes(newSDMList, oldSDMMap);
        
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Sales_Decision_Maker__c sdm : newSDMList){
            oppSetID.add(sdm.Opportunity_Id__c); 
        }
        if(!oppSetID.isEmpty()) {
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
        }
    }
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will handle after insert operation 
*****************************************************************/
    public static void onAfterInsert(List<Sales_Decision_Maker__c> newSDMList, List<Sales_Decision_Maker__c> oldSDMList, 
                                     Map<ID, Sales_Decision_Maker__c> newSDMMap , Map<ID, Sales_Decision_Maker__c> oldSDMMap) 
    {
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Sales_Decision_Maker__c sdm : newSDMList){
            oppSetID.add(sdm.Opportunity_Id__c); 
        }
        if(!oppSetID.isEmpty()) {
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
        }       
    }
}