/******************************************************************* 
* @author: Satya Pagadala
* @date: 2019-02-14  
* @description: This class is a helper class for Opportunity Deal Value Handler
* and this class is calling from OpportunityTriggerHandler 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

********************************************************************/
public without sharing class OpportunityChildSumDeaValuePercentHelper{
   
    /****************************************************************
    * @author: Satya Pagadala
    * @date: 2019-02-14
    * @param: newOpportunities - List of Opportunities    
    * @description: This method calling to update Sum of Deal values on Frame itself when Frame opp updated
    *****************************************************************/
    
    /****************************************************************
    * @author: Paresh Saxena
    * @date: 2020-02-13
    * @param: newOpportunities - List of Opportunities    
    * @description: This method is modified to use Parent Original Opportunity for all types of opp(U-0944).
    *****************************************************************/
    public static Map<Id, List<Opportunity>> sumChildOppsDealValueOnFrame(List<Opportunity> newOpportunities){        
        Set<Id> setParentOpportunityIds = new Set<Id>();
        //Get all Opportunity RecordtypeIds from Custom labels
        //U-1903
        Id simpleOppRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        Id simpleOppCreateRecordTypeId = GlobalConstants.simpleCreateOppRecTypeId;
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        Id standardOppCreateRecordTypeId = GlobalConstants.standardCreateOppRecordTypeId;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Id frameOppCreateRecordTypeId = GlobalConstants.frameCreateOppRecordTypeId;
        
        //Get Opportunity Stages from Custom labels
        //U-1903
        String oppStageNegotiateAndClose = GlobalConstants.Negotiate_and_Close;
        String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
        String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
        String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
        String oppStageClosedDuplicate = GlobalConstants.oppStageClosedDuplicate;
        Map<Id, List<Opportunity>> mapChildOppsWithFrameOppId = new Map<Id, List<Opportunity>>();
        
        try{
        //Get set of Frame Opportunity Ids from its child opportunities
        for(Opportunity opp : newOpportunities){
            //Get Frame opportunity id
            if((opp.RecordTypeId == frameOppRecordTypeId || opp.RecordTypeId == frameOppCreateRecordTypeId) && opp.Id != null){
                setParentOpportunityIds.add(opp.Id);                
            }
        }
        
        List<Opportunity> childOppsList = new List<Opportunity>();
        //List<Opportunity> frameOppsList = new List<Opportunity>();
        
        if(setParentOpportunityIds.size()>0){
            //Get list of all Child Opportunities from each given Frame
            //childOppsList = [Select Id, Name, StageName, Deal_Value__c, Deal_Value_SEK_Converted__c, Anticipated_Deal_Value__c, Anticipated_Deal_Value_SEK_Converted__c, RecordTypeId, RecordType.Name, Parent_Frame_Opportunity__c, Parent_Original_Opportunity__c from Opportunity where (Parent_Original_Opportunity__c in :setParentOpportunityIds or Parent_Frame_Opportunity__c in :setParentOpportunityIds)];   
            //U-0944
            childOppsList = [Select Id, Name, StageName, Deal_Value__c, Deal_Value_SEK_Converted__c, Anticipated_Deal_Value__c, Anticipated_Deal_Value_SEK_Converted__c, RecordTypeId, RecordType.Name, Parent_Original_Opportunity__c from Opportunity where (Parent_Original_Opportunity__c in :setParentOpportunityIds) Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];                          
        }       
        //Create a Map with Frame opportunity and its relative child opportunities for particular Stages
        if(childOppsList.size()>0){
            for(Opportunity opp :childOppsList){
                //U-1903
                if(((opp.RecordtypeId == simpleOppRecordTypeId || opp.RecordTypeId == simpleOppCreateRecordTypeId)
                   && (opp.StageName == oppStageNegotiateAndClose || opp.StageName == oppStageClosedWon)) || 
                   ((opp.RecordtypeId == standardOppRecordTypeId || opp.RecordTypeId == standardOppCreateRecordTypeId) 
                   && (opp.StageName != oppStageClosedLost && opp.StageName != oppStageClosedWithdrawn && opp.StageName != oppStageClosedDuplicate)) ){
                    
                    if(mapChildOppsWithFrameOppId.containskey(opp.Parent_Original_Opportunity__c)){
                        mapChildOppsWithFrameOppId.get(opp.Parent_Original_Opportunity__c).add(opp);                   
                    }
                    else{
                        mapChildOppsWithFrameOppId.put(opp.Parent_Original_Opportunity__c, new List<Opportunity>{opp});
                    }                    
                }
           /**    if((opp.RecordtypeId == standardOppRecordTypeId || opp.RecordtypeId == standardOppPDRecordTypeId || opp.RecordTypeId == standardOppCreateRecordTypeId) && (opp.StageName != oppStageClosedLost && opp.StageName != oppStageClosedWithdrawn && opp.StageName != oppStageClosedDuplicate)){
                    if(mapChildOppsWithFrameOppId.containskey(opp.Parent_Frame_Opportunity__c)){
                       mapChildOppsWithFrameOppId.get(opp.Parent_Frame_Opportunity__c).add(opp);  
					 }
                    else{
                       mapChildOppsWithFrameOppId.put(opp.Parent_Frame_Opportunity__c, new List<Opportunity>{opp});
                      }                   
                }**/
            }
        }
        return mapChildOppsWithFrameOppId;     
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityChildSumDeaValuePercentHelper, 
                                                                       GlobalConstants.sumChildOppsDealValueOnFrame, GlobalConstants.OpportunityChildSumDeaValuePercentHelper, true, e)));
        	return mapChildOppsWithFrameOppId;  
        }
    }
        /****************************************************************
* @author: Manu Singhal
* @date: 13-05-2019
* @param: newOpportunities ,oldOpportunities
* @description: This method will update MA Head and BA Heads
*****************************************************************/
public static void updateMAHeadandBAHeads(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap ){
    //U-1903
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        //Id standardOppPDRecordTypeId = System.Label.Record_Type_ID_Standard_Opportunity_PD;
        Id standardOppCreateRecordTypeId = GlobalConstants.standardCreateOppRecordTypeId;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        //Id frameOppPDRecordTypeId = System.Label.Record_Type_ID_Frame_Amendment_Opportunity_PD;
        Id frameOppCreateRecordTypeId = GlobalConstants.frameCreateOppRecordTypeId;
        List<Opportunity> newOpportunitiesList =  new List<Opportunity>();
        Set<id> createdByIdSet =  new Set<id>();
        Map<id,id> userWithMAHeadMap = new Map<id,id>();
        try{ 
            for(Opportunity opp: newOpportunities)
            {
                if((opp.recordTypeId == frameOppRecordTypeId || opp.recordTypeId == frameOppCreateRecordTypeId|| opp.recordTypeId == standardOppRecordTypeId || opp.recordTypeId == standardOppCreateRecordTypeId) &&  opp.High_Impact_Deal__c && (oldOpportunitiesMap.isEmpty() || (!oldOpportunitiesMap.isEmpty() && oldOpportunitiesMap.get(opp.id).High_Impact_Deal__c != opp.High_Impact_Deal__c)))
                {
                    newOpportunitiesList.add(opp);
                    if(oldOpportunitiesMap.isEmpty()) {
                        createdByIdSet.add(UserInfo.getUserId());
                    }else {
                        createdByIdSet.add(opp.CreatedById);
                    }
                }
            }
            if(!newOpportunitiesList.isEmpty())
            {
                if(!createdByIdSet.isEmpty())
                {
                    for(User user:[SELECT Id,MA_Head__c
                                   FROM User where Id in: createdByIdSet
                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                    {
                        userWithMAHeadMap.put(user.Id,user.MA_Head__c);  
                    }
                }
                for(Opportunity opp:newOpportunitiesList){
                    if(oldOpportunitiesMap.isEmpty() && userWithMAHeadMap.get(UserInfo.getUserId()) != null)
                        opp.MA_Head__c = userWithMAHeadMap.get(UserInfo.getUserId());
                    else if(userWithMAHeadMap.get(opp.CreatedById) != null)
                        opp.MA_Head__c = userWithMAHeadMap.get(UserInfo.getUserId());
                }        
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityChildSumDeaValuePercentHelper, 
                                                                       GlobalConstants.updateMAHeadandBAHeads, GlobalConstants.OpportunityChildSumDeaValuePercentHelper, true, e)));
        }
    }
    /****************************************************************
    * @author: Anukriti 
    * @date: 17-05-2019
    * @param: newOpportunities ,oldOpportunities
    * @description: This method update close date as today of simples
*****************************************************************/
    public static void updateCloseDateofSimple(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        try{
            for(Opportunity op : newOpportunities) {
                if(op.StageName == GlobalConstants.ClosedLost || op.StageName == GlobalConstants.ClosedDuplicate 
                   || op.StageName == GlobalConstants.ClosedWithdraw || op.StageName == GlobalConstants.ClosedWon) {
                       if(op.StageName != oldOpportunitiesMap.get(op.Id).StageName && (op.recordTypeId == GlobalConstants.simpleOppRecordTypeId || op.recordTypeId == GlobalConstants.simpleCreateOppRecTypeId)) {
                           op.CloseDate = System.today();
                       }
                  }
            }   
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityChildSumDeaValuePercentHelper, 
               GlobalConstants.updateCloseDateofSimple, GlobalConstants.OpportunityChildSumDeaValuePercentHelper, true, e)));
        }
        
    }
