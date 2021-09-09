/**
* @File Name          : OC_PRD_StagedObjToActualObjMapingHelper
* @Description        : Helper class for OC_PRD_StagedObjToActualObjMapingHandler - migrates the integration data from Staging object to Actual object.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 25th June 2021
* @Modification Log   :
*==================================================================================
* Ver         Date                     Author                Modification
*==================================================================================
* 1.0        2021-06-25                IBM                   U-2936 Initial Version
* 1.1        2021-07-22                IBM                   U-3067 Initial Version
* 1.2        2021-07-22                IBM                   U-3069 Initial Version
**/
public class OC_PRD_StagedObjToActualObjMapingHelper {
	Public Static String prdRecTypeId;
    Public Static Map<String,Id> mapStagingFieldValueToSfId = new Map<String,Id>();
    Public Static Map<String,OC_IB_IntegrationSobjectRecords__c> mapNotValidStagingRec;
    Public Static List<EventLog.integrationEventLog> listNotValidStagingRecEventLog;
/**************************************************************************************************
* @Method Name : createRelease
* @Description : creat release and return map of externalId and release.
* @Param       : objectName - name of the object
* @Param       : lstSuccessPRDWithRelease - List of success product rec with release
* @Param       : mapProductNameToId - map of productname and productid
* @Return      : Map<String,OC_MD_ProductAttributes__c>  - map of externalId and release
****************************************************************************************************/
    public static Map<String,OC_MD_ProductAttributes__c> createRelease(String objectName, List<OC_IB_IntegrationSobjectRecords__c> lstSuccessPRDWithRelease, Map<String,String>  mapProductNameToId) {
            Map<String,OC_MD_ProductAttributes__c> upsertProductRelease = new  Map<String,OC_MD_ProductAttributes__c>();
            mapStagingFieldValueToSfId = OC_IB_Utility.getServiceAccS2PIdToAccIdMapping();
            mapNotValidStagingRec = new Map<String,OC_IB_IntegrationSobjectRecords__c>();
            listNotValidStagingRecEventLog = new List<EventLog.integrationEventLog>();

            for(OC_IB_IntegrationSobjectRecords__c objSuccessStagingRec : lstSuccessPRDWithRelease) {

                            OC_PRD_StagedObjToActualObjMapingHandler.errorStagingRecordId = objSuccessStagingRec.Id;
                		    OC_PRD_StagedObjToActualObjMapingHandler.errorStagingrecord = objSuccessStagingRec;
                            prdRecTypeId = getRecordTypeIdName (objectName,objSuccessStagingRec.RecordType.DeveloperName,OC_IB_Constants.sObjectRecordTypeId);
                            sObject sObjRecProductRelease = Schema.getGlobalDescribe().get(OC_IB_Constants.productAttributeObject).newSObject();
                            sObjRecProductRelease.put(OC_IB_Constants.productReleaseName,objSuccessStagingRec.OC_PRD_Release_Name__c);
                            Date prdReleaseEos = (objSuccessStagingRec.OC_PRD_Release_EOS__c!=null && String.isNotBlank(String.valueof(objSuccessStagingRec.OC_PRD_Release_EOS__c))) ? Date.valueof(objSuccessStagingRec.OC_PRD_Release_EOS__c):null;
                            sObjRecProductRelease.put(OC_IB_Constants.productReleaseEOS,prdReleaseEos);
                            Date prdReleaseEom = (objSuccessStagingRec.OC_PRD_Release_EOM__c!=null && String.isNotBlank(String.valueof(objSuccessStagingRec.OC_PRD_Release_EOM__c))) ? Date.valueof(objSuccessStagingRec.OC_PRD_Release_EOM__c):null;
                            sObjRecProductRelease.put(OC_IB_Constants.productReleaseEOM,prdReleaseEom);
                       	    Date prdReleaseGA = (objSuccessStagingRec.OC_PRD_Release_GA__c!=null && String.isNotBlank(String.valueof(objSuccessStagingRec.OC_PRD_Release_GA__c))) ? Date.valueof(objSuccessStagingRec.OC_PRD_Release_GA__c):null;
                            sObjRecProductRelease.put(OC_IB_Constants.productReleaseGA,prdReleaseGA);
                			//U-2936 and U-2935 start
                            sObjRecProductRelease.put(OC_IB_Constants.ProductReleaseCompetenceSubDomain,objSuccessStagingRec.OC_PRD_CompetenceSubDomainName__c);
                            sObjRecProductRelease.put(OC_IB_Constants.ProductReleaseCustomer,getCutomerId(objSuccessStagingRec));
                           	//U-2936 and U-2935 end
                			sObjRecProductRelease.put(OC_IB_Constants.productReleasePRIMNo,objSuccessStagingRec.OC_PRD_Release_PrimNo__c);
                            sObjRecProductRelease.put(OC_IB_Constants.productReleaseRecordType,OC_IB_Constants.productReleaseRecordTypeId);
                            sObjRecProductRelease.put(OC_IB_Constants.ReleaseVersionParentProduct,mapProductNameToId.get((objSuccessStagingRec.name+OC_IB_Constants.seprator+prdRecTypeId).toLowercase()));
                            sObjRecProductRelease.put(OC_IB_Constants.productRelease,objSuccessStagingRec.name+OC_IB_Constants.seprator+objSuccessStagingRec.OC_PRD_Release_Name__c+OC_IB_Constants.seprator+prdRecTypeId);
                            upsertProductRelease.put(objSuccessStagingRec.name+OC_IB_Constants.seprator+objSuccessStagingRec.OC_PRD_Release_Name__c+OC_IB_Constants.seprator+prdRecTypeId,(OC_MD_ProductAttributes__c)sObjRecProductRelease);

                        }

            return upsertProductRelease;

    }
    //U-2936 start
    /**************************************************************************************************
* @Method Name : getCutomerId
* @Description : get salesforce customerid with respect to staging customer
* @Param       : objStagingRec - staging rec
* @Return      : String - customerId
****************************************************************************************************/
    public static String getCutomerId(OC_IB_IntegrationSobjectRecords__c objStagingRec){
        String prdCustomerId = null;
        String customer = objStagingRec.OC_PRD_Customer__c;

        IF (customer != null && String.isNotBlank(customer) ){
			customer = Customer.deleteWhitespace();

            IF (mapStagingFieldValueToSfId.containskey(Customer)) {
                prdCustomerId = mapStagingFieldValueToSfId.get (customer);
            } ELSE {
                mapNotValidStagingRec.put(objStagingRec.OC_PRD_TechConcatProductRelease__c,new OC_IB_IntegrationSobjectRecords__c (id = objStagingRec.id,OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncPartialStatus ));
                listNotValidStagingRecEventLog.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler,
                                                   OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj, null, true,null,OC_IB_Constants.Sfdc_Ebip_PRD_inApi,
                                                   null,false,true,false,true,false,String.ValueOf(objStagingRec.id), OC_IB_Constants.ProductReleaseCustomerError+objStagingRec.OC_PRD_Customer__c,false,null,null));
            }
        }
        return prdCustomerId;
    }
    //U-2936 end
