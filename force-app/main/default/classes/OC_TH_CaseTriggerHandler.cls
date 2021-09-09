/* Class Name : OC_TH_CaseTriggerHandler
* Description : This class handles all the trigger events for Case object. 
* Author      : IBM. 
*
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-03-16             Subashini Arulalan     U-2585 - To Add caseowners to caseteamember with respective roles
* 1.1        2021-06-08             Aayush Sachdeva        U-2773 - Initial Standard CSR Routing should be handled by Routing Rules instead of Case Assignment Rule.  
* 1.2        2021-06-09             Priyank Singh          U-2837 - Added Condition for Type and Priority
* 1.3        2021-07-13             Rishabh Sehgal         U-2947 - Partial Case Cloning for LICSR
**/

public with sharing class OC_TH_CaseTriggerHandler implements TriggerInterface{
/**************************************************************************************
* @Description :  This method updates custom fields of case object and
autocompletes case milestone completion date filed 
when Collaboration Request is created on Case object 
after inserting the record into Database.                  
* @Param          Map -Case oldMap and Map -Case newMap . 
**************************************************************************************/   
public void AfterInsert(Map<Id, SObject> newItems){ 
    Map<Id,Case> mapIdToNewCase = (Map<Id,Case>) newItems;
    Set<String> storeCaseServiceContractCLIPrioritySet = new Set<String> ();
    DateTime completionDate = System.now();
    Set<Id> setCaseId = new Set<Id>();
    Set<Id> caseSharingID = new set<ID>();
    /* Added as part of U-2585 */
    List<case> standardCSRcase = new list<Case>();
    List<Case> collaborationCSRcase = new List<Case>();
    set<Id> parentId = new set<Id>();
    //Added for U-2773 Initial Routing Rules
    Set<Id> caseTocheck = new Set<Id>();
    
    /*U-2947 || Rishabh Sehgal ||Partial Case Creation  */
    Set<Id> caseIdSetLICSR = new Set<Id>();
    
    Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getCollaborationCsrRecordType).getRecordTypeId();
    
    /* update Standard Case Remedy1,Callback1 and Solution1 fields based on service contract and priority selected during case creation. */
    if(OC_checkTriggerRecursive.runAgentTimeSpentPerDayValidationOnce()){
        for(Case cs : mapIdToNewCase.values()){  
            if(cs.RecordTypeId == standardRecordType){
                storeCaseServiceContractCLIPrioritySet.add(cs.OC_TH_ServiceContractLineItemPriority__c );
                storeCaseServiceContractCLIPrioritySet.add(cs.OC_TH_ServiceContractNullPriority__c);
                /* U-2585 ownerId check for StdCSR case */
                if(cs.OwnerId != null && !cs.OC_TH_Standard_CSR_Assignment_Check__c){
                    standardCSRcase.add(cs);
                }
                /*U-2947 || Rishabh Sehgal || Adding case to set id LICSR check is enabled on Case  */
                if(cs.OC_TH_LI_CSR__c){
                    caseIdSetLICSR.add(cs.Id);
                /*Added by Aishwarys - Share Case with public group */
                    caseSharingID.add(cs.Id);
                }
                /*U-2773 || Aayush Sachdeva || Adding case to set, if Assignment checkbox field is true */
                if(cs.OC_TH_Standard_CSR_Assignment_Check__c||cs.OC_TH_LI_CSR__c){
                    caseTocheck.add(cs.Id);
                }
            }            
            /* This logic automatically updates 'CALLBACK1' Milestone object completion date field after collaboration case is created  */ 
            if(cs.RecordTypeId == collaborationRecordType && cs.ParentId != null){ 
                setCaseId.add(cs.ParentId);
                /* U-2585 ownerId check for collaboration CSR case*/
                if(cs.OwnerId !=null){
                    collaborationCSRcase.add(cs);
                    parentId.add(cs.ParentId);
                }
            }
        }
        /*OC_TH_CaseMilestoneHelper class is used for updating milestone SLA */  
        if(!storeCaseServiceContractCLIPrioritySet.isEmpty()){    
            OC_TH_CaseMilestoneHelper.updateServiceMilestoneValuesOnCase(mapIdToNewCase,storeCaseServiceContractCLIPrioritySet);
        } 
        /*OC_TH_CaseMilestoneHelper class is used for updating milestone completion date.*/ 
        if (!setCaseId.isEmpty()){
            OC_TH_CaseMilestoneHelper.completeMilestone(setCaseId, OC_TH_Constants.getCallback1Milestone, completionDate);            
        }
        /*U-2585 - Subashini Arulalan - OC_TH_CaseTeamMember class is used to add the owner in caseTeamMember with respective role for standard/collaboration CSRs*/
        if (!standardCSRcase.isEmpty()){
            OC_TH_CaseTeamMember.standardCSRInsertCheck(standardCSRcase);
        }
        if (!collaborationCSRcase.isEmpty()){
            OC_TH_CaseTeamMember.CollaborationCSRInsertCheck(collaborationCSRcase,parentId);
        }
        
       
        /*U-2773 || Aayush Sachdeva || OC_TH_CaseAssignmentHelper class is used to assign case to a queue as per the matching Routing Rule */
        if(!caseTocheck.isEmpty()){
            OC_TH_CaseAssignmentHelper.caseQueueAssignment(caseTocheck);
        }
         /*sharing case recrd with Account billing country public group */
         if(!caseSharingID.isEmpty()){
            OC_SystemUtility.shareCaseWithPublicGroup(caseSharingID);
        }  
         
        if(newItems.values().size() > 0){
            OC_TH_CaseCheckLI_CSR.sendEmailtoPublicGroup(newItems);
        }
        /*U-2947 || Rishabh Sehgal || OC_TH_CaseMirroringLICSR.partialCaseClone is used to create the Partial copy of LICSR case  */
        if(!caseIdSetLICSR.isEmpty()){
            OC_TH_CaseMirroringLICSR.partialCaseClone(caseIdSetLICSR);
        }
    }   
}

