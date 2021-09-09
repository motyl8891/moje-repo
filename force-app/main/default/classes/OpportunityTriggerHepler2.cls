/******************************************************************************************
@author       : Richa Gupta
@date         : 07/07/2020
@description  : This class is used as a Replacement of Process Builder(U-1889)
@testClass    : OpportunityProcessTriggerTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
Richa Gupta             14-09-2020              U-1795 - Handling of Renewal   
Shubham Kadam           14/12/2020          	U-2399 - updateConsolidatedBlockListOnAccount Method
******************************************************************************************/
public class OpportunityTriggerHepler2 {
    /* This Method is used to set currency and Account on Parent Opportunity*/  
    public static void setAccountAndCurrency( List<Opportunity> newOpportunities){
        try{ 
            Set<Id> allAccId = new Set<Id>();
            Set<id> parentOppId=new set<id>();
            List<Opportunity> SimpleOppList= new  List<Opportunity>();
            List<Opportunity> oppList= new  List<Opportunity>();
            Map < Id,Opportunity > mapOpp;
            Map<ID, Account> mapAcc;
            for(Opportunity opp:newOpportunities){
            parentOppId.add(opp.Parent_Original_Opportunity__c);
            allAccId.add(opp.AccountId);
            if(opp.RecordTypeId==GlobalConstants.simpleOppRecordTypeId){
             SimpleOppList.add(opp);
            }else
             oppList.add(opp);
            }if(!SimpleOppList.isEmpty()&&!parentOppId.isEmpty()){
                mapOpp = new Map <Id, Opportunity >([Select id,CurrencyIsoCode,AccountId from Opportunity where id in:parentOppId
                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);}
            if(!oppList.isEmpty()&&!allAccId.isEmpty()){
                mapAcc = new Map<ID, Account>([Select Id,CurrencyIsoCode from Account Where Id in:allAccId
                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);}
            for(Opportunity opp:newOpportunities){
                if(opp.RecordTypeId==GlobalConstants.simpleOppRecordTypeId){
                    if((opp.AccountId!=mapOpp.get(opp.Parent_Original_Opportunity__c).AccountId || opp.CurrencyIsoCode!= mapOpp.get(opp.Parent_Original_Opportunity__c).CurrencyIsoCode) &&opp.Parent_Account_Update__c){
                        opp.AccountId=mapOpp.get(opp.Parent_Original_Opportunity__c).AccountId;
                        opp.CurrencyIsoCode=mapOpp.get(opp.Parent_Original_Opportunity__c).CurrencyIsoCode;
                        opp.Parent_Account_Update__c=false;}
                }else if(opp.CurrencyIsoCode!= mapAcc.get(opp.AccountId).CurrencyIsoCode && opp.Parent_Account_Update__c ){
                        opp.CurrencyIsoCode=mapAcc.get(opp.AccountId).CurrencyIsoCode;
                        opp.Parent_Account_Update__c=false;
                }else{opp.Parent_Account_Update__c=false;}
            }
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.setAccountAndCurrency, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
        } 
    }
    /* This Method is used to Assign Opportunity RecordType while Opportunity Creation*/ 
    public static void recordTypeAssignment( List<Opportunity> newOpportunities){
        try{
            for(Opportunity opp:newOpportunities){
                if(opp.RecordTypeId == GlobalConstants.standardCreateOppRecordTypeId|| opp.RecordTypeId==GlobalConstants.frameCreateOppRecordTypeId ){
                    if(opp.RecordTypeId==GlobalConstants.standardCreateOppRecordTypeId){
                        opp.RecordTypeId=GlobalConstants.standardOppRecordTypeId; 
                    } else {
                        opp.RecordTypeId=GlobalConstants.frameOppRecordTypeId;
                    }
                    if(opp.Forecast__c==null){
                        opp.Forecast__c=GlobalConstants.EXCLUDE;
                    }
                    if(opp.Trade_Classification_Formula__c!=null && opp.Trade_Classification_Formula__c.equals(GlobalConstants.DEFENSE)){
                        opp.Trade_Classifications__c=GlobalConstants.DEFENSE;
						opp.Trade_Compliance_Status__c = GlobalConstants.REQUIRED;
						opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                    }else if(opp.Trade_Classification_Formula__c!=null && opp.Trade_Classification_Formula__c.equals(GlobalConstants.CIVIL)){
                        opp.Trade_Classifications__c=GlobalConstants.CIVIL;
						opp.Trade_Compliance_Status__c = GlobalConstants.Not_Required;
						opp.Sensitive_Business_Status__c = GlobalConstants.Not_Required;
                    }/*else{
                    opp.Trade_Classifications__c=GlobalConstants.GOVERNMENT;
					opp.Trade_Compliance_Status__c = GlobalConstants.REQUIRED;
					opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
					}*/
					else if(opp.Trade_Classification_Formula__c!=null && opp.Trade_Classification_Formula__c.equals(GlobalConstants.GOVERNMENT)){
                    opp.Trade_Classifications__c=GlobalConstants.GOVERNMENT;
					opp.Trade_Compliance_Status__c = GlobalConstants.REQUIRED;
					opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
					}else {
                    opp.Trade_Classifications__c=null;
					opp.Trade_Compliance_Status__c = null;
					opp.Sensitive_Business_Status__c = null;
					}
                  }else if(opp.RecordTypeId==GlobalConstants.simpleCreateOppRecTypeId && opp.stageName.equals(GlobalConstants.Negotiate_and_Close)){
                    opp.RecordTypeId=GlobalConstants.simpleOppRecordTypeId;
                    if(opp.Forecast__c==null){
                       opp.Forecast__c=GlobalConstants.ForecastCategory;
                    }
                }
            }
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.recordTypeAssignment, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
        }
    }

    /* This Method is used to Update 'Opportunity Product Change' if Product on 'Opportunity' is changed*/ 
    public Static void setCloseDateStageNameProductChange(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
            for(Opportunity opp:newOpportunitiesList){
                if(opp.RecordTypeId==GlobalConstants.simpleOppRecordTypeId){
                    if(opp.Opportunity_Product_Count__c!=oldOpportunitiesMap.get(opp.Id).Opportunity_Product_Count__c&& opp.Opportunity_Product_Count__c==0){
                        opp.CloseDate=System.today();
                        opp.StageName=GlobalConstants.ClosedDuplicate;
                    }
                }
                else if(opp.RecordTypeId==GlobalConstants.frameOppRecordTypeId){
                    if(opp.Opportunity_Product_Count__c!=oldOpportunitiesMap.get(opp.Id).Opportunity_Product_Count__c){
                        opp.Opportunity_Product_Change__c=GlobalConstants.Product_Count_Changed;
                    }else if(opp.Opportunity_Product_Values_Sum__c!=oldOpportunitiesMap.get(opp.Id).Opportunity_Product_Values_Sum__c){
                        opp.Opportunity_Product_Change__c=GlobalConstants.Product_Values_Changed;
                    }else if(opp.Summary_of_Product_Margin__c!=oldOpportunitiesMap.get(opp.Id).Summary_of_Product_Margin__c){
                        opp.Opportunity_Product_Change__c=GlobalConstants.Product_Margin_Changed;
                    }else if(opp.CloseDate!=oldOpportunitiesMap.get(opp.Id).CloseDate){
                        opp.Opportunity_Product_Change__c=GlobalConstants.Close_Date_Changed;
                    }else if(opp.Forecast__c!=oldOpportunitiesMap.get(opp.Id).Forecast__c){
                        opp.Opportunity_Product_Change__c=GlobalConstants.Forecast_Category_Changed;
                    }
                } 
            }
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.setCloseDateStageNameProductChange, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
        }
    }
    /*  This method is used to update 'Opp Description' field on 'Secondary Approval' object after updation in 'Description' field on 'Opportunity' */
    public Static void updateOppDescriptionOnSecondaryApproval(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
            Map < Id,Opportunity > mapOpp = new Map <Id, Opportunity >();
            List<Secondary_Approval__c> secAppList= new List<Secondary_Approval__c>();
            for(Opportunity opp:newOpportunitiesList){
                if(opp.Description!=oldOpportunitiesMap.get(opp.id).Description){
                    mapOpp.put(opp.id, opp);
                }
               
            }
            if(!mapOpp.isEmpty()){
                for(Secondary_Approval__c secApp:[Select id,Opp_Description__c,Opportunity__c,Opportunity__r.Description from Secondary_Approval__c where Opportunity__c in :mapOpp.keyset()
                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    secApp.Opp_Description__c=mapOpp.get(secApp.Opportunity__c).Description;
                    secAppList.add(secApp);
                }if(!secAppList.isEmpty()){
                    update secAppList;
                }
            }
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.updateOppDescriptionOnSecondaryApproval, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
        }
    }/* This Method is used to Update Approved stage on Primary Proposal if approved stage on Opportunity is changed*/
    public Static void updateOpportunityApprovedStage(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
            Map < Id,Opportunity > mapOpp = new Map <Id, Opportunity >();
            List<Proposal__c>propList =New List<Proposal__c>();
            for(Opportunity opp:newOpportunitiesList){
                if(opp.Approved_Stage__c !=null && opp.Approved_Stage__c!=oldOpportunitiesMap.get(opp.id).Approved_Stage__c){
                    mapOpp.put(opp.id, opp);
                }}
            if(!mapOpp.isEmpty()){
                for(Proposal__c pro:[select id,Name,Primary__c,Approved_Stage__c,Opportunity__r.Approved_Stage__c from Proposal__c where Primary__c=TRUE and Opportunity__c in:mapOpp.keyset()
                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(pro.Approved_Stage__c==null || !pro.Approved_Stage__c.contains(mapOpp.get(pro.Opportunity__c).Approved_Stage__c)){
                        if(pro.Approved_Stage__c==null){
                            pro.Approved_Stage__c=mapOpp.get(pro.Opportunity__c).Approved_Stage__c;}
                        else{
                            pro.Approved_Stage__c=pro.Approved_Stage__c +';'+mapOpp.get(pro.Opportunity__c).Approved_Stage__c;}
                        if(mapOpp.get(pro.Opportunity__c).Approved_Stage__c.contains(GlobalConstants.Negotiate_and_Close)){
                            pro.Approved_in_Negotiate_and_Close__c=true;
                        }pro.Last_Approved_Date__c=System.today();
                    }
                    propList.add(pro);
                }if(!propList.isEmpty()){
                    update propList;
                }
            }}
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.updateOpportunityApprovedStage, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
        }
    }
    /*This Method is used to update Primary Proposal on SDR when Primary Proposal is changed on Opportunity*/
    public static void updatePrimaryProposalOnSDR(List<Opportunity> newOpportunitiesList,Map<ID,Opportunity> oldOpportunitiesMap){
        try{ 
            Map <Id,Opportunity > mapOpp = new Map <Id,Opportunity >();
            List<Sales_Decision_Record__c> sdrList =New List<Sales_Decision_Record__c>();
            for(Opportunity opp:newOpportunitiesList){
                if(opp.Primary_Proposal__c!=oldOpportunitiesMap.get(opp.Id).Primary_Proposal__c){
                    mapOpp.put(opp.Id,opp);
                }
            }if(!mapOpp.isEmpty()){
                for(Sales_Decision_Record__c sdr:[select id,Opportunity__r.Primary_Proposal__c,Opportunity__r.Primary_Proposal__r.Overall_EBD_Approval_Status__c from Sales_Decision_Record__c where Opportunity__c in:mapOpp.keyset() and Locked__c=false]){
                    sdr.Primary_Proposal__c=mapOpp.get(sdr.Opportunity__c).Primary_Proposal__c;
                    sdr.Overall_EBD_Approval_Status__c= sdr.Opportunity__r.Primary_Proposal__r.Overall_EBD_Approval_Status__c;
                    sdrList.add(sdr);
                }if(!sdrList.isEmpty()){
                    update sdrList;
                }
            }
        } catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.updatePrimaryProposalOnSDR, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
        }
    }/* This method is used to set Approvers On Opportunity while creating opportunity or updation of AccountId on Opportunity*/
    public static void setOpportunityApprovers( List<Opportunity> newOpportunities,Map<ID, Opportunity> oldOpportunitiesMap,Boolean isInsert){
        try{
            
         
           /* Set<Id> allAccId = new Set<Id>();
            Set<Id> ownerIds = new Set<Id>();
            for(Opportunity opp:newOpportunities){
                allAccId.add(opp.AccountId);
                ownerIds.add(opp.OwnerId);
            } 
            Map<ID,User> mapUser=new Map<ID,User>([Select Id,name,CU_Head__c,KAM__c from user where id in:ownerIds]);
            Map<ID, Account> mapAcc = new Map<ID, Account>([Select Id,MarketArea__c,CustomerReportingGroup__c,CustomerReportingGroup__r.GlobalCustomerUnit__c,CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Head__c,
                                                            CustomerReportingGroup__r.Valid_KAM_CU_Head_Approvers__c,CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Commercial_Head__c ,
                                                            CustomerReportingGroup__r.Account_Primary_KAM__c, CustomerReportingGroup__r.Account_CU_Head__c from Account Where Id in:allAccId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            */
            Set<Id> allAccId = new Set<Id>();
            Set<Id> ownerIds = new Set<Id>();
            Map<ID, Account> mapAcc;
            Map<ID,User> mapUser;
            List<Opportunity> oppList= new  List<Opportunity>();
            for(Opportunity opp:newOpportunities){
                allAccId.add(opp.AccountId);
                ownerIds.add(opp.OwnerId);
                oppList.add(opp);
            } 
            if(!ownerIds.isempty() && !oppList.isempty()){
            mapUser=new Map<ID,User>([Select Id,name,CU_Head__c,KAM__c from user where id in:ownerIds Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            }
            if(!allAccId.isempty() && !oppList.isempty()){
            mapAcc = new Map <Id, Account >([Select Id,MarketArea__c,CustomerReportingGroup__c,CustomerReportingGroup__r.GlobalCustomerUnit__c,CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Head__c,
                                                            CustomerReportingGroup__r.Valid_KAM_CU_Head_Approvers__c,CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Commercial_Head__c ,
                                                            CustomerReportingGroup__r.Account_Primary_KAM__c, CustomerReportingGroup__r.Account_CU_Head__c from Account Where Id in:allAccId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            }
            
            
            for(Opportunity opp:newOpportunities){
                if(isInsert && mapAcc.get(opp.AccountId).MarketArea__c!=GlobalConstants.MANA && mapAcc.get(opp.AccountId).CustomerReportingGroup__c!=null){ 
                    opp.CU_Head__c=mapAcc.get(opp.AccountId).CustomerReportingGroup__r.Account_CU_Head__c;
                    opp.KAM__c=mapAcc.get(opp.AccountId).CustomerReportingGroup__r.Account_Primary_KAM__c;
                }if(mapAcc.get(opp.AccountId).CustomerReportingGroup__c!=null&&mapAcc.get(opp.AccountId).CustomerReportingGroup__r.GlobalCustomerUnit__c!=null&&
                         mapAcc.get(opp.AccountId).CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Head__c!=null&& (isInsert || (!isInsert &&opp.AccountId!=oldOpportunitiesMap.get(opp.id).AccountId))){
                             opp.GCU_Head__c=mapAcc.get(opp.AccountId).CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Head__c;       
                }if(mapAcc.get(opp.AccountId).CustomerReportingGroup__c!=null&&mapAcc.get(opp.AccountId).CustomerReportingGroup__r.GlobalCustomerUnit__c!=null&&
                           mapAcc.get(opp.AccountId).CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Commercial_Head__c!=null&&(isInsert ||(!isInsert &&opp.AccountId!=oldOpportunitiesMap.get(opp.id).AccountId))){
                           opp.GCU_Commercial_Head__c=mapAcc.get(opp.AccountId).CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_Commercial_Head__c;       
                }if(mapAcc.get(opp.AccountId).MarketArea__c.equals(GlobalConstants.MANA)&& mapAcc.get(opp.AccountId).CustomerReportingGroup__c!=null&&
                              !mapAcc.get(opp.AccountId).CustomerReportingGroup__r.Valid_KAM_CU_Head_Approvers__c&&(isInsert || (!isInsert &&opp.AccountId!=oldOpportunitiesMap.get(opp.id).AccountId))){
                              opp.CU_Head__c=mapUser.get(opp.OwnerId).CU_Head__c;
                              opp.KAM__c=mapUser.get(opp.OwnerId).KAM__c;
                                 // system.debug('cu head is'+ opp.CU_Head__c);
                }
            }
           }catch(Exception e){
               EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.setOpportunityApprovers, GlobalConstants.OpportunityTriggerHepler2, true, e)));      
           }
    } 
        /****************************************************************
* @author: Richa Gupta
* @date: 14-09-2020
* @param: newOpportunitiesList
* @description: U-1795 Set Parent Opportunity as OpportunityId on Parent Contract
************************************************************************/
    public static void setParentOpportunityAsContractOpportunity(List<Opportunity> newOpportunities){
        try{
            Map<id,Contract> mapContract;
            set<id> contractId=new set<id>();
            for(Opportunity opp:newOpportunities){
              if(opp.Source_System__c!=null &&(opp.Source_System__c==GlobalConstants.Lighthouse||opp.Source_System__c==GlobalConstants.RB_PPMID_88159)&& opp.Parent_Contract__c!=null){
                contractId.add(opp.Parent_Contract__c);
            }
        }if(!contractId.IsEmpty()){
                mapContract= new Map<id,Contract>([Select id,OpportunityID__c,OpportunityID__r.RecordTypeId from Contract  where id in :contractId 
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                for(Opportunity opp:newOpportunities){
                   if(opp.Source_System__c!=null &&(opp.Source_System__c==GlobalConstants.Lighthouse||opp.Source_System__c==GlobalConstants.RB_PPMID_88159)&& opp.Parent_Contract__c!=null && mapContract.get(opp.Parent_Contract__c).OpportunityID__r.RecordTypeId==GlobalConstants.frameOppRecordTypeId){
                        opp.Parent_Original_Opportunity__c=mapContract.get(opp.Parent_Contract__c).OpportunityID__c;
                    }
                 }
            }
      }catch(Exception e){
      EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.setParentOpportunityAsContractOpportunity, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
      }
    }

   
     /****************************************************************
* @author: Aditya Mohapatra
* @date: 09-10-2020
* @param: newOpportunitiesList
* @description: U-2040 Set OpptyUseCase based on UseCase from Opportunity
************************************************************************/
     public static void createOppUseCase(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap)
    {
        try{
            Set<Id> opptyIdSet = new Set<Id>();
			Set<String> useCaseSet = new Set<String>();
			List<OpportunityUseCase__c> oppUseCaseList = New List<OpportunityUseCase__c>();
			List<OpportunityUseCase__c> oppUseCaseListInsertion = New List<OpportunityUseCase__c>();
			Map<Id ,Set<String>> oppIdWithUseCaseMap = new Map<Id ,Set<String>>();
            Map<String ,UseCase__c> oppUCIdwithoppUCIdMap = new Map<String ,UseCase__c>();
			boolean flag = false ; 
            for(Opportunity opp: newOpportunitiesList)
            {
                system.debug('1');
                if( opp.UseCase__c!= null && opp.UseCase__c != oldOpportunitiesMap.get(opp.Id).UseCase__c ){
                    opptyIdSet.add(opp.id);
                    useCaseSet.addAll(opp.UseCase__c .split(';'));
                    oppIdWithUseCaseMap.put(opp.id,useCaseSet);
                    system.debug('2'+oppIdWithUseCaseMap);
                }
            }
			
            if(!opptyIdSet.isEmpty())
            {
                system.debug('3'+useCaseSet);
			for(OpportunityUseCase__c oppUseCase : [Select id, Opportunity__c from OpportunityUseCase__c
													where Opportunity__c in : opptyIdSet
													Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
													oppUseCaseList.add(oppUseCase);
													}
													delete oppUseCaseList;
			}
            if(!useCaseSet.isEmpty()){
             
                for(UseCase__c us : [select id,Name,Code__c from UseCase__c 
                                     where Code__c in : useCaseSet
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ){
                                      oppUCIdwithoppUCIdMap.put(us.Code__c, us) ;
                                         system.debug('3.5'+oppUCIdwithoppUCIdMap);
                                     }
			for(Id oppId : oppIdWithUseCaseMap.keyset()){
                system.debug('3.9');
			 for(String s  : oppIdWithUseCaseMap.get(oppId)){
                 system.debug('4'+s);
                 oppUseCaseListInsertion.add(new OpportunityUseCase__c(UseCase__c = oppUCIdwithoppUCIdMap.get(s).Id,
																  Opportunity__c =oppId));
			}
            
        }
		}
            if(!oppUseCaseListInsertion.isEmpty())
            {insert oppUseCaseListInsertion;}
		}
    catch(Exception e) { EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                                        GlobalConstants.createOppUseCase, GlobalConstants.OpportunityTriggerHepler2, true, e)));
                           }   
    }

    
/****************************************************************
    /****************************************************************
* @author: Shubham Jagatap
* @date: 09-10-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: U-2072,U-2035 Set SBS Status, Update SBS Status (before update)
************************************************************************/
    public static void setSBSStatus(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap)
    {
        List<Opportunity>  oppWithProposalList = new List<Opportunity>();
        try{
            map<Id, EUFT__c> mapOppwithEUFT = new map<Id, EUFT__c>();
            map<Id, EUFT__c> mapOppwithEUFT_Threashold = new map<Id, EUFT__c>();
            set<ID>allOppId=new set<ID>();
            map<Id, EUFT__c> mapExemptionKeysEUFT = new map<Id, EUFT__c>();
            
            for(Opportunity opp : newOpportunitiesList)
            {   
                if(opp.SBSPilot__c){
                    if(opp.SBSResult__c != oldOpportunitiesMap.get(opp.Id).SBSResult__c){
                        if(opp.SBSResult__c == GlobalConstants.Success){
                            opp.SBSStatus__c = GlobalConstants.Successful;
                        }
                        if(opp.SBSResult__c == GlobalConstants.Failed){
                            opp.SBSStatus__c = GlobalConstants.Failed;
                        }
                        if(opp.SBSResult__c == GlobalConstants.PartiallyCompleted){
                            opp.SBSStatus__c = GlobalConstants.PartiallyCompleted;
                        }
                    }
                    //if(opp.StageName == GlobalConstants.Create_Proposal || opp.StageName == GlobalConstants.Negotiate_and_Close){ 
                        allOppId.add(opp.id);  
                    //}
                }	
            }
            System.debug('## alloppId '+allOppId);
            
            if(!allOppId.isEmpty()){
                for(EUFT__c eu : [SELECT Id,Opportunity__c,TechnologyRiskThreshold__c, ExemptionKeys__c, EUFT__r.ConsolidatedBlockList__c 
                                  from EUFT__c where Opportunity__c in : allOppId
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(eu.TechnologyRiskThreshold__c>=0 && eu.TechnologyRiskThreshold__c<=10) {
                        mapOppwithEUFT.put(eu.Opportunity__c, eu); 
                    }
                    if(eu.TechnologyRiskThreshold__c > 10 /*|| eu.EUFT__r.ConsolidatedBlockList__c != null*/ ) {
                        System.debug('##378');
                        mapOppwithEUFT_Threashold.put(eu.Opportunity__c, eu); 
                    }
                    if(eu.ExemptionKeys__c != null){
                        mapExemptionKeysEUFT.put(eu.Opportunity__c, eu);  //U-2386-3.f
                    }
                }   
            }
            
            System.debug('## mapOppwithEUFT '+mapOppwithEUFT);
            System.debug('## mapOppwithEUFT_Threashold '+mapOppwithEUFT_Threashold);
            System.debug('## mapExemptionKeysEUFT '+mapExemptionKeysEUFT);
            
            for(Opportunity opp : newOpportunitiesList){
                //if(opp.SBSPilot__c && (opp.StageName == GlobalConstants.Create_Proposal || opp.StageName == GlobalConstants.Negotiate_and_Close)){
					//Set SBSStatus and set SBSAutomationRequired__c flag                    
                    if((opp.SBSStatus__c == GlobalConstants.Not_Required || opp.SBSStatus__c == null) && 
                      (opp.SBSPilot__c /*&& (opp.StageName == GlobalConstants.Create_Proposal || opp.StageName == GlobalConstants.Negotiate_and_Close)*/)){
                        if((opp.Proposal_Count__c > 0 || mapExemptionKeysEUFT.containsKey(opp.Id)) && 
                           ((opp.Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_CAMEL || 
                             opp.Sales_Compliance_Country_Risk__c == GlobalConstants.MEDIUM_CAMEL) ||
                            (opp.Sales_Compliance_Country_Risk__c == GlobalConstants.CAMEL_LOW && 
                             (opp.Trade_Classifications__c == GlobalConstants.DEFENSE 
                              || opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT))) &&
                           (mapOppwithEUFT.containsKey(opp.Id) || mapExemptionKeysEUFT.containsKey(opp.Id)) //U-2386
                          ){
                              opp.SBSStatus__c = GlobalConstants.TriggerRequired;
                              opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED; //U-2386
                              opp.SBSAutomationRequired__c = true;   //set SBSAutomationRequired__c flag U-2386
                              //ResetSecondaryApprovalStatus(opp);  //U-2391
                              opp.SBSMessage__c = null;
                              opp.SBSResult__c = null;
                              System.debug('## in 2ns if '+opp);
                          }
                        else{
                                opp.SBSAutomationRequired__c = false;   //set SBSAutomationRequired__c flag U-2386
                            //ResetSecondaryApprovalStatus(opp);   //U-2391
                            System.debug('opp.SBSAutomationRequired__c '+opp.SBSAutomationRequired__c);
                        }
                    }
                
                //If SBSStatus__c == GlobalConstants.TriggerRequired and something changes
                if(opp.SBSPilot__c && opp.SBSStatus__c == GlobalConstants.TriggerRequired) 
                {
                    System.debug('@@ 1. TriggerRequired');
                    if(opp.Purpose__c != oldOpportunitiesMap.get(opp.Id).Purpose__c ||
                       opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.Id).Trade_Classifications__c ||
                       opp.Primary_Proposal__c != oldOpportunitiesMap.get(opp.Id).Primary_Proposal__c ||
                       opp.UseCase__c != oldOpportunitiesMap.get(opp.Id).UseCase__c || 
                      opp.Sales_Compliance_Country_Risk__c != oldOpportunitiesMap.get(opp.Id).Sales_Compliance_Country_Risk__c) 
                    {
                        System.debug('@@ 2. if 1 changed ');
                        if((opp.Proposal_Count__c > 0 || mapExemptionKeysEUFT.containsKey(opp.Id)) && 
                           ((opp.Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_CAMEL || 
                             opp.Sales_Compliance_Country_Risk__c == GlobalConstants.MEDIUM_CAMEL) ||
                            (opp.Sales_Compliance_Country_Risk__c == GlobalConstants.CAMEL_LOW && 
                             (opp.Trade_Classifications__c == GlobalConstants.DEFENSE 
                              || opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT))) &&
                           (mapOppwithEUFT.containsKey(opp.Id) || mapExemptionKeysEUFT.containsKey(opp.Id)) //U-2386
                          ) {
                              System.debug('@@ 3 in if ');
                              //opp.SBSStatus__c = GlobalConstants.TriggerRequired;
                              opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED; //U-2386
                              opp.SBSAutomationRequired__c = true;   //set SBSAutomationRequired__c flag U-2386
                              //opp.SBSMessage__c = null;
                              //opp.SBSResult__c = null;
                          }
                        else {
                            System.debug('@@ 4 in else ');
                            opp.SBSAutomationRequired__c = false;   //set SBSAutomationRequired__c flag U-2386
                        }
                    }
                }

					//Update SBSStatus if any field is changed 
                    if((opp.SBSStatus__c == GlobalConstants.Successful || opp.SBSStatus__c == GlobalConstants.PartiallyCompleted || opp.SBSStatus__c == GlobalConstants.Failed) && 
                       (opp.SBSPilot__c /*&& (opp.StageName == GlobalConstants.Create_Proposal || opp.StageName == GlobalConstants.Negotiate_and_Close)*/)){
                        if(opp.Purpose__c != oldOpportunitiesMap.get(opp.Id).Purpose__c ||
                           opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.Id).Trade_Classifications__c ||
                           opp.Primary_Proposal__c != oldOpportunitiesMap.get(opp.Id).Primary_Proposal__c ||
                           opp.UseCase__c != oldOpportunitiesMap.get(opp.Id).UseCase__c){
                               opp.SBSStatus__c = GlobalConstants.TriggerRequired;
                               opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED; //U-2386
                               opp.SBSMessage__c = null;
                               opp.SBSResult__c = null;
                               System.debug('## in 1st if '+opp);
                           }
                    }
                	System.debug('##opp.SBSPilot__c '+opp.SBSPilot__c);
                    System.debug('##opp.UseCase__c '+opp.UseCase__c);
                    System.debug('##opp.Purpose__c '+opp.Purpose__c);
                    System.debug('##opp.Sales_Compliance_Country_Risk__c '+opp.Sales_Compliance_Country_Risk__c);
                    System.debug('##opp.Trade_Classifications__c '+opp.Trade_Classifications__c);
                    System.debug('##mapExemptionKeysEUFT '+mapExemptionKeysEUFT);
                    System.debug('##mapOppwithEUFT_Threashold '+mapOppwithEUFT_Threashold);
					//set Sensitive_Business_Status and ManualSBStatusRequired flag   //U-2386 point-3  
                    if(opp.SBSPilot__c && (opp.Sales_Compliance_Country_Risk__c != oldOpportunitiesMap.get(opp.Id).Sales_Compliance_Country_Risk__c ||
                        opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.Id).Trade_Classifications__c ||
                        opp.UseCase__c != oldOpportunitiesMap.get(opp.Id).UseCase__c || opp.Purpose__c != oldOpportunitiesMap.get(opp.Id).Purpose__c)) {
                            if((opp.Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_LOWER || (opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT || opp.Trade_Classifications__c == GlobalConstants.DEFENSE) ||
                                (opp.UseCase__c != null && opp.UseCase__c.contains(GlobalConstants.Other)) || (opp.Purpose__c != null && opp.Purpose__c.contains(GlobalConstants.PURPOSE_SURVEILLANCE)) || 
                                mapExemptionKeysEUFT.containsKey(opp.Id) || mapOppwithEUFT_Threashold.containsKey(opp.Id)
                               ))
                            {
                                System.debug('## in 3rd if '+opp);
                                opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                                opp.ManualSBStatusRequired__c = true;  //set ManualSBStatusRequired__c flag U-2386
                                //ResetSecondaryApprovalStatus(opp);  //U-2391
                            }
                            else{
                                opp.ManualSBStatusRequired__c = false;
                                //ResetSecondaryApprovalStatus(opp);  //U-2391
 								//check if SBSStatus is not Trigger Required
                                if(!((opp.Proposal_Count__c > 0 || mapExemptionKeysEUFT.containsKey(opp.Id)) && 
                                     ((opp.Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_CAMEL || 
                                       opp.Sales_Compliance_Country_Risk__c == GlobalConstants.MEDIUM_CAMEL) ||
                                      (opp.Sales_Compliance_Country_Risk__c == GlobalConstants.CAMEL_LOW && 
                                       (opp.Trade_Classifications__c == GlobalConstants.DEFENSE 
                                        || opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT))) &&
                                     (mapOppwithEUFT.containsKey(opp.Id) || mapExemptionKeysEUFT.containsKey(opp.Id)) ))
                                {
                                    System.debug('##449 set not required');
                                    opp.Sensitive_Business_Status__c = GlobalConstants.Not_Required;
                                }
                            }
                        } 
                //}
            }
            System.debug('## end ');
        }
        catch(Exception e) {
            System.debug('##'+e.getLineNumber()+e.getMessage());
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.SetSBSStatus, GlobalConstants.OpportunityTriggerHepler2, true, e)));
        }   
    }
    
    
    /****************************************************************
* @author: Shubham Jagatap
* @date: 16-12-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: after update U-2284
************************************************************************/
    public static void setConditionsOnSA(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap)
    {
        Map<ID,List<String>> oppWithSetOfUseCaseMap =new Map<ID,List<String>>();
        String eufts;
        String useCases;
        try{
            Map<ID,Opportunity> oppMap =new Map<ID,Opportunity>();
            List<Secondary_Approval__c> saUpdateList = new List<Secondary_Approval__c>();
            List<Euft__c> euftUpdateList = new List<Euft__c>();
            Set<ID> activeSecondaryApprovalSet = new Set<ID>();
            
            for(Opportunity opp : newOpportunitiesList)
            {	
                if(opp.SBSResult__c != oldOpportunitiesMap.get(opp.Id).SBSResult__c && (opp.SBSResult__c == GlobalConstants.Success || opp.SBSResult__c == GlobalConstants.PartiallyCompleted) && opp.SBSPilot__c ){
                    activeSecondaryApprovalSet.add(opp.ActiveSensitiveBusinessApproval__c);
                    oppMap.put(opp.id,opp);
                    
                    if(opp.UseCase__c != null){
                        List<String> usecaseList  = new List<String>((opp.UseCase__c).split(GlobalConstants.SEMICOLON));
                        List<String> usecaseNameList  = new List<String>(); 
                        
                        Schema.DescribeFieldResult fieldResult = Opportunity.UseCase__c.getDescribe();  
                        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                        
                        for (String ucase : usecaseList) {
                            for (Schema.PicklistEntry f : ple) {  
                                System.debug('Label ='+ f.getLabel()+' === Value ='+ f.getValue());  
                                if(f.getValue() == ucase){
                                    usecaseNameList.add(f.getLabel());
                                }
                            }  
                            oppWithSetOfUseCaseMap.put(opp.id,usecaseNameList);
                        }
                        
                    }
                    
                }
            }
            
            if(!oppMap.isEmpty()){
                euftUpdateList = [SELECT Id,Opportunity__c,TechnologyRiskThreshold__c,blockList__c ,Name,EUFT__r.EUFTNumber__c
                                  from EUFT__c where Opportunity__c in : oppMap.keySet()
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }
            
            
             if(!activeSecondaryApprovalSet.isEmpty()){
                for(Secondary_Approval__c sa : [Select ID, Name, Approval_Status__c,Opportunity__c, Approval_Rejection_Reason__c,Conditions__c from Secondary_Approval__c 
                                                where ID IN : activeSecondaryApprovalSet and isActive__c = true])
                {     
                 if(!euftUpdateList.isEmpty()){
                     for(Euft__c eu : euftUpdateList)
                     { 
                         if(eufts == null){ eufts =  'EUFT Number : '+eu.EUFT__r.EUFTNumber__c + '\n'+ 'Block list : '+eu.BlockList__c + '\n\n';  }
                         else{eufts = eufts + 'EUFT Number : '+eu.EUFT__r.EUFTNumber__c + '\n'+ 'Block list : '+eu.BlockList__c + '\n\n';}
                     } 
                 }
                    
                    
                    if(oppWithSetOfUseCaseMap.size() > 0){
                        useCases = String.join(oppWithSetOfUseCaseMap.get(sa.Opportunity__c),'\n');
                    }else if(oppWithSetOfUseCaseMap.size() == 0){
                        useCases = 'No use cases selected on opportunity \n';
                    }
                    //////////////////////////////////////
                    sa.Conditions__c = System.label.SensitiveBusinessPreamble +'\n\n' 
                        + useCases + '\n\n'
                        + System.label.SensitiveBusinessTechnologyMitigations +'\n\n' + eufts;
                    /////////////////////////////////////
                 	saUpdateList.add(sa);
                }
                 
            }
            if(!saUpdateList.isEmpty()){
               update saUpdateList; 
            }
            
          
        }
        catch(Exception e) {
            System.debug('##'+e.getLineNumber()+e.getMessage());
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.SetSBSStatus, GlobalConstants.OpportunityTriggerHepler2, true, e)));
        }   
    }
    
    