/**************************************************************************************************
* @Method Name : createVersion
* @Description : creat version and return map of externalId and version.
* @Param  : objectName - name of the object
* @Param       : lstSucessReleaseRecWithVersion - List of success release rec with version
* @Param       : productReleaseId - map release id
* @Return      : Map<String,OC_MD_ProductAttributes__c>  - map of externalId and version
****************************************************************************************************/
    public  static Map<String,OC_MD_ProductAttributes__c>  createVersion(String objectName,List<OC_IB_IntegrationSobjectRecords__c> lstSucessReleaseRecWithVersion, Map<String,String>  productReleaseId) {
            Map<String,OC_MD_ProductAttributes__c> upsertProductVersion = new  Map<String,OC_MD_ProductAttributes__c>();

            For(OC_IB_IntegrationSobjectRecords__c objSuccessStagingRec : lstSucessReleaseRecWithVersion) {
                OC_PRD_StagedObjToActualObjMapingHandler.errorStagingRecordId = objSuccessStagingRec.Id;
                OC_PRD_StagedObjToActualObjMapingHandler.errorStagingrecord = objSuccessStagingRec;
                prdRecTypeId = getRecordTypeIdName (objectName,objSuccessStagingRec.RecordType.DeveloperName,OC_IB_Constants.sObjectRecordTypeId);

            For (String objVersion : objSuccessStagingRec.OC_PRD_VersionName__c.split('";"')) {
                 objVersion = objVersion.replaceAll('"','');
                 sObject sObjRecProductVersion = Schema.getGlobalDescribe().get(OC_IB_Constants.productAttributeObject).newSObject();
                 sObjRecProductVersion.put(OC_IB_Constants.productReleaseRecordType,OC_IB_Constants.productVersionRecordTypeId);
                 sObjRecProductVersion.put(OC_IB_Constants.VersionParent,productReleaseId.get(objSuccessStagingRec.OC_PRD_TechConcatProductRelease__c));
                 sObjRecProductVersion.put(OC_IB_Constants.productVersionName,objVersion);
                 sObjRecProductVersion.put(OC_IB_Constants.productReleaseVersion,objSuccessStagingRec.name+OC_IB_Constants.seprator+objSuccessStagingRec.OC_PRD_Release_Name__c+OC_IB_Constants.seprator+
                                           objVersion+OC_IB_Constants.seprator+prdRecTypeId);

                  upsertProductVersion.put((objSuccessStagingRec.name+OC_IB_Constants.seprator+objSuccessStagingRec.OC_PRD_Release_Name__c+OC_IB_Constants.seprator+objVersion+OC_IB_Constants.seprator+
                                            prdRecTypeId).toLowercase(),(OC_MD_ProductAttributes__c)sObjRecProductVersion);
            }

        }
                 return upsertProductVersion;
    }
