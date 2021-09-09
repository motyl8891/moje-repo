/*
* @File Name          : OC_TH_CaseMirroringLICSR
* @Description        : This class handles the Partial LICSR functionality logic as to create Clone and mirroring of new LICSR
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 02th July 2021 
* @Parameters		  : caseId - Set of Case ID on which LICSR is enabled(Partial case creation Or Mirroring).
					  : oldMap - Contains key value pair for Id and Old Case records before Update.
					  : fieldSet - Pertains to the API name of field set used to get fields for mirroring
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-13             Rishabh Sehgal         U-2947 - Partial Case Cloning for LICSR
*/
public with sharing class OC_TH_CaseMirroringLICSR {
    /***********************************************************************************************
    @ Description : This method handles to Clone new LICSR(cases) and create Partial View CSR(cases)
    ***********************************************************************************************/
        public static void partialCaseClone(set<Id> caseId){ 
            
            try{
                Id devRecordTypeId = OC_TH_Constants.recordType_PartialCSR;
                Id standardRecordType = OC_TH_Constants.recordType_StandardCSR;
                Set<Id> setParentId = new Set<Id>();
                List<Case> cloneCaseObject = new List<case>();
                Map<Id,Case> mapParentIdToClonedCase = new Map<Id,Case>();
                Map<Id,String> newcaseRecordtype = new Map<Id,String>();
                List<String> caseFieldNames = fieldApiList(System.Label.OC_TH_LICSRCaseCloningFieldSet);
                if(caseFieldNames.size() > 0){
                    String query = 'Select ' + String.join( caseFieldNames, ',' ) + ',Asset.Product2Id,Asset.OC_MD_Release__c,Asset.Product2.Name,Asset.OC_MD_Release__r.Name,Asset.OC_MD_Version__c From Case Where RecordTypeId =: standardRecordType AND Id =: caseId';
                    
                    for(Case caseRecord : Database.query(query)){
                        mapParentIdToClonedCase.put(caseRecord.Id,caseRecord);
                    }
                    
                    if(!mapParentIdToClonedCase.isEmpty()){
                        for(Case caseRec : mapParentIdToClonedCase.values()){
                            
                            if(String.isNotBlank(caseRec.Id)  && caseRec.OC_TH_LI_CSR__c == True && caseRec.RecordTypeId == standardRecordType){
                                Case objCaseClone  = caseRec.clone(false, false, false, false);
                                objCaseClone.recordtypeId = devRecordTypeId;
                                objCaseClone.ParentId = caseRec.Id;
                                objCaseClone.AssetId = null;
                                if(caseRec.AssetId != null){
                                    objCaseClone.OC_TH_Product_Details__c = productDetailFieldUpdate(caseRec);
                                }
                                cloneCaseObject.add(objCaseClone);
                            }
                        }
                    }
                }
                if( cloneCaseObject.size() > 0 ){
                    OC_checkTriggerRecursive.ownerForPVC();
                    insert cloneCaseObject;
                }
            }
            catch(Exception e){
                EventLog.createLog(new EventLog.Error(OC_TH_Constants.apexClass_CaseMirroringLICSR,OC_TH_Constants.method_partialCaseClone,null, false, e));
            }
        }
        /***********************************************************************************************************
    @ Description : This method handles to Mirroring of Cloned cases i.e the Partial view CSR from Parect LICSR.
    ***********************************************************************************************************/
        public static void caseMirroringOnUpdate(Set<Id> caseId, Map<Id,Case> oldMap){
            
            try{
                Id devRecordTypeId = OC_TH_Constants.recordType_PartialCSR;
                Id standardRecordType = OC_TH_Constants.recordType_StandardCSR;
                Set<Id> newCaseSet = new Set<Id>();
                Map<Id,Case> parentCaseMap = new Map<Id,Case>();
                Set<Id> assetUpdateSet = new Set<Id>();
                List<Case> updateCaseList = new List<Case>();
                List<String> caseFieldNames = fieldApiList(System.Label.OC_TH_LICSRCaseCloningFieldSet);
                
                if(caseFieldNames.size() > 0){
                    String queryNewCase = 'Select ' + String.join( caseFieldNames, ',' ) + ',OC_TH_Case_Number__c,Asset.Product2.Name,Asset.OC_MD_Release__r.Name,Asset.OC_MD_Version__c From Case Where Id =: caseId';
                    
                    for(Case caseObj : Database.query(queryNewCase))
                    {
                        Case oldCaseObj = oldMap.get(caseObj.Id);
                        if (!oldCaseObj.OC_TH_LI_CSR__c && caseObj.OC_TH_LI_CSR__c)
                        {
                            newCaseSet.add(caseObj.Id);
                        }
                        else if(oldCaseObj.OC_TH_LI_CSR__c && caseObj.OC_TH_LI_CSR__c)
                        {	
                            if(!String.isBlank(caseObj.OC_TH_Case_Number__c) && caseObj.OC_TH_Case_Number__c.startsWith(OC_TH_Constants.getSTA)) 
                            {
                                parentCaseMap.put(caseObj.Id,caseObj);
                                if(oldCaseObj.AssetId != caseObj.AssetId){
                                    assetUpdateSet.add(caseObj.Id);
                                }
                            } 
                        }
                   }
                    if(!parentCaseMap.isEmpty())
                    {	
                        List<String> lstOfFields = fieldApiList(System.Label.OC_TH_LICSRMirroringFieldSet);
                        Set<Id> setParentCaseId = parentCaseMap.keySet();
                        if(lstOfFields.size() > 0){
                            String query ='Select '+ string.join(lstOfFields,',') + ',OC_TH_Product_Details__c,AssetId,ParentId from Case Where parentId IN: setParentCaseId' ;
                            List<Case> partialCaseList = OC_SystemUtility.GetPartiaViewCaseList(setParentCaseId,query);
                            for(Case caseChildObj : partialCaseList)
                            {
                                Case newCaseObj = parentCaseMap.get(caseChildObj.parentId);
                                Boolean updateCase = false;
                                for(String fieldApi : lstOfFields){
                                    if((caseChildObj.get(fieldApi) != newCaseObj.get(fieldApi)) && fieldApi != OC_TH_Constants.assetLiteral)
                                    {
                                        caseChildObj.put(fieldApi, newCaseObj.get(fieldApi));
                                        updateCase = true;
                                    }
                                }
                                if(assetUpdateSet.contains(caseChildObj.parentId) && newCaseObj != null){
                                    String productDetailStr = '';
                                    if(newCaseObj.get(OC_TH_Constants.assetLiteral) != null){
                                        productDetailStr = productDetailFieldUpdate(newCaseObj);
                                    }else{
                                        productDetailStr = '';
                                    }
                                    caseChildObj.put(OC_TH_Constants.productDetailLiteral,productDetailStr);
                                    updateCase = true;
                                }
                                if(updateCase)
                                    updateCaseList.add(caseChildObj);
                            }
                        }
                    }
                    
                    if(updateCaseList.size() > 0){
                        OC_SystemUtility.updatePartiaViewCaseList(updateCaseList);
                    }
                    if(newCaseSet.size() > 0){
                        OC_TH_CaseMirroringLICSR.partialCaseClone(newCaseSet);
                    }
                }
            }
            catch(Exception e){
                EventLog.createLog(new EventLog.Error(OC_TH_Constants.apexClass_CaseMirroringLICSR,OC_TH_Constants.method_caseMirroringOnUpdate,null, false, e));
            }
        }
        
    /**********************************************************************************************************************
    @ Description : This Method is used to fetch List of field API name from respective field set that needs to be mirrored
    ***********************************************************************************************************************/
        public static List<String> fieldApiList(String fieldSet){
            List<String> lstOfFields = new List<String>();
            Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(OC_TH_Constants.caseLiteral);
            Schema.DescribeSObjectResult desSObjRslt = sObjType.getDescribe();     
            Map<String, Schema.SObjectField> caseFieldMap = desSObjRslt.fields.getMap();
            if(String.isNotBlank(fieldSet)){
                Schema.FieldSet fieldSetIns = desSObjRslt.FieldSets.getMap().get(fieldSet);
                if(fieldSetIns != null){
                    for( Schema.FieldSetMember fieldSetMember : fieldSetIns.getFields() ){
                        String fieldApi = String.valueOf(fieldSetMember.getFieldPath());
                        if(caseFieldMap.get(fieldApi).getDescribe().isUpdateable())
                            lstOfFields.add(fieldApi);
                    } 
                }
            }
            return lstOfFields;
        }
        
    /*************************************************************************************************************
    @ Description : This Method replicated the purpose of formula field on OC_TH_Product_Detail__c field of case
     to populate data if change in Asset or new case
    **************************************************************************************************************/
        public static String productDetailFieldUpdate(Case caseRec){
            String productDetailStr = '';
            if(caseRec.Asset.Product2Id != null && caseRec.Asset.Product2.Name != null){
                productDetailStr = caseRec.Asset.Product2.Name + ':';
            }else{
                productDetailStr = ':';
            }
            if(caseRec.Asset.OC_MD_Release__c != null && caseRec.Asset.OC_MD_Release__r.Name != null){
                productDetailStr = productDetailStr + caseRec.Asset.OC_MD_Release__r.Name + ':';
            }else{
                productDetailStr = productDetailStr +':';
            }
            if(caseRec.Asset.OC_MD_Version__c != null){
                productDetailStr = productDetailStr + caseRec.Asset.OC_MD_Version__c;
            }
            return productDetailStr;
        }

 /************************************************************************************************************************
@ Description : This Method Validates whether selected contact or Account of LICSR is Valid LI User or else throws error.
************************************************************************************************************************/
public static void ownerContactChangeValidation(Map<Id,Case> newCaseMap,Map<Id,Case> oldCaseMap,Set<Id> CaseIdSet){
    try{
        String standardRecordType = String.ValueOf(OC_TH_Constants.recordType_StandardCSR);
        set<Id> ericssonLIContactSet = new set<Id>();
        String recordOwnerId;
        Set<Id> ericssonLiUserSet = (new Map<Id,SObject>([SELECT Id,Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =: 
                                                                                                OC_TH_Constants.permissionSetEricssonLI)
                                                          AND IsActive=true])).keySet();
        for (User UserObj : [SELECT Id,Name,contactId FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name =: 
                                                                             OC_TH_Constants.getEricssonLiCommunityUserPermissionSet)
                             AND IsActive=true AND contactId != null])
        {
            ericssonLIContactSet.add(UserObj.contactId);
        }
        for(Id caseId : CaseIdSet){
            recordOwnerId = String.ValueOf(newCaseMap.get(caseId).OwnerId);
            if(standardRecordType.equalsIgnoreCase(String.ValueOf(newCaseMap.get(caseId).RecordTypeId)) && !ericssonLiUserSet.isEmpty() && !recordOwnerId.startsWith(OC_TH_Constants.standardGroupIdPrefix) && !ericssonLiUserSet.contains(recordOwnerId) && !recordOwnerId.equalsIgnoreCase(oldCaseMap.get(caseId).OwnerId)){    
                newCaseMap.get(caseId).addError(System.Label.OC_TH_CaseOwnerChangeValidation_LICSR);
            }
            if(standardRecordType.equalsIgnoreCase(String.ValueOf(newCaseMap.get(caseId).RecordTypeId)) && !ericssonLIContactSet.isEmpty() && newCaseMap.get(caseId).ContactId != null && !ericssonLIContactSet.contains(newCaseMap.get(caseId).ContactId) && newCaseMap.get(caseId).ContactId != oldCaseMap.get(caseId).ContactId){
                newCaseMap.get(caseId).addError(System.Label.OC_TH_ContactChangeValidation_LICSR);
            }
        }
    }
    catch(Exception e){
        EventLog.createLog(new EventLog.Error(OC_TH_Constants.apexClass_CaseMirroringLICSR,OC_TH_Constants.method_ownerContactChangeValidation,null, false, e));
    }
}

