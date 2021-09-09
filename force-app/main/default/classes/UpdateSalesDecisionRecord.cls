/****************************************************************
* @author: Pallavi Patil  
* @date: 09-09-2019
* @User Story: 1051
* @description: This class will be called from aura component 
*****************************************************************/
public without sharing class UpdateSalesDecisionRecord {
    /****************************************************************
* @author: Pallavi Patil  
* @date: 09-09-2019
* @User Story: 1051
* @description: This class will be called from aura component 
*****************************************************************/
    @AuraEnabled
    public static boolean updateCheck(id sdrId){
        Boolean flag = false;
        Set<Id> frameRecordTypes = GlobalConstants.frameRecordTypes;
        Set<Id> standRecordTypes = GlobalConstants.standRecordTypes;
        try{
           list<Sales_Decision_Record__c> SDR_list = new list<Sales_Decision_Record__c>();
           for (Sales_Decision_Record__c SDR : [select id,SDRInSyncWithOpportunity__c,Sales_Decision_Approval_Status__c,opportunity__r.CurrencyIsoCode,Opportunity__r.Deal_Value__c,Opportunity__r.Exchange_Rate__c,Opportunity__r.Anticipated_Deal_Value__c,opportunity__r.RecordTypeId,opportunity__r.PD_Proposal_Link__c,Last_Refreshed_datetime__c,DealMargin__c,Lead_Domain__c,Opportunity_Deal_Value__c,Primary_PP_most_recent_PD__c,opportunity__r.Margin__c,opportunity__r.Lead_Domain__c, 
                                                opportunity__r.Qualification_Status__c,Opportunity__r.Qualification_Status_Date__c,
                                                Opportunity__r.Comments__c, Opportunity__r.Tags__c, Opportunity__r.Team_Assignment__c, 
                                                Opportunity__r.Total_Pre_Sales_Budget__c, Opportunity__r.Proposal_Submission_Date__c,
                                                Opportunity__r.CloseDate,Opportunity__r.StageName, Opportunity__r.Is_ready_for_progression__c,
                                                Opportunity__r.Opportunity_Tier__c, Opportunity__r.High_Impact_Deal__c, Opportunity__r.Sensitive_Business_Status__c,
                                                Opportunity__r.Trade_Compliance_Status__c, Opportunity__r.Opportunity_Progression_Type__c
                                                from Sales_Decision_Record__c
                                                where id =: sdrId 
                                                limit 1]) {
                if(SDR.Sales_Decision_Approval_Status__c.equalsIgnoreCase(GlobalConstants.APPROVED))
                    flag = true;
                else {
                    SDR.DealMargin__c = SDR.opportunity__r.Margin__c;
                    SDR.Lead_Domain__c = SDR.opportunity__r.Lead_Domain__c;
                    SDR.Last_Refreshed_datetime__c = system.now();
                    SDR.Primary_PP_most_recent_PD__c = SDR.opportunity__r.PD_Proposal_Link__c;
             		SDR.CurrencyIsoCode = SDR.opportunity__r.CurrencyIsoCode;
                    SDR.Qualification_Status__c=SDR.opportunity__r.Qualification_Status__c;
                    SDR.Qualification_Status_Date__c=SDR.Opportunity__r.Qualification_Status_Date__c;
                    SDR.Comments__c=SDR.Opportunity__r.Comments__c;
                    SDR.Opportunity_Tags__c=SDR.Opportunity__r.Tags__c;
                    SDR.Team_Assignment__c=SDR.Opportunity__r.Team_Assignment__c; 
                    SDR.Total_Pre_Sales_Budget__c=SDR.Opportunity__r.Total_Pre_Sales_Budget__c;
                    SDR.Proposal_Submission_Date__c=SDR.Opportunity__r.Proposal_Submission_Date__c;
                    SDR.Close_Date__c=SDR.Opportunity__r.CloseDate;
                    SDR.Opportunity_Stage__c=SDR.Opportunity__r.StageName;
                    SDR.Opportunity_progression_ready__c=SDR.Opportunity__r.Is_ready_for_progression__c;
                    SDR.SDRInSyncWithOpportunity__c = true;
                    if(GlobalConstants.YES.equalsIgnoreCase(SDR.Opportunity_progression_ready__c) /*&& SDR.SDRInSyncWithOpportunity__c*/) {
                        SDR.SDR_Completed__c = GlobalConstants.YES;
                    }
                    SDR.Sales_Authority_Matrix__c=SDR.Opportunity__r.Opportunity_Progression_Type__c;
                    SDR.Opportunity_Approval_flow__c=SDR.Opportunity__r.Opportunity_Tier__c;
                    SDR.High_Impact_Deal__c=SDR.Opportunity__r.High_Impact_Deal__c;
                    SDR.Sensitive_Business_Status__c=SDR.Opportunity__r.Sensitive_Business_Status__c;
                    SDR.Trade_Compliance_Status__c=SDR.Opportunity__r.Trade_Compliance_Status__c;
                    if(frameRecordTypes.contains(SDR.Opportunity__r.RecordTypeId)){
                            SDR.Opportunity_Deal_Value__c = SDR.Opportunity__r.Anticipated_Deal_Value__c;
                    }else{
                            SDR.Opportunity_Deal_Value__c = SDR.Opportunity__r.Deal_Value__c;
                    }     
                    SDR_list.add(SDR);
                }
            }
             if(!SDR_list.isEmpty()){
                    update SDR_list;
                	SalesDecisionRecordUtility.resetSDMs(SDR_list);
                }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, GlobalConstants.getAllOLI, GlobalConstants.OppController, true, e)));}
        return flag;
    }
}