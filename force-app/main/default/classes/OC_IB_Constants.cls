/**
* @File Name          : OC_IB_Constants
* @Description        : Ibase integration Constant class.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-15                 IBM                   Modified Version
* 1.2        2021-03-29                 IBM                   U-2676 Contract ResponseProfile
* 1.3        2021-05-12                 IBM                   Product Mr Change
**/
public class OC_IB_Constants {

    public static final string Sfdc_Ebip_Ibase_OutApi = 'Sfdc_Ebip_Ibase_OutApi';
    public static final string Sfdc_Ebip_Ibase_InApi = 'Sfdc_Ebip_Ibase_InApi';
    public static final string Account = 'Account';
    public static final string FromDateTime = 'FromDateTime';
    public static final string toDateTime = 'ToDateTime';
    public static final string Service = 'Service';
    public static final string serviceAccRTdevName = 'OC_MD_Service_Account';
    public static final string textDataType = 'Text';
    public static final string integerDataType = 'Integer';
    public static final string decimalDataType = 'Decimal';
    public static final string booleanDataType = 'Boolean';
    public static final string ArrayOfStrings = 'ArrayOfStrings';
    public static final string pickListDataType = 'Picklist';
    public static final string multiSelectPickListDataType = 'MultiSelectPicklist';
    public static final string dateDataType = 'Date';
    public static final string dateDataTimeType = 'DateTime';
    public static final string EpochToDateDataType = 'EpochToDate';
    public static final string EpochToDateTimeDataType = 'EpochToDateTime';
    public static final string lookUpDataType = 'Lookup';
    public static final string httpMethodGET = 'GET';
    public static final string orderByField = 'LastModifiedDate ASC';
    public static final string objectAsset = 'Asset';
    public static final string objectintegSobjRecords = 'OC_IB_IntegrationSobjectRecords__c';
    public static final string serviceToId='ServiceToId';
    public static final string SoldToId='SoldToId';
    public static final string toBeSyncedStatus = 'To be synced';
    public static final string syncSuccessStatus = 'Sync Success';
    public static final string syncErrorStatus = 'Sync Error';
    public static final string AccountId = 'AccountId';
    public static final string assetFieldSoldToId = 'OC_IB_Sold_To_Id__c';
    public static final string assetExtKeySoldToId = 'OC_IB_ConcatAssetIdSoldToId__c';
    public static final string assetExtKeyServToId = 'OC_IB_ConcatAssetIdServiceToId__c';
    public static final string stagingExtKeyServToId = 'OC_IB_Asset_ConcatAssetIdServiceToId__c';
    public static final string stagingExtKeySoldToId = 'OC_IB_Asset_ConcatAssetIdSoldToId__c';
    public static final string stagingServToId = 'OC_IB_Asset_Service_To_Id__c';
    public static final string stagingSoldToId = 'OC_IB_Asset_Sold_To_Id__c';
    Public static final string sobjrecordTypeId = 'RecordTypeId';
    public static final string assetNodeTypeRT = 'OC_MD_Node_Type';
    public static final string integOutboundLogRT = 'IntegrationOutboundEvent';
    public static final string integInboundLogRT = 'IntegrationInboundEvent';
    public static final string IntegrationStagingToActualObjectEventRT = 'IntegrationStagingToActualObjectEvent';
    public static final string stagingObjFieldDataType = 'OC_IB_StagingObjectFieldDataType__c';
    public static final string stagingObjFieldApiName = 'OC_IB_StagingObjectFieldApiName__c';
    public static final string actualObjFielddataType = 'OC_IB_ActualObjectFieldDataType__c';
    public static final string actualObjFieldApiName = 'OC_IB_SfdcFieldApiName__c';
    public static final string actualObjSynStatus = 'OC_IB_ActualObjectSyncStatus__c';
    public static final string partnerAccRecType = 'Partner_Account';
    public static final string assetRecType = 'Asset';
    public static final string csdpRecId='OC_IB_Asset_Csdp_Id__c';
    public static final string name='Name';
    public static final string classInboundRequestHandler = 'OC_IB_InboundRequestHandler';
    public static final string methodprocessInboundRequest = 'processInboundRequest';
    public static final string methodCopyDataFromStagingObjToActualObj = 'copyDataFromStagingObjToActualObj';
    public static final string classStagedObjToActualObjMappingHandler = 'OC_IB_StagedObjToActualObjMappingHandler';
    public static final string methodCopyAssetDataFromStagingToActualObject = 'CopyAssetDataFromStagingToActualObject';
    public static final string classRequestGenerationHandler ='OC_IB_RequestGenerationHandler';
    public static final string methodGenerateRequest='GenerateRequest';
    public static final string methodSendRequest='sendRequest';
    public static final string methodSendRequestUI='sendRequestFromUI';
    public static final string logTypeSuccess='Success';
    public static final string logTypeError='Error';
    public static final string attachTextContentType='text/plain';
    public static final string connectivityIssue='connectivity Issue!Please contact your system administrator.';
    public Static final string toastMsgTypeError = 'error';
    public Static final string toastMsgTypeSuccess = 'success';
    public Static final String IBOutboundSuccessMsg = System.Label.OC_IB_Outbound_Success_Message;
    public Static final String IBOutboundErrorMsg = System.Label.OC_IB_Outbound_Error_Message;
    public Static final String errorMsgPrefix = 'Error Occured:';
    public Static final String errorMsgSuffix = 'Please contact your system administrator.';
    public Static final String jobStatusComplete = 'COMPLETE';
    public static final string soldToAccountQueryMdt = 'OC_IB_IbaseSoldToAccount';
    public static final string objectAccount = 'Account';
    public static final string infoNotCollected = 'Info not collected';
    public static final string classDeserializeInboundRequest='OC_IB_DeserializeInboundRequest';
    public static final string methodDeserializeInboundRequestexecute='execute';
    public static final string classParseInboundReq='OC_IB_ParseInboundReq';
    public static final string methodParseInboundReq='OC_IB_ParseInboundReq';
    public static final string methodParseInboundReqexecute='execute';
    public static final string methodInboundRequestHandler='OC_IB_InboundRequestHandler';
    public static final String DELIMITER = ';';
    public static final String REC_TYPE_PRODUCTATTRIBUTE_RELEASE = 'OC_MD_Release';
    public static final String REC_TYPE_PRODUCTATTRIBUTE_VERSION = 'OC_MD_Version';
    //Contract Related Constants
    public static final string Sfdc_Ebip_CSM_OutApi = 'Sfdc_Ebip_CSM_OutApi';
    public static final string Sfdc_Ebip_CSM_inApi = 'Sfdc_Ebip_CSM_inApi';
    public static final string stagingObjContractRt = 'ServiceContract';
    public static final string ContractRt = 'ServiceContract';
    public static final string classCSM_InboundRequestHandler = 'OC_CSM_InboundRequestHandler';
    public static final string methodCSM_InboundRequestHandler = 'OC_CSM_InboundRequestHandler';
    public static final string classCSMStagedObjToActualObjMapingHandler = 'OC_CSM_StagedObjToActualObjMapingHandler';
    public static final string methodCSMCopyDataFromStagingObjToActualObj = 'copyDataFromStagingObjToActualObj';
    public static final string syncPartialStatus='Sync Partial Success';
    public static final string methodCopyContractStagingToActualObject='CopyContractStagingToActualObject';
    public static final string keyCSMJsonContent='content';
    public static final string keyCSMJsonserviceElements='serviceElements';
    public static final string keyCSMjsonServiceElementName='name';
    public static final string contractCurrencyCode='currencyisocode';
    public static final string contractCurrencyCodeValue='SEK';
    public static final string contractpriceBook2id='priceBook2id';
    // public static final string priceBookName='Service Catalog';
    public static final string objectContract='ServiceContract';
    public static final string objectName='ObjectName';
    public static final string contentType='content-type';
    public static final string stagedRecContractNumber='OC_CSM_Contract_Number__c';
    public static final string stagedRecServicepackage='OC_CSM_Contract_ServicePackage__c';
    public static final string relatedDataType='Related';
    public static final string contractLineItemObject='ContractLineItem';
    public static final string clineServicePackage='OC_MD_Service_Package__c';
    public static final string clinePricebookEntryId='PricebookEntryId';
    public static final string clineServiceEleName='OC_MD_Service_Element_Name__c';
    public static final string clineUnitPrice='UnitPrice';
    public static final string clineQuantity='Quantity';
    public static final string jsonApplication='application/json';
    public static final string clineContractNoServElement='OC_CSM_ContractNumber_ServiceElement__c';
    public static final string clineServiceContractId='ServiceContractId';
    public static final string SyncAssetCreateSuccess='Asset Sync Success';
    public static final string objectEntitlement='Entitlement';
    public static final string serviceContractId='ServiceContractId';
    public static final string startDate='StartDate';
    public static final string endtDate='EndDate';
    public static final string entitlementNumber='OC_CSM_Entitlement_Number__c';
    public static final string IBContractNumbers='OC_IB_Contract_Numbers__c';
    public static final string classInstalledBaseItemsHandler='OC_IB_InstalledBaseItemsHandler';
    public static final string methodInstalledBaseItems='ProcessinstalledBaseItems';
    public static final string methodProcessInstalledBaseItems='ProcessinstalledBaseItemsMethod';
    public static final string noRecordsErrorMessage='Empty:No records found';
    //public static final string ibItemsConcatAssetIdServiceId='OC_IB_Asset_ConcatAssetIdServiceToId__c';
    public static final string installedBaseItemObject ='OC_MD_Installed_Base_Item__c';
    public static final string ibItemsServiceContract='OC_MD_Service_Contract__c';
    public static final string ibItemsAsset='OC_MD_Asset__c';
    public static final string ibItemContractNumAssetIdServiceId='OC_IB_ContractNumAssetIdServiceId__c';
    public static final string extcontractNumbers='contractNumbers';
    public static final string extserviceToIds='serviceToIds';
    public static final string assetCsdpId='OC_IB_Csdp_Id__c';
    public static final string assetStatusOutofScope='Out of Scope';
    public static final string assetStatusInScope='In Scope';
    public static final string installedbaseInactive='OC_IB_Inactive__c';
    public static final Boolean falseBoolean=false;
    public static final String updateIBItemsStatus='updateIBItemsStatus';
    public static final String updateAssetStausOutOfScope='updateAssetStausOutOfScope';
    public static final string ibItemsSoldToRecrds='SoldToRecords';
    public static final string ibItemsMultipleSTPRecrds='MultipleSTPs';
    public static final string classArchiveStagingObjects='OC_IB_Batch_ArchiveStagingObjects';
    public static final string methodExecute= 'execute';
    public static final String contractType='OC_CSM_Contract_Type__c';
    public static final String updateExistingIbItems='updateExistingIbItems';
    //Archival of Staging Object records
    public static final String SystemAdmin ='System Administrator';
    public static final String UserRoleDefaults='OC_TestDataGenerator.UserRoleDefaults';
    public static final String UserDefaults='OC_TestDataGenerator.UserDefaults';
    public static final String sRecordId=' Record Id';
    public static final String deleteOps='Delete';
    public static final String insertOps='Insert';
    public static final String updateOps='Update';