/*******************************************************************
* @author: Aditya
* @date: 2019-12-06
* @description: U-0985
1. Update KAM/VP Sales and Actuals Field based on Primary KAM from Account's CRG
*******************************************************************************************/
    public static void populateSalesOBTargetsandActualsOnNewOpp(List<Opportunity> newOppsList){
        Set<VP_Sales_KAM_OB_Target__c> KAMVPIdSet = new Set<VP_Sales_KAM_OB_Target__c>();
        Map<Id,Id> accId_And_Account_Primary_KAMMap = new Map<Id,Id> ();
        Map<Id,Id> opptyWithAccountMap = new Map<Id,Id> ();
        Map<Id,List<VP_Sales_KAM_OB_Target__c>> kamWithVppMap = new Map<Id,List<VP_Sales_KAM_OB_Target__c>>();
        try{
            for(Opportunity opp: newOppsList) {
                opptyWithAccountMap.put(opp.id,opp.AccountId);
            }
            for(Account acc : [select id, Account.CustomerReportingGroup__r.Account_Primary_KAM__c,Account.CustomerReportingGroup__r.CustomerUnit__r.Name 
                               from Account where id in:opptyWithAccountMap.values()  
                               Limit : (Limits.getLimitQueryRows())])
            {
                accId_And_Account_Primary_KAMMap.put(acc.Id,acc.CustomerReportingGroup__r.Account_Primary_KAM__c); //AccId and KAM Map   
            }
            for(VP_Sales_KAM_OB_Target__c vpp : [Select id,Name,Customer_Unit__c,OwnerId,CU_Value__c,CreatedById
                                                 from VP_Sales_KAM_OB_Target__c  where OwnerId in :accId_And_Account_Primary_KAMMap.values() 
                                                 Order by CreatedDate DESC
                                                 Limit : (Limits.getLimitQueryRows())]){
                    if(kamWithVppMap.containskey(vpp.OwnerId)){
                        kamWithVppMap.get(vpp.OwnerId).add(vpp);                   
                    }
                    else{
                        kamWithVppMap.put(vpp.OwnerId, new List<VP_Sales_KAM_OB_Target__c>{vpp});
                    }    
                } 
                for(Opportunity opp :newOppsList){
                    //U-1903
               // opp.Trade_Compliance_Status__c = GlobalConstants.Not_Required;
                //opp.Sensitive_Business_Status__c= GlobalConstants.Not_Required;
                    if(!kamWithVppMap.isEmpty() && !accId_And_Account_Primary_KAMMap.isEmpty() && !kamWithVppMap.isEmpty()){
                        for(VP_Sales_KAM_OB_Target__c v :kamWithVppMap.get(accId_And_Account_Primary_KAMMap.get(opptyWithAccountMap.get(opp.id))))
                        {
                            if(opp.Customer_Unit__c == v.CU_Value__c){
                                opp.KAM_VP_Sales_OB_Targets_and_Actuals__c = v.id;                
                                break;
                            }     
                        }
                    }
                }
            }catch(Exception e) {
                EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityChildSumDeaValuePercentHelper, 
                                                                           GlobalConstants.populateSalesOBTargetsandActualsOnNewOpp, GlobalConstants.OpportunityChildSumDeaValuePercentHelper, true, e)));
            }
        }
}