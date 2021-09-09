/**
* @File Name          : OC_PRD_StagedObjToActualObjMapingHandler
* @Description        : Handler class for OC_CSM_BATCH_StagedDataProcessor - migrates the integration data from Staging object to Actual object.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 27th May 2021
* @Modification Log   :
*==================================================================================
* Ver         Date                     Author                Modification
*==================================================================================
* 1.0        2021-05-27                IBM                   U-2818 Initial Version
* 1.1        2021-07-22                IBM                   U-3067 Initial Version
* 1.2        2021-07-22                IBM                   U-3069 Initial Version
**/
public class OC_PRD_StagedObjToActualObjMapingHandler {
    Public Static List<EventLog.integrationEventLog> integEventLogInsertList = new List<EventLog.integrationEventLog> ();
    Public Static Map<String,OC_IB_IntegrationSobjectRecords__c> upsertedResultStageProduct=new Map<String,OC_IB_IntegrationSobjectRecords__c>();
    Public Static OC_IB_IntegrationSobjectRecords__c errorStagingrecord;
    Public Static String errorStagingRecordId;

/**************************************************************************************************
* @Method Name : copyDataFromStagingObjToActualObj
* @Description : upserts the staging object records into actual object.
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing
****************************************************************************************************/

    Public Static Void copyDataFromStagingObjToActualObj(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){

        try {//U-3067 Start Start
                if (integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_NtSolnComp_InApi)) {
                    CopyPRDNodeTypeSolnCompStagingToActualObj (integrationIdentifier,stagedRecList);
                }else {
                    CopyProductStagingToActualObject (integrationIdentifier,stagedRecList);
                }
                //U-3067 Start End
        }catch (Exception excp) {
                integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler, OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj, null, true,excp,integrationIdentifier,null,false,true,false,true,false,errorStagingRecordId,null,false,null,null));
                EventLog.createIntegrationLog (integEventLogInsertList);
            if (errorStagingrecord != null) {
                errorStagingrecord.OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncErrorStatus;
                database.update (errorStagingrecord);
            }
        }

    }
    /**************************************************************************************************
* @Method Name : CopyProductStagingToActualObject
* @Description : processing staging object records into actual object.
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing
****************************************************************************************************/
    Public Static Void CopyProductStagingToActualObject(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){

        List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList;
        List<PricebookEntry> lstPriceBookEntry = new List<PricebookEntry>();
        List<OC_IB_IntegrationSobjectRecords__c> lstSuccessStagingRecWithRelease = new List<OC_IB_IntegrationSobjectRecords__c>();
        List<OC_IB_IntegrationSobjectRecords__c> lstSucessReleaseRecWithVersion = new List<OC_IB_IntegrationSobjectRecords__c>();
        String objectName;
        Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapActualobjFieldToMdtRec = new Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> ();
        Map<String,Id> mapStagingFieldValueToSfId = new Map<String,Id> ();
        Map<String,String>  mapProductIdToName = new map<String,String>();
        Map<String,Sobject> upsertProductSobjectRec = new map<String,Sobject>();
        Map<String,List<OC_IB_IntegrationSobjectRecords__c>> mapProductCodeStagingObj = new map<String,List<OC_IB_IntegrationSobjectRecords__c>>();
        Map<String,String>  mapProductNameToId = new map<String,String>();
        Map<String,Map<String,String>> getPriceBookEntryId = new  Map<String,Map<String,String>>();
        Map<String,OC_MD_ProductAttributes__c> upsertProductRelease = new  Map<String,OC_MD_ProductAttributes__c>();
        Map<String, Pricebook2> priceBooks;
        Map<String,OC_MD_ProductAttributes__c> upsertProductVersion = new  Map<String,OC_MD_ProductAttributes__c>();
		Map<String, Product2> mapOfProductsInSF = new Map<String, Product2>();
        Map<String,String> productReleaseId = new Map<String,String>();
        String recTypeId;
        Map<String,OC_IB_IntegrationSobjectRecords__c> mapPcodeKeyStagingObj = new Map<String,OC_IB_IntegrationSobjectRecords__c>();
        List<OC_MD_Product_Relation__c> upsertPcodePlatformRec = new List<OC_MD_Product_Relation__c>();
        Map<String,List<OC_IB_IntegrationSobjectRecords__c>> mapPrdPcodeCombination = new Map<String,List<OC_IB_IntegrationSobjectRecords__c>>();
        List<OC_IB_IntegrationSobjectRecords__c> lstStagingBadData = new List<OC_IB_IntegrationSobjectRecords__c>();

        Database.UpsertResult[] dmlProductResultList;
        Database.SaveResult[] 	dmlPriceBookEntryResultList;
        Database.UpsertResult[] dmlProductReleaseResultList;
        Database.UpsertResult[] dmlProductVersionResultList;
        Database.UpsertResult[] dmlPcodeRecList;

            priceBooks = OC_PRD_StagedObjToActualObjMapingHelper.getPriceBookId();
            inboundFieldMappingMdtRecordList = OC_IB_Utility.getInboundIntegrationFieldMappingMdtRecords (integrationIdentifier);
            objectName = inboundFieldMappingMdtRecordList[0].OC_IB_SfdcObjectApiName__c;

            If (inboundFieldMappingMdtRecordList != null && !inboundFieldMappingMdtRecordList.isEmpty()) {
                mapActualobjFieldToMdtRec = OC_IB_Utility.getActualobjFieldToMdtRecMapping (inboundFieldMappingMdtRecordList);

                For (OC_IB_IntegrationSobjectRecords__c stagedRec : stagedRecList) {
                     errorStagingRecordId = stagedRec.Id;
                     errorStagingrecord = stagedRec;
                     recTypeId = OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName (ObjectName,stagedRec.RecordType.DeveloperName,OC_IB_Constants.sObjectRecordTypeId);
                     sObject sObjRec = Schema.getGlobalDescribe().get(ObjectName).newSObject();

                    For (String FieldName : mapActualobjFieldToMdtRec.Keyset()) {
                         OC_IB_InboundIntegrationFieldMapping__mdt mdtRec = mapActualobjFieldToMdtRec.get(FieldName);

                            If (stagedRec.get (mdtRec.OC_IB_StagingObjectFieldApiName__c) != null) {
                                sObjRec = OC_IB_Utility.DataMapping (mdtRec,sObjRec,FieldName,stagedRec,OC_IB_Constants.mapStagingFieldValueToSfIdNotEmpty,mapStagingFieldValueToSfId);
                      	        sObjRec.Put(OC_IB_Constants.active,True);
                                sObjRec.Put(OC_IB_Constants.productRecordType,recTypeId);
								sObjRec.Put(OC_IB_Constants.productNameRecordTypeId,stagedRec.name+OC_IB_Constants.seprator+recTypeId);
                                //P-Code Start
                                If(stagedRec.RecordType.DeveloperName.equalsIgnoreCase(OC_IB_Constants.stagingObjProductSolutionRt) || stagedRec.RecordType.DeveloperName.equalsIgnoreCase(OC_IB_Constants.stagingObjProductNodeComponentRt) ) {
                                    sObjRec.put(OC_IB_Constants.prdPcode,stagedRec.OC_PRD_Pcode__c);
                                 }
                                //P-Code End
                            If (stagedRec.OC_PRD_Product_PlatformName__c != null && !String.isBlank(stagedRec.OC_PRD_Product_PlatformName__c))
                                sObjRec.put(OC_IB_Constants.productPlatform,stagedRec.OC_PRD_Product_PlatformName__c);
                            }else {
                                sObjRec.Put(FieldName,null);
                                }
                    }

                        String productExternalId = (String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecProductCode))+OC_IB_Constants.seprator+
                                                    recTypeId).toLowercase();

                    	upsertProductSobjectRec.put(productExternalId,sObjRec);

                    if(!mapProductCodeStagingObj.containskey(productExternalId)) {

                        mapProductCodeStagingObj.put(productExternalId,new list<OC_IB_IntegrationSobjectRecords__c>());

                    }
                	    mapProductCodeStagingObj.get(productExternalId).add(stagedRec);

                        upsertedResultStageProduct.put(String.valueOf(stagedRec.get(OC_IB_Constants.stagedRecProductReleaseVersionNumber)),stagedRec);

                }
                // Upsert Product
                If  (upsertProductSobjectRec != null && !upsertProductSobjectRec.isEmpty()) {
                     dmlProductResultList = database.upsert(upsertProductSobjectRec.values(),Product2.OC_PRD_TechProductNameRecordTypeId__c,false);

                    For (Integer i = 0; i < dmlProductResultList.size(); i++) {
                            Product2 productSuccessRec = ((List<Product2>)upsertProductSobjectRec.values())[i];
                        If (dmlProductResultList[i].isSuccess()) {

                            mapProductIdToName.put(productSuccessRec.id,(productSuccessRec.name+OC_IB_Constants.seprator+productSuccessRec.RecordTypeId).toLowercase());//pramada-added
                            mapProductNameToId.put((productSuccessRec.name+OC_IB_Constants.seprator+productSuccessRec.RecordTypeId).toLowercase(),
                                                    productSuccessRec.id);

                            For (OC_IB_IntegrationSobjectRecords__c stagingObject : mapProductCodeStagingObj.get((productSuccessRec.name+
                                                                                    OC_IB_Constants.seprator+productSuccessRec.RecordTypeId).toLowercase())) {

                                //P-code Start
                                If(OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName(OC_IB_Constants.objectintegSobjRecords,stagingObject.RecordTypeId,OC_IB_Constants.sObjectRecordTypeName) == OC_IB_Constants.ProductNodeTypeRt && !String.isBlank(stagingObject.OC_PRD_Platform_Pcode__c)){

                                    String prdPcodePlatformCombination = (stagingObject.name+OC_IB_Constants.seprator+stagingObject.OC_PRD_Platform_Pcode__c).toLowerCase();

                                    If (!mapPrdPcodeCombination.containsKey(prdPcodePlatformCombination)){
                                        mapPrdPcodeCombination.put(prdPcodePlatformCombination,new List<OC_IB_IntegrationSobjectRecords__c> {stagingObject});

                                        For(String objPlatformPcode : stagingObject.OC_PRD_Platform_Pcode__c.split('";"')){

                                            If(!objPlatformPcode.contains(OC_IB_Constants.nullValue)){
                                                String platformPcode = objPlatformPcode.remove('"');
                                                String pcodePlatformExtId = (stagingObject.name+OC_IB_Constants.seprator+platformPcode).toLowerCase();
                                                mapPcodeKeyStagingObj.put(pcodePlatformExtId,stagingObject);
                                            }Else{
                                                lstStagingBadData.add(stagingObject);
                                                }

                                        }
                                            }Else {
                                                    mapPrdPcodeCombination.get(prdPcodePlatformCombination).add(stagingObject);
                                                }
                                }


                                        //P-code End


                                If (stagingObject.OC_PRD_Release_Name__c != null && !String.isBlank(stagingObject.OC_PRD_Release_Name__c)) {
                                    lstSuccessStagingRecWithRelease.add(stagingObject);
                                }

                                    upsertedResultStageProduct.get(stagingObject.OC_PRD_TechConcatProductRelease__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                            }
                        } else {
                                For (OC_IB_IntegrationSobjectRecords__c stagingObject : mapProductCodeStagingObj.get((productSuccessRec.name+
                                                                                        OC_IB_Constants.seprator+productSuccessRec.RecordTypeId).toLowercase())) {
                                    Id errorStagingRecId = upsertedResultStageProduct.get(stagingObject.OC_PRD_TechConcatProductRelease__c).id;
                                    upsertedResultStageProduct.get(stagingObject.OC_PRD_TechConcatProductRelease__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncErrorStatus;
                                    integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler,
                                                                                            OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj,null,true,null,integrationIdentifier,
                                                                                            null,false,true,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlProductResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                            }
                        }
                    }
                }
                // Upsert PricebookEntry
                If  (mapProductNameToId != null && !mapProductNameToId.isEmpty()) {
                     If(priceBooks != null)
                      	getPriceBookEntryId = OC_PRD_StagedObjToActualObjMapingHelper.getPriceBookEntryId(priceBooks,mapProductNameToId.values());

                    For (String productId : mapProductNameToId.values()) {

                        If( priceBooks.containskey(OC_IB_Constants.PC_NAME_STANDARD_PRICE_BOOK) && ( (getPriceBookEntryId.isEmpty()
                            || !getPriceBookEntryId.containskey(OC_IB_Constants.PC_NAME_STANDARD_PRICE_BOOK))
                            || (getPriceBookEntryId.containskey(OC_IB_Constants.PC_NAME_STANDARD_PRICE_BOOK)
                            && !getPriceBookEntryId.get(OC_IB_Constants.PC_NAME_STANDARD_PRICE_BOOK).containskey(productId) ) ) ) {
                                lstPriceBookEntry.add(OC_PRD_StagedObjToActualObjMapingHelper.createPriceBookEntry(productId,priceBooks.get(OC_IB_Constants.PC_NAME_STANDARD_PRICE_BOOK).id));
                        }
                        If( priceBooks.containskey(OC_IB_Constants.PC_NAME_SERVICE_CATALOG) &&((getPriceBookEntryId.isEmpty()
                            || !getPriceBookEntryId.containskey(OC_IB_Constants.PC_NAME_SERVICE_CATALOG))
                            || (getPriceBookEntryId.containskey(OC_IB_Constants.PC_NAME_SERVICE_CATALOG)
                            && !getPriceBookEntryId.get(OC_IB_Constants.PC_NAME_SERVICE_CATALOG).containskey(productId) ) ) ) {
                                lstPriceBookEntry.add(OC_PRD_StagedObjToActualObjMapingHelper.createPriceBookEntry(productId,priceBooks.get(OC_IB_Constants.PC_NAME_SERVICE_CATALOG).id));
                        }
                    }

                    If(lstPriceBookEntry != null && !lstPriceBookEntry.isEmpty()){
                       dmlPriceBookEntryResultList = database.insert(lstPriceBookEntry,false);
                    for(Integer i=0; i<dmlPriceBookEntryResultList.size(); i++){

                        if(dmlPriceBookEntryResultList[i].isSuccess()){

                            for(OC_IB_IntegrationSobjectRecords__c stagingObject:mapProductCodeStagingObj.get(mapProductIdToName.get(lstPriceBookEntry[i].Product2Id))){
                                upsertedResultStageProduct.get(stagingObject.OC_PRD_TechConcatProductRelease__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                            }
                        }
                        else{
                            for(OC_IB_IntegrationSobjectRecords__c stagingObject:mapProductCodeStagingObj.get(mapProductIdToName.get(lstPriceBookEntry[i].Product2Id))){
                                IF(lstSuccessStagingRecWithRelease.indexOf(stagingObject) != OC_IB_Constants.emptyIndexValue)
                                   lstSuccessStagingRecWithRelease.remove(lstSuccessStagingRecWithRelease.indexOf(stagingObject));
                                   Id errorStagingRecId=upsertedResultStageProduct.get(stagingObject.OC_PRD_TechConcatProductRelease__c).id;
                             	   integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler, OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj, null, true,null,integrationIdentifier,null,false,true,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlPriceBookEntryResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                                   upsertedResultStageProduct.get(stagingObject.OC_PRD_TechConcatProductRelease__c).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;

                            }
                        }
                    }
                }

                // Release process
                    If(lstSuccessStagingRecWithRelease != null && !lstSuccessStagingRecWithRelease.isEmpty()){
                        upsertProductRelease = OC_PRD_StagedObjToActualObjMapingHelper.createRelease(objectName,lstSuccessStagingRecWithRelease,mapProductNameToId );

                        If(upsertProductRelease !=null && !upsertProductRelease.isEmpty()) {
                            dmlProductReleaseResultList = database.upsert(upsertProductRelease.values(),OC_MD_ProductAttributes__c.OC_PRD_TechProductRelease__c,false);
                            For(integer i=0;i<dmlProductReleaseResultList.size();i++){
								OC_MD_ProductAttributes__c releaseRec = ((List<OC_MD_ProductAttributes__c>)upsertProductRelease.values())[i];
								String productReleaseExternalId = (releaseRec.OC_PRD_TechProductRelease__c).substringBeforeLast(OC_IB_Constants.seprator)+OC_IB_Constants.seprator+OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName(objectName,(releaseRec.OC_PRD_TechProductRelease__c.substringAfterLast(OC_IB_Constants.seprator)), OC_IB_Constants.sObjectRecordTypeName) ;
                                If(dmlProductReleaseResultList[i].isSuccess()){

                                    IF(upsertedResultStageProduct.get(productReleaseExternalId).OC_PRD_VersionName__c!=null && !String.isBlank(upsertedResultStageProduct.get(productReleaseExternalId).OC_PRD_VersionName__c)) {
                                        lstSucessReleaseRecWithVersion.add(upsertedResultStageProduct.get(productReleaseExternalId));
                                    }
                                    productReleaseId.put(productReleaseExternalId,releaseRec.id);
                                    upsertedResultStageProduct.get(productReleaseExternalId).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncSuccessStatus;

                                } else {
                                     	Id errorStagingRecId = upsertedResultStageProduct.get(productReleaseExternalId).id;
                                        upsertedResultStageProduct.get(productReleaseExternalId).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncPartialStatus;
                                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler,
                                                                                                OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj, null, true,null,integrationIdentifier,
                                                                                                null,false,true,false,true,false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlProductReleaseResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));
                                }
                            }

                        }

                    }
                // Version Process

                    If(lstSucessReleaseRecWithVersion != null && !lstSucessReleaseRecWithVersion.isEmpty()) {
                        upsertProductVersion = OC_PRD_StagedObjToActualObjMapingHelper.createVersion(objectName,lstSucessReleaseRecWithVersion, productReleaseId);

                        If(upsertProductVersion != null && !upsertProductVersion.isEmpty()) {
                            dmlProductVersionResultList = database.upsert(upsertProductVersion.values(),OC_MD_ProductAttributes__c.OC_PRD_TechProductReleaseVersion__c,false);

                            for(Integer i = 0; i < dmlProductVersionResultList.size(); i++){
                                OC_MD_ProductAttributes__c versionRec = ((List<OC_MD_ProductAttributes__c>)upsertProductVersion.values())[i];
								String stagingExternalId = (versionRec.OC_PRD_TechProductReleaseVersion__c.substringBeforeLast(OC_IB_Constants.seprator)).substringBeforeLast(OC_IB_Constants.seprator)+OC_IB_Constants.seprator+OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName(objectName,(versionRec.OC_PRD_TechProductReleaseVersion__c.substringAfterLast(OC_IB_Constants.seprator)), OC_IB_Constants.sObjectRecordTypeName);

                                if(dmlProductVersionResultList[i].isSuccess()){
                                    upsertedResultStageProduct.get(stagingExternalId).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncSuccessStatus;
                                } else {
                                        Id errorStagingRecId=upsertedResultStageProduct.get(stagingExternalId).id;
                                        upsertedResultStageProduct.get(stagingExternalId).OC_IB_ActualObjectSyncStatus__c=OC_IB_Constants.syncPartialStatus;
                                        integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler,OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj, null, true,null,integrationIdentifier,null,false,true,false,true,
                                                                    false,String.ValueOf(errorStagingRecId),String.ValueOf(dmlProductVersionResultList[i].getErrors()).substringBetween('getMessage=', ';getStatusCode'),false,null,null));

                                }

                            }


                        }


                    }

                }
                // U- 2936 Not Valid Customer Start
                if(lstSuccessStagingRecWithRelease != null && !lstSuccessStagingRecWithRelease.isEmpty() && !OC_PRD_StagedObjToActualObjMapingHelper.mapNotValidStagingRec.isEmpty()) {
                   upsertedResultStageProduct.putAll(OC_PRD_StagedObjToActualObjMapingHelper.mapNotValidStagingRec);
                   integEventLogInsertList.addAll(OC_PRD_StagedObjToActualObjMapingHelper.listNotValidStagingRecEventLog);
                }// U- 2936 Not Valid Customer End

                // P-code Process
                If(mapPcodeKeyStagingObj !=null && !mapPcodeKeyStagingObj.isEmpty()) {
                    upsertPcodePlatformRec = OC_PRD_StagedObjToActualObjMapingHelper.createPcodeRec(mapPcodeKeyStagingObj,mapProductNameToId);

                    If(upsertPcodePlatformRec!=null && !upsertPcodePlatformRec.isEmpty()) {
                        dmlPcodeRecList = database.upsert(upsertPcodePlatformRec,OC_MD_Product_Relation__c.OC_PRD_TechNodeTypeExtId__c,false);

                        For(integer i = 0; i < dmlPcodeRecList.size(); i++){

                            if(!dmlPcodeRecList[i].isSuccess()){
                                OC_MD_Product_Relation__c prdRelationRec = ((List<OC_MD_Product_Relation__c>)upsertPcodePlatformRec)[i];
                                OC_IB_IntegrationSobjectRecords__c objPcodeStagingRec = mapPcodeKeyStagingObj.get(prdRelationRec.OC_PRD_TechNodeTypeExtId__c);
                                For(OC_IB_IntegrationSobjectRecords__c lstStagingRecords : mapPrdPcodeCombination.get(objPcodeStagingRec.name+OC_IB_Constants.seprator+objPcodeStagingRec.OC_PRD_Platform_Pcode__c)){
                                    OC_PRD_StagedObjToActualObjMapingHelper.createEventLog(upsertedResultStageProduct, lstStagingRecords.OC_PRD_TechConcatProductRelease__c, OC_IB_Constants.syncPartialStatus, String.ValueOf(dmlPcodeRecList[i].getErrors()).substringBetween(OC_IB_Constants.getEventLogMessage, OC_IB_Constants.getStatusCode), OC_IB_Constants.Sfdc_Ebip_PRD_inApi);
                                }

                            }
                        }
                    }
                }
                If(lstStagingBadData!=null && !lstStagingBadData.isEmpty()) {
                    For(OC_IB_IntegrationSobjectRecords__c lstStagingRecords : lstStagingBadData){
                        OC_PRD_StagedObjToActualObjMapingHelper.createEventLog(upsertedResultStageProduct, lstStagingRecords.OC_PRD_TechConcatProductRelease__c, OC_IB_Constants.syncPartialStatus,OC_IB_Constants.pcodeErrormsg, OC_IB_Constants.Sfdc_Ebip_PRD_inApi);
                    }
                }
                // P-code End
                if(integEventLogInsertList != null && !integEventLogInsertList.isEmpty()) {
                   EventLog.createIntegrationLog(integEventLogInsertList);
                }
                if(upsertedResultStageProduct !=null && !upsertedResultStageProduct.isEmpty()) {
                   database.update(upsertedResultStageProduct.Values());
                }

            }

    }//U-3067 Start
