/****************************************************************
 * @author: Pallavi Patil
 * @date: 1/8/2020
 * @User Story: U-1321
 * @description: This will update parent opp on extention early start
 *****************************************************************/
public class EarlyStartHelper {
	/****************************************************************
	 * @author: Pallavi Patil
	 * @date: 1/8/2020
	 * @param:
	 * @description: This will update parent opp on extention early start on creation
	 *****************************************************************/
	public static void updateParentOppOnCreation(
		List<EarlyStart__c> newEarlystart
	) {
		Map<id, id> esWithOppMap = new Map<id, id>();
		Map<EarlyStart__c, id> esWithParentESMap = new Map<EarlyStart__c, id>();
		try {
			for (EarlyStart__c es : newEarlystart) {
				if (es.RecordTypeId == GlobalConstants.extensionRecordTypeId) {
					esWithParentESMap.put(es, es.Parent_Early_Start__c);
				}
			}
			if (!esWithParentESMap.isEmpty()) {
				for (EarlyStart__c es : [
					SELECT id, Opportunity__c
					FROM EarlyStart__c
					WHERE id IN :esWithParentESMap.values()
					LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
				]) {
					esWithOppMap.put(es.id, es.Opportunity__c);
				}
			}
			if (!esWithOppMap.isEmpty()) {
				for (EarlyStart__c es : newEarlystart) {
					es.Opportunity__c = esWithOppMap.get(esWithParentESMap.get(es));
				}
			}
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.EarlyStartHelper,
						GlobalConstants.updateParentOppOnCreation,
						GlobalConstants.EarlyStartHelper,
						true,
						e
					)
				)
			);
		}
	}
	/****************************************************************
	 * @author: Pallavi Patil
	 * @date: 1/8/2020
	 * @param:
	 * @description:Update Parent opp on early start
	 *****************************************************************/
	public static void updateParentOpp(
		Map<id, EarlyStart__c> newEarlystartMap,
		Map<id, EarlyStart__c> oldEarlystartMap
	) {
		Map<id, id> esWithOppMap = new Map<id, id>();
		List<EarlyStart__c> updateList = new List<EarlyStart__c>();
		try {
			for (EarlyStart__c es : newEarlystartMap.values()) {
				if (
					es.RecordTypeId == GlobalConstants.newearlyStartRecordTypeId &&
					es.Opportunity__c != oldEarlystartMap.get(es.id).Opportunity__c
				) {
					esWithOppMap.put(es.id, es.Opportunity__c);
				}
			}
			if (!esWithOppMap.isEmpty()) {
				for (EarlyStart__c es : [
					SELECT id, Parent_Early_Start__c, Opportunity__c
					FROM EarlyStart__c
					WHERE Parent_Early_Start__c IN :esWithOppMap.keySet()
					LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
				]) {
					es.Opportunity__c = esWithOppMap.get(es.Parent_Early_Start__c);
					updateList.add(es);
				}
			}
			if (!updateList.isEmpty()) {
				update updateList;
			}
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.EarlyStartHelper,
						GlobalConstants.updateParentOpp,
						GlobalConstants.EarlyStartHelper,
						true,
						e
					)
				)
			);
		}
	}

    /****************************************************************
* @author: Aditya Mohapatra 
* @date: 12-07-2020
* @param: Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap
* @description: Update Currency on Early Start when Parent Early Start Currency is different	
*****************************************************************/
    public static void updateCurrencyFromES(List<EarlyStart__c> newEarlystart){
        try{
            List<EarlyStart__c> updateList = new List<EarlyStart__c>();
            Map<id,EarlyStart__c> parentIDWithESMap = new Map<id,EarlyStart__c>();
            for(EarlyStart__c es : newEarlystart){
                if(es.RecordTypeName__c == 'Extension' && es.Parent_Early_Start__c != null )
                {		parentIDWithESMap.put(es.Parent_Early_Start__c,es);
                }}
            if(!parentIDWithESMap.isEmpty()){
                for (EarlyStart__c es : [Select id,CurrencyIsoCode from EarlyStart__c where id in :parentIDWithESMap.keyset()
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())] 
                    ){
                        if(es.CurrencyIsoCode != parentIDWithESMap.get(es.Id).CurrencyIsoCode ){
                            parentIDWithESMap.get(es.Id).CurrencyIsoCode = es.CurrencyIsoCode ;
                        }
                    }}
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, GlobalConstants.updateParentOpp, GlobalConstants.EarlyStartHelper, true, e)));}   
        
    }
	 /****************************************************************
* @author: Aditya Mohapatra 
* @date: 14-07-2020
* @param: Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap
* @description: Update ACR,CSR,CFR on Early Start Extension when Early Start is marked as Updated	
*****************************************************************/
    public static void updateExtensionFromES(Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap,boolean isInsert){
        try{
            List<EarlyStart__c> earlyStartList = new List<EarlyStart__c>();
            Map<id,EarlyStart__c> parentIDWithESMap = new Map<id,EarlyStart__c>();
            List<EarlyStart__c> updateList = new List<EarlyStart__c>();
            for(EarlyStart__c es : newEarlystartMap.values()){
                if(isInsert){
                    if(es.RecordTypeName__c == GlobalConstants.newEarlyStart && es.Early_Start_Status__c == GlobalConstants.APPROVED
                       && (es.Early_Start_ACR__c != null || 
                           es.Early_Start_CFR__c != null ||
                           es.Early_Start_CSR__c != null)){
                               earlyStartList.add(es);
                           }else
                               if(es.RecordTypeName__c == GlobalConstants.Extension && es.Parent_Early_Start__r.Early_Start_Status__c == GlobalConstants.APPROVED){
                                   parentIDWithESMap.put(es.Parent_Early_Start__c,es);
                               }
                }
                else 
                    if(es.RecordTypeName__c == GlobalConstants.newEarlyStart && es.Early_Start_Status__c == GlobalConstants.APPROVED
                        &&(es.Early_Start_ACR__c != oldEarlystartMap.get(es.Id).Early_Start_ACR__c || 
                           es.Early_Start_CFR__c != oldEarlystartMap.get(es.Id).Early_Start_CFR__c ||
                           es.Early_Start_CSR__c != oldEarlystartMap.get(es.Id).Early_Start_CSR__c)){
                               earlyStartList.add(es);
                           } 
                else  /*parent values to be compared here*/
                    if(es.RecordTypeName__c == GlobalConstants.Extension && es.Parent_Early_Start__r.Early_Start_Status__c == GlobalConstants.APPROVED
                       ){
                                parentIDWithESMap.put(es.Parent_Early_Start__c,es);
                             }
            }
            if(!parentIDWithESMap.isEmpty()){
                for (EarlyStart__c es : [Select id,Early_Start_ACR__c,Early_Start_CFR__c,Early_Start_CSR__c from EarlyStart__c 
                                         where id in :parentIDWithESMap.keyset()Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ){
                                             if(es.Early_Start_ACR__c != parentIDWithESMap.get(es.Id).Early_Start_ACR__c ||
                                                es.Early_Start_CFR__c != parentIDWithESMap.get(es.Id).Early_Start_CFR__c ||
                                                es.Early_Start_CSR__c != parentIDWithESMap.get(es.Id).Early_Start_CSR__c ){
                                                updateList.add(new EarlyStart__c(Id =es.id,
                                                         Early_Start_ACR__c = es.Early_Start_ACR__c,
                                                         Early_Start_CFR__c = es.Early_Start_CFR__c,
                                                         Early_Start_CSR__c = es.Early_Start_CSR__c));
                                                    //parentIDWithESMap.get(es.Id).Early_Start_ACR__c = es.Early_Start_ACR__c ;
                                                   // parentIDWithESMap.get(es.Id).Early_Start_CFR__c = es.Early_Start_CFR__c ;
                                                   // parentIDWithESMap.get(es.Id).Early_Start_CSR__c = es.Early_Start_CSR__c ;
                                                   // updateList.add(parentIDWithESMap.get(es.Id));
                                                }     
                                         }
            }
            if(!earlyStartList.isEmpty()){
                for (EarlyStart__c es : [Select id ,Early_Start_ACR__c,Early_Start_CFR__c,Early_Start_CSR__c,Parent_Early_Start__c
                                         from EarlyStart__c where Parent_Early_Start__c in :earlyStartList ]){
                                             es.Early_Start_ACR__c = es.Parent_Early_Start__r.Early_Start_ACR__c;
                                             es.Early_Start_CFR__c = es.Parent_Early_Start__r.Early_Start_CFR__c;
                                             es.Early_Start_CSR__c = es.Parent_Early_Start__r.Early_Start_CSR__c;
                                             updateList.add(es);
                                         }
            }
            if(!updateList.isEmpty()){
                update updateList;
            }
            
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, GlobalConstants.updateParentOpp, GlobalConstants.EarlyStartHelper, true, e)));}
    }       
	/****************************************************************
* @author: Aditya Mohapatra 
* @date: 15-07-2020
* @param: Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap
* @description: Update Early Start when Parent Early Start Extension is updated	
*****************************************************************/
    public static void updateESFromExtension(Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap){
        try{
            Set<id> ESIDs = new Set<ID> ();
            List<EarlyStart__c> updateList = new List<EarlyStart__c>();
            for(EarlyStart__c es : newEarlystartMap.values()){
                if(es.RecordTypeName__c == GlobalConstants.Extension && (es.Early_Start_Status__c == GlobalConstants.APPROVED
                  || (es.Early_Start_Status__c == GlobalConstants.APPROVED && es.Early_Start_Status__c != oldEarlystartMap.get(es.Id).Early_Start_Status__c))) {
                    if(es.Updated_Reason_for_Early_Start__c!=oldEarlystartMap.get(es.Id).Updated_Reason_for_Early_Start__c) {
                        updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateReasonForEarlyStart, 
                         Reason_for_Early_Start__c = es.Updated_Reason_for_Early_Start__c));
                    }
                      //update dates
                      if(es.Updated_Scope_of_Early_Start__c!=oldEarlystartMap.get(es.Id).Updated_Scope_of_Early_Start__c){
                        updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateScopeOfEarlyStart, 
                         Updated_Scope_of_Early_Start__c = es.Updated_Scope_of_Early_Start__c));  
                      }
                      if(es.Updated_Early_Start_Degree__c!=oldEarlystartMap.get(es.Id).Updated_Early_Start_Degree__c){
                          updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateEarlyStartDegree, 
                         Updated_Early_Start_Degree__c = es.Updated_Early_Start_Degree__c));
                      }
                      if(es.Updated_Commodities__c!=oldEarlystartMap.get(es.Id).Updated_Commodities__c){
                          updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateCommodities, 
                         Updated_Commodities__c = es.Updated_Commodities__c));
                      }
                      if(es.Updated_BoQ_with_Delivery_Objects_Files__c!=oldEarlystartMap.get(es.Id).Updated_BoQ_with_Delivery_Objects_Files__c){
                          updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateBoQwithDeliveryObjectsAttachments, 
                         Updated_BoQ_with_Delivery_Objects_Files__c = es.Updated_BoQ_with_Delivery_Objects_Files__c));
                      }
                      if(es.Updated_Scope_Description__c!=oldEarlystartMap.get(es.Id).Updated_Scope_Description__c){
                          updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateScopeDescription, 
                         Updated_Scope_Description__c = es.Updated_Scope_Description__c));
                      }
                      if(es.Updated_Total_Deal_Value__c!=oldEarlystartMap.get(es.Id).Updated_Total_Deal_Value__c){
                          updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = GlobalConstants.updateUpdatedTotalValueOfRelatedOpp, 
                         Updated_Total_Deal_Value__c = es.Updated_Total_Deal_Value__c));
                      }
                      updateList.add(new EarlyStart__c(Id =es.Parent_Early_Start__c,Last_Approved_Extension__c = es.Name, 
                         Estimated_Revenue_for_Early_Start_Scope__c = es.Est_Revenue_for_AFTER_Extension_currency__c,
                         Estimated_Cost_for_Early_Start_Scope__c = es.Est_Cost_AFTER_Extension_currency__c,
                         Early_Start_Expected_End_Date__c = es.New_Expected_End_Date__c));
                }
            } 
            if(!updateList.isEmpty()){
                update updateList;
            }
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, GlobalConstants.updateParentOpp, GlobalConstants.EarlyStartHelper, true, e)));}   
        
    }  
    /***************************************************************************
* @author: Richa Gupta
* @date: 13-10-2020
* @User Story: 1930
* @description:  This method will set Approvers on Early start from Corressponding  CU
********************************************************************************/ 
    public static void setApprovers(List<EarlyStart__c> newEarlystart,Map<id,EarlyStart__c> oldEarlystartMap,Boolean isInsert){
        try{ 
            Set<Id> allOppId = new Set<Id>();
            List<EarlyStart__c> earlyStartList= new List<EarlyStart__c>();
            Map<ID, Opportunity> mapOpp;
            for(EarlyStart__c es:newEarlystart){
                if(es.RecordTypeName__c == GlobalConstants.newEarlyStart){
                    allOppId.add(es.Opportunity__c) ;
                    earlyStartList.add(es);
                }
            }
            if(!allOppId.isEmpty()&&!earlyStartList.isEmpty()){
                mapOpp = new Map <Id, Opportunity >([Select Id,Account.CustomerReportingGroup__r.CustomerUnit__r.EarlyStartApprovalValueLimit__c 
                                                     from Opportunity Where Id in:allOppId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            }
            Map<id,id> ESWithCUIdMap = new Map<id,id>();
            for(EarlyStart__c es:newEarlystart){
                if( es.RecordTypeName__c == GlobalConstants.newEarlyStart){
                    ESWithCUIdMap.put(es.id,mapOpp.get(es.Opportunity__c).Account.CustomerReportingGroup__r.CustomerUnit__c);
                }
            }
            Map<id,List<EarlyStartApprover__c>> CUIdWithESAMap = new Map<id,List<EarlyStartApprover__c>>();
            for(CustomerUnit__c cu: [SELECT Id, Name,(SELECT Name,ApproverName__c,ApproverRole__c,EarlyStartApprovalThresholdLevel__c From EarlyStartApprovers__r) FROM CustomerUnit__c where id in:ESWithCUIdMap.values() 
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                CUIdWithESAMap.put(cu.Id, cu.EarlyStartApprovers__r);
            }    
            for(EarlyStart__c es:newEarlystart){
                if(es.RecordTypeName__c == GlobalConstants.newEarlyStart){
                    List<EarlyStartApprover__c> esaList = CUIdWithESAMap.get(ESWithCUIdMap.get(es.id));
                    for(EarlyStartApprover__c esa : esaList){
                       Boolean isOther=False;
                       Boolean isCUSupplyHead=False;
                       Boolean isMAHead =False;
                       Boolean isTradeFinance =False;
                       Boolean isBMAS =False;
                       Boolean isBDGS =False;
                       Boolean isBTEB =False;
                       Boolean isBNEW =False; 
                       Boolean isOther2=False;
                       Boolean isOther3=False;
                        if(isInsert||(!isInsert &&(es.RecalculateApprovers__c!=oldEarlystartMap.get(es.id).RecalculateApprovers__c||es.Estimated_Cost_for_Early_Start_Scope__c!=oldEarlystartMap.get(es.id).Estimated_Cost_for_Early_Start_Scope__c))){
                            if(!isOther && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All)&&esa.ApproverRole__c.equals(GlobalConstants.Other)){
                              es.Other__c=esa.ApproverName__c;
                               isOther=True;
                            }else if(!isOther && es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c && esa.EarlyStartApprovalThresholdLevel__c.equals('High')&&esa.ApproverRole__c.equals(GlobalConstants.Other)){
                                es.Other__c=esa.ApproverName__c;
                            }else if(!isOther && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c && esa.EarlyStartApprovalThresholdLevel__c.equals('Low')&&esa.ApproverRole__c.equals(GlobalConstants.Other)){
                                es.Other__c=esa.ApproverName__c;
                            }if(!isOther2 && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All)&&esa.ApproverRole__c.equals(GlobalConstants.Other2)){
                              es.Other2__c=esa.ApproverName__c;
                               isOther2=True;
                            }else if(!isOther2 && es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c && esa.EarlyStartApprovalThresholdLevel__c.equals('High')&&esa.ApproverRole__c.equals(GlobalConstants.Other2)){
                                es.Other2__c=esa.ApproverName__c;
                            }else if(!isOther2 && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c && esa.EarlyStartApprovalThresholdLevel__c.equals('Low')&&esa.ApproverRole__c.equals(GlobalConstants.Other2)){
                                es.Other2__c=esa.ApproverName__c;
                            }if(!isOther3 && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All)&&esa.ApproverRole__c.equals(GlobalConstants.Other3)){
                              es.Other3__c=esa.ApproverName__c;
                               isOther3=True;
                            }else if(!isOther && es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c && esa.EarlyStartApprovalThresholdLevel__c.equals('High')&&esa.ApproverRole__c.equals(GlobalConstants.Other3)){
                                es.Other3__c=esa.ApproverName__c;
                            }else if(!isOther3 && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c && esa.EarlyStartApprovalThresholdLevel__c.equals('Low')&&esa.ApproverRole__c.equals(GlobalConstants.Other3)){
                                es.Other3__c=esa.ApproverName__c;
                            }
                        } 
                        if((isInsert||(!isInsert &&(es.RecalculateApprovers__c!=oldEarlystartMap.get(es.id).RecalculateApprovers__c||es.Estimated_Cost_for_Early_Start_Scope__c!=oldEarlystartMap.get(es.id).Estimated_Cost_for_Early_Start_Scope__c
                                                    ||(es.Reason_for_Early_Start__c!=oldEarlystartMap.get(es.id).Reason_for_Early_Start__c))))
                           &&es.Reason_for_Early_Start__c!=null && !es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)){
                               if(!isMAHead && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All)
                                  &&(esa.ApproverRole__c.equals(GlobalConstants.MAHeadorDelegate))){
                                      es.MA_Head_or_Delegate__c=esa.ApproverName__c;
                                      isMAHead=true;
                                  }
                               else if(!isMAHead && esa.EarlyStartApprovalThresholdLevel__c.equals('High')&& es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c
                                       &&(esa.ApproverRole__c.equals(GlobalConstants.MAHeadorDelegate))){
                                           es.MA_Head_or_Delegate__c=esa.ApproverName__c;
                                      }
                               else if( !isMAHead && esa.EarlyStartApprovalThresholdLevel__c.equals('Low')&& es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c
                                       &&(esa.ApproverRole__c.equals(GlobalConstants.MAHeadorDelegate))){
                                           es.MA_Head_or_Delegate__c=esa.ApproverName__c;
                                       }
                           }
                        if((isInsert||(!isInsert &&(es.RecalculateApprovers__c!=oldEarlystartMap.get(es.id).RecalculateApprovers__c||es.Estimated_Cost_for_Early_Start_Scope__c!=(oldEarlystartMap.get(es.id).Estimated_Cost_for_Early_Start_Scope__c)
                                                    ||(es.Reason_for_Early_Start__c!=oldEarlystartMap.get(es.id).Reason_for_Early_Start__c&&!oldEarlystartMap.get(es.id).Reason_for_Early_Start__c.contains(GlobalConstants.LetterofCredit)))))
                           && es.Reason_for_Early_Start__c!=null && es.Reason_for_Early_Start__c.contains(GlobalConstants.LetterofCredit)){
                               if(!isTradeFinance && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All) &&esa.ApproverRole__c.equals(GlobalConstants.TradeFinanceHeadofCustomerFinance)){
                                   es.Trade_Finance__c=esa.ApproverName__c;
                                   isTradeFinance=true;
                               }else if(!isTradeFinance &&esa.EarlyStartApprovalThresholdLevel__c.equals('High')&& es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c && esa.ApproverRole__c.equals(GlobalConstants.TradeFinanceHeadofCustomerFinance)){                         
                                   es.Trade_Finance__c=esa.ApproverName__c;
                               }else if(!isTradeFinance &&esa.EarlyStartApprovalThresholdLevel__c.equals('Low')&& es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c && esa.ApproverRole__c.equals(GlobalConstants.TradeFinanceHeadofCustomerFinance)){                         
                                   es.Trade_Finance__c=esa.ApproverName__c;
                               }
                           }
                        if((isInsert||(!isInsert &&(es.RecalculateApprovers__c!=oldEarlystartMap.get(es.id).RecalculateApprovers__c||es.Estimated_Cost_for_Early_Start_Scope__c!=oldEarlystartMap.get(es.id).Estimated_Cost_for_Early_Start_Scope__c
                                                    ||(es.Commodities__c!=oldEarlystartMap.get(es.id).Commodities__c)
                                                    ||(es.Reason_for_Early_Start__c!=oldEarlystartMap.get(es.id).Reason_for_Early_Start__c))))
                           && es.Commodities__c!=null && (es.Commodities__c.contains(GlobalConstants.Hardware)||
                                                          es.Commodities__c.contains(GlobalConstants.Software)) &&es.Reason_for_Early_Start__c!=null &&
                            !es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)){
                               if(!isCUSupplyHead && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All)
                                  &&(esa.ApproverRole__c.equals(GlobalConstants.CUSupplyHead))){
                                      es.CU_Supply_Head__c=esa.ApproverName__c;
                                      isCUSupplyHead=true;
                                  }
                               else if(!isCUSupplyHead  && esa.EarlyStartApprovalThresholdLevel__c.equals('High') && es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c
                                       &&(esa.ApproverRole__c.equals(GlobalConstants.CUSupplyHead))){
                                           es.CU_Supply_Head__c=esa.ApproverName__c;
                                       }
                               else if(!isCUSupplyHead  && esa.EarlyStartApprovalThresholdLevel__c.equals('Low') && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c
                                       &&(esa.ApproverRole__c.equals(GlobalConstants.CUSupplyHead))){
                                           es.CU_Supply_Head__c=esa.ApproverName__c;
                                       }
                            } 
                         if((isInsert &&es.BAPartofEarlyStartScope__c!=null &&
                            es.Reason_for_Early_Start__c!=null && !es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit))
                           ||(!isInsert &&(es.BAPartofEarlyStartScope__c!=oldEarlystartMap.get(es.Id).BAPartofEarlyStartScope__c
                                           ||es.RecalculateApprovers__c!=oldEarlystartMap.get(es.id).RecalculateApprovers__c
                                           ||es.Estimated_Cost_for_Early_Start_Scope__c!=oldEarlystartMap.get(es.id).Estimated_Cost_for_Early_Start_Scope__c
                                           ||es.Reason_for_Early_Start__c!=oldEarlystartMap.get(es.Id).Reason_for_Early_Start__c 
                                          )&&es.BAPartofEarlyStartScope__c!=null
                             &&es.Reason_for_Early_Start__c!=null
                              &&!es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit))){
							  if( es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BMAS)){
							    if(!isBMAS && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All) &&esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeManagedServices)){    
                                      es.BA_Representative_Managed_Services__c=esa.ApproverName__c;
                                      isBMAS=true;
                                   }else if(!isBMAS &&esa.EarlyStartApprovalThresholdLevel__c.equals('High')  && es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c
                                           &&esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeManagedServices)){    
                                               es.BA_Representative_Managed_Services__c=esa.ApproverName__c;
                                   }else if(!isBMAS &&esa.EarlyStartApprovalThresholdLevel__c.equals('Low') && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c 
                                                    &&esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeManagedServices)){    
                                                        es.BA_Representative_Managed_Services__c=esa.ApproverName__c;
                                  }
                              } 
                                  if( es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BDGS)){
							       if(!isBDGS && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All) && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeDigital)){
                                      es.BA_Representative_Digital__c=esa.ApproverName__c;
                                      isBDGS=true;
                                  }else if(!isBDGS && esa.EarlyStartApprovalThresholdLevel__c.equals('High') && es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c 
                                           && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeDigital)){
                                               es.BA_Representative_Digital__c=esa.ApproverName__c;
                                  }else if(!isBDGS && esa.EarlyStartApprovalThresholdLevel__c.equals('Low') && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c 
                                          && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeDigital)){
                                          es.BA_Representative_Digital__c=esa.ApproverName__c;
                                }
								}if(es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BTEB)){
								if(!isBTEB && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All) 
                                     && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeEmergingBusIOT)){
                                         es.BA_Representative_Emerging_Bus_IOT__c=esa.ApproverName__c;
                                         isBTEB=true;
                               }else if(!isBTEB &&esa.EarlyStartApprovalThresholdLevel__c.equals('High')&& es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c 
                                      && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeEmergingBusIOT)){   
                                         es.BA_Representative_Emerging_Bus_IOT__c=esa.ApproverName__c;
                               }else if(!isBTEB &&esa.EarlyStartApprovalThresholdLevel__c.equals('Low') && es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c 
                                       && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeEmergingBusIOT)){
                                        es.BA_Representative_Emerging_Bus_IOT__c=esa.ApproverName__c;
                               }
                             } if(es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BNEW)){
							  if(!isBNEW && esa.EarlyStartApprovalThresholdLevel__c.equals(GlobalConstants.All) && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeNetworks)){
                                      es.BA_Representative_Networks__c=esa.ApproverName__c;
                                      isBNEW=true;
                                  }else if(!isBNEW &&esa.EarlyStartApprovalThresholdLevel__c.equals('High')&&es.Estimated_Cost_for_Early_Start_Scope__c>es.EarlyStartApprovalValueLimit__c 
                                           && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeNetworks)){
                                               es.BA_Representative_Networks__c=esa.ApproverName__c;
                                   }else if(!isBNEW && esa.EarlyStartApprovalThresholdLevel__c.equals('Low')&&es.Estimated_Cost_for_Early_Start_Scope__c<es.EarlyStartApprovalValueLimit__c 
                                             && esa.ApproverRole__c.equals(GlobalConstants.BARepresentativeNetworks)){
                                               es.BA_Representative_Networks__c=esa.ApproverName__c;
                                   }
                              }
							  }
                  } 
                }
            } 
        }
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, GlobalConstants.setApprovers, 
                                                                       GlobalConstants.EarlyStartHelper, true, e)));}   
    }
    
 
      /****************************************************************
* @author: Richa Gupta 
* @date: 09-11-2020
* @param: List<EarlyStart__c> newEarlystart
* @description: Inherit parent ES Approvers on ES Extension	(U-0887)
*****************************************************************/
 public static void setApproversOnExtension(List<EarlyStart__c> newEarlystart){
     try{
         set<id> parentESId= new set<id>();
         Map<id,EarlyStart__c> approvers= new Map<id,EarlyStart__c>();
         for(EarlyStart__c es:newEarlystart){
             if(es.RecordTypeName__c==GlobalConstants.Extension){
                 parentESId.add(es.Parent_Early_Start__c);
             }
         }
        if(!parentESId.isEmpty()){
        approvers=new Map<id,EarlyStart__c>([Select Other__c,Other2__c,Other3__c,MA_Head_or_Delegate__c,Trade_Finance__c,CU_Supply_Head__c,
                                    BA_Representative_Managed_Services__c,BA_Representative_Emerging_Bus_IOT__c,
                                    BA_Representative_Networks__c,BA_Representative_Digital__c from EarlyStart__c 
                             where id in:parentESId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
        } //system.debug('approvers'+approvers);
         if(!approvers.isEmpty()){
         for(EarlyStart__c es:newEarlystart){
            if(approvers.get(es.Parent_Early_Start__c).Other__c!=null){
               es.Other__c=approvers.get(es.Parent_Early_Start__c).Other__c;
            }if(approvers.get(es.Parent_Early_Start__c).Other2__c!=null){
                es.Other2__c=approvers.get(es.Parent_Early_Start__c).Other2__c;
            }if(approvers.get(es.Parent_Early_Start__c).Other3__c!=null){
               es.Other3__c=approvers.get(es.Parent_Early_Start__c).Other3__c;
            }if(approvers.get(es.Parent_Early_Start__c).MA_Head_or_Delegate__c!=null){
                es.MA_Head_or_Delegate__c=approvers.get(es.Parent_Early_Start__c).MA_Head_or_Delegate__c;
            }if(approvers.get(es.Parent_Early_Start__c).Trade_Finance__c!=null){
                es.Trade_Finance__c=approvers.get(es.Parent_Early_Start__c).Trade_Finance__c;
            }if(approvers.get(es.Parent_Early_Start__c).CU_Supply_Head__c!=null){
                es.CU_Supply_Head__c=approvers.get(es.Parent_Early_Start__c).CU_Supply_Head__c;
            }if(approvers.get(es.Parent_Early_Start__c).BA_Representative_Managed_Services__c!=null){
                es.BA_Representative_Managed_Services__c=approvers.get(es.Parent_Early_Start__c).BA_Representative_Managed_Services__c;
            }if(approvers.get(es.Parent_Early_Start__c).BA_Representative_Emerging_Bus_IOT__c!=null){
                es.BA_Representative_Emerging_Bus_IOT__c=approvers.get(es.Parent_Early_Start__c).BA_Representative_Emerging_Bus_IOT__c;
            }if(approvers.get(es.Parent_Early_Start__c).BA_Representative_Networks__c!=null){
                es.BA_Representative_Networks__c=approvers.get(es.Parent_Early_Start__c).BA_Representative_Networks__c;
            }if(approvers.get(es.Parent_Early_Start__c).BA_Representative_Digital__c!=null){
                es.BA_Representative_Digital__c=approvers.get(es.Parent_Early_Start__c).BA_Representative_Digital__c;
            }
         }
     }
     }catch(Exception e){
      EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, 
                           GlobalConstants.setApproversOnExtension, GlobalConstants.EarlyStartHelper, true, e)));    
     }
 }
   /*************************************************************************************
* @author: Richa Gupta 
* @date: 11-12-2020
* @param: Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap
* @UserStory: U-2190
* @description: This method is used to get Fedration Id of User in Early start records	
******************************************************************************************/ 
    public static void getSignumofUser(List<EarlyStart__c> newEarlystart,Map<id,EarlyStart__c> oldEarlystartMap,Boolean isInsert){
        try{
            set<string> fields=new set<string>();
            map<string,string>mapofupdatedfields= GlobalConstants.returnUserValue();
            Map<id,User> UserSignum;
            set<string> userId=new set<string>();
            for(EarlyStart__c es:newEarlystart){
                for(string s:mapofupdatedfields.keyset()){
                    if(es.get(s)!=null){
                        object ob=es.get(s);
                        String returnValue = String.valueOf(ob);
                        userId.add(returnValue);
                    }
                }
            }
            if(!userId.isEmpty()) {
                UserSignum = New Map<id,User>([select id,FederationIdentifier from User where id in:UserId]) ; 
            }   
            for(EarlyStart__c es:newEarlystart){
                for(string s:mapofupdatedfields.keyset()){
                    object ob=es.get(s);
                    string userValue = string.valueOf(ob);
                    if(userValue!=null && UserSignum.get(userValue).FederationIdentifier!=null){
                        string fieldname=mapofupdatedfields.get(s);
                        es.put(fieldName,UserSignum.get(userValue).FederationIdentifier);
                    }
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, 
                                                                       GlobalConstants.getSignumofUser, GlobalConstants.EarlyStartHelper, true, e)));
        }   
        
    }
     /*************************************************************************************
* @author: Richa Gupta 
* @date: 11-12-2020
* @param: Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap
* @UserStory: U-1910 (Part Of U- 2215,U-1930)
* @description: This method is used to Remove Approvers based on Condition.	
******************************************************************************************/ 
    public static void disappearApprovers(List<EarlyStart__c> newEarlystart,Map<id,EarlyStart__c> oldEarlystartMap){
        try{
            for(EarlyStart__c es:newEarlystart){
                if(es.RecordTypeName__c == GlobalConstants.newEarlyStart){
                    if(es.Commodities__c.equals(GlobalConstants.Services)||es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)){
                        if(es.CU_Supply_Head__c!=null){
                            es.CU_Supply_Head__c=null;
                        }
                    }if(es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)){
                        if(es.MA_Head_or_Delegate__c!=null){
                            es.MA_Head_or_Delegate__c=null;
                        }
                    }if(!es.Reason_for_Early_Start__c.contains(GlobalConstants.LetterofCredit)){
                        if(es.Trade_Finance__c!=null){
                            es.Trade_Finance__c=null;
                        }
                    }if(es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)||es.BAPartofEarlyStartScope__c==null||(es.BAPartofEarlyStartScope__c!=null&&!es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BDGS))){
                        if(es.BA_Representative_Digital__c!=null){
                            es.BA_Representative_Digital__c=null;
                        }
                    } if(es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)||es.BAPartofEarlyStartScope__c==null||(es.BAPartofEarlyStartScope__c!=null&&!es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BMAS))){
                        if(es.BA_Representative_Managed_Services__c!=null){
                            es.BA_Representative_Managed_Services__c=null;
                        }
                    }if(es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)||es.BAPartofEarlyStartScope__c==null||(es.BAPartofEarlyStartScope__c!=null&&!es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BTEB))){
                        if(es.BA_Representative_Emerging_Bus_IOT__c!=null){
                            es.BA_Representative_Emerging_Bus_IOT__c=null;
                        }
                    }if(es.Reason_for_Early_Start__c.equals(GlobalConstants.LetterofCredit)||es.BAPartofEarlyStartScope__c==null||(es.BAPartofEarlyStartScope__c!=null&&!es.BAPartofEarlyStartScope__c.contains(GlobalConstants.BNEW))){
                        if(es.BA_Representative_Networks__c!=null){
                            es.BA_Representative_Networks__c=null;
                        }
                    }   
                }
            }
        }
        catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EarlyStartHelper, GlobalConstants.disappearApprovers, 
                                                                       GlobalConstants.EarlyStartHelper, true, e)));}   
    }
}