/****************************************************************
* @author: Shubham Jagatap
* @date: 08-10-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: U-2035 Calls makeCallouttoExternal method on closed Won
************************************************************************/
    public static void sbsCalloutOnClosedWon(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        try {
            for(Opportunity opp : newOpportunities){
                if(opp.SBSPilot__c && (opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName && opp.StageName == GlobalConstants.oppStageClosedWon)){
                    makeCallouttoExternal1(opp.Id);
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.sbsCalloutOnClosedWon, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
    }
    
    /****************************************************************
* @author: Shubham Jagatap
* @date: 07-11-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: U-2035 Set Minimum Purpose Risk field on Opportunity from Purpose Custom Setting
************************************************************************/
    public static void setSBSRiskValues(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        List<String> purposeValuesList = new List<String>();
        List<Purpose__c> purposeCustomSetting = new List<Purpose__c>();
        Map<String,String> mapPurposeWithName = new Map<String,String>();
        
        purposeCustomSetting = Purpose__c.getall().values();
        for(Purpose__c p : purposeCustomSetting){
            mapPurposeWithName.put(p.Purpose__c,p.Name);
        }
        try {                                   
            for(Opportunity opp : newOpportunities){
                List<Decimal> riskValuesSet = new List<Decimal>();
                if(opp.Purpose__c != oldOpportunitiesMap.get(opp.Id).Purpose__c ){
                    if(opp.Purpose__c != null){
                        purposeValuesList = opp.Purpose__c.split(GlobalConstants.SEMICOLON);
                        for(String p: purposeValuesList){
                            Decimal r = Purpose__c.getValues(mapPurposeWithName.get(p)).RiskValue__c ;
                            riskValuesSet.add(r);
                        }
                        riskValuesSet.sort();
                        opp.MinimumPurposeRisk__c = riskValuesSet[0]; 
                    }
                    else{
                        opp.MinimumPurposeRisk__c = null;
                    }
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.setSBSRiskValues, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
    }
/****************************************************************
* @author: Shubham kadam
* @date: 08-10-2020
* @param: newOpportunitiesList
* @description: U-2035 Create EUFT Record when Opportunity is Created
************************************************************************/
    public static void createEUFTRecord(List<Opportunity> newOpportunities) {
        try {            
            List<EUFT__c> EUFTInsertList = new List<EUFT__c>();
            
            for(Opportunity opp : newOpportunities)
            {
                EUFT__c EUFTobj = new EUFT__c();
                EUFTobj.EUFT__c = opp.AccountId;
                EUFTobj.Opportunity__c = opp.Id;
                EUFTInsertList.add(EUFTobj);
            }
            if(!EUFTInsertList.isEmpty()) {
                database.insert(EUFTInsertList); 
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.createEUFTRecord, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
    }
    
/****************************************************************
* @author: Amjad Khan
* @date: 08-10-2020
* @param: Opp RecordId
* @description: 
************************************************************************/    
    public static void makeCallouttoExternal(Id recID) { 
        //System.debug('in callout');
        //recID='0063O000007f5EAQAY';
        opportunity opp=[select id,StageName,OpportunityNumber__c,SBSResult__c,SBSStatus__c,SBSMessage__c from opportunity where id=:recID];
        string body='<notifications>    <Notification>        <sObject>            <fieldsToNull>test</fieldsToNull>            <Id>'+opp.id+'</Id>            <OpportunityNumber__c>'+opp.OpportunityNumber__c+'</OpportunityNumber__c>            <StageName>'+opp.StageName+'</StageName>        </sObject>    </Notification></notifications>';
        system.debug('body='+body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GlobalConstants.SBS_Endpoint);
        request.setHeader(GlobalConstants.HTTP_HEADER_FIELD_NAME_CONTENT_TYPE,GlobalConstants.HTTP_HEADER_FIELD_CONTENT_TYPE_VALUE_APPLICATION_XML);
        request.setBody(body);
        request.setMethod(GlobalConstants.HTTP_METHOD_POST);
        system.debug('request='+request);
        HttpResponse response = http.send(request);
        string jsonRes=response.getBody();
        integer resCode=response.getStatusCode();
        System.debug('jsonResponse: '+jsonRes);
        system.debug('SSSSSS='+response.getStatusCode());
        //Map<String, object> m = (Map<String, object>)JSON.deserializeUntyped(jsonRes);
        //string resultmessage=string.valueof(m.get('message'));
        //system.debug('resultmessage=='+resultmessage);
        //Boolean result=resultmessage.contains('Successfully');
        if(resCode==200 && opp.StageName!=GlobalConstants.ClosedWon){
            opp.SBSStatus__c = GlobalConstants.In_Progress;
            opp.SBSResult__c = null;
          }
        opp.SBSMessage__c = jsonRes;
        update opp;
    }
    
    /****************************************************************
* @author: Amjad Khan
* @date: 08-10-2020
* @param: Opp RecordId
* @description: 
************************************************************************/ 
    @Future(callout=true)
    public static void makeCallouttoExternal1(Id recID) { 
        //System.debug('in callout');
        //recID='0063O000007f5EAQAY';
        opportunity opp=[select id,name, StageName,OpportunityNumber__c,SBSResult__c,SBSStatus__c,SBSMessage__c, 
                         Customer_Unit__c, MarketArea__c, EndCustomerName__c, Legacy_Estimated_Deal_Value__c,CloseDate
                         from opportunity where id=:recID];
        string body='<notifications>    <Notification>        <sObject>            <fieldsToNull>test</fieldsToNull>            <Id>'+opp.id+'</Id>            <OpportunityNumber__c>'+opp.OpportunityNumber__c+'</OpportunityNumber__c>            <StageName>'+opp.StageName+'</StageName>        </sObject>    </Notification></notifications>';
        system.debug('body='+body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GlobalConstants.SBS_Endpoint);
        request.setHeader(GlobalConstants.HTTP_HEADER_FIELD_NAME_CONTENT_TYPE,GlobalConstants.HTTP_HEADER_FIELD_CONTENT_TYPE_VALUE_APPLICATION_XML);
        request.setBody(body);
        request.setMethod(GlobalConstants.HTTP_METHOD_POST);
        system.debug('request='+request);
        HttpResponse response = http.send(request);
        string jsonRes=response.getBody();
        integer resCode=response.getStatusCode();
        System.debug('jsonResponse: '+jsonRes);
        system.debug('SSSSSS='+response.getStatusCode());
        //Map<String, object> m = (Map<String, object>)JSON.deserializeUntyped(jsonRes);
        //string resultmessage=string.valueof(m.get('message'));
        //system.debug('resultmessage=='+resultmessage);
        //Boolean result=resultmessage.contains('Successfully');
        if(resCode==200 && opp.StageName!=GlobalConstants.ClosedWon){
            opp.SBSStatus__c = GlobalConstants.In_Progress;
            opp.SBSResult__c = null;
        }
        if(resCode != 200){
            System.debug('##closed won and failed : '+resCode+' -- stage: '+opp.StageName);
            if(opp.StageName==GlobalConstants.ClosedWon){
                 OpportunityTriggerHepler2.sendEmailToAOForSBS(opp);
            }
            else if(opp.StageName != GlobalConstants.ClosedWon){
                opp.SBSResult__c = GlobalConstants.Failed;
            }
        }
        opp.SBSMessage__c = jsonRes;
        update opp;
    }
    
    /****************************************************************
* @author: Shubham kadam
* @date: 15-10-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: U-2035 - This method will update ConfirmEndCustomer__c checkbox based upon Pilot/non-Pilot type 
************************************************************************/
    public static void addErrorOnConfirmEndCustomer(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        try {
            Boolean flag = false;
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            Set<Id> setAccId = new Set<Id>();
            Map<Id,Account> mapOppwithAcc;
            Map<Id,List<EUFT__c>> mapOppwithEUFTList = new Map<Id,List<EUFT__c>>();
            
            /*for(Opportunity opp : newOpportunities) {
                if((opp.ConfirmEndCustomer__c && opp.ConfirmEndCustomer__c != oldOpportunitiesMap.get(opp.Id).ConfirmEndCustomer__c) || 
                   (!opp.ConfirmEndCustomer__c && opp.StageName != oldOpportunitiesMap.get(opp.Id).stageName))
                {*/
                    for(Opportunity opp1 : newOpportunities) {
                        setAccId.add(opp1.AccountId);
                    }
                    if(!setAccId.isEmpty()){
                        mapOppwithAcc = new Map<Id,Account>([select Id, Name, EUFTNumber__c, SBSPilot__c from Account where id in :setAccId
                                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
                    }
                    
                    List<Opportunity> oppList = [Select Id, Name, Ship_To_Countries__c,
                                                 (select Id, Name, Opportunity__c, EUFT__r.BillingCountry, EUFT__r.EUFTNumber__c from EUFTs__r) 
                                                 from Opportunity where Id IN :newOpportunities  
                                                 Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]; 
                    
                    for(Opportunity opp1 : oppList)
                    {
                        mapOppwithEUFTList.put(opp1.Id,opp1.EUFTs__r );
                    }
               //}
            //}
            
            for(Opportunity opp : newOpportunities) {               
                if(!mapOppwithAcc.isEmpty() && mapOppwithAcc.containsKey(opp.AccountId) && !mapOppwithAcc.get(opp.AccountId).SBSPilot__c) {
                    //if(!mapOppwithEUFTList.get(opp.Id).isEmpty()) {
                        opp.ConfirmEndCustomer__c = true;
                    /*}
                    else if(mapOppwithEUFTList.get(opp.Id).isEmpty() && (opp.StageName == GlobalConstants.Define_CustomerValue && 
                                                                         opp.StageName != oldOpportunitiesMap.get(opp.Id).stageName)) {                                           
                    	opp.addError('Please create EUFT record');
                    }*/
                }
                else if(mapOppwithAcc.containsKey(opp.AccountId) && mapOppwithAcc.get(opp.AccountId).SBSPilot__c) {
                    for(EUFT__c eu : mapOppwithEUFTList.get(opp.Id)) {
                        if(eu.EUFT__r.EUFTNumber__c != null) {
                            flag = true;
                            break;
                        }
                    }
                    if(!flag && (opp.ConfirmEndCustomer__c && opp.ConfirmEndCustomer__c != oldOpportunitiesMap.get(opp.Id).ConfirmEndCustomer__c)) {
                        opp.addError(GlobalConstants.addErrorOnConfirmEndCustomerError1);
                    }
                    else if(!opp.ConfirmEndCustomer__c && opp.StageName != oldOpportunitiesMap.get(opp.Id).stageName) {
                        opp.addError(GlobalConstants.addErrorOnConfirmEndCustomerError2);
                    }
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.addErrorOnConfirmEndCustomer, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
    }

    
/****************************************************************
* @author: Shubham Jagatap
* @date: 08-10-2020
* @User Story:  2072
* @description:  This mehod fetches Account details from Opportunity Id
*****************************************************************/     
    @AuraEnabled
    public static Account getAccDetails(String recordId) {
        Id AccId = [Select Id, AccountId from Opportunity where Id =:recordId LIMIT 1].AccountId;
        return [SELECT Id, Name,SBSPilot__c  FROM Account where Id =:AccId LIMIT 1];
    }
/****************************************************************
* @author: Shubham Jagatap
* @date: 08-10-2020
* @User Story:  2072
* @description:  This mehod fetches Opportunity details from Opportunity Id
*****************************************************************/     
    @AuraEnabled
    public static Opportunity getOppDetails(String recordId) {
        return [SELECT Id, Name, SBSStatus__c,SBSPilot__c, MarketArea__c  FROM Opportunity where Id =:recordId LIMIT 1];
    }
/****************************************************************
* @author: Shubham Jagatap
* @date: 08-10-2020
* @User Story:  2072
* @description:  This mehod calls future callout method makeCallouttoExternal
*****************************************************************/     
 
    @AuraEnabled
    public static String  makeCallout(Id recID){
        
        String errorMessage = '';
        Opportunity opp = [Select Id, UseCase__c, Purpose__c from Opportunity where Id = : recID Limit 1];
        
        if(opp.UseCase__c == null){errorMessage = GlobalConstants.Error_UseCase_CannotBeBlank;} 
        if(opp.Purpose__c == null){errorMessage = GlobalConstants.Error_Purpose_CannotBeBlank;}
        if(opp.Purpose__c == null && opp.UseCase__c == null){errorMessage = GlobalConstants.Error_PurposeOrUsecase_CannotBeBlank;}
        for(EUFT__c eu : [select Id, Name, Opportunity__c,TechnologyRiskThreshold__c from EUFT__c where Opportunity__c =: recID])
        {
            if(eu.TechnologyRiskThreshold__c == null){
                errorMessage = errorMessage + GlobalConstants.Error_TechnologyRiskThreshold_CannotBeBlank;
                break;}
        }
        if(String.isBlank(errorMessage)){
            makeCallouttoExternal(recID);    
        }
        return errorMessage;
    }
    
    /****************************************************************
* @author: Manu Singhal
* @date: 20-10-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: U-1666 - This will update the Override_Deal_Value_and_Margin__c to true for simple oppty
************************************************************************/
    public static void updateOverrideCheckboxOnSimpleOppty(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        try {
            for(Opportunity opp:newOpportunities){
                if(opp.RecordTypeId == GlobalConstants.simpleOppRecordTypeId && (opp.Deal_Value__c != oldOpportunitiesMap.get(opp.id).Deal_Value__c || opp.Margin__c != oldOpportunitiesMap.get(opp.id).Margin__c)){
                    opp.Override_Deal_Value_and_Margin__c = true;
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.createEUFTRecord, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
}
        /****************************************************************
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 09-12-2020
* @User Story: 1901
* @description: This method will create SDR Records based on the parameters passed
*****************************************************************/
public static Sales_Decision_Record__c createSDRRecords(boolean isMinorFlow , String Type, Id opptyId , Map<ID, Opportunity> newOpportunitiesMap ){
    Sales_Decision_Record__c  sdr = new Sales_Decision_Record__c();
    sdr.Sales_Decision_Type__c = Type;
    sdr.Sales_Decision_Date__c = system.today();
    sdr.Name = Type ;
    sdr.Opportunity__c = opptyId; 
    sdr.Source__c = GlobalConstants.AUTOMATIC;
    if(isMinorFlow || newOpportunitiesMap.get(opptyId).Not_Deviating_from_Parent__c || newOpportunitiesMap.get(opptyId).MarketArea__c == GlobalConstants.MELA)
    {
        sdr.IsAutoGen__c = true; 
        sdr.UsedForStageProgression__c=true;
        sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED; 
        sdr.Support_Information_and_Material__c = GlobalConstants.SUPPORTTEXT;
    }
    else 
    {
        sdr.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
    }
    return sdr;
}
    
/* @author: Amit Ojha
* @date: 09-11-2020
* @User Story: 2263
* @description: This method will set OpportunityOwner for Lighthouse created Opportunities based on Owner in the request
*****************************************************************/
     public static void setOpportunityOwnerSecond( List<Opportunity> newOpportunities){
         List<Opportunity> oppListwithoutOwnerId = new List<Opportunity>();
         Set<Id> signumList = new Set<Id>();
         Map<Id, User> ownerMap;// = new Map<Id, User>();
        try{

                for (opportunity opp1: newOpportunities) {                     
                    if(opp1.Source_System__c==GlobalConstants.Lighthouse || opp1.Source_System__c==GlobalConstants.RB_PPMID_88159)
                    { 
                     //   system.debug('************* 1 *************'+opp1.OwnerId);
                        signumList.add(opp1.OwnerId);   
                      //  system.debug('************* 11 *************'+signumList);
                    }
                }
            
            if (!signumList.isEmpty()){
              //  system.debug('************* 2 *************');
              ownerMap = new Map<Id, User>([ Select Id, Profile.Name From User where Id IN: signumList ]);
               // system.debug('************* 22 *************'+ownerMap);
            }
            
            for (opportunity opp1: newOpportunities) {                
                if(opp1.Source_System__c==GlobalConstants.Lighthouse || opp1.Source_System__c==GlobalConstants.RB_PPMID_88159)
                    { 
                        // system.debug('************* 3 *************'+ownerMap.get(opp1.OwnerId).Profile.Name);
                          if(ownerMap.get(opp1.OwnerId).Profile.Name  == GlobalConstants.INTEGRATIONUSERPROFILENAME){
                             // system.debug('************* 33 *************'+ownerMap.get(opp1.OwnerId).Profile.Name);
                              oppListwithoutOwnerId.add(opp1);
                          }
                    }
            }
            if (!oppListwithoutOwnerId.isEmpty()){
                //system.debug('************* 4 *************'+oppListwithoutOwnerId);
                OpportunityTriggerHelper.setOpportunityOwner(oppListwithoutOwnerId);
            }

        } catch (Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,GlobalConstants.setOpportunityOwner, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
	/****************************************************************
* @author: Amit Ojha
* @date: 21-01-2021
* @param: newOpportunitiesList
* @description: U-2152 ONLY MELA & MANA: Do not automatically update the probability of an Opportunity when changing the Opportunity stage
*****************************************************************/
    public static void updateProbablity(List<Opportunity> newOpportunities) {
        try{
           // system.debug('********************* 1 **********************');
            List<Opportunity> opptyList = new List<Opportunity>();
            for (Opportunity newOppty : newOpportunities) {
               // system.debug('********************* 2 **********************');
                if (newOppty.ManualProbability__c != null && (newOppty.MarketArea__c.equals(GlobalConstants.MELA) || newOppty.MarketArea__c.equals(GlobalConstants.MANA))) {
                    if(newOppty.stageName.equals(GlobalConstants.oppStageClosedWon) || newOppty.stageName.equals(GlobalConstants.oppStageClosedLost)
                       || newOppty.stageName.equals(GlobalConstants.oppStageClosedDuplicate) || newOppty.stageName.equals(GlobalConstants.oppStageClosedWithdrawn)){
                        //   system.debug('********************* 3 ********************** '+newOppty.ManualProbability__c);
                           newOppty.ManualProbability__c = newOppty.Probability;
                        //   system.debug('********************* 4 ********************** '+newOppty.Probability);
                       }else {
                          // system.debug('********************* 3 B ********************** '+newOppty.Probability);
                           newOppty.Probability = newOppty.ManualProbability__c;
                          // system.debug('********************* 4 B ********************** '+newOppty.ManualProbability__c);
                       }
                }
            }
        }catch(Exception e){
           // system.debug('********************* 5 ********************** '+e);
		   }
    }
    /****************************************************************
* @author: Shubham Kadam
* @date: 14-12-2020
* @param: newOpportunities, oldOpportunitiesMap
* @description: U-2399, U-2259, U-2385, U-2389 This Method will pick the Block List values from the EUFT__c.BlockList__c, 
and concatenate the unique values from it to the existing Consolidated Block List on Account
*****************************************************************/
    public static void updateConsolidatedBlockListOnAccount(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap,Map<ID, Opportunity> newOpportunitiesMap){
        Set<ID> closedWonOppIDSet = new Set<ID>();
        set<ID>oppIDset=new set<ID>();
        map<Id, EUFT__c> mapOppwithEUFT = new map<Id, EUFT__c>();		
        Map<ID,Set<String>> mapOfAccountWithBlockList = new Map<ID,Set<String>>();
        List<Account> updateAccount = new List<Account>();
        Boolean flag1 = false;
        Boolean flag2 = false;
        Set<ID> activeSecondaryApprovalSet = new Set<ID>();
        List<Secondary_Approval__c> updateSAList = new List<Secondary_Approval__c>();
        
        try{
            for(Opportunity opp : newOpportunities) {
                if(opp.StageName == GlobalConstants.ClosedWon && opp.StageName != oldOpportunitiesMap.get(opp.id).StageName && opp.SBSPilot__c) {
                    closedWonOppIDSet.add(opp.ID);
                }
                //U-2259,U-2385,U-2389 SBS status change - changes start
                if(/*(opp.StageName == GlobalConstants.oppStg3 || opp.StageName == GlobalConstants.oppStg4) &&*/ opp.SBSPilot__c 
                   && opp.SBSStatus__c != oldOpportunitiesMap.get(opp.id).SBSStatus__c && (opp.SBSStatus__c == GlobalConstants.Failed || opp.SBSStatus__c == GlobalConstants.Successful || opp.SBSStatus__c == GlobalConstants.PartiallyCompleted)) {
                       activeSecondaryApprovalSet.add(opp.ActiveSensitiveBusinessApproval__c);
                       oppIDset.add(opp.id);
                       flag1 = true;
                   }
                //if flag2
                if(opp.StageName != oldOpportunitiesMap.get(opp.id).StageName /*&& (opp.StageName == GlobalConstants.oppStg4 || opp.StageName == GlobalConstants.oppStg3 )*/ && opp.SBSPilot__c) {
                    activeSecondaryApprovalSet.add(opp.ActiveSensitiveBusinessApproval__c);
                    flag2 = true;
                }
            }
            //get blocklists from EUFT
            if(!oppIDset.isEmpty()){
                for(EUFT__c eu : [SELECT Id,Opportunity__c ,BlockList__c
                                  from EUFT__c where Opportunity__c in : oppIDset
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(eu.BlockList__c != null){
                        mapOppwithEUFT.put(eu.Opportunity__c, eu); 
                    }
                }   
            }
            //Update fields on Secondary Approval
            if(!activeSecondaryApprovalSet.isEmpty()){
            for(Secondary_Approval__c sa : [Select ID, Name, Approval_Status__c,Opportunity__c,Opportunity__r.Sensitive_Business_Status__c, Approval_Rejection_Reason__c from Secondary_Approval__c 
                                            where ID IN : activeSecondaryApprovalSet and isActive__c = true
                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                if(flag1 && sa.Approval_Status__c == GlobalConstants.Pending){
                    if(newOpportunitiesMap.get(sa.Opportunity__c).SBSStatus__c == GlobalConstants.Successful && sa.Approval_Rejection_Reason__c == GlobalConstants.Submittedforautoapproval){
                        if(!mapOppwithEUFT.containsKey(sa.Opportunity__c)){
                            sa.Approval_Status__c = GlobalConstants.APPROVED;
                            sa.Approval_Rejection_Reason__c = GlobalConstants.APPROVED;
                            updateSAList.add(sa);
                            //Set the sa.Conditions__c as per the logic provided.
                        }
                        
                        if( mapOppwithEUFT.containsKey(sa.Opportunity__c)){
                            sa.Approval_Status__c = GlobalConstants.APPROVED;
                            sa.Approval_Rejection_Reason__c = GlobalConstants.Approvedwithcondition;
                            updateSAList.add(sa);
                            //Set the sa.Conditions__c as per the logic provided.
                        }
                    }
                    if( newOpportunitiesMap.get(sa.Opportunity__c).SBSStatus__c == GlobalConstants.Failed || 
                       newOpportunitiesMap.get(sa.Opportunity__c).SBSStatus__c == GlobalConstants.PartiallyCompleted || 
                       sa.Approval_Rejection_Reason__c == GlobalConstants.Submittedforsemiautoapproval)
                    {
                        sa.Approval_Status__c = GlobalConstants.Pending;
                        sa.Approval_Rejection_Reason__c = GlobalConstants.Submittedformanualapproval;
                        updateSAList.add(sa);
                    }
                }
                if(flag2){
                    sa.Approval_Status__c = GlobalConstants.COMPLETED;
                    sa.Opportunity__r.Sensitive_Business_Status__c = GlobalConstants.APPROVED;
                    if(sa.Approval_Rejection_Reason__c == GlobalConstants.APPROVED){
                        sa.Approval_Rejection_Reason__c = GlobalConstants.ACCEPTED_APPROVAL;
                        updateSAList.add(sa);
                    }
                    else if(sa.Approval_Rejection_Reason__c == GlobalConstants.Approvedwithcondition){
                        sa.Approval_Rejection_Reason__c = GlobalConstants.AcceptedApprovalwithconditions;
                        updateSAList.add(sa);
                    }
                    else if(sa.Approval_Rejection_Reason__c == GlobalConstants.DismissedbySBteam){
                        sa.Approval_Rejection_Reason__c = GlobalConstants.AcceptedDismissal;
                        updateSAList.add(sa);
                    }
                }
            }
            }
            if(!updateSAList.isEmpty()) {
                update updateSAList;
            }
            //U-2259, U-2385, U-2389 - changes end
            if(!closedWonOppIDSet.isEmpty()){
            for(EUFT__c eu : [Select Id,EUFT__c,BlockList__c from EUFT__c where Opportunity__c IN : closedWonOppIDSet
                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
            {
                String blockList = eu.BlockList__c;
                Set<String> ss = new Set<String>();
                if(blockList!=null) {
                    ss.addAll(blockList.split(GlobalConstants.COMMA)); 
                }
                if(mapOfAccountWithBlockList.containsKey(eu.EUFT__c)) {
                    Set<String> s = mapOfAccountWithBlockList.get(eu.EUFT__c);
                    ss.addAll(s);
                    mapOfAccountWithBlockList.put(eu.EUFT__c, ss);
                } 
                else {
                    mapOfAccountWithBlockList.put(eu.EUFT__c, ss);
                }
            }
          }  
            
            if(!mapOfAccountWithBlockList.isEmpty()){
            for(Account acc : [Select Id, Name, ConsolidatedBlockList__c from Account where Id IN: mapOfAccountWithBlockList.keySet()
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
            {
                if(mapOfAccountWithBlockList.containsKey(acc.ID)) {
                    List<String> oneString = new List<String>();
                    Set<String> finalString = new Set<String>();
                    List<String> finalStr;
                    
                    oneString.addAll(mapOfAccountWithBlockList.get(acc.ID));
                    finalString = new Set<String>(oneString);
                    finalStr = new List<String>(finalString);
                    String joinedString = String.join(finalStr, GlobalConstants.COMMA);
                    acc.ConsolidatedBlockList__c = joinedString;
                    updateAccount.add(acc);
                }
            }
         }
            
            if(!updateAccount.isEmpty()) {
                update updateAccount;
            }
            
            
            
        } catch (Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,GlobalConstants.updateConsolidatedBlockListOnAccount, 
                                                                       GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    
       /****************************************************************
* @author: Shubham Jagatap
* @date: 14-12-2020
* @param: secApprovalSet
* @description: U-2385 Reset Secondary Approval Status
************************************************************************/
    Public static void ResetSecondaryApprovalStatus(set<String> secApprovalSet){
        try{
            List<Secondary_Approval__c> salistToUpdate = new List<Secondary_Approval__c>();
            List<Secondary_Approval__c> saList = [Select id,name, Approval_Status__c, Approval_Rejection_Reason__c from Secondary_Approval__c where id in :secApprovalSet];
            
            for(Secondary_Approval__c sa : saList){
                if( sa.Approval_Status__c == GlobalConstants.APPROVED ||
                   (sa.Approval_Status__c == GlobalConstants.Pending 
                    && sa.Approval_Rejection_Reason__c != GlobalConstants.Submittedformanualapproval))
                {
                    sa.Approval_Status__c = GlobalConstants.Tobesubmitted;
                    sa.Approval_Rejection_Reason__c = GlobalConstants.Tobesubmitted;
                    salistToUpdate.add(sa);
                }
                
            }
            if(salistToUpdate != null)
            {
                update salistToUpdate;
            }
        }catch(Exception e){
            System.debug('## Error '+e.getMessage()+' -- '+e.getLineNumber());
        } 
    }
    
     /****************************************************************
* @author: Shubham Jagatap
* @date: 14-12-2020
* @param: newOpportunities, oldOpportunitiesMap
* @description: U-2385 Call Reset Secondary Approval Status
************************************************************************/
    public static void CallResetSecondaryApprovalStatus(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        try {
            Set<String> secApprovalSet = new Set<String>();
            Set<Id> OppToUpdateSet = new Set<Id>();   //TriggerEUFT
            List<EUFT__c> EUFTToUpdateList = new List<EUFT__c>();   //TriggerEUFT
            for(Opportunity opp:newOpportunities){
                if(opp.SBSPilot__c &&  (opp.Purpose__c != oldOpportunitiesMap.get(opp.id).Purpose__c 
                   || opp.Sales_Compliance_Country_Risk__c != oldOpportunitiesMap.get(opp.id).Sales_Compliance_Country_Risk__c ||
                   opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.id).Trade_Classifications__c ||
                   opp.UseCase__c != oldOpportunitiesMap.get(opp.id).UseCase__c ||
                   opp.Proposal_Count__c != oldOpportunitiesMap.get(opp.id).Proposal_Count__c )){
                       if(opp.ActiveSensitiveBusinessApproval__c != null)
                       {
                        secApprovalSet.add(opp.ActiveSensitiveBusinessApproval__c);
                       }
                   }
                //////TriggerEUFT start
                if(opp.Purpose__c != oldOpportunitiesMap.get(opp.Id).Purpose__c){
                    OppToUpdateSet.add(opp.id);
                }
                ////// TriggerEUFT end
            }
            if(!secApprovalSet.isEmpty()){
                ResetSecondaryApprovalStatus(secApprovalSet);
            }
            //////TriggerEUFT start            
            if(!OppToUpdateSet.isEmpty()){
                for(EUFT__c eu : [SELECT Id,Opportunity__c,TechnologyRiskThreshold__c, ExemptionKeys__c, EUFT__r.ConsolidatedBlockList__c 
                                  from EUFT__c where Opportunity__c in : OppToUpdateSet
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    EUFTToUpdateList.add(eu);
                }
            }
            if(!EUFTToUpdateList.isEmpty()){
                update EUFTToUpdateList;
            }
            ////// TriggerEUFT end
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, GlobalConstants.createEUFTRecord, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
    }
    
    /****************************************************************
* @author: Shubham kadam
* @date: 05-01-2021
* @param: opp
* @description: U-2282 this method will send email when SBS status is failed for closed won Opportunity
************************************************************************/
    public static void sendEmailToAOForSBS(Opportunity opp) {
        try {
            String SBSEmailRecipents = System.label.SBSEmailRecipents;
            Set<String> emailids = new Set<String>(SBSEmailRecipents.split(';'));
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> sendTo = new List<String>();
            for(String eId :emailids){
                sendTo.add(eId);
            }
            mail.setToAddresses(sendTo);
            
            mail.setSubject('SBS Callout Failed for '+opp.Name +' ('+opp.OpportunityNumber__c+')');
            String body = 'Hi,'+'<br/>'+'<br/>'+'<br/>';
            body += 'Please note that the SBS Callout for Closed-Won Opportunity - '+opp.Name+ ' (' +opp.OpportunityNumber__c +') has been Failed.'+'<br/>'+'<br/>';
            body += 'Please find the Opportunity Record here in Salesforce: <a href='+GlobalConstants.OrgbaseURL+'/'+opp.Id+'>Link </a>'+'<br/>'+'<br/>';
            body += 'Opportunity Details : ' + '<br/>'+'<br/>';
            body += 'Opportunity ID : '+opp.Id + '<br/>';
            body += 'Opportunity Name : '+opp.Name + '<br/>';
            body += 'Opportunity Number : '+opp.OpportunityNumber__c + '<br/>';
            body += 'CU : '+opp.Customer_Unit__c+ '<br/>';
            body += 'MA : '+opp.MarketArea__c + '<br/>';
            body += 'Account : '+opp.EndCustomerName__c + '<br/>';
            body += 'Total Deal Value : '+opp.Legacy_Estimated_Deal_Value__c + '<br/>';
            body += 'Close Date : '+(opp.CloseDate).format() + '<br/>'+'<br/>'+'<br/>';
            body += 'Best Regards, ' + '<br/>' +'Salesforce';
            mail.setHtmlBody(body);
            
            mails.add(mail);
            
            Messaging.sendEmail(mails);
		}
		catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHepler2, 
                                                                       GlobalConstants.sendEmailToAOForSBS, GlobalConstants.OpportunityTriggerHepler2, true, e)));  
        }
	}

}