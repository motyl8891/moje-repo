/******************************************************************************************
*
*      	@author       : 
*      	@date         : 
		@description  : Helper Class for OpportunityTrigger
		@testClass    : OpportunityTriggerHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Amit					09-06-2020				U-1819 - updateCloseDateandProposalSubDate Method added
Shubham Kadam			10-06-2020				U-1825 - setUsedForStageProgression Method added
Pallavi Patil			22-06-2020				U-1859 & D-2910 - updateShipToCountryText Method updated, fetchStringShipToCountry & fetchMapShipToCountry added


******************************************************************************************/

/****************************************************************
* @author: Pallavi Patil
* @date: 13-05-2019
* @User Story:  0891
* @description: This class is a helper class for OpportunityTriggerHandler 
*****************************************************************/
public without sharing class OpportunityTriggerHelper {
   // public static integer accountQueryCount = 0;
    public static integer updateLineItemsCount = 0;
    public static integer refreshDealMArginCount = 0;
    public static integer sensitiveBusinessCheckCount = 0;
    public static boolean queueFlag=false;
    public static integer oppStageChangeCount = 0;
    public static integer updatePPCloseWonCount = 0;
    /****************************************************************
* @author: Pallavi Patil
* @date: 13-05-2019
* @param: newOpportunities ,oldOpportunitiesMap
* @description: This method will update simple child's stage according to parent frame opportunity.
*****************************************************************/
    public static void simpleToCloseUpdate( List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap ){
        Set<Id> frameOpptyIdSet = new Set<id>();
        Set<Id> StandOpptyIdSet = new Set<Id>();
        try{ 
            for(opportunity opp : newOpportunities){ 
                if((opp.stagename.equals(GlobalConstants.oppStageClosedLost) || opp.StageName.equals(GlobalConstants.oppStageClosedWithdrawn) || opp.StageName.equals(GlobalConstants.oppStageClosedDuplicate)) &&
                   (opp.stagename != oldOpportunitiesMap.get(opp.id).stagename)) {
                       if(opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId) {
                           frameOpptyIdSet.add(opp.id);
                       }
                       if(opp.RecordTypeId == GlobalConstants.standardOppRecordTypeId) {
                           StandOpptyIdSet.add(opp.id);
                       }
                   }
            }
            if((!frameOpptyIdSet.isEmpty() || !StandOpptyIdSet.isEmpty())){
                queueFlag=true;
                System.enqueueJob(new SimpleToCloseUpdateStage( frameOpptyIdSet, StandOpptyIdSet)); 
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.simpleToCloseUpdate, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Tobias Gustafsson 
* @date: 11-14-2019
* @param: newOpportunities ,oldOpportunitiesMap
* @description: This method will set ApprovedStage for Pilot opportunities in order to ensure Proposal is approved on stage progression.
*****************************************************************/
    public static void setApprovedStage( List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap ){
        
        for(Opportunity opp : newOpportunities){
           // if(opp.Is_Pilot_Group__c){
                
                if(opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName && opp.StageName == GlobalConstants.Define_CustomerValue){
                    opp.Approved_Stage__c = GlobalConstants.Qualify_Opportunity;
                    
                }
                
                if(opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName && opp.StageName == GlobalConstants.Create_Proposal){
                    opp.Approved_Stage__c = GlobalConstants.Define_CustomerValue;
                    
                }
                
                if(opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName && opp.StageName == GlobalConstants.Negotiate_and_Close){
                    opp.Approved_Stage__c = GlobalConstants.Create_Proposal;
                    
                }
                else if(opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName && opp.StageName == GlobalConstants.oppStageClosedWon){
                    try{
                       if(opp.Opportunity_Tier__c == GlobalConstants.Minor){
                        Proposal__c pp = [Select Id, Is_Closed_Won__c from Proposal__c where Opportunity__c =: opp.Id limit 1];
                        pp.Is_Closed_Won__c = true;
                        opp.Approved_Stage__c = GlobalConstants.Negotiate_and_Close;
                       }
                        
                    }
                    catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.setApprovedStage, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
                }
                
            //}
        }
        
    }
    
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 14-08-2019
* @User Story: 1084, 1511
* @description: This method will set OpportunityOwner for Lighthouse created Opportunities based on Account
*****************************************************************/
   public static void setOpportunityOwner( List<Opportunity> newOpportunities){
        Map<Opportunity,id> oppWithAccountIdMap= new Map<Opportunity,id>();
       Account acc = new Account();
        Map<id, id> accWithOwnerMap = new Map<id, id>();
        List<Opportunity> oppList = new List<Opportunity>();
        try{
            //if(accountQueryCount<1)
            //{
                for (opportunity opp1: newOpportunities) {
                    if(opp1.Source_System__c==GlobalConstants.Lighthouse || opp1.Source_System__c==GlobalConstants.RB_PPMID_88159)
                    { oppList.add(opp1);
                     oppWithAccountIdMap.put(opp1,opp1.AccountId);
                     acc.id = opp1.AccountID; 
                    }
                }
                if(!oppWithAccountIdMap.isEmpty()){
                    Map<id, Set<Id>> accToUserMap = new Map<id, Set<Id>>();
                     
                    List<AccountUserTerritory2View> accTerrViewList = [Select Account.Name,AccountId,Territory2.Name,
                                                                      User.Name,User.ID,Territory2.AccountAccessLevel
                                                                      from AccountUserTerritory2View
                                                                      where AccountId = : acc.id and Territory2.AccountAccessLevel = 'Edit'
                                                                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                    for(AccountUserTerritory2View ua :accTerrViewList){
                        if(!accToUserMap.containsKey(ua.AccountId)) {
                            accToUserMap.put(ua.AccountId, new Set<Id>());
                        }
                        accToUserMap.get(ua.AccountId).add(ua.User.ID);
                    }
                    for(Account account:[Select id,Responsible__c,Responsible__r.IsActive,
                                         Account.CustomerReportingGroup__r.Account_Primary_KAM__c,Account.CustomerReportingGroup__r.Account_Primary_KAM__r.IsActive,
                                         Account.CustomerReportingGroup__r.Account_CU_Head__c,Account.CustomerReportingGroup__r.Account_CU_Head__r.IsActive
                                         from Account where id in :oppWithAccountIdMap.values() 
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        if(accToUserMap.containsKey(account.Id)) {
                            Set<id> userIdSet = accToUserMap.get(account.Id);
                            if(account.Responsible__c != null && account.Responsible__r.IsActive && userIdSet.contains(account.Responsible__c)){
                                accWithOwnerMap.put(account.Id,account.Responsible__c);
                            }else if (account.CustomerReportingGroup__r.Account_Primary_KAM__c != null && account.CustomerReportingGroup__r.Account_Primary_KAM__r.IsActive){
                                accWithOwnerMap.put(account.Id,account.CustomerReportingGroup__r.Account_Primary_KAM__c);
                            }else if (account.CustomerReportingGroup__r.Account_CU_Head__c != null && account.CustomerReportingGroup__r.Account_CU_Head__r.IsActive){
                                accWithOwnerMap.put(account.Id,account.CustomerReportingGroup__r.Account_CU_Head__c);       
                            }                 
                        }
                     }
                }
                for (opportunity opp1: oppList) {
                    if(accWithOwnerMap.get(oppWithAccountIdMap.get(opp1)) != null){
                        opp1.OwnerId = accWithOwnerMap.get(oppWithAccountIdMap.get(opp1));
          }
          else opp1.AddError(GlobalConstants.ValidAccountResponsible_AccountPrimary_KAM_CU_Head_Error);
                }
           // }accountQueryCount++;
        } catch (Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,GlobalConstants.setOpportunityOwner, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 14-08-2019
* @User Story: 1084
* @description: This method will set GCU KAM for Global Frame Opportunities based on Account
*****************************************************************/
    public static void setGCUKAMonOppty ( List<Opportunity> newOpportunities ,Map<id,Opportunity> oldOpportunitiesMap, Boolean isInsert){
        Map<Opportunity,id> oppWithAccountIdMap= new Map<Opportunity,id>();
        Map<id, id> accWithGCUKAMMap = new Map<id, id>();
        try{
            //if(accountQueryCount<5) {
                for (opportunity opp: newOpportunities)
                {
                    if((isInsert && opp.Global_Frame__c )||
                       (!isInsert && opp.Global_Frame__c != oldOpportunitiesMap.get(opp.id).Global_Frame__c && opp.Global_Frame__c))
                    {
                        oppWithAccountIdMap.put(opp,opp.AccountId);
                    }
                    else if(!isInsert && opp.Global_Frame__c != oldOpportunitiesMap.get(opp.id).Global_Frame__c && 
                            !opp.Global_Frame__c)
                    {
                        opp.GCU_KAM__c = null;
                    }
                }
                if(!oppWithAccountIdMap.isEmpty()){
                    for(Account account:[Select id,CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_KAM__c,CustomerReportingGroup__r.Account_Primary_KAM__c
                                         from Account where id in :oppWithAccountIdMap.values() 
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){   
                                             if(account.CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_KAM__c != null){
                                                 accWithGCUKAMMap.put(account.Id,account.CustomerReportingGroup__r.GlobalCustomerUnit__r.GCU_KAM__c);
                                             }else if(account.CustomerReportingGroup__r.Account_Primary_KAM__c!= null){
                                                 accWithGCUKAMMap.put(account.Id,account.CustomerReportingGroup__r.Account_Primary_KAM__c);
                                             }
                                         }
                    
                    for (opportunity opp: oppWithAccountIdMap.keySet()) { 
                             
                        if(accWithGCUKAMMap.containsKey(oppWithAccountIdMap.get(opp))){
                            opp.GCU_KAM__c=accWithGCUKAMMap.get(oppWithAccountIdMap.get(opp));
                        }else if (!accWithGCUKAMMap.containsKey(oppWithAccountIdMap.get(opp)) && opp.KAM__c != null ){
                            opp.GCU_KAM__c = opp.KAM__c;
                        }
                   
                        else if(!accWithGCUKAMMap.containsKey(oppWithAccountIdMap.get(opp)) && opp.KAM__c == null){
                            opp.AddError(GlobalConstants.GCU_KAM_Account_Primary_KAM_KAM);
                        }
                    }                   
                }
           // }accountQueryCount++;
        }
        catch (Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,
                                                                       GlobalConstants.setOpportunityOwner, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 05-07-2019
* @param: newOpportunities 
* @description: This method will update ATS flag (U-1060, U-1056).
*****************************************************************/
    /****************************************************************
* @author: Paresh Saxena 
* @date: 21-01-2020
* @description: This method will update ATS flag (U-1577) based on deal value/Anticipated deal value.
*****************************************************************/    
    public static void updateFinancialComplianceAuditScope(List<Opportunity> newOpportunities){
        //Id framePDOppRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity_PD;
        //Id standardPDOppRecordTypeId = System.Label.Record_Type_ID_Standard_Opportunity_PD; 
        try{
            for(opportunity opp : newOpportunities){
                if(opp.CRM360_ATS_Flag__c )
                {
                    opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.INSCOPE;
                }
				else if((opp.Deal_Value_SEK_Converted__c<5000000.00 && opp.RecordTypeId == GlobalConstants.standardOppRecordTypeId) 
						||
						(opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId && opp.Anticipated_Deal_Value_SEK_Converted__c<5000000.00))
                {
                    if((opp.Consideration_payable_to_customer_incl__c==GlobalConstants.NO) 
                       && (opp.Voucher_or_FoC_Items_included__c==GlobalConstants.No 
                       || opp.Voucher_or_FoC_Items_included__c ==GlobalConstants.Yesbelow5millionSEK))
                    {
                        opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.OUTOFSCOPE;
                    }
                    else if((opp.Consideration_payable_to_customer_incl__c==GlobalConstants.NO 
                             && opp.Voucher_or_FoC_Items_included__c==GlobalConstants.Yesabove5millionSEK) 
                             || opp.Consideration_payable_to_customer_incl__c ==GlobalConstants.Yes)
                    {
                        opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.INSCOPE; 
                    }
                }
                
                else if((opp.StageName == GlobalConstants.Create_Proposal ||opp.StageName == GlobalConstants.Negotiate_and_Close || 
                         opp.StageName == GlobalConstants.oppStageClosedWon) && 
                        (opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId  || opp.RecordTypeId == GlobalConstants.standardOppRecordTypeId ) &&
                        date.valueOf(opp.CreatedDate) > date.newInstance(2018,3,31) &&
                        opp.CloseDate > date.newInstance(2017,12,31))    
                {
                    if(opp.Consideration_payable_to_customer_incl__c != null ||
                       opp.Voucher_or_FoC_Items_included__c != null || 
                       opp.Is_Extended_Warranty_SiA_included__c  != null || 
                       opp.Any_New_Questions__c)
                    {
                        if(opp.Global_Frame__c || 
                           opp.Complex_Solution_Count__c > 0 || 
                           opp.Consideration_payable_to_customer_incl__c == GlobalConstants.YES ||
                          // opp.Voucher_or_FoC_Items_included__c == GlobalConstants.YES ||
                           opp.Voucher_or_FoC_Items_included__c ==GlobalConstants.Yesbelow5millionSEK ||
                           opp.Voucher_or_FoC_Items_included__c ==GlobalConstants.Yesabove5millionSEK ||
                           opp.Is_Extended_Warranty_SiA_included__c == GlobalConstants.YES ||
                           opp.Deal_Value_Compared_To_CU_Value_Limits__c != GlobalConstants.UNDER ||(opp.Any_New_Questions__c && opp.New_Risk_Score_Text__c != GlobalConstants.LOW) || (!opp.Any_New_Questions__c && opp.Risk_Score_Text__c != GlobalConstants.LOW)
						   || opp.COUNT_Approved_Early_start__c > 0) 
						   
                        {
                            opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.INSCOPE;
                        }
                        else
                        {
                            opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.OUTOFSCOPE;
                        }   
                    }
                    else if(opp.Global_Frame__c ||  
                            opp.Complex_Solution_Count__c > 0 ||
                            opp.Will_opp_modify_global_pricing_or_T_Cs__c == GlobalConstants.YES ||
                            opp.Do_you_expect_an_early_start__c == GlobalConstants.YES ||
                            opp.QC_inexperienced_delivering_solution__c == GlobalConstants.YES || 
                            opp.Will_non_standard_price_model_and_T_C_S__c == GlobalConstants.YES ||
                            opp.Does_the_Opp_span_multiple_countries__c == GlobalConstants.YES ||
                            opp.QC_Requires_3rd_Party__c == GlobalConstants.YES ||
                            opp.Are_there_discounts_incentives_outside_E__c == GlobalConstants.YES ||
                            opp.Is_there_a_risk_of_late_payment__c == GlobalConstants.YES ||
                            opp.QC_inexperienced_delivering_solution__c == GlobalConstants.UNKNOWN || 
                            opp.Will_non_standard_price_model_and_T_C_S__c == GlobalConstants.UNKNOWN || 
                            opp.Does_the_Opp_span_multiple_countries__c == GlobalConstants.UNKNOWN || 
                            opp.QC_Requires_3rd_Party__c == GlobalConstants.UNKNOWN ||  
                            opp.Are_there_discounts_incentives_outside_E__c == GlobalConstants.UNKNOWN ||  
                            opp.Is_there_a_risk_of_late_payment__c == GlobalConstants.UNKNOWN ||
                            opp.Deal_Value_Compared_To_CU_Value_Limits__c != GlobalConstants.UNDER  ||
                           	opp.COUNT_Approved_Early_start__c > 0)    
                    {
                        opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.INSCOPE;
                    }
                    else
                    {
                        opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.OUTOFSCOPE;
                    }           
                }
                else
                {
                    opp.Financial_Compliance_Audit_Scope__c = GlobalConstants.OUTOFSCOPE;
                }
            } 
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.UPDATEFINANCIALCOMPLIANCEAUDITSCOPE, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
     //U-1666 Added Simple Oppty check
    public static void updateOppLineItems(List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap, Map<ID, Opportunity> newOpportunitiesMap){
        if(updateLineItemsCount < 2) {
            updateLineItemsCount++;
            Set<Id> validRecordTypes = GlobalConstants.frameStandRecordTypes;
            Set<Id> frameRecordTypes = GlobalConstants.frameRecordTypes;
            Set<Id> standRecordTypes = GlobalConstants.standRecordTypes;
            Set<Id> oppIds = new Set<Id>();
            Set<Id> marginUpdateOpp = new Set<Id>();
            Set<Id> dealUpdateOpp = new Set<Id>();
            for(Opportunity op : newOpportunities) {
                if((op.Override_Deal_Value_and_Margin__c && validRecordTypes.contains(op.RecordTypeId)) || (op.Override_Deal_Value_and_Margin__c && op.RecordTypeId == GlobalConstants.simpleOppRecordTypeId)) {
                    if(op.Margin__c != oldOpportunitiesMap.get(op.Id).Margin__c && op.Margin__c != op.formula_Margin__c) {
                        oppIds.add(op.Id);
                        marginUpdateOpp.add(op.Id);
                    }
                    if(frameRecordTypes.contains(op.RecordTypeId) && op.anticipated_deal_value__c != oldOpportunitiesMap.get(op.Id).anticipated_deal_value__c
                       && op.anticipated_deal_value__c != op.Formula_Anticipated_Deal_Value__c) {
                           oppIds.add(op.Id);
                           dealUpdateOpp.add(op.Id);
                       }
                    if((standRecordTypes.contains(op.RecordTypeId) || op.RecordTypeId == GlobalConstants.simpleOppRecordTypeId) && op.deal_value__c != oldOpportunitiesMap.get(op.Id).deal_value__c
                       && op.Deal_value__c != op.Formula_Deal_Value__c) {
                           oppIds.add(op.Id);
                           dealUpdateOpp.add(op.Id);
                       }
                }
            }
            Map<Id, Decimal> oppToTotalDealValMap = new Map<Id, Decimal>();
            Map<Id, Id> oppToOLIMap = new Map<Id, Id>();
            Decimal value=0;
            if(!oppIds.isEmpty()){
            	Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>([SELECT ID, UnitPrice, Estimated_Margin__c, OpportunityId 
                                                                                    FROM OpportunityLineItem WHERE OpportunityId IN : oppIds Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            for(OpportunityLineItem oli : oliMap.values()) {
                if(!oppToOLIMap.containsKey(oli.OpportunityId)) {
                    oppToOLIMap.put(oli.OpportunityId, oli.Id);
                }
                if(dealUpdateOpp.contains(oli.OpportunityId)) {
                    if(standRecordTypes.contains(newOpportunitiesMap.get(oli.OpportunityId).RecordTypeId) || newOpportunitiesMap.get(oli.OpportunityId).RecordTypeId == GlobalConstants.simpleOppRecordTypeId) {
                        oli.UnitPrice = (oli.UnitPrice * newOpportunitiesMap.get(oli.OpportunityId).deal_value__c)/oldOpportunitiesMap.get(oli.OpportunityId).deal_value__c;                    
                    }else if(frameRecordTypes.contains(newOpportunitiesMap.get(oli.OpportunityId).RecordTypeId)) {
                        oli.UnitPrice = (oli.UnitPrice * newOpportunitiesMap.get(oli.OpportunityId).anticipated_deal_value__c)/oldOpportunitiesMap.get(oli.OpportunityId).anticipated_deal_value__c;                    
                    }
                }
                if(marginUpdateOpp.contains(oli.OpportunityId) && oldOpportunitiesMap.get(oli.OpportunityId).Margin__c != 0 && oli.Estimated_Margin__c != null) {
                    oli.Estimated_Margin__c = (oli.Estimated_Margin__c * newOpportunitiesMap.get(oli.OpportunityId).Margin__c)/oldOpportunitiesMap.get(oli.OpportunityId).Margin__c;
                }
                
                if(oppToTotalDealValMap.containsKey(oli.OpportunityId)) {
                    value = oppToTotalDealValMap.get(oli.OpportunityId)+oli.UnitPrice;
                    oppToTotalDealValMap.put(oli.OpportunityId,value);
                }else {
                    oppToTotalDealValMap.put(oli.OpportunityId,oli.UnitPrice);
                }
            }
            
            Decimal totalVal=0;
            for(Opportunity op : newOpportunities) {
                if(oppToOLIMap.containsKey(op.Id) && oppToTotalDealValMap.containsKey(op.Id)) {
                    totalVal = oppToTotalDealValMap.get(op.Id);
                    if(frameRecordTypes.contains(op.RecordTypeId) && op.Anticipated_Deal_Value__c > totalVal) {
                        oliMap.get(oppToOLIMap.get(op.Id)).UnitPrice = oliMap.get(oppToOLIMap.get(op.Id)).UnitPrice+op.Anticipated_Deal_Value__c - totalVal;
                    }else if((standRecordTypes.contains(op.RecordTypeId) || op.RecordTypeId == GlobalConstants.simpleOppRecordTypeId)&& op.Deal_Value__c > totalVal) {
                        oliMap.get(oppToOLIMap.get(op.Id)).UnitPrice = oliMap.get(oppToOLIMap.get(op.Id)).UnitPrice+op.Deal_Value__c - totalVal;
                    }
                }
            }
            update oliMap.values();    
            }
        }
    }
    
    public static void refreshDealMarginValue(List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap) {
        Try{
        //if(refreshDealMArginCount < 2) {
        //    refreshDealMArginCount++;
        Set<Id> validRecordTypes = GlobalConstants.frameStandRecordTypes;
        Set<Id> frameRecordTypes = GlobalConstants.frameRecordTypes;
        Set<Id> standRecordTypes = GlobalConstants.standRecordTypes;
        Set<Id> oppIds = new Set<Id>();
        List<Proposal__c> propList = new List<Proposal__c>();
        for(Opportunity op : newOpportunities) {
            if(!op.Override_Deal_Value_and_Margin__c && oldOpportunitiesMap.get(op.Id).Override_Deal_Value_and_Margin__c
               && validRecordTypes.contains(op.RecordTypeId)) {
                   oppIds.add(op.Id);
               }
        }
        if(!oppIds.Isempty()) {
            Map<Id, Proposal__c> oppToProposal = new Map<Id, Proposal__c>();
            for(Proposal__c prop : [SELECT ID, Opportunity__c, Opportunity__r.Pricebook2Id, Opportunity__r.CurrencyIsoCode,
                                    RecordType.Name, Effective_Net_Price__c, UMAR_Percent__c, primary__c
                                    FROM Proposal__c WHERE Opportunity__c IN: oppIds order by createdDate desc Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                        if(!oppToProposal.containsKey(prop.Opportunity__c)) {
                                            if(prop.RecordType.Name == GlobalConstants.PREMIUM_DECISION_RT_NAME) {
                                                oppToProposal.put(prop.Opportunity__c, prop);               
                                            }else if(prop.RecordType.Name == GlobalConstants.ppRecordTypeID1 && prop.Primary__c) {
                                                propList.add(prop);
                                                oppToProposal.put(prop.Opportunity__c, prop);               
                                            }
                                        }
                                    }
            for(Opportunity op : newOpportunities) {
                if(oppToProposal.containsKey(op.Id)) {
                    op.Margin__c = oppToProposal.get(op.Id).UMAR_Percent__c;
                    if(frameRecordTypes.contains(op.RecordTypeId)) {
                        op.Anticipated_Deal_Value__c = oppToProposal.get(op.Id).Effective_Net_Price__c;
                    }else if(standRecordTypes.contains(op.RecordTypeId)) {
                        op.deal_value__c = oppToProposal.get(op.Id).Effective_Net_Price__c;
                    }
                }
                
            }
            if(!propList.isEmpty()) {
                system.enqueueJob(new AsyncReplaceProducts(propList));
            }
        }
            }catch(Exception e){	}
        //}
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 12-09-2019
* @param: newOpportunitiesMap, oldOpportunitiesMap
* @description: This method will create sales decision records on oppty stage progression for streamlined opptys.
*****************************************************************/
    public static void createSDRecordsOnOpptyStageProgression(Map<ID, Opportunity> newOpportunitiesMap , Map<ID, Opportunity> oldOpportunitiesMap)
    {
        try
        {
            Set<Id> opptyIdSet = new Set<Id>();
            List<Sales_Decision_Record__c> sdrListToInsert = new List<Sales_Decision_Record__c>();
            Map<id, List<String>> opptyWithSalesDecisionsMap = new Map<id, List<String>>();
            List<String> salesDecisionTypeList;
            for(Opportunity opp : newOpportunitiesMap.values())
            {
                if(opp.StageName != oldOpportunitiesMap.get(opp.id).StageName && opp.RecordTypeId != GlobalConstants.simpleOppRecordTypeId)
                {
                    opptyIdSet.add(opp.id);
                }
            }
            if(!opptyIdSet.isEmpty())
            {
                for(Sales_Decision_Record__c salesDecision : [Select id, Sales_Decision_Type__c, Opportunity__c from Sales_Decision_Record__c
                                                              where Opportunity__c in : opptyIdSet
                                                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(opptyWithSalesDecisionsMap.containsKey(salesDecision.Opportunity__c))
                    {
                        salesDecisionTypeList = opptyWithSalesDecisionsMap.get(salesDecision.Opportunity__c);
                        salesDecisionTypeList.add(salesDecision.Sales_Decision_Type__c);
                        opptyWithSalesDecisionsMap.put(salesDecision.Opportunity__c,salesDecisionTypeList);
                    }
                    else
                    {
                        salesDecisionTypeList = new List<String>();
                        salesDecisionTypeList.add(salesDecision.Sales_Decision_Type__c);
                        opptyWithSalesDecisionsMap.put(salesDecision.Opportunity__c,salesDecisionTypeList);
                    }   
                }
            }
            if(!opptyIdSet.isEmpty())
            {
                for(Id opptyId : opptyIdSet)
                {
                    List<String> sdrList = opptyWithSalesDecisionsMap.get(opptyId);
                    Boolean isMinorFlow = false;
                    if(newOpportunitiesMap.get(opptyId).Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER && ((newOpportunitiesMap.get(opptyId).Commercial_Risk_Score_Text__c == GlobalConstants.LOW && newOpportunitiesMap.get(opptyId).Fulfillment_Risk_Score_Text__c == GlobalConstants.LOW && newOpportunitiesMap.get(opptyId).Financial_Accounting_Risk_Score_Text__c == GlobalConstants.LOW && newOpportunitiesMap.get(opptyId).SHE_Score_Text__c == GlobalConstants.LOW && newOpportunitiesMap.get(opptyId).Solution_Risk_Score_Text__c == GlobalConstants.LOW && newOpportunitiesMap.get(opptyId).QC_support_and_or_network_sharing__c == GlobalConstants.NO) || newOpportunitiesMap.get(opptyId).New_Risk_Score_Text__c == GlobalConstants.LOW))
                    {
                        isMinorFlow = true;
                    }
                    if(oldOpportunitiesMap.get(opptyId).StageName == GlobalConstants.Define_CustomerValue 
                       && newOpportunitiesMap.get(opptyId).StageName == GlobalConstants.Create_Proposal)
                    {  
                        if(sdrList == null || !sdrList.contains(GlobalConstants.SDP1InvestToWin))
                        {
                            if(newOpportunitiesMap.get(opptyId).Not_Deviating_from_Parent__c || isMinorFlow || newOpportunitiesMap.get(opptyId).MarketArea__c == GlobalConstants.MELA)
                            {
                               /* Sales_Decision_Record__c  sdr = new Sales_Decision_Record__c();
                                sdr.Sales_Decision_Type__c = GlobalConstants.SDP1InvestToWin;
                                sdr.Sales_Decision_Date__c = system.today();
                                sdr.Name = GlobalConstants.SDP1InvestToWin ;
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
                                }*/
                             
                       sdrListToInsert.add(OpportunityTriggerHepler2.createSDRRecords(isMinorFlow,GlobalConstants.SDP1InvestToWin,opptyId,newOpportunitiesMap));
                            }
                        }
                        
                    }
                    else if(oldOpportunitiesMap.get(opptyId).StageName == GlobalConstants.Create_Proposal 
                            && newOpportunitiesMap.get(opptyId).StageName == GlobalConstants.Negotiate_and_Close)
                    {
                        if(sdrList == null || !sdrList.contains(GlobalConstants.SDP2SubmitProposal))
                        { 
                            if(newOpportunitiesMap.get(opptyId).Not_Deviating_from_Parent__c || isMinorFlow)
                            {
                                /*Sales_Decision_Record__c  sdr = new Sales_Decision_Record__c();
                                sdr.Sales_Decision_Type__c = GlobalConstants.SDP2SubmitProposal;
                                sdr.Sales_Decision_Date__c = system.today(); 
                                sdr.Name = GlobalConstants.SDP2SubmitProposal ;
                                sdr.Opportunity__c = opptyId;
                                sdr.Source__c = GlobalConstants.AUTOMATIC;
                                if(isMinorFlow || newOpportunitiesMap.get(opptyId).Not_Deviating_from_Parent__c)
                                {
                                    sdr.IsAutoGen__c = true; 
                                    sdr.UsedForStageProgression__c=true;
                                    sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED;                           
                                    sdr.Support_Information_and_Material__c = GlobalConstants.SUPPORTTEXT;
                                }
                                else
                                {
                                    sdr.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
                                }*/
                                
                                sdrListToInsert.add(OpportunityTriggerHepler2.createSDRRecords(isMinorFlow,GlobalConstants.SDP2SubmitProposal,opptyId,newOpportunitiesMap));
                            } 
                        }
                    }
                    else if(oldOpportunitiesMap.get(opptyId).StageName == GlobalConstants.Negotiate_and_Close 
                            && newOpportunitiesMap.get(opptyId).StageName == GlobalConstants.oppStageClosedWon)
                    {
                        if(sdrList == null || !sdrList.contains(GlobalConstants.SDP3SignContract))
                        {
                            if(!newOpportunitiesMap.get(opptyId).Not_Deviating_from_Parent__c|| isMinorFlow)
                            {
                               /* Sales_Decision_Record__c  sdr = new Sales_Decision_Record__c();
                                sdr.Sales_Decision_Type__c = GlobalConstants.SDP3SignContract;
                                sdr.Sales_Decision_Date__c = system.today();
                                sdr.Name = GlobalConstants.SDP3SignContract ;
                                sdr.Opportunity__c = opptyId;
                                sdr.Source__c = GlobalConstants.AUTOMATIC;
                                if(isMinorFlow)
                                {
                                    sdr.IsAutoGen__c = true; 
                                    sdr.UsedForStageProgression__c=true;
                                    sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED; 
                                    sdr.Support_Information_and_Material__c = GlobalConstants.SUPPORTTEXT;
                                }
                                else
                                {
                                    sdr.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
                                }*/
                                sdrListToInsert.add(OpportunityTriggerHepler2.createSDRRecords(isMinorFlow,GlobalConstants.SDP3SignContract,opptyId,newOpportunitiesMap));
                            }   
                        }
                    }
                }
            }
            if(!sdrListToInsert.isEmpty())
            {
                database.insert(sdrListToInsert,true);
                OpportunityTriggerHandler.isUpdated = false;
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.createSDRecordsOnOpptyStageProgression, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Richa Gupta  
* @date: 09-10-2019
* @param: newOpportunitiesList
* @description: This method will update EndCustomer While opportunity Creation.(U-1055)
*****************************************************************/
    public static void setEndCustomer(List<Opportunity> newOpportunities) {
        try{
            for(Opportunity opp:newOpportunities) {
                opp.End_Customer__c=opp.AccountId;
                /*//U-1990
                if(opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId){
                    opp.StageName = GlobalConstants.oppStage1;
                }*/
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.setEndCustomer, GlobalConstants.OpportunityTriggerHelper, true, e)));}
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 4-10-2019
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will update Opportunity tier after oppty creation and update.(U-1366)
*****************************************************************/
    public static void updateOpportunityTier(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap)
    {
        try
        {
            Set<Id> frameRecordTypes = GlobalConstants.frameRecordTypes;
            Set<Id> standRecordTypes = GlobalConstants.standRecordTypes;
            for(Opportunity opp: newOpportunitiesList)
            {
                if(opp.RecordTypeId != GlobalConstants.simpleOppRecordTypeId && opp.RecordTypeId != GlobalConstants.simpleCreateOppRecTypeId){
                    if(opp.Opportunity_Progression_Type__c == GlobalConstants.GCUFRAMEOPPTY && 
                       opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.OVER)
                    {
                        opp.Opportunity_Tier__c = GlobalConstants.TIER1;
                    } 
                    else if (opp.Opportunity_Progression_Type__c == GlobalConstants.GCUFRAMEOPPTY && 
                             (opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.BETWEEN || opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER))
                    {
                        opp.Opportunity_Tier__c = GlobalConstants.TIER2;
                    }
                    else if(opp.Opportunity_Progression_Type__c == GlobalConstants.CUSTANDARDFRAMEOPPS || 
                            opp.Opportunity_Progression_Type__c == GlobalConstants.LOCALACCOUNTGCUOPP)
                    {
                        if(opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER && 
                           ((opp.Any_New_Questions__c && opp.New_Risk_Score_Text__c == GlobalConstants.LOW)
                            || (!opp.Any_New_Questions__c && opp.Risk_Score_Text__c == GlobalConstants.LOW)))
                        {
                            opp.Opportunity_Tier__c = GlobalConstants.TIER3;
                        }
                        else if((standRecordTypes.contains(opp.RecordTypeId) && opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.OVER) || 
                                (frameRecordTypes.contains(opp.RecordTypeId) && opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.OVER))
                        {
                            opp.Opportunity_Tier__c = GlobalConstants.TIER1;
                        }
                        else if(opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.OVER || 
                                (opp.Any_New_Questions__c && 
                                 (opp.New_Risk_Score_Text__c == GlobalConstants.MEDIUM || opp.New_Risk_Score_Text__c == GlobalConstants.HIGH))|| 
                                (!opp.Any_New_Questions__c && 
                                 (opp.Risk_Score_Text__c == GlobalConstants.MEDIUM || opp.Risk_Score_Text__c == GlobalConstants.HIGH)) || 
                                ((frameRecordTypes.contains(opp.RecordTypeId) || standRecordTypes.contains(opp.RecordTypeId)) && (opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.UNDER || opp.Deal_Value_Compared_To_CU_Value_Limits__c == GlobalConstants.BETWEEN)))
                        {
                            opp.Opportunity_Tier__c = GlobalConstants.TIER2;
                        } 
                    }                
                }
            }
        }
        catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.UPDATEOPPORTUNITYTIER, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }   
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 4-10-2019
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will check if 'Sensitive Products in scope?' is checked or not if Ship-to-Country on Opp or Account.BillingCountry is a less sensitive country(U-0913)
*****************************************************************/
    public static Boolean sendEmailForTradeCompliance(List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap, Boolean isUpdate, Boolean isInsert)
    {
        Boolean TCFlag = false;	//D-2744 - changes
        try
        {
            //String oppStageCreateProposal = System.Label.Sales_Stage_3_Create_Proposal;
            //String oppStageNegotiateandClose = System.Label.Sales_Stage_4_Negotiate_and_Close;
            List<String> sensitiveList = new List<String>();
            List<String> lessSensitiveList = new List<String>();        
            Map<id, String> opptyIdWithAccountCountryMap = new Map<id, String>();
            Boolean lessSensitiveFlag;
            Boolean sensitiveFlag;
            Set<String> shipToCountrySet;
            Set<Id> accountIdSet = new Set<Id>();
            String billingCountry;
            Boolean fireQueryCS=false;
            Boolean fireQueryAc=false;
            for(Opportunity opp : newOpportunities) {
                //D-3107
                if(isInsert ||(isUpdate && 
                   (opp.Ship_To_Countries__c!=oldOpportunitiesMap.get(opp.Id).Ship_To_Countries__c
                    || (opp.Sensitive_Products_in_scope__c == GlobalConstants.YES 
                        && opp.Sensitive_Products_in_scope__c!=oldOpportunitiesMap.get(opp.Id).Sensitive_Products_in_scope__c)))) {
                            fireQueryCS=true;
                        }
                if( isUpdate && opp.Sensitive_Products_in_scope__c == GlobalConstants.YES 
                  && opp.Sensitive_Products_in_scope__c!=oldOpportunitiesMap.get(opp.Id).Sensitive_Products_in_scope__c) {
                       fireQueryAC=true;
                  }
                accountIdSet.add(opp.AccountId);
            }
            if(fireQueryCS) {
                for(Country_Risk__c countryRisk : [Select TC_Sensitivy_Class__c,Name from Country_Risk__c 
                                                   where TC_Sensitivy_Class__c =: GlobalConstants.LESSSENSITIVE OR
                                                   TC_Sensitivy_Class__c =: GlobalConstants.SENSITIVE
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                       if(countryRisk.TC_Sensitivy_Class__c == GlobalConstants.SENSITIVE)
                                                           sensitiveList.add(countryRisk.Name);
                                                       else if(countryRisk.TC_Sensitivy_Class__c == GlobalConstants.LESSSENSITIVE)
                                                           lessSensitiveList.add(countryRisk.Name);
                                                   }
            }
            if(fireQueryAC) {
                for(Opportunity opp : [SELECT id, Account.BillingCountry, AccountId FROM Opportunity 
                                       WHERE AccountId IN: accountIdSet
                                       LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                           if(opp.Account.BillingCountry != null)
                                           {
                                               //U-2274//billingCountry = opp.Account.BillingCountry.substringBefore(GlobalConstants.COMMA);
                                               billingCountry = opp.Account.BillingCountry;
                                               opptyIdWithAccountCountryMap.put(opp.id, billingCountry);
                                           }
                                       }
            }
            for(Opportunity opp : newOpportunities)
            {   lessSensitiveFlag = false;
                sensitiveFlag = false;
                if(opp.ship_To_Countries__c != null)
                {
                    shipToCountrySet = new Set<String>(opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON));
                    for(string str : shipToCountrySet)
                    { 
                        if(!lessSensitiveList.isEmpty() && lessSensitiveList.contains(str))
                          lessSensitiveFlag  = true;  
                         //D-3107
                         if(isInsert||(opp.Ship_To_Countries__c != oldOpportunitiesMap.get(opp.id).Ship_To_Countries__c && isUpdate)){
                         if(!sensitiveList.isEmpty() && (sensitiveList.contains(str.trim())||sensitiveList.contains(str))){
                             sensitiveFlag = true;
                             }
                         }
                    }
                } 
                if(GlobalConstants.OpenStage.contains(opp.StageName)) //D-3107
                {
                    if(sensitiveFlag ||((isUpdate && opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.id).Trade_Classifications__c) 
                                        &&(opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT || opp.Trade_Classifications__c == GlobalConstants.DEFENSE)))
                    {   
                        opp.Trade_Compliance_Status__c = GlobalConstants.REQUIRED;
                    }
                    if(sensitiveFlag ||
                       (( isUpdate && opp.Ship_To_Countries__c != oldOpportunitiesMap.get(opp.id).Ship_To_Countries__c ) &&
                        (lessSensitiveFlag && opp.Sensitive_Products_in_scope__c == GlobalConstants.YES))
                       ||
                       ((isUpdate && opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.id).Trade_Classifications__c) &&
                        (opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT || opp.Trade_Classifications__c == GlobalConstants.DEFENSE)) || 
                       (opp.Sensitive_Products_in_scope__c == GlobalConstants.YES && (opp.Sensitive_Products_in_scope__c != oldOpportunitiesMap.get(opp.id).Sensitive_Products_in_scope__c && isUpdate))
                       &&((opptyIdWithAccountCountryMap.get(opp.id) != null && lessSensitiveList.contains(opptyIdWithAccountCountryMap.get(opp.id))) || lessSensitiveFlag))
                    {
                        opp.Email_Notification__c = true;
                        OpportunityTriggerHandler.emailSent = false;
                    }
                }
            }
            if(isInsert) {
                Set<Id> accountIds = new Set<Id>();
                for (Account ac : [SELECT ID, BillingCountry, Trade_Classification__c FROM Account WHERE ID IN :accountIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                    if(ac.Trade_Classification__c == GlobalConstants.GOVERNMENT || ac.Trade_Classification__c == GlobalConstants.DEFENSE) {
                           accountIds.add(ac.Id);
                       }
                }
                for(Opportunity op : newOpportunities) {
                    if(!op.Email_Notification__c && accountIds.contains(op.AccountId)) {
                        op.Email_Notification__c = true;
                        op.Trade_Compliance_Status__c = GlobalConstants.REQUIRED;
                        op.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                        TCFlag = true; //D-2744 - changes
                        
                    }
                }
            }       
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.sendEmailForTradeCompliance, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }

        return TCFlag; //D-2744 - changes
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 4-10-2019
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will check if 'Sensitive Products in scope?' is Yes or No if Ship-to-Country on Opp or Account.BillingCountry is a less sensitive country(U-0913)
*****************************************************************/
    public static void checkSensitiveProductsCheckbox(List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap)
    {  
        try
        {
            List<String> sensitiveCountryList = new List<String>();
            Boolean flag;
            Set<String> shipToCountrySet;
            Map<id, String> opptyIdWithAccountCountryMap = new Map<id, String>();
            Map<id, Opportunity> opptyMap = new Map<id, Opportunity>();
            String billingCountry;
            for(Opportunity opp : newOpportunities)
            {
                if((opp.Sensitive_Products_in_scope__c !=null || opp.Ship_To_Countries__c!=null)&&
                   (oldOpportunitiesMap.get(opp.id)==null || opp.Sensitive_Products_in_scope__c != oldOpportunitiesMap.get(opp.id).Sensitive_Products_in_scope__c 
                    || opp.Ship_To_Countries__c != oldOpportunitiesMap.get(opp.id).Ship_to_countries__c)) 
                {
                    opptyMap.put(opp.id, opp);
                }
            }
            if(!opptyMap.isEmpty())
            {
                for(Country_Risk__c countryRisk : [Select TC_Sensitivy_Class__c,Name from Country_Risk__c 
                                                   where TC_Sensitivy_Class__c =: GlobalConstants.LESSSENSITIVE
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    sensitiveCountryList.add(countryRisk.Name);
                }
                For(Opportunity opp : [SELECT id, Account.BillingCountry FROM Opportunity 
                                       Where Id IN: opptyMap.keyset()
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                           if(opp.Account.BillingCountry != null){
                                               //U-2274//billingCountry = opp.Account.BillingCountry.substringBefore(GlobalConstants.COMMA);
                                               billingCountry = opp.Account.BillingCountry;
                                               opptyIdWithAccountCountryMap.put(opp.id, billingCountry);
                                           }
                                       }
                for(Opportunity opp : opptyMap.values())
                {
                    flag = false;
                    shipToCountrySet = new Set<String>(opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON));
                    for(string str : shipToCountrySet)
                    {
                        if(sensitiveCountryList.contains(str.trim()))
                        {
                            flag = true;     
                            break;
                        }
                    }
                    if(!flag && opptyIdWithAccountCountryMap.get(opp.id) != null)
                    {
                        if(sensitiveCountryList.contains(opptyIdWithAccountCountryMap.get(opp.id))) 
                            flag = true;
                    }          
                    if(flag && opp.Sensitive_Products_in_scope__c != GlobalConstants.YES)
                        opp.Has_Less_Sensitive_Country__c = true;   
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.checkSensitiveProductsCheckbox, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }   
    }
  /*  public static void setClosedWithdrawnReason(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        Try{
        for(Opportunity opp: newOpportunitiesList){
            if(opp.Not_Pursued_Reason__c!=null && opp.Not_Pursued_Reason__c.contains(GlobalConstants.Bracket)) {
                opp.Not_Pursued_Reason__c.replace(GlobalConstants.Bracket, GlobalConstants.BLANK);
            }
            if(opp.Not_Pursued_Reason__c!=null && opp.Not_Pursued_Reason__c.contains(GlobalConstants.Bracket)) {
                opp.Not_Pursued_Reason__c.replace(GlobalConstants.Bracket, GlobalConstants.BLANK);
            }
        }
            }catch(Exception e){	}
    } */
    
    /****************************************************************
* @author: Richa Gupta  
* @date: 02-12-2019
* @param: newOpportunitiesList
* @description: This method will update ForeCast Category While closing the Opportunity.(U-1267)
*****************************************************************/
    
    public static void setForecastCategory(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
            for(Opportunity opp: newOpportunitiesList){
                if(opp.StageName!=oldOpportunitiesMap.get(opp.Id).StageName){
                    if(opp.StageName.equalsIgnoreCase(GlobalConstants.oppStageClosedWon)){
                        opp.Forecast__c= GlobalConstants.Won;
                    
                    }
                    else if(opp.StageName.equalsIgnoreCase(GlobalConstants.oppStageClosedWithdrawn)||opp.StageName.equalsIgnoreCase(GlobalConstants.oppStageClosedLost)||opp.StageName.equalsIgnoreCase(GlobalConstants.oppStageClosedDuplicate)){
                        opp.Forecast__c= GlobalConstants.Lost;
                       
                    }
                } }
        }
     catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.setForecastCategory, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }}
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 04-11-2019
* @User Story: 1084
* @description: This method will set Opportunity Ready for next Sales Stage?  based on Opportunity's Field Values.
*****************************************************************/
   public static void VerifyOpportunityProgression(List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap) {
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        
       try{
        for(Opportunity opp : newOpportunities ) {
		Opportunity oldOpp = oldOpportunitiesMap.get(opp.id);
            if(opp.RecordTypeId != GlobalConstants.simpleOppRecordTypeId && opp.RecordTypeId != GlobalConstants.simpleCreateOppRecTypeId){
            if(checkForStage1(opp)){
                if(checkForStage2(opp,oldOpp)){
				if(opp.StageName == oppStageDefineCustomerValue || opp.StageName == oppStageCreateProposal || opp.StageName == oppStageNegotiateandClose){
                        if(checkForStage3(opp , oldOpportunitiesMap.get(opp.Id))){
                            if(checkForStage4(opp)){
                                if(checkForClosedWon(opp)){
                                    opp.Is_progression_ready_for_stage__c=String.valueOf(Integer.valueOf(GlobalConstants.mapStageToVal.get(oppStageNegotiateandClose))+1);
                                    break;
                                }	
                                opp.Is_progression_ready_for_stage__c=String.valueOf(Integer.valueOf(GlobalConstants.mapStageToVal.get(oppStageNegotiateandClose)));
                                break;
                            }
                            opp.Is_progression_ready_for_stage__c=String.valueOf(Integer.valueOf(GlobalConstants.mapStageToVal.get(oppStageCreateProposal)));
                            break;
                        }
                    }
                    opp.Is_progression_ready_for_stage__c=String.valueOf(Integer.valueOf(GlobalConstants.mapStageToVal.get(oppStageDefineCustomerValue)));
                    break;
                }                opp.Is_progression_ready_for_stage__c=String.valueOf(Integer.valueOf(GlobalConstants.mapStageToVal.get(oppStageQualifyOppty)));
        break;
            }
            opp.Is_progression_ready_for_stage__c=String.valueOf(Integer.valueOf(GlobalConstants.mapStageToVal.get(oppStageQualifyOppty))-1);
        }
    }
    }
    catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.VerifyOpportunityProgression, GlobalConstants.OpportunityTriggerHelper, true, e)));
     }   
   } 
                   
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 04-11-2019
* @User Story: 1084
* @description: 
*****************************************************************/
 public static Boolean checkForStage1(Opportunity opp) {
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Boolean flag = false;
        Boolean mFlag = false;
        try{
            if(GlobalConstants.frameStandRecordTypes.contains(opp.RecordTypeId) && opp.MarketArea__c == GlobalConstants.MELA)
            {
                 if(opp.CloseDate >= System.Today() 
                   && (opp.Tags__c != null && ((opp.Tags__c.countMatches(GlobalConstants.MELADS) == 1 && !opp.Tags__c.contains(GlobalConstants.MELANMS)) ||
                                               (opp.Tags__c.countMatches(GlobalConstants.MELANMS) == 1 && !opp.Tags__c.contains(GlobalConstants.MELADS)))
                      ))
                {
                    if((opp.Proposal_Submission_Date__c >= System.Today() && (opp.StageName ==oppStageQualifyOppty 
                       || opp.StageName ==oppStageDefineCustomerValue  ||opp.StageName ==oppStageCreateProposal))
                      || (opp.Proposal_Submission_Date__c <= System.Today() && (opp.StageName ==oppStageNegotiateandClose )
                         || (opp.StageName ==GlobalConstants.oppStageClosedWon )))
                    {
                           mFlag = true;                                           
                           } 
                         if(opp.Proposal_Submission_Date__c >= System.Today() && (opp.StageName ==oppStageNegotiateandClose )){
                             mFlag = true;                                           
                           }                        
                        
                    //opp.Opportunity_Ready_for_OQB__c = 'Yes';
                   // mFlag = true;
                }
                else
                {   
                    //opp.Opportunity_Ready_for_OQB__c = 'No';
                   mFlag = false ;
                }
            }
            /*Account acc = [SELECT Id,SBSPilot__c  FROM account where id = : opp.AccountId];*/
            if(opp.Name != null
               && opp.AccountId != null
               && opp.CurrencyIsoCode != null
               && opp.CloseDate != null
               && opp.ForecastCategory != null
               && opp.Opportunity_Product_Count__c > 0
               && (opp.Customer_intent_to_buy__c != null &&
                   opp.Local_experience_and_resources_to_win__c != null && opp.Relations_with_customer_decision_maker__c != null &&
                   opp.Customer_sourcing_work__c != null && opp.Impact_Customer_and_RfQ__c != null &&
                   opp.WDR_3PP_share_of_total_cost__c != null && opp.Advantantage_towards_the_customer__c != null &&
                   opp.Extraordinary_challenges_or_risks__c != null && opp.Solid_solution_and_references__c != null &&
                   opp.Non_delegated_business__c != null && opp.Confidence_to_win_winning_value__c != null )
               && opp.Will_Opp_involve_intermediate_partner__c != null && opp.Ship_To_Countries__c != null
               &&  opp.Trade_Classifications__c != null
               && opp.End_Customer__c != null ){
                   flag = true;
                   if(opp.Has_Less_Sensitive_Country__c) {
                       if(opp.Sensitive_Products_in_scope__c == null) {
                           flag = false;
                       }
                   }if(opp.What_is_the_Technology_Risk__c == null && !opp.SBSPilot__c){
                       flag = false;
                   }
               }
            if(mFlag==False || flag== False){
                if(opp.StageName ==oppStageQualifyOppty || opp.StageName ==oppStageDefineCustomerValue 
                   ||opp.StageName ==oppStageCreateProposal ||opp.StageName ==oppStageNegotiateandClose  ){
                       opp.OpportunityNotReadyReason__c = GlobalConstants.BLANK;
                       if(opp.MarketArea__c == GlobalConstants.MELA){
                           if( opp.OpportunityNotReadyReason__c  == null || opp.OpportunityNotReadyReason__c == GlobalConstants.OpptyReadyString){
                               opp.OpportunityNotReadyReason__c = GlobalConstants.BLANK;
                           }
                           if(opp.Tags__c == null 
                              || (opp.Tags__c != null && !(opp.Tags__c.countMatches(GlobalConstants.MELADS) == 1 && !opp.Tags__c.contains(GlobalConstants.MELANMS)) &&
                                  !(opp.Tags__c.countMatches(GlobalConstants.MELANMS) == 1 && !opp.Tags__c.contains(GlobalConstants.MELADS)))) {
                                      opp.OpportunityNotReadyReason__c += GlobalConstants.Opportunity_Tags +GlobalConstants.newLine1;  
                                  }  
                           if(opp.CloseDate < System.Today() || opp.CloseDate == null) 
                           {
                                      opp.OpportunityNotReadyReason__c += GlobalConstants.Close_Date + GlobalConstants.newLine1; 
                                  }if(opp.StageName ==oppStageQualifyOppty || opp.StageName ==oppStageDefineCustomerValue 
                   ||opp.StageName ==oppStageCreateProposal){
                        if(opp.Proposal_Submission_Date__c < System.Today() || opp.Proposal_Submission_Date__c == null){
                                       opp.OpportunityNotReadyReason__c += GlobalConstants.Proposal_Sub_Date_NotNULLandNotPast + GlobalConstants.newLine1 ; 
                                  }}
                           if(opp.StageName ==oppStageNegotiateandClose){
                                if(opp.Proposal_Submission_Date__c >= System.Today() || opp.Proposal_Submission_Date__c == null){
                                     opp.OpportunityNotReadyReason__c += GlobalConstants.Proposal_Sub_Date_NotFuture + GlobalConstants.newLine1 ;
                               }}
                       }
                       if(opp.Opportunity_Product_Count__c == 0){
                           opp.OpportunityNotReadyReason__c  += GlobalConstants.Products + GlobalConstants.newLine1 ;
                       }if(opp.Customer_intent_to_buy__c == null
                           || opp.Local_experience_and_resources_to_win__c == null
                           || opp.Relations_with_customer_decision_maker__c == null
                           || opp.Customer_sourcing_work__c == null
                           || opp.Impact_Customer_and_RfQ__c == null
                           || opp.WDR_3PP_share_of_total_cost__c == null
                           || opp.Advantantage_towards_the_customer__c == null
                           || opp.Extraordinary_challenges_or_risks__c == null
                           || opp.Solid_solution_and_references__c == null
                           || opp.Non_delegated_business__c == null
                           || opp.Confidence_to_win_winning_value__c == null
                          ){
                              opp.OpportunityNotReadyReason__c += GlobalConstants.Qualification_FrameworkWDR + GlobalConstants.newLine1 ;
                          }if(opp.Ship_To_Countries__c == null){
                              opp.OpportunityNotReadyReason__c  += GlobalConstants.Ship_To_Countries + GlobalConstants.newLine1 ;
                          }if(opp.Will_Opp_involve_intermediate_partner__c == null){
                              opp.OpportunityNotReadyReason__c  += GlobalConstants.Will_Opp_Involve_Intermediate_Partner + GlobalConstants.newLine1 ;
                          }if(opp.What_is_the_Technology_Risk__c == null && !opp.SBSPilot__c){
                              opp.OpportunityNotReadyReason__c  += GlobalConstants.What_is_the_Technology_Risk + GlobalConstants.newLine1 ;
                          }if(opp.Trade_Classifications__c == null){
                              opp.OpportunityNotReadyReason__c  += GlobalConstants.Trade_Classification + GlobalConstants.newLine1 ;
                          }if(opp.End_Customer__c == null){
                              opp.OpportunityNotReadyReason__c  += GlobalConstants.End_Customer+GlobalConstants.newLine1 ;
                          }if(opp.Has_Less_Sensitive_Country__c == true &&
                              opp.Sensitive_Products_in_scope__c == null){
                                  opp.OpportunityNotReadyReason__c  += GlobalConstants.Sensitive_Products_in_Scope + GlobalConstants.newLine1 ;
                              } } }else{
                                  opp.OpportunityNotReadyReason__c = GlobalConstants.OpptyReadyString;
                              }
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,  GlobalConstants.checkForStage1and2, GlobalConstants.OpportunityTriggerHelper, true, e)));
                           }
        if(GlobalConstants.frameStandRecordTypes.contains(opp.RecordTypeId) && opp.MarketArea__c == GlobalConstants.MELA)
        {
            if(mFlag && flag){
                return true;
            }else return false;
        } return flag;
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 04-11-2019
* @User Story: 1084
* @description: 
*****************************************************************/
    public static Boolean checkForStage2(Opportunity opp ,Opportunity oldOpp) {
        Boolean flag = true;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        try{
            if(opp.Estimated_Delivery_Start_Date__c == null || opp.Estimated_Delivery_End_Date__c==null) {
                flag = false;
            }
			if(opp.IsPartofPilot__c  && opp.ABCIsNew__c){
				if(!opp.Approved_In_Stage2__c && (oldOpp.stageName == oppStageDefineCustomerValue  || opp.stageName == oppStageDefineCustomerValue)){
				flag = false;
				}
            }
            if(!flag &&(opp.StageName ==oppStageDefineCustomerValue ||opp.StageName ==oppStageCreateProposal ||opp.StageName ==oppStageNegotiateandClose)){
                if( opp.OpportunityNotReadyReason__c  == null || opp.OpportunityNotReadyReason__c == GlobalConstants.OpptyReadyString){
                    opp.OpportunityNotReadyReason__c = GlobalConstants.BLANK;
                }if(opp.Estimated_Delivery_Start_Date__c == null){
                    opp.OpportunityNotReadyReason__c  += GlobalConstants.Estimated_Project_Start_Date + GlobalConstants.newLine1 ;
                }
                if(opp.IsPartofPilot__c  && opp.ABCIsNew__c && opp.ABCApprovalStatus__c != GlobalConstants.ApprovedforStage2 && opp.StageName ==oppStageDefineCustomerValue){
                    opp.OpportunityNotReadyReason__c += GlobalConstants.msgforStage2+ GlobalConstants.newLine1;
                }
                if(opp.Estimated_Delivery_End_Date__c == null){
                    opp.OpportunityNotReadyReason__c  += GlobalConstants.Estimated_Project_End_Date + GlobalConstants.newLine1 ;
                }} else{
                    opp.OpportunityNotReadyReason__c  = GlobalConstants.OpptyReadyString;
                }
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.checkForStage1and2, GlobalConstants.OpportunityTriggerHelper, true, e)));}
        return flag;
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 04-11-2019
* @User Story: 1084
* @description: 
*****************************************************************/
    public static Boolean checkForStage3(Opportunity opp,Opportunity oldOpp) {
        Boolean flag = false;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close ;
        try{
            //First check common fields
            if(
                opp.Is_Extended_Warranty_SiA_included__c !=null && opp.Voucher_or_FoC_Items_included__c !=null 
                && (opp.Sensitive_Business_Status__c == GlobalConstants.Not_Required ||opp.Sensitive_Business_Status__c == GlobalConstants.APPROVED 
                    ||opp.Sensitive_Business_Status__c ==  GlobalConstants.Approved_with_condition)
                && opp.Consideration_payable_to_customer_incl__c != null && (opp.Trade_Compliance_Status__c == GlobalConstants.APPROVED
                                                                             || opp.Trade_Compliance_Status__c ==GlobalConstants.Not_Required)){
                                                                                 if(!opp.Lock_Small_Value__c && !opp.Not_Deviating_from_Parent__c && !opp.Managed_Services_Governance__c ){
                                                                                     if(opp.Cashflow_Analysis_Status__c == GlobalConstants.Complete && opp.Risk_Assessment_Status__c == GlobalConstants.Complete ){
                                                                                         flag = true;
                                                                                     }
                                                                                 }
                                                                                
                                                                                 //U-1584
                                                                                 if(opp.High_Impact_Deal__c) {
                                                                                     if(opp.MA_Head__c == null || opp.BA_Head__c == null||(opp.Cashflow_Analysis_Status__c != GlobalConstants.Complete && opp.Risk_Assessment_Status__c != GlobalConstants.Complete)) {
                                                                                         flag = false;
                                                                                     }
                                                                                     else{
                                                                                         flag = true;
                                                                                     }
                                                                                 }
                                                                                 else if(opp.Lock_Small_Value__c || opp.Not_Deviating_from_Parent__c || opp.Managed_Services_Governance__c){
                                                                                     flag = true;
                                                                                 }
                                                                             }
                                                                              if(opp.IsPartofPilot__c  && opp.ABCIsNew__c){
                if (!opp.Approved_In_Stage3__c && (opp.StageName ==oppStageCreateProposal || oldOpp.StageName ==oppStageCreateProposal)){
                    flag = false;
                }
            }
            //U-2279
            Boolean activeSAFlag = false;
            Boolean notActiveSAFlag = false;
            if(opp.SBSPilot__c && opp.Sensitive_Business_Status__c == 'Required') {
                System.debug('##SBS check for stage 3 #1'+opp.ActiveSensitiveBusinessApproval__c);
                if(opp.ActiveSensitiveBusinessApproval__c != null) {
                    System.debug('##SBS check for stage 3 #2');
                    Secondary_Approval__c sa = [Select Id, Name, Approval_Status__c from Secondary_Approval__c where ID =: opp.ActiveSensitiveBusinessApproval__c];
                    System.debug('##SBS check for stage 3 #3' +sa);
                    if(sa.Approval_Status__c != 'Approved' && sa.Approval_Status__c != 'Completed') {
                        flag = false;
                        activeSAFlag = true;
                        System.debug('##SBS check for stage 3 #4'+flag);
                    }
                    else {flag=true;}
                }
                else if(opp.ActiveSensitiveBusinessApproval__c == null) {
                    flag = false;
                    notActiveSAFlag = true;
                    System.debug('##SBS check for stage 3 #5'+flag);
                }
                else {flag=true;}
            }
            System.debug('##flag '+flag);
            if(!flag && (opp.StageName ==oppStageCreateProposal ||opp.StageName ==oppStageNegotiateandClose)){
                if( opp.OpportunityNotReadyReason__c  == null || opp.OpportunityNotReadyReason__c == GlobalConstants.OpptyReadyString){
                    opp.OpportunityNotReadyReason__c = GlobalConstants.BLANK;
                }if(!opp.SBSPilot__c && (opp.Sensitive_Business_Status__c != GlobalConstants.Not_Required &&opp.Sensitive_Business_Status__c != GlobalConstants.APPROVED 
                                         &&opp.Sensitive_Business_Status__c !=  GlobalConstants.Approved_with_condition)){
                                             opp.OpportunityNotReadyReason__c  += GlobalConstants.Sensitive_Business_Status + GlobalConstants.newLine1 ;
                                         }if(opp.IsPartofPilot__c  && opp.ABCIsNew__c && opp.ABCApprovalStatus__c != GlobalConstants.ApprovedforStage3 && opp.StageName == oppStageCreateProposal){
                                             opp.OpportunityNotReadyReason__c += GlobalConstants.msgforStage3+ GlobalConstants.newLine1;
                                         }                
                if(opp.Is_Extended_Warranty_SiA_included__c == null){
                         opp.OpportunityNotReadyReason__c  += GlobalConstants.Is_Extended_Warranty_SiA_included + GlobalConstants.newLine1 ;
                     }if(opp.Voucher_or_FoC_Items_included__c == null){
                         opp.OpportunityNotReadyReason__c  += GlobalConstants.Voucher_FoC_Items_Included + GlobalConstants.newLine1 ;
                     }if(opp.Consideration_payable_to_customer_incl__c == null){
                         opp.OpportunityNotReadyReason__c  += GlobalConstants.Consideration_Payable_To_Customer_Inclusive + GlobalConstants.newLine1 ;
                     }if(opp.Trade_Compliance_Status__c == GlobalConstants.REQUIRED || opp.Trade_Compliance_Status__c == GlobalConstants.Rejected || opp.Trade_Compliance_Status__c == GlobalConstants.PENDINGAPPROVAL){
                         opp.OpportunityNotReadyReason__c  += GlobalConstants.Trade_Compliance_Secondary_Approval + GlobalConstants.newLine1 ;
                     }
                if(!opp.Lock_Small_Value__c && !opp.Not_Deviating_from_Parent__c && !opp.Managed_Services_Governance__c ){  
                    if(opp.Cashflow_Analysis_Status__c != GlobalConstants.Complete ){
                        opp.OpportunityNotReadyReason__c  += GlobalConstants.Cashflow_Analysis_Status+ GlobalConstants.newLine1 ;
                    }if(opp.Risk_Assessment_Status__c != GlobalConstants.Complete){
                        opp.OpportunityNotReadyReason__c  += GlobalConstants.Risk_Assessment_Status+ GlobalConstants.newLine1 ; 
                    }
                }if(opp.High_Impact_Deal__c) {
                    if(opp.MA_Head__c == null) {
                        opp.OpportunityNotReadyReason__c  += GlobalConstants.MA_Head + GlobalConstants.newLine1 ;
                    } if(opp.BA_Head__c == null){
                        opp.OpportunityNotReadyReason__c  += GlobalConstants.BA_Head + GlobalConstants.newLine1 ;    
                    }//U-1584
                    if(opp.Cashflow_Analysis_Status__c != GlobalConstants.Complete && !opp.OpportunityNotReadyReason__c.contains(GlobalConstants.Cashflow_Analysis_Status)){
                        opp.OpportunityNotReadyReason__c  += GlobalConstants.Cashflow_Analysis_Status + GlobalConstants.newLine1 ;    
                    }if(opp.Risk_Assessment_Status__c != GlobalConstants.Complete && !opp.OpportunityNotReadyReason__c.contains(GlobalConstants.Risk_Assessment_Status)){
                        opp.OpportunityNotReadyReason__c  += GlobalConstants.Risk_Assessment_Status+ GlobalConstants.newLine1 ;
                    }
                }
                //U-2279
                if(opp.SBSPilot__c) {
                    System.debug('##SBS check for stage 3 #61'+opp.SBSPilot__c);
                    if(activeSAFlag) {
                        opp.OpportunityNotReadyReason__c  += 'Secondary Approval should be in Approved/Complete State' + GlobalConstants.newLine1 ;
                        System.debug('##SBS check for stage 3 #7'+opp.OpportunityNotReadyReason__c);
                    }
                    else if(notActiveSAFlag) {
                        opp.OpportunityNotReadyReason__c  += 'No Active Secondary Approval Present' + GlobalConstants.newLine1 ;
                        System.debug('##SBS check for stage 3 #8'+opp.OpportunityNotReadyReason__c);
                    }
                }
            }else{
                opp.OpportunityNotReadyReason__c  = GlobalConstants.OpptyReadyString;
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,  GlobalConstants.checkForStage3, GlobalConstants.OpportunityTriggerHelper, true, e)));}
        return flag;
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 04-11-2019
* @User Story: 1084
* @description:
* @date: 05-11-2020
* @User Story: 1760
* @description: Added Check for Proposal Submission Date can not be in Future in Stage 4 (Amit Ojha)
*****************************************************************/
    public static Boolean checkForStage4(Opportunity opp) {
        Boolean flag = true;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close ;
        try{
            if(opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.Approved_with_condition)) {    
                if(!opp.I_confirm_the_SB_Conditional_Adherence__c) {
                    flag = false;
                }   
            }
            if(opp.IsPartofPilot__c && opp.ABCIsNew__c){
                if (!opp.Approved_In_Stage4__c || opp.ABCConditionalAdherance__c != 'Yes'){
                    flag = false;
                }
            }
            // U-1760 Proposal Submission Date can not be in Future in Stage 4 - Start
            if(opp.Proposal_Submission_Date__c != null && opp.Proposal_Submission_Date__c > system.today()){
                 flag = false;
                 }   // U-1760 - End
			// U-1997 - Start
            if(opp.Opportunity_Tier__c != GlobalConstants.TIER3 && 
               ( opp.Contract_Evaluation_Status__c != GlobalConstants.Complete)
              && !opp.Not_Deviating_from_Parent__c){
                 flag = false;
                 }  // U-1997 - End
            //U-2279
            Boolean activeSAFlag = false;
            Boolean notActiveSAFlag = false;
            if(opp.SBSPilot__c && opp.Sensitive_Business_Status__c == 'Required') {
                System.debug('##SBS check for stage 3 #11'+opp.ActiveSensitiveBusinessApproval__c);
                if(opp.ActiveSensitiveBusinessApproval__c != null) {
                    System.debug('##SBS check for stage 3 #21');
                    Secondary_Approval__c sa = [Select Id, Name, Approval_Status__c from Secondary_Approval__c where ID =: opp.ActiveSensitiveBusinessApproval__c];
                    System.debug('##SBS check for stage 3 #31' +sa);
                    if(sa.Approval_Status__c != 'Approved' && sa.Approval_Status__c != 'Completed') {
                        flag = false;
                        activeSAFlag = true;
                        System.debug('##SBS check for stage 3 #41'+flag);
                    }
                    else {flag=true;}
                }
                else if(opp.ActiveSensitiveBusinessApproval__c == null) {
                    flag = false;
                    notActiveSAFlag = true;
                    System.debug('##SBS check for stage 3 #51'+flag);
                }
                else {flag=true;}
            }
            if(!flag && opp.StageName == GlobalConstants.Negotiate_and_Close ){
                if( opp.OpportunityNotReadyReason__c  == null || opp.OpportunityNotReadyReason__c == GlobalConstants.OpptyReadyString){
                            opp.OpportunityNotReadyReason__c = GlobalConstants.BLANK;
                        }if(opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.Approved_with_condition)){
                    if(opp.I_confirm_the_SB_Conditional_Adherence__c !=true  ){
                        opp.OpportunityNotReadyReason__c += GlobalConstants.I_Confirm_The_SB_Conditional_Adherence + GlobalConstants.newLine1;
                    }
                }
                if(opp.IsPartofPilot__c && opp.StageName == oppStageNegotiateandClose  && opp.ABCIsNew__c){
                  if(opp.ABCApprovalStatus__c != GlobalConstants.ApprovedforStage4){
                    opp.OpportunityNotReadyReason__c += GlobalConstants.msg1forStage4 + GlobalConstants.newLine1;
                  } if(opp.ABCConditionalAdherance__c != 'Yes'){
                      opp.OpportunityNotReadyReason__c += GlobalConstants.msg2forStage4 + GlobalConstants.newLine1;
                  }
                }
                    
                // U-1760 - Start
                if(opp.Proposal_Submission_Date__c != null && opp.Proposal_Submission_Date__c > system.today()){
                opp.OpportunityNotReadyReason__c  += GlobalConstants.Proposal_Sub_Date_NotFuture + GlobalConstants.newLine1 ;
            } // U-1760 - End
			// U-1997 - Start
           if(opp.Opportunity_Tier__c != GlobalConstants.TIER3 && 
               ( opp.Contract_Evaluation_Status__c != GlobalConstants.Complete)
              && !opp.Not_Deviating_from_Parent__c){
                  opp.OpportunityNotReadyReason__c  += GlobalConstants.completeContractEval + GlobalConstants.newLine1 ;
                 }   // U-1997 - End
                
                //U-2279
                if(opp.SBSPilot__c) {
                    System.debug('##SBS check for stage 3 #61'+opp.SBSPilot__c);
                    if(activeSAFlag) {
                        opp.OpportunityNotReadyReason__c  += 'Secondary Approval should be in Approved/Complete State' + GlobalConstants.newLine1 ;
                        System.debug('##SBS check for stage 3 #71'+opp.OpportunityNotReadyReason__c);
                    }
                    else if(notActiveSAFlag) {
                        opp.OpportunityNotReadyReason__c  += 'No Active Secondary Approval Present' + GlobalConstants.newLine1 ;
                        System.debug('##SBS check for stage 3 #81'+opp.OpportunityNotReadyReason__c);
                    }
                }
                
            }else{
                opp.OpportunityNotReadyReason__c  = GlobalConstants.OpptyReadyString;
            }
        }catch(Exception e) { EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.checkForStage4, GlobalConstants.OpportunityTriggerHelper, true, e)));
                            }
        return flag;        
    }
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 04-11-2019
* @User Story: 1084
* @description: 
*****************************************************************/
    public static boolean checkForClosedWon(Opportunity opp) {
        Boolean flag = false;
         String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close ;
        try{
            // Check common fields
            if(!opp.Override_Deal_Value_and_Margin__c){
                if(opp.Valid_Contracts_Count__c > 0 || opp.Completed_Contracts_Count__c > 0){
                    if(!opp.Lock_Small_Value__c && !opp.Not_Deviating_from_Parent__c && !opp.Managed_Services_Governance__c ){
                        if(opp.Valid_Contracts_Count__c > 0 || opp.Completed_Contracts_Count__c > 0){
                            flag = true;
                        }
                    }
                    else{
                        flag = true;
                    }
                }
            }
            if(opp.IsPartofPilot__c && opp.ABCIsNew__c){
                if (!opp.Approved_In_Stage4__c || opp.ABCConditionalAdherance__c != 'Yes'){
                    flag = false;
                }
            }

            if(!flag && opp.StageName == GlobalConstants.Negotiate_and_Close){
                if( opp.OpportunityNotReadyReason__c  == null || opp.OpportunityNotReadyReason__c == GlobalConstants.OpptyReadyString){
                    opp.OpportunityNotReadyReason__c = GlobalConstants.BLANK;
                }if( opp.Completed_Contracts_Count__c == 0){
                   opp.OpportunityNotReadyReason__c  = GlobalConstants.Completed_Contract + GlobalConstants.newLine1; 
                }if(opp.Valid_Contracts_Count__c == 0 ){
                    opp.OpportunityNotReadyReason__c  = GlobalConstants.Valid_Contract + GlobalConstants.newLine1; 
                }if(opp.IsPartofPilot__c && opp.StageName == oppStageNegotiateandClose  && opp.ABCIsNew__c){
                  if(opp.ABCApprovalStatus__c != GlobalConstants.ApprovedforStage4){
                    opp.OpportunityNotReadyReason__c += GlobalConstants.msg1forStage4 + GlobalConstants.newLine1;
                  } if(opp.ABCConditionalAdherance__c != 'Yes'){
                      opp.OpportunityNotReadyReason__c += GlobalConstants.msg2forStage4 + GlobalConstants.newLine1;
                  }
                }
            }else{
                opp.OpportunityNotReadyReason__c  = GlobalConstants.OpptyReadyString;
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.checkForClosedWon, GlobalConstants.OpportunityTriggerHelper, true, e)));
                            }
        return flag;
    }
    /****************************************************************
* @author: Pallavi Patil  
* @date: 17-01-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will needs to be fulfilled in order for "Opportunity Ready for OQB?" = Yes, otherwise it will display No
*****************************************************************/    
 /*   public static void updateOpportunityReadyForOQB(List<Opportunity> newOpportunities , Map<ID, Opportunity> oldOpportunitiesMap) {
        system.debug('####inside updateOpportunityReadyForOQB####');
        boolean flag;
        String oppStageQualifyOppty = System.Label.Sales_Stage_1_Qualify_Opportunity;
        //List<Opportunity> oppListupdate = new List<Opportunity>();
        try{ 
            for(Opportunity opp : newOpportunities ){
                if(GlobalConstants.frameStandRecordTypes.contains(opp.RecordTypeId))
                {
                if(opp.CloseDate > System.Today() && opp.Proposal_Submission_Date__c > System.Today()
                   && opp.Opportunity_Product_Count__c > 0
                   && opp.MarketArea__c == 'MELA'
                   && (opp.Customer_intent_to_buy__c != null && 
                       opp.Local_experience_and_resources_to_win__c != null && opp.Relations_with_customer_decision_maker__c != null &&
                       opp.Customer_sourcing_work__c != null && opp.Impact_Customer_and_RfQ__c != null &&
                       opp.WDR_3PP_share_of_total_cost__c != null && opp.Advantantage_towards_the_customer__c != null &&
                       opp.Extraordinary_challenges_or_risks__c != null && opp.Solid_solution_and_references__c != null &&
                       opp.Non_delegated_business__c != null && opp.Confidence_to_win_winning_value__c != null && 
                       (opp.Tags__c != null && (
                           !opp.Tags__c.contains(GlobalConstants.NEWLINE) && (opp.Tags__c.startsWith(GlobalConstants.MELADS) || opp.Tags__c.startsWith(GlobalConstants.MELANMS))))
                      ))
                {
                    system.debug('inside if');
                    opp.Opportunity_Ready_for_OQB__c = 'Yes';
                    flag = true;
                }
                else
                {   
                    opp.Opportunity_Ready_for_OQB__c = 'NO';
                    flag = false ;
                }
                if (!flag){
                    if(opp.MarketArea__c == 'MELA'){
                        if( opp.OpportunityNotReadyReason__c  == null || opp.OpportunityNotReadyReason__c == GlobalConstants.OpptyReadyString){
                            opp.OpportunityNotReadyReason__c = '';
                        }
                        if(opp.Tags__c == null){
                            opp.OpportunityNotReadyReason__c += 'Opportunity Tags' + GlobalConstants.newLine1 ;  
                        }if(opp.Tags__c!=null && !opp.Tags__c .startsWith(GlobalConstants.MELADS)){
                            opp.OpportunityNotReadyReason__c += 'Opportunity Tags MELA DS' + GlobalConstants.newLine1 ;   
                        }else if(opp.Tags__c!=null && !opp.Tags__c .startsWith(GlobalConstants.MELANMS)){
                            opp.OpportunityNotReadyReason__c += 'Opportunity Tags MELA NMS'+ GlobalConstants.newLine1 ; 
                        }if(opp.CloseDate < System.Today() || opp.CloseDate == null) {
                            opp.OpportunityNotReadyReason__c += 'Close Date' + GlobalConstants.newLine1; 
                        }if(opp.Proposal_Submission_Date__c < System.Today() || opp.Proposal_Submission_Date__c == null){
                            opp.OpportunityNotReadyReason__c += 'Proposal Submission Date'+ GlobalConstants.newLine1 ; 
                        }
                    }
                }else{
                    opp.OpportunityNotReadyReason__c  = GlobalConstants.OpptyReadyString;
                }
            }
            }  
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.updateOpportunityReadyForOQB, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }*/     
    public static void updateSDRcompletion( List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap ){
        Set<Id> oppIds = new Set<Id>();
        try{
            for(Opportunity opp :newOpportunities) {
                if(GlobalConstants.frameStandRecordTypes.contains(opp.RecordTypeId) 
                   && opp.Is_ready_for_progression__c!=oldOpportunitiesMap.get(opp.Id).Is_ready_for_progression__c) {oppIds.add(opp.Id);}
            }
            if(!oppIds.isEmpty()) {
                List<Sales_Decision_Record__c> sdrList = [SELECT id,SDRInSyncWithOpportunity__c, Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c, Opportunity__r.Not_Deviating_from_Parent__c,
                                                          Opportunity__r.Is_ready_for_progression__c, Sales_Decision_Type__c, Locked__c, Opportunity__r.High_Impact_Deal__c,
                                                          Opportunity__r.Opportunity_Progression_Type__c,
                                                          Opportunity__r.Opportunity_Tier__c /*,(SELECT ID,Approver_Role__c,Notification__c 
                                                                                               FROM Sales_Decision_Makers__r WHERE Approver_Name__c!=null)*/
                                                          FROM Sales_Decision_Record__c WHERE Opportunity__c IN: oppIds AND Locked__c=false
                                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(!sdrList.isEmpty()) {
                    Boolean isReady=false;
                    List<Sales_Decision_Record__c> sdrListtoUpdate = new List<Sales_Decision_Record__c>();
                    for(Sales_Decision_Record__c sdr : sdrList) {
                        if(GlobalConstants.NO.equalsIgnoreCase(sdr.Opportunity__r.Is_ready_for_progression__c) /*|| !sdr.SDRInSyncWithOpportunity__c*/) {
                            sdr.SDR_Completed__c=GlobalConstants.NO;
                            sdrListtoUpdate.add(sdr);
                        }/*else if(GlobalConstants.YES.equalsIgnoreCase(sdr.Opportunity__r.Is_ready_for_progression__c) && sdr.SDRInSyncWithOpportunity__c) {
                            isReady=SalesDecisionRecordUtility.readyForNextStage(sdr.Opportunity__r.High_Impact_Deal__c, 
                                                                                 sdr.Opportunity__r.Opportunity_Progression_Type__c, SDR.Opportunity__r.Opportunity_Tier__c, 
                                                                                 sdr.Opportunity__r.Not_Deviating_from_Parent__c, sdr.Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c, sdr, 
                                                                                 sdr.Sales_Decision_Makers__r);
                            if(isReady) {sdr.SDR_Completed__c=GlobalConstants.YES;sdrListtoUpdate.add(sdr);}*/
                         else if(GlobalConstants.YES.equalsIgnoreCase(sdr.Opportunity__r.Is_ready_for_progression__c)){
                             sdr.SDR_Completed__c=GlobalConstants.YES;
                             sdrListtoUpdate.add(sdr);
                        }else {}
                    }
                    if(!sdrListtoUpdate.isEmpty()) {
                        Database.update(sdrListtoUpdate);
                    }
                }
            }
        } 
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.updateOppTradeCompliance, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
        
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 4-10-2019
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will check if 'Sensitive Products in scope?' is Yes or No if Ship-to-Country on Opp or Account.BillingCountry is a less sensitive country(U-0913)
*****************************************************************/
public static void updateOppTradeCompliance(Map<ID, Opportunity> newOpportunitiesMap , Map<ID, Opportunity> oldOpportunitiesMap)
{
    try
    {
        List<String> sensitiveCountryList = new List<String>();
        List<String> lessSensitiveList = new List<String>();  
        Boolean sensitiveFlag;
        Boolean lessSensitiveFlag;
        Boolean runQueries = false;
        
        Set<String> shipToCountrySet;
        String billingCountry;
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> opptyIdSet = new Set<Id>(); 
        for(Opportunity opp : newOpportunitiesMap.values()){
            if(opp.Ship_To_Countries__c != oldOpportunitiesMap.get(opp.id).Ship_To_Countries__c ||
               opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.id).Trade_Classifications__c ||
               opp.Sensitive_Products_in_scope__c != oldOpportunitiesMap.get(opp.id).Sensitive_Products_in_scope__c){
                   runQueries = true;
               }
        }
        if(runQueries){
            for(Country_Risk__c countryRisk : [Select TC_Sensitivy_Class__c,Name from Country_Risk__c 
                                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                if(countryRisk.TC_Sensitivy_Class__c == GlobalConstants.SENSITIVE)
                    sensitiveCountryList.add(countryRisk.Name);
                else if(countryRisk.TC_Sensitivy_Class__c == GlobalConstants.LESSSENSITIVE)
                    lessSensitiveList.add(countryRisk.Name);
            }
            for(Opportunity opp : newOpportunitiesMap.values())
            {
                sensitiveFlag = false;
                lessSensitiveFlag = false;
                if(opp.Ship_To_Countries__c != null)
                {
                    shipToCountrySet = new Set<String>(opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON));
                    for(string str : shipToCountrySet)
                    {
                        if(sensitiveCountryList.contains(str))
                            sensitiveFlag  = true;  
                        if(lessSensitiveList.contains(str))
                            lessSensitiveFlag  = true; 
                    }
                }
                if(opp.Ship_To_Countries__c != oldOpportunitiesMap.get(opp.id).Ship_To_Countries__c ||
                   opp.Trade_Classifications__c != oldOpportunitiesMap.get(opp.id).Trade_Classifications__c )
                {
                    if(!sensitiveFlag && opp.Trade_Classifications__c != GlobalConstants.GOVERNMENT && opp.Trade_Classifications__c != GlobalConstants.DEFENSE)
                    {
                        accountIdSet.add(opp.AccountId); 
                        opptyIdSet.add(opp.id);
                    }
                }
            }
            if(!accountIdSet.isEmpty() && !opptyIdSet.isEmpty())
            {
                for(Opportunity opp : [SELECT id, Account.BillingCountry,Account.Trade_Classification__c,
                                       AccountId,Trade_Compliance_Status__c,
                                       Sensitive_Products_in_scope__c 
                                       FROM Opportunity 
                                       WHERE AccountId IN: accountIdSet and id IN: opptyIdSet
                                       LIMIT : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                { 
                    if(newOpportunitiesMap.get(opp.id).Account.BillingCountry != null)
                        //U-2274//billingCountry = opp.Account.BillingCountry.substringBefore(GlobalConstants.COMMA);
                        billingCountry = opp.Account.BillingCountry;
                    if(!sensitiveCountryList.contains(billingCountry) 
                       && newOpportunitiesMap.get(opp.id).Account.Trade_Classification__c != GlobalConstants.GOVERNMENT
                       && newOpportunitiesMap.get(opp.id).Account.Trade_Classification__c != GlobalConstants.DEFENSE)
                    {
                        newOpportunitiesMap.get(opp.id).Trade_Compliance_Status__c = GlobalConstants.NotRequired;
                        OpportunityTriggerHandler.tradeFlag = false;
                    }
                }
            }
        }
        
    }
    catch(Exception e) {
        EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                   GlobalConstants.updateOppTradeCompliance, GlobalConstants.OpportunityTriggerHelper, true, e)));
    }    
}
    /****************************************************************
* @author: Anukriti Agrawal  
* @date: 20-01-2020
* @param: U-1578
* @description: This Method refresh key information fields of SDR from Opp's fields
*****************************************************************/
    public static void refreshSDRInfo(List<Opportunity> newOpportunitiesList, Map<Id, Opportunity> newOpportunityMap,
                                      Map<Id, Opportunity> oldOpportunitiesMap){
                                          try{
                                              Set<Id> oppIds = new Set<Id>();
                                              for(Opportunity opp : newOpportunitiesList) {
                                                  if(GlobalConstants.frameStandRecordTypes.contains(opp.RecordTypeId)) {
                                                      Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
                                                      if(opp.stageName != oldOpp.stageName
                                                         || opp.Is_ready_for_progression__c != oldOpp.Is_ready_for_progression__c
                                                         || opp.Anticipated_Deal_Value__c != oldOpp.Anticipated_Deal_Value__c
                                                         || opp.Deal_Value__c != oldOpp.Deal_Value__c 
                                                         || opp.Margin__c != oldOpp.Margin__c 
                                                         || opp.Comments__c != oldOpp.Comments__c 
                                                         || opp.Opportunity_Tier__c != oldOpp.Opportunity_Tier__c
                                                         || opp.Lead_Domain__c != oldOpp.Lead_Domain__c
                                                         || opp.PD_Proposal_Link__c != oldOpp.PD_Proposal_Link__c
                                                         || opp.Trade_Compliance_Status__c != oldOpp.Trade_Compliance_Status__c 
                                                         || opp.Sensitive_Business_Status__c != oldOpp.Sensitive_Business_Status__c
                                                         || opp.High_Impact_Deal__c != oldOpp.High_Impact_Deal__c 
                                                         || opp.Tags__c != oldOpp.Tags__c
                                                         || opp.Pre_Sales_Budget__c != oldOpp.Pre_Sales_Budget__c 
                                                         || opp.Proposal_Submission_Date__c != oldOpp.Proposal_Submission_Date__c
                                                         || opp.CloseDate != oldOpp.closedate 
                                                         || opp.Qualification_Status__c != oldOpp.Qualification_Status__c
                                                         || opp.Team_Assignment__c != oldOpp.Team_Assignment__c
                                                         || opp.Qualification_Status_Date__c != oldOpp.Qualification_Status_Date__c
                                                         || opp.Opportunity_Product_Count__c != oldOpp.Opportunity_Product_Count__c
														 || opp.OpportunityNotReadyReason__c != oldOpp.OpportunityNotReadyReason__c) {
                                                             oppIds.add(opp.Id);                                                             
                                                         }
                                                  }
                                              }
                                               List<Sales_Decision_Record__c> sdrListToUpdate = new List<Sales_Decision_Record__c>();
                                              if(!oppIds.isEmpty()){
                                             
                                              for(Sales_Decision_Record__c sdr : [SELECT Id, Requested_SDM_Count__c, SDMCount__c, SDR_Flag__c, Opportunity__c, CurrencyIsoCode, DealMargin__c, Lead_Domain__c, Primary_PP_most_recent_PD__c, 
                                                                                  Qualification_Status__c, Qualification_Status_Date__c,Sales_Decision_Type__c,
                                                                                  Comments__c, Opportunity_Tags__c, Team_Assignment__c, Total_Pre_Sales_Budget__c, Proposal_Submission_Date__c,
                                                                                  Close_Date__c, Opportunity_Stage__c, Opportunity_progression_ready__c, Sales_Authority_Matrix__c,
                                                                                  Opportunity_Approval_flow__c, High_Impact_Deal__c, Sensitive_Business_Status__c,Trade_Compliance_Status__c, 
                                                                                  Opportunity_Deal_Value__c , SDR_Completed__c 
                                                                                  FROM Sales_Decision_Record__c WHERE opportunity__c IN :oppIds AND Locked__c=false AND Sales_Decision_Approval_Status__c !=: GlobalConstants.Rejected
                                                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                                                      Opportunity opp = newOpportunityMap.get(sdr.Opportunity__c);
                                                                                     //Reset Open SDRs to be in Sync and recall all approvers
                                                                                          sdr.SDRInSyncWithOpportunity__c = true;
                                                                                      		//sdr.Sales_Decision_Approval_Status__c = 'In Progress';
                                                                                      		SalesDecisionRecordUtility.mapSDRFields(sdr, opp);
                                                                                          sdrListToUpdate.add(sdr);                                          
                                                                                      
                                                                                  }}
                                              if(!sdrListToUpdate.isEmpty()){
                                                  Database.update(sdrListToUpdate);
                                                  //SalesDecisionRecordUtility.resetSDMs(sdrListToUpdate);
                                              }
                                          }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                                                                          GlobalConstants.refreshSDRInfo, GlobalConstants.OpportunityTriggerHelper, true, e)));}
                                      }
    
   /****************************************************************
* @author: Manu Singhal
* @date: 29-01-2020
* @param: D-2433
* @description: This Method will update sensitive business status on oppty according to trade classification, technology and country risk.
*****************************************************************/
    public static void updateSensitiveBusinessStatus(List<Opportunity> newOpportunitiesList,
                                                     Map<Id, Opportunity> oldOpportunitiesMap)
    {
        try
        {  
            if(sensitiveBusinessCheckCount == 0){ 
                for (opportunity opp: newOpportunitiesList) 
                {          
                    if ( !opp.SBSPilot__c && (opp.Sensitive_Business_Status__c == null || (!opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.APPROVED) && !opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.PENDINGAPPROVAL) && !opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.Rejected) && !opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.APPROVALINPROCESS) && !opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.Approved_with_condition) && !opp.Sensitive_Business_Status__c.equalsIgnoreCase(GlobalConstants.DISMISSED)))) 
                    {
                        System.debug('opp.SBSPilot__c'+ opp.SBSPilot__c);
                        Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
                        if(oldOpp != null)
                        {
                            if((opp.Trade_Classifications__c != oldOpp.Trade_Classifications__c) &&(opp.Trade_Classifications__c == GlobalConstants.DEFENSE || opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT))
                            {
                                opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                            }
                            else if((opp.Sales_Compliance_Country_Risk__c != oldOpp.Sales_Compliance_Country_Risk__c && GlobalConstants.HIGH_LOWER.equalsIgnoreCase(opp.Sales_Compliance_Country_Risk__c)) ||
                                    (opp.What_is_the_Technology_Risk__c != oldOpp.What_is_the_Technology_Risk__c && GlobalConstants.HIGH_CAMEL.equalsIgnoreCase(opp.What_is_the_Technology_Risk__c)))
                            {
                                opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                            }
                            else if((opp.Sales_Compliance_Country_Risk__c != oldOpp.Sales_Compliance_Country_Risk__c && GlobalConstants.MEDIUM_LOWER.equalsIgnoreCase(opp.Sales_Compliance_Country_Risk__c) && GlobalConstants.MEDIUM_CAMEL.equalsIgnoreCase(opp.What_is_the_Technology_Risk__c)) ||
                                    (opp.What_is_the_Technology_Risk__c != oldOpp.What_is_the_Technology_Risk__c && GlobalConstants.MEDIUM_CAMEL.equalsIgnoreCase(opp.What_is_the_Technology_Risk__c) && GlobalConstants.MEDIUM_LOWER.equalsIgnoreCase(opp.Sales_Compliance_Country_Risk__c)))
                            {
                                opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                            }
                            else if(opp.Trade_Classifications__c != GlobalConstants.DEFENSE && opp.Trade_Classifications__c != GlobalConstants.GOVERNMENT && opp.Sales_Compliance_Country_Risk__c != GlobalConstants.HIGH_LOWER && opp.What_is_the_Technology_Risk__c != GlobalConstants.HIGH_CAMEL)
                            {
                                if(!(opp.Sales_Compliance_Country_Risk__c == GlobalConstants.MEDIUM_LOWER && opp.What_is_the_Technology_Risk__c == GlobalConstants.MEDIUM_CAMEL))
                                {
                                    opp.Sensitive_Business_Status__c = GlobalConstants.NotRequired ;
                                }
                            }
                        }
                    }
                }
                sensitiveBusinessCheckCount++;
            }          
        }
        catch(Exception e) 
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.updateSensitiveBusinessStatus, GlobalConstants.OpportunityTriggerHelper, true, e)));}
    }
    public static void calculateCountryRisk(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldMap) {
        Try{
        for(Opportunity opp : newOpportunities){
            if((Trigger.isUpdate && oldMap.get(opp.id).Ship_To_Countries__c != opp.Ship_To_Countries__c)
               || (Trigger.isInsert)){
                   //Low value = High Risk
                   Decimal highestRisk;
                   Decimal[] riskList = new List<Decimal>();
                   List<string> countries;
                   if(opp.Ship_To_Countries__c!=null) {
                       for(String country : opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON)){
                           Country_Risk__c cr = Country_Risk__c.getValues(country);

                               
                           highestRisk = (cr != null && cr.RiskValue__c != null && cr.RiskValue__c < highestRisk) ? cr.RiskValue__c : (cr != null  && cr.RiskValue__c != null && highestRisk== null ? cr.RiskValue__c : highestRisk) ;
                       }
                   }
                      opp.CountryRiskValue__c =  highestRisk;    
               }
        }
            }catch(Exception e){	}
    }
    
    /****************************************************************
* @author: Ankit Jain 
* @date: 15-04-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will update Opportunity Approved_SDP_Stage__c after oppty update.(U-1737 & U-1733)
*****************************************************************/
    public static void updateOpportunityApprovedSdpStage(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap)
    {
        try
        {
            for(Opportunity opp: newOpportunitiesList)
            {
                Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
                 if((opp.High_Impact_Deal__c != oldOpp.High_Impact_Deal__c)||(opp.Primary_Proposal__c!=oldOpp.Primary_Proposal__c)||(opp.Trade_Compliance_Status__c!=oldOpp.Trade_Compliance_Status__c && (GlobalConstants.REQUIRED).equalsIgnoreCase(opp.Trade_Compliance_Status__c) && ('3. Create Proposal'.equalsIgnoreCase(opp.StageName)|| GlobalConstants.Negotiate_and_Close.equalsIgnoreCase(opp.StageName)))||(opp.Sensitive_Business_Status__c!=oldOpp.Sensitive_Business_Status__c && 'Required'.equalsIgnoreCase(opp.Sensitive_Business_Status__c) && (GlobalConstants.Create_Proposal.equalsIgnoreCase(opp.StageName)|| GlobalConstants.Negotiate_and_Close.equalsIgnoreCase(opp.StageName))))
                {
                    opp=SalesDecisionRecordUtility.MarkOppoyApprovedSDPStageToObsolete(opp);
                    /*if(opp.Approved_SDP_Stage__c!=null){
                        if((opp.Approved_SDP_Stage__c=='OQB' && opp.StageName=='1. Qualify Opportunity' && opp.MarketArea__c=='MELA')
                           ||(opp.Approved_SDP_Stage__c=='SDP1 Invest to Win' && opp.StageName=='2. Define Customer Value' && !opp.Not_Deviating_from_Parent__c && opp.Opportunity_Tier__c!='Minor' && opp.MarketArea__c!='MELA')
                          ||(opp.Approved_SDP_Stage__c=='SDP2 Submit Proposal' && opp.StageName=='3. Create Proposal' && !opp.Not_Deviating_from_Parent__c && opp.Opportunity_Tier__c!='Minor')
                          ||(opp.Approved_SDP_Stage__c=='SDP3 Sign Contract' && opp.StageName=='4. Negotiate and Close' && !opp.Not_Deviating_from_Parent__c && opp.Opportunity_Tier__c!='Minor' && opp.RecordTypeId!=System.Label.Record_Type_ID_Simple_Opportunity && opp.RecordTypeId!=System.Label.Record_Type_ID_Simple_Opportunity_Create)){
                              opp.Approved_SDP_Stage__c='obsolete';
                        }
                    }*/
                }
            }
        }
        catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.updateOpportunityApprovedSdpStage, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }   
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 17-04-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will update ship to country text field on opp.
*****************************************************************/
    public static void updateShipToCountryText(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap, Boolean isInsert)
    {
        
        try
        {
          Map<String, string> mmmp = fetchMapShipToCountry();
          string strship = null;
         // mmmp = fetchMapShipToCountry();
            for(Opportunity opp : newOpportunitiesList)
            {
                // Comment as part of U-1859, D-2910  - Start
               /** if(isInsert)
                {
                    if(opp.Ship_To_Countries__c != null){
                        //mmmp = fetchMapShipToCountry();
                        strship = fetchStringShipToCountry(opp,mmmp);
                        //opp.ShipToCountryText__c = opp.Ship_To_Countries__c;
                        opp.ShipToCountryText__c = strship;
                    }
                      
                }**/
                // Comment as part of U-1859, D-2910  - End
				if (opp.Ship_To_Countries__c != null && (oldOpportunitiesMap==null || opp.Ship_To_Countries__c != oldOpportunitiesMap.get(opp.id).Ship_To_Countries__c))
                {
                   // mmmp = fetchMapShipToCountry();
                    strship = fetchStringShipToCountry(opp,mmmp);
                    //opp.ShipToCountryText__c = opp.Ship_To_Countries__c;  as part of U-1859, D-2910
                    opp.ShipToCountryText__c = strship;
                }
            }
        }
        catch(Exception e) { EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                                        GlobalConstants.UPDATEOPPORTUNITYTIER, GlobalConstants.OpportunityTriggerHelper, true, e)));
                           }   
    }
