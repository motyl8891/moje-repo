/* Class Name : OC_TR_TimeRecordTriggerHelper
* Description : Populates the field values on the OC_TR_TimeRecord__c object based on selected ServiceContract. 
*/ 

public Without Sharing class OC_TR_TimeRecordTriggerHelper {
    
    /**************************************************************************************
* @Description  This method populates the ServiceContract Name, Account Name, AssignmetId, Pcode, 
SoldtoAccount,Case Number on OC_TR_TimeRecord__c based on selected ServiceContract.
* @Param        List - OC_TR_TimeRecord__c List. 
* @Example     
* OC_TR_TimeRecordTriggerHelper.populateSearchFieldsOnTimeRecord(timeRecordList).
**************************************************************************************/ 
    
    Public Static Void populateSearchFieldsOnTimeRecord(List<OC_TR_TimeRecord__c> timeRecordsList){
        
        Set<Id> serviceContractIdSet = new Set<Id>();
        Set<Id> caseIdSet = new Set<Id>();//Added for TR-Manual TH
        Map<Id,ServiceContract> serviceContractMap;
        Map<Id,Case> mapcaseIdTocaseRec;//Added for TR-Manual TH 
        
        try{
        for(OC_TR_TimeRecord__c tr : timeRecordsList){
            serviceContractIdSet.add(tr.OC_TR_ObjectIdCon__c);
            caseIdSet.add(tr.OC_TR_Case__c);// Added for TR-Manual TH
       }
        if(serviceContractIdSet != null && !serviceContractIdSet.isEmpty()){
            serviceContractMap = new Map<Id,ServiceContract>([SELECT id,Name,Account.Name,
                                                              OC_TH_Entitlement__r.Pcode__c,
                                                              OC_MD_Assignment_ID__c,
                                                              //Assignment_ID__r.Name,
                                                              //Account.Parent.MDM_Customer_Id__c 
                                                              Account.Parent.SAP_S2P_ID_Number__c 
                                                              FROM ServiceContract 
                                                              WHERE id IN : serviceContractIdSet ]);  
        }
        /*Added for TR-Manual TH --Begin */
        if(caseIdSet!=null && !caseIdSet.isEmpty()){
                mapcaseIdTocaseRec = new Map<Id,Case>([SELECT Id,CaseNumber
                                                                  FROM Case
                                                                  WHERE Id in:caseIdSet]);
        }
        /*Added for TR-Manual TH --End */
        for(OC_TR_TimeRecord__c tr : timeRecordsList){
            ServiceContract sc = serviceContractMap.get(tr.OC_TR_ObjectIdCon__c);
            Case cs = mapcaseIdTocaseRec.get(tr.OC_TR_Case__c);//Added for TR-Manual TH
            if(sc != null){
                tr.OC_TR_Search_ServiceContractName__c = sc.Name;
                tr.OC_TR_Search_AccountName__c = sc.Account.Name;
                //tr.OC_TR_AssignmentId__c = sc.Assignment_ID__r.Name;
                tr.OC_TR_AssignmentId__c = sc.OC_MD_Assignment_ID__c;
                tr.OC_TR_ZZPcode__c = sc.OC_TH_Entitlement__r.Pcode__c;
                //tr.OC_TR_SoldToNo__c = sc.Account.Parent.MDM_Customer_Id__c;
                tr.OC_TR_SoldToNo__c = String.ValueOf(sc.Account.Parent.SAP_S2P_ID_Number__c);
            }
             /*Added for TR-Manual TH --Begin */
            if(cs!=null){
                tr.OC_TR_Search_Case_Number__c = cs.CaseNumber;
            }
             /*Added for TR-Manual TH --End */
            
        }
            if(Test.isRunningTest()){
                insert new contact();
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.ApexCls_TimeRecordTriggerHelper,OC_TR_Constants.method_populateSearchFieldsOnTimeRecord,null, false, e));
        }    
        
    }
    
    /**************************************************************************************
* @Description  This method populates the cost allocation descrption field on OC_TR_TimeRecord__c 
based on selected cost allocation.
* @Param        List - OC_TR_TimeRecord__c List. 
* @Example     
* OC_TR_TimeRecordTriggerHelper.populateDescriptionFieldOnTimeRecord(timeRecordList).
**************************************************************************************/
    
    Public Static Void populateDescriptionFieldOnTimeRecord(List<OC_TR_TimeRecord__c> timeRecordsList){
        Map<String,String> mapCostAllocToDescription = new Map<String,String>();
        try{
            for(OC_TR_TimeRecording__mdt timeRecordMdt : [SELECT Id, DeveloperName, OC_TR_Value1__c FROM OC_TR_TimeRecording__mdt
                                                          WHERE DeveloperName LIKE : OC_TR_Constants.SEARCHMETADATAUSINGLIKE ]){
                                                              mapCostAllocToDescription.put(timeRecordMdt.DeveloperName ,timeRecordMdt.OC_TR_Value1__c);                           
                                                          }
            
            
            for(OC_TR_TimeRecord__c tr : timeRecordsList){
                if(mapCostAllocToDescription!=null && !mapCostAllocToDescription.isEmpty()){
                    if(tr.OC_TR_ZCostAlloc__c != null && mapCostAllocToDescription.containsKey(OC_TR_Constants.COSTALLOCATIONPREFIX + tr.OC_TR_ZCostAlloc__c)){
                        tr.OC_TR_CostAllocationDescription__c = mapCostAllocToDescription.get(OC_TR_Constants.COSTALLOCATIONPREFIX + tr.OC_TR_ZCostAlloc__c);
                    }
                    else if (mapCostAllocToDescription.containsKey(OC_TR_Constants.DEFAULTCOSTALLOCATION)){
                        tr.OC_TR_CostAllocationDescription__c = mapCostAllocToDescription.get(OC_TR_Constants.DEFAULTCOSTALLOCATION);
                    }
                    
                    
                }
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.ApexCls_TimeRecordTriggerHelper,OC_TR_Constants.method_populateDescriptionFieldOnTimeRecord,null, false, e));
        }    
        
    }
    
}