    /*U-2676/U-2675 Contract ResponseProfile/Account Update Changes*/
    public static final String responseProfile='responseProfile';
    public static final String responseDurations='responseDurations';
    public static final String stagingResponseProfile='OC_CSM_ResponseProfile__c';
    public static final String toUpperCase='toUpperCase';
    public static final String toLowerCase='toLowerCase';
    public static final String minute='MINUTE';
    public static final String hour='HOUR';
    public static final String day='DAY';
    public static final String month='MONTH';
    public static final String quarter='QUARTER';
    public static final String second='SECOND';
    public static final String week='WEEK';
    public static final String year='YEAR';
    public static final String serviceMilestoneObject='OC_TH_Service_Milestone__c';
    public static final String priorityField='OC_TH_Priority__c';
    public static final String responseDurationPriority='responseDurationPriority';
    public static final String responseDurationType='responseDurationType';
    public static final String timeUnit='timeUnit';
    public static final String timeValue='timeValue';
    public static final String CustomerMarketArea='OC_TH_Customer_Market_Area__c';
    public static final String CustomerUnit='OC_TH_Customer_Unit__c';
    public static final String serviceMilestoneExtKey='OC_CSM_ConcatContractNumPriority__c';
    public static final String serviceMileStoneContract='OC_TH_Service_Contract__c';
    public static final Integer hourToMinutes=60;
    public static final Integer dayToMinutes=60*24;
    public static final Integer monthToMinutes=60*24*30;
    public static final Integer quarterToMinutes=60*24*90;
    public static final Integer weekToMinutes=60*24*7;
    public static final Integer yearToMinutes=60*24*365;
    public static final String processResProfileToMilestone='processResProfileToMilestone';
    public static final String responseDurationTypeBlank='ServiceMilestone creation failed:responseDurationType is blank';
    public static final String responseDurationType_PriorityBlank='ServiceMilestone creation failed:Priority and responseDurationType are blank';
    public static final String MethodprocessContractRequest='processContractRequest';
    public static final String AccountUpdateErrorMessage = 'Account update failed';
    public static final String AccountIdField = 'Id';
    public static final String timeValueZero='0';

