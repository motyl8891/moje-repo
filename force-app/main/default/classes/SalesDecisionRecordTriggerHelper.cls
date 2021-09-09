/****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This class is a helper class for SalesDecisionRecordTriggerHandler

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			16-07-2020				U-1991 - Profile related condition updated with "AccessSettings__c" custom setting

*****************************************************************/
public without sharing class SalesDecisionRecordTriggerHelper {
    //public static Map<Id,Id> opptyWithSDRIdMap = new Map<Id,Id>();
    
    /****************************************************************
* @author: Tobias Gustafsson  
* @date: 09-09-2019
* @param: oldSalesDecisionMap,  newSalesDecisionMap
* @param: newSalesDecision 
* @description: This method will set the snapshot data when creating the sales decision records based on Opportunity data (U-1272)
*****************************************************************/
    
    public static void setDataSnapshotFields(List<Sales_Decision_Record__c> newSalesDecision){
        List<Id> oppIds = new List<Id>();
        //List<Opportunity> oppList = new List<Opportunity>();
        //Set<Id> validRecordTypes = GlobalConstants.frameStandRecordTypes;
        Set<Id> frameRecordTypes = GlobalConstants.frameRecordTypes;
        Set<Id> standRecordTypes = GlobalConstants.standRecordTypes;
        try{
            for(Sales_Decision_Record__c SDR : newSalesDecision){
                oppIds.add(SDR.Opportunity__c);
            }
            //NS
            if(!oppIds.isEmpty()){
                for(Opportunity opp : [Select id, Is_ready_for_progression__c, RecordTypeId, Anticipated_Deal_Value__c, Deal_Value__c, CurrencyIsoCode, 
                                       Margin__c, Lead_Domain__c, PD_Proposal_Link__c, Qualification_Status__c, Qualification_Status_Date__c,
                                       Comments__c, Tags__c, Team_Assignment__c, Total_Pre_Sales_Budget__c, Proposal_Submission_Date__c,
                                       CloseDate, StageName, Opportunity_Progression_Type__c,OpportunityNotReadyReason__c,
                                       Opportunity_Tier__c, High_Impact_Deal__c, Sensitive_Business_Status__c,Primary_Proposal__c,
                                       Trade_Compliance_Status__c,Primary_Proposal__r.Overall_EBD_Approval_Status__c
                                       from Opportunity where Id in :oppIds Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                           for(Sales_Decision_Record__c SDR : newSalesDecision){
                                               if(SDR.Opportunity__c == opp.Id){
                                                   SalesDecisionRecordUtility.mapSDRFields(SDR, opp);
                                                   if(SDR.Opportunity_progression_ready__c.equalsIgnoreCase(GlobalConstants.YES) /*&& SDR.SDRInSyncWithOpportunity__c*/) {
                                                       SDR.SDR_Completed__c = GlobalConstants.YES;
                                                   }    
                                               }
                                           }
                                       }    
            }
            
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
                                                                       GlobalConstants.SalesDecisionSnapshotError, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @param: oldSalesDecisionMap,  newSalesDecisionMap
* @description: This method will show error if sales decision status is changed to approved and all the sales makers do not have approved status(U-1051)
*****************************************************************/
    public static void SalesDecisionApprovedStatusError(Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap , Map<ID, Sales_Decision_Record__c> newSalesDecisionMap)
    { 
        try{
            Set<id> salesDecisionApprovedIdset = new Set<id>();
            List<String> approvalStatusList;
            Map<id, List<String>> decisionWithDecisionMakerMap = new Map<id, List<String>>();
            for(Sales_Decision_Record__c salesDecision : newSalesDecisionMap.values())
            {
                if(salesDecision.Sales_Decision_Approval_Status__c != oldSalesDecisionMap.get(salesDecision.id).Sales_Decision_Approval_Status__c
                   && salesDecision.Sales_Decision_Approval_Status__c == GlobalConstants.APPROVED)
                {
                    salesDecisionApprovedIdset.add(salesDecision.id);
                }
            }
            if(!salesDecisionApprovedIdset.isEmpty())
            {
                for(Sales_Decision_Maker__c salesDecisionMaker : [Select id, Approval_Status__c,Sales_Decision_Record__c from Sales_Decision_Maker__c 
                                                                  where Sales_Decision_Record__c in : salesDecisionApprovedIdset
                                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(decisionWithDecisionMakerMap.containsKey(salesDecisionMaker.Sales_Decision_Record__c))
                    {
                        approvalStatusList = decisionWithDecisionMakerMap.get(salesDecisionMaker.Sales_Decision_Record__c);
                        approvalStatusList.add(salesDecisionMaker.Approval_Status__c);
                        decisionWithDecisionMakerMap.put(salesDecisionMaker.Sales_Decision_Record__c,approvalStatusList);
                    }
                    else
                    {
                        approvalStatusList = new List<String>();
                        approvalStatusList.add(salesDecisionMaker.Approval_Status__c);
                        decisionWithDecisionMakerMap.put(salesDecisionMaker.Sales_Decision_Record__c,approvalStatusList);
                    }
                }
            }
            if(!decisionWithDecisionMakerMap.isEmpty())
            {
                for(id decisionId : decisionWithDecisionMakerMap.keyset())
                {
                    for(String approvalStatus : decisionWithDecisionMakerMap.get(decisionId))
                    {
                        if(approvalStatus != GlobalConstants.APPROVED)
                        {
                            newSalesDecisionMap.get(decisionId).addError(GlobalConstants.SalesDecisionApprovedStatusError1);
                        }
                    }
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
                                                                       GlobalConstants.SalesDecisionApprovedStatusError, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @param: newSalesDecision 
* @description: This method will update ACR,CSR and CFR based on Oppty Sales Team(U-1051)
*****************************************************************/
    /*******************************************************************
* @author: <Paresh Saxena>
* @date: <2020-01-16>
* @description: <Epic> <U-1484> <Update the Sales Decision Record creation logic to pick
the records with the Primary flag checked for populating the ACR/CFR/CSR>
********************************************************************/ 
    public static void updateACR_CSR_CFRBasedOnOpptySalesTeam(List<Sales_Decision_Record__c> newSalesDecision){
        try
        {
            
            Map<id, List<Sales_Decision_Record__c>> opptyWithSalesDecisionsMap = new Map<id, List<Sales_Decision_Record__c>>();
            List<Sales_Decision_Record__c> salesDecisionList;
            List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
            Map<id, id> opptyWithOpptyOwnerMap = new Map<id, id>();
            Map<id, String> userIdWithSignumMap = new Map<id, String>();
            Map<String, id> empSignumWithEmployeeMap = new Map<String, id>();
            for(Sales_Decision_Record__c salesDecision : newSalesDecision)
            {
                if(opptyWithSalesDecisionsMap.containsKey(salesDecision.Opportunity__c))
                {
                    salesDecisionList = opptyWithSalesDecisionsMap.get(salesDecision.Opportunity__c);
                    salesDecisionList.add(salesDecision);
                    opptyWithSalesDecisionsMap.put(salesDecision.Opportunity__c,salesDecisionList);
                }
                else
                {
                    salesDecisionList = new List<Sales_Decision_Record__c>();
                    salesDecisionList.add(salesDecision);
                    opptyWithSalesDecisionsMap.put(salesDecision.Opportunity__c,salesDecisionList);
                }   
            }
            if(!opptyWithSalesDecisionsMap.isEmpty())
            {  
                
                for(Opportunity_Sales_Team__c oppSalesTeam : [select id, Employee__c,Employee__r.Email__c, Role__c, Opportunity__c 
                                                              from Opportunity_Sales_Team__c 
                                                              where Opportunity__c in: opptyWithSalesDecisionsMap.keySet()
                                                              and Primary__c=true
                                                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                { 
                    

                    if(oppSalesTeam.Role__c == GlobalConstants.CSR)
                    {
                        for(Sales_Decision_Record__c salesDecision : opptyWithSalesDecisionsMap.get(oppSalesTeam.Opportunity__c))
                        {
                            salesDecision.CSR__c = oppSalesTeam.Employee__c;
                            salesDecision.CSR_Email__c = oppSalesTeam.Employee__r.Email__c;
                        }
                    }
                    if(oppSalesTeam.Role__c == GlobalConstants.CFR)
                    {
                        for(Sales_Decision_Record__c salesDecision : opptyWithSalesDecisionsMap.get(oppSalesTeam.Opportunity__c))
                        {
                            salesDecision.CFR__c = oppSalesTeam.Employee__c;
                            salesDecision.CFR_Email__c = oppSalesTeam.Employee__r.Email__c;
                        }
                    }
                    if(oppSalesTeam.Role__c == GlobalConstants.ACR)
                    {
                        for(Sales_Decision_Record__c salesDecision : opptyWithSalesDecisionsMap.get(oppSalesTeam.Opportunity__c))
                        {
                            salesDecision.ACR__c = oppSalesTeam.Employee__c;
                            salesDecision.ACR_Email__c = oppSalesTeam.Employee__r.Email__c;
                        }
                    }
                }
                
                for(Opportunity oppty : [Select id,ownerId from Opportunity 
                                         where id in: opptyWithSalesDecisionsMap.keySet()
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    opptyWithOpptyOwnerMap.put(oppty.id, oppty.ownerId);
                }
            }
            if(!opptyWithOpptyOwnerMap.isEmpty())
            {
                for(User user : [Select id, Signum__c from User 
                                 where id in :opptyWithOpptyOwnerMap.values() Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    userIdWithSignumMap.put(user.id, user.Signum__c.toLowerCase());
                }
                if(!userIdWithSignumMap.isEmpty())
                {
                    for(Employee__c emp : [select id,Signum__c from Employee__c 
                                           where Signum__c in : userIdWithSignumMap.values() Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                    {
                        empSignumWithEmployeeMap.put(emp.Signum__c.toLowerCase(),emp.id);
                    }  
                }
            }
            if(!empSignumWithEmployeeMap.isEmpty())
            {
                for (List<Sales_Decision_Record__c> salesDecision : opptyWithSalesDecisionsMap.values())
                { sdrList.addAll(salesDecision); }
                for(Sales_Decision_Record__c salesDecision : sdrList)
                {
                    if(salesDecision.Source__c == GlobalConstants.AUTOMATIC)
                    {
                        id employeeId = empSignumWithEmployeeMap.get(userIdWithSignumMap.get(opptyWithOpptyOwnerMap.get(salesDecision.Opportunity__c)).toLowerCase());
                        if(salesDecision.ACR__c == null)
                        { salesDecision.ACR__c = employeeId; }
                        if(salesDecision.CFR__c == null)
                        { salesDecision.CFR__c = employeeId; }
                        if(salesDecision.CSR__c == null)
                        { salesDecision.CSR__c = employeeId; }
                    }
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
                                                                       GlobalConstants.updateACR_CSR_CFRBasedOnOpptySalesTeam, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Jagatap  
* @date: 28-01-2020
* @param: oldSalesDecision,  newSalesDecisionMap
* @description: This method will update ACR_Email, CSR_Email, CFR_Email values when any of ACR,CSR and CFR values for SDR are changed.
*****************************************************************/    
    public static void updateACR_CSR_CFREmail(Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap,
                                              Map<ID, Sales_Decision_Record__c> newSalesDecisionMap){
                                                  try
                                                  {
                                                      Set<id> empIdSet = new Set<id>();
                                                      Map<id, String> empWithEmailMap = new Map<id, String>();          
                                                      for(Sales_Decision_Record__c sdr : newSalesDecisionMap.values()){
                                                          
                                                          if(sdr.ACR__c != oldSalesDecisionMap.get(sdr.Id).ACR__c)
                                                          {  
                                                              empIdSet.add(sdr.ACR__c);  
                                                          }
                                                          if(sdr.CSR__c != oldSalesDecisionMap.get(sdr.Id).CSR__c)
                                                          {   
                                                              empIdSet.add(sdr.CSR__c); 
                                                          }
                                                          if(sdr.CFR__c != oldSalesDecisionMap.get(sdr.Id).CFR__c)
                                                          {                     
                                                              empIdSet.add(sdr.CFR__c);    
                                                          }
                                                      }
                                                      if(!empIdSet.isEmpty())
                                                      {
                                                          for(Employee__c emp :[select id,Email__c from Employee__c 
                                                                                where id in: empIdSet
                                                                                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                                                          {
                                                              empWithEmailMap.put(emp.id, emp.Email__c);
                                                          }
                                                      }
                                                      if(!empWithEmailMap.isEmpty())
                                                      {
                                                          for(Sales_Decision_Record__c sdr : newSalesDecisionMap.values())
                                                          {
                                                              if(sdr.ACR__c != oldSalesDecisionMap.get(sdr.Id).ACR__c && empWithEmailMap.get(sdr.ACR__c) != null)
                                                              {   
                                                                  sdr.ACR_Email__c = empWithEmailMap.get(sdr.ACR__c);     
                                                              }
                                                              if(sdr.CSR__c != oldSalesDecisionMap.get(sdr.Id).CSR__c && empWithEmailMap.get(sdr.CSR__c) != null)
                                                              {  
                                                                  sdr.CSR_Email__c = empWithEmailMap.get(sdr.CSR__c);        
                                                              }
                                                              if(sdr.CFR__c != oldSalesDecisionMap.get(sdr.Id).CFR__c && empWithEmailMap.get(sdr.CFR__c) != null)
                                                              {  
                                                                  sdr.CFR_Email__c = empWithEmailMap.get(sdr.CFR__c);        
                                                              }                   
                                                          }   
                                                      }
                                                  }
                                                  catch(Exception e) {
                                                      EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
                                                                                                                 GlobalConstants.updateACR_CSR_CFREmail, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
                                                  }
                                              }
    /****************************************************************
* @author: Aditya Mohapatra  
* @date: 12-09-2019
* @param: oldSalesDecisionMap,  newSalesDecisionMap
* @description: This method will update Latest Approved SDP Stage on Opportunity when a Sales Decision Record is Saved and Locked(U-1271)
*****************************************************************/
    /**    public static void updateApprovedSDPStage(List<Sales_Decision_Record__c> newSalesDecision){
try{
List<Sales_Decision_Record__c> salesDecisionList = new List<Sales_Decision_Record__c>();
List<Opportunity> oppToUpdateList = new List<Opportunity>();
Map<id,id> salesDecisionWithOpptyIdMap = new Map<id,id>();
for(Sales_Decision_Record__c salesDecision : newSalesDecision)
{	
if(salesDecision.Locked__c)
{
salesDecisionWithOpptyIdMap.put(salesDecision.id,salesDecision.Opportunity__c);
salesDecisionList.add(salesDecision);
}
}
if(!salesDecisionWithOpptyIdMap.isEmpty())
{  
Map<id,Opportunity> opptyMap = new Map<id,Opportunity>([select id, Approved_SDP_Stage__c, Approved_for_closed_won__c, Approved_Stage__c from Opportunity 
where id in: salesDecisionWithOpptyIdMap.values()
Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
if(!opptyMap.isEmpty() && !salesDecisionList.isEmpty())
{
for(Sales_Decision_Record__c salesDecision : salesDecisionList)
{
opptyMap.get(salesDecisionWithOpptyIdMap.get(salesDecision.id)).Approved_SDP_Stage__c = salesDecision.Sales_Decision_Type__c;
if(salesDecision.Sales_Decision_Type__c == 'SDP3 Sign Contract' || salesDecision.Sales_Decision_Type__c == 'Confirm GCU Child'){
opptyMap.get(salesDecisionWithOpptyIdMap.get(salesDecision.id)).Approved_Stage__c = '4. Negotiate and Close';
opptyMap.get(salesDecisionWithOpptyIdMap.get(salesDecision.id)).Approved_for_closed_won__c = true;

}
oppToUpdateList.add(opptyMap.get(salesDecisionWithOpptyIdMap.get(salesDecision.id)));
}
}

}
if(!oppToUpdateList.isEmpty())
database.update(oppToUpdateList,false);

}catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
GlobalConstants.updateApprovedSDPStage, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));

}
}***/
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @param: oldSalesDecisionMap,  newSalesDecisionMap
* @description: This method will show error If Opportunity is MELA only MELA Sales Ops have access to set the Sales Decision Approval Status to "Approved" if the Sales Decision type is OQB(U-1271)
*****************************************************************/
    public static void checkRecordEditabilityForMELAOppty(Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap , Map<ID, Sales_Decision_Record__c> newSalesDecisionMap)
    { 
        try
        {
            Map<id,id> sdrWithOppidMap = new Map<id,id>();
            for(Sales_Decision_Record__c salesDecision : newSalesDecisionMap.values())
            {
                if(salesDecision.Sales_Decision_Approval_Status__c != oldSalesDecisionMap.get(salesDecision.id).Sales_Decision_Approval_Status__c
                   && salesDecision.Sales_Decision_Approval_Status__c == GlobalConstants.APPROVED
                   && salesDecision.Sales_Decision_Type__c == GlobalConstants.OQB)
                {
                    sdrWithOppidMap.put(salesDecision.id,salesDecision.Opportunity__c);
                }
            }
            if(!sdrWithOppidMap.isEmpty())
            {
                Map<id, Opportunity> oppWithMarketAreaMap = new Map<id, Opportunity>([Select id, MarketArea__c from Opportunity 
                                                                                      where id in : sdrWithOppidMap.values()
                                                                                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                User user = [select id, CompanyName, ProfileId from User 
                             where id =: userinfo.getUserId() 
                             Limit 1]; 
                for(id sdrId : sdrWithOppidMap.keySet())
                {
                    //U-1991
                    if(oppWithMarketAreaMap.get(sdrWithOppidMap.get(sdrId)).MarketArea__c == GlobalConstants.MELA 
                       &&  !AccessSettings__c.getInstance().CanEditMELA__c 
                       && (user.CompanyName != GlobalConstants.MELA || !AccessSettings__c.getInstance().CanEditMELA__c))
                    {
                        newSalesDecisionMap.get(sdrId).addError(GlobalConstants.MELAOpptyError);
                    }
                }
            }    
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
                                                                       GlobalConstants.checkRecordEditabilityForMELAOppty, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 04-10-2019
* @param: newSalesDecision 
* @description: This method will create sales decision makers records based on oppty progression type and oppty stage.(U-1366)
*****************************************************************/
    public static void createSalesDecisionMakerRecords(List<Sales_Decision_Record__c> newSalesDecision) {
        try {   
            Map<id,id> salesWithOpptyIdMap = new Map<id,id>();
            Map<String, Sales_Decision_Maker_Rules__c> uniqueToValMap = new Map<String, Sales_Decision_Maker_Rules__c>();
            Map<Id, Opportunity> opptyMap=new Map<Id, Opportunity>();
            Opportunity opp;
            String uniqueKey;
            for(Sales_Decision_Record__c salesDecision : newSalesDecision) {
                if(salesDecision.Source__c != GlobalConstants.AUTOMATIC 
                   || salesDecision.Sales_Decision_Approval_Status__c != GlobalConstants.APPROVED) {
                       salesWithOpptyIdMap.put(salesDecision.id,salesDecision.Opportunity__c);
                   //opptyWithSDRIdMap.put(salesDecision.Opportunity__c, salesDecision.id);
				   }
            }
            if(!salesWithOpptyIdMap.isEmpty())
            {
                opptyMap = new Map<Id, Opportunity>([Select id, Not_Deviating_from_Parent__c, KAM__c, CU_Head__c, GCU_Head__c,
                                                     GCU_Commercial_Head__c,GCU_KAM__c,MA_Head__c,BA_Head__c,
                                                     Opportunity_Progression_Type__c,StageName,Opportunity_Tier__c,
                                                     High_Impact_Deal__c,Deal_Value_Compared_To_CU_Value_Limits__c,
                                                     GCU_Commercial_Director__c
                                                     FROM Opportunity where id in:salesWithOpptyIdMap.values()
                                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            }
            for(Sales_Decision_Maker_Rules__c rule : [SELECT KAM__c,CU_Head__c,BA_Head__c,
                                                      Commercials__c,Fulfillment__c,GCU_Commercial_Management__c,                    
                                                      GCU_Head__c,GCU_KAM__c,MA_Head__c,
                                                      Solution__c,Unique_String__c FROM Sales_Decision_Maker_Rules__c
                                                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                          uniqueToValMap.put(rule.Unique_String__c, rule);
                                                      }
            if(!opptyMap.isEmpty())
            {
                for(Sales_Decision_Record__c sdr : newSalesDecision) {
                    opp = opptyMap.get(salesWithOpptyIdMap.get(sdr.id));
                    //if(!opptyWithSDRIdMap.containsKey(opp.Id)){
                    if(!opp.Not_Deviating_from_Parent__c)
                    {
                        if(opp.High_Impact_Deal__c) {
                            uniqueKey = opp.Opportunity_Progression_Type__c+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+opp.High_Impact_Deal__c+GlobalConstants.DASH+sdr.Sales_Decision_Type__c; }
                        else {
                            uniqueKey = opp.Opportunity_Progression_Type__c+GlobalConstants.DASH+opp.Opportunity_Tier__c+GlobalConstants.DASH+opp.High_Impact_Deal__c+GlobalConstants.DASH+sdr.Sales_Decision_Type__c; }                            
                    }
                    else
                    {
                        if(opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER) {
                            uniqueKey = opp.Opportunity_Progression_Type__c+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+sdr.Sales_Decision_Type__c+GlobalConstants.DASH+GlobalConstants.UNDER; } 
                        else { 
                            uniqueKey = opp.Opportunity_Progression_Type__c+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+GlobalConstants.NULLVAL+GlobalConstants.DASH+sdr.Sales_Decision_Type__c; }     
                    }
                    if(uniqueToValMap.get(uniqueKey) != null) {
                        SalesDecisionRecordUtility.createSDMRecords(uniqueToValMap.get(uniqueKey),opp,sdr.id,sdr.SDR_Completed__c);
                    	//opptyWithSDRIdMap.put(opp.Id,sdr.id);
                    }
                //}
            }
            } 
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
                                                                       GlobalConstants.createSalesDecisionMakerRecords, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method locks SDR, Opp and Proposals when Requested_SDM_Count__c > 0
*****************************************************************/
    /*  public static void lockSDROppProposal(List<Sales_Decision_Record__c> newSDRList, 
Map<Id, Sales_Decision_Record__c> oldSDRMap) {
try{
List<Id> oppIds = new List<Id>();
for(Sales_Decision_Record__c sdr : newSDRList) {
if(sdr.Requested_SDM_Count__c == 0 && sdr.Requested_SDM_Count__c != oldSDRMap.get(sdr.Id).Requested_SDM_Count__c) {
oppIds.add(sdr.Opportunity__c);
}
}
if(!oppIds.isEmpty()) {
List<Approval.lockResult> ulrList =Approval.lock(oppIds); //lock opps
}
}catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
GlobalConstants.lockSDROppProposal, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));}
}*/
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method unlocks SDR, Opp and proposals
*****************************************************************/
    /* public static void unlockSDROppProposal(List<Sales_Decision_Record__c> newSDRList, 
Map<Id, Sales_Decision_Record__c> oldSDRMap) {
try{
List<Id> oppIds = new List<Id>();
for(Sales_Decision_Record__c sdr : newSDRList) {
if(sdr.Requested_SDM_Count__c > 0 && sdr.Requested_SDM_Count__c==sdr.SDMCount__c && sdr.Requested_SDM_Count__c != oldSDRMap.get(sdr.Id).Requested_SDM_Count__c) {
oppIds.add(sdr.Opportunity__c);
}
if(GlobalConstants.Rejected.equalsIgnoreCase(sdr.Sales_Decision_Approval_Status__c) 
&& sdr.Sales_Decision_Approval_Status__c != oldSDRMap.get(sdr.Id).Sales_Decision_Approval_Status__c) {
oppIds.add(sdr.Opportunity__c);
}
}
if(!oppIds.isEmpty()) {
Approval.unlock(oppIds); //unlock opps
}
}catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, 
GlobalConstants.unlockSDROppProposal, GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));}
}*/
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 10-04-2020
* @param: U-1668
* @description: This method is called when Sales Decision Approval Status = 'Approved'
*****************************************************************/
    public static void CheckSDRIsReadyForNextStage(Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap , Map<ID, Sales_Decision_Record__c> newSalesDecisionMap)
    {
        try {
            Set<id> salesDecisionApprovedIdset = new Set<id>();
            Boolean isReady=false;
            List<Sales_Decision_Record__c> sdrErrorList = new List<Sales_Decision_Record__c>();
            for(Sales_Decision_Record__c salesDecision : newSalesDecisionMap.values())
            {
                if(salesDecision.Sales_Decision_Approval_Status__c != oldSalesDecisionMap.get(salesDecision.id).Sales_Decision_Approval_Status__c
                   && salesDecision.Sales_Decision_Approval_Status__c == GlobalConstants.APPROVED && salesDecision.Sales_Decision_Type__c!=GlobalConstants.Other)
                {
                    salesDecisionApprovedIdset.add(salesDecision.id);
                }
            }
            if(!salesDecisionApprovedIdset.isEmpty())
            {
                for(Sales_Decision_Record__c sdrList : [SELECT id,Sales_Decision_Type__c, Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c, Opportunity__r.Not_Deviating_from_Parent__c, 
                                                        Opportunity__r.Is_ready_for_progression__c, Opportunity__r.High_Impact_Deal__c, 
                                                        Opportunity__r.Opportunity_Progression_Type__c,Opportunity__r.Opportunity_Tier__c , 
                                                        (SELECT ID,Approver_Role__c,Notification__c FROM Sales_Decision_Makers__r WHERE Approver_Name__c!=null)
                                                        FROM Sales_Decision_Record__c WHERE id IN :salesDecisionApprovedIdset
                                                        Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    isReady=SalesDecisionRecordUtility.readyForNextStage(sdrList.Opportunity__r.High_Impact_Deal__c, 
                                                                         sdrList.Opportunity__r.Opportunity_Progression_Type__c, sdrList.Opportunity__r.Opportunity_Tier__c, 
                                                                         sdrList.Opportunity__r.Not_Deviating_from_Parent__c, sdrList.Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c, 
                                                                         sdrList, sdrList.Sales_Decision_Makers__r);
                    if(!isReady) {
                        sdrErrorList.add(newSalesDecisionMap.get(sdrList.id));
                    }                                          
                }
            }
            if(!sdrErrorList.isEmpty()){
                for(Sales_Decision_Record__c sdr : sdrErrorList)
                {
                    sdr.addError(GlobalConstants.CheckSDRIsReadyForNextStageError); 
                }
            }
            
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, GlobalConstants.CheckSDRIsReadyForNextStage, 
                                                                       GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Ankit Jain
* @date: 15-04-2020
* @param: oldSalesDecisionMap,newSalesDecisionMap
* @description: This method will update Latest Approved SDP Stage on Opportunity when a Sales Decision Record is Approved(U-1737 & U-1733)
*****************************************************************/
    public static void updateApprovedSDPStage(Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap , Map<ID, Sales_Decision_Record__c> newSalesDecisionMap){
        try {
            Set<Sales_Decision_Record__c> salesDecisionset = new Set<Sales_Decision_Record__c>();
            Map<id,id> salesDecisionApprovedMap=new Map<id,id>();
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            for(Sales_Decision_Record__c salesDecision : newSalesDecisionMap.values())
            {
                if(salesDecision.Sales_Decision_Approval_Status__c != oldSalesDecisionMap.get(salesDecision.id).Sales_Decision_Approval_Status__c
                   && salesDecision.Sales_Decision_Approval_Status__c == GlobalConstants.APPROVED && salesDecision.Sales_Decision_Type__c!=GlobalConstants.Other && salesDecision.Sales_Decision_Type__c!=GlobalConstants.SDP0Qualify)
                {
                    salesDecisionApprovedMap.put(salesDecision.id,salesDecision.Opportunity__c);
                    salesDecisionset.add(salesDecision);
                }
            }
            if(!salesDecisionApprovedMap.isEmpty())
            {
                Map<id,Opportunity> opptyMap = new Map<id,Opportunity>([select id, Approved_SDP_Stage__c from Opportunity where id in: salesDecisionApprovedMap.values() Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                for(Sales_Decision_Record__c salesDecision : salesDecisionset)
                {
                    Opportunity opp=opptyMap.get(salesDecisionApprovedMap.get(salesDecision.id));
                    opp.Approved_SDP_Stage__c = salesDecision.Sales_Decision_Type__c;
                    opp.LatestApprovedSDR__c=salesDecision.id;
                    if(opp.Approved_SDP_Stage__c.equalsIgnoreCase(GlobalConstants.SDP3SignContract)
                       || opp.Approved_SDP_Stage__c.equalsIgnoreCase(GlobalConstants.ConfirmGCUChild))
                    {
                        opp.Approved_Stage__c = GlobalConstants.Negotiate_and_Close;
                        opp.Approved_for_closed_won__c = true;
                    }
                    oppToUpdateList.add(opptyMap.get(salesDecisionApprovedMap.get(salesDecision.id)));
                }
            }
            if(!oppToUpdateList.isEmpty()){
                database.update(oppToUpdateList,false);
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisionRecordTriggerHelper, GlobalConstants.updateApprovedSDPStageMethod, 
                                                                       GlobalConstants.SalesDecisionRecordTriggerHelper, true, e)));
        }
    }
}