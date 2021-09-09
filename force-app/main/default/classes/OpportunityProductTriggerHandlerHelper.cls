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

******************************************************************************************/
public class OpportunityProductTriggerHandlerHelper{

	public static void validateOnDelete(List<OpportunityLineItem> deletedOppProducts){
        Try{
		Id profileId = UserInfo.getProfileId();
		String profileName = [SELECT Name FROM Profile WHERE Id =: profileId
                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].Name;
		for(OpportunityLineItem oli: deletedOppProducts){
            //U-1991
			if(!AccessSettings__c.getInstance().CanDeleteOpportunityProduct__c)
            {if(!oli.Bypass_Deletion_Validation__c && oli.Opportunity_Locked_To_PP__c)oli.addError(GlobalConstants.Opportunity_Product_Delete_Validation_Error);
			}
		}
            }catch(Exception e){	}
	}

	public static void calculateLeadDomain(List<OpportunityLineItem> newOppProducts){
		try{
			Set<Id> oppIdSet = new Set<Id>();
			for(OpportunityLineItem oli: newOppProducts){
				oppIdSet.add(oli.OpportunityId);
			}

			System.debug('oppIdSet '+oppIdSet);
            if(!oppIdSet.isEmpty()){
                List<Opportunity> oppWithProductsList = [SELECT Id, Lead_Domain__c, 
														(Select Id, Business_Area__c, UnitPrice From OpportunityLineItems)
													FROM Opportunity
													WHERE Id IN:oppIdSet
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];

			for(Opportunity opp: oppWithProductsList){
				if(String.isBlank(opp.Lead_Domain__c)){
					opp.Lead_Domain__c = getLeadingDomain(opp.OpportunityLineItems);
					System.debug('test1');
				}
			}

			update oppWithProductsList;
            }
		}catch(Exception e){
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.calculateLeadDomain, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e)));
            System.debug(LoggingLevel.ERROR, GlobalConstants.OpportunityProductTriggerHandlerHelper_Get_error + e.getMessage());
		}
	}

	private static String getLeadingDomain(List<OpportunityLineItem> oppLinesList){
		String result = '';
		try{	
			Map<String, Integer> baPriorityMap = GlobalConstants.baPriorityMap;
			OpportunityLineItem leadingOli;
			for(OpportunityLineItem oli: oppLinesList){
				if(leadingOli == null && oli.UnitPrice != null)leadingOli = oli;
				if(oli.UnitPrice != null && oli.UnitPrice > leadingOli.UnitPrice){leadingOli = oli;}else if(oli.UnitPrice == leadingOli.UnitPrice){
					if(baPriorityMap.get(oli.Business_Area__c) != null && baPriorityMap.get(leadingOli.Business_Area__c) != null && baPriorityMap.get(oli.Business_Area__c) < baPriorityMap.get(leadingOli.Business_Area__c)){
						leadingOli = oli;
					}else if(baPriorityMap.get(oli.Business_Area__c) != null && baPriorityMap.get(leadingOli.Business_Area__c) == null){
						leadingOli = oli;
					}
				}
			}

			if(leadingOli != null)result = leadingOli.Business_Area__c;
		}catch(Exception e){
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.getLeadingDomain, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e)));
            System.debug(LoggingLevel.ERROR, GlobalConstants.OpportunityProductTriggerHandlerHelper_Get_error + e.getMessage());
		}
		System.debug('result '+result);
		return result;
	}
	
    public static void triggerOpportunitiesUpdate(List<OpportunityLineItem> newOpportunityLineItemList){
        Set<Id> oppIdSet = new Set<Id>();
        string ProductArea;
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        
        for(OpportunityLineItem oli: newOpportunityLineItemList){
            oppIdSet.add(oli.OpportunityId);
            ProductArea=oli.Product_Area__c;
        }
        //update this method based on U-2247. 
        for(opportunity opp:[SELECT Id,ProductArea__c, (Select Id,Product_Area__c From OpportunityLineItems)
                             FROM Opportunity
                             WHERE Id IN:oppIdSet
                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                 
                                 set<string> oppProductAreaset=new set<string>();                                          
                                 for(OpportunityLineItem oli: opp.OpportunityLineItems){
                                     if(oli.Product_Area__c!=null){
                                         oppProductAreaset.add(oli.Product_Area__c); 
                                     }
                                 }
                                 String oppProductArea = '';
                                 for(String s:oppProductAreaset) {
                                     oppProductArea += (oppProductArea==''?'':',')+s;
                                 } 
                                 if(ProductArea!=null && String.isNotBlank(ProductArea)){
                                     oppToUpdateList.add(new Opportunity(Id = opp.id,ProductArea__c=oppProductArea));
                                 }else{
                                     oppToUpdateList.add(new Opportunity(Id = opp.id));
                                 }    
                                 
                             }
        try{
            update oppToUpdateList;
        }catch (Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesUpdate, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e));
            System.debug(LoggingLevel.ERROR, GlobalConstants.OpportunityProductTriggerHandlerHelper_Get_error + e.getMessage());
        }
    
    }
    public static void RestrictDuplicateOppProduct(List<OpportunityLineItem> newOpportunityLineItemList) {
        Map<Id,List<Id>> mapProduct = new Map<Id,List<Id>>();
        Set<Id> setOppIds = new Set<Id>();
        try{
        for(OpportunityLineItem oli: newOpportunityLineItemList){
            setOppIds.add(oli.OpportunityId);
        }
        for(OpportunityLineItem oli: [Select Id, Product2Id, OpportunityId from OpportunityLineItem where OpportunityId IN:setOppIds Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            if(mapProduct.containsKey(oli.OpportunityId))
                mapProduct.get(oli.OpportunityId).add(oli.Product2Id);
            else
                mapProduct.put(oli.OpportunityId,new List<Id>{oli.Product2Id});
        }
        String errortext = GlobalConstants.DuplicateOpportunityProduct;
        for(OpportunityLineItem oli: newOpportunityLineItemList){           
            if(mapProduct.containsKey(oli.OpportunityId)){
                for(Id prodId: mapProduct.get(oli.OpportunityId)){
                    if(oli.Product2Id.equals(prodId))
                        oli.addError(errortext);
                }
            }
        }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.RestrictDuplicateOppProduct, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e)));
        }
    }
    
    /****************************************************************
* @author: Ankit Jain
* @date: 15-04-2020
* @param: newOpportunityLineItemList
* @description: This method will update Opportunity Approved_SDP_Stage__c after Oppty line Item insert.(U-1737) && D-2731
*****************************************************************/
    public static void triggerOpportunitiesApprovedSdpStageInsert(List<OpportunityLineItem> newOpportunityLineItemList){
        Set<Id> oppIdSet = new Set<Id>();
        List<Sales_Decision_Record__c> sdrListToRecall;
        for(OpportunityLineItem oli: newOpportunityLineItemList){
            oppIdSet.add(oli.OpportunityId);
        }
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        if(!oppIdSet.isEmpty())
        {
            for(Opportunity opp:[Select id,Approved_SDP_Stage__c,Not_Deviating_from_Parent__c,Opportunity_Tier__c,MarketArea__c,RecordTypeId,StageName from Opportunity where id in :oppIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                oppToUpdateList.add(SalesDecisionRecordUtility.MarkOppoyApprovedSDPStageToObsolete(opp));
            }
            try{
                update oppToUpdateList;
                
                sdrListToRecall =[SELECT Id, Opportunity__c,Sales_Decision_Approval_Status__c
                                  FROM Sales_Decision_Record__c 
                                  WHERE opportunity__c IN :oppIdSet AND Sales_Decision_Approval_Status__c = :GlobalConstants.APPROVALSONGOING
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];                       
                if(!sdrListToRecall.isEmpty())
                    SalesDecisionRecordUtility.resetSDMs(sdrListToRecall);            
            }catch (Exception e){EventLog.createLog(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesApprovedSdpStageInsert, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e));
                                }
        }
    }
    
    /****************************************************************
* @author: Ankit Jain
* @date: 15-04-2020
* @param: newOpportunityLineItemList,oldOppProductMap
* @description: This method will update Opportunity Approved_SDP_Stage__c after Oppty line Item update.(U-1737) && D-2731
*****************************************************************/
    public static void triggerOpportunitiesApprovedSdpStageUpdate(List<OpportunityLineItem> newOpportunityLineItemList,Map<ID, OpportunityLineItem> oldOppProductMap){
        Set<Id> oppIdSet = new Set<Id>();
        List<Sales_Decision_Record__c> sdrListToRecall;
        for(OpportunityLineItem oli: newOpportunityLineItemList){
            OpportunityLineItem oldOli = oldOppProductMap.get(oli.Id);
            if((oli.Estimated_Margin__c != oldOli.Estimated_Margin__c)||(oli.UnitPrice!=oldOli.UnitPrice)){
                oppIdSet.add(oli.OpportunityId);        
            }   
        }
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        if(!oppIdSet.isEmpty()){
            for(Opportunity opp:[Select id,Approved_SDP_Stage__c,Not_Deviating_from_Parent__c,Opportunity_Tier__c,MarketArea__c,RecordTypeId,StageName from Opportunity where id in :oppIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            oppToUpdateList.add(SalesDecisionRecordUtility.MarkOppoyApprovedSDPStageToObsolete(opp));}
        try{
            update oppToUpdateList;
            //D-2729
            //if(!oppIdSet.isEmpty())
            //{
                sdrListToRecall =[SELECT Id, Opportunity__c,Sales_Decision_Approval_Status__c
                                  FROM Sales_Decision_Record__c 
                                  WHERE opportunity__c IN :oppIdSet AND Sales_Decision_Approval_Status__c = :GlobalConstants.APPROVALSONGOING
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];                        
            if(!sdrListToRecall.isEmpty())
                SalesDecisionRecordUtility.resetSDMs(sdrListToRecall);
        }catch (Exception e){EventLog.createLog(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesApprovedSdpStageUpdate, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e));
                        }
        }
}