    // Added for Product MR
    public static final string objectProduct = 'Product';
    public static final string Sfdc_Ebip_PRD_OutApi = 'Sfdc_Ebip_PRD_OutApi';
	public static final boolean outbondIntegrationobjectactive = true;

    //Inbound to staging
    public static final string Sfdc_Ebip_PRD_inApi = 'Sfdc_Ebip_PRD_inApi';
    public static final string productInboundhandlerClass='OC_PRD_InboundRequestHandler';
    public static final string prdProcessInboundRequest='processProductRequestData';
    public static final string nodeTypePlatform='nodeTypePlatform';
    public static final string stagingPrdPlatfromName='OC_PRD_Product_PlatformName__c';
    public static final string platform='platform';
    public static final string plaformName='name';
    public static final string nodeTypeSoftwareReleases='nodeTypeSoftwareReleases';
    public static final string releaseName='name';
    public static final string stagingReleaseName='OC_PRD_Release_Name__c';
    public static final string product='product';
    public static final string eos ='eos';
    public static final string eom ='eom';
    public static final string primNo ='primNo';
    public static final string ga ='ga';
    public static final string stagingReleaseEos ='OC_PRD_Release_EOS__c';
    public static final string stagingReleaseEom ='OC_PRD_Release_EOM__c';
    public static final string stagingReleasePrimNo ='OC_PRD_Release_PrimNo__c';
    public static final string stagingReleaseGa ='OC_PRD_Release_GA__c';
    public static final string softwareVersions ='softwareVersions';
    public static final string versionName ='name';
    public static final string stagingVersionName='OC_PRD_VersionName__c';
    public static final string stagingPrdRelVerExtkey='OC_PRD_TechConcatProductRelease__c';
    public static final string ProductNodeTypeRt='ProductNodeType';
   	public static final string extProductModels='productModels';
    public static final string extTechnologies='technologies';
    public static final string stagingProductModel='OC_PRD_ProductModel__c';
    public static final string stagingPrdTechnologyStnd='OC_PRD_ProductTechnolgyStandard__c';
    public static final string extProductModelName='name';
    public static final string extTechStandName='name';
    public static final string extIdstagingNodeTypeRt='Node Type';
    public static final string extNodeTypes='nodeTypes';
    public static final string stagingObjName='Name';
    public static final string productNodeType='NodeType';
    public static final string classPrdDeserializeInboundRequest='OC_PRD_DeserializeInboundRequest';
    public static final string processNodeTypeProductRequestMethod='processNodeTypeProductRequest';
    public static final string batchProductInboundProcessorCls='OC_PRD_BatchProductInboundProcessor';
    public static final string finishMethod='finish';
    public static final string productInboundRequestProcessorCls='OC_PRD_ProductInboundRequestProcessor';
    public static final string handleInboundRequestMethod='handleInboundRequest';
    public static final string stagingProductNodeTypeRt=Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get('ProductNodeType').getRecordTypeId();





