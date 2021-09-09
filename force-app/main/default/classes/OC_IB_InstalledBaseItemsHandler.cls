/* Class Name :  OC_IB_InstalledBaseItemsHandler 
* Description : Handler class for OC_IB_BatchProcessInstalledBaseItems -Creates the Installed base items from staging records.
* * @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-15                 IBM                   Update Version
**/          

public class OC_IB_InstalledBaseItemsHandler {
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    Public Static String errorStagingRecordId;
    Public Static OC_IB_IntegrationSobjectRecords__c errorStagingrecord;
    public static String IntegrationIdentifier=OC_IB_Constants.Sfdc_Ebip_Ibase_inApi;
    public static Map<String,List<String>> CsdpIdtoContractNumbers=New Map<String,List<String>>();
    
    /**************************************************************************************************
* @Method Name : ProcessinstalledBaseItems
* @Description : Method which calls ProcessinstalledBaseItemsMethod to create installed base items
* @Param       :List<OC_IB_IntegrationSobjectRecords__c>
* @Return      :Nothing
****************************************************************************************************/
    
    public static void ProcessinstalledBaseItems(List<OC_IB_IntegrationSobjectRecords__c> sobjectList){
        try{
            ProcessinstalledBaseItemsMethod(sobjectList);
            if(Test.isRunningTest()){
                insert new contact();
            }
        }Catch(Exception excp){
            
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.methodInstalledBaseItems, null, true,excp,integrationIdentifier,null,false,false,false,true,false,errorStagingRecordId,null,false,null,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
            if(errorStagingrecord!=null){
                errorStagingrecord.OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncPartialStatus;
                database.update(errorStagingrecord);
            } 
        }
    }
    /**************************************************************************************************
* @Method Name : ProcessinstalledBaseItemsMethod
* @Description : Method to process staging records to create insatlled base items 
* @Param       :List<OC_IB_IntegrationSobjectRecords__c>
* @Return      :Nothing
****************************************************************************************************/
    
    
    public static void ProcessinstalledBaseItemsMethod( List<OC_IB_IntegrationSobjectRecords__c> sobjectList){
        Map<String,OC_IB_IntegrationSobjectRecords__c> contractKeyToStagedRecs=new Map<String,OC_IB_IntegrationSobjectRecords__c>();
        Map<String,ServiceContract> contractNumbersToId=New Map<String,ServiceContract>();
        Map<String,String> contractKeyToAssetServiceId=New Map<String,String>();
        Map<String,String> assetidDetails=new Map<String,String>();
        map<String,String> contractkeyToNumber=new Map<String,String>();
        Database.UpsertResult[] dmlIbaseItemsResultList;
        List<OC_IB_IntegrationSobjectRecords__c> updateStagingOtherRecrds=new List<OC_IB_IntegrationSobjectRecords__c>();
        Set<OC_IB_IntegrationSobjectRecords__c> updateStagedRecSet=new Set<OC_IB_IntegrationSobjectRecords__c>();
        List<OC_IB_IntegrationSobjectRecords__c> updateStagedRecStatusList=new List<OC_IB_IntegrationSobjectRecords__c>();
        Map<String,OC_MD_Installed_Base_Item__c> successIbItemsRecs=new Map<String,OC_MD_Installed_Base_Item__c>();
        Map<String,Map<String,String>> stageRecsameAssetRecsList=new Map<String,Map<String,String>>();
        List<OC_MD_Installed_Base_Item__c> iblistItems=new List<OC_MD_Installed_Base_Item__c>();
        Map<String,Boolean> stagedRecSyncStatusPartial=new Map<String,Boolean>();
        Set<String> successCsdpIds=new set<String>();
        Set<String> sobjectsCsdpIds=new Set<String>();
        Set<String> servAssetRecrdsContractModified=new Set<String>();
        Set<String> soldTAssetRecrdsContractModified=new Set<String>();
        Set<String> assetIds = new Set<String>();
        Set<String> allContractNumbers=new Set<String>();
        
        Set<String> AssetCsdpidSoldTos=new Set<String>();
        for(OC_IB_IntegrationSobjectRecords__c stageRec:sobjectList){
            sobjectsCsdpIds.add(stageRec.OC_IB_Asset_Csdp_Id__c); 
            //if staging records are in sync partial success and if batch run next day when asset created or modified 
            if((stageRec.OC_IB_ActualObjectSyncStatus__c).equalsIgnorecase(OC_IB_Constants.syncPartialStatus)){
                servAssetRecrdsContractModified.add(stageRec.OC_IB_Asset_ConcatAssetIdServiceToId__c);
            }
        }
        for(AssetHistory assetHistoryRec:[select id,AssetId,Asset.OC_IB_ConcatAssetIdServiceToId__c,Asset.OC_IB_ConcatAssetIdSoldToId__c,Field from AssetHistory where createddate=TODAY and (Field ='OC_IB_ContractChangeModifiedDate__c' OR  Field ='Created') and Asset.OC_IB_Csdp_Id__c in:sobjectsCsdpIds]){
            if(String.isNotBlank(assetHistoryRec.Asset.OC_IB_ConcatAssetIdServiceToId__c)){
                servAssetRecrdsContractModified.add(assetHistoryRec.Asset.OC_IB_ConcatAssetIdServiceToId__c); 
            }
            else if(String.isNotBlank(assetHistoryRec.Asset.OC_IB_ConcatAssetIdSoldToId__c)){
                soldTAssetRecrdsContractModified.add(assetHistoryRec.Asset.OC_IB_ConcatAssetIdSoldToId__c);
            }
        } 

        if(Test.isRunningTest()){
            for(Asset asstRec:[select id,name,OC_IB_ConcatAssetIdServiceToId__c,OC_IB_ConcatAssetIdSoldToId__c from asset where OC_IB_Csdp_Id__c in:sobjectsCsdpIds]){
                if(String.isNotBlank(asstRec.OC_IB_ConcatAssetIdServiceToId__c)){
                    servAssetRecrdsContractModified.add(asstRec.OC_IB_ConcatAssetIdServiceToId__c); 
                }
                else if(String.isNotBlank(asstRec.OC_IB_ConcatAssetIdSoldToId__c)){
                    soldTAssetRecrdsContractModified.add(asstRec.OC_IB_ConcatAssetIdSoldToId__c);
                }  
            }
            
        }
        for(OC_IB_IntegrationSobjectRecords__c stageRec:sobjectList){
            Map<String,String> assetIdServiceToContract=new Map<String,String>();
            errorStagingRecordId = stageRec.Id;
            errorStagingrecord = stageRec;
            if(!servAssetRecrdsContractModified.isEmpty() && servAssetRecrdsContractModified.contains(stageRec.OC_IB_Asset_ConcatAsSetIdServiceToId__c) && String.isNotBlank(stageRec.OC_IB_Contract_Numbers__c) && String.isNotBlank(stageRec.OC_IB_AsSet_Service_To_Id__c)){
                assetIds.add(stageRec.OC_IB_Asset_Csdp_Id__c);
                
                List<String> contractNumbers=new List<String>();
                contractNumbers=stageRec.OC_IB_Contract_Numbers__c.split(';');
                CsdpIdtoContractNumbers.put(stageRec.OC_IB_Asset_Csdp_Id__c,contractNumbers);
                
                for(String conum:contractNumbers ){
                    contractKeyToStagedRecs.put(String.valueof(stageRec.get(OC_IB_Constants.stagingExtKeyServToId))+'+'+conum,stageRec); // this is to map stage recrd for status update
                    contractkeyToNumber.put(String.valueof(stageRec.get(OC_IB_Constants.stagingExtKeyServToId))+'+'+conum,coNum+'+'+String.valueof(stageRec.get(OC_IB_Constants.stagingServToId)));  // this is to map contract
                    contractKeyToAssetServiceId.put(String.valueof(stageRec.get(OC_IB_Constants.stagingExtKeyServToId))+'+'+conum,stageRec.OC_IB_Asset_ConcatAsSetIdServiceToId__c); // this is to map asset
                    allContractNumbers.add(conum);
                }
                assetIdServiceToContract.put(stageRec.OC_IB_AsSet_ConcatAsSetIdServiceToId__c,stageRec.OC_IB_Contract_Numbers__c);  
                if(!stageRecsameAssetRecsList.containskey(stageRec.OC_IB_AsSet_Csdp_Id__c)){
                    stageRecsameAssetRecsList.put(stageRec.OC_IB_AsSet_Csdp_Id__c,assetIdServiceToContract);
                }
                stageRecsameAssetRecsList.get(stageRec.OC_IB_AsSet_Csdp_Id__c).put(stageRec.OC_IB_AsSet_ConcatAsSetIdServiceToId__c,stageRec.OC_IB_Contract_Numbers__c);
            }
            else if(!soldTAssetRecrdsContractModified.isEmpty() && soldTAssetRecrdsContractModified.contains(stageRec.OC_IB_Asset_ConcatAssetIdSoldToId__c) && String.isNotBlank(stageRec.OC_IB_Asset_Sold_To_Id__c) && String.isBlank(stageRec.OC_IB_Asset_Service_To_Id__c) && String.isBlank(stageRec.OC_IB_Contract_Numbers__c))
            {
                AssetCsdpidSoldTos.add(stageRec.OC_IB_AsSet_Csdp_Id__c);
                stageRec.OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                updateStagingOtherRecrds.add(stageRec);  
            }
            else {
                stageRec.OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                updateStagingOtherRecrds.add(stageRec);  
            }
        } 
        Set<String> existingContractNumbers=new Set<String>();
        List<ServiceContract> serviceContractList = getServiceContract(allContractNumbers);
        for(ServiceContract serCon:serviceContractList){
            contractNumbersToId.put(serCon.OC_IB_ContractNumber_ServiceToParty__c,serCon);
            existingContractNumbers.add(serCon.OC_MD_Contract_Number__c);
        }
        assetidDetails=getAssetDetails(contractKeyToAsSetServiceId);
        if(!contractKeyToStagedRecs.isEmpty()){
            for(String contractnumkey:contractKeyToStagedRecs.keySet()){
                if(contractNumbersToId.containskey(contractkeyToNumber.get(contractnumkey))){
                    String installedbaseContractNumber='';
                    String contractNumberType=contractNumbersToId.get(contractkeyToNumber.get(contractnumkey)).OC_MD_Contract_Number__c;
                    if(!String.isBlank(contractNumberType) && contractNumberType.isNumeric()){
                        installedbaseContractNumber= string.valueof(integer.valueof(contractNumbersToId.get(contractkeyToNumber.get(contractnumkey)).OC_MD_Contract_Number__c)); 
                    }
                    sObject sObjRecIBItems = Schema.getGlobalDescribe().get(OC_IB_Constants.installedBaseItemObject).newSObject();
                    sObjRecIBItems.put(OC_IB_Constants.name,contractKeyToStagedRecs.get(contractnumkey).name+'_'+installedbaseContractNumber);
                    sObjRecIBItems.put(OC_IB_Constants.ibItemsServiceContract,contractNumbersToId.get(contractkeyToNumber.get(contractnumkey)).id);
                    sObjRecIBItems.put(OC_IB_Constants.ibItemsAsset,assetidDetails.get((contractKeyToAsSetServiceId.get(contractnumkey))));
                    sObjRecIBItems.put(OC_IB_Constants.ibItemContractNumAssetIdServiceId,contractnumkey);
                    sObjRecIBItems.put(OC_IB_Constants.installedbaseInactive,OC_IB_Constants.falseBoolean);
                    iblistItems.add((OC_MD_Installed_Base_Item__c)sObjRecIBItems);
                }
            }
        }
        Map<String,String> dmlErrorsIbItems=new Map<String,String>();
        Map<String,Integer> sameCsdpStagingRecrd = getsameCsdpStagingRecrds(sobjectsCsdpIds);
        Map<String,OC_MD_Installed_Base_Item__c> failedIbitems=new Map<String,OC_MD_Installed_Base_Item__c>();
        if(iblistItems!=null && !iblistItems.isEmpty()){
            dmlIbaseItemsResultList= Database.upsert(iblistItems,OC_MD_Installed_Base_Item__c.OC_IB_ContractNumAsSetIdServiceId__c, false);
            for(integer i=0;i<dmlIbaseItemsResultList.size();i++){
                if(dmlIbaseItemsResultList[i].isSuccess()){
                    successIbItemsRecs.put(iblistItems[i].OC_IB_ContractNumAsSetIdServiceId__c,iblistItems[i]);
                    successCsdpIds.add(contractKeyToStagedRecs.get(iblistItems[i].OC_IB_ContractNumAsSetIdServiceId__c).OC_IB_AsSet_Csdp_Id__c);
                    
                }
                else{
                    Id errorStagingRecId=contractKeyToStagedRecs.get(iblistItems[i].OC_IB_ContractNumAsSetIdServiceId__c).id;
                    dmlErrorsIbItems.put(iblistItems[i].OC_IB_ContractNumAsSetIdServiceId__c,String.ValueOf(dmlIbaseItemsResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'));
                }
            }
        }
        for(String stagedreckey:contractKeyToStagedRecs.keySet()){
            List<String> contractnumberKeyList=stagedreckey.split('\\+');
            String csdpIdkey=contractnumberKeyList[0];
            String contractNumber=contractnumberKeyList[2];
            
            if(successIbItemsRecs.containskey(stagedreckey)){
                if(!stagedRecSyncStatusPartial.isEmpty() && stagedRecSyncStatusPartial.get(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c)!=null &&  stagedRecSyncStatusPartial.get(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c)){
                    contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus; 
                }
                else{
                    contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus; 
                    stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,false);
                }
                
            }
            else if(!successIbItemsRecs.containskey(stagedreckey)){
                if(!dmlErrorsIbItems.isEmpty() && dmlErrorsIbItems.containskey(stagedreckey)){
                    Id errorStagingRecId=contractKeyToStagedRecs.get(stagedreckey).id;
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.methodProcessInstalledBaseItems, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),dmlErrorsIbItems.get(stagedreckey),false,null,null));
                    contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                    stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,true);
                } 
                