/**************************************************************************************************
* @Method Name : CopyPRDNodeTypeSolnCompStagingToActualObj
* @Description : processing NodetypeSolution and NodetypeNodeComponent staging object records into actual object.
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : stagedRecList - List of staging object records which needs to be upserted into actual object.
* @Return      : Void - Nothing
****************************************************************************************************/
    Public Static Void CopyPRDNodeTypeSolnCompStagingToActualObj(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList){
           List<String> lstPrdNodeTypeSolnCompReleaseExtId = new List<String>();
           Map<String,OC_MD_ProductAttributes__c> mapReleaseExtIdObj = new Map <String,OC_MD_ProductAttributes__c> ();
           List<OC_MD_Product_Relation__c> productRelationRec = new List<OC_MD_Product_Relation__c>();

           Database.UpsertResult[] dmlProductRelationResultList;

           For (OC_IB_IntegrationSobjectRecords__c stagedRec : stagedRecList) {
                errorStagingRecordId = stagedRec.Id;
                errorStagingrecord = stagedRec;
                upsertedResultStageProduct.put(stagedRec.OC_PRD_TechConcatProductRelease__c,stagedRec);

                if((String.isBlank(stagedRec.OC_PRD_NodeTypeName__c) || String.isBlank(stagedRec.OC_PRD_NodeTypeSwReleaseName__c))
                || (String.isBlank(stagedRec.OC_PRD_SolutionReleaseName__c) && String.isBlank(stagedRec.OC_PRD_NodeComponentReleaseName__c ))) {
                    OC_PRD_StagedObjToActualObjMapingHelper.createEventLog(upsertedResultStageProduct, stagedRec.OC_PRD_TechConcatProductRelease__c, OC_IB_Constants.syncErrorStatus, OC_IB_Constants.blankInvalidErrorMsg, OC_IB_Constants.Sfdc_Ebip_PRD_inApi);

                } else {
                    String nodeTypeExternalId = stagedRec.OC_PRD_NodeTypeName__c+OC_IB_Constants.seprator+stagedRec.OC_PRD_NodeTypeSwReleaseName__c+OC_IB_Constants.seprator+OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName (OC_IB_Constants.sobjectName,OC_IB_Constants.stagingObjProductRt,OC_IB_Constants.sObjectRecordTypeId);
                    String recTypeId = OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName (OC_IB_Constants.sobjectName,stagedRec.RecordType.DeveloperName,OC_IB_Constants.sObjectRecordTypeId);
                    lstPrdNodeTypeSolnCompReleaseExtId.add(nodeTypeExternalId);

                    If (stagedRec.RecordType.DeveloperName.equalsIgnoreCase(OC_IB_Constants.stagingObjProductNodeTypeSolution)) {
                        String solutionExtId = stagedRec.Name+OC_IB_Constants.seprator+stagedRec.OC_PRD_SolutionReleaseName__c+OC_IB_Constants.seprator+recTypeId;
                        lstPrdNodeTypeSolnCompReleaseExtId.add(solutionExtId);

                    } else { // U-3069 Starts
                        String nodeComponentExtId = stagedRec.Name+OC_IB_Constants.seprator+stagedRec.OC_PRD_NodeComponentReleaseName__c+OC_IB_Constants.seprator+recTypeId;
                        lstPrdNodeTypeSolnCompReleaseExtId.add(nodeComponentExtId);

                    } //U-3069 END

                }

            }

            If(lstPrdNodeTypeSolnCompReleaseExtId != null && !lstPrdNodeTypeSolnCompReleaseExtId.isEmpty()) {
                mapReleaseExtIdObj = OC_PRD_StagedObjToActualObjMapingHelper.getMapExternalIdReleaseObj(lstPrdNodeTypeSolnCompReleaseExtId);
                if(mapReleaseExtIdObj != null && !mapReleaseExtIdObj.isEmpty()) {
                   productRelationRec = OC_PRD_StagedObjToActualObjMapingHelper.createProductReleationObj(upsertedResultStageProduct, stagedRecList, mapReleaseExtIdObj, integrationIdentifier);
                }

                if (productRelationRec != null && !productRelationRec.isEmpty()) {
                    dmlProductRelationResultList = database.upsert(productRelationRec,OC_MD_Product_Relation__c.OC_PRD_TechNodeTypeExtId__c,false);

                    For(integer i = 0; i < dmlProductRelationResultList.size(); i++){
                        OC_MD_Product_Relation__c prdRelationRec = ((List<OC_MD_Product_Relation__c>)productRelationRec)[i];

                        if(dmlProductRelationResultList[i].isSuccess()){
                            upsertedResultStageProduct.get(prdRelationRec.OC_PRD_TechNodeTypeExtId__c).OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncSuccessStatus;

                        } else {
                            OC_PRD_StagedObjToActualObjMapingHelper.createEventLog(upsertedResultStageProduct, prdRelationRec.OC_PRD_TechNodeTypeExtId__c, OC_IB_Constants.syncPartialStatus, String.ValueOf(dmlProductRelationResultList[i].getErrors()).substringBetween(OC_IB_Constants.getEventLogMessage, OC_IB_Constants.getStatusCode), OC_IB_Constants.Sfdc_Ebip_PRD_inApi);

                        }
                    }
                }

            }

            if(integEventLogInsertList != null && !integEventLogInsertList.isEmpty()) {
                EventLog.createIntegrationLog(integEventLogInsertList);
            }
            if(upsertedResultStageProduct !=null && !upsertedResultStageProduct.isEmpty()) {
                database.update(upsertedResultStageProduct.Values());
            }
    }//U-3067 End
}