/********************************************************************************************************************************************************
@ Description : This Method checks for the Owner of LICSR if Queue : Then it needs to change the ownership to LI CSR Queue but latest queue remains same.
********************************************************************************************************************************************************/
public static void ownerQueueChangeLICSR(Set<Id> caseRecSet,Set<Id> liOwnerQueueId){
    try{
        Map<Id,String> groupIdNameMap = new Map<Id,String>();
        Map<Id,case> caseObjectIdMap = new Map<Id,case>();
        String standardRecordType = String.ValueOf(OC_TH_Constants.recordType_StandardCSR);
        List<Case> caseListUpdate = new List<Case>();
        String liCsrQueueId;
        for(Group groupRec : [Select Id,Name,developerName from Group where type =: OC_TH_Constants.getQueue AND (Id In: liOwnerQueueId OR developerName =: OC_TH_Constants.getLICSRQueueDevName)]){
            groupIdNameMap.put(groupRec.Id,groupRec.Name);
            if(groupRec.developerName.equalsIgnoreCase(OC_TH_Constants.getLICSRQueueDevName)){
                liCsrQueueId = groupRec.Id;
            }
        }
        if(!groupIdNameMap.isEmpty()){
            for(case objCase: [Select Id,OwnerId,OC_TH_Latest_Queue_Name__c,RecordTypeId from Case Where Id IN: caseRecSet]){
                if(groupIdNameMap.containsKey(objCase.OwnerId) && !groupIdNameMap.get(objCase.OwnerId).equalsIgnoreCase(OC_TH_Constants.getLICSRQueue)){
                    objCase.OC_TH_Latest_Queue_Name__c = groupIdNameMap.get(objCase.OwnerId);
                    objCase.OwnerId = liCsrQueueId;
                    caseListUpdate.add(objCase);
                }
                if(standardRecordType.equalsIgnoreCase(objCase.RecordTypeId)){
                    caseObjectIdMap.put(objCase.Id,objCase);
                }
            }
            if(!caseListUpdate.isEmpty()){
                Database.update(caseListUpdate, false);
            }
            if(caseObjectIdMap.values().size() > 0){
                OC_TH_CaseCheckLI_CSR.sendEmailtoPublicGroup(caseObjectIdMap);
            }
        }
    }
    catch(Exception e){
        EventLog.createLog(new EventLog.Error(OC_TH_Constants.apexClass_CaseMirroringLICSR,OC_TH_Constants.method_ownerQueueChangeLICSR,null, false, e));
    }
}
}