/**
* @File Name          : OC_TestDataGenerator
* @Description        : Test Data generator for test class OmniChannelThemeControllersTest
*
*						Base copied from TestDataGenerator class
*
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 22nd May 2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-05-22              Rohit Gaba               Initial Version
**/
@isTest
public class OC_TestDataGenerator {

    /**
     * Methods thats creates SObject
     * @param  sObj SObject
     * @return      SObject with all needed information
     */
    public static SObject createSObject(SObject sObj) {
        String objectName = String.valueOf(sObj.getSObjectType());
        String defaultClassName = 'OC_TestDataGenerator.' + objectName.replaceAll('__c|__', '') + 'Defaults';
		system.debug('defaultClassName>> ' +defaultClassName);
        if (Type.forName(defaultClassName) != null) {
            sObj = createSObject(sObj, defaultClassName);
        }
        return sObj;
    }

    /**
     * Method that inserts SObject in Salesforce database
     * @param  sObj     SObject
     * @param  doInsert Determines if object should be added to database if true or should not if false
     * @return          Returns SObject
     */
    public static SObject createSObject(SObject sObj, Boolean doInsert) {
        SObject retObject = createSObject(sObj);

        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }

    /**
     * Method that creates SObject thats has a default class like Account, Case etc.
     * @param  sObj             SObject
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @return                  SObject
     */
    public static SObject createSObject(SObject sObj, String defaultClassName) {
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            Throw new TestFactoryException('Invalid defaults class.');
        }
        FieldDefaults defaults = (FieldDefaults)t.newInstance();