    //Staging to actual object
    public static final String stagingObjNameNull = 'null%';
    public static final String stagingObjProductRt = 'ProductNodeType';
    //public static final String sobjectName = 'Product2';
    public static final string productRecordType = 'RecordTypeId';
    public static final Boolean mapStagingFieldValueToSfIdNotEmpty = false;
    public static final String stagedRecProductCode = 'Name';
    public static final String stagedRecProductReleaseVersionNumber = 'OC_PRD_TechConcatProductRelease__c';
    public static final String classPRDtagedObjToActualObjMapingHandler = 'OC_PRD_StagedObjToActualObjMapingHandler';
    public static final String methodPRDCopyDataFromStagingObjToActualObj = 'copyDataFromStagingObjToActualObj';
    public static final Integer priceBookUnitPrice = 0;
    public static final Boolean priceBookActive = True;
    public static final string productAttributeObject='OC_MD_ProductAttributes__c';
    public static final string productReleaseName = 'Name';
    public static final string productReleaseEOS = 'OC_MD_EOS__c';
    public static final string productReleaseEOM = 'OC_MD_EoM__c';
    public static final string productReleaseGA = 'OC_MD_GA__c';
    public static final string productReleasePRIMNo = 'OC_MD_PRIM_No__c';
    public static final string productReleaseRecordType = 'RecordTypeId';
    public static final string productReleaseRecordTypeId = Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get('OC_MD_Release').getRecordTypeId();
    public static final string productVersionRecordTypeId = Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get('OC_MD_Version').getRecordTypeId();
    public static final string ReleaseVersionParentProduct = 'OC_MD_Product__c';
    public static final string VersionParent = 'OC_MD_Parent__c';
    public static final string productRelease = 'OC_PRD_TechProductRelease__c';
    public static final String PC_NAME_STANDARD_PRICE_BOOK = 'Standard Price Book';
    public static final String PC_NAME_SERVICE_CATALOG = 'Service Catalog';
    public static final String productVersionName = 'name';
    public static final String productReleaseVersion = 'OC_PRD_TechProductReleaseVersion__c';
    //public static final string productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
    public static final string productNodeRecordTypeName = 'OC_MD_Node_Type';
    public static final string productId = 'Id';
    public static final string active = 'isActive';
    public static final string productPlatform = 'OC_MD_Platform__c';
    //public static final string productRecordTypeName = 'Node Type';
    public static final string productNameRecordTypeId = 'OC_PRD_TechProductNameRecordTypeId__c';
    public static final string sObjectRecordTypeId = 'Id';
    public static final string seprator = '+';
    public static final string sObjectRecordTypeName = 'Name';
    public static final Integer emptyIndexValue = -1;
    public static final string objPriceBookEntry = 'PricebookEntry';
    public static final string PriceBookEntryUnitPrice = 'UnitPrice';
    public static final string PriceBookEntryIsActive = 'IsActive';
    public static final string PriceBookEntryProduct2Id = 'Product2Id';
    public static final string PriceBookEntryPricebook2Id = 'Pricebook2Id';
	public static final string ProductReleaseCompetenceSubDomain = 'OC_PRD_CompetenceSubDomainName__c';
    public static final string ProductReleaseCustomer = 'OC_MD_Customer__c';
    public static final string ProductReleaseCustomerError= 'CustomerId is invalid :';
    public static final string extCompetenceSubDomain= 'competenceSubDomainName';
    public static final string extCustomer= 'customer';
    public static final string stagingCompetenceSubDomain='OC_PRD_CompetenceSubDomainName__c';
    public static final string stagingCustomer='OC_PRD_Customer__c';


