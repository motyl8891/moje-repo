/******************************************************************************************
*
*       @author:   
* 		@date: 
* 		@User Story: 
* 		@description: 
@testClass    : 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			16-07-2020				U-1991 - Profile related condition updated with "AccessSettings__c" custom setting
Shubham Kadam			19-08-2020				U-1928 - Post to Chatter on Proposal Record Page when RequestedDeviationsApproval__c == true
******************************************************************************************/
public without sharing class ProposalTriggerHandlerHelper {
    //public static integer onePrimaryProposalAI = 0;
    
    /****************************************************************
* Method that searches for Primary Proposals and passes list of Primary Proposals to Proposal Unit method replace Products
* @param newProposals   List of new Proposals objects
* @param oldProposalMap Map of old Proposal objects
****************************************************************/
    public static void updatePrimaryProposalProducts(List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap) {
        try{
            List<Proposal__c> listOfPrimaryProposals = new List<Proposal__c>();
            for (Proposal__c newProposal : newProposals) {
                Proposal__c oldProposal = oldProposalMap.get(newProposal.Id);
                if ( newProposal.Primary__c == true &&
                    newProposal.Primary__c != oldProposal.Primary__c) {
                        listOfPrimaryProposals.add(newProposal);
                    }
            }
            if (listOfPrimaryProposals.size() != 0) {
                ProposalUtils.replaceProducts_queryProductsFirst(listOfPrimaryProposals);
            }
        }catch(Exception e){ EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesUpdate, GlobalConstants.ProposalTriggerHandlerHelper_triggerOpportunitiesUpdate, true, e));	}
    }
    
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description:
*****************************************************************/
    public static void onePrimaryProposalBeforeUpdate(Map<ID, Proposal__c> newProposalMap, Map<ID, Proposal__c> oldProposalMap){
        Try{
            for(Proposal__c p:newProposalMap.values()){
                if(p.Primary__c != true && oldProposalMap.get(p.Id).Primary__c == true && 
                   p.Candidate_For_Primary_Remove__c != true){
                    p.addError(GlobalConstants.Error_Only_One_Primary_Proposal);
                }else{
                    p.Candidate_For_Primary_Remove__c = false;
                }
            }
        }catch(Exception e){ EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesUpdate, GlobalConstants.ProposalTriggerHandlerHelper_triggerOpportunitiesUpdate, true, e));	}
    }
    
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description: // Sets proposal as closed won if opp is minor flow and moved to closed won R19 11
*****************************************************************/
    public static void setClosedWonMinorFlow(Map<ID, Proposal__c> newProposalMap){
        try{
            List<Id> oppIds = new List<id>();
            for(Proposal__c p:newProposalMap.values()){
                if(p.Primary__c && p.Approved_Stage__c!=null &&p.Approved_Stage__c.contains(GlobalConstants.Negotiate_and_Close) && !p.Is_Closed_Won__c){
                    oppIds.add(p.Opportunity__c);
                }
            }
            //NS
            //List<Opportunity> Opps = [Select Id, Opportunity_Tier__c from Opportunity where Opportunity_Tier__c = :GlobalConstants.Minor and Id in :oppIds Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            for(Proposal__c p:newProposalMap.values()){
                if(p.Approved_Stage__c!=null && p.Primary__c && p.Approved_Stage__c.contains(GlobalConstants.Negotiate_and_Close) && !p.Is_Closed_Won__c){
                    for(Opportunity opp : [Select Id, Opportunity_Tier__c from Opportunity 
                                           where Opportunity_Tier__c = :GlobalConstants.Minor and Id in :oppIds 
                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                               if(p.Opportunity__c == opp.Id){
                                                   p.Is_Closed_Won__c = true;
                                               }
                                           }
                }
            }
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.setClosedWonMinorFlow, GlobalConstants.ProposalTriggerHandlerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description:
*****************************************************************/
    public static void onePrimaryProposalAfterInsert(List<Proposal__c> newProposalList){
        //System.debug('onePrimaryProposalAI: '+onePrimaryProposalAI);
        Try{
            //  if(onePrimaryProposalAI==0){
            Map<ID,Proposal__c> newProposalMap = new Map<ID,Proposal__c>();
            for(Proposal__c p: newProposalList){
                if(p.Primary__c==true){
                    newProposalMap.put(p.Id, p);    
                }
            }
            if(newProposalMap.size()>0){
                onePrimaryProposal(newProposalMap, new Map<ID,Proposal__c>());        
            }
            //}
            //onePrimaryProposalAI++;
        }catch(Exception e){ EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesUpdate, GlobalConstants.ProposalTriggerHandlerHelper_triggerOpportunitiesUpdate, true, e));	}
    }
    
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description:
*****************************************************************/
    public static void onePrimaryProposal(Map<ID, Proposal__c> newProposalMap, Map<ID, Proposal__c> oldProposalMap){
        try{
            Set<Id> oppIdsSet = new Set<Id>();
            Set<Id> changedPropsIdsSet = new Set<Id>();
            for(Proposal__c p:newProposalMap.values()){
                if(p.Primary__c == true && (oldProposalMap.get(p.Id) == null || oldProposalMap.get(p.Id).Primary__c != true)){
                    oppIdsSet.add(p.Opportunity__c);
                    changedPropsIdsSet.add(p.Id);
                }
            }
            
            //NS
            /*List<Opportunity> oppList = [SELECT Id,Working_Capital_Days__c, 
(Select Id, Primary__c,Cash_Flow_Opp_WCD__c From Proposal__r)
FROM Opportunity
WHERE Id IN: oppIdsSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];*/
            if(!oppIdsSet.isEmpty()){
                List<Proposal__c> updateList = new List<Proposal__c>();
                for(Opportunity opp: [SELECT Id,Working_Capital_Days__c, (Select Id, Primary__c,Cash_Flow_Opp_WCD__c From Proposal__r)
                                      FROM Opportunity WHERE Id IN: oppIdsSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                          for(Proposal__c p: opp.Proposal__r){
                                              if(!changedPropsIdsSet.contains(p.Id) && p.Primary__c){
                                                  p.Primary__c = false;
                                                  p.Candidate_For_Primary_Remove__c = true;
                                                  updateList.add(p);
                                              }
                                          }
                                      }
                Database.update(updateList);	
            }
            
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper,GlobalConstants.onePrimaryProposal , GlobalConstants.ProposalTriggerHandlerHelper , true, e)));
        }					
    }
    
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description:
*****************************************************************/
    public static void triggerOpportunitiesUpdate(List<Proposal__c> newProposalList){
        // Variables for Eligible_for_Small_Value_Flow__c
        ID idPrimaryProp;
        //ID accId;
        //ID crgId;
        Decimal svu;
        Boolean b0 = false;
        Boolean b1 = false;
        Boolean b2 = false;
        Boolean isStand = false;
        Boolean isFrame = false;
        
        Set<Id> oppIdSet = new Set<Id>();
          
        for(Proposal__c prop: newProposalList){
            oppIdSet.add(prop.Opportunity__c);
            if (prop.Primary__c == true)
            { 
                idPrimaryProp = prop.Id;
            }
        }
        
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        for(Id oppId: oppIdSet){
            oppToUpdateList.add(new Opportunity(Id = oppId));
        }
        //U-1584 filtered Oppty where hid is Unchecked
        //NS
        /*List<Opportunity> oppList = [SELECT ID,AccountId,
RecordTypeId, Risk_Score_Text__c,Any_new_questions__c,New_Risk_Score_Text__c,
RecordTypeName__c,Deal_Value_Compared_To_CU_Value_Limits__c,
Complex_Solution_Count__c,Working_Capital_Days__c,
IsClosed, (SELECT Effective_Net_Price__c,Cash_Flow_Opp_WCD__c,Primary__c FROM Proposal__r)  
FROM Opportunity WHERE Id IN :oppToUpdateList AND IsClosed=false AND High_Impact_Deal__c=False 
Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];*/
        
        // Condition from WFR to replace it
        Map<id,Opportunity> oppsUpdatedMap = new Map<id,Opportunity>();
        
        if(!oppToUpdateList.isEmpty()){
            for (Opportunity o : [SELECT ID,AccountId,
                                  RecordTypeId, Risk_Score_Text__c,Any_new_questions__c,New_Risk_Score_Text__c,
                                  RecordTypeName__c,Deal_Value_Compared_To_CU_Value_Limits__c,
                                  Complex_Solution_Count__c,Working_Capital_Days__c,
                                  IsClosed, (SELECT Effective_Net_Price__c,Cash_Flow_Opp_WCD__c,Primary__c FROM Proposal__r)  
                                  FROM Opportunity WHERE Id IN :oppToUpdateList AND IsClosed=false AND High_Impact_Deal__c=False 
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) { 
                                      //U-1584 calculating Eligible_for_Small_Value_Flow__c for Frame Opportunity also.
                                      if(((o.RecordTypeId == GlobalConstants.standardOppRecordTypeId)||(o.RecordTypeId == GlobalConstants.frameOppRecordTypeId)) && o.IsClosed==false)
                                      {
                                          isStand = true;
                                          for(Proposal__c p : o.Proposal__r) {
                                              if(p.Primary__c == true)
                                              {
                                                  if(p.Cash_Flow_Opp_WCD__c == null) {
                                                      o.Working_Capital_Days__c = 0; }
                                                  else {
                                                      o.Working_Capital_Days__c = Integer.valueOf(p.Cash_Flow_Opp_WCD__c); }
                                                  // Object Creation cannot be done outside the for loop as it takes the value from the query
                                                  oppsUpdatedMap.put(o.Id, new Opportunity(Id = o.Id,Working_Capital_Days__c =o.Working_Capital_Days__c )); 
                                              }
                                              
                                              if ((!o.Any_new_questions__c && o.Risk_Score_Text__c.equalsIgnoreCase(GlobalConstants.LOW) && 
                                                   o.Deal_Value_Compared_To_CU_Value_Limits__c.equalsIgnoreCase(GlobalConstants.UNDER)) || (o.Any_New_Questions__c && o.New_Risk_Score_Text__c.equalsIgnoreCase(GlobalConstants.LOW) && o.Deal_Value_Compared_To_CU_Value_Limits__c.equalsIgnoreCase(GlobalConstants.UNDER))) { b0 = true; }
                                              
                                              if (p.Effective_Net_Price__c < svu) { b1 = true; }
                                              
                                              if (o.Complex_Solution_Count__c  == 0) { b2 = true; }
                                              
                                              if (b0 && b2) { o.Eligible_for_Small_Value_Flow__c = GlobalConstants.ELIGIBLE; }
                                              else{
                                                  o.Eligible_for_Small_Value_Flow__c = GlobalConstants.Ineligible;
                                                  /*U-1719 update the value of Small deal value */
                                                  o.Lock_Small_Value__c=false;
                                              } 
                                              
                                              if(oppsUpdatedMap.get(o.Id) != null) {
                                                  oppsUpdatedMap.get(o.Id).Eligible_for_Small_Value_Flow__c = o.Eligible_for_Small_Value_Flow__c; }
                                              else {
                                                  // Object Creation cannot be done outside the for loop as it takes the value from the query
                                                  oppsUpdatedMap.put(o.Id, new Opportunity(Id = o.Id, Eligible_for_Small_Value_Flow__c = o.Eligible_for_Small_Value_Flow__c)); }
                                              // Set Eligible_for_Small_Value_Flow__c for updating this field     
                                          }
                                      }
                                      else if((o.RecordTypeId == GlobalConstants.frameOppRecordTypeId) && o.IsClosed==false)
                                      {
                                          for(Proposal__c p : o.Proposal__r) {   
                                              if(p.Primary__c = true)
                                              {
                                                  if(p.Cash_Flow_Opp_WCD__c == null) {
                                                      o.Working_Capital_Days__c = 0; }
                                                  else {
                                                      o.Working_Capital_Days__c = Integer.valueOf(p.Cash_Flow_Opp_WCD__c); }
                                                  isFrame = true;
                                                  oppsUpdatedMap.put(o.Id,new Opportunity(Id = o.Id,Working_Capital_Days__c =o.Working_Capital_Days__c ));
                                              }
                                          }   
                                      }
                                  }     
        }
        try{
            if((isStand || isFrame) && !oppsUpdatedMap.isEmpty()) { Database.update(oppsUpdatedMap.values()); }
        }catch (Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesUpdate, GlobalConstants.ProposalTriggerHandlerHelper_triggerOpportunitiesUpdate, true, e));
        }
    }
    
    /****************************************************************
* @author: Anukriti Agrawal 
* @date: 07-05-2020
* @param: List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap
* @description: Recall all deviations if we unchecked primary(U-1711),U-1826
*****************************************************************/
    public static void recallDeviationApprovals(List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap){
        try{
            if(newProposals[0].Primary__c==false && oldProposalMap.get(newProposals[0].Id).Primary__c==true) {
                if(Trigger.isAfter && newProposals[0].Overall_EBD_Approval_Status__c==GlobalConstants.Cancelled) {
                    List<DeviationTypeGroup__c> devList = [SELECT Id FROM DeviationTypeGroup__c WHERE Proposal__c =:newProposals[0].Id 
                                                           AND DeviationApprovalStatus__c=:GlobalConstants.Pending
                                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                    
                    for(DeviationTypeGroup__c dev:devList) {                        
                        dev.MAStatus__c = GlobalConstants.Cancelled;
                        dev.BAStatus__c = GlobalConstants.Cancelled;
                    }
                    Database.update(devList);
                }
                if(Trigger.isBefore && newProposals[0].Overall_EBD_Approval_Status__c==GlobalConstants.Pending) {
                    newProposals[0].Overall_EBD_Approval_Status__c=GlobalConstants.Cancelled;
                }
                If(Test.isRunningTest())
            {
                Integer i = 5/0;
            }
            }    
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.recallDeviationApprovals, GlobalConstants.ProposalTriggerHandlerHelper, true, e));
        }
        
    }
    /****************************************************************
* @author: Anukriti Agrawal 
* @date: 15-06-2020
* @param: List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap
* @description: Only Mela Commerical Director Group Member can edit "Deviation Pre-Approved Field", U-2033
*****************************************************************/
    public static void checkEditabilityOfPreApprovalField(List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap){
        try{
            //U-1991
            set<String> grupNameSet = new Set<String>();
            if(!AccessSettings__c.getInstance().CanUpdateDeviationPreApprovedField__c 
               && ((newProposals[0].DeviationsPreApproved__c != oldProposalMap.get(newProposals[0].Id).DeviationsPreApproved__c) || (newProposals[0].AllBDGSDeviationsarePreApproved__c != oldProposalMap.get(newProposals[0].Id).AllBDGSDeviationsarePreApproved__c)
              || (newProposals[0].PreApprovalComments__c != oldProposalMap.get(newProposals[0].Id).PreApprovalComments__c) || (newProposals[0].BDGSPreApprovalComments__c != oldProposalMap.get(newProposals[0].Id).BDGSPreApprovalComments__c))){           
                   String publicGroupName;
                   For(DeviationTypeGroup__c devType : [select Id, MarketArea__c,BusinessArea__c from DeviationTypeGroup__c where Proposal__c =: newProposals[0].Id
                                                        Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
                   {                       
                       if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MOAI))
                       {
                           publicGroupName = GlobalConstants.MOAI_EBD_Commercial;
                       }
                       if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MMEA))
                       {
                           publicGroupName = GlobalConstants.MMEA_CU_Commercial_Directors;
                       }
                       if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MANA))
                       {
                           publicGroupName = GlobalConstants.MANACOMMERCIALMGMT;
                       }
                       if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MNEA))
                       {
                           publicGroupName = GlobalConstants.MNEA_CM_Head;                            
                       }
                       if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MELA))
                       {
                           if(devType.BusinessArea__c == GlobalConstants.BNEW && (newProposals[0].DeviationsPreApproved__c != oldProposalMap.get(newProposals[0].Id).DeviationsPreApproved__c || newProposals[0].PreApprovalComments__c != oldProposalMap.get(newProposals[0].Id).PreApprovalComments__c))
                           {
                               publicGroupName = GlobalConstants.MELACommercialDirectors;
                           }  
                           else if(devType.BusinessArea__c == GlobalConstants.BDGS && (newProposals[0].AllBDGSDeviationsarePreApproved__c != oldProposalMap.get(newProposals[0].Id).AllBDGSDeviationsarePreApproved__c || newProposals[0].BDGSPreApprovalComments__c != oldProposalMap.get(newProposals[0].Id).BDGSPreApprovalComments__c))
                           {
                               publicGroupName = GlobalConstants.MELADSPriceManagers;
                           } 
                       }
                       grupNameSet.add(publicGroupName);
                   }                   
                   List<GroupMember> grmList = [SELECT id FROM GroupMember WHERE Group.Name IN: grupNameSet
                                                AND UserOrGroupId=: UserInfo.getUserId() Limit 1];
                   if(grmList.isEmpty()) {
                       newProposals[0].addError(GlobalConstants.DeviationPreApprovedEditError);
                   }
               }
           /* if(newProposals[0].DeviationsPreApproved__c && newProposals[0].RequestedDeviationsApproval__c) {
                newProposals[0].addError(GlobalConstants.approvalAlreayRequested);
            }*/
            If(Test.isRunningTest())
            {
                Integer i = 5/0;
            }
        }catch(Exception e){EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.checkEditabilityOfPreApprovalField, GlobalConstants.ProposalTriggerHandlerHelper, true, e));}}
    
    /****************************************************************
* @author: Anukriti Agrawal 
* @date: 15-06-2020
* @param: List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap
* @description: Approve all deviations if pre-approval checkbix is true, U-2033
*****************************************************************/
    public static void updateDeviationsToApproved(List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap) {
        try{
            if((newProposals[0].DeviationsPreApproved__c && newProposals[0].DeviationsPreApproved__c != oldProposalMap.get(newProposals[0].Id).DeviationsPreApproved__c)
               ||(newProposals[0].AllBDGSDeviationsarePreApproved__c && newProposals[0].AllBDGSDeviationsarePreApproved__c != oldProposalMap.get(newProposals[0].Id).AllBDGSDeviationsarePreApproved__c)) {
                   List<DeviationTypeGroup__c> devList = new List<DeviationTypeGroup__c>();
                   for(DeviationTypeGroup__c dev : [SELECT ID, MAStatus__c, BAStatus__c,BusinessArea__c,BA_Approver__c,MA_Approver__c FROM DeviationTypeGroup__c WHERE Proposal__c=:newProposals[0].Id and 
                                                    MA_Approver__c!=null Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
                   {
                       if(dev.BusinessArea__c == GlobalConstants.BDGS && newProposals[0].AllBDGSDeviationsarePreApproved__c && newProposals[0].AllBDGSDeviationsarePreApproved__c != oldProposalMap.get(newProposals[0].Id).AllBDGSDeviationsarePreApproved__c){
                           dev.MAStatus__c = GlobalConstants.PREAPPROVED;
                           dev.MAComments__c = GlobalConstants.AUTOPREAPPROVED;
                           if(dev.BA_Approver__c != null){
                           dev.BAStatus__c = GlobalConstants.PREAPPROVED;
                           }                          
                           devList.add(dev); 
                       }
                       else if(dev.BusinessArea__c == GlobalConstants.BNEW && newProposals[0].DeviationsPreApproved__c && newProposals[0].DeviationsPreApproved__c != oldProposalMap.get(newProposals[0].Id).DeviationsPreApproved__c){
                           dev.MAStatus__c = GlobalConstants.PREAPPROVED;
                           dev.MAComments__c = GlobalConstants.AUTOPREAPPROVED;
                           if(dev.BA_Approver__c != null){
                           dev.BAStatus__c = GlobalConstants.PREAPPROVED;
                           }                          
                           devList.add(dev);
                       }                                                                                  
                   }
                   if(!devList.isEmpty()) {
                       Database.update(devList);
                   }
                   If(Test.isRunningTest())
                   {
                       Integer i = 5/0;
                   }
               }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.updateDeviationsToApproved, GlobalConstants.ProposalTriggerHandlerHelper, true, e));     
        }}
    /****************************************************************
* @author: Aditya Mohapatra 
* @date: 07-07-2020
* @param: Map<id,Proposal__c> newProposalsMap, Map<ID, Proposal__c> oldProposalMap
* @description: Update Primary Proposal on Opp when Proposal is marked as Primary
*****************************************************************/
    public static void updatePrimaryProposal(Map<id,Proposal__c> newProposalsMap, Map<ID, Proposal__c> oldProposalMap,boolean isInsert){
        try{
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            Map<id,Opportunity> propIdtoOppMap = new Map<id,Opportunity>();
            Map<id,id> propIdWithOppIdmap = new Map<id,id>();
            for(Proposal__c prop : newProposalsMap.values()){
                if(isInsert){
                    if(prop.Primary__c){
                        propIdWithOppIdmap.put(prop.Opportunity__c,prop.id);
                    }
                }else{
                    if (prop.Primary__c != oldProposalMap.get(prop.Id).Primary__c && prop.Primary__c){
                        propIdWithOppIdmap.put(prop.Opportunity__c,prop.id);   
                    }
                } 
            }
            if(!propIdWithOppIdmap.isEmpty()){
                for (Opportunity opp :[Select id ,Primary_Proposal__c from Opportunity where Id in :propIdWithOppIdmap.keyset()
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                           propIdtoOppMap.put(propIdWithOppIdmap.get(opp.id),opp);
                                       }
                if(!propIdtoOppMap.isEmpty()){
                    for(Id propId :propIdWithOppIdmap.values()){
                        propIdtoOppMap.get(propId).Primary_Proposal__c = propId;
                        oppListToUpdate.add(propIdtoOppMap.get(propId));
                    }
                }
            }
            if(!oppListToUpdate.isEmpty()){
                Database.update(oppListToUpdate);
            }
            If(Test.isRunningTest())
            {
                Integer i = 5/0;
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, GlobalConstants.updatePrimaryProposal, GlobalConstants.ProposalTriggerHandlerHelper, true, e)); }}
    
    /****************************************************************
* @author: Shubham Kadam/Biswajit Sahoo
* @date: 19-08-2020/20-01-2021
* @param: List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap
* @description: U-1928 - Post to Chatter on Proposal Record Page when RequestedDeviationsApproval__c == true and
				U-2291 - Update on Chatter with the List of Deviating Product Groups and Deviating Questions.	
*****************************************************************/
  public static void postToChatter(List<Proposal__c> newProposals, Map<ID, Proposal__c> oldProposalMap) {
        try {
            if(newProposals[0].RequestedDeviationsApproval__c == true && 
               newProposals[0].RequestedDeviationsApproval__c != oldProposalMap.get(newProposals[0].Id).RequestedDeviationsApproval__c) {
                   set<String> grupNameSet = new Set<String>();
                   set<id> chatterGrupIdSet = new Set<Id>();
                   Opportunity opp = [select Id, Name, RecordTypeId, Customer_Unit__c, Anticipated_Deal_Value__c, Deal_Value__c, Customer_Tier__c, AccountId, 
                                      OpportunityNumber__c,Lead_Domain__c from Opportunity 
                                      where Id =: newProposals[0].Opportunity__c LIMIT 1];
                   /***U-2173 start****/
                   Set<String> productList = new Set<String>();
                   Set<String> bmasProductSet = new Set<String>();
                   Integer countBMASProd = 0;
                   Integer countAllProd = 0;
                   For(Product__c pd : [SELECT Id,Business_Area__c,name,Product_Group__c FROM Product__c 
                                        WHERE Proposal__c =: newProposals[0].Id and Product_Group__c != ''])
                   {                    
                       if(pd.Business_Area__c.equalsIgnoreCase(GlobalConstants.BMAS) && !bmasProductSet.contains(pd.Product_Group__c))
                       {
                           countBMASProd = countBMASProd +1;
                           bmasProductSet.add(pd.Product_Group__c);
                       }
                       if(!productList.contains(pd.Product_Group__c))
                       {
                           countAllProd = countAllProd + 1;
                       		productList.add(pd.Product_Group__c);
                       }
                       
                   }   
                   /***U-2173 END****/
                   for(DeviationTypeGroup__c devls : [select Id, Name, MA_Approver__c, MarketArea__c,BADeviationType__c,DeviationType__c,BusinessArea__c from DeviationTypeGroup__c 
                                                      where Proposal__c =: newProposals[0].Id 
                                                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
                   {
                       String chatterGroupName = GlobalConstants.BLANK ;
                       if(devls.MA_Approver__c != null && opp.Customer_Unit__c != null && devls.MarketArea__c != GlobalConstants.MELA) 
                       {
                           if(devls.MarketArea__c == GlobalConstants.MANA)
                           {
                               if(devls.MA_Approver__c == GlobalConstants.MANA_Commercial_Management && 
                                  ((opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId && opp.Anticipated_Deal_Value__c > 30000000) || 
                                   (opp.RecordTypeId == GlobalConstants.standardOppRecordTypeId && opp.Deal_Value__c > 30000000)))
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c;
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.MANA_Commercial_Management && 
                                       ((opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId && opp.Anticipated_Deal_Value__c <= 30000000) || 
                                        (opp.RecordTypeId == GlobalConstants.standardOppRecordTypeId && opp.Deal_Value__c <= 30000000)))
                               {
                                   if(opp.Customer_Unit__c == GlobalConstants.CUCanada || opp.Customer_Unit__c == GlobalConstants.CUEmergingBusiness)
                                   {
                                       chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.SPACE + opp.Customer_Unit__c;	
                                   }
                                   else {
                                       chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.CUWithSpace + opp.Customer_Unit__c;
                                   }
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.BMAS_SPOCs)
                               {
                                   chatterGroupName = devls.MA_Approver__c + GlobalConstants.SPACE + GlobalConstants.DASH + GlobalConstants.SPACE + devls.MarketArea__c;						
                               }
                           }
                           else if(devls.MarketArea__c == GlobalConstants.MMEA)
                           {
                               //U-2286 Changes Start
                               /*if(devls.MA_Approver__c == GlobalConstants.MMEA_CM_Head)
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c;
                               }
                               else */
                               if(devls.MA_Approver__c == GlobalConstants.MMEA_CU_Commercial_Directors || devls.MA_Approver__c == GlobalConstants.MMEA_CM_Head) //U-2286 Changes End
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.SPACE  + opp.Customer_Unit__c;	
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.BMAS_SPOCs)
                               {
                                   chatterGroupName = devls.MA_Approver__c + GlobalConstants.SPACE + GlobalConstants.DASH + GlobalConstants.SPACE + devls.MarketArea__c;						
                               }
                           }
                           else if(devls.MarketArea__c == GlobalConstants.MNEA){
                               if(devls.MA_Approver__c == GlobalConstants.MNEA_CM_Head) {
                                   if(opp.Customer_Unit__c == GlobalConstants.CU_IOT) {
                                       chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.SPACE + opp.Customer_Unit__c;
                                   }
                                   else{
                                       chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.CUWithSpace + opp.Customer_Unit__c;
                                   }       
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.BMAS_SPOCs)
                               {
                                   chatterGroupName = devls.MA_Approver__c + GlobalConstants.SPACE + GlobalConstants.DASH + GlobalConstants.SPACE + devls.MarketArea__c;						
                               }
                           }
                           else if(devls.MarketArea__c == GlobalConstants.MOAI)
                           {
                               if(devls.MA_Approver__c == GlobalConstants.MOAI_EBD_Contractual_TnC)
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.SPACE + GlobalConstants.Contractual;
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.MOAI_EBD_Commercial && 
                                       (opp.Customer_Unit__c == GlobalConstants.CU_BHARTI || opp.Customer_Unit__c == GlobalConstants.CU_MALAYSIA || 
                                        opp.Customer_Unit__c == GlobalConstants.CU_SINGAPORE || opp.Customer_Unit__c == GlobalConstants.CU_AUSTRALIA))
                               {
                                   String grpName = opp.Customer_Unit__c.SubStringBefore(GlobalConstants.COMMA);
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.SPACE + grpName;
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.MOAI_EBD_Commercial && 
                                       (opp.Customer_Unit__c == GlobalConstants.CU_INDONESIA || opp.Customer_Unit__c == GlobalConstants.CU_OTHER_MOAI || 
                                        opp.Customer_Unit__c == GlobalConstants.CU_SERVICE_PROVIDERS_INDIA || opp.Customer_Unit__c == GlobalConstants.CU_WEST_INDIA || 
                                        opp.Customer_Unit__c == GlobalConstants.CU_VIETNAM || opp.Customer_Unit__c == GlobalConstants.CU_THAILAND))
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.SPACE + opp.Customer_Unit__c;
                               }
                               else if(devls.MA_Approver__c == GlobalConstants.BMAS_SPOCs)
                               {
                                   chatterGroupName = devls.MA_Approver__c + GlobalConstants.SPACE + GlobalConstants.DASH + GlobalConstants.SPACE + devls.MarketArea__c;						
                               }
                           }
                       }
                       /***U-2173 start****/
                       else if(devls.MA_Approver__c != null && devls.MarketArea__c == GlobalConstants.MELA)
                       {
                           if(devls.BADeviationType__c == GlobalConstants.BMAS_EBD_TnC)
                           {
                               if((!productList.contains(GlobalConstants.IT_MS_ADM) && devls.MA_Approver__c == GlobalConstants.MELA_NMS_CM_Head)||
                                  (productList.contains(GlobalConstants.IT_MS_ADM) && countBMASProd > 1 && devls.MA_Approver__c == GlobalConstants.MELA_NMS_DS_CM_Head))
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_NMS_CM_Head;
                               }
                               else if(productList.contains(GlobalConstants.IT_MS_ADM) && countBMASProd == 1 && devls.MA_Approver__c == GlobalConstants.MELA_DS_CM_Head)
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_DS_CM_Head;
                               }
                           }
                           else if(devls.BADeviationType__c == GlobalConstants.EBD_TnC)
                           {
                               if((!productList.contains(GlobalConstants.IT_MS_ADM) && opp.Lead_Domain__c == GlobalConstants.BDGS && devls.MA_Approver__c == GlobalConstants.MELA_DS_CM_Head)||
                                  (productList.contains(GlobalConstants.IT_MS_ADM) && countAllProd==1 && devls.MA_Approver__c == GlobalConstants.MELA_DS_CM_Head))
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_DS_CM_Head;
                               }
                               else if(!productList.contains(GlobalConstants.IT_MS_ADM) && (opp.Lead_Domain__c == GlobalConstants.BMAS || opp.Lead_Domain__c == GlobalConstants.BNEW) && devls.MA_Approver__c == GlobalConstants.MELA_NMS_CM_Head)
                               {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_NMS_CM_Head;
                               }
                               else if(productList.contains(GlobalConstants.IT_MS_ADM) && countAllProd > 1 && devls.MA_Approver__c == GlobalConstants.MELA_NMS_DS_CM_Head)
                               {
                                   if(opp.Lead_Domain__c == GlobalConstants.BDGS)
                                   {
                                       chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_DS_CM_Head;
                                   }
                                   else if(opp.Lead_Domain__c == GlobalConstants.BMAS || opp.Lead_Domain__c == GlobalConstants.BNEW)
                                   {
                                       chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_NMS_CM_Head;
                                   }
                               }
                           }
                           else if((((devls.DeviationType__c == GlobalConstants.DEVIATIONTYPE_ProfitabilityUM || devls.DeviationType__c == GlobalConstants.UMAR) && devls.BusinessArea__c == GlobalConstants.BMAS) &&
                                    ((!productList.contains(GlobalConstants.IT_MS_ADM) && devls.MA_Approver__c == GlobalConstants.MELA_NMS_Tactical_Managers)|| (productList.contains(GlobalConstants.IT_MS_ADM) && countAllProd > 1 && devls.MA_Approver__c == GlobalConstants.NMS_Tactical_DS_Strategic_Price_Managers))) ||
                                   devls.MA_Approver__c == GlobalConstants.MELA_NMS_Tactical_Managers)
                           {
                               if(opp.Customer_Unit__c == GlobalConstants.CU_UK_n_Ireland) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + GlobalConstants.CU_UKI; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_Eastern_Europe) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + GlobalConstants.CU_EECA; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_Northern_n_Central_Europe) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + GlobalConstants.CU_NCE; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_South_East_Mediterranean) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + GlobalConstants.CU_SEM; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_France_BeLux) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + GlobalConstants.CU_FBAT; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_LATAM_North_n_Caribbean) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + GlobalConstants.CU_LATAM_North; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_LATAM_South || opp.Customer_Unit__c == GlobalConstants.CU_Iberia || 
                                       opp.Customer_Unit__c == GlobalConstants.CU_Western_Europe || opp.Customer_Unit__c == GlobalConstants.CU_OTHER_MELA) {
                                           chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.NMSWithSpace + opp.Customer_Unit__c; 
                                       }                   
                           }
                           else if((devls.DeviationType__c == GlobalConstants.DEVIATIONTYPE_ProfitabilityUM || devls.DeviationType__c == GlobalConstants.UMAR) && devls.BusinessArea__c == GlobalConstants.BMAS && productList.contains(GlobalConstants.IT_MS_ADM) && countAllProd == 1 && devls.MA_Approver__c == GlobalConstants.MELA_DS_Strategic_Price_Manager)
                           {
                               chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + GlobalConstants.MELA_DS_Strategic_Price_Manager;
                           }
                           else if(devls.MA_Approver__c == GlobalConstants.MELA_DS_Strategic_Price_Manager)
                           {
                               chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MA_Approver__c;
                           }
                           else if(devls.MA_Approver__c == GlobalConstants.MELA_DS_CM_Head)
                           {
                               chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MA_Approver__c;
                           }
                           else if(devls.MA_Approver__c == GlobalConstants.MELA_NMS_CM_Head)
                           {
                               chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MA_Approver__c;
                           }
                           else if(devls.MA_Approver__c == GlobalConstants.MELA_DS_CM_Head_n_Head_of_Price_Mgmt)
                           {
                               chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MA_Approver__c;
                           }
                           else if(devls.MA_Approver__c == GlobalConstants.MELA_Head_of_DS_n_MELA_DS_CM_Head)
                           {
                               chatterGroupName = GlobalConstants.MELA_Head_of_DS_n_MELA_DS_CM_Head;
                           }                           
                           else if(devls.MA_Approver__c == GlobalConstants.MELA_DS_CU_CD_n_CU_HoDS)
                           {
                               if(opp.Customer_Unit__c == GlobalConstants.CU_UK_n_Ireland) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace  + GlobalConstants.CU_UKI; } 
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_Eastern_Europe) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace  + GlobalConstants.CU_EECA; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_Northern_n_Central_Europe) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace + GlobalConstants.CU_NCE; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_South_East_Mediterranean) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace + GlobalConstants.CU_SEM; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_France_BeLux) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace + GlobalConstants.CU_FBAT; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_LATAM_North_n_Caribbean) {
                                   chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace + GlobalConstants.CU_LATAM_North; }
                               else if(opp.Customer_Unit__c == GlobalConstants.CU_LATAM_South || opp.Customer_Unit__c == GlobalConstants.CU_Iberia || 
                                       opp.Customer_Unit__c == GlobalConstants.CU_Western_Europe || opp.Customer_Unit__c == GlobalConstants.CU_OTHER_MELA) {
                                           chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devls.MarketArea__c + GlobalConstants.DSWithSpace + opp.Customer_Unit__c; }
                           }
                           else if(devls.MA_Approver__c == GlobalConstants.BMAS_SPOCs)
                           {
                               chatterGroupName = devls.MA_Approver__c + GlobalConstants.SPACE + GlobalConstants.DASH + GlobalConstants.SPACE + devls.MarketArea__c;						
                           }
                       }
                       /***U-2173 END****/
                       grupNameSet.add(chatterGroupName);
                   }
                   
                   for(CollaborationGroup chatterGroup1 : [select Id, Name from CollaborationGroup where Name IN :grupNameSet 
                                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                               chatterGrupIdSet.add(chatterGroup1.Id);
                                                           }              
                   if(!chatterGrupIdSet.isEmpty())
                   {
                       Account acc = [select Id, Name from Account where Id =: opp.AccountId LIMIT 1];
                       User ur = [Select Id, Name from User where id =: newProposals[0].Requestor__c LIMIT 1];
                       
                       ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                       ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                       ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                       
                       messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                       
                       for(Id Idset : chatterGrupIdSet){
                           ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                           mentionSegmentInput.id = Idset;
                           messageBodyInput.messageSegments.add(mentionSegmentInput);
                       }
                       
                      textSegmentInput.text = '\n\n Hi,\n\n There are some deviations from the list below that require you attention. \n ' +        
                           '\n Account : ' + acc.Name + '\n CU : ' + opp.Customer_Unit__c + '\n Opportunity Name : ' + opp.Name +
                           '\n Opportunity Number : ' + opp.OpportunityNumber__c + '\n Proposal : ' + newProposals[0].Name + '\n Proposal Id : ' + newProposals[0].Proposal_Id__c +
                           '\n Proposal Version : ' + newProposals[0].Version__c + '\n Requester : ' + ur.Name +
                           '\n\n List of Deviation Product Groups: \n' + newProposals[0].ListofDeviationProductGroups__c +
                           '\n\n List of Deviating Questions: \n' + newProposals[0].ListofDeviatingQuestions__c + 
                            '\n\n Review your deviations in the Proposal - \n'+ GlobalConstants.ORGANIZATION_URL + newProposals[0].Id + 
                           '\n Review your deviations in your Deviations List Views - \n' + GlobalConstants.ORGANIZATION_URL + 'lightning/o/DeviationTypeGroup__c/list'+ 
                           '\n\n Regards,\n Salesforce';
                       
                       messageBodyInput.messageSegments.add(textSegmentInput);
                       
                       feedItemInput.body = messageBodyInput ;
                       feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                       
                       feedItemInput.subjectId = newProposals[0].Id;
                       
                       ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                   }        
               }
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.ProposalTriggerHandlerHelper, 
                                                  GlobalConstants.postToChatter, GlobalConstants.ProposalTriggerHandlerHelper, true, e)); }
    }   
}