/****************************************************************
* @author: Ankit Jain
* @date: 15-04-2020
* @param: oldOpportunityLineItemList
* @description: This method will update Opportunity Approved_SDP_Stage__c after Oppty line Item delete.(U-1737 & U-1733)
*****************************************************************/
public static void triggerOpportunitiesApprovedSdpStageDelete(List<OpportunityLineItem> oldOpportunityLineItemList){
    Set<Id> oppIdSet = new Set<Id>();
    List<Sales_Decision_Record__c> sdrListToRecall;
    for(OpportunityLineItem oli: oldOpportunityLineItemList){
        oppIdSet.add(oli.OpportunityId);
    }
    List<Opportunity> oppToUpdateList = new List<Opportunity>();
    if(!oppIdSet.isEmpty())
    {
        for(Opportunity opp:[Select id,Approved_SDP_Stage__c,Not_Deviating_from_Parent__c,Opportunity_Tier__c,MarketArea__c,RecordTypeId,StageName from Opportunity where id in :oppIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            oppToUpdateList.add(SalesDecisionRecordUtility.MarkOppoyApprovedSDPStageToObsolete(opp)); }
        try{
            update oppToUpdateList;
            //D-2729
            
            sdrListToRecall =[SELECT Id, Opportunity__c,Sales_Decision_Approval_Status__c
                              FROM Sales_Decision_Record__c 
                              WHERE opportunity__c IN :oppIdSet AND Sales_Decision_Approval_Status__c = :GlobalConstants.APPROVALSONGOING
                              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]; 
            
            if(!sdrListToRecall.isEmpty())
                SalesDecisionRecordUtility.resetSDMs(sdrListToRecall);
        }catch (Exception e){EventLog.createLog(new EventLog.Error(GlobalConstants.OpportunityProductTriggerHandlerHelper, GlobalConstants.triggerOpportunitiesApprovedSdpStageDelete, GlobalConstants.OpportunityProductTriggerHandlerHelper, true, e));
                            }
    }
}
}