    // U-3069 NodeComponent Product
    public static final String stagingObjProductNodeComponentRt = 'ProductNodeComponent';
    public static final String productNodeComponentRecordTypeName = 'OC_MD_Node_Component';
    public static final String stagingObjProductNodeTypeComponentRelease = 'NodeTypeNodeComponent';
    public static final string productNodeTypeNodeCompId = Schema.SObjectType.OC_MD_Product_Relation__c.getRecordTypeInfosByDeveloperName().get('Node_Type_and_Node_Component').getRecordTypeId();
    public static final String nodeComponentFld = 'OC_MD_Node_Component__c';
    public static final String nodeComponentReleaseFld = 'OC_MD_Node_Component_Release__c';
    // U-3067 Solution Product
    public static final String stagingObjProductSolutionRt = 'ProductSolution';
    public static final String productSolutionRecordTypeName = 'OC_MD_Solution';
    //public static final String Sfdc_Ebip_PRD_SolnComp_InApi = 'Sfdc_Ebip_PRD_SolnComp_InApi';
    public static final String Sfdc_Ebip_PRD_NtSolnComp_InApi = 'Sfdc_Ebip_PRD_SolnComp_InApi';
    public static final List<String> lstPRDRecType = new List<String>{'ProductNodeType','ProductNodeComponent','ProductSolution'};
    public static final List<String> lstPRDNodeTypeSolnCompRecType = new List<String>{'NodeTypeNodeComponent','NodeTypeSolution'};
    public static final String sobjectName = 'Product2';
    public static final String stagingObjProductNodeTypeSolution = 'NodeTypeSolution';
    public static final String ProductReleationObj = 'OC_MD_Product_Relation__c';
    public static final String nodeTypeFld = 'OC_MD_Node_Type__c';
    public static final String nodeTypeReleaseFld = 'OC_MD_Node_type_Release__c';
    public static final String solutionFld = 'OC_MD_Solution__c';
    public static final String solutionReleaseFld = 'OC_MD_Soln_Release__c';
    public static final String NodeTypeExtIdFld = 'OC_PRD_TechNodeTypeExtId__c';
    public static final String blankInvalidErrorMsg = 'Field values are invalid or blank';
    public static final String prdNodeTypeAndSolDevName = 'Node_Type_and_Solutions';
    public static final String productNodeTypeSolnRecId = Schema.SObjectType.OC_MD_Product_Relation__c.getRecordTypeInfosByDeveloperName().get(prdNodeTypeAndSolDevName).getRecordTypeId();
    public static final String getEventLogMessage = 'getMessage=';
    public static final String getStatusCode = ';getStatusCode';
    //U-3066 EBIP To Staging Solution Product
    public static final String productSolutionType ='ProductSolution';
    public static final String extSolutions ='solutions';
    public static final String nodeTypeSolution='NodeTypeSolution';
    public static final String extNodeTypeSolution='nodeTypeSolution';
    public static final String stagingProductSolutionRtDevName='ProductSolution';
    public static final String stagingProductSolutionRt=Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get(stagingProductSolutionRtDevName).getRecordTypeId();
    public static final String extsolutionReleases='solutionReleases';
    public static final String solutionRtName='Solution';
    public static final String solutionCompReleaseName='name';
    public static final String stagingNodeTypeSolutionRtDevName='NodeTypeSolution';
    public static final String stagingNodeTypeSolutionRt=Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get(stagingNodeTypeSolutionRtDevName).getRecordTypeId();
    public static final String extsolutionName='solutionName';
    public static final String stagingSolutionRelname='OC_PRD_SolutionReleaseName__c';
    public static final String stagingNodeTypeName='OC_PRD_NodeTypeName__c';
    public static final String stagingNodeTypeSwRelName='OC_PRD_NodeTypeSwReleaseName__c';
    public static final String classNTSolutionNComponentHandler='OC_PRD_NTSolutionNComponentHandler';
    public static final String methodprocessNTSolutionNCompRecords='processNTSolutionNCompRecords';
    public static final String classSolnNCompInboundRequestHandler='OC_PRD_SolnNCompInboundRequestHandler';
    public static final String methodprocessSolutionNCompTypeRecords='processSolutionNCompTypeRecords';
    //U-3068 EBIP to staging NodeComponent Product
    public static final String productNodeComponentType='ProductNodeComponent';
    public static final String extNodeComponents ='nodeComponents';
    public static final String nodeTypeNodeComponent='NodeTypeNodeComponent';
    public static final String extNodeTypeNodeComponent='nodeTypeNodeComponentReleases';
    public static final String extnodeComponentSoftwareReleases='nodeComponentSoftwareReleases';
    public static final String nodeCompRtName='Node Component';
    public static final String stagingProductNodeComponentRtDevName='ProductNodeComponent';
    public static final String stagingNodeTypeNodeComponentRtDevName='NodeTypeNodeComponent';
    public static final String stagingProductNodeComponentRt=Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get(stagingProductNodeComponentRtDevName).getRecordTypeId();
    public static final String stagingNodeTypeNodeComponentRt=Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get(stagingNodeTypeNodeComponentRtDevName).getRecordTypeId();
    public static final String extnodeComponentName='nodeComponentName';
    public static final String stagingNodeComponentRelname='OC_PRD_NodeComponentReleaseName__c';

