/****************************************************************
* @author: Anukriti 
* @date: 20-01-2020
* @User Story: U-1578
* @description: This class is a helper class for SalesDecisionMakerTrigger 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

*****************************************************************/
public without sharing class SalesDecisonMakerHelper {
    /****************************************************************
* @author: Manu Singhal
* @date: 13-04-2020
* @param: U-1700
* @description: This method will restrict duplicate approver.
*****************************************************************/
   public static void restrictDuplicateApprover(List<Sales_Decision_Maker__c> newSDMList,Map<Id, Sales_Decision_Maker__c> oldSDMMap,Boolean isInsert){
        try{
            Map<id,List<Sales_Decision_Maker__c>> sdrMap = new Map<id,List<Sales_Decision_Maker__c>>(); 
            List<id> approverNameList;
            List<Sales_Decision_Maker__c> sdmErrorList = new List<Sales_Decision_Maker__c>();
            for(Sales_Decision_Maker__c sdm : newSDMList)
            {
                if(isInsert)
				{
					if(sdm.Approver_Name__c != null)
					{
						if(!sdrMap.containsKey(sdm.Sales_Decision_Record__c)) 
							sdrMap.put(sdm.Sales_Decision_Record__c, new List<Sales_Decision_Maker__c>());
						sdrMap.get(sdm.Sales_Decision_Record__c).add(sdm); 
					}
				}
				else if(sdm.Approver_Name__c != null && sdm.Approver_Name__c != oldSDMMap.get(sdm.id).Approver_Name__c)
				{
					if(!sdrMap.containsKey(sdm.Sales_Decision_Record__c)) 
                        sdrMap.put(sdm.Sales_Decision_Record__c, new List<Sales_Decision_Maker__c>());
                    sdrMap.get(sdm.Sales_Decision_Record__c).add(sdm); 
				}
            }
            if(!sdrMap.keySet().isEmpty())
            {
                for(Sales_Decision_Record__c sdr: [select id,(SELECT ID,Approver_Name__c FROM Sales_Decision_Makers__r)                                                     
                                                   from Sales_Decision_Record__c where id in : sdrMap.keySet()])
                {
                    approverNameList = new List<id>();
                    for(Sales_Decision_Maker__c sdm : sdr.Sales_Decision_Makers__r)	
                    {    
                        if((isInsert || (!isInsert && !oldSDMMap.keySet().contains(sdm.id))) && sdm.Approver_Name__c != null)                         
                        	approverNameList.add(sdm.Approver_Name__c);                      	
                    }
                    for(Sales_Decision_Maker__c newSDM : sdrMap.get(sdr.id))
                    {
                        if(!approverNameList.isEmpty() && approverNameList.contains(newSDM.Approver_Name__c))
                        {
                            sdmErrorList.add(newSDM);
                            break;
                        }
                    }                    
                }
            }
            if(!sdmErrorList.isEmpty())
            {	//U-1903
                for(Sales_Decision_Maker__c sdm : sdmErrorList)
                    sdm.addError(GlobalConstants.SDM_APPROVER_ALREADY_ADDED_ERROR);
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, 
                                                                                        GlobalConstants.restrictDeletionOfAutoSDM, GlobalConstants.SalesDecisonMakerHelper, true, e)));}
    }
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578, U-1700
* @description: This method will restrict deletion of auto-generated SDMs if the role is not present.
*****************************************************************/
    public static void restrictDeletionOfAutoSDM(List<Sales_Decision_Maker__c> oldSDMList){
        try{
            Set<id> sdrIdSet = new Set<id>();
            Set<id> sdmIdSet= new Set<id>();           
            Map<id, List<Sales_Decision_Maker__c>> sdrIdWithSDMMap = new Map<id, List<Sales_Decision_Maker__c>>();
            List<String> roleList = new List<String>();
            List<String> role = new List<String>();
            for(Sales_Decision_Maker__c sdm: oldSDMList) {
                if(sdm.Auto_Generated__c) 
                {
                    sdrIdSet.add(sdm.Sales_Decision_Record__c);
                    sdmIdSet.add(sdm.id);
                }       
            }
            if(sdrIdSet != null)
            {
                for(Sales_Decision_Maker__c sdm : [select id,Auto_Generated__c, Approver_Name__c,Approver_Role__c,Sales_Decision_Record__c 
                                                   from Sales_Decision_Maker__c 
                                                   where Sales_Decision_Record__c in : sdrIdSet and Auto_Generated__c =: true and id not in :sdmIdSet])
                {
                    if(!sdrIdWithSDMMap.containsKey(sdm.Sales_Decision_Record__c)) 
                        sdrIdWithSDMMap.put(sdm.Sales_Decision_Record__c, new List<Sales_Decision_Maker__c>());
                    sdrIdWithSDMMap.get(sdm.Sales_Decision_Record__c).add(sdm);                 
                }
            }
            for(Sales_Decision_Maker__c sdm: oldSDMList)
            {
                if(sdrIdWithSDMMap.get(sdm.Sales_Decision_Record__c) != null)
                {
                    for(Sales_Decision_Maker__c sdmOld : sdrIdWithSDMMap.get(sdm.Sales_Decision_Record__c))
                    {	//U-1903
                        if(sdmOld.Approver_Role__c.contains(GlobalConstants.SEMICOLON))
                        {
                            role = sdmOld.Approver_Role__c.split(GlobalConstants.SEMICOLON);
                            roleList.addAll(role);
                        }
                        else 
                            roleList.add(sdmOld.Approver_Role__c);
                    }       
                    if(!roleList.isEmpty())
					{	//U-1903
						for(String str : sdm.Approver_Role__c.split(GlobalConstants.SEMICOLON))	
						{
							if(!roleList.contains(str))
								sdm.addError(GlobalConstants.Error_Msg_for_Restrict_Deletion_of_SDM);							
						}
					}                 
                }
                 else if(sdmIdSet.contains(sdm.id) && roleList.isEmpty())
                        sdm.addError(GlobalConstants.Error_Msg_for_Restrict_Deletion_of_SDM);
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, 
                                                                                        GlobalConstants.restrictDeletionOfAutoSDM, GlobalConstants.SalesDecisonMakerHelper, true, e)));}
    }
    
    /****************************************************************
* @author: Anukriti
* @date: 20-01-2020
* @param: U-1578
* @description: This method will reCalculate Ready for SDr field, if there is change in SDM's role and approver
*****************************************************************/
 /*   public static void reCalculateReadySDR(List<Sales_Decision_Maker__c> newSDMList, Map<Id, Sales_Decision_Maker__c> oldSDMMap){
        try{
            Set<Id> sdrIds = new Set<Id>();
            
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, 
                                                                                        GlobalConstants.reCalculateReadySDR, GlobalConstants.SalesDecisonMakerHelper, true, e)));}
    }*/
    
    /****************************************************************
* @author: Manu Singhal
* @date: 20-01-2020
* @param: U-1578, D-2511
* @description: This method will update SDR approval status to 'Approvals Ongoing' when sdm status is updated from 'To be Requested'.
*****************************************************************/
    public static void updateSalesDecisionApprovalStatus(List<Sales_Decision_Maker__c> newSDMList, Map<Id, Sales_Decision_Maker__c> oldSDMMap){
        try{
            Set<id> tobereqSDMSet = new Set<id>();
            Set<id> reqSDMSet = new Set<id>();
            List<Sales_Decision_Record__c> sdrListToUpdate = new List<Sales_Decision_Record__c>();
            for(Sales_Decision_Maker__c sdm: newSDMList) {
                if(sdm.Approval_Status__c != oldSDMMap.get(sdm.id).Approval_Status__c)
                {
                    if(oldSDMMap.get(sdm.id).Approval_Status__c == GlobalConstants.TOBEREQUESTED){
                        tobereqSDMSet.add(sdm.id);
                    }
                    else if(sdm.Approval_Status__c == GlobalConstants.TOBEREQUESTED) 
         {
                                reqSDMSet.add(sdm.id);
                            }
                }                             
            }
            if(!tobereqSDMSet.isEmpty() || !reqSDMSet.isEmpty())
            {
                for(Sales_Decision_Maker__c sdm : [select id,Sales_Decision_Record__r.id, Sales_Decision_Record__r.Sales_Decision_Approval_Status__c,
                                                   Sales_Decision_Record__r.SDMCount__c,Sales_Decision_Record__r.Requested_SDM_Count__c
                                                   from Sales_Decision_Maker__c where id in : tobereqSDMSet OR id in : reqSDMSet
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(tobereqSDMSet.contains(sdm.id) && sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c == GlobalConstants.INPROGRESS)
                    {
                        sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVALSONGOING;
                        sdrListToUpdate.add(sdm.Sales_Decision_Record__r);
                    }                     
                    else if(reqSDMSet.contains(sdm.id) &&
                            sdm.Sales_Decision_Record__r.Requested_SDM_Count__c == 0
                            && sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c == GlobalConstants.APPROVALSONGOING)
                    {
                        sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
                        sdrListToUpdate.add(sdm.Sales_Decision_Record__r);
                    }
                }
            }
            if(!sdrListToUpdate.isEmpty()){
                database.update(sdrListToUpdate);          
            }                
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, 
                                                                                        GlobalConstants.updateSalesDecisionApprovalStatus, GlobalConstants.SalesDecisonMakerHelper, true, e)));}
    }
   
