/******************************************************************************************
*      	@author       : Shubham Jagatap
*      	@date         : 8/24/2020
@Class Name   : ABCTriggerHelper
@testClass    : ABCTriggerHelperTest

Modification Log   :
------------------------------------------------------------------------------------------
* Ver         Date                     Developer           User Story    Modification
------------------------------------------------------------------------------------------
* 1.0    					  		 Aditya Mohapatra   			   Initial Version
* 1.1      8/24/2020   			 Shubham Jagatap	 U-1981		   Added methods : updateApprovalStatus, PopulateKamEmail, getAntiBriberyCorruption
* 1.2      9/25/2020   			 Shubham Jagatap	 U-2021		   Nova suite Fixes
******************************************************************************************/

public without sharing class ABCTriggerHelper {
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 
* @User Story:  
* @description:  
*****************************************************************/
    public static void goToApprovalStep1(List<AntiBriberyCorruption__c> newABCList,
                                         Map<ID, AntiBriberyCorruption__c> newABCMap,
                                         Map<ID,AntiBriberyCorruption__c> oldABCMap,boolean isInsert) {
                                             Try{
                                                 List<String> idList = new List<String>();
                                                 List<String> mailToAddresses = new List<String>(); 
                                                 set<id> abcIDSet = new set<id>();
                                                 Map <ID , Opportunity> abcIdWithOpptyMap = new Map <ID , Opportunity>();
                                                 String gpName;
                                                 Id abcId ;
                                                 String oppName;
                                                 list<Approval.ProcessSubmitRequest> submitRequestList = new list<Approval.ProcessSubmitRequest>();
                                                 for(AntiBriberyCorruption__c abc:newABCList) {
                                                     gpName = abc.CustomerUnit__c;
                                                     abcId = abc.Id;
                                                     abcIDSet.add(abc.Opportunity__c);
                                                     if(isInsert || abc.SubmitForApproval__c && abc.SubmitForApproval__c != oldABCMap.get(abc.id).SubmitForApproval__c) {
                                                         Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                                                         req.setComments(GlobalConstants.Submitting_request_for_approval);
                                                         req.setObjectId(abc.Id);  
                                                         group g = [select id,name from group where name=:abc.CustomerUnit__c and Type = 'Regular' Limit 1];
                                                         Id approverId = g.Id;
                                                         req.setNextApproverIds(new Id[] {approverId});
                                                         submitRequestList.add(req);
                                                     }
                                                 }
                                                 Map<ID, Opportunity> abcWithOpptyMap = new Map<ID, Opportunity>();
                                                 if(!abcIDSet.isEmpty()){
                                                 abcWithOpptyMap = new Map<ID, Opportunity>([Select id, ABCApprovalStatus__c from Opportunity where id =: abcIDSet]);
                                                 }
                                                 if(!submitRequestList.isEmpty()){
                                                     Approval.process(submitRequestList);
                                                 }
                                                     
                                                  
                                                 List<Opportunity> updatedOpp = new List<Opportunity>();
                                                 for(AntiBriberyCorruption__c abc:newABCList) {
                                                     opportunity opp = abcWithOpptyMap.get(abc.Opportunity__c);
                                                     if(!oldABCMap.isEmpty() && abc.ApprovalStatus__c != oldABCMap.get(abc.id).ApprovalStatus__c) {
                                                         opp.ABCApprovalStatus__c = abc.ApprovalStatus__c;
                                                         if(abc.ApprovalStatus__c == GlobalConstants.ApprovedforStage2){
                                                             opp.Approved_In_Stage2__c = true;
                                                         }
                                                             if(abc.ApprovalStatus__c == GlobalConstants.ApprovedforStage3){
                                                             opp.Approved_In_Stage3__c = true;
                                                             }
                                                         if(abc.ApprovalStatus__c == GlobalConstants.ApprovedforStage4){
                                                             opp.Approved_In_Stage4__c = true;
                                                         }
                                                         
                                                     }
                                                    updatedOpp.add(opp); 
                                                 }
                                                 if(!updatedOpp.isEmpty())
                                                  Database.update(updatedOpp);
                                             }
                                             catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelper, 
                                                                                                                           GlobalConstants.goToApprovalStep1, GlobalConstants.ABCTriggerHelper, true, e)));}
                                         }
        /****************************************************************
* @author: Aditya Mohapatra
* @date: 
* @User Story:  
* @description:  
*****************************************************************/ 
    public static void updatePartnerAccountFields(List<AntiBriberyCorruption__c> newABCList,  
                                                  Map<ID, AntiBriberyCorruption__c> newABCMap){
                                                      try{
                                                          Set<Id> accIdSet =  new set<Id>();
                                                          for(AntiBriberyCorruption__c abc:newABCList) {
                                                              if(abc.BusinessPartnerAccount__c != null ) {
                                                                  accIdSet.add(abc.BusinessPartnerAccount__c);  
                                                              }
                                                          }
                                                          Account acc = new Account();
                                                          if(!accIdSet.isEmpty())
                                                          {acc =[Select id ,Name,CorrOrAntitrust__c,
                                                                CorrOrAntitrustDescr__c,OwnReqComplDescr__c,
                                                                OwnRequirementsCompliance__c,PublicOfficials__c,
                                                                PublicOfficialsDescribe__c,PublicSanctionList__c,PublicSectInvName__c,
                                                                PublicSectInvQuota__c,PublicSectorInvolved__c,PublSanctListDescr__c
                                                                 from Account where id in :accIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];}
                                                          for (AntiBriberyCorruption__c abc:newABCList) {
                                                              if (!String.isBlank(abc.BusinessPartnerAccount__c) && 
                                                                  !accIdSet.isEmpty()){
                                                                      abc.CorruptionAntitrust2__c = acc.CorrOrAntitrust__c;
                                                                      abc.CorruptionAntitrustDescr2__c = acc.CorrOrAntitrustDescr__c;
                                                                      abc.OwnReqComplianceDesc2__c = acc.OwnReqComplDescr__c;
                                                                      abc.OwnRequirementsCompliance2__c = acc.OwnRequirementsCompliance__c;
                                                                      abc.PublicOfficials2__c = acc.PublicOfficials__c;
                                                                      abc.PublicOfficialsDescribe2__c = acc.PublicOfficialsDescribe__c;
                                                                      abc.PublicSanctionList2__c = acc.PublicSanctionList__c;
                                                                      abc.PublicSectInvName2__c = acc.PublicSectInvName__c;
                                                                      abc.PublicSectInvQuota2__c = acc.PublicSectInvQuota__c;
                                                                      abc.PublicSectorInvolved2__c = acc.PublicSectorInvolved__c;
                                                                      abc.PublSanctListDescr2__c = acc.PublSanctListDescr__c;
                                                                  } 
                                                          }
                                                      }catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelper, 
                                                                                                                                     GlobalConstants.goToApprovalStep1, GlobalConstants.ABCTriggerHelper, true, e)));}  
                                                  }
    
        /****************************************************************
* @author: Aditya Mohapatra
* @date: 18/01/2021
* @User Story:  2258
* @description: To populate the Approver Comments based on final Approval
*****************************************************************/
    @Future(callout=true)
    public static void populateApproverComments(set<id> ABCrecset){
        try{
            Set<Id> AbcSet = new Set<Id>();
            List<AntiBriberyCorruption__c> abcList = new List<AntiBriberyCorruption__c>();
            List<processinstancestep> existingApprovals=new List<processinstancestep>();
            
            list<ProcessInstance> ProcIns=new list<ProcessInstance>();
            if(!ABCrecset.isEmpty()){
                abcList = [Select Id,ApprovalComments__c,ApprovalStatus__c from AntiBriberyCorruption__c where Id = :ABCrecset];
             }
            ProcIns=[select id,LastActor.name,CompletedDate from ProcessInstance where TargetObjectId IN : ABCrecset Order BY CreatedDate DESC];
            map<id,list<ProcessInstanceHistory>>approvalcommentwithABC=new map<id,list<ProcessInstanceHistory>>();
            String commentsStr='Approver Name :' + 'Approver Comments';
            boolean commentflag=false;
            AntiBriberyCorruption__c abcupdaterecord=new AntiBriberyCorruption__c();
            for (ProcessInstance pi : [SELECT TargetObjectId,LastActorId,LastActor.Name,(SELECT Id,Actor.name, ActorId,OriginalActor.Name,Comments, ProcessInstanceId FROM StepsAndWorkitems where StepStatus =: 'Approved' Order BY CreatedDate DESC), (SELECT Id, StepStatus, Comments  FROM Steps ORDER BY CreatedDate DESC LIMIT 1 )
                       FROM ProcessInstance WHERE Id IN :ProcIns ORDER BY CreatedDate DESC])
            {
               
                approvalcommentwithABC.put(pi.TargetObjectId,pi.StepsAndWorkitems); 
                if (pi.StepsAndWorkitems.size() > 0){
                    
                    
                   for(ProcessInstanceHistory pih :pi.StepsAndWorkitems){
                      if(pih.Comments == null){
                                commentsStr+='\n' + pih.Actor.name + ' : ' + 'No Comments';
                                commentflag=true; 
                      }else if(pih.Comments == 'Submitting request for approval'){
                                commentsStr+='\n' + pih.Actor.name + ' : ' + 'Automatically Approved';
                                commentflag=true;  
                            }else{
                                commentsStr+='\n' + pih.Actor.name + ' : ' + pih.Comments;
                                commentflag=true;         
                            }
                      
                      
                    }
                    
                 }
                abcupdaterecord.id=pi.TargetObjectId; 
                abcupdaterecord.ApprovalComments__c=commentsStr;
               
            }
            if(commentflag)
            update abcupdaterecord;
        }
        catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelper,GlobalConstants.updateAccountFields, GlobalConstants.ABCTriggerHelper, true, e)));}
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 
* @User Story:  
* @description:  
*****************************************************************/
    public static void checkAccountFields(List<AntiBriberyCorruption__c> newABCList, Map<ID, AntiBriberyCorruption__c> newABCMap,  
                                          Map<ID, AntiBriberyCorruption__c> oldABCMap,boolean isInsert){
                                              try{
                                                  Set<String> AccnameSet = new Set<String>();
                                                  Map<String,Account> AccountMap = new Map<String,Account>();
                                                  for(AntiBriberyCorruption__c abc:newABCList) {
                                                      AccnameSet.add(abc.Account__c);
                                                  }
                                                  
                                                  for(Account a : [select id,Name,PublicSanctionList__c,PublSanctListDescr__c,CorrOrAntitrust__c,
                                                                   CorrOrAntitrustDescr__c,OwnRequirementsCompliance__c,
                                                                   OwnReqComplDescr__c, PublicOfficials__c,
                                                                   PublicOfficialsDescribe__c,PublicSectorInvolved__c,
                                                                   PublicSectInvName__c,PublicSectInvQuota__c,
                                                                   GovernmentallyOwned__c,ActingJVP__c from account where name in: AccnameSet 
                                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                                       AccountMap.put(a.name,a);
                                                                   }  
                                                  for(AntiBriberyCorruption__c abc:newABCList) {
                                                      if(AccountMap.containsKey(abc.Account__c) && isInsert){
                                                          if(abc.PublicSanctionList__c !=AccountMap.get(abc.Account__c).PublicSanctionList__c ||
                                                             abc.PublSanctListDescr__c != AccountMap.get(abc.Account__c).PublSanctListDescr__c ||
                                                             abc.CorruptionOrAntitrust__c != AccountMap.get(abc.Account__c).CorrOrAntitrust__c ||
                                                             abc.CorruptionOrAntitrustDescr__c != AccountMap.get(abc.Account__c).CorrOrAntitrustDescr__c ||
                                                             abc.OwnRequirementsCompliance__c != AccountMap.get(abc.Account__c).OwnRequirementsCompliance__c ||
                                                             abc.OwnReqComplianceDesc__c != AccountMap.get(abc.Account__c).OwnReqComplDescr__c ||
                                                             abc.PublicOfficials__c != AccountMap.get(abc.Account__c).PublicOfficials__c ||
                                                             abc.PublicOfficialsDescribe__c != AccountMap.get(abc.Account__c).PublicOfficialsDescribe__c ||
                                                             abc.PublicSectorInvolved__c != AccountMap.get(abc.Account__c).PublicSectorInvolved__c ||
                                                             abc.PublicSectInvName__c != AccountMap.get(abc.Account__c).PublicSectInvName__c ||
                                                             abc.PublicSectInvQuota__c != AccountMap.get(abc.Account__c).PublicSectInvQuota__c)
                                                          {
                                                              abc.AccountDataMismatch__c = true ;
                                                          }
                                                          if(isInsert)
                                                           abc.SubmitForApproval__c = true ;
                                                      }else if(!isInsert){
                                                          if(abc.RequestToUtilize3rdParties__c != oldABCMap.get(abc.Id).RequestToUtilize3rdParties__c ||
                                                            abc.RequirementsOnCertain3rdParties__c != oldABCMap.get(abc.Id).RequirementsOnCertain3rdParties__c ||
                                                            abc.DesribeCustomerRequest__c !=oldABCMap.get(abc.Id).DesribeCustomerRequest__c ||
                                                            abc.PlansToCoverCost__c != oldABCMap.get(abc.Id).PlansToCoverCost__c||
                                                            abc.IncludeBusinessEvents__c != oldABCMap.get(abc.Id).IncludeBusinessEvents__c||
                                                            abc.CostIncludedInProposal__c != oldABCMap.get(abc.Id).CostIncludedInProposal__c||
                                                            abc.TravelAccConfirmApproval__c != oldABCMap.get(abc.Id).TravelAccConfirmApproval__c||
                                                            abc.CaseNumber__c != oldABCMap.get(abc.Id).CaseNumber__c||
                                                            abc.AttemptedContactsWithComp__c != oldABCMap.get(abc.Id).AttemptedContactsWithComp__c||
                                                            abc.AttContWithCompDescribe__c != oldABCMap.get(abc.Id).AttContWithCompDescribe__c||
                                                            abc.HasThereBeenGifts__c != oldABCMap.get(abc.Id).HasThereBeenGifts__c||
                                                            abc.GiftsDeviateFromABCGuidelines__c != oldABCMap.get(abc.Id).GiftsDeviateFromABCGuidelines__c ||
                                                            abc.ConfirmApprovalMACOCCD__c != oldABCMap.get(abc.Id).ConfirmApprovalMACOCCD__c ||
                                                            abc.DonationsOrSponsorships__c != oldABCMap.get(abc.Id).DonationsOrSponsorships__c ||
                                                            abc.DonationSponsorshipsDesc__c != oldABCMap.get(abc.Id).DonationSponsorshipsDesc__c ||
                                                            abc.Donorsponsanticipated__c != oldABCMap.get(abc.Id).Donorsponsanticipated__c ||
                                                            abc.DonSponsAnticipatedDesc__c != oldABCMap.get(abc.Id).DonSponsAnticipatedDesc__c ||
                                                            abc.FormerEricssonEmployees__c != oldABCMap.get(abc.Id).FormerEricssonEmployees__c ||
                                                            abc.FormEricssonEmplNames__c != oldABCMap.get(abc.Id).FormEricssonEmplNames__c ||
                                                            abc.DescribenatureofJVPorC__c !=oldABCMap.get(abc.Id).DescribenatureofJVPorC__c ||
                                                            abc.DescribenatureofCP__c != oldABCMap.get(abc.Id).DescribenatureofCP__c){
                                                              abc.AccountDataMismatch__c = true ;
                                                          }
                                                          if(!isInsert && abc.AccountDataMismatch__c)
                                                           abc.SubmitForApproval__c = true ;
                                                      }
                                                  } 
                                              }
                                              catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelper, 
                                                                                                                            GlobalConstants.updateAccountFields, GlobalConstants.ABCTriggerHelper, true, e)));}   
                                          }
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story:  1981
* @description:  This method updates ApprovalStatus,Reason_for_Approval fields on changing Account related Questions
*****************************************************************/
    public static void updateApprovalStatus(List<AntiBriberyCorruption__c> newABCList,  Map<ID, AntiBriberyCorruption__c> oldABCMap)
    {		
        Try{
            boolean approvedflag=false;
            for(AntiBriberyCorruption__c abc : newABCList) {
                if(abc.Sales_Scenario__c != oldABCMap.get(abc.id).Sales_Scenario__c ||
                   abc.PublicSanctionList__c != oldABCMap.get(abc.id).PublicSanctionList__c ||
                   abc.PublSanctListDescr__c != oldABCMap.get(abc.id).PublSanctListDescr__c ||
                   abc.CorruptionOrAntitrust__c != oldABCMap.get(abc.id).CorruptionOrAntitrust__c ||
                   abc.CorruptionOrAntitrustDescr__c != oldABCMap.get(abc.id).CorruptionOrAntitrustDescr__c ||
                   abc.OwnRequirementsCompliance__c != oldABCMap.get(abc.id).OwnRequirementsCompliance__c ||
                   abc.OwnReqComplianceDesc__c != oldABCMap.get(abc.id).OwnReqComplianceDesc__c ||
                   abc.PublicSectorInvolved__c != oldABCMap.get(abc.id).PublicSectorInvolved__c ||
                   abc.PublicSectInvName__c != oldABCMap.get(abc.id).PublicSectInvName__c ||
                   abc.PublicSectInvQuota__c != oldABCMap.get(abc.id).PublicSectInvQuota__c ||
                   abc.PublicOfficials__c != oldABCMap.get(abc.id).PublicOfficials__c ||
                   abc.PublicOfficialsDescribe__c != oldABCMap.get(abc.id).PublicOfficialsDescribe__c ||
                   
                   abc.PublicSanctionList2__c != oldABCMap.get(abc.id).PublicSanctionList2__c ||
                   abc.PublSanctListDescr2__c != oldABCMap.get(abc.id).PublSanctListDescr2__c ||
                   abc.CorruptionAntitrust2__c != oldABCMap.get(abc.id).CorruptionAntitrust2__c ||
                   abc.CorruptionAntitrustDescr2__c != oldABCMap.get(abc.id).CorruptionAntitrustDescr2__c ||
                   abc.OwnRequirementsCompliance2__c != oldABCMap.get(abc.id).OwnRequirementsCompliance2__c ||
                   abc.OwnReqComplianceDesc2__c != oldABCMap.get(abc.id).OwnReqComplianceDesc2__c ||
                   abc.PublicSectorInvolved2__c != oldABCMap.get(abc.id).PublicSectorInvolved2__c ||
                   abc.PublicSectInvName2__c != oldABCMap.get(abc.id).PublicSectInvName2__c ||
                   abc.PublicSectInvQuota2__c != oldABCMap.get(abc.id).PublicSectInvQuota2__c ||
                   abc.PublicOfficials2__c != oldABCMap.get(abc.id).PublicOfficials2__c ||
                   abc.PublicOfficialsDescribe2__c != oldABCMap.get(abc.id).PublicOfficialsDescribe2__c||
                   
                   abc.RequestToUtilize3rdParties__c != oldABCMap.get(abc.id).RequestToUtilize3rdParties__c ||
                   abc.RequirementsOnCertain3rdParties__c != oldABCMap.get(abc.id).RequirementsOnCertain3rdParties__c || 
                   abc.DesribeCustomerRequest__c != oldABCMap.get(abc.id).DesribeCustomerRequest__c ||
                   abc.PlansToCoverCost__c != oldABCMap.get(abc.id).PlansToCoverCost__c ||
                   abc.IncludeBusinessEvents__c != oldABCMap.get(abc.id).IncludeBusinessEvents__c ||
                   abc.CostIncludedInProposal__c != oldABCMap.get(abc.id).CostIncludedInProposal__c ||
                   abc.TravelAccConfirmApproval__c != oldABCMap.get(abc.id).TravelAccConfirmApproval__c ||
                   abc.CaseNumber__c != oldABCMap.get(abc.id).CaseNumber__c ||
                   abc.AttemptedContactsWithComp__c != oldABCMap.get(abc.id).AttemptedContactsWithComp__c ||
                   abc.AttContWithCompDescribe__c != oldABCMap.get(abc.id).AttContWithCompDescribe__c ||
                   abc.HasThereBeenGifts__c != oldABCMap.get(abc.id).HasThereBeenGifts__c ||
                   abc.GiftsDeviateFromABCGuidelines__c != oldABCMap.get(abc.id).GiftsDeviateFromABCGuidelines__c ||
                   abc.ConfirmApprovalMACOCCD__c != oldABCMap.get(abc.id).ConfirmApprovalMACOCCD__c ||
                   abc.DonationsOrSponsorships__c != oldABCMap.get(abc.id).DonationsOrSponsorships__c ||
                   abc.DonationSponsorshipsDesc__c != oldABCMap.get(abc.id).DonationSponsorshipsDesc__c ||
                   abc.Donorsponsanticipated__c != oldABCMap.get(abc.id).Donorsponsanticipated__c ||
                   abc.DonSponsAnticipatedDesc__c != oldABCMap.get(abc.id).DonSponsAnticipatedDesc__c ||
                   abc.FormerEricssonEmployees__c != oldABCMap.get(abc.id).FormerEricssonEmployees__c ||
                   abc.FormEricssonEmplNames__c != oldABCMap.get(abc.id).FormEricssonEmplNames__c ||
                   abc.DescribenatureofJVPorC__c != oldABCMap.get(abc.id).DescribenatureofJVPorC__c ||
                   abc.DescribenatureofCP__c != oldABCMap.get(abc.id).DescribenatureofCP__c )
                {
                    if(oldABCMap.get(abc.id).ApprovalStatus__c!=null && oldABCMap.get(abc.id).ApprovalStatus__c.contains(GlobalConstants.APPROVED)){
                        approvedflag=true;
                        abc.ApprovalStatus__c = GlobalConstants.RecalledOrNotYetSubmitted;
                        abc.SubmitForApproval__c = false;
                        abc.Reason_for_Approval__c = GlobalConstants.BLANK;
                        if(abc.StageName__c == GlobalConstants.Negotiate_and_Close){
                            abc.I_confirm_the_ABC_Conditional_Adherance__c = false;
                        }
                    }
                }
                Opportunity opp = [Select id, ABCConditionalAdherance__c from Opportunity where id =: abc.Opportunity__c Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(abc.I_confirm_the_ABC_Conditional_Adherance__c){
                    opp.ABCConditionalAdherance__c = GlobalConstants.YES;
                }else { opp.ABCConditionalAdherance__c = GlobalConstants.NO; }
                if(approvedflag){
                        opp.Approved_In_Stage2__c=false;
                        opp.Approved_In_Stage3__c=false;
                        opp.Approved_In_Stage4__c=false;
                }
                Database.update(opp);
            }
            
        }
        catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelper, 
                                                                                      GlobalConstants.updateApprovalStatus, GlobalConstants.ABCTriggerHelper, true, e)));}
    }
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story:  1981
* @description:  This method populates Kam_Email field on ABC record
*****************************************************************/    
    public static void populateKamEmail(List<AntiBriberyCorruption__c> newABCList,Map<ID, AntiBriberyCorruption__c> newABCMap)
    {		
        Try{
            set<Id> oppIdSet = new set<Id>();
            
            List<Opportunity> oppList = new List<Opportunity>();
            Map<Id, String> oppWithKAMemailMap = new Map<Id, String>();
            Map<Id, String> oppWithKAMMap = new Map<Id, String>();
            for(AntiBriberyCorruption__c abc : newABCList) {
                oppIdSet.add(abc.Opportunity__c);
            }
            for(Opportunity opp : [select Id,KAM__c,KAM__r.Email from Opportunity where Id in:oppIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                oppWithKAMemailMap.Put(Opp.Id, opp.KAM__r.Email);
                oppWithKAMMap.Put(Opp.Id, opp.KAM__c);
            }
            for(AntiBriberyCorruption__c abc : newABCList) {
                abc.KAM_Email__c = oppWithKAMemailMap.get(abc.Opportunity__c);
                abc.KAM__c = oppWithKAMMap.get(abc.Opportunity__c);
            }
        }
        catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelper, 
                                                                                      GlobalConstants.populateKamEmail, GlobalConstants.ABCTriggerHelper, true, e)));}
        
    } 
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story:  1981
* @description:  This mehod fetches ABC details from Opportunity Id
*****************************************************************/    
    @AuraEnabled
    public static AntiBriberyCorruption__c getAntiBriberyCorruption(String recordId) {
        return [SELECT Id, Name, BusinessPartnerAccount__c, PublicSanctionList__c,
                ApprovalStatus__c, Opportunity__c,Reason_for_Approval__c,I_confirm_the_ABC_Conditional_Adherance__c,StageName__c
                FROM AntiBriberyCorruption__c where Opportunity__c =:recordId LIMIT 1];
    }
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story:  1981
* @description:  This mehod fetches ABC details from ABC Id
*****************************************************************/    
    @AuraEnabled
    public static AntiBriberyCorruption__c getAntiBriberyCorruptionById(String recordId) {
        return [SELECT Id, Name, BusinessPartnerAccount__c, PublicSanctionList__c,
                ApprovalStatus__c, Opportunity__c,Reason_for_Approval__c,I_confirm_the_ABC_Conditional_Adherance__c,StageName__c
                FROM AntiBriberyCorruption__c where Id =:recordId LIMIT 1];
    }
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story:  1981
* @description:  This mehod fetches ABC and Opportunity details from ABC Id
*****************************************************************/    
    @AuraEnabled
    public static Opportunity getOppwithABC(String recordId) {
        return [SELECT Id, Name, StageName,ABC_Count__c, (SELECT Id, Name, BusinessPartnerAccount__c, PublicSanctionList__c,
                                                          ApprovalStatus__c, Opportunity__c,Reason_for_Approval__c,
                                                          I_confirm_the_ABC_Conditional_Adherance__c,StageName__c 
                                                          from Anti_Bribery_Corruptions__r Limit 1) FROM Opportunity where Id =:recordId LIMIT 1];
    }
}