        addFieldDefaults(sObj, defaults.getFieldDefaults());
        return sObj;
    }

    /**
     * Method that inserts SObject in database
     * @param  sObj             SObject
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @param  doInsert         Determines if object should be added to database if true or should not if false
     * @return                  SObject
     */
    public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
        SObject retObject = createSObject(sObj, defaultClassName);
        if (doInsert) {
            insert retObject;
        }
        return retObject;
    }

    /**
     * Method that returns a List of SObjects
     * @param  sObj            SObject
     * @param  numberOfObjects Number that determines how many SObjects should be created
     * @return                 List of SObject
     */
    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
        return createSObjectList(sObj, numberOfObjects, (String)null);
    }

    /**
     * Method that inserts List of SObejct in database
     * @param  sObj            SObject
     * @param  numberOfObjects Number that determines how many SObjects should be created
     * @param  doInsert        Determines if SObject List should be added to database if true or should not if false
     * @return                 List of SObject
     */
    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
        if (doInsert) {
            insert retList;
        }
        return retList;
    }

    /**
     * Method that creates a List of SObject that have a default class like Account, Case etc.
     * @param  sObj             SObject
     * @param  numberOfObjects  Number that determines how many SObjects should be created
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @return                  List of SObject
     */
    public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
        SObject[] sObjs = new SObject[] {};
        SObject newObj;

        if (defaultClassName == null) {
            newObj = createSObject(sObj);
        } else {
            newObj = createSObject(sObj, defaultClassName);
        }

        String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
        if (nameField == null) {
            nameField = 'Name';
        }

        for (Integer i = 0; i < numberOfObjects; i++) {
            SObject clonedSObj = newObj.clone(false, true);
            clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
            sObjs.add(clonedSObj);
        }
        return sObjs;
    }

    /**
     * Method that inserts a List of SObject with a Default class in database
     * @param  sObj             SObject
     * @param  numberOfObjects  Number that determines how many SObjects should be created
     * @param  defaultClassName Name of a default Class like Account, Case etc.
     * @param  doInsert         Determines if SObject List should be added to database if true or should not if false
     * @return                  List of SObject
     */
    public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
        SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
        if (doInsert) {
            insert retList;
        }
        return retList;
    }

    /**
     * Method that sets SObject field values with set default values
     * @param sObj     SObject
     * @param defaults SObject Map with default values that have been set
     */
    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaults) {
        for (String field : defaults.keySet()) {
            if (sObj.get(field) == null) {
                sObj.put(field, defaults.get(field));
            }
        }
    }
    /**
     * Method that create string as per the length
     * @param stringLength length of the string
     * @param stringValue input string value
     */
    public static String createString(Integer stringLength, String stringValue) {

        String strValue ='';
        Integer defaultLength =10 ;
        String defaultString ='TestString';

       	stringLength = (stringLength !=null && stringLength>=1) ? stringLength : defaultLength ;
        stringValue =  (String.isBlank(stringValue)) ? defaultString : stringValue ;


        for (integer i=0; i<stringLength/stringValue.length(); i++){
             strValue +=  stringValue;
        }
        return strValue;
    }

    // When we create a list of SObjects, we need to
    private static Map<String, String> nameFieldMap = new Map<String, String> {
        'Contact' => 'LastName',
        'Case' => 'Subject',
        'Task' => 'Description'
    };

    /**
     * Sub class that throws exception when needed
     */
    public class TestFactoryException extends Exception {}

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }

    // To specify defaults for objects, use the naming convention [ObjectName]Defaults.
    // For custom objects, omit the __c from the Object Name
    //
    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Account',
                'SAP_S2P_ID__c' => '12345',
                'CurrencyIsoCode' => 'SEK',
                'Visible__c' => true
            };
        }
    }

    public class ContactDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'AccountId' => NULL,
                'FirstName' => 'First',
                'LastName' => 'Last',
                'Email' => 'azaza@test.com',
                'MailingCountry' => 'Sweden'
            };
        }
    }

    public class ContentDocumentLinkDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Visibility' => 'AllUsers',
                'ShareType' => 'V',
                'ContentDocumentId' => NULL,
                'LinkedEntityId' => NULL
            };
        }
    }

    public class ContentVersionDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Title' => 'OC Document',
                'PathOnClient' => 'OCDOcument.pdf',
                'VersionData' => Blob.valueOf('OC Content'),
                'IsMajorVersion' => True
            };
        }
    }

    public class FeedCommentDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'CommentBody' => '<p><b>OC Comment Body</b></p>',
                'FeedItemId' => NULL
            };
        }
    }

    public class FeedItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Title' => 'OC Post Title',
                'Body' => '<p><b>OC Post Body</b></p>',
                'Type' => 'QuestionPost',
                'NetworkScope' => NULL,
                'Visibility' => 'AllUsers',
                'ParentId' => UserInfo.getUserId()
            };
        }
    }

    public class IntegrationUserDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
			String tempUserId = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128)).subString(0,8);
            return new Map<String, Object> {
                'Alias' => tempUserId,
                'Email' => tempUserId + '@ericsson.com.test',
                'EmailEncodingKey' => 'UTF-8',
                'FirstName' => 'OC Integration',
				'LastName' => 'Testing',
				'LanguageLocaleKey' => 'en_US',
				'LocaleSidKey' => 'en_US',
				'TimeZoneSidKey' => 'Europe/Paris',
				'UserName' => tempUserId + '@ericsson.com.test'
            };
        }
    }
    //Modified on: 02-Jul-2021
    //Added CSN Queue as not null to test code change as part of U-2926 
	public class PartnerAccountDefaults implements FieldDefaults {
        //Adding record type in inserted account
        Id serviceAccRecordType= Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Account').getRecordTypeId();           
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Partner Account',
                'CurrencyIsoCode' => 'SEK',
                'Account_Type__c' => 'Service',
                'RecordtypeId' => serviceAccRecordType,
                'CNS_Queue__c' => 'AMX1/CNS',  
				'Visible__c' => True
            };
        }
    }

    public class PartnerContactDefaults implements FieldDefaults {
        String tempUserId = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128)).subString(0,8);
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'FirstName' => 'Partner',
                'LastName' => 'Contact',
                'MailingCountry' => 'Sweden'
            };
        }
    }

	public class PartnerUserDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
			String tempUserId = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128)).subString(0,8);
            return new Map<String, Object> {
                'Alias' => tempUserId,
                'Email' => tempUserId + '@ericsson.com.test',
                'EmailEncodingKey' => 'UTF-8',
                'FirstName' => 'OC Partner',
				'LastName' => 'Testing',
				'LanguageLocaleKey' => 'en_US',
				'LocaleSidKey' => 'en_US',
				'TimeZoneSidKey' => 'Europe/Paris',
				'UserName' => tempUserId + '@ericsson.com.test'
            };
        }
    }

    public class TopicAssignmentDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'EntityId' => NULL,
				'TopicId' => NULL
            };
        }
    }

    public class TopicDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'OC Topic',
                'Description' => 'OC Topic',
				'NetworkId' => NULL
            };
        }
    }

	public class Topic2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'OC Topic 2',
                'Description' => 'OC Topic 2',
				'NetworkId' => NULL
            };
        }
    }

	public class Topic3Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'OC Topic 3',
                'Description' => 'OC Topic 3',
				'NetworkId' => NULL
            };
        }
    }

	public class UserDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
			String tempUserId = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128)).subString(0,8);
            return new Map<String, Object> {
                'Alias' => tempUserId,
                'Email' => tempUserId + '@ericsson.com.test',
                'EmailEncodingKey' => 'UTF-8',
                'FirstName' => 'OC',
				'LastName' => 'Testing',
				'LanguageLocaleKey' => 'en_US',
				'LocaleSidKey' => 'en_US',
				'TimeZoneSidKey' => 'Europe/Paris',
				'UserName' => tempUserId + '@ericsson.com.test'
            };
        }
    }

    public class UserRoleDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'DeveloperName' => 'OC_Role',
                'Name' => 'OC Role'
            };
        }
    }

    public class CaseDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Subject' => 'Test Case',
                'Origin' => 'Web',
                'Status' => 'New',
                'Type' => 'Installation',
                'Priority' => '1'
            };
        }
    }
    public class GroupDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'A&N - Test Group'
            };
        }
    }

    public class GroupMemberDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {

            };
        }
    }

    public class OC_AN_Bulletin_TemplateDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
            'OC_AN_Delay_In_Hours__c'  => 5,
            'OC_AN_Internal_Text__c'   => 'Internal Text',
            'OC_AN_Template__c'        => 'Template',
            'OC_AN_Type__c'            => 'Emergency Problem'
            };
        }
    }
      public class OC_AN_Bulletin_Account_ProductDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {

            };
        }
    }

     public class OC_AN_Public_GroupDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {

            };
        }
    }

    public class OC_AN_Group_MemberDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {

            };
        }
    }



    public class OC_AN_BulletinDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test Bulletin'
            };
        }
    }
    
    
    public class OC_TH_QueueDefault implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'Name' => 'Test queues',
                'OC_TH_Queue_Type__c' => 'Local'    
            };
        }
    }
    public class RoutingRuleDefault implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                'OC_TH_Selected_Routing_Rule__c' => 'With-in Market Area',
                'OC_TH_Active__c' => true
            };
        }
    }

    public static void insertCustomSettingsData(){
        List<GST_API_Details__c> gstAPICustomSettings = new List<GST_API_Details__c>();
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Base_URL',
			Value__c='https://acc.customersupport.search.ericsson.net/rest/apps/gst/searchers/omnichannel'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Default_Hit',
			Value__c='10'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='External_Profile',
			Value__c='dummy'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Facet_source',
			Value__c='Product+Information'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Internal_User_Signum',
			Value__c='EMP_INTERNAL'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Token',
			Value__c='6kxtrJP60cgx0smZdyc7GjLBFIb'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='HeaderToken',
			Value__c='RjbzzRpd9fM764hQ6zrzt9bt'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Click_Base_URL_PWD',
			Value__c='cpi'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Click_Base_URL_USR',
			Value__c='cpi'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Referrer_Header',
			Value__c='referrer'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Referrer_Community',
			Value__c='https://test.salesforce.com'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Referrer_Console',
			Value__c='https://test.salesforce.com'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Cpi_Doc_Number_Param',
			Value__c='collapse!0!cpi_document_number'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Cpi_Doc_Number_Param_Value',
			Value__c='secondary_hits'
        ));
        gstAPICustomSettings.add(new GST_API_Details__c(
        	Name='Max_Search_Results',
			Value__c='10000'
        ));

        insert gstAPICustomSettings;

        OC_Org_Defaults__c tempServiceOrgDefaults = new OC_Org_Defaults__c();
        tempServiceOrgDefaults.OC_Account_RecType_DevName_Service__c = 'OC_MD_Service_Account';
        tempServiceOrgDefaults.OC_Customer_Community_Profile_Name__c = 'Customer Community Plus Custom User';
        tempServiceOrgDefaults.OC_Extended_Lookup_Limit__c = 200;
        tempServiceOrgDefaults.OC_Forum_Visibility_PermissionSetName__c = 'Ericsson_Service_Community_Chatter';
        tempServiceOrgDefaults.OC_IB_TechStdTransformation_FieldName__c = 'OC_MD_Technology_Standard__c';
        tempServiceOrgDefaults.OC_PriceBookEntryForProduct__c = 'Service Catalog';
        tempServiceOrgDefaults.OC_ProductUploadScriptMaxRecords__c = 500;
        tempServiceOrgDefaults.OC_Standard_Lookup_Limit__c = 5;
        tempServiceOrgDefaults.OC_TH_Case_RecType_DevName_Standard_CSR__c = 'OC_TH_Standard_CSR';
        tempServiceOrgDefaults.OC_IBStagingObjToAssetObjBatchSize__c = 100;
        tempServiceOrgDefaults.OC_IB_InstalledBaseItemsBatchSize__c = 100;
        /*U-2669 Archival Staging Object Changes - begin*/
        tempServiceOrgDefaults.OC_ArchiveStagingObjectCronExp__c = '0 5 * 1/1 * ? *';
        tempServiceOrgDefaults.OC_IB_ArchiveStagingBatchSize__c = 2000;
        /*U-2669 Archival Staging Object Changes - ends*/
        tempServiceOrgDefaults.OC_PRD_StagingObjToProductObjBatchSize__c = 100;
        tempServiceOrgDefaults.OC_PRD_CsdpToStagingObjBatchSize__c=100;

        tempServiceOrgDefaults.OC_CSM_StagingObjToContractObjBatchSize__c = 100;/*U-2676 Contract Response Profile-begin*/
		tempServiceOrgDefaults.OC_CSM_StagingObjToCCObjBatchSize__c=100; //Added for contract sapOrder
       insert tempServiceOrgDefaults;
    }

    public class ServiceContractDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {

            return new Map<String, Object> {
                'Name' => 'Test Service Contract',
                'StartDate' => Date.Today() - 5,
                'EndDate' => Date.Today() + 5
             };
                        }
    }
    public class LiveChatTranscriptDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            LiveChatVisitor visitorRec = new LiveChatVisitor();
            insert visitorRec;

            return new Map<String, Object> {
                'LiveChatVisitorId' => visitorRec.Id,
                 'Status' => 'Completed'
                    };
                        }
    }

    public static void insertIntegrationRecords(){
            Id serviceAccRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Account').getRecordTypeId();
            Id versionRecTypeId = Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByName().get('Version').getRecordTypeId();
            Id ReleaseRecTypeId = Schema.SObjectType.OC_MD_ProductAttributes__c.getRecordTypeInfosByName().get('Release').getRecordTypeId();
            Id integrationContractRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('ServiceContract').getRecordTypeId();
            Id integrationAssetRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
			Id integrationProductRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('ProductNodeType').getRecordTypeId();  // Start Change (Product I/B S2A  - 28 May 2021 XSHAHUS)
			Id integrationNodeTypeNodeCompProductRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('NodeTypeNodeComponent').getRecordTypeId();	
        	Id integrationNodeTypeSolutionProductRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('NodeTypeSolution').getRecordTypeId();	
        	Id integrationProductSolutionProductRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('ProductSolution').getRecordTypeId();	
        	Id integrationProductNodeComponentProductRt = Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByName().get('ProductNodeComponent').getRecordTypeId();
        	Id contractSapOrderRtId =Schema.SObjectType.OC_IB_IntegrationSobjectRecords__c.getRecordTypeInfosByDeveloperName().get('ContractsapOrder').getRecordTypeId(); /*Added for Contract sapOrder*/
        
            List<Account> accList=new List<Account>();

            accList = createSObjectList(new Account(),2);

            accList[0].Name='Test Account';
            accList[0].Account_Type__c='Service';
            accList[0].RecordtypeId=serviceAccRecType;
            accList[0].SAP_S2P_ID_Number__c=1190376;

            accList[1].Name='Test Account1';
            accList[1].Account_Type__c='Service';
            accList[1].RecordtypeId=serviceAccRecType;
            accList[1].SAP_S2P_ID_Number__c=123456;

            insert accList;

            List<Asset> assetList = createSObjectList(new Asset(),7);
            assetList[0].Name='Asset1 Testing';
            assetList[0].OC_IB_Csdp_Id__c='6539004';
            assetList[0].OC_IB_ConcatAssetIdServiceToId__c='6539004+123456';
            assetList[0].AccountId=accList[1].id;

            assetList[1].Name='Asset Testing same csdp';
            assetList[1].OC_IB_Csdp_Id__c='6539004';
            assetList[1].OC_IB_ConcatAssetIdServiceToId__c='6539004+123456';
            assetList[1].AccountId=accList[1].id;


            assetList[2].Name='Asset2 Testing';
            assetList[2].OC_IB_Csdp_Id__c='6539007';
            assetList[2].OC_IB_ConcatAssetIdServiceToId__c='6539007+1190376';
            assetList[2].AccountId=accList[1].id;

            assetList[3].Name='Asset3 Testing';
            assetList[3].OC_IB_Csdp_Id__c='6539008';
            assetList[3].OC_IB_ConcatAssetIdSoldToId__c='6539008+507952';
            assetList[3].AccountId=accList[0].id;


            assetList[4].name='BSCRJ52-TA-2';
            assetList[4].Accountid=accList[0].id;
            assetList[4].OC_IB_Csdp_Id__c='14346';
            assetList[4].OC_IB_ConcatAssetIdSoldToId__c='14346+507952';
            assetList[4].OC_IB_ConcatAssetIdServiceToId__c='14346+1190367';

            assetList[5].name='BSCRJ52-TA-3';
            assetList[5].Accountid= accList[0].id;
            assetList[5].OC_IB_Csdp_Id__c='14347';
            assetList[5].OC_IB_ConcatAssetIdSoldToId__c='14347+507952';
            assetList[5].OC_IB_ConcatAssetIdServiceToId__c='14347+1190367';

            assetList[6].name='BSCRJ52-TA-1';
            assetList[6].Accountid= accList[0].id;
            assetList[6].OC_IB_Csdp_Id__c='14345';
            assetList[6].OC_IB_ConcatAssetIdSoldToId__c=null;
            assetList[6].OC_IB_Sold_To_Id__c=accList[0].id;
            assetList[6].OC_IB_ConcatAssetIdServiceToId__c='14345+1190367';

            insert assetList;

            List<pricebook2> priceBookList = createSObjectList(new pricebook2(),1);
            priceBookList[0].name='Service Catalog';
            insert priceBookList;


            List<ServiceContract> serviceContractList = createSObjectList(new ServiceContract(),2);

            serviceContractList[0].Name='ContractName';
            serviceContractList[0].AccountId=accList[1].id;
            serviceContractList[0].OC_MD_Contract_Number__c='112345';

            serviceContractList[1].Name='ContractName1';
            serviceContractList[1].AccountId=accList[1].id;
            serviceContractList[1].OC_MD_Contract_Number__c='11222';
            insert serviceContractList;



            List<OC_MD_Installed_Base_Item__c> ibitemslist=createSObjectList(new OC_MD_Installed_Base_Item__c(),2);

            ibitemslist[0].name='Asset1 Testing_112345';
            ibitemslist[0].OC_MD_Asset__c=assetList[2].id;
            ibitemslist[0].OC_MD_Service_Contract__c=serviceContractList[0].id;

            ibitemslist[1].name='Asset1 Testing_112345';
            ibitemslist[1].OC_MD_Asset__c=assetList[2].id;
            ibitemslist[1].OC_MD_Service_Contract__c=serviceContractList[1].id;

            insert ibitemslist;

            List<product2> productList=new List<product2>();
            productList = createSObjectList(new Product2(),1);
            productList[0].name='BTS';
            productList[0].Product_Code_Number__c='1224';
            insert productList;


            List<OC_IB_IntegrationSobjectRecords__c> integrationSobjectRecords=createSObjectList(new OC_IB_IntegrationSobjectRecords__c(),22);
            integrationSobjectRecords[0].name='contractName';
            integrationSobjectRecords[0].OC_CSM_Contract_assignmentId__c='6879001';
            integrationSobjectRecords[0].OC_CSM_Contract_Number__c	='112345';
            integrationSobjectRecords[0].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[0].RecordTypeId=integrationContractRt;
            integrationSobjectRecords[0].OC_CSM_Contract_serviceElements__c='product CSR;invalid Element';
            integrationSobjectRecords[0].OC_IB_ActualObjectSyncStatus__c='To be synced';
            integrationSobjectRecords[0].OC_IB_Asset_ConcatAsSetIdServiceToId__c='6879001+123456';

            integrationSobjectRecords[1].OC_IB_Asset_Csdp_Id__c='6539004';
            integrationSobjectRecords[1].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[1].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[1].OC_IB_ActualObjectSyncStatus__c='Asset Sync Success';
            integrationSobjectRecords[1].RecordTypeId=integrationAssetRt;
            integrationSobjectRecords[1].OC_IB_Asset_Service_To_Id__c='123456';
            integrationSobjectRecords[1].OC_IB_Contract_Numbers__c='112345;1122';
            integrationSobjectRecords[1].OC_IB_Asset_ConcatAsSetIdServiceToId__c='6539004+123456';

            integrationSobjectRecords[2].OC_IB_Asset_Csdp_Id__c='6539004';
            integrationSobjectRecords[2].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[2].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[2].OC_IB_ActualObjectSyncStatus__c='Asset Sync Success';
            integrationSobjectRecords[2].RecordTypeId=integrationAssetRt;
            integrationSobjectRecords[2].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[2].OC_IB_Contract_Numbers__c='112345;1122';
            integrationSobjectRecords[2].OC_IB_Asset_ConcatAsSetIdServiceToId__c='6539004+1190376';

            integrationSobjectRecords[3].OC_IB_Asset_Csdp_Id__c='6539007';
            integrationSobjectRecords[3].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[3].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[3].OC_IB_ActualObjectSyncStatus__c='Asset Sync Success';
            integrationSobjectRecords[3].RecordTypeId=integrationAssetRt;
            integrationSobjectRecords[3].OC_IB_Contract_Numbers__c='112345';
            integrationSobjectRecords[3].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[3].OC_IB_Asset_ConcatAsSetIdServiceToId__c='6539007+1190376';

            integrationSobjectRecords[4].OC_IB_Asset_Csdp_Id__c='6539007';
            integrationSobjectRecords[4].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[4].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[4].OC_IB_ActualObjectSyncStatus__c='Asset Sync Success';
            integrationSobjectRecords[4].OC_IB_Contract_Numbers__c='12345678';
            integrationSobjectRecords[4].OC_IB_Asset_Service_To_Id__c='123456';
            integrationSobjectRecords[4].OC_IB_Asset_ConcatAsSetIdServiceToId__c='6539007+123456';
            integrationSobjectRecords[4].OC_IB_Asset_ConcatAssetIdSoldToId__c='';
            integrationSobjectRecords[4].RecordTypeId=integrationAssetRt;

            integrationSobjectRecords[5].OC_IB_Asset_Csdp_Id__c='6539009';
            integrationSobjectRecords[5].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[5].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[5].OC_IB_ActualObjectSyncStatus__c='Asset Sync Success';
            integrationSobjectRecords[5].RecordTypeId=integrationAssetRt;
            integrationSobjectRecords[5].OC_IB_Asset_Service_To_Id__c='';
            integrationSobjectRecords[5].OC_IB_Contract_Numbers__c='112345';
            integrationSobjectRecords[5].OC_IB_Asset_ConcatAsSetIdServiceToId__c='';
            integrationSobjectRecords[5].OC_IB_Asset_Sold_To_Id__c='507952';
            integrationSobjectRecords[5].OC_IB_Asset_ConcatAssetIdSoldToId__c='6539008+507952';

            integrationSobjectRecords[6].OC_IB_Asset_Csdp_Id__c='6539008';
            integrationSobjectRecords[6].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[6].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[6].OC_IB_ActualObjectSyncStatus__c='Asset Sync Success';
            integrationSobjectRecords[6].RecordTypeId=integrationAssetRt;
            integrationSobjectRecords[6].OC_IB_Asset_Service_To_Id__c='';
            integrationSobjectRecords[6].OC_IB_Contract_Numbers__c='';
            integrationSobjectRecords[6].OC_IB_Asset_ConcatAsSetIdServiceToId__c='';
            integrationSobjectRecords[6].OC_IB_Asset_Sold_To_Id__c='507952';
            integrationSobjectRecords[6].OC_IB_Asset_ConcatAssetIdSoldToId__c='6539008+507952';


            integrationSobjectRecords[7].OC_IB_Asset_Csdp_Id__c='6539008';
            integrationSobjectRecords[7].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[7].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[7].OC_IB_ActualObjectSyncStatus__c='Sync Partial Success';
            integrationSobjectRecords[7].RecordTypeId=integrationAssetRt;
            integrationSobjectRecords[7].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[7].OC_IB_Contract_Numbers__c='112345';
            integrationSobjectRecords[7].OC_IB_Asset_ConcatAsSetIdServiceToId__c='6539008+1190376';
            integrationSobjectRecords[7].OC_IB_Asset_Sold_To_Id__c='507952';
            integrationSobjectRecords[7].OC_IB_Asset_ConcatAssetIdSoldToId__c='6539008+507952';

            integrationSobjectRecords[8].OC_IB_Asset_Csdp_Id__c='6539004';
            integrationSobjectRecords[8].OC_IB_Asset_SW_Version__c='L18.Q3';
            integrationSobjectRecords[8].OC_IB_Asset_SW_Release__c='BTS G16B.11';
            integrationSobjectRecords[8].OC_IB_ActualObjectSyncStatus__c='To be Synced';
            integrationSobjectRecords[8].OC_IB_Contract_Numbers__c='12345678';
            integrationSobjectRecords[8].OC_IB_Asset_Service_To_Id__c='123456';
            integrationSobjectRecords[8].OC_IB_Asset_ConcatAsSetIdServiceToId__c='';
            integrationSobjectRecords[8].OC_IB_Asset_Sold_To_Id__c='507952';
            integrationSobjectRecords[8].OC_IB_Asset_ConcatAssetIdSoldToId__c='6539007+507952';


            integrationSobjectRecords[9].name='contractName1';
            integrationSobjectRecords[9].OC_CSM_Contract_assignmentId__c='6879001';
            integrationSobjectRecords[9].OC_CSM_Contract_Number__c  ='112345';
            integrationSobjectRecords[9].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[9].RecordTypeId=integrationContractRt;
            integrationSobjectRecords[9].OC_CSM_Contract_serviceElements__c='product CSR;invalid Element';
            integrationSobjectRecords[9].OC_IB_ActualObjectSyncStatus__c='To be synced';
            integrationSobjectRecords[9].OC_CSM_ResponseProfile__c='[{"timeUnit":"MINUTE","timeValue":15,"responseDurationType":"CALLBACK1","responseDurationPriority":""},{"timeUnit":"","timeValue":0,"responseDurationType":"","responseDurationPriority":""},{"timeUnit":"HOUR","timeValue":1,"responseDurationType":"CALLBACK1","responseDurationPriority":""},{"timeUnit":"WEEK","timeValue":5,"responseDurationType":"SOLUTION1","responseDurationPriority":"MEDIUM"},{"timeUnit":"","timeValue":0,"responseDurationType":"SOLUTION2","responseDurationPriority":"MEDIUM"},{"timeUnit":"HOUR","timeValue":2,"responseDurationType":"CALLBACK1","responseDurationPriority":"LOW"},{"timeUnit":"","timeValue":0,"responseDurationType":"CALLBACK2","responseDurationPriority":"LOW"}]';

        	integrationSobjectRecords[10].name='contractName2';
            integrationSobjectRecords[10].OC_CSM_Contract_assignmentId__c='6879001';
            integrationSobjectRecords[10].OC_CSM_Contract_Number__c  ='112345';
            integrationSobjectRecords[10].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[10].RecordTypeId=integrationContractRt;
            integrationSobjectRecords[10].OC_CSM_Contract_serviceElements__c='product CSR;invalid Element';
            integrationSobjectRecords[10].OC_IB_ActualObjectSyncStatus__c='To be synced';
            integrationSobjectRecords[10].OC_CSM_ResponseProfile__c='[{"timeUnit":"MINUTE","timeValue":15,"responseDurationType":"CALLBACK1","responseDurationPriority":"EMERGENCY"},{"timeUnit":"","timeValue":0,"responseDurationType":"CALLBACK2","responseDurationPriority":"EMERGENCY"},{"timeUnit":"HOUR","timeValue":1,"responseDurationType":"CALLBACK1","responseDurationPriority":"HIGH"},{"timeUnit":"WEEK","timeValue":5,"responseDurationType":"SOLUTION1","responseDurationPriority":"MEDIUM"},{"timeUnit":"","timeValue":0,"responseDurationType":"SOLUTION2","responseDurationPriority":"MEDIUM"},{"timeUnit":"HOUR","timeValue":2,"responseDurationType":"CALLBACK1","responseDurationPriority":"LOW"},{"timeUnit":"","timeValue":0,"responseDurationType":"CALLBACK2","responseDurationPriority":"LOW"}]';



            integrationSobjectRecords[11].name='contractName4';
            integrationSobjectRecords[11].OC_CSM_Contract_assignmentId__c='6879001';
            integrationSobjectRecords[11].OC_CSM_Contract_Number__c  ='88832';
            integrationSobjectRecords[11].OC_IB_Asset_Service_To_Id__c='123456';
            integrationSobjectRecords[11].RecordTypeId=integrationContractRt;
            integrationSobjectRecords[11].OC_CSM_Contract_serviceElements__c='product CSR;invalid Element';
            integrationSobjectRecords[11].OC_IB_ActualObjectSyncStatus__c='To be synced';
            integrationSobjectRecords[11].OC_CSM_ResponseProfile__c='[{"timeUnit":"MINUTE","timeValue":15,"responseDurationType":"CALLBACK1","responseDurationPriority":"EMERGENCY"},{"timeUnit":"","timeValue":0,"responseDurationType":"CALLBACK2","responseDurationPriority":"EMERGENCY"},{"timeUnit":"HOUR","timeValue":1,"responseDurationType":"CALLBACK1","responseDurationPriority":"HIGH"},{"timeUnit":"WEEK","timeValue":5,"responseDurationType":"SOLUTION1","responseDurationPriority":"MEDIUM"},{"timeUnit":"","timeValue":0,"responseDurationType":"SOLUTION2","responseDurationPriority":"MEDIUM"},{"timeUnit":"HOUR","timeValue":2,"responseDurationType":"CALLBACK1","responseDurationPriority":"LOW"},{"timeUnit":"","timeValue":0,"responseDurationType":"CALLBACK2","responseDurationPriority":"LOW"}]';

			integrationSobjectRecords[12].name='contractName5';
            integrationSobjectRecords[12].OC_CSM_Contract_assignmentId__c='6879001';
            integrationSobjectRecords[12].OC_CSM_Contract_Number__c  ='83132';
            integrationSobjectRecords[12].OC_IB_Asset_Service_To_Id__c='1190376';
            integrationSobjectRecords[12].RecordTypeId=integrationContractRt;
            integrationSobjectRecords[12].OC_CSM_Contract_serviceElements__c='product CSR;invalid Element';
            integrationSobjectRecords[12].OC_IB_ActualObjectSyncStatus__c='To be synced';
            integrationSobjectRecords[12].OC_CSM_ResponseProfile__c='[{"timeUnit":"MINUTE","timeValue":15,"responseDurationType":"CALLBACK1","responseDurationPriority":"EMERGENCY"},{"timeUnit":"DAY","timeValue":10,"responseDurationType":"CALLBACK2","responseDurationPriority":"EMERGENCY"},{"timeUnit":"HOUR","timeValue":1,"responseDurationType":"CALLBACK1","responseDurationPriority":"HIGH"},{"timeUnit":"WEEK","timeValue":5,"responseDurationType":"SOLUTION1","responseDurationPriority":"MEDIUM"},{"timeUnit":"YEAR","timeValue":1,"responseDurationType":"","responseDurationPriority":""},{"timeUnit":"HOUR","timeValue":2,"responseDurationType":"CALLBACK1","responseDurationPriority":""},{"timeUnit":"","timeValue":0,"responseDurationType":"","responseDurationPriority":"LOW"}]';

        	integrationSobjectRecords[13].name='BMCV';
            integrationSobjectRecords[13].OC_PRD_ProductTechnolgyStandard__c = 'N';
            integrationSobjectRecords[13].OC_PRD_ProductDescription__c ='Juniper/BMC';
            integrationSobjectRecords[13].OC_PRD_Product_PlatformName__c  ='Juniper; BMC';
            integrationSobjectRecords[13].RecordTypeId=integrationProductRt;
            integrationSobjectRecords[13].OC_IB_Asset_Product_Model__c= 'P1,P2';
            integrationSobjectRecords[13].OC_PRD_Release_EOS__c='2010-06-20T00:00:00.000+0000';
            integrationSobjectRecords[13].OC_PRD_Release_EOM__c='2010-05-30T00:00:00.000+0000';
            integrationSobjectRecords[13].OC_PRD_Release_GA__c='2010-05-30T00:00:00.000+0000';
        	integrationSobjectRecords[13].OC_PRD_Release_PrimNo__c = createString(100,'TestPrimeNo');
            integrationSobjectRecords[13].OC_PRD_Release_Name__c ='Testrelease';
        	integrationSobjectRecords[13].OC_PRD_CompetenceSubDomainName__c ='Testrelease';
        	integrationSobjectRecords[13].OC_PRD_Platform_Pcode__c ='"TestPlatform+123";"test+345"';
        	integrationSobjectRecords[13].OC_PRD_Customer__c ='111112';
            integrationSobjectRecords[13].OC_PRD_VersionName__c ='15,16,17,18,19,20,21,22,24,23,26';
            integrationSobjectRecords[13].OC_IB_ActualObjectSyncStatus__c ='To be Synced';
            integrationSobjectRecords[13].OC_PRD_TechConcatProductRelease__c =  'BMCV'+'+'+'Testrelease'+'+'+'Node Type';
			
        	integrationSobjectRecords[14].name='BMCVtest1';
            integrationSobjectRecords[14].OC_PRD_ProductTechnolgyStandard__c = 'N';
            integrationSobjectRecords[14].OC_PRD_ProductDescription__c ='Juniper/BMC';
            integrationSobjectRecords[14].OC_PRD_Product_PlatformName__c  ='Juniper; BMC';
            integrationSobjectRecords[14].RecordTypeId=integrationProductRt;
            integrationSobjectRecords[14].OC_IB_Asset_Product_Model__c= 'P1,P2';
            integrationSobjectRecords[14].OC_PRD_Release_EOS__c='2010-06-20T00:00:00.000+0000';
            integrationSobjectRecords[14].OC_PRD_Release_EOM__c='2010-05-30T00:00:00.000+0000';
            integrationSobjectRecords[14].OC_PRD_Release_GA__c='2010-05-30T00:00:00.000+0000';
        	integrationSobjectRecords[14].OC_PRD_Release_PrimNo__c = '123';
            integrationSobjectRecords[14].OC_PRD_Release_Name__c ='Testrelease';
        	integrationSobjectRecords[14].OC_PRD_Platform_Pcode__c ='"TestPlatform+null";"test+345"';
        	integrationSobjectRecords[14].OC_PRD_CompetenceSubDomainName__c ='Testrelease';
        	integrationSobjectRecords[14].OC_PRD_Customer__c ='111112';
            integrationSobjectRecords[14].OC_PRD_VersionName__c =createString(100,'TestPrimeNo');
            integrationSobjectRecords[14].OC_IB_ActualObjectSyncStatus__c ='To be Synced';
            integrationSobjectRecords[14].OC_PRD_TechConcatProductRelease__c =  'BMCVtest1'+'+'+'Testrelease'+'+'+'Node Type';
        	
        	integrationSobjectRecords[15].name='BMCVtest2';
            integrationSobjectRecords[15].OC_PRD_ProductTechnolgyStandard__c = 'N';
            integrationSobjectRecords[15].OC_PRD_ProductDescription__c ='Juniper/BMC';
            integrationSobjectRecords[15].OC_PRD_Product_PlatformName__c  ='Juniper; BMC';
            integrationSobjectRecords[15].RecordTypeId=integrationProductRt;
            integrationSobjectRecords[15].OC_IB_Asset_Product_Model__c= 'P1,P2';
            integrationSobjectRecords[15].OC_PRD_Release_EOS__c='2010-05-30T00:00:00.000+0000';
            integrationSobjectRecords[15].OC_PRD_Release_EOM__c='2010-05-30T00:00:00.000+0000';
            integrationSobjectRecords[15].OC_PRD_Release_GA__c='2010-05-30T00:00:00.000+0000';
        	integrationSobjectRecords[15].OC_PRD_Release_PrimNo__c = '123';
            integrationSobjectRecords[15].OC_PRD_Release_Name__c ='Testrelease';
        	integrationSobjectRecords[15].OC_PRD_CompetenceSubDomainName__c ='Testrelease';
        	integrationSobjectRecords[15].OC_PRD_Customer__c ='111112';
            integrationSobjectRecords[15].OC_PRD_VersionName__c =createString(100,'TestPrimeNo');
            integrationSobjectRecords[15].OC_IB_ActualObjectSyncStatus__c ='To be Synced';
            integrationSobjectRecords[15].OC_PRD_TechConcatProductRelease__c =  'BMCVtest2'+'+'+'Testrelease'+'+'+'Node Type';
        
        				//Solution And Node Component Changes Start	
        	integrationSobjectRecords[16].name='BMCVtest2';	
            integrationSobjectRecords[16].OC_PRD_ProductTechnolgyStandard__c = 'N';	
            integrationSobjectRecords[16].OC_PRD_ProductDescription__c ='Juniper/BMC';	
            integrationSobjectRecords[16].OC_PRD_Product_PlatformName__c  ='Juniper; BMC';	
            integrationSobjectRecords[16].RecordTypeId=integrationProductNodeComponentProductRt;	
            integrationSobjectRecords[16].OC_IB_Asset_Product_Model__c= 'P1,P2';	
            integrationSobjectRecords[16].OC_PRD_Release_EOS__c='2010-05-30T00:00:00.000+0000';	
            integrationSobjectRecords[16].OC_PRD_Release_EOM__c='2010-05-30T00:00:00.000+0000';	
            integrationSobjectRecords[16].OC_PRD_Release_GA__c='2010-05-30T00:00:00.000+0000';	
        	integrationSobjectRecords[16].OC_PRD_Release_PrimNo__c = '123';	
            integrationSobjectRecords[16].OC_PRD_Release_Name__c ='Testrelease';	
        	integrationSobjectRecords[16].OC_PRD_CompetenceSubDomainName__c ='Testrelease';	
        	integrationSobjectRecords[16].OC_PRD_Customer__c ='111112';	
            integrationSobjectRecords[16].OC_IB_ActualObjectSyncStatus__c ='To be Synced';	
            integrationSobjectRecords[16].OC_PRD_TechConcatProductRelease__c =  'BMCVtest2'+'+'+'Testrelease'+'+'+'Node Component';	
        	integrationSobjectRecords[17].name='BMCVtest2';	
            integrationSobjectRecords[17].OC_PRD_ProductTechnolgyStandard__c = 'N';	
            integrationSobjectRecords[17].OC_PRD_ProductDescription__c ='Juniper/BMC';	
            integrationSobjectRecords[17].OC_PRD_Product_PlatformName__c  ='Juniper; BMC';	
            integrationSobjectRecords[17].RecordTypeId=integrationProductSolutionProductRt;	
            integrationSobjectRecords[17].OC_IB_Asset_Product_Model__c= 'P1,P2';	
            integrationSobjectRecords[17].OC_PRD_Release_EOS__c='2010-05-30T00:00:00.000+0000';	
            integrationSobjectRecords[17].OC_PRD_Release_EOM__c='2010-05-30T00:00:00.000+0000';	
            integrationSobjectRecords[17].OC_PRD_Release_GA__c='2010-05-30T00:00:00.000+0000';	
        	integrationSobjectRecords[17].OC_PRD_Release_PrimNo__c = '123';	
            integrationSobjectRecords[17].OC_PRD_Release_Name__c ='Testrelease';	
        	integrationSobjectRecords[17].OC_PRD_CompetenceSubDomainName__c ='Testrelease';	
        	integrationSobjectRecords[17].OC_PRD_Customer__c ='111112';	
            integrationSobjectRecords[17].OC_IB_ActualObjectSyncStatus__c ='To be Synced';	
            integrationSobjectRecords[17].OC_PRD_TechConcatProductRelease__c =  'BMCVtest2'+'+'+'Testrelease'+'+'+'Solution';	
				
        	integrationSobjectRecords[18].name='BMCVtest2';	
        	integrationSobjectRecords[18].OC_PRD_NodeComponentReleaseName__c ='Testrelease';	
        	integrationSobjectRecords[18].OC_PRD_NodeTypeName__c = 'BMCVtest1';	
        	integrationSobjectRecords[18].OC_PRD_NodeTypeSwReleaseName__c = 'Testrelease';	
        	integrationSobjectRecords[18].OC_PRD_TechConcatProductRelease__c = 'BMCVtest2+Testrelease+BMCVtest1+Testrelease+Node Component';	
            integrationSobjectRecords[18].RecordTypeId = integrationNodeTypeNodeCompProductRt;	
				
			integrationSobjectRecords[19].name='BMCVtest2';	
        	integrationSobjectRecords[19].OC_PRD_SolutionReleaseName__c ='Testrelease';	
        	integrationSobjectRecords[19].OC_PRD_NodeTypeName__c = 'BMCVtest1';	
        	integrationSobjectRecords[19].OC_PRD_NodeTypeSwReleaseName__c = 'Testrelease';	
        	integrationSobjectRecords[19].OC_PRD_TechConcatProductRelease__c = 'BMCVtest2+Testrelease+BMCVtest1+Testrelease+Solution';	
            integrationSobjectRecords[19].RecordTypeId = integrationNodeTypeSolutionProductRt;	
        		
        	integrationSobjectRecords[20].name='BMCVtest2';	
        	integrationSobjectRecords[20].OC_PRD_SolutionReleaseName__c ='Testrelease';	
        	integrationSobjectRecords[20].OC_PRD_NodeTypeName__c = '';	
        	integrationSobjectRecords[20].OC_PRD_NodeTypeSwReleaseName__c = 'Testrelease';	
        	integrationSobjectRecords[20].OC_PRD_TechConcatProductRelease__c = 'BMCVtest2+Testrelease+Testrelease+Solution';	
            integrationSobjectRecords[20].RecordTypeId = integrationNodeTypeSolutionProductRt;	
           //Solution And Node Component Changes End
           
          /*Start: Added for Contract sapOrder*/
            integrationSobjectRecords[21].name='contractsapOrderName1';
            integrationSobjectRecords[21].OC_CSM_sapOrderContractNumber__c  ='112345';
            integrationSobjectRecords[21].RecordTypeId=contractSapOrderRtId;
            integrationSobjectRecords[21].OC_CSM_Network_Id__c='0067891';
        	integrationSobjectRecords[21].OC_CSM_Service_Order_Number__c='00898415';
            integrationSobjectRecords[21].OC_IB_ActualObjectSyncStatus__c='To be synced';
            integrationSobjectRecords[21].OC_CSM_Network_Description__c='Test contract sapOrder';
            integrationSobjectRecords[21].OC_CSM_Company_Code__c='6574';
        	integrationSobjectRecords[21].OC_CSM_concatContractNetworkServiceOrder__c='112345+0067891+00898415';
            /*End: Added for Contract sapOrder*/
        
        //Product MR start
        for (Integer i = 0; i<=20; i++  ) {

            OC_IB_IntegrationSobjectRecords__c integrationSobject= new OC_IB_IntegrationSobjectRecords__c();
            integrationSobject.name='BMC'+i;
            integrationSobject.OC_PRD_ProductTechnolgyStandard__c = 'N';
            integrationSobject.OC_PRD_ProductDescription__c ='Juniper/BMC';
            integrationSobject.OC_PRD_Product_PlatformName__c  ='Juniper; BMC';
            integrationSobject.RecordTypeId=integrationProductRt;
            integrationSobject.OC_IB_Asset_Product_Model__c= 'P1,P2';
            integrationSobject.OC_PRD_Release_EOS__c='2010-06-20T00:00:00.000+0000';
            integrationSobject.OC_PRD_Release_EOM__c='2010-05-30T00:00:00.000+0000';
            integrationSobject.OC_PRD_Release_GA__c='2010-05-30T00:00:00.000+0000';
            integrationSobject.OC_PRD_Release_Name__c ='Test'+i;
            integrationSobject.OC_PRD_VersionName__c ='15,16,17,18,19,20,21,22,24,23,26';
            If(i==9)
                integrationSobject.OC_PRD_ProductTechnolgyStandard__c = 'Nss';
            integrationSobject.OC_IB_ActualObjectSyncStatus__c ='To be Synced';
            integrationSobject.OC_PRD_TechConcatProductRelease__c =  integrationSobject.name+'+'+integrationSobject.OC_PRD_Release_Name__c+'+'+'Node Type';
            integrationSobjectRecords.add(integrationSobject);
        }

        //Product MR End
        
        insert integrationSobjectRecords;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        Update standardPricebook;
       

            List<OC_MD_ProductAttributes__c> prodAttributesList=createSObjectList(new OC_MD_ProductAttributes__c(),2);
            prodAttributesList[0].Name='L16B.10-2';
            prodAttributesList[0].recordTypeId=versionRecTypeId;

            prodAttributesList[1].Name='L18.Q3';
            prodAttributesList[1].recordTypeId=ReleaseRecTypeId;

            insert prodAttributesList;
      }
}