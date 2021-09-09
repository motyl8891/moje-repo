/****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This class will handle SalesDecisionRecordTrigger
*****************************************************************/
public without sharing class SalesDecisionRecordTriggerHandler {
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This method will be called from SalesDecisionRecordTrigger on before insert
*****************************************************************/
    public static void OnBeforeInsert( List<Sales_Decision_Record__c> newSalesDecision){
        SalesDecisionRecordTriggerHelper.updateACR_CSR_CFRBasedOnOpptySalesTeam(newSalesDecision);
        SalesDecisionRecordTriggerHelper.setDataSnapshotFields(newSalesDecision);  
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This method will be called from SalesDecisionRecordTrigger on after insert
*****************************************************************/
    public static void OnAfterInsert( List<Sales_Decision_Record__c> newSalesDecision){
        //SalesDecisionRecordTriggerHelper.createSDApproverRecords(newSalesDecision);
        //U-1366
        SalesDecisionRecordTriggerHelper.createSalesDecisionMakerRecords(newSalesDecision);
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This method will be called from SalesDecisionRecordTrigger on before update
*****************************************************************/
    public static void onBeforeUpdate( List<Sales_Decision_Record__c> newSalesDecision, List<Sales_Decision_Record__c> oldSalesDecision, Map<ID, Sales_Decision_Record__c> newSalesDecisionMap , Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap ){
        SalesDecisionRecordTriggerHelper.SalesDecisionApprovedStatusError(oldSalesDecisionMap,newSalesDecisionMap);
        //U-1271
        SalesDecisionRecordTriggerHelper.checkRecordEditabilityForMELAOppty(oldSalesDecisionMap,newSalesDecisionMap);
        //U-1507
        SalesDecisionRecordTriggerHelper.updateACR_CSR_CFREmail(oldSalesDecisionMap, newSalesDecisionMap); 
        //U-1668
        SalesDecisionRecordTriggerHelper.CheckSDRIsReadyForNextStage(oldSalesDecisionMap,newSalesDecisionMap);
        
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1271
* @description: This method will be called from SalesDecisionRecordTrigger on after update
*****************************************************************/
    public static void onAfterUpdate( List<Sales_Decision_Record__c> newSalesDecision, List<Sales_Decision_Record__c> oldSalesDecision, Map<ID, Sales_Decision_Record__c> newSalesDecisionMap , Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap ){
        //U-1578
        //SalesDecisionRecordTriggerHelper.lockSDROppProposal(newSalesDecision, oldSalesDecisionMap);
        //SalesDecisionRecordTriggerHelper.unlockSDROppProposal(newSalesDecision, oldSalesDecisionMap); 
        SalesDecisionRecordTriggerHelper.updateApprovedSDPStage(oldSalesDecisionMap,newSalesDecisionMap);
    }    
}