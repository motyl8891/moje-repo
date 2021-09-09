/****************************************************************
* @author: Ankita Mahobia
* @date: 24-03-2020
* @User Story: 1694
* @description: This class is a handler class for  SecondaryApprovalTrigger

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
Ankita Mahobia			24-03-2020				Initial Version
Shubham Kadam			08-07-2020				U-1889 - onAfterInsert, onAfterUpdate Methods added
*****************************************************************/
public without sharing class SecondaryApprovalTriggerHandler 
{
    /****************************************************************
* @author: Ankita Mahobia
* @date: 24-03-2020
* @User Story: 1694
* @description: This method will be called from SecondaryApprovalTrigger on before insert
*****************************************************************/
    public void onBeforeInsert(List<Secondary_Approval__c> newSecondaryApproval)
    {
        SecondaryApprovalTriggerHelper.calculatePurposeRisk(newSecondaryApproval,null);
        SecondaryApprovalTriggerHelper.setOppDescriptionFromOpportunity(newSecondaryApproval);
        SecondaryApprovalTriggerHelper.restrictCreationOfSecondaryApproval(newSecondaryApproval);
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 08-07-2020
* @User Story: U-1889
* @description: This method will be called from SecondaryApprovalTrigger on after insert
*****************************************************************/
    public void onAfterInsert(List<Secondary_Approval__c> newSecondaryApproval)
    {
        SecondaryApprovalTriggerHelper.updatePreSalesAdjustmentStatus(newSecondaryApproval);
        SecondaryApprovalTriggerHelper.UpdateOpportunitySalesComplianceStatus(newSecondaryApproval);
        SecondaryApprovalTriggerHelper.UpdateOpportunityTradeComplianceStatus(newSecondaryApproval, null); 
        SecondaryApprovalTriggerHelper.updateActiveSensitiveBusinessApprovalOnOpp(newSecondaryApproval);
    }
    
    /****************************************************************
* @author: Ankita Mahobia
* @date: 24-03-2020
* @User Story: 1694
* @description: This method will be called from SecondaryApprovalTrigger on before update
*****************************************************************/
    public void onBeforeUpdate(List<Secondary_Approval__c> newSecondaryApproval, List<Secondary_Approval__c> oldSecondaryApproval,
                               Map<ID, Secondary_Approval__c> newSecondaryApprovalMap, Map<ID, Secondary_Approval__c> oldSecondaryApprovalMap)
    {
        SecondaryApprovalTriggerHelper.calculatePurposeRisk(newSecondaryApproval,oldSecondaryApprovalMap);
        SecondaryApprovalTriggerHelper.updateisActiveFlag(newSecondaryApproval,oldSecondaryApprovalMap,newSecondaryApprovalMap);
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 08-07-2020
* @User Story: U-1889
* @description: This method will be called from SecondaryApprovalTrigger on after update
*****************************************************************/
    public void onAfterUpdate(List<Secondary_Approval__c> newSecondaryApproval, List<Secondary_Approval__c> oldSecondaryApproval,
                              Map<ID, Secondary_Approval__c> newSecondaryApprovalMap, Map<ID, Secondary_Approval__c> oldSecondaryApprovalMap)
    {
        SecondaryApprovalTriggerHelper.updatePreSalesAdjustmentStatus(newSecondaryApproval);
        SecondaryApprovalTriggerHelper.UpdateOpportunitySalesComplianceStatus(newSecondaryApproval);
        SecondaryApprovalTriggerHelper.UpdateOpportunityTradeComplianceStatus(newSecondaryApproval, oldSecondaryApprovalMap);
        SecondaryApprovalTriggerHelper.clearActiveSensitiveBusinessApprovalOnOpp(newSecondaryApproval, oldSecondaryApprovalMap,newSecondaryApprovalMap);
        //2381
        SecondaryApprovalTriggerHelper.callSBSCalloutOrApprovalProcess(newSecondaryApproval,oldSecondaryApprovalMap);
    }
}