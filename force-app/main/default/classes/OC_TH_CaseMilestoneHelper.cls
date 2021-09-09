/* Class Name : OC_TH_CaseMilestoneHelper
* Description : This class handles CaseMilestone logic.
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 19 Jan 2021
* @Modification Log   : 
*==============================================================================completeMilestone
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-01-19                 IBM                   Initial Version
* 1.1        2021-03-18          Subashini Arulalan          D-3620 Modified as part of defect
**/ 
public with sharing class OC_TH_CaseMilestoneHelper {
    /****************************************************************************************
@ Description : This method handles auto-closure of the milestone by passing 
CaseId,Milestone Name and Milestone completion date.
***************************************************************************************/
    public static void completeMilestone(Set<Id> caseIds,String milestoneName, DateTime completeDate) {
        
        List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
        try{
            for (CaseMilestone cm : [SELECT Id,caseId,completionDate FROM CaseMilestone caseMilestone WHERE caseId IN: caseIds 
                                     AND caseMilestone.MilestoneType.Name =:milestoneName  AND completionDate = null]){
                                         cm.CompletionDate = completeDate;
                                         cmsToUpdate.add(cm) ;                          
                                     }   
            update cmsToUpdate;
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseMilestoneUtils,OC_TH_Constants.method_completeMilestone,null, false, e));
        } 
    }
    
    /****************************************************************************************
@ Description : This method restarts the CaseMilestone by passing 
CaseId and Milestone Name.
***************************************************************************************/
    
    public static void startMilestone(Set<Id> caseIds,string milestoneName) {
        
        List<CaseMilestone> cmsToUpdate = new List<CaseMilestone>();
        try{
            for(CaseMilestone cm : [SELECT Id,caseId,completionDate,caseMilestone.MilestoneType.Name FROM CaseMilestone caseMilestone WHERE caseId =: caseIds 
                                    AND caseMilestone.MilestoneType.Name=:milestoneName AND completionDate != null]){  
                                        System.debug('Case milsetone :--' +cm);
                                        cm.CompletionDate = null;
                                        cmsToUpdate.add(cm);                                
                                    }
            update cmsToUpdate;  
            System.debug('cmsToUpdate:--' +cmsToUpdate);
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseMilestoneUtils,OC_TH_Constants.method_startMilestone,null, false, e));
        } 
    }
    
    /****************************************************************************************
@ Description : This method checks the combination of Service Contract,CLI and Priority 
on case record with Service milestone record object and 
updates the case custom field Remedy1,Callback1 and Solution1.
***************************************************************************************/  
    public static void updateServiceMilestoneValuesOnCase(Map<Id,Case> newMapItem ,Set<String> storeCaseServiceContractCLIPriority){
        Map<Id,Case> mapIdToNewCase = (Map<Id,Case>) newMapItem;
        Map<String,OC_TH_Service_Milestone__c> mapKeyServiceMilestone = new Map<String,OC_TH_Service_Milestone__c>();
        List<Case> caseList = new List<Case>();
        try{
            for(OC_TH_Service_Milestone__c serviceMilestone : [SELECT ID,OC_TH_Priority__c,OC_TH_Service_Contract__c,OC_TH_ServiceContractLineItemPriority__c,OC_TH_Contract_Line_Item__c,OC_TH_Remedy1__c,OC_TH_Solution1__c,OC_TH_CallBack1__c FROM OC_TH_Service_Milestone__c
                                                               WHERE OC_TH_ServiceContractLineItemPriority__c IN:storeCaseServiceContractCLIPriority ]){
                                                                   mapKeyServiceMilestone.put(serviceMilestone.OC_TH_ServiceContractLineItemPriority__c,serviceMilestone);
                                                               }
            for(Case cs : mapIdToNewCase.values()){
                Case caseRec = new Case(Id = cs.Id);
                /*If condiditon checks service milestone contains the key and updates the value of case custom fields.*/
                if(!mapKeyServiceMilestone.isEmpty() && mapKeyServiceMilestone.containsKey(cs.OC_TH_ServiceContractLineItemPriority__c)){ 
                    caseRec.OC_TH_Remedy1__c = mapKeyServiceMilestone.get(cs.OC_TH_ServiceContractLineItemPriority__c).OC_TH_Remedy1__c;
                    caseRec.OC_TH_Solution1__c = mapKeyServiceMilestone.get(cs.OC_TH_ServiceContractLineItemPriority__c).OC_TH_Solution1__c;
                    caseRec.OC_TH_CallBack1__c = mapKeyServiceMilestone.get(cs.OC_TH_ServiceContractLineItemPriority__c).OC_TH_CallBack1__c;
                    caseList.add(caseRec); 
                }
                else if(!mapKeyServiceMilestone.isEmpty() && mapKeyServiceMilestone.containsKey(cs.OC_TH_ServiceContractNullPriority__c)){
                    caseRec.OC_TH_Remedy1__c = mapKeyServiceMilestone.get(cs.OC_TH_ServiceContractNullPriority__c).OC_TH_Remedy1__c;
                    caseRec.OC_TH_Solution1__c = mapKeyServiceMilestone.get(cs.OC_TH_ServiceContractNullPriority__c).OC_TH_Solution1__c;
                    caseRec.OC_TH_CallBack1__c = mapKeyServiceMilestone.get(cs.OC_TH_ServiceContractNullPriority__c).OC_TH_CallBack1__c;
                    caseList.add(caseRec);    
                }
                else{
                    caseRec.OC_TH_Remedy1__c = '';
                    caseRec.OC_TH_Solution1__c = '';
                    caseRec.OC_TH_CallBack1__c = '';
                    caseList.add(caseRec);    
                } 
            }
            update caseList;    
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseMilestoneUtils,OC_TH_Constants.method_updateCaseMilestoneValuesOnCase,null, false, e));
        }   
    }
    /*** US-2224 - Subashini Arulalan - added New Method for Milestone Alert update ***/
    @future
    public static void updateMilestoneAlertOnCase (Map<Id,String> caseValues) {
        Map<String, OC_TH_WarningTimeAction__c> mapTime = OC_TH_WarningTimeAction__c.getAll();
        System.debug('Custom setting values get all :-'+mapTime);
        Map<id,List<CaseMilestone>> mapCaseMilestone = new Map<id,List<CaseMilestone>>();
        System.debug('Map case milestone :--' +mapCaseMilestone);
        List<Case> caseListupdate = new List<Case>();
        try
        {
            for(CaseMilestone milestone:[select id,TimeRemainingInMins,MilestoneType.name,CaseId,case.Priority from CaseMilestone where CaseId IN:caseValues.Keyset()])			
            {
                System.debug('milestone with caseId:--' +milestone);
                if(mapCaseMilestone.containsKey(milestone.CaseId))
                {
                    List<CaseMilestone> exisitingList = mapCaseMilestone.get(milestone.CaseId);
                    exisitingList.add(milestone);
                    mapCaseMilestone.put(milestone.CaseId,exisitingList);
                    System.debug('exisitingList of mapCaseMilestone'+mapCaseMilestone);
                }
                else
                {
                    List<CaseMilestone> newList = new list<CaseMilestone>();
                    newList.add(milestone);
                    mapCaseMilestone.put(milestone.CaseId,newList);
                      System.debug('newList of mapCaseMilestone'+mapCaseMilestone);
                }
            }
            for(Id caseId:caseValues.keyset())
            {
                if(!mapCaseMilestone.isempty() && mapCaseMilestone.containsKey(caseId) ) {
                    System.debug('Check if condition of  mapCaseMilestone:--'+mapCaseMilestone);
                    Case caseRec = new Case(Id = caseId);
                    String casePriority = caseValues.get(caseId);
                    for(CaseMilestone caseMil:mapCaseMilestone.get(caseId)){
                        System.debug('Case Priority :--'+casePriority);
                        System.debug('Case milestone of hogh value :--'+caseMil.MilestoneType.Name);
                        if(casePriority.equals(OC_TH_Constants.getEmergencyPriority) && caseMil.MilestoneType.name.equals(OC_TH_Constants.getRemedy1Milestone))
                        {
                            String Miltime = caseMil.TimeRemainingInMins;  
                            String timeRemainingMins = Miltime.substring(0, Miltime.indexOf(':'));
                            if(Integer.Valueof(timeRemainingMins) > mapTime.get(OC_TH_Constants.getEmgTime).Minutes__c)
                                System.debug('Pass:--');
                            {
                                caseRec.OC_TH_Milestone_Alert__c = OC_TH_Constants.getMilestoneAlertGreen;
                                caseListupdate.add(caseRec);
                            }
                        }
                        else if(casePriority.equals(OC_TH_Constants.getHighPriority) && caseMil.MilestoneType.name.equals(OC_TH_Constants.getSolution1Milestone))
                        {
                            String Miltime = caseMil.TimeRemainingInMins;
                            String timeRemainingMins = Miltime.substring(0, Miltime.indexOf(':'));
                            System.debug('case milestone high :--'+timeRemainingMins);
                             System.debug('Custom setting values high :-'+ mapTime.get(OC_TH_Constants.getHighTime).Minutes__c);
                            if(Integer.Valueof(timeRemainingMins) > mapTime.get(OC_TH_Constants.getHighTime).Minutes__c)
                            {
                                caseRec.OC_TH_Milestone_Alert__c = OC_TH_Constants.getMilestoneAlertGreen;
                                caseListupdate.add(caseRec);
                            }
                        }
                        else if(casePriority.equals(OC_TH_Constants.getMediumPriority) && caseMil.MilestoneType.name.equals(OC_TH_Constants.getSolution1Milestone))
                        {
                            String Miltime = caseMil.TimeRemainingInMins;
                            String timeRemainingMins = Miltime.substring(0, Miltime.indexOf(':'));
                             System.debug('case milestone medium time :--'+timeRemainingMins);
                             System.debug('Custom setting values medium :-'+mapTime.get(OC_TH_Constants.getMediumTime).Minutes__c);
                            if(Integer.Valueof(timeRemainingMins) > mapTime.get(OC_TH_Constants.getMediumTime).Minutes__c)
                            {
                                caseRec.OC_TH_Milestone_Alert__c = OC_TH_Constants.getMilestoneAlertGreen;
                                caseListupdate.add(caseRec);
                            }
                        }
                        else if(casePriority.equals(OC_TH_Constants.getlowPriority) && caseMil.MilestoneType.name.equals(OC_TH_Constants.getSolution1Milestone))
                        {
                            String Miltime = caseMil.TimeRemainingInMins;
                            String timeRemainingMins = Miltime.substring(0, Miltime.indexOf(':'));
                            if(Integer.Valueof(timeRemainingMins) > mapTime.get(OC_TH_Constants.getLowTime).Minutes__c)
                            {
                                caseRec.OC_TH_Milestone_Alert__c = OC_TH_Constants.getMilestoneAlertGreen;
                                caseListupdate.add(caseRec);
                            }
                        }
                    }
                }
            }
            
            update caseListupdate;      
            
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseMilestoneUtils,OC_TH_Constants.method_updateMilestoneAlertOnCase,null, false, e));
        }   
        
    }
     
}