/**************************************************************************************************
* @Method Name : getPriceBookId
* @Description : fetch the pricebookid for the product.
* @Param       : Nothing
* @Return      : Map<String, Pricebook2>  - priceBookName and Pricebook object
****************************************************************************************************/
public static Map<String, Pricebook2>  getPriceBookId(){
    Map<String, Pricebook2> priceBooks = new Map<String, Pricebook2>();
 for(Pricebook2 objPriceBook : [SELECT id,name FROM pricebook2 WHERE name= :OC_IB_Constants.PC_NAME_STANDARD_PRICE_BOOK OR name = :OC_IB_Constants.PC_NAME_SERVICE_CATALOG ]) {
     priceBooks.put(objPriceBook.Name, objPriceBook);
 }
     return priceBooks;
}
/**************************************************************************************************
* @Method Name : createPriceBookEntry
* @Description : Create PricrbookEntry.
* @Param       : productId- Product Object Id.
* @Param       : pricebookId- pricebook Object Id.
* @Return      : priceBookEntry object
****************************************************************************************************/
public static PricebookEntry  createPriceBookEntry( String productId, String pricebookId){
     sObject priceBookSer = Schema.getGlobalDescribe().get(OC_IB_Constants.objPriceBookEntry).newSObject();
     priceBookSer.put(OC_IB_Constants.PriceBookEntryUnitPrice,OC_IB_Constants.priceBookUnitPrice);
     priceBookSer.put(OC_IB_Constants.PriceBookEntryIsActive,OC_IB_Constants.priceBookActive);
     priceBookSer.put(OC_IB_Constants.PriceBookEntryProduct2Id,productId);
     priceBookSer.put(OC_IB_Constants.PriceBookEntryPricebook2Id,pricebookId);
     return (PricebookEntry)priceBookSer;
}
/**************************************************************************************************
* @Method Name : getPriceBookEntryId
* @Description : fetch pricebookentry for muliplepricebook.
* @Param       : priceBook - pricebookname and pricebook
* @Param       : productIds - List of productIds.
* @Return      : Map<String,Map<String,String>> - pricebookname with productid and pricebookEntryid
****************************************************************************************************/
public static  Map<String,Map<String,String>> getPriceBookEntryId( Map<String, Pricebook2> priceBook,List<id> productIds){
 Map<String,Map<String,String>> productIdToPriceBookEntry = new Map<String, Map<String,String>>();

 for(priceBookEntry pb :  [SELECT Id, Name,Pricebook2.Name, Pricebook2Id,isActive, CurrencyIsoCode,Product2Id
                             FROM PricebookEntry WHERE CurrencyIsoCode=:OC_IB_Constants.contractCurrencyCodeValue and Pricebook2.Name IN :priceBook.keySet()
                              AND product2id in:productIds]){
     if(!productIdToPriceBookEntry.containskey(pb.Pricebook2.Name)) {
         productIdToPriceBookEntry.put(pb.Pricebook2.Name,new Map<String,String>());
     }
         productIdToPriceBookEntry.get(pb.Pricebook2.Name).put(pb.Product2Id,pb.Id);
 }
         return productIdToPriceBookEntry;
}
/**************************************************************************************************
* @Method Name :  getRecordTypeIdName
* @Description :  fetch object recordtypeId or name on the basis of recordTypeIdName and other object recordtype.
* @Param       :  objectName - object name
* @Parm        :  recordType - other object recordtype
* @Parm        :  recordTypeIdName - Id or Name.
* @Return      :  recordTypeId or recordtype name on the basis of recordTypeIdName
****************************************************************************************************/
public static String getRecordTypeIdName(String objectName,String recordType, String recordTypeIdName) {
 String recTypeIdName = '';
 IF(recordTypeIdName.equalsIgnoreCase(OC_IB_Constants.sObjectRecordTypeId)) {
        //U-3067 Start
         If(recordType.equalsIgnoreCase(OC_IB_Constants.stagingObjProductRt)) {
            recTypeIdName =  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.productNodeRecordTypeName).getRecordTypeId();
         } ELSE IF(recordType.equalsIgnoreCase(OC_IB_Constants.stagingObjProductSolutionRt)  || recordType.equalsIgnoreCase(OC_IB_Constants.stagingObjProductNodeTypeSolution)) {
            recTypeIdName =  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.productSolutionRecordTypeName).getRecordTypeId();
         } //U-3069 Start
         Else IF (recordType.equalsIgnoreCase(OC_IB_Constants.stagingObjProductNodeComponentRt)  || recordType.equalsIgnoreCase(OC_IB_Constants.stagingObjProductNodeTypeComponentRelease)) {
           recTypeIdName =  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.productNodeComponentRecordTypeName).getRecordTypeId();
         } //U-3069 End
    } Else IF (recordTypeIdName.equalsIgnoreCase(OC_IB_Constants.sObjectRecordTypeName)) {
     recTypeIdName = Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosById().get(recordType).getName();
    }
 return recTypeIdName;
}//U-3067 END
//U-3067 and 3069 Start
/**************************************************************************************************
* @Method Name : getMapExternalIdReleaseObj
* @Description : get map of release ExternalId and Release object
* @Param       : lstdNodeTypeSolnCompReleaseExtId - List of NodeTypeSolution and NodeTypeNodeComponent ExternalId
* @Return      : Map<String,OC_MD_ProductAttributes__c> - Map of  externalId and release object
****************************************************************************************************/
Public Static Map<String,OC_MD_ProductAttributes__c> getMapExternalIdReleaseObj(List<String> lstdNodeTypeSolnCompReleaseExtId) {
        Map<String,OC_MD_ProductAttributes__c> mapExtIdReleaseObj = new Map<String,OC_MD_ProductAttributes__c> ();

        for(OC_MD_ProductAttributes__c lstRelease : [SELECT Id, OC_MD_Product__c, OC_PRD_TechProductRelease__c
                                                       FROM OC_MD_ProductAttributes__c
                                                      WHERE OC_PRD_TechProductRelease__c IN :lstdNodeTypeSolnCompReleaseExtId]){
            mapExtIdReleaseObj.put(lstRelease.OC_PRD_TechProductRelease__c.toLowercase(),lstRelease);
            }


        return mapExtIdReleaseObj;
}//U-3067 and 3069END
//U-3067 Start
/**************************************************************************************************
* @Method Name : createProductReleationObj
* @Description : create productReleation juntion object
* @Param       : upsertedResultStageProduct - map of staging external id and staging record
* @Param       : lstNodeTypeSolCompStagingRec - list of all staging records
* @Param       : mapReleaseExternalIdObj - map of nodetyperelease externalId and relase object
* @Param       : integrationIdentifier - string to indetify integration context
* @Return      : List<OC_MD_Product_Relation__c> - list on product Relation object records
****************************************************************************************************/
 Public Static List<OC_MD_Product_Relation__c> createProductReleationObj(Map<String,OC_IB_IntegrationSobjectRecords__c> upsertedResultStageProduct, List<OC_IB_IntegrationSobjectRecords__c> lstNodeTypeSolCompStagingRec, Map<String,OC_MD_ProductAttributes__c>  mapReleaseExternalIdObj, String integrationIdentifier) {
        List<OC_MD_Product_Relation__c> lstProductRelation = new List<OC_MD_Product_Relation__c>();
        String nodeTypeSolnCompExtId='';

        for(OC_IB_IntegrationSobjectRecords__c objStagingRec : lstNodeTypeSolCompStagingRec) {
            OC_PRD_StagedObjToActualObjMapingHandler.errorStagingRecordId = objStagingRec.Id;
            OC_PRD_StagedObjToActualObjMapingHandler.errorStagingrecord = objStagingRec;
            String nodeTypeReleaseExtId = (objStagingRec.OC_PRD_NodeTypeName__c+OC_IB_Constants.seprator+objStagingRec.OC_PRD_NodeTypeSwReleaseName__c+OC_IB_Constants.seprator+getRecordTypeIdName (OC_IB_Constants.sobjectName,OC_IB_Constants.stagingObjProductRt,OC_IB_Constants.sObjectRecordTypeId)).toLowercase();
            String solnCompRecTypeId = OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName (OC_IB_Constants.sobjectName,objStagingRec.RecordType.DeveloperName,OC_IB_Constants.sObjectRecordTypeId);

            if (objStagingRec.RecordType.DeveloperName.equalsIgnoreCase(OC_IB_Constants.stagingObjProductNodeTypeSolution)) {
                nodeTypeSolnCompExtId = (objStagingRec.Name+OC_IB_Constants.seprator+objStagingRec.OC_PRD_SolutionReleaseName__c+OC_IB_Constants.seprator+solnCompRecTypeId).toLowercase();

            }else{
                nodeTypeSolnCompExtId = (objStagingRec.Name+OC_IB_Constants.seprator+objStagingRec.OC_PRD_NodeComponentReleaseName__c+OC_IB_Constants.seprator+solnCompRecTypeId).toLowercase();
            }
            if (mapReleaseExternalIdObj.containsKey(nodeTypeReleaseExtId) && mapReleaseExternalIdObj.containsKey(nodeTypeSolnCompExtId)) {
                sObject sObjProductReleation = Schema.getGlobalDescribe().get(OC_IB_Constants.ProductReleationObj).newSObject();
                sObjProductReleation.put(OC_IB_Constants.NodeTypeExtIdFld,objStagingRec.OC_PRD_TechConcatProductRelease__c);
                sObjProductReleation.put(OC_IB_Constants.nodeTypeFld,mapReleaseExternalIdObj.get(nodeTypeReleaseExtId).OC_MD_Product__c);
                sObjProductReleation.put(OC_IB_Constants.nodeTypeReleaseFld,mapReleaseExternalIdObj.get(nodeTypeReleaseExtId).id);

                If (objStagingRec.RecordType.DeveloperName == OC_IB_Constants.stagingObjProductNodeTypeSolution) {
                    sObjProductReleation.put(OC_IB_Constants.solutionFld,mapReleaseExternalIdObj.get(nodeTypeSolnCompExtId).OC_MD_Product__c);
                    sObjProductReleation.put(OC_IB_Constants.sobjrecordTypeId,OC_IB_Constants.productNodeTypeSolnRecId);
                    sObjProductReleation.put(OC_IB_Constants.solutionReleaseFld,mapReleaseExternalIdObj.get(nodeTypeSolnCompExtId).id);

                } else { //U-3069 Start
                    sObjProductReleation.put(OC_IB_Constants.nodeComponentFld,mapReleaseExternalIdObj.get(nodeTypeSolnCompExtId).OC_MD_Product__c);
                    sObjProductReleation.put(OC_IB_Constants.sobjrecordTypeId,OC_IB_Constants.productNodeTypeNodeCompId);
                    sObjProductReleation.put(OC_IB_Constants.nodeComponentReleaseFld,mapReleaseExternalIdObj.get(nodeTypeSolnCompExtId).id);
                } //U-3069 END
                    lstProductRelation.add((OC_MD_Product_Relation__c) sObjProductReleation);

            } else {
                    createEventLog(upsertedResultStageProduct, objStagingRec.OC_PRD_TechConcatProductRelease__c, OC_IB_Constants.syncErrorStatus, OC_IB_Constants.blankInvalidErrorMsg, OC_IB_Constants.Sfdc_Ebip_PRD_inApi );

            }
        }
        return lstProductRelation;
 } //U-3067 END
 //U-3067 Start
 /**************************************************************************************************
* @Method Name : createEventLog
* @Description : create eventlog records and update status in staging records
* @Param       : mapStagingRec - map of staging records
* @Param       : ObjStagingExtId - staging external id
* @Param       : syncStatus - status for staging record
* @Param       : errorMsg - error message for event log record
* @Param       : integrationIdentifier - string to indetify integration context
* @Return      : Void - Nothing
****************************************************************************************************/
 public static void createEventLog(Map<String,OC_IB_IntegrationSobjectRecords__c> mapStagingRec, String ObjStagingExtId, String syncStatus, String errorMsg, String integrationIdentifier) {
        Id errorStagingRecId = mapStagingRec.get(ObjStagingExtId).id;
        OC_PRD_StagedObjToActualObjMapingHandler.upsertedResultStageProduct.get(ObjStagingExtId).OC_IB_ActualObjectSyncStatus__c = syncStatus;
        OC_PRD_StagedObjToActualObjMapingHandler.integEventLogInsertList.add(new EventLog.integrationLog(OC_IB_Constants.logTypeError,OC_IB_Constants.classPRDtagedObjToActualObjMapingHandler,
                                                                                                         OC_IB_Constants.methodPRDCopyDataFromStagingObjToActualObj, null, true,null,integrationIdentifier,
                                                                                                         null,false,true,false,true,false,String.ValueOf(errorStagingRecId),errorMsg,false,null,null));
 }