/**************************************************************************************
* @Description :  This method updates custom fields of case object and
autocompletes case milestone completion date filed 
when case prioty or Type or Status field value
is updated on Case object after updating 
the record into Database.                  
* @Param          Map -Case oldMap and Map -Case newMap . 
**************************************************************************************/    
public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
    Map<Id,Case> mapIdToNewCase = (Map<Id,Case>) newItems;
    Map<Id,Case> mapIdToOldCase = (Map<Id,Case>) oldItems;
    Set<String> storeCaseServiceContractCLIPrioritySet = new Set<String> ();
    Set<Id> setCaseId = new Set<Id>(); 
    DateTime completionDate = System.now();
    Map<Id,Case> storeCaseMap= new Map<Id,Case>();
    Map<id,String> caseMap = new Map<id,String>();
    /* Added as part of U-2585 */
    List<Case> caseList = new List<Case>();
    set<id> parentId = new Set<id>();
    Set<Id> caseSharingID = new set<ID>();
    Map<Id,Case> statusChangeMap = new Map<id,case>();
    
    /*U-2974 || Rishabh Sehgal || Mirroring Of Parent LICSR to PVCSR  */
    Set<Id> caseIdSetLICSR = new Set<Id>();
    Id liCsrRecordTypeId = OC_TH_Constants.recordType_PartialCSR;
    Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Set<Id> caseIdSet = new Set<Id>();
    Set<Id> liOwnerQueueId = new Set<Id>();
    /* Added as part of U-2585 */
    Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getCollaborationCsrRecordType).getRecordTypeId();
    if(OC_checkTriggerRecursive.runAgentTimeSpentPerDayValidationOnce()){ 
        for(Case cs : mapIdToNewCase.values()){
            Case oldCaseValue = mapIdToOldCase.get(cs.Id);
            if(cs.RecordTypeId == standardRecordType){
                //(oldCaseValue != Null && oldCaseValue.OC_TH_Service_Contract__c == Null) ||
                if((cs.OC_TH_Installed_Base_Item__c != oldCaseValue.OC_TH_Installed_Base_Item__c || (cs.OC_TH_Service_Contract__c != oldCaseValue.OC_TH_Service_Contract__c && cs.OC_TH_Service_Contract__c != Null) || cs.Priority != oldCaseValue.Priority)){
                    storeCaseServiceContractCLIPrioritySet.add(cs.OC_TH_ServiceContractLineItemPriority__c );
                    storeCaseServiceContractCLIPrioritySet.add(cs.OC_TH_ServiceContractNullPriority__c);
                    /*storeCaseMap hold cases to update Service milestone SLA*/
                    storeCaseMap.put(cs.Id,cs); 
                    /*updating the MilestoneAlert field on Kanban view based on case priority */
                    caseMap.put(cs.id,cs.Priority); 
                }  
                if(cs.OC_TH_LI_CSR__c){
                    caseSharingID.add(cs.Id);
                }
                /* Check case status/Priority/Type with old values and milestone completion date with SLAStartDate and SLAExitDate */                       
                if((oldCaseValue != Null && !cs.Status.equalsIgnoreCase(oldCaseValue.Status) || !cs.Type.equalsIgnoreCase(oldCaseValue.Type) || !cs.Priority.equalsIgnoreCase(oldCaseValue.Priority)) && 
                    ((cs.SlaStartDate <= completionDate)&&(cs.SlaExitDate == null))){
                        setCaseId.add(cs.Id);  
                    }
                /* U-2585 checks whether ownerId is changed for StdCSR*/
                if(cs.OwnerId != oldCaseValue.OwnerId && cs.OwnerId != null ){
                    caseList.add(cs);
                    parentId.add(cs.id);
                }
            }
            /*U-2974 || Rishabh Sehgal || Adding in the set if RecordtypeId is liCsrRecordTypeId or standardRecordType */
            if(cs.RecordTypeId == liCsrRecordTypeId || cs.RecordTypeId == standardRecordType){
                caseIdSetLICSR.add(cs.Id);
            } 
            /*D-4191 || Rishabh Sehgal || Creating set for ownerId if queue and respective caseId*/
            if((cs.RecordTypeId == collaborationRecordType || cs.RecordTypeId == standardRecordType) && cs.OC_TH_LI_CSR__c && cs.OwnerId != oldCaseValue.OwnerId && String.ValueOf(cs.OwnerId).startsWith(OC_TH_Constants.standardGroupIdPrefix) ){
                caseIdSet.add(cs.Id);
                liOwnerQueueId.add(cs.OwnerId);
            }
            /* U-2585 checks whether ownerId is changed or case is closed for collaborationCSR */
            if(cs.RecordTypeId == collaborationRecordType && cs.ParentId != null && cs.OwnerId != null){
                if(cs.OwnerId != oldCaseValue.OwnerId || (cs.IsClosed != oldCaseValue.IsClosed && cs.IsClosed == True)){
                    caseList.add(cs);
                    parentId.add(cs.parentId);}
            }
        }
        /* update Standard Case Remedy1,Callback1 and Solution1 fields. */  
        if(!storeCaseServiceContractCLIPrioritySet.isEmpty()){
            OC_TH_CaseMilestoneHelper.updateServiceMilestoneValuesOnCase(storeCaseMap,storeCaseServiceContractCLIPrioritySet);
        }
        /*OC_TH_CaseMilestoneHelper class is used for updating milestone completion date.*/
        if (!setCaseId.isEmpty()){
            OC_TH_CaseMilestoneHelper.completeMilestone(setCaseId, OC_TH_Constants.getCallback1Milestone, completionDate);            
        } 
        /** US-2224 - Subashini Arulalan - updating the MilestoneAlert field based on milestone Remaning time **/
        if(!caseMap.isEmpty()) {
            OC_TH_CaseMilestoneHelper.updateMilestoneAlertOnCase(caseMap);
        }
        /*Aishwarya - Sharing LI-case record with Account billing country public group */
         if(!caseSharingID.isEmpty()){
            OC_SystemUtility.shareCaseWithPublicGroup(caseSharingID);    
        }
        /*U-2585 - Subashini Arulalan - OC_TH_CaseTeamMember class is used to add/update the owner in caseTeamMember with respective role for standard/collaboration CSRs */
        if(!caseList.isEmpty()){
            OC_TH_CaseTeamMember.caseUpdateCheck(caseList,mapIdToOldCase,parentId);
           // OC_TH_CaseCheckLI_CSR.caseCheckLI_CSR(caseList);
        } 
        /*D-4191 || Rishabh Sehgal || OC_TH_CaseMirroringLICSR.ownerQueueChangeLICSR if LICSR is routed to any queue then it will change the ownership to LICSR Queue but latesque remains as routed*/
        if(!caseIdSet.isEmpty()){
            OC_TH_CaseMirroringLICSR.ownerQueueChangeLICSR(caseIdSet,liOwnerQueueId);
        }
        
        if(!caseIdSetLICSR.isEmpty()){
            OC_TH_CaseMirroringLICSR.caseMirroringOnUpdate(caseIdSetLICSR,mapIdToOldCase);
        }
	} 
    /*if(OC_checkTriggerRecursive.runLICSRMirroringValidationOnce()){ 
        for(Case cs : mapIdToNewCase.values()){
            if(cs.RecordTypeId == standardRecordType && cs.OC_TH_LI_CSR__c){
                caseIdSetLICSR.add(cs.Id);
            }
        }
        if(!caseIdSetLICSR.isEmpty()){
            OC_TH_CaseMirroringLICSR.caseMirroringOnUpdate(caseIdSetLICSR,mapIdToOldCase);
        }
    }*/
}
/**************************************************************************************
* @Description :  This method populates custom fields of case object from Main Asset Type field
on Case object before inserting the record into Database.                  
* @Param          List -Case newMap . 
**************************************************************************************/    
    public void BeforeInsert(List<SObject> newItems){
    List<Case> caseList = (List<Case>) newItems;
    List<Case> caseToBeUpdated = new List<Case>();
    for(Case cas:caseList){
        if(cas.OC_TH_Main_Asset_Type__c != null){
            caseToBeUpdated.add(cas);
            }
            OC_TH_CaseAssignmentHelper.updateCaseWithAssetFields(caseToBeUpdated);
    }

    for(Case cas:caseList){
        if(cas.Priority != OC_TH_Constants.getlowPriority && cas.Type == OC_TH_Constants.getTypeConsultation){
                cas.addError(System.Label.OC_TH_ErrorMessage_Type_Consultation_Priority_Low);
            }     
    }
}
/**************************************************************************************
* @Description :  This method updates custom fields of case object before saving the record 
into Database whenever Asset field on Case object is updated.                  
* @Param          Map -Case oldMap and Map -Case newMap .  
**************************************************************************************/     
public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    
     Map<Id,Case> newCaseMap = (Map<Id,Case>) newItems;
    Map<Id,Case> oldCaseMap = (Map<Id,Case>) oldItems;
    list<case> lstCase = new list<case>();
    Map<id,Case> foraccesingLookupMap = new Map<id,Case>([select id, OC_TH_Service_Contract__r.OC_CSM_Contract_Type__c from case where id in :newItems.keyset()] );
    Map<id,Case> foraccesingLookupMapold = new Map<id,Case>([select id, OC_TH_Service_Contract__r.OC_CSM_Contract_Type__c from case where id in :oldItems.keyset()] );
    map<id,id> mapCaseParentOwner = new map<id,id>();
    List<Case> caseToBeUpdated = new List<Case>();
    set<id> setParentId = new set<id>();
    set<Id> liCaseIdSet = new set<Id>();
    
    for(Case cas: newCaseMap.values()){
        if(cas.AssetId != oldCaseMap.get(cas.id).Assetid && cas.OC_TH_Main_Asset_Type__c != null){
            caseToBeUpdated.add(cas);
        }
        OC_TH_CaseAssignmentHelper.updateCaseWithAssetFields(caseToBeUpdated);
        if(cas.OC_TH_LI_CSR__c != oldCaseMap.get(cas.id).OC_TH_LI_CSR__c && cas.OC_TH_LI_CSR__c){
            lstCase.add(cas);
        }
        if(cas.parentid != null){
            setParentId.add(cas.parentid);
        }
    }
    if(!lstCase.isEmpty()){
        OC_TH_CaseCheckLI_CSR.caseCheckLI_CSR(lstCase);
    }
    for(Case cas: newCaseMap.values()){
        if(cas.Type == OC_TH_Constants.getTypeConsultation){
            cas.Priority = OC_TH_Constants.getlowPriority;                       
        }
    }
    for(case objCase : [select id,OC_TH_Case_Number__c,ownerid from case where id =: setParentId AND OC_TH_Case_Number__c != null]){
        if(setParentId.contains(objCase.id)){
            String caseNumber = objCase.OC_TH_Case_Number__c;
            if(caseNumber.startsWith(OC_TH_Constants.getSTA)){    
                 mapCaseParentOwner.put(objCase.id,objCase.ownerid);
            }
        }
    }
    for(Case objCase: newCaseMap.values()){
        if(foraccesingLookupMap != null && foraccesingLookupMap.get(objCase.id) != null ){      
            if(foraccesingLookupMap.get(objCase.id).OC_TH_Service_Contract__r.OC_CSM_Contract_Type__c == System.Label.OC_TH_BasicProductSupport && objCase.Type != OC_TH_Constants.getTypeProblem ){
                    objCase.addError(System.Label.OC_TH_ErrorMessage_Type_Problem_SC_Basic);
            } 
        }
        if(objCase.OC_TH_Case_Number__c != null){
            String caseNumber = objCase.OC_TH_Case_Number__c;
            if(caseNumber.startsWith(OC_TH_Constants.getPVC) && mapCaseParentOwner.get(objCase.parentid) != objCase.ownerid && OC_checkTriggerRecursive.ownerForPVC()){  
                 objCase.addError(System.Label.OC_TH_ErrorMessage_PartialView_Cannot_Change_Owner);
            }
            /*D-4191 || Rishabh Sehgal || Creating set to check validation on Owner/contact for LICSR*/
            if(objCase.OC_TH_LI_CSR__c && caseNumber.startsWith(OC_TH_Constants.getSTA) && (objCase.OwnerId != oldCaseMap.get(objCase.id).OwnerId || objCase.ContactId != oldCaseMap.get(objCase.id).ContactId)){
                liCaseIdSet.add(objCase.Id);
            }
        }
    }
    /*D-4191 || Rishabh Sehgal || OC_TH_CaseMirroringLICSR.ownerContactChangeValidation : Validation on change of owner to any user/contact other then LI User/Contact*/
    if(!liCaseIdSet.isEmpty()){
        OC_TH_CaseMirroringLICSR.ownerContactChangeValidation(newCaseMap,oldCaseMap,liCaseIdSet);
    }
}   

public void BeforeDelete(Map<Id, SObject> oldItems){}

public void AfterDelete(Map<Id, SObject> oldItems){}

public void AfterUndelete(Map<Id, SObject> oldItems){}
}