    //pcode to Staging
    public static final string stagingPrdPcodeNodeType ='OC_PRD_Platform_Pcode__c';
    public static final string extPrdpcode ='pcode';

	//Contract sapOrder
    public static final String sapOrderNumber = 'sapOrderNumber';
    public static final String networkIdField = 'OC_CSM_Network_Id__c';
    public static final String serviceOrderNumberField = 'OC_CSM_Service_Order_Number__c';
    public static final String networkDescriptionField = 'OC_CSM_Network_Description__c';
    public static final String companyCodeField = 'OC_CSM_Company_Code__c';
    public static final String stagingContractName = 'Name';
    public static final String networkId = 'networkId';
    public static final String serviceOrderNumber = 'serviceOrderNumber';
    public static final String networkDescription = 'networkDescription';
    public static final String companyCode = 'companyCode';
    public static final String contractNumber = 'OC_CSM_sapOrderContractNumber__c';
    public static final String concatContractNetworkServiceOrder = 'OC_CSM_concatContractNetworkServiceOrder__c';
    public static final String contractName = 'contractName';
    public static final String csContractNumber = 'csContractNumber';
    public static final string Sfdc_Ebip_CC_inApi = 'Sfdc_Ebip_CC_inApi';
    public static final string currencyCode = 'CurrencyIsoCode';
    public static final string concatContractNetworkIdServiceOrder = 'OC_CC_concatContractNetworkServiceOrder__c';
    public static final String ContractSapOrderRtId =Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get('ContractsapOrder').getRecordTypeId();
    public static final String serviceContract = 'Service_Contract__c';
    public static final String costCollectorContractNumber = 'OC_CC_Contract_Number__c';
    public static final String contractSapOrder = 'ContractsapOrder';
    public static final String errorMessage = 'Service Contract Record is not found';
    public static final string methodCopyContractSapOrderFromStagingToActualObj = 'CopyContractSapOrderFromStagingToActualObj';
    // PCodeActual
    public static final string prdPcode = 'OC_PRD_Pcode__c';
    public static final string prdPlatform = 'OC_PRD_Platfrom__c';
    public static final string prdPcodeNodeType = 'OC_PRD_PcodeNode_Type__c';
    public static final string pcodeErrormsg = 'Pcode or platform value is invalid, Please check';
    public static final string productPcodeDevelopername = 'Node_Type_and_PlatformPcode';
    public static final string productPcodeRectypeId = Schema.SObjectType.OC_MD_Product_Relation__c.getRecordTypeInfosByDeveloperName().get(productPcodeDevelopername).getRecordTypeId();
    public static final string nullValue = 'null';
}