/****************************************************************
* @author: Pallavi Patil
* @date: 22-06-2020
* @story: U-1859, D-2910
* @description: This method will Fetch Ship to coutry API name and Label in a Map.
*****************************************************************/
 public static Map<String, string> fetchMapShipToCountry()
 {
     Schema.DescribeFieldResult fieldResult = Opportunity.Ship_To_Countries__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        string strship = null;
        Map<String, string> mmmp = new  Map<String, string>();
     Try{
        for( Schema.PicklistEntry pickListVal : ple){
            mmmp.put(pickListVal.getValue(), pickListVal.getLabel());
        }
         }catch(Exception e){	}
     return mmmp;
 }
    /****************************************************************
* @author: Pallavi Patil
* @date: 22-06-2020
* @story: U-1859, D-2910
* @param: Opportunity, Map of API and Label of ShiptoCoutry Picklist
* @description: This method will Fetch Ship to coutry API name and Label in a Map.
*****************************************************************/
 public static string fetchStringShipToCountry(opportunity opp,Map <String, string> mmmp)
 {	
     string strship = null;
     if(opp.Ship_To_Countries__c != null) {
     String[] arrSplit = opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON);
     for (string str : arrSplit)
     {
                if(strship == null )
                strship = mmmp.get(str.trim());
 
                else
                    strship = strship+GlobalConstants.SEMICOLON+mmmp.get(str);
            }
     }
     return strship;
 }
    /*****************************************************************************
* @author: Richa Gupta
* @date: 23-04-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will recall SDM For all 'Ongoing Approval' SDR(D-2729)
***********************************************************************************/ 
    public static void recallSDM(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        Set<Id> oppIdSet = new Set<Id>();
        List<Sales_Decision_Record__c> sdrListToRecall;
        try{
            for(Opportunity opp: newOpportunitiesList){
                Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
                if((opp.High_Impact_Deal__c != oldOpp.High_Impact_Deal__c)||(opp.Primary_Proposal__c!=oldOpp.Primary_Proposal__c)||(opp.Trade_Compliance_Status__c!=oldOpp.Trade_Compliance_Status__c && opp.Trade_Compliance_Status__c==GlobalConstants.REQUIRED && (opp.StageName== GlobalConstants.oppStg3|| opp.StageName== GlobalConstants.oppStg4))||(opp.Sensitive_Business_Status__c!=oldOpp.Sensitive_Business_Status__c && opp.Sensitive_Business_Status__c== GlobalConstants.REQUIRED && (opp.StageName== GlobalConstants.oppStg3|| opp.StageName== GlobalConstants.oppStg4))){
                    oppIdSet.add(Opp.id);}
                }
                if(!oppIdSet.isEmpty())
                {
                    sdrListToRecall = [SELECT Id,Sales_Decision_Approval_Status__c, Opportunity__c   
                                       FROM Sales_Decision_Record__c 
                                       WHERE opportunity__c IN :oppIdSet AND Sales_Decision_Approval_Status__c = :GlobalConstants.APPROVALSONGOING
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
               
                                       if(!sdrListToRecall.isEmpty())
                                       SalesDecisionRecordUtility.resetSDMs(sdrListToRecall);
                }
                
                
            }
        
        catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper,  GlobalConstants.updateOpportunityApprovedSdpStage, GlobalConstants.OpportunityTriggerHelper, true, e)));
                          }}
	   /****************************************************************
* @author: Ankit Jain 
* @date: 29-04-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will send confirmation email to SDMs.(U-1737 & U-1733)
*****************************************************************/
    public static void updateOpportunityStageChange(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
		if(oppStageChangeCount==0){
            List<Sales_Decision_Maker__c> makerList = new List<Sales_Decision_Maker__c>();
            List<id> sdrIdList=new List<id>();
            List<id> oppIdList=new List<id>();
            for(Opportunity opp: newOpportunitiesList)
            {
                Opportunity oldOpp = oldOpportunitiesMap.get(opp.Id);
                if(opp.StageName!=oldOpp.StageName &&(GlobalConstants.Qualify_Opportunity.equalsIgnoreCase(oldOpp.StageName)||GlobalConstants.Define_CustomerValue.equalsIgnoreCase(oldOpp.StageName)||GlobalConstants.Create_Proposal.equalsIgnoreCase(oldOpp.StageName)||GlobalConstants.Negotiate_and_Close.equalsIgnoreCase(oldOpp.StageName))){
                    sdrIdList.add(opp.LatestApprovedSDR__c);
                }
            }
            //NS
            /*List<Sales_Decision_Record__c> sdrList=[select id,Sales_Decision_Type__c,(SELECT ID,Notification__c,Approver_Role__c 
            										 FROM Sales_Decision_Makers__r WHERE Approver_Name__c!=null) 
                									 from Sales_Decision_Record__c where id in :sdrIdList];*/
            if(!sdrIdList.isEmpty()){
            	for(Sales_Decision_Record__c sdr:[select id,Sales_Decision_Type__c,(SELECT ID,Notification__c,Approver_Role__c 
            								 FROM Sales_Decision_Makers__r WHERE Approver_Name__c!=null) 
                							 from Sales_Decision_Record__c where id in :sdrIdList]){
                for(Sales_Decision_Maker__c sdm : sdr.Sales_Decision_Makers__r) {
                    sdm.Notification__c = true;
                    makerList.add(sdm);
                }
            }    
            }
            
            if(makerList!=null){
                update makerList;    
            }
			oppStageChangeCount++;
            }
        }
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.updateOpportunityStageChange, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Ankit Jain 
* @date: 14-05-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: This method will update primary proposal to Close Won.(D-1928)
*****************************************************************/
    public static void updatePrimaryProposalClosedWon(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
            if(updatePPCloseWonCount==0){
                List<id> oppIdList=new List<id>();
                for(Opportunity opp: newOpportunitiesList)
                {
                    if(GlobalConstants.oppStageClosedWon.equalsIgnoreCase(opp.StageName)&&(GlobalConstants.TrueVal.equalsIgnoreCase(opp.Primary_Proposal_Approved__c) || (GlobalConstants.SIMPLEOPPORTUNITYNAME).equalsIgnoreCase(opp.RecordTypeName__c))){
                        oppIdList.add(opp.id);
                    }
                }
                if(!oppIdList.isEmpty()){
                    List<Proposal__c> proposalList=[select id,Is_Closed_Won__c,Opportunity__c,Primary__c,Opportunity__r.RecordTypeName__c from Proposal__c where Opportunity__c in:oppIdList and Is_Closed_Won__c=false and Primary__c=true Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                    for(Proposal__c prop:proposalList){
                        prop.Is_Closed_Won__c=true;
                        if(!GlobalConstants.SIMPLEOPPORTUNITYNAME.equalsIgnoreCase(prop.Opportunity__r.RecordTypeName__c)){
                            prop.Last_Approved_Date__c=System.today();
                        }
                    }
                    database.update(proposalList);    
                }
                updatePPCloseWonCount++;
            }
        }
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.updatePrimaryProposalClosedWon, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    
    
    /****************************************************************
* @author: Amit Ojha 
* @date: 09-06-2020
* @param: newOpportunitiesList, oldOpportunitiesMap
* @description: U-1819 This method will update Closed Date and Proposal Submission Date 
When Stage is set to Closed-Withdrawn, Closed- Duplicate and Closed-Lost
*****************************************************************/
    public static void updateCloseDateandProposalSubDate(List<Opportunity> newOpportunitiesList){
        List<Opportunity> toupdateOppoList = new List<Opportunity>();
        try{
           for(opportunity opp : newOpportunitiesList){
                if((opp.StageName == GlobalConstants.oppStageClosedLost || opp.StageName == GlobalConstants.oppStageClosedDuplicate || opp.StageName == GlobalConstants.oppStageClosedWithdrawn) && 
                        (opp.RecordTypeId == GlobalConstants.frameOppRecordTypeId  ||opp.RecordTypeId == GlobalConstants.standardOppRecordTypeId))
                {   
                    if(opp.CloseDate > system.today() && opp.Proposal_Submission_Date__c > system.today() && opp.Proposal_Submission_Date__c != null ){
                        opp.Proposal_Submission_Date__c = system.today();
                        opp.CloseDate = system.today();
                        toupdateOppoList.add(opp);
                    }else if(opp.CloseDate > system.today()){
                        opp.CloseDate = system.today();
                         toupdateOppoList.add(opp);
                    }/*else if(opp.Proposal_Submission_Date__c > system.today() && opp.Proposal_Submission_Date__c != null){
                        opp.Proposal_Submission_Date__c = system.today();
                         toupdateOppoList.add(opp);
                    }else{
                       //system.debug('All dates are correct');
                    }*/
                } 
         } 
            if(!toupdateOppoList.isEmpty()){
            	database.update(toupdateOppoList);
            }
        }
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, GlobalConstants.updateCloseDateandProposalSubDate, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 10-06-2020
* @param: newOpportunitiesList,oldOpportunitiesMap
* @description: U-1825 This method will update the UsedForStageProgression Checkbox (on SDR) to true when Opportunity moved from one stage to other 
*****************************************************************/
    public static void setUsedForStageProgression(List<Opportunity> newOpportunitiesList , Map<ID, Opportunity> oldOpportunitiesMap){
        try{
            List<id> sdrIdList=new List<id>();
            List<Sales_Decision_Record__c> sdrToUpdateList=new List<Sales_Decision_Record__c>();
            
            for(Opportunity opp: newOpportunitiesList){
                if(opp.StageName != oldOpportunitiesMap.get(opp.Id).StageName && opp.LatestApprovedSDR__c!=null){
                    sdrIdList.add(opp.LatestApprovedSDR__c);
                }
            }
            if(!sdrIdList.isEmpty())
            {
                for(Sales_Decision_Record__c sdr:[select id, UsedForStageProgression__c from Sales_Decision_Record__c where id in :sdrIdList
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                      sdr.UsedForStageProgression__c = true;
                                                      sdrToUpdateList.add(sdr);
                                                  }
                if(!sdrToUpdateList.isEmpty()){
                    update sdrToUpdateList;    
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.setUsedForStageProgression, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Shubham Jagatap
* @date: 16-06-2020
* @param: newOpportunitiesList
* @description: U-1859 Set Ship_To_Countries__c field on Opp 
*****************************************************************/
    public static void SetShipToCountries(list<Opportunity> newOpportunitiesList){
        try{
            set<ID> accIDSet = new set<ID>();
            list<Account> acclist = new list<Account>();
            map<ID , Account> accmap = new map<ID , Account>();
            Id simple_OpportunityId = GlobalConstants.simpleOppRecordTypeId;
            Id simple_Opportunity_CreateId = GlobalConstants.simpleCreateOppRecTypeId;
            for(Opportunity opp : newOpportunitiesList){
                if(opp.RecordTypeId != GlobalConstants.simpleOppRecordTypeId && opp.RecordTypeId != GlobalConstants.simpleCreateOppRecTypeId){
                    if(opp.End_Customer__c != Null){
                        accIDSet.add(opp.End_Customer__c); 
                    }
                }
            }
            if(accIDSet.size() > 0){
                for(Account acc :  [ SELECT Id, BillingCountryCode FROM Account WHERE ID IN: accIDSet 
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ]){
                                        accmap.put(acc.Id , acc);
                                    }
            }	
            for(Opportunity op : newOpportunitiesList){
                if(op.RecordTypeId != GlobalConstants.simpleOppRecordTypeId && op.RecordTypeId != GlobalConstants.simpleCreateOppRecTypeId){
                    if(op.End_Customer__c != Null && accmap.get(op.End_Customer__c).BillingCountryCode != null){
                        //U-2274//op.Ship_To_Countries__c = accmap.get(op.End_Customer__c).BillingCountry.substringAfter(GlobalConstants.COMMA);
                        op.Ship_To_Countries__c = accmap.get(op.End_Customer__c).BillingCountryCode;
                    }}
            }  
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityTriggerHelper, 
                                                                       GlobalConstants.SetShipToCountries, GlobalConstants.OpportunityTriggerHelper, true, e)));
        }
    }
    /****************************************************************
* @author: Shubham Jagatap
* @date: 16-06-2020
* @param: newOpportunitiesList,oldOpportunitiesMap
* @description: U-1859 Update Ship_To_Countries__c field on Opp 
*****************************************************************/
    public static void updateShipToCountries(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        Try{
        List<Opportunity> opptyList = new List<Opportunity>();
        for (Opportunity newOppty : newOpportunities) {
            if(newOppty.RecordTypeId != GlobalConstants.simpleOppRecordTypeId && newOppty.RecordTypeId != GlobalConstants.simpleCreateOppRecTypeId){
                //Opportunity oldOppty = oldOpportunitiesMap.get(newOppty.Id);
                if (newOppty.End_Customer__c != null &&
                    newOppty.End_Customer__c != oldOpportunitiesMap.get(newOppty.Id).End_Customer__c) {
                        opptyList.add(newOppty);
                    }}
        }
        if (opptyList.size() > 0) {
            SetShipToCountries(opptyList);
        }
            }catch(Exception e){	}
    } 
}