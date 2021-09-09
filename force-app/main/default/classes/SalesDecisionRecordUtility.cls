/****************************************************************
* @author: Manu Singhal  
* @date: 09-10-2019
* @User Story: 1366
* @description: This class is a utility class for SalesDecisionRecordTrigger
*****************************************************************/
public without sharing class SalesDecisionRecordUtility {
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-10-2019
* @User Story: 1366
* @description: This method will be called from SalesDecisionRecordTriggerHelper to create sales decision maker records
*****************************************************************/
    public static void createSDMRecords(Sales_Decision_Maker_Rules__c sdrm, Opportunity opp, Id sdrId, String SDRCompleted) {
        try{
            List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
            List<Sales_Decision_Maker__c> sdmListToInsert = new List<Sales_Decision_Maker__c>(); 
            List<Sales_Decision_Maker__c> newSDMListToInsert = new List<Sales_Decision_Maker__c>();
            Map<Id,Sales_Decision_Maker__c> userWithSdmMap = new Map<Id,Sales_Decision_Maker__c>(); 
            if(sdrm.KAM__c) {
                Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                sdm.Auto_Generated__c=true;
                sdm.Approver_Role__c = GlobalConstants.KAM;
                sdm.Sales_Decision_Record__c = sdrId;
                if(opp.KAM__c != null) {
                    sdm.Approver_Name__c = opp.KAM__c;
                    userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                }else{sdmListToInsert.add(sdm);}                                   
            }
            if(sdrm.CU_Head__c)
            {
                if(opp.CU_Head__c != null && userWithSdmMap.keySet().contains(opp.CU_Head__c))
                {
                    Sales_Decision_Maker__c sdm = userWithSdmMap.get(opp.CU_Head__c);
                    sdm.Approver_Role__c = sdm.Approver_Role__c + GlobalConstants.SEMICOLON + GlobalConstants.CUHEAD;
                    userWithSdmMap.put(opp.CU_Head__c,sdm);
                }
                else
                {
                    Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                    sdm.Auto_Generated__c=true;
                    sdm.Approver_Role__c = GlobalConstants.CUHEAD;
                    sdm.Sales_Decision_Record__c = sdrId;
                    if(opp.CU_Head__c != null) {
                        sdm.Approver_Name__c = opp.CU_Head__c;
                        userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                    }else{sdmListToInsert.add(sdm);}                    
                }
            }
            if(sdrm.GCU_Head__c) {
                if(opp.GCU_Head__c != null && userWithSdmMap.keySet().contains(opp.GCU_Head__c))
                {
                    Sales_Decision_Maker__c sdm = userWithSdmMap.get(opp.GCU_Head__c);
                    sdm.Approver_Role__c = sdm.Approver_Role__c + GlobalConstants.SEMICOLON + GlobalConstants.GCUHEAD;
                    userWithSdmMap.put(opp.GCU_Head__c,sdm);
                }
                else
                {
                    Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                    sdm.Auto_Generated__c=true;
                    sdm.Approver_Role__c = GlobalConstants.GCUHEAD;
                    sdm.Sales_Decision_Record__c = sdrId;
                    if(opp.GCU_Head__c != null) {
                        sdm.Approver_Name__c = opp.GCU_Head__c;
                        userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                    }else{sdmListToInsert.add(sdm);}                 
                }
            }
            if(sdrm.GCU_KAM__c) {
                if(opp.GCU_KAM__c != null && userWithSdmMap.keySet().contains(opp.GCU_KAM__c))
                {
                    Sales_Decision_Maker__c sdm = userWithSdmMap.get(opp.GCU_KAM__c);
                    sdm.Approver_Role__c = sdm.Approver_Role__c + GlobalConstants.SEMICOLON + GlobalConstants.GCUKAM;
                    userWithSdmMap.put(opp.GCU_KAM__c,sdm);
                }
                else
                {
                    Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                    sdm.Auto_Generated__c=true;
                    sdm.Approver_Role__c = GlobalConstants.GCUKAM;
                    sdm.Sales_Decision_Record__c = sdrId;
                    if(opp.GCU_KAM__c != null) {
                        sdm.Approver_Name__c = opp.GCU_KAM__c;
                        userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                    }else{sdmListToInsert.add(sdm);}
                }                   
            }
            if(sdrm.MA_Head__c) {
                if(opp.MA_Head__c != null && userWithSdmMap.keySet().contains(opp.MA_Head__c))
                {
                    Sales_Decision_Maker__c sdm = userWithSdmMap.get(opp.MA_Head__c);
                    sdm.Approver_Role__c = sdm.Approver_Role__c + GlobalConstants.SEMICOLON + GlobalConstants.MAHEAD;
                    userWithSdmMap.put(opp.MA_Head__c,sdm);
                }
                else
                {
                    Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                    sdm.Auto_Generated__c=true;
                    sdm.Approver_Role__c = GlobalConstants.MAHEAD;
                    sdm.Sales_Decision_Record__c = sdrId;
                    if(opp.MA_Head__c != null) {
                        sdm.Approver_Name__c = opp.MA_Head__c;
                        userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                    }else{sdmListToInsert.add(sdm);}                 
                }
            }
            if(sdrm.BA_Head__c) {
                if(opp.BA_Head__c != null && userWithSdmMap.keySet().contains(opp.BA_Head__c))
                {
                    Sales_Decision_Maker__c sdm = userWithSdmMap.get(opp.BA_Head__c);
                    sdm.Approver_Role__c = sdm.Approver_Role__c + GlobalConstants.SEMICOLON + GlobalConstants.BAHEAD;
                    userWithSdmMap.put(opp.BA_Head__c,sdm);
                }
                else
                {
                    Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                    sdm.Auto_Generated__c=true;
                    sdm.Approver_Role__c = GlobalConstants.BAHEAD;
                    sdm.Sales_Decision_Record__c = sdrId;
                    if(opp.BA_Head__c != null) {
                        sdm.Approver_Name__c = opp.BA_Head__c;
                        userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                    }else{ sdmListToInsert.add(sdm);}
                }                  
            }
           if(sdrm.GCU_Commercial_Management__c) {
                if(opp.GCU_Commercial_Head__c != null && userWithSdmMap.keySet().contains(opp.GCU_Commercial_Head__c))
                {
                    Sales_Decision_Maker__c sdm = userWithSdmMap.get(opp.GCU_Commercial_Head__c);
                    sdm.Approver_Role__c = sdm.Approver_Role__c + GlobalConstants.SEMICOLON + GlobalConstants.GCUCOMMERCIALMANAGEMENT;
                    userWithSdmMap.put(opp.GCU_Commercial_Head__c,sdm);
                }
                else
                {
                    Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                    sdm.Auto_Generated__c=true;
                    sdm.Approver_Role__c = GlobalConstants.GCUCOMMERCIALMANAGEMENT;
                    sdm.Sales_Decision_Record__c = sdrId;
                    if(opp.GCU_Commercial_Head__c != null) {
                        sdm.Approver_Name__c = opp.GCU_Commercial_Head__c;
                        userWithSdmMap.put(sdm.Approver_Name__c,sdm);
                    }else{sdmListToInsert.add(sdm); }
                }                
            }
            if(sdrm.Commercials__c) {
                Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                sdm.Auto_Generated__c=true;
                sdm.Approver_Role__c = GlobalConstants.COMMERCIALS;
                sdm.Sales_Decision_Record__c = sdrId;
                sdmListToInsert.add(sdm);                 
            }
            if(sdrm.Solution__c) {
                Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                sdm.Auto_Generated__c=true;
                sdm.Approver_Role__c = GlobalConstants.SOLUTION;
                sdm.Sales_Decision_Record__c = sdrId;
                sdmListToInsert.add(sdm); 
            }
            if(sdrm.Fulfillment__c) {
                Sales_Decision_Maker__c sdm = new Sales_Decision_Maker__c();
                sdm.Auto_Generated__c=true;
                sdm.Approver_Role__c = GlobalConstants.FULFILLMENT;
                sdm.Sales_Decision_Record__c = sdrId;
                sdmListToInsert.add(sdm);    
            }  
            newSDMListToInsert.addAll(userWithSdmMap.Values());
            newSDMListToInsert.addAll(sdmListToInsert);
            if(!newSDMListToInsert.isEmpty())
            {
                database.insert(newSDMListToInsert);
            }
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordUtility, GlobalConstants.createSDMRecords, GlobalConstants.SalesDecisionRecordUtility, true, e)));
                           }
    }
    /****************************************************************
* @author: Anukriti
* @date: 09-10-2019
* @User Story: 1366
* @description: This method will check if the SDR is ready to be progressed based on SDMs.
*****************************************************************/        
    public static boolean readyForNextStage(Boolean oppHighImpactDeal, String oppProgressionType, String oppCustomerTier, 
                                            Boolean oppNotDeviating, String oppDealValueLimit, Sales_Decision_Record__c SDR, 
                                            List<Sales_Decision_Maker__c> makersList) {
                                                try{
                                                    Map<String, Sales_Decision_Maker_Rules__c> ruleMap=new Map<String, Sales_Decision_Maker_Rules__c>();
                                                    for(Sales_Decision_Maker_Rules__c rule : [SELECT KAM__c,CU_Head__c,BA_Head__c,Commercials__c,Fulfillment__c,
                                                                                              GCU_Commercial_Management__c,GCU_Head__c,GCU_KAM__c,MA_Head__c,Solution__c,Unique_String__c 
                                                                                              FROM Sales_Decision_Maker_Rules__c Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                                                                  ruleMap.put(rule.Unique_String__c, rule);
                                                                                              }
                                                    String uniqueKey;
                                                    Set<String> rolesSet = new Set<String>();
                                                    List<String> role = new List<String>();
                                                    for(Sales_Decision_Maker__c sdm : makersList) {
                                                        if(sdm.Approver_Role__c.contains(GlobalConstants.SEMICOLON))
                                                        {
                                                            role = sdm.Approver_Role__c.split(GlobalConstants.SEMICOLON);
                                                            rolesSet.addAll(role);
                                                        }
                                                        else    
                                                            rolesSet.add(sdm.Approver_Role__c);
                                                    }
                                                    if(!oppNotDeviating) {
                                                        if(oppHighImpactDeal) {
                                                            uniqueKey = oppProgressionType+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+
                                                                oppHighImpactDeal+GlobalConstants.DASH+SDR.Sales_Decision_Type__c;
                                                        }else {
                                                            uniqueKey = oppProgressionType+GlobalConstants.DASH+oppCustomerTier+GlobalConstants.DASH+
                                                                oppHighImpactDeal+GlobalConstants.DASH+SDR.Sales_Decision_Type__c;               
                                                        }
                                                    }else {
                                                        if(sdr.Sales_Decision_Type__c == GlobalConstants.ConfirmGCUChild && oppDealValueLimit != GlobalConstants.UNDER)
                                                            uniqueKey = GlobalConstants.NULLVAL+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+sdr.Sales_Decision_Type__c+GlobalConstants.DASH+GlobalConstants.UNDER; 
                                                        else 
                                                            uniqueKey = GlobalConstants.NULLVAL+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+sdr.Sales_Decision_Type__c;      
                                                    }                                     
                                                    Sales_Decision_Maker_Rules__c rule;
                                                    if(ruleMap.get(uniqueKey)!=null) {
                                                        rule=ruleMap.get(uniqueKey);
                                                    }
                                                    if(rule != null) {
                                                        if(rule.KAM__c && !rolesSet.contains(GlobalConstants.KAM)) {return false;}
                                                        else if(rule.CU_Head__c && !rolesSet.contains(GlobalConstants.CUHEAD))  {return false;}
                                                        else if(rule.GCU_Head__c && !rolesSet.contains(GlobalConstants.GCUHEAD)) {return false;}
                                                        else if(rule.GCU_Commercial_Management__c && !rolesSet.contains(GlobalConstants.GCUCOMMERCIALMANAGEMENT)) {return false;}
                                                        else if(rule.GCU_KAM__c && !rolesSet.contains(GlobalConstants.GCUKAM)) {return false;}
                                                        else if(rule.MA_Head__c && !rolesSet.contains(GlobalConstants.MAHEAD)) {return false;}
                                                        else if(rule.BA_Head__c && !rolesSet.contains(GlobalConstants.BAHEAD)) {return false;}
                                                        else if(rule.Commercials__c && !rolesSet.contains(GlobalConstants.COMMERCIALS)) {return false;}
                                                        else if(rule.Solution__c && !rolesSet.contains(GlobalConstants.SOLUTION)) {return false;}
                                                        else if(rule.Fulfillment__c && !rolesSet.contains(GlobalConstants.FULFILLMENT)) {return false;}
                                                        else {return true;}
                                                    }else {
                                                        return true;
                                                    }
                                                }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordUtility, GlobalConstants.readyForNextStage, GlobalConstants.SalesDecisionRecordUtility, true, e)));return false;}
                                            }
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method Maps SDR fields from Opp's fields
*****************************************************************/
    public static void mapSDRFields(Sales_Decision_Record__c SDR, Opportunity opp) {
        try{
            SDR.CurrencyIsoCode = opp.CurrencyIsoCode;
            SDR.DealMargin__c = opp.Margin__c;
            SDR.Lead_Domain__c = opp.Lead_Domain__c;
            SDR.Primary_PP_most_recent_PD__c = opp.PD_Proposal_Link__c;
            SDR.Last_Refreshed_datetime__c = system.now();
            SDR.Qualification_Status__c=opp.Qualification_Status__c;
            SDR.Qualification_Status_Date__c=opp.Qualification_Status_Date__c;
            SDR.Comments__c=opp.Comments__c;
            SDR.Opportunity_Tags__c=opp.Tags__c;
            SDR.Team_Assignment__c=opp.Team_Assignment__c; 
            SDR.Total_Pre_Sales_Budget__c=opp.Total_Pre_Sales_Budget__c;
            SDR.Proposal_Submission_Date__c=opp.Proposal_Submission_Date__c;
            SDR.Close_Date__c=opp.CloseDate;
            SDR.Opportunity_Stage__c=opp.StageName;
            SDR.Opportunity_progression_ready__c=opp.Is_ready_for_progression__c;
			if(SDR.Sales_Decision_Type__c != GlobalConstants.SDP3SignContract && opp.StageName == GlobalConstants.STAGE4
              && opp.OpportunityNotReadyReason__c == GlobalConstants.completeContractEval){
                   SDR.Opportunity_progression_ready__c = GlobalConstants.YES;
				}
			if( SDR.Opportunity_progression_ready__c == GlobalConstants.YES){
                SDR.SDR_Completed__c = GlobalConstants.YES;
            }else {
                SDR.SDR_Completed__c = GlobalConstants.NO;
            }
            SDR.Sales_Authority_Matrix__c=opp.Opportunity_Progression_Type__c;
            SDR.Opportunity_Approval_flow__c=opp.Opportunity_Tier__c;
            SDR.High_Impact_Deal__c=opp.High_Impact_Deal__c;
            SDR.Sensitive_Business_Status__c=opp.Sensitive_Business_Status__c;
            SDR.Trade_Compliance_Status__c=opp.Trade_Compliance_Status__c;
            SDR.Primary_Proposal__c= opp.Primary_Proposal__c;
            if(opp.Primary_Proposal__c == null)
                SDR.Overall_EBD_Approval_Status__c = 'No information';
            else 
            	SDR.Overall_EBD_Approval_Status__c = opp.Primary_Proposal__r.Overall_EBD_Approval_Status__c;
            SDR.SDRInSyncWithOpportunity__c=true;
            if(GlobalConstants.frameRecordTypes.contains(opp.RecordTypeId)){
                SDR.Opportunity_Deal_Value__c = opp.Anticipated_Deal_Value__c;
            }
            else{SDR.Opportunity_Deal_Value__c = opp.Deal_Value__c;} 
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, GlobalConstants.mapSDRFields, GlobalConstants.SalesDecisonMakerHelper, true, e)));}
        
    }
    /****************************************************************
* @author: Tobias G
* @date: 20-05-2020
* @param: U-1578
* @description: This method resets SDMs status and recalls related approval processes
*****************************************************************/
    public static void resetSDMs(List<Sales_Decision_Record__c> sdrList) {
        try{
            List<Sales_Decision_Maker__c> sdmList = [Select Id, Approval_Status__c, Sales_Decision_Record__c,Sales_Decision_Record__r.Sales_Decision_Approval_Status__c from Sales_Decision_Maker__c where Sales_Decision_Record__c in :sdrList 
                                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            List<Sales_Decision_Maker__c> sdmUpdateList = new List<Sales_Decision_Maker__c>();
            List<Sales_Decision_Record__c> sdrListToUpdate = new List<Sales_Decision_Record__c>();
            List<ProcessInstanceWorkItem> approvals = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId in : sdmList
                                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
            if(!approvals.isempty() && !sdmList.isempty()){
                for(Sales_Decision_Maker__c sdm : sdmList){
                    for(ProcessInstanceWorkItem approval : approvals){
                        if(approval.ProcessInstance.TargetObjectId == sdm.Id){
                            Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                            pwr.setAction(GlobalConstants.Removed);
                            pwr.setComments(GlobalConstants.Recalled);
                            pwr.setWorkItemId(approval.id);  
                            prWkItems.add(pwr);
                        }
                    }
                    if(sdm.Approval_Status__c != GlobalConstants.TOBEREQUESTED){
                        sdm.Approval_Status__c = GlobalConstants.TOBEREQUESTED;
                        sdm.sdm_flag__c=false;
                        sdm.Conditions_Notes__c = GlobalConstants.BLANK;
						Approval.UnlockResult unlockedRersult = Approval.unlock(sdm);
                        sdmUpdateList.add(sdm);
                        sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
                        if(!sdrListToUpdate.contains(sdm.Sales_Decision_Record__r))
                                sdrListToUpdate.add(sdm.Sales_Decision_Record__r);
                    }
                }
                if(!prWkItems.isEmpty())
                    Approval.ProcessResult[] appResult = Approval.process(prWkItems);
            }
            else
            {  
                if(!sdmList.isempty()){
                    for(Sales_Decision_Maker__c sdm : sdmList)
                    {
                        if(sdm.Approval_Status__c != GlobalConstants.TOBEREQUESTED){
							Approval.UnlockResult unlockedRersult = Approval.unlock(sdm);  // D-3183
                            sdm.Approval_Status__c = GlobalConstants.TOBEREQUESTED;
                            sdm.sdm_flag__c=false;
                            sdm.Conditions_Notes__c = GlobalConstants.BLANK;
                            sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
                            sdmUpdateList.add(sdm);
                            if(!sdrListToUpdate.contains(sdm.Sales_Decision_Record__r))
                                sdrListToUpdate.add(sdm.Sales_Decision_Record__r);
                        }
                    }
                }
            }
            if(!sdmUpdateList.isEmpty() && !sdrListToUpdate.isEmpty()){                                
                update sdmUpdateList;
                update sdrListToUpdate;
            } 
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, GlobalConstants.resetSDMs, GlobalConstants.SalesDecisonMakerHelper, true, e)));
                           }        
    }
    /****************************************************************
* @author: Ankit Jain
* @date: 20-04-2020
* @param: U-1737
* @description: Mark Oppoy ApprovedSDPStage To Obsolete (U-1737 & U-1733)
*****************************************************************/
    public static Opportunity MarkOppoyApprovedSDPStageToObsolete(Opportunity opp) {
        try{
            if(null != opp.Approved_SDP_Stage__c){
                 if((GlobalConstants.OQB.equalsIgnoreCase(opp.Approved_SDP_Stage__c) && GlobalConstants.Qualify_Opportunity.equalsIgnoreCase(opp.StageName) && GlobalConstants.MELA.equalsIgnoreCase(opp.MarketArea__c))
                   ||(GlobalConstants.QualifyGCUChild.equalsIgnoreCase(opp.Approved_SDP_Stage__c) && GlobalConstants.Qualify_Opportunity.equalsIgnoreCase(opp.StageName) && opp.Not_Deviating_from_Parent__c)
                   ||(GlobalConstants.SDPStage1.equalsIgnoreCase(opp.Approved_SDP_Stage__c) && GlobalConstants.Define_CustomerValue.equalsIgnoreCase(opp.StageName) && !opp.Not_Deviating_from_Parent__c && GlobalConstants.Minor !=opp.Opportunity_Tier__c && GlobalConstants.MELA !=opp.MarketArea__c)
                   ||(GlobalConstants.SDPStage2.equalsIgnoreCase(opp.Approved_SDP_Stage__c) && GlobalConstants.Create_Proposal.equalsIgnoreCase(opp.StageName) && !opp.Not_Deviating_from_Parent__c &&  GlobalConstants.Minor !=opp.Opportunity_Tier__c)
                   ||(GlobalConstants.SDPStage3.equalsIgnoreCase(opp.Approved_SDP_Stage__c) && GlobalConstants.Negotiate_and_Close.equalsIgnoreCase(opp.StageName) && !opp.Not_Deviating_from_Parent__c && GlobalConstants.Minor !=opp.Opportunity_Tier__c && opp.RecordTypeId!=GlobalConstants.simpleOppRecordTypeId && opp.RecordTypeId!=GlobalConstants.simpleCreateOppRecTypeId)
                   ||(GlobalConstants.ConfirmGCUChild.equalsIgnoreCase(opp.Approved_SDP_Stage__c) && GlobalConstants.Negotiate_and_Close.equalsIgnoreCase(opp.StageName) && opp.Not_Deviating_from_Parent__c)){
                       opp.Approved_SDP_Stage__c=GlobalConstants.obsolete;
                       if(GlobalConstants.Negotiate_and_Close.equalsIgnoreCase(opp.StageName)){
                           opp.Primary_Proposal_Approved__c = GlobalConstants.falseText;
                           opp.Approved_for_closed_won__c =false;
                       }
                   }
            } 
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordUtility, GlobalConstants.MarkOppoyApprovedSDPStageToObsolate, GlobalConstants.SalesDecisionRecordUtility, true, e)));}
        return opp;        
    }
}