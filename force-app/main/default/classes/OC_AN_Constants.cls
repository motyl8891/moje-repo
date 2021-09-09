/**
* @File Name          : OC_AN_Constants 
* @Description        : Constants related to Alerts and Notifications bulletin creation.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10 April 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10                IBM                   Initial Version
**/
Public with sharing class OC_AN_Constants{
    
    public static void testConstants(){
        System.assertNotEquals(null, recTypeId_Product_ServiceElement);
        System.assertNotEquals(null, recTypeId_AccPrdForBulletin_Product);
        System.assertNotEquals(null, const_Product);
        System.assertNotEquals(null, const_Release);
        System.assertNotEquals(null, recTypeId_PrdAttribute_Release);
        System.assertNotEquals(null, recTypeId_PrdAttribute_Version);
        System.assertNotEquals(null, groupNameLikeAN);
        System.assertNotEquals(null, regular);
        System.assertNotEquals(null, recTypeId_forServiceAccount);
        System.assertNotEquals(null, PRODUCT_TYPE);
        System.assertNotEquals(null, subDivision);
        System.assertNotEquals(null, service);
        System.assertNotEquals(null, serviceAccount);
        System.assertNotEquals(null, INTECHNICALREVIEW);
        System.assertNotEquals(null, INEDITORIALREVIEW);
        System.assertNotEquals(null, DRAFT);
        System.assertNotEquals(null, OC_AN_Alerts_and_Notfication_Role_Values);
        System.assertNotEquals(null, recTypeId_Account);
        System.assertNotEquals(null, recTypeId_PublicGroup);
    }
    
    public static final String recTypeId_Product_ServiceElement = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Element').getRecordTypeId();
    public static final String recTypeId_AccPrdForBulletin_Product = Schema.SObjectType.OC_AN_Bulletin_Account_Product__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Product_Record').getRecordTypeId();
    public static final String const_Product = 'Product';
    public static final String const_Release = 'OC_MD_Release';
    public static final String const_Version = 'OC_MD_Version';
    public static final String recTypeId_PrdAttribute_Release = Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.const_Release).getRecordTypeId();
    public static final String recTypeId_PrdAttribute_Version = Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByDeveloperName().get(OC_AN_Constants.const_Version).getRecordTypeId();
    public static final String groupNameLikeAN = 'A&N %';
    public static final String regular = 'Regular';
    public static final String recTypeId_PublicGroup = Schema.SObjectType.OC_AN_Bulletin_Account_Product__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Public_Group').getRecordTypeId();
    public static final String recTypeId_Account = Schema.SObjectType.OC_AN_Bulletin_Account_Product__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Account_Record').getRecordTypeId();
    public static final String OC_AN_Alerts_and_Notfication_Role_Values = 'OC_AN_Alerts_and_Notfication_Role_Values';
    public static final String DRAFT = 'Draft';
    public static final String INEDITORIALREVIEW = 'In Editorial Review';
    public static final String INTECHNICALREVIEW = 'In Technical Review';
    public static final String serviceAccount = 'Service Account';
    public static final String service = 'Service';
    public static final String sales = 'Sales';
    public static final String subDivision = 'Subdivision';
    public static final String PRODUCT_TYPE = 'Node Type';
    public static final String OC_AN_Bulletin_Account_Product = 'OC_AN_Bulletin_Account_Product__c';
    public static final String OC_AN_RoleForA_N = 'OC_AN_RoleForA_N__c';
    public static final String recTypeId_forServiceAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(OC_AN_Constants.serviceAccount).getRecordTypeId();
    public static final String OC_AN_InternalDistributionHandler = 'OC_AN_InternalDistributionHandler';
    public static final String markIsInternalAsTrue = 'markIsInternalAsTrue';
    public static final String OC_AN_MultipleAccountSelectionHandler = 'OC_AN_MultipleAccountSelectionHandler';
    public static final String markIsExternalAsTrue = 'markIsExternalAsTrue';
    /*Begin: Added for U-2763*/
    public static final String OC_AN_Auth_Url = 'OC_AN_Auth_Url';
    public static final String httpMethodPOST = 'POST';
    public static final String httpMethodPUT = 'PUT';
    public static final String OC_AN_Create_Email = 'OC_AN_Create_Email';
    public static final String OC_AN_Insert_Internal_User = 'OC_AN_Insert_Internal_User';
    public static final String OC_AN_Insert_Event_Definition = 'OC_AN_Insert_Event_Definition';
    public static final String OC_AN_Create_Internal_User_DE = 'OC_AN_Create_Internal_User_DE';
    public static final String OC_AN_Execute_Journey = 'OC_AN_Execute_Journey';
    public static final String OC_AN_Create_Journey = 'OC_AN_Create_Journey';
    public static final String OC_AN_Ex_SQL_Activity = 'OC_AN_Ex_SQL_Activity';
    public static final String OC_AN_Ex_Automation = 'OC_AN_Ex_Automation';
    public static final String BULLETIN_ID = 'BulletinId';
    public static final String ACCESS_TOKEN = 'AccessToken';
    public static final String EMAIL_ID = 'EmailId';
    public static final String BULLETIN_DATA_EXTENSION_ID = 'BulletinDataExtensionId';
    public static final String BULLETIN_JOURNEY_ID = 'JourneyId';
    public static final String BULLETIN_AUTOMATION_ID = 'BulletinAutomationId';
    public static final String BULLETIN_NAME = 'BulletinName';
    public static final String Success = 'Success';
    public static final String OC_AN_Bull_Internal_Body_begin = 'OC_AN_Bull_Internal_Body_begin';
    public static final String OC_AN_Bull_Internal_Body_end = 'OC_AN_Bull_Internal_Body_end';
    public static final String OC_AN_Email_Subscription_Body = 'OC_AN_Email_Subscription_Body';
    public static final String NewObjId_Step1 = 'NewObjId_Step1';
    public static final String ID_Step_1_DE_Target_CustomerKey = 'ID_Step_1_DE_Target_CustomerKey';
    public static final String resAccessToken = 'access_token';
    public static final String userName = '{!$Credential.UserName}';
    public static final String password = '{!$Credential.Password}';
    public static final String accessTokenEndPoint = 'callout:SFMC/v2/token';
    public static final String clientCreds = 'client_credentials';
    public static final String grantType = 'grant_type';
    public static final String clientId = 'client_id';
    public static final String clientSecret = 'client_secret';  
    public static final String accountId ='account_id';
    /*End: Added for U-2763*/
    public static final String AssetTypeName = 'htmlemail';
    public static final Integer AssetTypeId = 208;
    public static final String BlockAssetTypeName = 'htmlblock';
    public static final Integer BlockAssetTypeId = 197;
    public static final String AllInternalUsers =  'AllInternalUsers';
    public static final String Standard =  'Standard';
    /**USER PREFERENCES CONSTANTS */
    public static final String UserPreference_RT_Bulletin = 'Bulletin_Setting';
    public static final String UserPreference_RT_Product = 'Product_Setting'; 
    public static final String UserPreference_Key_recordType = 'recordType'; 
    public static final String UserPreference_Key_email = 'email'; 
    public static final String UserPreference_Key_notification = 'notification'; 
    public static final String UserPreference_Key_selectedProducts = 'selectedProducts';
    public static final String UserPreference_Key_deselectedProducts = 'deselectedProducts';
    public static final String UserPreference_Key_Name = 'Name'; 
    public static final String UserPreference_Key_ProductAttribute = 'ProductAttribute'; 
    public static final String UserPreference_Key_Id = 'Id'; 
    public static final String UserPreference_Field_DeveloperName = 'DeveloperName';
    public static final String UserPreference_Product_RT_Node = 'OC_MD_Node_Type';
    
    /** INTERNAL/EXTERNAL Publication Constants */
    public static final String INTERNAL_DISTRIBUTION_NAME_PRESET = 'ID';
    public static final String EXTERNAL_DISTRIBUTION_NAME_PRESET = 'ED';
    
    /** HEADER VALUES FOR ALL THE REQUESTS */
    public static final String CONTENT_TYPE = 'Content-Type';
    public static final String APPLICATION_JSON = 'application/json';
    public static final String APPLICATION_SOAP = 'application/soap+xml; charset=utf-8';
    public static final String AUTHORIZATION =   'Authorization';
    public static final String BEARER = 'Bearer ';
    public static final String RESPONSE = 'SUCCESS';
    public static final String INTERNALUSER = 'InternalUser_';
    
    /**Fields to fetch the emailId */
    public static final String DATA = 'data';
    public static final String LEGACYID = 'legacyId=';
    public static final String LEGACYKEY = 'legacyKey';
    
    /** CLIENT ID AND SECRET */
    public static final String OC_AN_CLIENT_CLIENTSECRET = 'OC_AN_ClientId_ClientSecret';
    
    /** JOURNEY CREATION VALUES */
    public static final String MULTIPLEENTRIES     = 'MultipleEntries';
    public static final string MULTISTEP           = 'Multistep';
    public static final string EVENT               = '{{Event.';
    public static final string EMAIL               = '.\"Email\"}}';
    public static final string EMAILADDRESS        = '.\"EmailAddress\"}}';
    public static final string INTERNALDISTRIBUTION = 'ID';
    public static final string EXTERNALDISTRIBUTION = 'ED';
    public static final string EMAILV2_1 = 'EMAILV2-1';
    public static final string EMAILV2 = 'EMAILV2';
    public static final string WAITBYDURATION_1 = 'WAITBYDURATION-1';
    public static final string WAITBYDURATION_2 = 'WAITBYDURATION-2';
    public static final string WAITBYDURATION_3 = 'WAITBYDURATION-3';
    public static final string JB_EMAIL_ACTIVITY = 'jb-email-activity';
    public static final string ONE_MINUTE = '1 minute';
    public static final string WAIT = 'WAIT';
    public static final string MINUTES = 'MINUTES';
    public static final string TIME_IN_IST = 'India Standard Time';
    public static final string TWELVE = '00:00';
    public static final string TYPE_TRIGGER = 'TRIGGER';
    public static final string AUTOMATIONAUDIENCE = 'AutomationAudience';
    public static final string NONE = 'None';
    public static final string DATAEXTENSION_URL = '/images/icon-data-extension.svg';
    public static final string DATAEXTENSION = 'Data Extension';
    public static final string ENTRYSOURCE_GROUP_CONFIGURL = 'jb:///data/entry/audience/entrysourcegroupconfig.json';
    public static final string MODE = 'Production';
    public static final string CATEGORY = 'Audience';
    public static final String JOURNEY_PUBLISH_URL_VERSION = '?versionNumber=1';
    
    public static final string FLOWTYPE_INTERNAL = 'Internal';
    public static final string FLOWTYPE_EXTERNAL = 'External';
    public static final string JOB_NAME_INTERNAL = 'OC_AN_IN_';
    public static final string JOB_NAME_EXTERNAL = 'OC_AN_EX_';
    public static final string JOB_NAME_EXTERNAL_Delay = 'OC_AN_EX_DE';
    
    /**EVENTLOG PARAMS */
    public static final string OC_AN_HandleCalloutWhenBulletinApproved = 'OC_AN_HandleCalloutWhenBulletinApproved';
    public static final string mcRestCallouts = 'mcRestCallouts';
    public static final string OC_IB_ResponseHandler =  'OC_IB_ResponseHandler';
    public static final string handleResponseCallouts =  'handleResponseCallouts';
    public static final string OC_AN_AutomationScheduler = 'OC_AN_AutomationScheduler';
    public static final string execute  = 'execute';
    public static final string updateBulletin = 'updateBulletin';
    
    /**JourneyConstants*/
    public static final string DEAudience = 'DEAudience-';
    
    /** MCUTILS Constants */
    
    public static final string MC_INSTANCE = 'mcs82tyyyzfmk1mrbbjnd1m9f5l4';
    public static final string HTTPS = 'https://';
    public static final string MC_SOAP_URL = '.soap.marketingcloudapis.com/Service.asmx';
    public static final string MC_BASE_URL = '.auth.marketingcloudapis.com/';
    public static final string MC_REST_URL = '.rest.marketingcloudapis.com/asset/v1/';
    public static final string MC_REST_URL_ONLY = '.rest.marketingcloudapis.com/';
    public static final string MC_INTERACTION_REST_URL = '.rest.marketingcloudapis.com/interaction/v1/interactions';
    public static final string MC_INTERACTION_STOP = '/stop/';
    public static final string V2_TOKEN = 'v2/token';
    public static final string CONTENT_ASSETS = 'content/assets';
    public static final string Content = 'application/json; charset=utf8';
    public static final string Mc_Id_End_Point = '/rowset';
    public static final string Mc_End_Point_De = '.rest.marketingcloudapis.com/hub/v1/dataevents/key:';
    
     /** External distribution */
     public static final String AUTOMATION_EXTRA_SQL = 'NewSqlObjId_Step1';
    public static final String AUTOMATION_EXTRA_SQL_STEP1 = 'NewSqlObjId_StepOne';
    public static final String AUTOMATION_EXTRA_SQL_STEP2 = 'NewSqlObjId_Step2';
     public static final String AUTOMATION_THIRD_STEP = '_step3_';
     public static final String AUTOMATION_CREATION_EXTERNAL_NAME = 'ExternalUser_';
    
    /** Utility Class Constants */
    public static final String OC_AN_Utility = 'OC_AN_Utility';
    public static final String getBulletinRelatedRecord = 'getBulletinRelatedRecord';
    public static final String verifyBulletinStatusAndRecordEditability = 'verifyBulletinStatusAndRecordEditability';
    
    /** CallOutUtils Constants */
    public static final String OC_AN_MC_CalloutUtils = 'OC_AN_MC_CalloutUtils';
    public static final String  SEND =  'send';
    
    //Local Bullentin Creation
    public static final string OC_AN_RecordTypeId_Local_Bulletin=Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Local_Bulletin').getRecordTypeId();
    public static final string OC_AN_External_Distribution_List_Status='Hold, I want to modify';   
    public static final string OC_AN_External_Distribution_List_Substatus='I want to modify';       
    public static final string Under_Analysis_Status='Under Analysis'; 
    public static final string Under_Analysis_SubStatus='Under Analysis'; 
    public static final string Internally_Published_Status='Internally Published';
    public static final string STATUS_SEND = 'Send';
    public static final string SUBSTATUS_SEND = 'Send';

    public static final string recordTypeId_LocalPublisher=Schema.SObjectType.OC_AN_Group_Member__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Local_Publisher').getRecordTypeId();
    public static final string HOLD='Hold, I want to modify';   
    public static final string SUBSTATUS_VALUE='I want to modify';    //Message Applicable, but I want to modify   
    public static final string comments='Test';
    public static final string FirstName='Test Local Publisher';
    
    //GroupMemberRecordTypeIds
    public static final string recTypeId_PublicGroupMember =Schema.SObjectType.OC_AN_Group_Member__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Public_Group_Member').getRecordTypeId();
  
    //U-2758
    public static final String recTypeId_UsrPrefBulletin = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Bulletin_Setting').getRecordTypeId();
    public static final String recTypeId_UsrPrefProduct = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Product_Setting').getRecordTypeId();
    public static final String bulletinSetting='Bulletin Setting';
    public static final String productSetting='Product Setting';
    public static final String strQuery = 'SELECT Id,Name,OC_MD_Product__r.Name,OC_MD_Parent__r.OC_MD_Product__r.Name FROM OC_MD_ProductAttributes__c ';
    public static final string csvname= 'CSVUploadStatusFile.csv';
    public static final String subject ='CSV Upload Status';
    public static final String body='Hi,Please find CSV Upload Status File Attached.';
    public static final String sObjectUserPref='OC_AN_User_Preferences__c';
    public static final String queryPart1='(OC_MD_Parent__r.Name =\'';
    public static final String queryPart2='\'  AND Name = \'';
    public static final String queryPart3='\' AND ';
    public static final String queryPart4='OC_MD_Parent__r.OC_MD_Product__r.Name =\'';
    public static final String queryPart5='\' )';
    public static final String queryPart6='(OC_MD_Product__r.Name =\'';
    public static final String queryPart7='\'  AND Name = \'';
    public static final String queryPart8='\')';
    public static final String queryPart9='WHERE ';
    public static final String queryPart10= ' OR ';
    public static final String underScore='_';
    public static final String comma=',';
    public static final String doubleComma=',,';
    public static final String slashN='\n';
    public static final String slashR='\r';
    public static final String ACTION_REQUIRED = 'Action Required';
    
    //Product Selection Improvement Settings
    public static final String VERSION = '___VERSION___';
    public static final String RELEASE = '___RELEASE___';
    public static final String OC_MD_ParentR = 'OC_MD_Parent__r';
    public static final String OC_MD_ParentC = 'OC_MD_Parent__c';
    public static final String OC_MD_ProductC = 'OC_MD_Product__c';
    public static final String OC_MD_Product = 'OC_MD_Product';
    
    public static final String query_Step_1_WithProduct = '_Query_Step_1_WithProduct';
    public static final String step_1_DE_Target_CustomerKey = '_Step_1_DE_Target_CustomerKey';
    public static final String step_1_DE_Target_Name = '_Step_1_DE_Target_Name';
    public static final String query_Step_1 = '_Query_Step_1';
    public static final String step1 = '_step1_';
    public static final String SQLActivity_Query ='_SQLActivity_Query';
    public static final String SQLActivity_Query_WithoutProduct = '_SQLActivity_Query_WithoutProduct';
    public static final String step3 ='_step3_';
    public static final String sql ='_sql';
    
    public static final String DE_CATEGORY_ID ='DE_CategoryId';
    public static final String DE_ENDPOINT ='DE_ENDPOINT';
    public static final String ericcsonLogo='ericcsonLogo';
    
    
    public static final String recTypeId_forSalesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Sales_Account').getRecordTypeId();
    
    public static final String recTypeId_salesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Sales_Account').getRecordTypeId();
    public static final String recTypeId_serviceAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
    public static final String recTypeId_prdUsrPrefrences = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Product_Setting').getRecordTypeId();
    
    public static final String query = 'SELECT Id, Name,Product2.Name,AccountId,OC_MD_Release__c,OC_TH_Release__c,OC_MD_Version__c,Product2Id,recordTypeId FROM Asset where AccountId!=null and Product2Id!=null and OC_MD_Release__c!=null and OC_MD_Version__c!=null';
    
    public static final String ED_FINAL_STEP_QUERY = 'OC_AN_ED_FinalStep_SQLQuery';
     public static final String ED_FINAL_STEP_CustomerKey = 'OC_AN_ED_FinalStep_DE_CustomerKey';

    /*Internal Distribution*/
    public static final String Internal_Groups = '%Internal Groups%';
    
    /*Distribution Summary */
    public static final String MCAccountId = 'AccountId';
    public static final String OC_AN_ExtlDistributionSummaryListCtr = 'OC_AN_ExtlDistributionSummaryListCtr';
    public static final String getExternalDistributionListSummary = 'getExternalDistributionListSummary';
    public static final String XMLBody = 'Body';
    public static final String NodeValue = 'Value';

    public static final String OC_AN_AAndNTriggerHandler = 'OC_AN_AAndNTriggerHandler';
    public static final String AfterUpdate = 'AfterUpdate';
  
}