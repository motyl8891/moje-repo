/******************************************************************************************
*
*            @author       : Ankit Jain
*            @date         : 08-07-2020
@description  : Helper Class for TerritoryTrigger
@testClass    : TerritoryTriggerHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-                                                                                     -                                                                                     Original Version
Ankit Jain                 08-07-2020          U-1921,U-1990

******************************************************************************************/

public without sharing class TerritoryTriggerHelper {
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: oldTerritoryMap,newTerritoryMap
* @description: U-1921 & U-1990 This method will update CRG sharing on changing CRG/CAG field value in territory
*****************************************************************/
    public static void updateCrgSharing(Map<ID, Territory2> oldTerritoryMap , Map<ID, Territory2> newTerritoryMap){
        try {
            Map<Id,String> crgterritoryMap =new Map<Id,String>();
            Map<Id,String> terrirotyIdWithOldCRGMap =new Map<Id,String>();            
            Map<Id,String> terrirotyIdWithOldCAGMap =new Map<Id,String>(); 
            Map<Id,String> terrirotyIdWithNewCAGMap =new Map<Id,String>();
            Set<id> territoryIdSet = new Set<id>();
            Map<Id,String> oldCrgMap =new Map<Id,String>(); 
            Map<Id,String> newCrgMap =new Map<Id,String>();
            for(Territory2 territory : newTerritoryMap.values()){
				Set<String> allOldCrgSet=new Set<String>();
				Set<String> allNewCrgSet=new Set<String>();
                if(((territory.CRG__c != null && oldTerritoryMap.isEmpty())||(!oldTerritoryMap.isEmpty() && territory.CRG__c != oldTerritoryMap.get(territory.id).CRG__c))||((territory.CAG__c != null && oldTerritoryMap.isEmpty())||(!oldTerritoryMap.isEmpty() && territory.CAG__c != oldTerritoryMap.get(territory.id).CAG__c))){
                    territoryIdSet.add(territory.id);
                    if(territory.CRG__c!=null){
                    	allNewCrgSet.addAll(territory.CRG__c.split(GlobalConstants.COMMA));
					}
                    
                    if(!oldTerritoryMap.isEmpty()){
                        if(oldTerritoryMap.get(territory.id).CRG__c!=null){
                        	allOldCrgSet.addAll(oldTerritoryMap.get(territory.id).CRG__c.split(GlobalConstants.COMMA));    
                        }
                        terrirotyIdWithOldCRGMap.put(territory.id,oldTerritoryMap.get(territory.id).CRG__c);
                    }
                    crgterritoryMap.put(territory.Id,territory.CRG__c);
                    
                    if(!oldTerritoryMap.isEmpty())
                        terrirotyIdWithOldCAGMap=getCrgMapAfterCagSplit(territory,oldTerritoryMap);
                    terrirotyIdWithNewCAGMap=getCrgMapAfterCagSplit(territory,newTerritoryMap);  
                    
                    Set<String> oldCrgSet=new Set<String>();
                    if(terrirotyIdWithOldCRGMap.get(territory.id)!=null){
                        for(String oldCrg:allOldCrgSet){
							if(!allNewCrgSet.contains(oldCrg)){
								oldCrgSet.add(oldCrg);
							}
						}
						//terrirotyIdWithOldCRGMap.get(territory.id).split(GlobalConstants.COMMA);
						//oldCrgSet.addAll(
                    }
                    if(terrirotyIdWithOldCAGMap.get(territory.id)!=null){
                        oldCrgSet.addAll(terrirotyIdWithOldCAGMap.get(territory.id).split(GlobalConstants.COMMA));
                    }
                    String oldCrgs='';
                    for(String oldcrg:oldCrgSet){
                        oldCrgs=oldCrgs+oldcrg+GlobalConstants.COMMA;
                    }
                    oldCrgMap.put(territory.id,oldCrgs);        
                    Set<String> newCrgSet=new Set<String>();
                    if(crgterritoryMap.get(territory.id)!=null){
                        for(String newCrg:allNewCrgSet){
							if(!allOldCrgSet.contains(newCrg)){
								newCrgSet.add(newCrg);
							}
						}
						//newCrgSet.addAll(crgterritoryMap.get(territory.id).split(GlobalConstants.COMMA));
                    }
                    if(terrirotyIdWithNewCAGMap.get(territory.id)!=null){
                        newCrgSet.addAll(terrirotyIdWithNewCAGMap.get(territory.id).split(GlobalConstants.COMMA));
                    }
                    String newCrgs='';
                    for(String newcrg:newCrgSet){
                        newCrgs=newCrgs+newcrg+GlobalConstants.COMMA;
                    }
                    newCrgMap.put(territory.id,newCrgs);
                }
            }    
            if(territoryIdSet!=null){
                updateSharing(territoryIdSet,oldCrgMap,newCrgMap);
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.updateCrgSharing, 
                                                                                        GlobalConstants.TerritoryTriggerHelper, true, e)));}
    }   
    
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: territoryIdSet,terrirotyIdWithOldCRGMap,crgterritoryMap
* @description: U-1921 & U-1990 This method will update CRG sharing on changing CRG/CAG field value in territory
*****************************************************************/
    public static void updateSharing(Set<id> territoryIdSet , Map<Id,String> terrirotyIdWithOldCRGMap,Map<Id,String> crgterritoryMap){
        try{
            Map<Id,List<Id>> territoryGroupMap=new Map<Id,List<Id>>();
            if(!territoryIdSet.isEmpty()){
                for(Territory2 territoryVal : [select Id, Territory2Type.DeveloperName, ParentTerritory2.Id,ParentTerritory2.DeveloperName,ParentTerritory2.Territory2Type.DeveloperName, ParentTerritory2.ParentTerritory2.Id, ParentTerritory2.ParentTerritory2.Territory2Type.DeveloperName, ParentTerritory2.ParentTerritory2.ParentTerritory2.Id, ParentTerritory2.ParentTerritory2.ParentTerritory2.Territory2Type.DeveloperName, Name, DeveloperName, CRG__c, CAG__c from Territory2 where id IN:territoryIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(territoryVal.Territory2Type.DeveloperName.equals(GlobalConstants.KAM_Access_Group) || (territoryVal.Territory2Type.DeveloperName.equals(GlobalConstants.Customer_Unit)&& territoryVal.ParentTerritory2.DeveloperName.equals(GlobalConstants.MANA))){
                        List<Id> relatedGroupList=new List<Id>();
                        relatedGroupList.add(territoryVal.Id);
                        relatedGroupList.add(territoryVal.ParentTerritory2.Id);
                        relatedGroupList.add(territoryVal.ParentTerritory2.ParentTerritory2.Id);
                        relatedGroupList.add(territoryVal.ParentTerritory2.ParentTerritory2.ParentTerritory2.Id);
                        territoryGroupMap.put(territoryVal.Id,relatedGroupList);   
                    }
                }
            }
            Map<Id,List<Id>> crgMap=getCrgMapAfterCrgSplit(crgterritoryMap);
            Map<Id,List<Id>> crgMapOld=getCrgMapAfterCrgSplit(terrirotyIdWithOldCRGMap);
            Map<Id,List<Id>> groupMap=new Map<Id,List<Id>>();  
            if(!territoryGroupMap.isEmpty()){
                for(Id tId:territoryGroupMap.keySet()){
                    for(Group grpRec:[select id from group where RelatedId IN:territoryGroupMap.get(tId) and type=:GlobalConstants.TERRITORY Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        if(!groupMap.containsKey(tId)){
                            groupMap.put(tId, new List<Id>());}
                        groupMap.get(tId).add(grpRec.id);
                    }
                }
            }
            Map<Id,Id> oldcrgGcuMap=createCrgGcuMap(crgMapOld);
            Map<Id,Id> newcrgGcuMap=createCrgGcuMap(crgMap);
            Map<Id,Id> gcuGroupMapOld=new Map<Id,Id>(); 
            Map<Id,Id> gcuGroupMapNew=new Map<Id,Id>();  
            Set<Id> crgIds=new Set<Id>();
            if(!oldcrgGcuMap.isEmpty()){
                for(Id crgIdOld:oldcrgGcuMap.keySet()){
                    for(Group grpRec:[select id from group where RelatedId =: oldcrgGcuMap.get(crgIdOld) and type=:GlobalConstants.TERRITORY Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        gcuGroupMapOld.put(crgIdOld,grpRec.id);
                        crgIds.add(crgIdOld);
                    }
                }
            }
            if(!newcrgGcuMap.isEmpty()){
                for(Id crgIdNew:newcrgGcuMap.keySet()){
                    for(Group grpRec:[select id from group where RelatedId =: newcrgGcuMap.get(crgIdNew) and type=:GlobalConstants.TERRITORY Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        gcuGroupMapNew.put(crgIdNew,grpRec.id);
                        crgIds.add(crgIdNew);
                    }
                }
            }
            for(Id trrId:territoryIdSet){
                AddCrgShareRecord(groupMap.get(trrId),crgMap.get(trrId),crgMapOld.get(trrId));                
            }          
            if(!crgIds.isEmpty()){
                for(Id crgId:crgIds){
                    updateGcuShareRecord(crgId,!gcuGroupMapOld.isEmpty()?gcuGroupMapOld.get(crgId):null,!gcuGroupMapNew.isEmpty()?gcuGroupMapNew.get(crgId):null);
                }
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.updateSharing, 
                                                                                        GlobalConstants.TerritoryTriggerHelper, true, e)));}
    }    
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: territory,territoryMap
* @description: U-1921 & U-1990 This method will provide CRGs.
*****************************************************************/
    public static Map<Id,String> getCrgMapAfterCagSplit(Territory2 territory,Map<ID, Territory2> territoryMap){
        Map<Id,String> crgStringMap=new Map<Id,String>();
        try{            
            String crgIdString='';
            String cagString=territoryMap.get(territory.id).CAG__c;
            String crgString=territoryMap.get(territory.id).CRG__c;
            List<String> arrCrgString=new List<String>();
            if(!String.isBlank(crgString)){
                arrCrgString = crgString.split(GlobalConstants.COMMA);    
            }
            if(!String.isBlank(cagString)){
                String[] arrCagString = cagString.split(GlobalConstants.COMMA);
                List<Integer> arrCagInteger=new List<Integer>();
                for(String decCag:arrCagString){
                    arrCagInteger.add(Integer.valueOf(decCag));
                }
                for(CustomerReportingGroup__c crgRecOld:[select CRG_ID__c from CustomerReportingGroup__c where CustomerAccountGroup__r.CAGID__c IN :arrCagInteger Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                    if(!arrCrgString.contains(crgRecOld.CRG_ID__c)){
                        crgIdString=crgIdString+crgRecOld.CRG_ID__c+GlobalConstants.COMMA;
                    }
                }
                crgStringMap.put(territory.id,crgIdString);
            }       
        } catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.getCrgMapAfterCagSplit, 
                                                                                         GlobalConstants.TerritoryTriggerHelper, true, e)));}
        return crgStringMap;
    }
    
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: crgterritoryMap
* @description: U-1921 & U-1990 This method will provide CRGs.
*****************************************************************/
    public static Map<Id,List<Id>> getCrgMapAfterCrgSplit(Map<Id,String> crgterritoryMap){
        Map<Id,List<Id>> crgMap=new Map<Id,List<Id>>();
        try{            
            if(!crgterritoryMap.isEmpty()){
                for(Id trId:crgterritoryMap.keySet()){ 
                    String crgString=crgterritoryMap.get(trId);
                    if(!String.isBlank(crgString)){
                        String[] arrString = crgString.split(GlobalConstants.COMMA);
                        for(CustomerReportingGroup__c crgRec:[select id from CustomerReportingGroup__c where CRG_ID__c IN :arrString Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                            if(!crgMap.containsKey(trId)){
                                crgMap.put(trId, new List<Id>());
                            }
                            crgMap.get(trId).add(crgRec.id);
                        }   
                    }
                }
            }                        
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.getCrgMapAfterCrgSplit, 
                                                                                        GlobalConstants.TerritoryTriggerHelper, true, e)));}  
        return crgMap;
    }
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: crgMap
* @description: U-1921 & U-1990 This method will provide GCU with CRG map.
*****************************************************************/
    public static Map<Id,Id> createCrgGcuMap(Map<Id,List<Id>> crgMap){
        Map<Id,Id> crgGcuMap=new Map<Id,Id>();
        try{           
            for(Id trId:crgMap.keySet()){
                for(CustomerReportingGroup__c crgRec:[select id,GlobalCustomerUnit__r.Name from CustomerReportingGroup__c where
                                                      id IN:crgMap.get(trId) AND GlobalCustomerUnit__c != '' Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                                          Territory2 gCUterr=[select id from Territory2 where Name =:GlobalConstants.GCUHYPHEN+crgRec.GlobalCustomerUnit__r.Name Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                                                          crgGcuMap.put(crgRec.id,gCUterr.id);
                                                      }
            }        
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.createCrgGcuMap, 
                                                                                        GlobalConstants.TerritoryTriggerHelper, true, e)));}
        return crgGcuMap;
    }    
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: groupMap,crgMap,crgMapOld
* @description: U-1921 & U-1990 This method will delete/insert CRG sharing records.
*****************************************************************/    
    @future
    public static void AddCrgShareRecord(List<id> groupMap,List<Id> crgMap,List<Id> crgMapOld){ 
        try{
            if(crgMapOld!=null && groupMap!=null){
                List<CustomerReportingGroup__Share> crgShareListToDelete = [select id,ParentId from CustomerReportingGroup__Share where ParentId IN: crgMapOld and RowCause=:GlobalConstants.Manual and UserOrGroupId IN: groupMap Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(!crgShareListToDelete.isEmpty())
                    delete crgShareListToDelete;
            }
            List<CustomerReportingGroup__Share> crgShareListToInsert = new List<CustomerReportingGroup__Share>();
            if(crgMap!=null && groupMap!=null){
                for(Id crg: crgMap){
                    for(Id grp:groupMap){
                        CustomerReportingGroup__Share crgShare=new CustomerReportingGroup__Share();
                        crgShare.ParentId=crg;
                        crgShare.UserOrGroupId=grp;
                        crgShare.AccessLevel=GlobalConstants.Edit;
                        crgShare.RowCause=GlobalConstants.Manual;
                        crgShareListToInsert.add(crgShare);
                    }
                }    
                if(!crgShareListToInsert.isEmpty())
                    insert crgShareListToInsert;    
            }         
        } catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.AddCrgShareRecord, 
                                                                                         GlobalConstants.TerritoryTriggerHelper, true, e)));}
    }    
    /****************************************************************
* @author: Ankit Jain,Manu Singhal
* @date: 08-07-2020
* @param: crgId,groupIdNew
* @description: U-1921 & U-1990 This method will delete/insert GCU sharing record
*****************************************************************/   
    @future
    public static void updateGcuShareRecord(Id crgId, Id groupIdOld,Id groupIdNew)
    {
        try{
            if(groupIdOld!=null){
                CustomerReportingGroup__Share gcuToDelete = [select id,ParentId from CustomerReportingGroup__Share where ParentId =: crgId and RowCause=:GlobalConstants.Manual and UserOrGroupId =: groupIdOld Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(gcuToDelete != null)
                    delete gcuToDelete;   
            }
            if(groupIdNew!=null){
                CustomerReportingGroup__Share crgShare=new CustomerReportingGroup__Share();
                crgShare.ParentId=crgId;
                crgShare.UserOrGroupId=groupIdNew;
                crgShare.AccessLevel=GlobalConstants.Edit;
                crgShare.RowCause=GlobalConstants.Manual;
                insert crgShare;    
            } 
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TerritoryTriggerHelper, GlobalConstants.updateGcuShareRecord, 
                                                                                        GlobalConstants.TerritoryTriggerHelper, true, e)));}
    }
}