/****************************************************************
* @author: Ankita Mahobia
* @date: 24-03-2020
* @User Story: 1694
* @description: This class is a helper class for  SecondaryApprovalTrigger

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
Ankita Mahobia			24-03-2020				Initial Version
Shubham Kadam			08-07-2020				U-1889 - setOppDescriptionFromOpportunity, updatePreSalesAdjustmentStatus, 
														 UpdateOpportunitySalesComplianceStatus, UpdateOpportunityTradeComplianceStatus Methods Added												
*****************************************************************/
public without sharing class SecondaryApprovalTriggerHelper {
	/****************************************************************
	* @author: Ankita Mahobia
	* @date: 24-03-2020
	* @param: U-1694
	* @description: This Method will update Main Purpose Risk on Secondary Approval from Purpose Custom Setting depending upon Main Purpose picklist value
	*****************************************************************/   
	public static void calculatePurposeRisk(List<Secondary_Approval__c> newSecondaryApproval, Map<ID, Secondary_Approval__c> oldMap) 
	{
		try {
			for(Secondary_Approval__c mp : newSecondaryApproval)
			{
				if((trigger.isUpdate && oldMap.get(mp.id).MainPurpose__c != mp.MainPurpose__c && mp.MainPurpose__c!=null) || 
                   (trigger.isInsert && mp.MainPurpose__c!=null))
				{
					Integer highestRisk = 0;
					Purpose__c cr = Purpose__c.getValues(mp.MainPurpose__c);
					highestRisk = (cr != null && cr.RiskValue__c != null && integer.valueOf(cr.RiskValue__c) > highestRisk)? integer.valueOf(cr.RiskValue__c) : highestRisk;
					mp.MainPurposeRisk__c = highestRisk;
				}
			}
		}
		catch(Exception e) {
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, GlobalConstants.calculatePurposeRisk, 
                                                                       GlobalConstants.SecondaryApprovalTriggerHelper, true, e))); 
		}
	}
    
    /****************************************************************
	* @author: Shubham Kadam
	* @date: 08-07-2020
	* @param: U-1889
	* @description: This Method will set Opp Description From Opportunity to Secondary Approval
	*****************************************************************/
	public static void setOppDescriptionFromOpportunity(List<Secondary_Approval__c> newSecondaryApproval)
	{
		try {
            set<ID> oppIdSet = new Set<ID>();		
            for(Secondary_Approval__c sa : newSecondaryApproval) {
                oppIdSet.add(sa.Opportunity__c);
			}

            for(Opportunity opp : [select Id, Name, Description FROM Opportunity 
                                   WHERE Id IN :oppIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                for(Secondary_Approval__c sa : newSecondaryApproval) {
                    if(opp.Description != null) {
						sa.Opp_Description__c = opp.Description;
					}
                }
            }
		} catch(Exception e) {
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                    GlobalConstants.setOppDescriptionFromOpportunity, GlobalConstants.SecondaryApprovalTriggerHelper, true, e))); 
		}
	}
    
    /****************************************************************
	* @author: Shubham Kadam
	* @date: 08-07-2020
	* @param: U-1889
	* @description: This Method will update the Pre Sales Adjustment Status based on Approval_Status__c
	*****************************************************************/
	public static void updatePreSalesAdjustmentStatus(List<Secondary_Approval__c> newSecondaryApproval)
	{
		List<PreSalesBudgetRequests__c> updatePreSalesBudgetList = new List<PreSalesBudgetRequests__c>();
		try{
			for(Secondary_Approval__c sa : newSecondaryApproval) {
                
                if(sa.Approval_Status__c != null) {
                    if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Pending) || 
                       sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.APPROVED) || 
                       sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Rejected)) {
                           
                        Secondary_Approval__c salesBudgetList = [select Id, (select id,Status__c from Pre_Sales_Budget_Requests__r) from Secondary_Approval__c 
                                                                 where id =: sa.Id LIMIT 1];
    
                        for(PreSalesBudgetRequests__c ps : salesBudgetList.Pre_Sales_Budget_Requests__r){
                            ps.Status__c = sa.Approval_Status__c;
                            updatePreSalesBudgetList.add(ps);
                        }
                    }
                }
			}
            if(!updatePreSalesBudgetList.isEmpty()) {
				Database.update(updatePreSalesBudgetList, false);
			}
        } 
        catch(Exception e) {
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                    GlobalConstants.updatePreSalesAdjustmentStatus, GlobalConstants.SecondaryApprovalTriggerHelper, true, e))); 
        }    
	}
    
    /****************************************************************
	* @author: Shubham Kadam
	* @date: 08-07-2020
	* @param: newSecondaryApproval
	* @User Story: U-1889
	* @description: This Method will Update Opportunity Sales Compliance Status for Sign-Off Type
	*****************************************************************/
    public static void updateOpportunitySalesComplianceStatus(List<Secondary_Approval__c> newSecondaryApproval)
    {
        List<Opportunity> updateOpportunityList = new List<Opportunity>();
        try {
            for(Secondary_Approval__c sa : newSecondaryApproval) {
                String recordTypeDeveloperName = Schema.SObjectType.Secondary_Approval__c.getRecordTypeInfosById().get(sa.RecordTypeId).getDevelopername();
                
                if(recordTypeDeveloperName.equalsIgnoreCase(GlobalConstants.Sensitive_Business)) {
                    Opportunity opp = [Select Id,Name,Sensitive_Business_Status__c,SBSPilot__c from Opportunity where Id =:sa.Opportunity__c LIMIT 1];
                    
                    if(sa.Approval_Status__c != null && sa.Approval_Rejection_Reason__c != null) {
                        if(!opp.SBSPilot__c && 
                           (sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.APPROVED) &&
                            (sa.Approval_Rejection_Reason__c.equalsIgnoreCase(GlobalConstants.APPROVED) 
                             || sa.Approval_Rejection_Reason__c.equalsIgnoreCase(GlobalConstants.Approvedwithcondition)))) /*|| 
                           sa.Approval_Rejection_Reason__c.equalsIgnoreCase(GlobalConstants.Rejected) || 
                           sa.Approval_Rejection_Reason__c.equalsIgnoreCase(GlobalConstants.DISMISSED))*/ {
                               if(sa.Approval_Rejection_Reason__c == null) {
                                   opp.Sensitive_Business_Status__c = sa.Approval_Status__c;
                                   updateOpportunityList.add(opp);
                               }
                               else {
                                   opp.Sensitive_Business_Status__c = GlobalConstants.APPROVED;
                                   updateOpportunityList.add(opp);
                               }	
                           }
                        /*else if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Pending) && 
                                sa.Approval_Rejection_Reason__c.equalsIgnoreCase(GlobalConstants.Pending)) {      
                                    opp.Sensitive_Business_Status__c = GlobalConstants.PENDINGAPPROVAL;
                                    updateOpportunityList.add(opp);
                                }
                        else if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Pending) && 
                                sa.Approval_Rejection_Reason__c.equalsIgnoreCase(GlobalConstants.In_Progress)) {      
                                    opp.Sensitive_Business_Status__c = GlobalConstants.APPROVALINPROCESS;
                                    updateOpportunityList.add(opp);
                                }*/
                    }    
                    /*else if(sa.Approval_Status__c !=null && sa.Approval_Rejection_Reason__c == null) {
                        if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Pending) && sa.Approval_Rejection_Reason__c == null) {
                               opp.Sensitive_Business_Status__c = GlobalConstants.PENDINGAPPROVAL;
                               updateOpportunityList.add(opp);
                        }
                    }*/
                }
            }
            if(!updateOpportunityList.isEmpty()) {
                Database.update(updateOpportunityList, false);
            }
        } catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                    GlobalConstants.updateOpportunitySalesComplianceStatus, GlobalConstants.SecondaryApprovalTriggerHelper, true, e))); 
        }
    }
    
    /****************************************************************
	* @author: Shubham Kadam
	* @date: 08-07-2020
	* @param: newSecondaryApproval
	* @User Story: U-1889
	* @description: This Method will Update Opportunity Sales Compliance Status for Sign-Off Type
	*****************************************************************/
	public static void updateOpportunityTradeComplianceStatus(List<Secondary_Approval__c> newSecondaryApproval, Map<ID, Secondary_Approval__c> oldMap)
	{
		List<Opportunity> updateOpportunityList = new List<Opportunity>();
		try {
			for(Secondary_Approval__c sa : newSecondaryApproval) {
                if(sa.Sign_Off_Type__c != null) {
                    Opportunity opp = [Select Id,Name,Trade_Compliance_Status__c from Opportunity where Id =:sa.Opportunity__c LIMIT 1];
                    if(sa.Approval_Status__c!=null && sa.Sign_Off_Type__c.equalsIgnoreCase(GlobalConstants.Trade_Compliance) && 
                      (Trigger.isInsert || (Trigger.isUpdate && sa.Approval_Status__c != oldMap.get(sa.Id).Approval_Status__c))) {
                        if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.APPROVED)) {
                            opp.Trade_Compliance_Status__c = GlobalConstants.APPROVED;
                            updateOpportunityList.add(opp);
                        }
                        else if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Pending)) {
                            opp.Trade_Compliance_Status__c = GlobalConstants.PENDINGAPPROVAL;
                            updateOpportunityList.add(opp);
                        }
                        else if(sa.Approval_Status__c.equalsIgnoreCase(GlobalConstants.Rejected)) {
                            opp.Trade_Compliance_Status__c = GlobalConstants.Rejected;
                            updateOpportunityList.add(opp);
                        }
                    }
                }
            }
			if(!updateOpportunityList.isEmpty()) {
				Database.update(updateOpportunityList, false);
			}	
		} catch(Exception e) {
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
			GlobalConstants.UpdateOpportunityTradeComplianceStatus, GlobalConstants.SecondaryApprovalTriggerHelper, true, e))); 
		}	
	}
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 07-12-2020
* @User Story: U-2381
* @description: This method will be called when 'Submit for Sensitive Business Approval' Button is Clicked
*****************************************************************/   
    @AuraEnabled
    public static void sensitiveBusinessApprovalSubmission(String parentId)
    {
        String message = GlobalConstants.BLANK;
        try{
            List<Secondary_Approval__c> saUpdateList = new List<Secondary_Approval__c>();
            
            Secondary_Approval__c sa = [Select Id, Name, Opportunity__c, Approval_Status__c, Approval_Rejection_Reason__c from Secondary_Approval__c 
                                        where Id =: parentId LIMIT 1];
            Opportunity opp = [Select Id, Name, SBSPilot__c, ManualSBStatusRequired__c, SBSAutomationRequired__c from Opportunity 
                               where Id =: sa.Opportunity__c LIMIT 1];        

            if(opp.SBSPilot__c){
                if(opp.ManualSBStatusRequired__c == true && opp.SBSAutomationRequired__c == true) {
                    sa.Approval_Status__c = GlobalConstants.Pending;
                    sa.Approval_Rejection_Reason__c = GlobalConstants.Submittedforsemiautoapproval;
                    saUpdateList.add(sa);   
                }
                else if(opp.ManualSBStatusRequired__c == false && opp.SBSAutomationRequired__c == true) {
                    sa.Approval_Status__c = GlobalConstants.Pending;
                    sa.Approval_Rejection_Reason__c = GlobalConstants.Submittedforautoapproval;
                    saUpdateList.add(sa);  
                }
                else if(opp.ManualSBStatusRequired__c == true && opp.SBSAutomationRequired__c == false) {
                    sa.Approval_Status__c = GlobalConstants.Pending;
                    sa.Approval_Rejection_Reason__c = GlobalConstants.Submittedformanualapproval;
                    saUpdateList.add(sa);    
                }
                else{
                    sa.Approval_Status__c = GlobalConstants.APPROVED;
                    sa.Approval_Rejection_Reason__c = GlobalConstants.APPROVED;
                    saUpdateList.add(sa); 
                }
            }
            else if(!opp.SBSPilot__c){
                sa.Approval_Status__c = GlobalConstants.Pending;
                sa.Approval_Rejection_Reason__c = GlobalConstants.Submittedformanualapproval;
                saUpdateList.add(sa); 
            }
            
            if(!saUpdateList.isEmpty()) {
                database.update(saUpdateList);
            }
        }
        catch(Exception e) {
            EventLog.createLog(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                                  GlobalConstants.sensitiveBusinessApprovalSubmission, GlobalConstants.SecondaryApprovalTriggerHelper, true, e));
        }      
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 07-12-2020
* @User Story: U-2381
* @description: This method will be called whern Approval_Rejection_Reason__c is updated
*****************************************************************/   
    public static void callSBSCalloutOrApprovalProcess(List<Secondary_Approval__c> newSecondaryApproval, Map<ID, Secondary_Approval__c> oldMap)
    {
        try {
            Set<ID> oppIdSet = new Set<ID>();
            
            for(Secondary_Approval__c sa : newSecondaryApproval) {
				oppIdSet.add(sa.Opportunity__c);
            }
            Map<Id,Opportunity> IdWithOppMap = new Map<Id,Opportunity>([Select ID, Name, ManualSBStatusRequired__c, SBSPilot__c from Opportunity where ID IN : oppIdSet
                                                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            
            for(Secondary_Approval__c sa : newSecondaryApproval) {
                if(sa.Approval_Rejection_Reason__c != null && sa.Approval_Rejection_Reason__c != oldMap.get(sa.Id).Approval_Rejection_Reason__c && 
                   (sa.Approval_Rejection_Reason__c == GlobalConstants.Submittedforautoapproval || sa.Approval_Rejection_Reason__c == GlobalConstants.Submittedforsemiautoapproval) &&
                   IdWithOppMap.get(sa.Opportunity__c).SBSPilot__c == true)
                {
                    OpportunityTriggerHepler2.makeCallouttoExternal1(sa.Opportunity__c);
                }
                else if(sa.Approval_Rejection_Reason__c != null && sa.Approval_Rejection_Reason__c != oldMap.get(sa.Id).Approval_Rejection_Reason__c && 
                        sa.Approval_Rejection_Reason__c == GlobalConstants.Submittedformanualapproval) {
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments(GlobalConstants.Submitting_request_for_approval);
                    req1.setObjectId(sa.Id);
                    Approval.process(req1);
                }
            }
        }
        catch(Exception e) {
            EventLog.createLog(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                                  GlobalConstants.callSBSCalloutOrApprovalProcess, GlobalConstants.SecondaryApprovalTriggerHelper, true, e));
        }
    }
    
   
    /****************************************************************
* @author: Shubham Jagatap
* @date: 11-12-2020
* @User Story: U-2390
* @description: before insert
*****************************************************************/  
    public static void restrictCreationOfSecondaryApproval(List<Secondary_Approval__c> newSecondaryApproval)
    {
        try{
            
            Set<Id> oppIdSet = new Set<Id>();
            Map<Id,List<Secondary_Approval__c>> mapOppIDwithSAlist = new Map<Id,List<Secondary_Approval__c>>();
            List<Id> rejectOppList = new List<Id>();
            for(Secondary_Approval__c SA : newSecondaryApproval)
            {//check
                if(SA.RecordTypeId == GlobalConstants.sensitiveBusinessRecordTypeId){
                    oppIdSet.add(SA.Opportunity__c);   
                }
            }
            Map<Id,Opportunity> mapOppIDwithOpp = new Map<Id,Opportunity>([SELECT id,SBSPilot__c from Opportunity where id in : oppIdSet]);
            for(Opportunity opp : [Select Id,SBSPilot__c,
                                   (select Id, isActive__c,RecordTypeId from Secondary_Approval__r 
                                    where isActive__c=true) 
                                   from Opportunity where Id IN: oppIdSet and SBSPilot__c=true
                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                if(opp.Secondary_Approval__r.size() > 0){
                    mapOppIDwithSAlist.put(opp.id, opp.Secondary_Approval__r); 
                }
                    
            }
            for(Secondary_Approval__c SA :newSecondaryApproval)
            {//check
                if(mapOppIDwithSAlist.containsKey(SA.Opportunity__c)){
                    SA.addError( GlobalConstants.activeSecondaryApprovalerrorMessage );
                }
                else if(mapOppIDwithOpp.containsKey(SA.Opportunity__c) && mapOppIDwithOpp.get(SA.Opportunity__c).SBSPilot__c==true){
                    
                        SA.isActive__c = true;
                }
            } 
        } 
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                                  GlobalConstants.restrictCreationOfSecondaryApproval, GlobalConstants.SecondaryApprovalTriggerHelper, true, e));
        }
    }
     /****************************************************************
* @author: Shubham Jagatap
* @date: 11-12-2020
* @User Story: U-2390
* @description: after insert
*****************************************************************/  
    public static void updateActiveSensitiveBusinessApprovalOnOpp(List<Secondary_Approval__c> newSecondaryApproval)
    {
        try{
            Map<Id,Secondary_Approval__c> mapSAIDwithSA = new Map<Id,Secondary_Approval__c>(newSecondaryApproval);
            List<Opportunity> oppList = new List<Opportunity>();
            for(Secondary_Approval__c SA : [Select Id,Opportunity__c,RecordTypeId, Opportunity__r.ActiveSensitiveBusinessApproval__c,Opportunity__r.SBSPilot__c from Secondary_Approval__c 
                                            where Id in: mapSAIDwithSA.keySet() Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                if(SA.RecordTypeId == GlobalConstants.sensitiveBusinessRecordTypeId && SA.Opportunity__r.SBSPilot__c){
                    SA.Opportunity__r.ActiveSensitiveBusinessApproval__c = SA.Id;
                    oppList.add(SA.Opportunity__r);
                }             
            }
            if(!oppList.isEmpty()){
                update oppList;
            }
        } 
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                                  GlobalConstants.updateActiveSensitiveBusinessApprovalOnOpp, GlobalConstants.SecondaryApprovalTriggerHelper, true, e));
        }
    }
        /****************************************************************
* @author: Shubham Jagatap
* @date: 11-12-2020
* @User Story: U-2390
* @description: before update 
*****************************************************************/  
   public static void updateisActiveFlag(List<Secondary_Approval__c> newSecondaryApproval,Map<ID, Secondary_Approval__c> oldMap,Map<ID, Secondary_Approval__c> newMap)
    {
        try{
            Set<id> oppIdSet = new Set<id>();
            for(Secondary_Approval__c SA : newSecondaryApproval)
            {
                if(SA.RecordTypeId == GlobalConstants.sensitiveBusinessRecordTypeId){
                    oppIdSet.add(SA.Opportunity__c);   
                }
            }
            Map<Id,Opportunity> mapOppIDwithOpp = new Map<Id,Opportunity>([SELECT id,SBSPilot__c from Opportunity where id in : oppIdSet]);
            for(Secondary_Approval__c SA : newSecondaryApproval)
            {
                if(SA.RecordTypeId == GlobalConstants.sensitiveBusinessRecordTypeId && SA.Approval_Status__c != oldMap.get(SA.Id).Approval_Status__c 
                   && mapOppIDwithOpp.containsKey(SA.Opportunity__c) && mapOppIDwithOpp.get(SA.Opportunity__c).SBSPilot__c 
                   && SA.Approval_Status__c == GlobalConstants.COMPLETED && SA.isActive__c==true){
                       SA.isActive__c = false;
                }
            }
            
        } 
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                                  GlobalConstants.updateisActiveFlag, GlobalConstants.SecondaryApprovalTriggerHelper, true, e));
        }
    }
     /****************************************************************
* @author: Shubham Jagatap
* @date: 11-12-2020
* @User Story: U-2390
* @description: After update 
*****************************************************************/  
   public static void clearActiveSensitiveBusinessApprovalOnOpp(List<Secondary_Approval__c> newSecondaryApproval,Map<ID, Secondary_Approval__c> oldMap,Map<ID, Secondary_Approval__c> newMap)
   {
       try{List<Opportunity> oppList = new List<Opportunity>();
           Set<id> oppIdSet = new Set<id>();
           for(Secondary_Approval__c SA : newSecondaryApproval)
           {
               if(SA.RecordTypeId == GlobalConstants.sensitiveBusinessRecordTypeId){
                   oppIdSet.add(SA.Opportunity__c);   
               }
           }
           Map<Id,Opportunity> mapOppIDwithOpp = new Map<Id,Opportunity>([SELECT id,SBSPilot__c,ActiveSensitiveBusinessApproval__c from Opportunity where id in : oppIdSet]);
           for(Secondary_Approval__c SA : newSecondaryApproval)
           {
               if(SA.RecordTypeId == GlobalConstants.sensitiveBusinessRecordTypeId && SA.Approval_Status__c != oldMap.get(SA.Id).Approval_Status__c 
                  && mapOppIDwithOpp.containsKey(SA.Opportunity__c) && mapOppIDwithOpp.get(SA.Opportunity__c).SBSPilot__c 
                  && SA.Approval_Status__c == GlobalConstants.COMPLETED && SA.isActive__c == false){
                      Opportunity opp = mapOppIDwithOpp.get(SA.Opportunity__c);
                      opp.ActiveSensitiveBusinessApproval__c = null;
                      opp.Sensitive_Business_Status__c = GlobalConstants.APPROVED;
                      oppList.add(opp);
                  }
           }
           
           if(!oppList.isEmpty()){
               update oppList;
           }
          } 
       catch(Exception e){
           EventLog.createLog(new EventLog.Error(GlobalConstants.SecondaryApprovalTriggerHelper, 
                                                  GlobalConstants.clearActiveSensitiveBusinessApprovalOnOpp, GlobalConstants.SecondaryApprovalTriggerHelper, true, e));
       }
   }
}