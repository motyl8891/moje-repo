/**
* @File Name          : OC_CSM_StagedObjToActualObjMapingHandler
* @Description        : Handler class for OC_CSM_BATCH_StagedDataProcessor - migrates the integration data from Staging object to Actual object.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2011
* @Created Date       : 1Oth November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-11                IBM                   Initial Version
* 1.1        2021-03-29                IBM                   U-2598 Contract Improvement to consider Contract type field
* 1.2        2021-04-01                IBM                   U-2676 Contract ResponseProfile
**/
public class OC_CSM_StagedObjToActualObjMapingHandler {
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    
    Public Static String errorStagingRecordId;
    Public Static OC_IB_IntegrationSobjectRecords__c errorStagingrecord;
    /*U-2676 Contract Response Profile-begin*/
    Public Static Map<String,OC_IB_IntegrationSobjectRecords__c> upsertedResultStageContract=new Map<String,OC_IB_IntegrationSobjectRecords__c>();// map to get id for the contract number
    Public Static Map<String,Boolean> responseDurationTypeError=new Map<String,Boolean>();
    /*U-2676 Contract Response Profile-end*/
    
    /*U-2675 Account update Changes -begin*/
    /*
    Public Static  Map<String,String> contractNumbertoCustomerUnitMap = new Map<String,String>(); 
    Public Static Map<String,String> contractNumbertoMarketAreaCodeMap = new Map<String,String>();
	*/
    /*U-2675 Account update Changes -end*/
    /**************************************************************************************************
* @Method Name : copyDataFromStagingObjToActualObj
* @Description : upserts the staging object records into actual object. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing 
****************************************************************************************************/
    Public Static Void copyDataFromStagingObjToActualObj(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){
        
        try{
            CopyContractStagingToActualObject(integrationIdentifier,stagedRecList);
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
        }catch(Exception excp){
         system.debug('exception is==>'+excp);            
            integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.methodCSMCopyDataFromStagingObjToActualObj, null, true,excp,integrationIdentifier,null,false,false,false,true,false,errorStagingRecordId,null,false,null,null));
            EventLog.createIntegrationLog(integEventLogInsertList);
            if(errorStagingrecord!=null){
                errorStagingrecord.OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncErrorStatus;
                database.update(errorStagingrecord);
            }
        }  
    }
    
    /**************************************************************************************************
* @Method Name : CopyContractStagingToActualObject
* @Description : upserts the staging object records into Service contract and Contract Line Items object. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing 
****************************************************************************************************/
    
    Public Static Void CopyContractStagingToActualObject(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){
        String objectName;
        Set<String> serviceElementsSet=new Set<String>();
        List<sObject> contractsObjectList=new List<sObject>();
        Map<String,String> contractNumberToServicePackage=new Map<String,String>();
        List<ServiceContract> contractUpsertList=new List<ServiceContract>();
        List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList;
        Map<String,OC_IB_IntegrationSobjectRecords__c> mapExtKeyToStagingRec  = new Map<String,OC_IB_IntegrationSobjectRecords__c> ();
        Map<String,Id> mapStagingFieldValueToSfId = new Map<String,Id> ();
        Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapActualobjFieldToMdtRec = new Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> ();
        Boolean mapStagingFieldValueToSfIdNotEmpty;
        Set<String> contractNumbers=new Set<String>();
        Map<String,List<String>> contractNumberToServiceElements=new Map<String,List<String>>();
        Map<String,String> contractNumbersToId=new Map<String,String>();
        Map<String,Sobject> upsertContractSobjectRec=new map<String,Sobject>();
        // Map<String,OC_IB_IntegrationSobjectRecords__c> upsertedResultStageContract=new Map<String,OC_IB_IntegrationSobjectRecords__c>();// map to get id for the contract number
        List<ContractLineItem> contractLineItemsList=new List<ContractLineItem>();
        Map<String,Id> productNametoId = new Map<String,id>();
        Map<String,String> getPriceBookEntryId = new Map<String,String>();
        Map<String,Boolean> islineItemsfailed=new Map<String,Boolean>();
        List<ServiceContract> entitlementsCreationList=new List<ServiceContract>();
        List<Entitlement> updateServiceContractListforEntitlement=new List<Entitlement>();
        Map<String,Boolean> entitlementFailed=new Map<String,Boolean>();
        /*U-2675 Account update Changes - begin*/
        /*
        Map<Id,Account> updateAccountFieldMap =new Map<id,Account>();
        List<Account> updateAccountList =new List<Account>();        
        Map<String,List<OC_IB_IntegrationSobjectRecords__c>> serviceIdtoIntegrationObjectMap=new Map<String,List<OC_IB_IntegrationSobjectRecords__c>>();
        Map<String,String> ContractNumbertoAccountIdMap = new Map<String,String>();
		*/
        /*U-2675 Account update Changes - end*/        
        Database.UpsertResult[] dmlServContractResultList;
        Database.UpsertResult[] dmlServContractLineItemsResultList;
        Database.UpsertResult[] dmlEntitlementResultList;
        Database.UpsertResult[] dmlServiceMilestoneResultList;
      //  Database.SaveResult[] dmlAccountResultList;/*U-2675 Account update Changes */      
        
        /*U-2676 Contract Response Profile-begin*/
        Map<String,String> serviceContractResponseProfile=new Map<String,String>();
        List<OC_TH_Service_Milestone__c> serviceMilestoneUpsertList= new List<OC_TH_Service_Milestone__c>();
        /*U-2676 Contract Response Profile-end*/
        
        Id priceBookid=getPriceBookId();
        
        inboundFieldMappingMdtRecordList = OC_IB_Utility.getInboundIntegrationFieldMappingMdtRecords(integrationIdentifier);
        objectName = inboundFieldMappingMdtRecordList[0].OC_IB_SfdcObjectApiName__c;
        if(inboundFieldMappingMdtRecordList!=null && !inboundFieldMappingMdtRecordList.isEmpty()){
            mapActualobjFieldToMdtRec = OC_IB_Utility.getActualobjFieldToMdtRecMapping (inboundFieldMappingMdtRecordList);
            mapStagingFieldValueToSfId = OC_IB_Utility.getServiceAccS2PIdToAccIdMapping();
            
            mapStagingFieldValueToSfIdNotEmpty =  (mapStagingFieldValueToSfId!=null && !mapStagingFieldValueToSfId.isEmpty() ) ? true : false;
            
            
            for(OC_IB_IntegrationSobjectRecords__c stagedRec : stagedRecList){
                errorStagingRecordId = stagedRec.Id;
                errorStagingrecord = stagedRec;
                List<String> serviceElements=new List<String>();
                if(String.isNotEmpty(stagedRec.OC_CSM_Contract_serviceElements__c) && String.isNotBlank(stagedRec.OC_CSM_Contract_serviceElements__c)) {
                    String elements=stagedRec.OC_CSM_Contract_serviceElements__c;
                    List<String> elementsIdentifierList=elements.split('";"');
                    for(String rec:elementsIdentifierList){
                        serviceElements.add(rec.replaceAll('"','')) ; 
                    }
                    serviceElementsSet.addAll(serviceElements);
                    
                }
                contractNumberToServicePackage.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecContractNumber)),String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecServicepackage)));
                contractNumberToServiceElements.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecContractNumber)),serviceElements);
                
                /*U-2676 Contract Response Profile-begin*/
                serviceContractResponseProfile.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecContractNumber)),String.valueof(stagedRec.get(OC_IB_Constants.stagingResponseProfile)));
			 	/*U-2676 Contract Response Profile-end*/
                
                sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                sObjRec.put(OC_IB_Constants.contractCurrencyCode,OC_IB_Constants.contractCurrencyCodeValue);
                sObjRec.put(OC_IB_Constants.contractpriceBook2id,priceBookid);
                //added as part of US-2021 04 Contract Type update on service contract 
                sObjRec.put(OC_IB_Constants.contractType,String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecServicepackage)));
                
                for(String FieldName : mapActualobjFieldToMdtRec.Keyset()){
                    OC_IB_InboundIntegrationFieldMapping__mdt mdtRec = mapActualobjFieldToMdtRec.get(FieldName);
                    if(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c) != null){
                        sObjRec = OC_IB_Utility.DataMapping(mdtRec,sObjRec,FieldName,stagedRec,mapStagingFieldValueToSfIdNotEmpty,mapStagingFieldValueToSfId);
                    }else{
                        sObjRec.Put(FieldName,null);    
                    }
                }
                
                upsertContractSobjectRec.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecContractNumber)),sObjRec);   
                upsertedResultStageContract.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecContractNumber)),stagedRec);
               
            }
            if(!upsertContractSobjectRec.isEmpty()){
                contractUpsertList.addAll((List<ServiceContract>)upsertContractSobjectRec.values()); 
            }
            
            if(contractUpsertList!=null && !contractUpsertList.isEmpty()){
                dmlServContractResultList=database.upsert(contractUpsertList,ServiceContract.OC_MD_Contract_Number__c,false);
                
                for(integer i=0;i<dmlServContractResultList.size();i++){
                    if(dmlServContractResultList[i].isSuccess()){
                        entitlementsCreationList.add(contractUpsertList[i]);
                        contractNumbersToId.put(contractUpsertList[i].OC_MD_Contract_Number__c,contractUpsertList[i].id);
                        upsertedResultStageContract.get(contractUpsertList[i].OC_MD_Contract_Number__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                       
                    }else{
                        Id errorStagingRecId=upsertedResultStageContract.get(contractUpsertList[i].OC_MD_Contract_Number__c).id;
                        upsertedResultStageContract.get(contractUpsertList[i].OC_MD_Contract_Number__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncErrorStatus;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.methodCSMCopyDataFromStagingObjToActualObj, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlServContractResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));    
                    }
                }
            }
            
            List<Entitlement> entitlementUpsertList=getEntitlementList(entitlementsCreationList);
            if(entitlementUpsertList!=null && !entitlementUpsertList.isEmpty()){
                dmlEntitlementResultList=database.upsert(entitlementUpsertList,Entitlement.OC_CSM_Entitlement_Number__c,false);
                for(integer i=0;i<dmlEntitlementResultList.size();i++){
                    if(dmlEntitlementResultList[i].isSuccess()){
                        updateServiceContractListforEntitlement.add(entitlementUpsertList[i]);
                    }
                    else{
                        entitlementFailed.put(entitlementUpsertList[i].OC_CSM_Entitlement_Number__c,true);
                        upsertedResultStageContract.get(entitlementUpsertList[i].OC_CSM_Entitlement_Number__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        Id errorStagingRecId=upsertedResultStageContract.get(entitlementUpsertList[i].OC_CSM_Entitlement_Number__c).id;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.methodCopyContractStagingToActualObject, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlEntitlementResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+ 'Entitlement creation failed',false,null,null));
                    }
                }
                
            }
            updateContractEntitlementLookup(updateServiceContractListforEntitlement);
            productNametoId=OC_IB_Utility.getProductNameToProductIdMapping(serviceElementsSet);
            getPriceBookEntryId=getPriceBookEntryId(priceBookid,productNametoId.values());
            
            if(!contractNumberToServiceElements.isEmpty()){
                for(string contractNo:contractNumberToServiceElements.keyset()){
                    String servicePackage=contractNumberToServicePackage.get(contractNo);
                    if(!contractNumbersToId.isEmpty() && contractNumbersToId.containskey(contractNo) && !contractNumberToServiceElements.get(contractNo).isEmpty() && contractNumberToServiceElements.get(contractNo)!=null){
                        for(String serElement:contractNumberToServiceElements.get(contractNo)){
                            sObject sObjRecLineItems = Schema.getGlobalDescribe().get(OC_IB_Constants.contractLineItemObject).newSObject();
                            sObjRecLineItems.put(OC_IB_Constants.clineServicePackage,servicePackage);
                            sObjRecLineItems.put(OC_IB_Constants.clinePricebookEntryId,getPriceBookEntryId.get(productNametoId.get(serElement)));
                            sObjRecLineItems.put(OC_IB_Constants.clineServiceEleName,serElement);
                            sObjRecLineItems.put(OC_IB_Constants.clineUnitPrice,1);
                            sObjRecLineItems.put(OC_IB_Constants.clineQuantity,1);
                            sObjRecLineItems.put(OC_IB_Constants.clineContractNoServElement,contractNo+'+'+serElement);
                            sObjRecLineItems.put(OC_IB_Constants.clineServiceContractId,contractNumbersToId.get(contractNo));
                            contractLineItemsList.add((ContractLineItem)sObjRecLineItems);
                        }
                    }
                }
            }
            
            if(contractLineItemsList!=null && !contractLineItemsList.isEmpty()){
                dmlServContractLineItemsResultList=database.upsert(contractLineItemsList,ContractLineItem.OC_CSM_ContractNumber_ServiceElement__c,false);  
                for(integer i=0;i<dmlServContractLineItemsResultList.size();i++){
                    if(dmlServContractLineItemsResultList[i].isSuccess()){
                        List<string> contractNumberServiceElements=contractLineItemsList[i].OC_CSM_ContractNumber_ServiceElement__c.split('\\+');
                        string contractNumber=contractNumberServiceElements[0];
                        if(!islineItemsfailed.isEmpty() && islineItemsfailed.containskey(contractNumber) && islineItemsfailed.get(contractNumber)){
                            upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        }
                        else if(!entitlementFailed.isEmpty() && entitlementFailed.containskey(contractNumber) && entitlementFailed.get(contractNumber)){
                            upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        }
                        else {
                            upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                        }
                        
                    }
                    else{
                        List<string> contractNumberServiceElements=contractLineItemsList[i].OC_CSM_ContractNumber_ServiceElement__c.split('\\+');
                        string contractNumber=contractNumberServiceElements[0];
                        string serviceElement=contractNumberServiceElements[1];
                        upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        Id errorStagingRecId=upsertedResultStageContract.get(contractNumber).id;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.methodCopyContractStagingToActualObject, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlServContractLineItemsResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+serviceElement,false,null,null));
                        islineItemsfailed.put(contractNumber,true);
                    }
                }
                
            }
            /*U-2676 Contract Response Profile-begin*/
            serviceMilestoneUpsertList=processResProfileToMilestone(serviceContractResponseProfile,contractNumbersToId);
            
            if(serviceMilestoneUpsertList!=null && !serviceMilestoneUpsertList.isEmpty()){
                dmlServiceMilestoneResultList=Database.upsert(serviceMilestoneUpsertList,OC_TH_Service_Milestone__c.OC_CSM_ConcatContractNumPriority__c,false);   
                
                for(integer i=0;i<dmlServiceMilestoneResultList.size();i++){
                    if(dmlServiceMilestoneResultList[i].isSuccess()){
                        List<string> contractNumberPriority=serviceMilestoneUpsertList[i].OC_CSM_ConcatContractNumPriority__c.split('\\+');
                        String contractNumber=contractNumberPriority[0];
                        if((islineItemsfailed!=null && !islineItemsfailed.isEmpty() && islineItemsfailed.containskey(contractNumber) && islineItemsfailed.get(contractNumber))||(entitlementFailed!=null && !entitlementFailed.isEmpty() && entitlementFailed.containskey(contractNumber) && entitlementFailed.get(contractNumber)) || responseDurationTypeError!=null && !responseDurationTypeError.isEmpty() && responseDurationTypeError.containsKey(contractNumber) && responseDurationTypeError.get(contractNumber)){
                            upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        }
                        else{
                            upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                        }
                    }
                    else{
                        List<string> contractNumberPriority=serviceMilestoneUpsertList[i].OC_CSM_ConcatContractNumPriority__c.split('\\+');
                        String contractNumber=contractNumberPriority[0];
                        upsertedResultStageContract.get(contractNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                        Id errorStagingRecId=upsertedResultStageContract.get(contractNumber).id;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.methodCopyContractStagingToActualObject, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlServiceMilestoneResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode')+':'+'ServiceMilestone creation failed for Priority'+':'+String.valueOf(serviceMilestoneUpsertList[i].OC_TH_Priority__c),false,null,null));
                    }
                }
            }
            if(!integEventLogInsertList.isEmpty()) {
                EventLog.createIntegrationLog(integEventLogInsertList);
            }
            if(!upsertedResultStageContract.isEmpty()) {
                database.update(upsertedResultStageContract.Values());
            }
        }
    }  
    /**************************************************************************************************
* @Method Name : getPriceBookEntryId
* @Description : fetch the pricebookentryid for the ServiceElements[Products]. 
* @Param       : priceBookId - 
* 
* @Param       : productIds - List of productIds mapped from serviceElements.
* @Return      : Map<String,String> - Map<productId,PricebookEntryid> 
****************************************************************************************************/
    public static Map<String,String> getPriceBookEntryId(String priceBookId,List<id> productIds){
        Map<String,String> productIdToPriceBookEntry= new Map<String,String>();
        List<PricebookEntry> priceBookEntryList=[SELECT Id, Name, Pricebook2Id,isActive, CurrencyIsoCode,Product2Id 
                                                 FROM PricebookEntry where CurrencyIsoCode=:OC_IB_Constants.contractCurrencyCodeValue and pricebook2id=:priceBookId
                                                 and product2id in:productIds];
        for(priceBookEntry pb:priceBookEntryList){
            productIdToPriceBookEntry.put(pb.Product2Id,pb.Id);
        }
        
        return productIdToPriceBookEntry;
    }
    
    
    /**************************************************************************************************
* @Method Name : getPriceBookId
* @Description : fetch the pricebookid for the the ServiceElements[Contract Line Items]. 
* @Param       :Nothing
* @Return      : Id - priceBookid 
****************************************************************************************************/
    public static Id getPriceBookId(){
        OC_Org_Defaults__c mc = OC_Org_Defaults__c.getOrgDefaults();
        Id priceBookid= [select id,name from pricebook2 where name=:mc.OC_PriceBookEntryForProduct__c].Id;
        return priceBookid;
     }
    
    /**************************************************************************************************
* @Method Name : getEntitlementList
* @Description : get Entitlement List to create entitlement records 
* @Param       : List<ServiceContract>
* @Return      : List<Entitlement> 
****************************************************************************************************/
    public static List<Entitlement> getEntitlementList(List<ServiceContract> serviceContractList){
        List<Entitlement> entitleList=new List<Entitlement>();
        
        if(serviceContractList!=null && !serviceContractList.isEmpty()){
            for(ServiceContract Sc:serviceContractList){
                sObject sObjRecEntitlement = Schema.getGlobalDescribe().get(OC_IB_Constants.objectEntitlement).newSObject();
                
                sObjRecEntitlement.put(OC_IB_Constants.name,Sc.Name);
                sObjRecEntitlement.put(OC_IB_Constants.AccountId,Sc.AccountId);
                sObjRecEntitlement.put(OC_IB_Constants.serviceContractId,Sc.Id);
                sObjRecEntitlement.put(OC_IB_Constants.startDate,Sc.StartDate);
                sObjRecEntitlement.put(OC_IB_Constants.endtDate,Sc.EndDate);
                sObjRecEntitlement.put(OC_IB_Constants.entitlementNumber,Sc.OC_MD_Contract_Number__c);
                
                entitleList.add((Entitlement)sObjRecEntitlement);
            }}
        return entitleList;
    }
    
    /**************************************************************************************************
* @Method Name : updateContractEntitlementLookup
* @Description : Update Contract Entitlement Lookup Value
* @Param       : List<Entitlement>
* @Return      : Nothing
****************************************************************************************************/
    
    public static void updateContractEntitlementLookup(List<Entitlement> entitlementRecords){
        Database.SaveResult[] updateContractLookupList;
        List<ServiceContract> updateserviceContract=new List<ServiceContract>();
        if(entitlementRecords!=null && !entitlementRecords.isEmpty())
            for(Entitlement en:entitlementRecords){
                ServiceContract sc=new ServiceContract();
                sc.id=en.serviceContractId;
                sc.OC_TH_Entitlement__c=en.id;
                updateserviceContract.add(sc);
            }
        
        if(!updateserviceContract.isEmpty()){
            updateContractLookupList=Database.update(updateserviceContract,false);
        }
    }
  /*U-2676 Contract Response Profile-begin*/

    /**************************************************************************************************
* @Method Name : processResProfileToMilestone
* @Description : method to return list of serviceMilestone records to process responseProfiles as serviceMilestones.
* @Param       : Map<String,String> serContractsToResProfile,Map<String,String> contractNumbersToId
* @Return      : List<OC_TH_Service_Milestone__c>
****************************************************************************************************/

    public static List<OC_TH_Service_Milestone__c> processResProfileToMilestone(Map<String,String> serContractsToResProfile,Map<String,String> contractNumbersToId){
        Map<String,SObject> serviceMilestonesToUpsertMap=new Map<String,Sobject>();
        Map<String,String> milestonePriorities=OC_Utility.getObjectPicklistValues(OC_IB_Constants.serviceMilestoneObject,OC_IB_Constants.priorityField,OC_IB_Constants.toUpperCase);
        List<OC_TH_Service_Milestone__c> serviceMilestoneUpsertList= new List<OC_TH_Service_Milestone__c>();
        Map<String,String> responseProfileMetadataRecrdsMap=getResponseProfileMetadataRecords();
        
        if( serContractsToResProfile!=null && !serContractsToResProfile.isEmpty()){
            for(String conNumber:serContractsToResProfile.Keyset()){
                if(contractNumbersToId!=null && !contractNumbersToId.isEmpty() && contractNumbersToId.containsKey(conNumber) && contractNumbersToId.get(conNumber)!=null && serContractsToResProfile!=null && !serContractsToResProfile.isEmpty() && serContractsToResProfile.containsKey(conNumber) && serContractsToResProfile.get(conNumber)!=null){
                    List<Object> resProfileRecs=(List<Object>)JSON.deserializeUntyped(serContractsToResProfile.get(conNumber));
                    for(Object resRec:resProfileRecs){
                        sObject sObjRecServMileStone = Schema.getGlobalDescribe().get(OC_IB_Constants.serviceMilestoneObject).newSObject();
                        Map<String, Object> resObjectRecData = (Map<String, Object>) resRec;
                        String fieldApiName;
                        String responseDurationPriority=String.valueOf(resObjectRecData.get(OC_IB_Constants.responseDurationPriority)).toUpperCase();
                        String responseDurationType=String.valueOf(resObjectRecData.get(OC_IB_Constants.responseDurationType));
                        String timeUnit=String.valueOf(resObjectRecData.get(OC_IB_Constants.timeUnit));
                        String timeValue=String.valueOf(resObjectRecData.get(OC_IB_Constants.timeValue));
                        
                        String milestonePriority=String.isNotBlank(responseDurationPriority)?responseDurationPriority : null;
                        String concatContractNumToPriority=conNumber+'+'+milestonePriority;
                        
                        String convertedTimevalue=convertTimeUnitsforMilestone(timeUnit,timeValue);
                        if(responseProfileMetadataRecrdsMap!=null && !responseProfileMetadataRecrdsMap.isEmpty() && responseProfileMetadataRecrdsMap.containsKey(responseDurationType)){
                            fieldApiName=responseProfileMetadataRecrdsMap.get(responseDurationType);
                        }
                        if(String.isNotBlank(fieldApiName)){
                            if(serviceMilestonesToUpsertMap!=null && !serviceMilestonesToUpsertMap.isEmpty() && serviceMilestonesToUpsertMap.containsKey(concatContractNumToPriority)){
                                serviceMilestonesToUpsertMap.get(concatContractNumToPriority).put(fieldApiName,convertedTimevalue);
                            }
                            else{
                                sObjRecServMileStone.put(OC_IB_Constants.serviceMilestoneExtKey,concatContractNumToPriority);
                                sObjRecServMileStone.put(fieldApiName,convertedTimevalue);
                                sObjRecServMileStone.put(OC_IB_Constants.priorityField,milestonePriorities.get(responseDurationPriority));
                                sObjRecServMileStone.put(OC_IB_Constants.serviceMileStoneContract,contractNumbersToId.get(conNumber));
                                serviceMilestonesToUpsertMap.put(concatContractNumToPriority,sObjRecServMileStone); 
                            }
                        }
                        else{
                            if(String.isNotBlank(responseDurationPriority)){
                                Id errorStagingRecId=upsertedResultStageContract.get(conNumber).id;
                                upsertedResultStageContract.get(conNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.processResProfileToMilestone, null, true,null,OC_IB_Constants.Sfdc_Ebip_CSM_inApi,null,false,false,false,true,false,errorStagingRecId,OC_IB_Constants.responseDurationTypeBlank,false,null,null));
                                responseDurationTypeError.put(conNumber,True);   
                            }else{
                                Id errorStagingRecId=upsertedResultStageContract.get(conNumber).id;
                                upsertedResultStageContract.get(conNumber).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.processResProfileToMilestone, null, true,null,OC_IB_Constants.Sfdc_Ebip_CSM_inApi,null,false,false,false,true,false,errorStagingRecId,OC_IB_Constants.responseDurationType_PriorityBlank,false,null,null));
                                responseDurationTypeError.put(conNumber,True);      
                            }
                        }
                    }
                }
            }
        }
        if(serviceMilestonesToUpsertMap!=null && !serviceMilestonesToUpsertMap.isEmpty()){
            serviceMilestoneUpsertList.addAll((List<OC_TH_Service_Milestone__c>)serviceMilestonesToUpsertMap.values());
        }
        return serviceMilestoneUpsertList;
    }
   
    /**************************************************************************************************
* @Method Name : convertTimeUnitsforMilestone
* @Description : method to return converted timevalue for the given timeunit and timevalue.
* @Param       : String timeunit,String timevalue
* @Return      : String
****************************************************************************************************/ 
    public static String convertTimeUnitsforMilestone(String timeunit,String timevalue){
        String convertedTimevalue='';
        if(String.isNotBlank(timeunit) && String.isNotBlank(timevalue)){
            if(timeunit.equalsIgnoreCase(OC_IB_Constants.minute)){
                convertedTimevalue=timevalue;  
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.hour)){
                convertedTimevalue=String.valueOf(Integer.valueOf(timevalue)*OC_IB_Constants.hourToMinutes);
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.day)){
                convertedTimevalue=String.valueOf(Integer.valueOf(timevalue)*OC_IB_Constants.dayToMinutes);
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.month)){
                convertedTimevalue=String.valueOf(Integer.valueOf(timevalue)*OC_IB_Constants.monthToMinutes);
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.quarter)){
                convertedTimevalue=String.valueOf(Integer.valueOf(timevalue)*OC_IB_Constants.quarterToMinutes);
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.second)){
                convertedTimevalue=String.valueOf((Decimal.valueOf(timevalue)/Decimal.valueOf(OC_IB_Constants.hourToMinutes)).round(system.RoundingMode.CEILING));
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.week)){
                convertedTimevalue=String.valueOf(Integer.valueOf(timevalue)*OC_IB_Constants.weekToMinutes);
            }
            else if(timeunit.equalsIgnoreCase(OC_IB_Constants.year)){
                convertedTimevalue=String.valueOf(Integer.valueOf(timevalue)*OC_IB_Constants.yearToMinutes);
            }
        }
        else{
            convertedTimevalue=OC_IB_Constants.timeValueZero;
            
        }
        return convertedTimevalue;
        
    }
    /**************************************************************************************************
* @Method Name : getResponseProfileMetadataRecords
* @Description : method to create map of response profile's duration type as key and its respective serviceMilestones fieldApiName as value.
* @Param       : None
* @Return      : Map<String,String>
****************************************************************************************************/  
    public static Map<String,String> getResponseProfileMetadataRecords(){
        String soql;
        Map<String,String> responseProfileMetadataRecrdsMap=new Map<String,String>();
        soql='SELECT Id,OC_CSM_FieldLabel__c,OC_CSM_FieldApiName__c	FROM OC_CSM_ResponseProfileType__mdt';
        for(OC_CSM_ResponseProfileType__mdt resProRec:Database.query(soql)){
            responseProfileMetadataRecrdsMap.put(resProRec.OC_CSM_FieldLabel__c,resProRec.OC_CSM_FieldApiName__c);  
        }
        return responseProfileMetadataRecrdsMap;
    }
    
     /**************************************************************************************************
* @Method Name : CopySapOrderFromStagingToActualObject
* @Description : upserts the staging object records into Cost Collector object
* @Return      : void
****************************************************************************************************/     
    Public Static Void CopyContractSapOrderFromStagingToActualObj(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){
        
        String objectName;
        List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList;
        Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapActualobjFieldToMdtRec = new Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> ();
        List<OC_Cost_Collector__c> costCollectorList=new List<OC_Cost_Collector__c>();
        Database.UpsertResult[] dmlcostCollectorResultList;
        Map<String,sObject> contractNumberSobjectMap = new Map<String,sObject>();
        Set<String> contractNumberSet = new Set<String>();
        Map<String,String> contractNumberToId = new Map<String,String>();
        
        inboundFieldMappingMdtRecordList = OC_IB_Utility.getInboundIntegrationFieldMappingMdtRecords(integrationIdentifier);
        objectName = inboundFieldMappingMdtRecordList[0].OC_IB_SfdcObjectApiName__c;
        
        if(inboundFieldMappingMdtRecordList!=null && !inboundFieldMappingMdtRecordList.isEmpty()){
            
            mapActualobjFieldToMdtRec = OC_IB_Utility.getActualobjFieldToMdtRecMapping (inboundFieldMappingMdtRecordList);
            
            for(OC_IB_IntegrationSobjectRecords__c stagedRec : stagedRecList){
                errorStagingRecordId = stagedRec.Id;
                errorStagingrecord = stagedRec;
                sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();
                
                for(String FieldName : mapActualobjFieldToMdtRec.Keyset()){
                    OC_IB_InboundIntegrationFieldMapping__mdt mdtRec = mapActualobjFieldToMdtRec.get(FieldName);
                    if(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c) != null){
                        sObjRec = OC_IB_Utility.DataMapping(mdtRec,sObjRec,FieldName,stagedRec,null,null);
                    }else{
                        sObjRec.Put(FieldName,null);    
                    }
                }
                sObjRec.put(OC_IB_Constants.currencyCode,OC_IB_Constants.contractCurrencyCodeValue);
                sObjRec.put(OC_IB_Constants.concatContractNetworkIdServiceOrder,String.valueOf(stagedRec.get(OC_IB_Constants.concatContractNetworkServiceOrder)));
                upsertedResultStageContract.put(String.valueOf(stagedRec.get(OC_IB_Constants.contractNumber)),stagedRec);
                
                contractNumberSet.add(String.valueOf(stagedRec.get(OC_IB_Constants.contractNumber)));
                contractNumberSobjectMap.put(String.valueOf(stagedRec.get(OC_IB_Constants.contractNumber)),sObjRec);
            }
            for(ServiceContract servContract: [select Id, Name,OC_MD_Contract_Number__c from ServiceContract where OC_MD_Contract_Number__c IN: contractNumberSet]){
                contractNumberToId.put(servContract.OC_MD_Contract_Number__c,servContract.Id);
            }
            
            for(String contractNum:contractNumberSobjectMap.keyset()){
                Sobject sObjRec = contractNumberSobjectMap.get(contractNum);
                
                //Added if else to check if the contract number is available in Service Contract
                if(contractNumberToId.containsKey(contractNum)){
                    Sobject sObj = contractNumberSobjectMap.get(contractNum).clone();
                    sObj.put(OC_IB_Constants.serviceContract,contractNumberToId.get(contractNum));
                    costCollectorList.add((OC_Cost_Collector__c)sObj);
                }
                else{
                    Id errorStagingRecId=upsertedResultStageContract.get(string.valueof(contractNum)).id;
                    upsertedResultStageContract.get(string.valueof(contractNum)).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncErrorStatus;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler, OC_IB_Constants.methodCopyContractSapOrderFromStagingToActualObj, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),OC_IB_Constants.errorMessage,false,null,null));
                } 
            }
            
            if(costCollectorList!=null && !costCollectorList.isEmpty()){                
                dmlcostCollectorResultList=database.upsert(costCollectorList,OC_Cost_Collector__c.OC_CC_concatContractNetworkServiceOrder__c,false);
                for(integer i=0;i<dmlcostCollectorResultList.size();i++){
                    if(dmlcostCollectorResultList[i].isSuccess()){
                        upsertedResultStageContract.get(costCollectorList[i].OC_CC_Contract_Number__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                    }
                    else{
                        Id errorStagingRecId=upsertedResultStageContract.get(costCollectorList[i].OC_CC_Contract_Number__c).id;
                        upsertedResultStageContract.get(costCollectorList[i].OC_CC_Contract_Number__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncErrorStatus;
                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classCSMStagedObjToActualObjMapingHandler,OC_IB_Constants.methodCopyContractSapOrderFromStagingToActualObj, null, true,null,integrationIdentifier,null,false,false,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlcostCollectorResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));    
                    }
                }
            }
        }
        if(!integEventLogInsertList.isEmpty()) {
            EventLog.createIntegrationLog(integEventLogInsertList);
        }
        if(!upsertedResultStageContract.isEmpty()) {
            database.update(upsertedResultStageContract.Values());
        }
    }
}