//U-3067 END
/**************************************************************************************************
* @Method Name : createPcodeRec
* @Description : create createPcodeRec records
* @Param       : mapPcodePlatformKeyStagingObj - map of platformpcodeCombinationandstaging
* @Param       : mapPrdNameId -map productname and id
* @Return      : PcodeRecords
****************************************************************************************************/
//P-code Start
Public Static List<OC_MD_Product_Relation__c> createPcodeRec(Map<String,OC_IB_IntegrationSobjectRecords__c> mapPcodePlatformKeyStagingObj, Map<String,String> mapPrdNameId) {
    List<OC_MD_Product_Relation__c> lstPcodePlatformRec = new List<OC_MD_Product_Relation__c>();

  For(String pcodeExtId : mapPcodePlatformKeyStagingObj.keySet()){
      OC_IB_IntegrationSobjectRecords__c objStaging = mapPcodePlatformKeyStagingObj.get(pcodeExtId);
      OC_PRD_StagedObjToActualObjMapingHandler.errorStagingRecordId = objStaging.Id;
      OC_PRD_StagedObjToActualObjMapingHandler.errorStagingrecord = objStaging;
      sObject sObjPcodePlatformRec = Schema.getGlobalDescribe().get(OC_IB_Constants.ProductReleationObj).newSObject();
      sObjPcodePlatformRec.put(OC_IB_Constants.NodeTypeExtIdFld,pcodeExtId);
      sObjPcodePlatformRec.put(OC_IB_Constants.prdPcode,pcodeExtId.substringAfterLast(OC_IB_Constants.seprator));
      sObjPcodePlatformRec.put(OC_IB_Constants.prdPlatform,pcodeExtId.substringBetween(OC_IB_Constants.seprator));
      sObjPcodePlatformRec.put(OC_IB_Constants.sobjrecordTypeId,OC_IB_Constants.productPcodeRectypeId);
      String prdNameKey = (objStaging.Name+OC_IB_Constants.seprator+OC_PRD_StagedObjToActualObjMapingHelper.getRecordTypeIdName (OC_IB_Constants.sobjectName,objStaging.RecordType.DeveloperName,OC_IB_Constants.sObjectRecordTypeId)).toLowercase();
      sObjPcodePlatformRec.put(OC_IB_Constants.prdPcodeNodeType,mapPrdNameId.get(prdNameKey));
      lstPcodePlatformRec.add((OC_MD_Product_Relation__c) sObjPcodePlatformRec);
      System.debug('lstPcodePlatformRec::'+lstPcodePlatformRec);
  }
      return lstPcodePlatformRec;
}
//P-code End
}