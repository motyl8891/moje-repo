/******************************************************************* 
* @author: Linda Kalasnikova
* @date: 2018-05-08  
* @description: This class is a helper class to handle cloned Opportunities in OpportunityTriggerHandler 
********************************************************************/
public with sharing class CloneOpportunityHelper {
      
    // Cache the record type map by developer name
    //private static Map<String, Schema.RecordTypeInfo> rtOppMap = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
   
    // Only compare to "Create" record type IDs, as new / cloned opportunities will always have this record type
    private static Id FRAME_AMENDEMNT_OPPTY_CREATE = GlobalConstants.frameCreateOppRecordTypeId; //U-1903
        //rtOppMap.get(System.Label.Record_Type_Developer_Name_Frame_Amendment_Opportunity_Create).getRecordTypeId();
    private static Id STANDARD_OPPTY_CREATE = GlobalConstants.standardCreateOppRecordTypeId; //U-1903 
        //rtOppMap.get(System.Label.Record_Type_Developer_Name_Standard_Opportunity_Create).getRecordTypeId();
    
    /****************************************************************
    * @author: Linda Kalasnikova
    * @date: 2018-05-08 
    * @param: newOpportunities
    * @return: none
    * @description: Method resets Oppty fields if it's a cloned Opportunity
    *****************************************************************/    
        public static void resetClonedOppties(List<Opportunity> newOpportunities){
        try{  
            for(Opportunity oppty : newOpportunities)
            {
                // Update opportunity fields for cloned opportunities of type Standard and Frame
                if(oppty.IsClone() && 
                    (
                        FRAME_AMENDEMNT_OPPTY_CREATE.equals(oppty.RecordTypeID) ||
                        STANDARD_OPPTY_CREATE.equals(oppty.RecordTypeID)
                    )
                )
                {
                    // Conditionally reset Anticipated Deal Value if Opportunity is Standard
                    if(STANDARD_OPPTY_CREATE.equals(oppty.RecordTypeID))
                    {
                        oppty.Deal_Value__c = null;
                    }
                    // Conditionall reset Deal Value if Opportunity is Frame
                    else if(FRAME_AMENDEMNT_OPPTY_CREATE.equals(oppty.RecordTypeID))
                    {
                        oppty.Anticipated_Deal_Value__c = null;
                    }
                    // RESET Opportunity fields that are calculated by child objects, or are
                    // back-end fields that are only set on specific events, and should not be
                    // inherited by a Cloned opportunity.
                    oppty.Amount = null;
                    oppty.Approved_for_Closed_Won__c = false;
                    oppty.Approved_Stage__c = null;
                    oppty.Auto_Rejection_Reason__c = null;
                    oppty.Cashflow_Analysis_Status__c = null;
                    oppty.CFR_Signum__c = null;
                    oppty.Contract_Evaluation_Status__c = null;
                    oppty.Error_in_Publishing__c = false;
                    oppty.Existing_Early_Starts__c = false;
                    oppty.GCU_Opportunity_Sharing__c = null;
                    oppty.Legacy_SDP2_Status__c = null;
                    oppty.Legacy_SDP3_Status__c = null;
                    oppty.Locked_to_PP__c = false;
                   // oppty.Migrated_Close_Won_Fast_Track__c = false;
                    oppty.Primary_Proposal_Approved__c = null;
                    oppty.Primary_Proposal_Number__c = null;
                    oppty.Proposal_Deal_Value__c = null;
                    oppty.Proposal_Gross_Price__c = null;
                    //oppty.Proposal_Link__c = null;
                    oppty.Proposal_Margin__c = null;
                    oppty.Proposal_Ready_for_Decision__c = false;
                    oppty.Proposal_Submission_Date__c = null;
                    oppty.Proposal_UMBR_Percent__c = null;
                    oppty.Sensitive_Business_Status__c = null;
                    oppty.Salesforce_SDP3_Status__c =null;
                    oppty.Salesforce_SDP2_Status__c =null;
                    oppty.Sequence_When_SDP2_Approved__c = null;
                    oppty.Lock_Small_Value__c = false;
                    oppty.Stage_3_Date__c = null;
                    oppty.Stage_4_Date__c = null;
                    oppty.Trade_Compliance_Status__c = null;
                    oppty.Working_Capital_Days__c = null;
                }
            }
        }catch(UtilException ue){
            EventLog.createLogFuture(Json.serialize(new 
                    EventLog.Error(GlobalConstants.CloneOpportunityHelper, GlobalConstants.resetClonedOppties, GlobalConstants.CloneOpportunityHelper, true, ue)));
        }
    }  
}