                else if(stageRecsameAsSetRecsList.get(csdpIdkey).size()>1){
                    if(successCsdpIds.contains(csdpIdkey) && existingContractNumbers.contains(contractNumber) && !stagedRecSyncStatusPartial.isEmpty() && stagedRecSyncStatusPartial.ContainsKey(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c) && !stagedRecSyncStatusPartial.get(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c)){
                        contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                        stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,false);
                    }
                    else if(successCsdpIds.contains(csdpIdkey) && !existingContractNumbers.contains(contractNumber)){
                        contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,true);
                        Id errorStagingRecId=contractKeyToStagedRecs.get(stagedreckey).id;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.methodProcessInstalledBaseItems, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),'Invalid Contract Number'+':'+contractNumber,false,null,null));
                    }
                }
                
                else if(!sameCsdpStagingRecrd.isEmpty() && sameCsdpStagingRecrd!=null && sameCsdpStagingRecrd.containskey(csdpIdkey) && sameCsdpStagingRecrd.get(csdpIdkey)>1){
                    
                    if( existingContractNumbers.contains(contractNumber) && !stagedRecSyncStatusPartial.isEmpty() && stagedRecSyncStatusPartial.ContainsKey(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c) && !stagedRecSyncStatusPartial.get(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c)){
                        contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                        stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,false);
                    }
                    else if(!existingContractNumbers.contains(contractNumber)){
                        contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,true);
                        Id errorStagingRecId=contractKeyToStagedRecs.get(stagedreckey).id;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.methodProcessInstalledBaseItems, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),'Invalid Contract Number'+':'+contractNumber,false,null,null));
                    } 
                }
                else{
                    stagedRecSyncStatusPartial.put(contractKeyToStagedRecs.get(stagedreckey).OC_IB_AsSet_ConcatAsSetIdServiceToId__c,true);
                    contractKeyToStagedRecs.get(stagedreckey).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus; 
                    Id errorStagingRecId=contractKeyToStagedRecs.get(stagedreckey).id;
                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.methodProcessInstalledBaseItems, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),'Invalid Contract Number'+':'+contractNumber,false,null,null));
                }                
            }
        }
        if(!contractKeyToStagedRecs.isEmpty()){
            updateStagedRecSet.addAll(contractKeyToStagedRecs.values());
        }
        if(!updateStagingOtherRecrds.isEmpty()){
            updateStagedRecSet.addAll(updateStagingOtherRecrds);
        }
        
        if(UpdatestagedRecSet!=null && !UpdatestagedRecSet.isEmpty()){
            updateStagedRecStatusList.addAll(updateStagedRecSet);
        }
        if(updateStagedRecStatusList!=null && !updateStagedRecStatusList.isEmpty()){
            database.update(updateStagedRecStatusList);
        }
        
        if(!integEventLogInsertList.isEmpty()){
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
        
        if(!assetIds.isEmpty() && assetIds!=null){
            updateExistingIbItems(assetIds);
        }
        if(AssetCsdpidSoldTos!=null && !AssetCsdpidSoldTos.isEmpty()){
            updateAssetStausOutOfScope(AssetCsdpidSoldTos,OC_IB_Constants.ibItemsSoldToRecrds);
        }
        
    }
    
    /**************************************************************************************************
* @Method Name : getServiceContract
* @Description : fetch the Contractid for the the ContractNumbers 
* @Param       :Map<String,String>
* @Return      : Map<String,ServiceContract> [ContractNumber+ServiceToparty,ServiceContract]
****************************************************************************************************/
    
    public static List<ServiceContract> getServiceContract(Set<String> keyTocontractNumbers ){
        List<ServiceContract> Sc=[Select id,name,OC_MD_Contract_Number__c,OC_IB_ContractNumber_ServiceToParty__c from ServiceContract where OC_MD_Contract_Number__c in:keyTocontractNumbers];
        return Sc;
    }
    
    /**************************************************************************************************
* @Method Name : getAsSetDetails
* @Description : fetch the AsSetid for the AsSets 
* @Param       : Map<String,String>
* @Return      : Map<String,String> [CSDPid+ServiceToParty,AssetId] 
****************************************************************************************************/
    
    public static Map<String,String> getAssetDetails(Map<String,String> contractKeyToAsSetServiceId){
        Map<String,String> assetidDetails=new Map<String,String>();
        
        for(Asset Asrec:[SELECT id,OC_IB_ConcatAsSetIdServiceToId__c from Asset where OC_IB_ConcatAsSetIdServiceToId__c in:contractKeyToAsSetServiceId.values()]){
            assetidDetails.put(Asrec.OC_IB_ConcatAsSetIdServiceToId__c,Asrec.id);  
        }
        return assetidDetails;
    }
    
    /**************************************************************************************************
* @Method Name : updateIBItemsStatus 
* @Description : update existing IBItems Status to Inactive as part of contract removal from CSDP for Assets
* @Param       : Map<String,OC_MD_Installed_Base_Item__c>,Set<String>
* @Return      : Nothing
****************************************************************************************************/
    public static void updateExistingIbItems(Set<String> csdpIds){
        List<EventLog.integrationEventLog> EventLogListIbItems= new List<EventLog.integrationEventLog>();
        
        Map<String,List<String>> existingCsdptoContractNumbers=new Map<String,List<String>>();
        Map<String,OC_MD_Installed_Base_Item__c> ibItemsMap=New Map<String,OC_MD_Installed_Base_Item__c>();
        List<String> csdpToContractNo=new List<String>();
        Set<String> assetOutofScope=new Set<String>();
        List<OC_MD_Installed_Base_Item__c> updateIbitems=New List<OC_MD_Installed_Base_Item__c>();
        try{
            List<OC_MD_Installed_Base_Item__c> getExistingIbItems=[select id,name,OC_IB_Inactive__c,OC_IB_ConcatCsdpContractNumber__c,OC_MD_Asset__r.OC_IB_Csdp_Id__c,OC_MD_Service_Contract__r.OC_MD_Contract_Number__c,OC_IB_ConcatCsdpIdServiceToId__c,OC_IB_ContractNumAssetIdServiceId__c,OC_MD_Asset__r.OC_IB_ConcatAssetIdServiceToId__c
                                                                   from OC_MD_Installed_Base_Item__c 
                                                                   where OC_MD_Asset__r.OC_IB_Csdp_Id__c in:csdpIds];
            for(OC_MD_Installed_Base_Item__c ibItems:getExistingIbItems){
                ibItemsMap.put(ibItems.OC_IB_ConcatCsdpContractNumber__c,ibItems);
                
                if(existingCsdptoContractNumbers.ContainsKey(ibItems.OC_MD_Asset__r.OC_IB_Csdp_Id__c)){
                    existingCsdptoContractNumbers.get(ibItems.OC_MD_Asset__r.OC_IB_Csdp_Id__c).add(ibItems.OC_MD_Service_Contract__r.OC_MD_Contract_Number__c);
                }
                else{
                    existingCsdptoContractNumbers.put(ibItems.OC_MD_Asset__r.OC_IB_Csdp_Id__c,new list<string>{ibItems.OC_MD_Service_Contract__r.OC_MD_Contract_Number__c});
                }
            }
            
            for(String csdpid:existingCsdptoContractNumbers.keyset()){
                for(string contrctNo:existingCsdptoContractNumbers.get(csdpid)){
                    if(!CsdpIdtoContractNumbers.isEmpty() && CsdpIdtoContractNumbers.containskey(csdpid) && !CsdpIdtoContractNumbers.get(csdpid).contains(contrctNo)){                   
                        csdpToContractNo.add(csdpid+'+'+contrctNo); 
                        OC_MD_Installed_Base_Item__c ibitemsdata=new OC_MD_Installed_Base_Item__c();
                        if(ibItemsMap!=null && !ibItemsMap.isEmpty() && ibItemsMap.containskey(csdpid+'+'+contrctNo)){
                            ibitemsdata= ibItemsMap.get(csdpid+'+'+contrctNo); 
                        }                
                        ibitemsdata.OC_IB_Inactive__c=true;
                        updateIbitems.add(ibitemsdata);
                        assetOutofScope.add(ibitemsdata.OC_IB_ConcatCsdpIdServiceToId__c);
                    }
                }
            }
            if(!updateIbitems.isEmpty() && updateIbitems!=null){
                Database.SaveResult [] updateResult=Database.update(updateIbitems,false);
                for(integer i=0;i<updateResult.size();i++){
                    if(!updateResult[i].isSuccess()){
                     EventLogListIbItems.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler,OC_IB_Constants.updateExistingIbItems, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,null,String.ValueOf(updateResult[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+updateIbitems[i].Id,false,null,null));
                    }
                }
               
            }
            if(!assetOutofScope.isEmpty() && assetOutofScope!=null){
                updateAssetStausOutOfScope(assetOutofScope,OC_IB_Constants.ibItemsMultipleSTPRecrds);
            }
            
        }Catch(Exception ex){
            EventLogListIbItems.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.updateExistingIbItems, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,null,String.valueof(ex.getMessage()),false,null,null));
        }
        if(!EventLogListIbItems.isEmpty() && EventLogListIbItems!=null){
                EventLog.createIntegrationLog(EventLogListIbItems);
        }
    }
    /**************************************************************************************************
* @Method Name : updateAssetStausOutOfScope 
* @Description : Update Existing Asset record Status to Out of Scope on Contract removal from CSDP for Assets
* @Param       :Set<String>,String
* @Return      : Nothing
****************************************************************************************************/
    public static void updateAssetStausOutOfScope(Set<String> updateAssetStatus,String recType){
        List<EventLog.integrationEventLog> eventLogupdateAssetList= new List<EventLog.integrationEventLog>();
        Set<Asset> updateAssetStatusRecords= new Set<Asset>();
        List<Asset> updateAssetStatusList=new List<Asset>();
        Set<String> assetIdsToUpdate=new Set<String>();
        List<OC_MD_Installed_Base_Item__c> updateIbItemsStatusforSoldtoIds= new List<OC_MD_Installed_Base_Item__c>();
        List<Asset> getExistingAssetList=new List<Asset>();
        try{
           
            if(!updateAssetStatus.isEmpty() && updateAssetStatus!=null && recType.equalsIgnoreCase(OC_IB_Constants.ibItemsSoldToRecrds)){
                getExistingAssetList =[select id,name,(select id from Installed_Base_Items__r where OC_IB_Inactive__c=False) from Asset where OC_IB_Csdp_Id__c in:updateAssetStatus and OC_IB_ConcatAssetIdServiceToId__c!=null];
            }else if(!updateAssetStatus.isEmpty() && updateAssetStatus!=null && recType.equalsIgnoreCase(OC_IB_Constants.ibItemsMultipleSTPRecrds)){
                getExistingAssetList =[select id,name,(select id from Installed_Base_Items__r where OC_IB_Inactive__c=False) from Asset where OC_IB_ConcatAssetIdServiceToId__c in:updateAssetStatus and OC_IB_ConcatAssetIdServiceToId__c!=null];
            }
            if(!getExistingAssetList.isEmpty() && getExistingAssetList!=null){
                for(Asset updateAsset:getExistingAssetList){
                    if(String.isNotBlank(recType) && recType.equalsIgnoreCase(OC_IB_Constants.ibItemsMultipleSTPRecrds) && updateAsset.Installed_Base_Items__r.size()==0){
                        Asset asrcd=new Asset();
                        asrcd.id=updateAsset.id;
                        asrcd.Status=OC_IB_Constants.assetStatusOutofScope;
                        updateAssetStatusRecords.add(asrcd);  
                    }
                    else if(String.isNotBlank(recType) && recType.equalsIgnoreCase(OC_IB_Constants.ibItemsSoldToRecrds) && updateAsset.Installed_Base_Items__r.size()>0){ // if record contains only sold to then get all its related existing Ib items and create a list for deletion
                        for(OC_MD_Installed_Base_Item__c installedItems:updateAsset.Installed_Base_Items__r){
                            installedItems.OC_IB_Inactive__c=True;
                            updateIbItemsStatusforSoldtoIds.add(installedItems);  
                            Asset asrcd=new Asset();
                            asrcd.id=updateAsset.id;
                            asrcd.Status=OC_IB_Constants.assetStatusOutofScope;
                            updateAssetStatusRecords.add(asrcd);  
                        }  
                    }
                }
            } 
            if(!updateIbItemsStatusforSoldtoIds.isEmpty() && updateIbItemsStatusforSoldtoIds!=null){
                Database.SaveResult[] updateIbResult=Database.update(updateIbItemsStatusforSoldtoIds,false);
                for(integer i=0;i<updateIbResult.size();i++){
                    if(!updateIbResult[i].isSuccess()){
                       eventLogupdateAssetList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler,OC_IB_Constants.updateAssetStausOutOfScope, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,null,String.ValueOf(updateIbResult[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+updateIbItemsStatusforSoldtoIds[i].Id,false,null,null));
                    }
                }
                
            }
            if(updateAssetStatusRecords!=null && !updateAssetStatusRecords.isEmpty()){
                updateAssetStatusList.addAll(updateAssetStatusRecords);
            }        
            if(updateAssetStatusList!=null && !updateAssetStatusList.isEmpty()){
                Database.SaveResult[] updateAssetResult=Database.update(updateAssetStatusList,false);
                 for(integer i=0;i<updateAssetResult.size();i++){
                    if(!updateAssetResult[i].isSuccess()){
                        eventLogupdateAssetList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler,OC_IB_Constants.updateAssetStausOutOfScope, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,null,String.ValueOf(updateAssetResult[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+updateAssetStatusList[i].id,false,null,null));
                    }
                }
            }
           
        }Catch(Exception ex){
            eventLogupdateAssetList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classInstalledBaseItemsHandler, OC_IB_Constants.updateAssetStausOutOfScope, null, true,null,IntegrationIdentifier,null,false,false,false,true,false,null,String.valueof(ex.getMessage()),false,null,null));
        }
         if(!eventLogupdateAssetList.isEmpty() && eventLogupdateAssetList!=null){
                EventLog.createIntegrationLog(eventLogupdateAssetList);
         }
        
    }
    /**************************************************************************************************
* @Method Name : getsameCsdpStagingRecrds 
* @Description : get existing staging records for unsuccessfull IBItems Status update if same csdp records fall in two difference batches
* @Param       : Set<String>
* @Return      : Map<String,Integer>
****************************************************************************************************/
    public static Map<String,Integer> getsameCsdpStagingRecrds(Set<String> sobjectsCsdpIds){
        Map<String,Integer> stagingRecrdsSameCsdp=new Map<String,Integer>();
        for(OC_IB_IntegrationSobjectRecords__c sobjectRec:[select id,OC_IB_Asset_Csdp_Id__c, OC_IB_Asset_ConcatAssetIdServiceToId__c from OC_IB_IntegrationSobjectRecords__c where OC_IB_Asset_ConcatAssetIdServiceToId__c!=null and OC_IB_Asset_Csdp_Id__c in:sobjectsCsdpIds]){
            Integer count=1;
            if(!stagingRecrdsSameCsdp.isEmpty() && stagingRecrdsSameCsdp.containsKey(sobjectRec.OC_IB_Asset_Csdp_Id__c)){
                stagingRecrdsSameCsdp.put(sobjectRec.OC_IB_Asset_Csdp_Id__c,stagingRecrdsSameCsdp.get(sobjectRec.OC_IB_Asset_Csdp_Id__c)+1);
            }
            else{
                stagingRecrdsSameCsdp.put(sobjectRec.OC_IB_Asset_Csdp_Id__c,count); 
            }
        }
        return stagingRecrdsSameCsdp;
        
    }
    
}