/****************************************************************
* @author: Biswajit Sahoo
* @date: 16-09-2020
* @param: U-1756
* @description: Summarize comment/notes related to SDM
*****************************************************************/
    public static void updateSDRAllConditionsNotes(List<Sales_Decision_Maker__c> sdmList, Map<Id,Sales_Decision_Maker__c> oldSDMMap)
    {
        try{
           	List<Sales_Decision_Record__c> updateSDRList = new List<Sales_Decision_Record__c>();
            Set<Id> toBeUpdatedCondList = new Set<Id>();
            for(Sales_Decision_Maker__c sdm : sdmList)
            {
              if(sdm.Conditions_Notes__c != oldSDMMap.get(sdm.id).Conditions_Notes__c)
              {
                  toBeUpdatedCondList.add(sdm.Sales_Decision_Record__c);
              }
            }
          
          /*  List<Sales_Decision_Record__c> srdList = [Select Id, All_Conditions_Notes__c,
                                                    (SELECT id, Conditions_Notes__c, 
                                                    Approver_Name__r.FirstName,
                                                     Approver_Name__r.LastName
                                                   FROM Sales_Decision_Makers__r)
                                                   FROM Sales_Decision_Record__c
                                                   WHERE Id IN:toBeUpdatedCondList
                                                   ];*/
           // If(srdList != NULL){
           If(toBeUpdatedCondList != NULL){
                for(Sales_Decision_Record__c sdr :[Select Id, AllConditionsaNotes__c,
                                                    (SELECT id, Conditions_Notes__c, Approver_Name__r.FirstName,
                                                     Approver_Name__r.LastName
                                                   FROM Sales_Decision_Makers__r)
                                                   FROM Sales_Decision_Record__c
                                                   WHERE Id IN:toBeUpdatedCondList
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                                                   ])
                {
                    String concatenateConditions = '';
                    for(Sales_Decision_Maker__c sdms : sdr.Sales_Decision_Makers__r )
                    {   if(sdms.Conditions_Notes__c != null){
                        concatenateConditions += sdms.Approver_Name__r.FirstName + ' ' + sdms.Approver_Name__r.LastName + ' ' +  GlobalConstants.COLON+  + ' ' + sdms.Conditions_Notes__c +  GlobalConstants.newLine1; 
                    }
                    }
                    sdr.AllConditionsaNotes__c = concatenateConditions;
                    updateSDRList.add(sdr);
                }
            }

            if(Test.IsRunningTest())
            {
                Integer i = 5/0;
            }

            if(!updateSDRList.isEmpty()){
                database.update(updateSDRList);          
            }

        }
        catch(Exception e)
        {
             {EventLog.createLog(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper,
                                  GlobalConstants.updateSDRAllConditionsNotes, GlobalConstants.SalesDecisonMakerHelper, true, e));
                           }
        }
    }
}