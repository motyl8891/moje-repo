/****************************************************************
* @author: Manu Singhal
* @date: 14-03-2020
* @User Story: 1581
* @description: This class will handle DeviationTypeGroupTrigger

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			16-07-2020				U-1991 - Profile related condition updated with "AccessSettings__c" custom setting
Shubham Kadam			19-08-2020 				U-1928 - Post to Chatter on Deviation Record Page when Approver 1 = Approved or Approved with Condition 
and Approver 2 = Pending
*****************************************************************/
public with sharing class DeviationTypeGroupHandler {
    /****************************************************************
* @author: Manu Singhal/Biswajit Sahoo
* @date: 14-03-2020/14-01-2021
* @User Story: 1581/U-2291
* @description: This method will be called from DeviationTypeGroupTrigger on after update
*****************************************************************/
    public void onAfterUpdate(
        List<DeviationTypeGroup__c> newDeviationsList,
        List<DeviationTypeGroup__c> oldDeviationsList,
        Map<ID, DeviationTypeGroup__c> newDeviationsMap,
        Map<ID, DeviationTypeGroup__c> oldDeviationsMap
    ) {
        //DeviationTypeGroupHelper.goToApprovalStep1(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);
        //DeviationTypeGroupHelper.goToApprovalStep2(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);
        DeviationTypeGroupHelper.updateProposalEBDStatus(
            newDeviationsList,
            oldDeviationsMap
        );
        //U-1928
        DeviationTypeGroupHelper.postToChatter(
            newDeviationsList,
            oldDeviationsMap
        );     
        
         DeviationTypeGroupHelper.updateQuesProdGroupsOnProposal(
            newDeviationsList
        );
        
    }
    
    /****************************************************************
* @author: Manu Singhal
* @date: 14-03-2020
* @User Story: 1581
* @description: This method will be called from DeviationTypeGroupTrigger on before update
*****************************************************************/
    public void onBeforeUpdate(
        List<DeviationTypeGroup__c> newDeviationsList,
        List<DeviationTypeGroup__c> oldDeviationsList,
        Map<ID, DeviationTypeGroup__c> newDeviationsMap,
        Map<ID, DeviationTypeGroup__c> oldDeviationsMap
    ) {
        //U-1826
        DeviationTypeGroupHelper.updateDeviationFields(
            newDeviationsList,
            oldDeviationsList,
            newDeviationsMap,
            oldDeviationsMap
        );
        //U-1991 
        if(!AccessSettings__c.getInstance().CanEditDeviationFields__c){
            DeviationTypeGroupHelper.restrictEditOfSupportingMaterial(
                newDeviationsList,
                oldDeviationsList,
                newDeviationsMap,
                oldDeviationsMap
            );
            DeviationTypeGroupHelper.restrictEditOfMAFields(
                newDeviationsList,
                oldDeviationsList,
                newDeviationsMap,
                oldDeviationsMap
            );
            DeviationTypeGroupHelper.restrictEditOfBAFields(
                newDeviationsList,
                oldDeviationsList,
                newDeviationsMap,
                oldDeviationsMap
            );
        }          
    }
    public void onAfterInsert(
        List<DeviationTypeGroup__c> newDeviationsList
  ) {
        DeviationTypeGroupHelper.updateProposalEBDStatus1(
            newDeviationsList
        );
        DeviationTypeGroupHelper.updateQuesProdGroupsOnProposal(
            newDeviationsList
        );
     /*  DeviationTypeGroupHelper.updateLookupDeviationType(
       newDeviationsList
       );*/
    }
}