/******************************************************************************************
*
*      	@author       : Ananth Chilapally
*      	@date         : 
		@description  : Handler Class for OpportunityTrigger
		@testClass    : OpportunityTriggerHandlerTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
Ananth Chilapally		07-10-2019				Initial Version
Amit					09-06-2020				U-1819 - updateCloseDateandProposalSubDate Method Called
Shubham Kadam			10-06-2020				U-1825 - setUsedForStageProgression Method Called
Shubham Jagatap			16-07-2020				U-1991 - Profile related condition updated with "AccessSettings__c" custom setting
Richa Gupta             17-07-2020              U-1889 - Replace Process Builders with Triggers - OPPORTUNITY
Shubham Kadam			14-12-2020				U-2399 - updateConsolidatedBlockListOnAccount Method Called
******************************************************************************************/

public with sharing class OpportunityTriggerHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean isFromBachJob ;
    public static boolean isFromUploadAPI=false;
    public static boolean isUpdated = true;
    public static boolean emailSent = true;
    public static boolean tradeFlag = true;
    public static boolean TCFlag = false; //D-2744
       
    public OpportunityTriggerHandler(boolean isExecuting, integer size){
        this.isExecuting = isExecuting;
        batchSize = size;
    }
            
    public void onBeforeInsert(List<Opportunity> newOpportunities){ 	
        Try{
        //U-1593
       // OpportunityTriggerHelper.updateShipToCountryText(newOpportunities, null, true);
       // OpportunityOutboundHelper.resetCloneOpps(newOpportunities); 
       //U-1889
        OpportunityTriggerHepler2.recordTypeAssignment(newOpportunities);
        OpportunityTriggerHepler2.setAccountAndCurrency(newOpportunities);
        OpportunityTriggerHepler2.setOpportunityApprovers(newOpportunities, null, true);
        CloneOpportunityHelper.resetClonedOppties(newOpportunities);
        OpportunityPriceBookHelper.populatePriceBookIdOnNewOpp(newOpportunities);
        OpportunityChildSumDeaValuePercentHelper.populateSalesOBTargetsandActualsOnNewOpp(newOpportunities);
        //U-1022
        OpportunityChildSumDeaValuePercentHelper.updateMAHeadandBAHeads(newOpportunities, new Map<id,Opportunity>());
       // U-1060, U-1056
        OpportunityTriggerHelper.updateFinancialComplianceAuditScope(newOpportunities);
      //  OpportunityTriggerHelper.setOpportunityOwner(newOpportunities);
		OpportunityTriggerHepler2.setOpportunityOwnerSecond(newOpportunities);
        system.debug('newOpportunities List&& b4 insert'+newOpportunities[0].KAM__c);
        OpportunityTriggerHelper.setGCUKAMonOppty(newOpportunities, null, true);
        //U-1055
        OpportunityTriggerHelper.setEndCustomer(newOpportunities);
        //U-1366
        OpportunityTriggerHelper.updateOpportunityTier(newOpportunities,new Map<ID, Opportunity>());
             //U-1859 ,D-3107 (change the sequence of methods) 
        OpportunityTriggerHelper.SetShipToCountries(newOpportunities);
         //U-0913
        if(emailSent)
        {
            //D-2744 - changes start
        	TCFlag = OpportunityTriggerHelper.sendEmailForTradeCompliance(newOpportunities,new Map<ID, Opportunity>(), false, true); //D-2744 - changes End
        }
        OpportunityTriggerHelper.calculateCountryRisk(newOpportunities,null);
            TradeComplianceHelper.updateCountryRiskOpptys(newOpportunities, new Map<ID, Opportunity>());
            OpportunityTriggerHelper.checkSensitiveProductsCheckbox(newOpportunities,new Map<ID, Opportunity>());
            OpportunityTriggerHelper.updateShipToCountryText(newOpportunities, null, true);
           // U-1795
            OpportunityTriggerHepler2.setParentOpportunityAsContractOpportunity(newOpportunities);
        }catch(Exception e){	}
        }
    public void onAfterInsert(List<Opportunity> newOpportunities){       
        //U-2035
        OpportunityTriggerHepler2.createEUFTRecord(newOpportunities);
        
        // OpportunityOutboundHelper.pushOppPublishMessageAfterInsert(newOpportunities);

        //Calling below class to update Sum of Deal values on Frame from child Opportunities - After Insert
        //OpportunityChildSumDeaValuePercentHelper.sumChildOppsDealValue(newOpportunities);       
     
    }
    
    public void onBeforeUpdate( List<Opportunity> newOpportunities, List<Opportunity> oldOpportunities, Map<ID, Opportunity> newOpportunitiesMap , Map<ID, Opportunity> oldOpportunitiesMap ){
        Try{
            //U-2270
            OpportunityTriggerHepler2.setSBSRiskValues(newOpportunities, oldOpportunitiesMap);
            //U-1666
            OpportunityTriggerHepler2.updateOverrideCheckboxOnSimpleOppty(newOpportunities, oldOpportunitiesMap);
            //U-2072
            OpportunityTriggerHepler2.setSBSStatus(newOpportunities, oldOpportunitiesMap);
            //U-2035
            Boolean checkflag = false;
            for(Opportunity opp : newOpportunities) {
                if((opp.ConfirmEndCustomer__c && opp.ConfirmEndCustomer__c != oldOpportunitiesMap.get(opp.Id).ConfirmEndCustomer__c) || 
                   (!opp.ConfirmEndCustomer__c && opp.StageName != oldOpportunitiesMap.get(opp.Id).stageName))
                {
                    checkflag=true;
                }
            }   
            if(checkflag){
            OpportunityTriggerHepler2.addErrorOnConfirmEndCustomer(newOpportunities, oldOpportunitiesMap);
        	}
       //U-1593
        OpportunityTriggerHelper.updateShipToCountryText(newOpportunities, oldOpportunitiesMap, false);
        //D-2780 changed the order of execution of order
        OpportunityTriggerHandler.triggerOpportunitiesUpdate(newOpportunities, oldOpportunities, newOpportunitiesMap, oldOpportunitiesMap);
        //U-1413
        OpportunityTriggerHelper.VerifyOpportunityProgression(newOpportunities,oldOpportunitiesMap);
        //U-1366
        OpportunityTriggerHelper.updateOpportunityTier(newOpportunities,oldOpportunitiesMap);
       // OpportunityTriggerHelper.updateOpportunityReadyForOQB(newOpportunities,oldOpportunitiesMap);
        //U-1267 
        OpportunityTriggerHelper.setForecastCategory(newOpportunities,oldOpportunitiesMap);
		//SDR set approved stage
        //D-2203
       if(tradeFlag)
        {
        OpportunityTriggerHelper.updateOppTradeCompliance(newOpportunitiesMap,oldOpportunitiesMap);
        }
        OpportunityTriggerHelper.setApprovedStage(newOpportunities,oldOpportunitiesMap);
         system.debug('newOpportunities List&&'+newOpportunities);
		OpportunityTriggerHelper.setGCUKAMonOppty(newOpportunities,oldOpportunitiesMap, false);
      
        //U-1889
        OpportunityTriggerHepler2.setCloseDateStageNameProductChange(newOpportunities, oldOpportunitiesMap);
        //Avoid Soql 101 Error for Prod Defect R 20 08
       // OpportunityTriggerHepler2.setOpportunityApprovers(newOpportunities, oldOpportunitiesMap, false);
       for(Opportunity opp:newOpportunities){ 
               if(opp.AccountId!=oldOpportunitiesMap.get(opp.id).AccountId){ 
        OpportunityTriggerHepler2.setOpportunityApprovers(newOpportunities, oldOpportunitiesMap, false); 
                } 
            } 
		
		//U-0913
        if(emailSent)
        {
        OpportunityTriggerHelper.sendEmailForTradeCompliance(newOpportunities,oldOpportunitiesMap, true, false);
        }
        //U-0913
        OpportunityTriggerHelper.checkSensitiveProductsCheckbox(newOpportunities,oldOpportunitiesMap);
        //U-1108
        OpportunityTriggerHelper.refreshDealMarginValue(newOpportunities, oldOpportunitiesMap);
       // OpportunityOutboundHelper.updateSfdcSdpStatus(newOpportunities, oldOpportunities, newOpportunitiesMap, oldOpportunitiesMap);   
        TradeComplianceHelper.updateCountryRiskOpptys(newOpportunities, oldOpportunitiesMap);
        OpportunityTerritoryAssignmentHelper.updateOpptyTerritoryAssignment(newOpportunities, oldOpportunitiesMap);
        //OpportunityTriggerHelper.setSensitiveBusinessStatus(newOpportunities,oldOpportunitiesMap);
        //D-2744 - changes start
        if(!TCFlag) {
            OpportunityTriggerHelper.updateSensitiveBusinessStatus(newOpportunities,oldOpportunitiesMap); } //D-2744 - changes End
        
        OpportunityPriceBookHelper.populatePriceBookIdOnNewOpp(newOpportunities);
          //U-1022
        OpportunityChildSumDeaValuePercentHelper.updateMAHeadandBAHeads(newOpportunities, oldOpportunitiesMap);
        // U-1060, U-1056
        OpportunityTriggerHelper.updateFinancialComplianceAuditScope(newOpportunities);
        //U-1030
        OpportunityChildSumDeaValuePercentHelper.updateCloseDateofSimple(newOpportunities, oldOpportunitiesMap);
        //OpportunityTriggerHelper.checkBox(newOpportunities, oldOpportunitiesMap);
        
        OpportunityTriggerHelper.calculateCountryRisk(newOpportunities,oldOpportunitiesMap);
        //Calling below method to update Sum of Deal values on Frame itself - Before Update
        //Map<Id, List<Opportunity>> getChildOppsMap = OpportunityChildSumDeaValuePercentHelper.sumChildOppsDealValueOnFrame(newOpportunities);
        //Sum each converted deal Value from child opportunities and update on Frame opportunity 
        /*Id frameOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity;
        Id frameOppPDRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity_PD;
        Id frameOppCreateRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity_Create;
        for(Opportunity frameOpp : newOpportunities){
            if((frameOpp.recordTypeId == frameOppRecordTypeId || frameOpp.recordTypeId == frameOppPDRecordTypeId || frameOpp.RecordTypeId == frameOppCreateRecordTypeId) && getChildOppsMap.containskey(frameOpp.id)){
                Decimal sumOfDealVal = 0;
                for(Opportunity childOpp : getChildOppsMap.get(frameOpp.id)){
                    if(childOpp.Deal_Value_SEK_Converted__c != null){
                        sumOfDealVal = sumOfDealVal + childOpp.Deal_Value_SEK_Converted__c;
                    }                   
                }               
                 if(sumOfDealVal != 0 && frameOpp.Anticipated_Deal_Value_SEK_Converted__c !=0){               
                    frameOpp.Deal_Value_of_linked_opportunities__c = (sumOfDealVal/frameOpp.Anticipated_Deal_Value_SEK_Converted__c)*100;
                }
                else{
                    frameOpp.Deal_Value_of_linked_opportunities__c = 0;
                }
            }
            else{
                frameOpp.Deal_Value_of_linked_opportunities__c = 0;                        
            }
        } */      
        OpportunityTriggerHelper.updateOpportunityApprovedSdpStage(newOpportunities,oldOpportunitiesMap);
        OpportunityTriggerHelper.updateOpportunityStageChange(newOpportunities,oldOpportunitiesMap);
         //U-1819
        OpportunityTriggerHelper.updateCloseDateandProposalSubDate(newOpportunities);
        //U-1859
        OpportunityTriggerHelper.updateShipToCountries(newOpportunities,oldOpportunitiesMap);
			//U-2152
        OpportunityTriggerHepler2.updateProbablity(newOpportunities);
            }catch(Exception e){	}
      }
    public void onAfterUpdate( List<Opportunity> newOpportunities, List<Opportunity> oldOpportunities, Map<ID, Opportunity> newOpportunitiesMap , Map<ID, Opportunity> oldOpportunitiesMap ){
	   //D-2729
        Try{
        OpportunityTriggerHelper.recallSDM(newOpportunities,oldOpportunitiesMap);
		OpportunityTriggerHelper.simpleToCloseUpdate(newOpportunities, oldOpportunitiesMap); 		
        //OpportunityOutboundHelper.executeOppPublishLogic(newOpportunities, oldOpportunities, newOpportunitiesMap, oldOpportunitiesMap);
        OpportunityTriggerHelper.updateOppLineItems(newOpportunities, oldOpportunitiesMap, newOpportunitiesMap);
        OpportunityTriggerHelper.updateSDRcompletion(newOpportunities, oldOpportunitiesMap);
        //U-1578
        OpportunityTriggerHelper.refreshSDRInfo(newOpportunities, newOpportunitiesMap, oldOpportunitiesMap);
        //U-1889
        OpportunityTriggerHepler2.updateOppDescriptionOnSecondaryApproval(newOpportunities, oldOpportunitiesMap);
        OpportunityTriggerHepler2.updateOpportunityApprovedStage(newOpportunities, oldOpportunitiesMap);
        OpportunityTriggerHepler2.updatePrimaryProposalOnSDR(newOpportunities, oldOpportunitiesMap);
     		//U-2040
            OpportunityTriggerHepler2.createOppUseCase(newOpportunities, oldOpportunitiesMap);
      
       //Calling below class to update Sum of Deal values on Frame from child Opportunities - After Update
        //OpportunityChildSumDeaValuePercentHelper.sumChildOppsDealValue(newOpportunities);
        //U-1186
        if(isUpdated)
        {
        	OpportunityTriggerHelper.createSDRecordsOnOpptyStageProgression(newOpportunitiesMap,oldOpportunitiesMap);	
        }
        //D-1928
        OpportunityTriggerHelper.updatePrimaryProposalClosedWon(newOpportunities,oldOpportunitiesMap); 
        //U- 1825
        OpportunityTriggerHelper.setUsedForStageProgression(newOpportunities,oldOpportunitiesMap);
            
        //U-1979
        set<ID> oppSetID=new set<ID>();
        for(Opportunity opp : newOpportunities) {
                if(opp.OwnerId != oldOpportunitiesMap.get(opp.Id).OwnerId && opp.OwnerId != null) {
                    oppSetID.add(opp.Id); }
            }
            if(!oppSetID.isEmpty()) {
                S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
            }    
            
            //U-2035
            OpportunityTriggerHepler2.sbsCalloutOnClosedWon(newOpportunities,oldOpportunitiesMap);
            
            //U-2399,U-2284
            OpportunityTriggerHepler2.updateConsolidatedBlockListOnAccount(newOpportunities,oldOpportunitiesMap,newOpportunitiesMap);
            OpportunityTriggerHepler2.setConditionsOnSA(newOpportunities,oldOpportunitiesMap);
            //SBS U-2386
            OpportunityTriggerHepler2.CallResetSecondaryApprovalStatus(newOpportunities,oldOpportunitiesMap);
        }catch(Exception e){	}
    }

    public void onBeforeDelete(List<Opportunity> oldOpportunities){
        Try{
        for(Opportunity opp:oldOpportunities){
            //U-1991
            if(opp.RecordTypeId != GlobalConstants.simpleOppRecordTypeId && !AccessSettings__c.getInstance().CanDeleteNonSimpleOpportunity__c)
            {
                 opp.addError(GlobalConstants.You_cannot_deletea_nonsimple_opportunity);
            } 
        }
            }catch(Exception e){	}
    }
        
    public static void triggerOpportunitiesUpdate(List<Opportunity> newOpportunities, 
                                                  List<Opportunity> oldOpportunities, 
                                                  Map<ID, Opportunity> newOpportunitiesMap, 
                                                  Map<ID, Opportunity> oldOpportunitiesMap) {
                                                      Try{
                                                      List<Opportunity> selectedOpportunities = new List<Opportunity>();
                                                      for(Opportunity op : newOpportunities) {
                                                          Opportunity oldOpp = oldOpportunitiesMap.get(op.Id);
                                                          //U-1584 If high Impact deal is true Opp should be 'ineligible' for frame & standard Oppty
                                                          if(op.RecordTypeId == GlobalConstants.standardOppRecordTypeId ||op.RecordTypeId == GlobalConstants.frameOppRecordTypeId){
                                                              if(op.High_Impact_Deal__c!=oldOpp.High_Impact_Deal__c && op.High_Impact_Deal__c){
                                                                op.Eligible_for_Small_Value_Flow__c= GlobalConstants.Ineligible;
                                                                  op.Lock_Small_Value__c=false;
                                                              }
                                                          else if ((op.High_Impact_Deal__c!=oldOpp.High_Impact_Deal__c && !op.High_Impact_Deal__c)||
                                                                  op.Are_there_discounts_incentives_outside_E__c != oldOpp.Are_there_discounts_incentives_outside_E__c || 
                                                                   op.Risk_Score_Text__c != oldOpp.Risk_Score_Text__c || 
                                                                   op.New_Risk_Score_Text__c != oldOpp.New_Risk_Score_Text__c || 
                                                                   op.QC_inexperienced_delivering_solution__c != oldOpp.QC_inexperienced_delivering_solution__c || 
                                                                   op.QC_support_and_or_network_sharing__c != oldOpp.QC_support_and_or_network_sharing__c || 
                                                                   op.Overall_Score_Text__c != oldOpp.Overall_Score_Text__c || 
                                                                   op.Will_non_standard_price_model_and_T_C_S__c != oldOpp.Will_non_standard_price_model_and_T_C_S__c || 
                                                                   op.Do_you_expect_an_early_start__c != oldOpp.Do_you_expect_an_early_start__c || 
                                                                   op.Complex_Solution_Count__c != oldOpp.Complex_Solution_Count__c || 
                                                                   op.Deal_Value__c != oldOpp.Deal_Value__c || 
                                                                   op.Deal_Value_Compared_To_CU_Value_Limits__c != oldOpp.Deal_Value_Compared_To_CU_Value_Limits__c) {
                                                                   selectedOpportunities.add(op);
                                                                   }
                                                          }  }                                            
                                                      
                                                      
                                                      
                                                      Set<Id> oppIdSet = new Set<Id>();
                                                      
                                                      for (Opportunity o0 : selectedOpportunities) {
                                                          oppIdSet.add(o0.Id);
                                                      }
                                                      
                                                      Set<Id> accIdSet = new Set<Id>();
                                                      Map<Id, Opportunity> mOpp = new Map<Id, Opportunity>();
                                                      if (oppIdSet.size() > 0 ) {
                                                          for (Opportunity o1 : [SELECT Id, Description, Account.Id, Account.Existing_Customer__c  
                                                                                 FROM Opportunity 
                                                                                 WHERE Id IN :oppIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                                                     mOpp.put(o1.Id, o1);
                                                                                     accIdSet.add(o1.Account.Id);
                                                                                 }
                                                      }
                                                      
                                                      Set<Id> crgIdSet = new Set<Id>();
                                                      Map<Id, Account> mAcc = new Map<Id, Account>();
                                                      if (accIdSet.size() > 0 ) {
                                                          for (Account a0 : [SELECT Id, CustomerReportingGroup__r.Id 
                                                                             FROM Account 
                                                                             WHERE Id IN :accIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                                                 mAcc.put(a0.Id, a0);
                                                                                 crgIdSet.add(a0.CustomerReportingGroup__r.Id); 
                                                                             }
                                                      }
                                                      
                                                      Map<Id, CustomerReportingGroup__c> mCRG = new Map<Id, CustomerReportingGroup__c>();
                                                      
                                                      if (crgIdSet.size() > 0) {
                                                          for (CustomerReportingGroup__c crg0 : [SELECT Id, CustomerUnit__r.Small_Value_Limit__c  
                                                                                                 FROM CustomerReportingGroup__c 
                                                                                                 WHERE Id IN :crgIdSet]) {
                                                                                                     mCRG.put(crg0.Id, crg0);
                                                                                                 }
                                                      }
                                                      
                                                      Set<Id> cuIdSet = new Set<Id>();
                                                      Map<Id, CustomerUnit__c> mCU = new Map<Id, CustomerUnit__c>();
                                                      if (crgIdSet.size() > 0 ) {
                                                          for (CustomerUnit__c cu0 : [SELECT Id, Small_Value_Limit__c 
                                                                                      FROM CustomerUnit__c 
                                                                                      WHERE Id IN :crgIdSet]) {
                                                                                          mCU.put(cu0.Id, cu0);
                                                                                          cuIdSet.add(cu0.Id); 
                                                                                      }
                                                      }
                                                      
                                                      for (Opportunity o2 : selectedOpportunities) {
                                                          //U-1584 calculating Eligible_for_Small_Value_Flow__c for Frame Opportunity also.
                                                          if(o2.RecordTypeId == GlobalConstants.standardOppRecordTypeId ||o2.RecordTypeId== GlobalConstants.frameOppRecordTypeId)
                                                          {
                                                              // Variables for Eligible_for_Small_Value_Flow__c
                                                              ID idPrimaryProp;
                                                              ID accId;
                                                              ID crgId;
                                                              ID cuId;
                                                              Decimal svu;
                                                              Boolean b0 = false;
                                                              Boolean b1 = false;
                                                              Boolean b2 = false;
                                                              
                                                              if (o2.Id != null) {
                                                                  accId = mOpp.get(o2.Id).Account.Id;
                                                              }
                                                              
                                                              if (accId != null) {
                                                                  crgId = mAcc.get(accId).CustomerReportingGroup__r.Id;
                                                              }
                                                              
                                                              if (crgId != null) {
                                                                  cuId = mCRG.get(crgId).CustomerUnit__r.Id;
                                                                  
                                                                  if (mCRG.get(crgId).CustomerUnit__r.Small_Value_Limit__c != null) {
                                                                      svu = mCRG.get(crgId).CustomerUnit__r.Small_Value_Limit__c;
                                                                  } else {
                                                                      svu = null;
                                                                  }
                                                              }
                                                              
                                                              if ((!o2.Any_new_questions__c && o2.Risk_Score_Text__c == GlobalConstants.LOW && 
                                                                   o2.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER) || (o2.Any_New_Questions__c && o2.New_Risk_Score_Text__c == GlobalConstants.LOW && o2.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER)) {
                                                                       b0 = true;                   
                                                                   }
                                                              
                                                              if (o2.Deal_Value__c < svu && svu != null) {
                                                                  b1 = true;
                                                                  
                                                              }
                                                              
                                                              if (o2.Complex_Solution_Count__c == 0) {
                                                                  b2 = true;
                                                              }
                                                              
                                                              if (b0 && b2) {
                                                                  o2.Eligible_for_Small_Value_Flow__c = GlobalConstants.ELIGIBLE;
                                                              } else {
                                                                  o2.Eligible_for_Small_Value_Flow__c = GlobalConstants.Ineligible;
                                                                  /*U-1719 update the value of Small deal value */
                                                                  o2.Lock_Small_Value__c=false;
                                                              }
                                                          }
                                                      }
                                                          }catch(Exception e){	}
                                                  }
    
    /*@future 
    public static void onAfterUpdateAsync(Set<ID> newOpportunitiesIDs){

    }    

    public boolean isTriggerContext{
        get{ return isExecuting;}
    }
    public boolean isVisualforcePageContext{
        get{ return !isTriggerContext;}
    }
    public boolean isWebServiceContext{
        get{ return !isTriggerContext;}
    }
    public boolean isExecuteAnonymousContext{
        get{ return !isTriggerContext;}
    }*/
}