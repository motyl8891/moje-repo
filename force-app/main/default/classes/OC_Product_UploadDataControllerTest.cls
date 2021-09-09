/**
* @File Name          : OC_Product_UploadDataControllerTest
* @Description        : Test Class for
*						OC_Product_UploadDataController (Direct)
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 04th September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
**/
@isTest
public class OC_Product_UploadDataControllerTest {
    
    @isTest(SeeAllData = false)
    public static void positiveExecution() {
        Test.startTest();
        Integer recordsCount = OC_Product_UploadDataController.processData(JSON.serialize(new TestDataFactory().generateRecordsWithAllPositiveTestCases())).size();
        System.assertEquals(true, recordsCount > 0);
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void generateRecordsWithAllPosibilitiesNullProduct() {
        Test.startTest();
        Integer recordsCount = OC_Product_UploadDataController.processData(JSON.serialize(new TestDataFactory().generateRecordsWithAllPosibilitiesNullProduct())).size();
        System.assertEquals(true, recordsCount > 0);
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void generateRecordsWithAllPosibilitiesNullRelease() {
        Test.startTest();
        Integer recordsCount = OC_Product_UploadDataController.processData(JSON.serialize(new TestDataFactory().generateRecordsWithAllPosibilitiesNullRelease())).size();
        System.assertEquals(true, recordsCount > 0);
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void generateRecordsWithAllPosibilitiesNullVersion() {
        Test.startTest();
        Integer recordsCount = OC_Product_UploadDataController.processData(JSON.serialize(new TestDataFactory().generateRecordsWithAllPosibilitiesNullVersion())).size();
        System.assertEquals(true, recordsCount > 0);
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void generateRecordsWithAllNegativeTestCases() {
        Test.startTest();
        Integer recordsCount = OC_Product_UploadDataController.processData(JSON.serialize(new TestDataFactory().generateRecordsWithAllNegativeTestCases())).size();
        System.assertEquals(true, recordsCount > 0);
        Test.stopTest();
    }
    
    public class TestDataFactory{
        public List<String> technologyStandardPicklistValues;
        public List<String> hardwarePlatformPicklistValues;
        public TestDataFactory(){
            getPickListValuesFromSystem();
        }
        public void getPickListValuesFromSystem(){
            Schema.SObjectType s = Schema.getGlobalDescribe().get('Product2') ;
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
            
            Schema.DescribeFieldResult fieldResult = fields.get('OC_MD_Technology_Standard__c').getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            technologyStandardPicklistValues = new List<String>();
            for( Schema.PicklistEntry pickListVal : ple){
                technologyStandardPicklistValues.add(pickListVal.getValue());
            }
            
            Schema.DescribeFieldResult fieldResultHW = fields.get('OC_MD_Platform__c').getDescribe();
            List<Schema.PicklistEntry> pleHW = fieldResultHW.getPicklistValues();
            hardwarePlatformPicklistValues = new List<String>();
            for( Schema.PicklistEntry pickListVal : pleHW){
                hardwarePlatformPicklistValues.add(pickListVal.getValue());
            } 
        }
        /* Possible Negative Test Cases are as follows
         * Product Name is NULL                     || Release Name is NULL             || Version Name is NULL         
        || Invalid date Format Expected yyyy-mm-dd  || Invalid Hardware Map             || Invalid Technology Standard  
           
        Possible Positive Test Cases are as follows
        || Duplicate Product                        || Duplicate Release for Product    || Duplicate Version for a Release     
        || Duplicate Service Model                  || Duplicate Hardware Map           || Duplicate Technology Standard    

           Bulk load testing 
        || Bulk data test above 800
        || Bulk data test above 1000                || Bulk data test above 9000        || Bulk data test above 10000
        */
        public List<OC_Product_UploadDataController.ProductWrapper> generateRecordsWithAllPosibilitiesNullProduct(){
            List<OC_Product_UploadDataController.ProductWrapper> listOfRecords = new List<OC_Product_UploadDataController.ProductWrapper>();
            Integer i = Integer.valueOf((Math.random() * 100));
            // Case 1 - All Values Not Null
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 2 - ProductModel is empty for different Product
            listOfRecords.add(createRecord(null, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 3 - TechnologyStandard is empty for different Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 4 - HardwarePlatform is empty for different Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues),'', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 5 - PrimNo is empty for different Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 6 - GA is empty for different Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 7 - EOM is empty for different Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             i = Integer.valueOf((Math.random() * 100));
            // Case 8 - EOS is empty for different Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            i = Integer.valueOf((Math.random() * 100));
            // Case 9 - All values empty for different Product
            listOfRecords.add(createRecord(null, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', '', '', '', '', ''));
            
            i = Integer.valueOf((Math.random() * 100));
            // Case 10 - ProductModel is empty for same Product
            listOfRecords.add(createRecord(null, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 11 - TechnologyStandard is empty for same Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 12 - HardwarePlatform is empty for same Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues),'', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 13 - PrimNo is empty for same Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 14 - GA is empty for same Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            
            // Case 15 - EOM is empty for same Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             
            // Case 16 - EOS is empty for same Product
            listOfRecords.add(createRecord(null, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            
            // Case 17 - All values empty for same Product
            listOfRecords.add(createRecord(null, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', '', '', '', '', ''));
            
            return listOfRecords;
        }
        
        public List<OC_Product_UploadDataController.ProductWrapper> generateRecordsWithAllPosibilitiesNullRelease(){
            List<OC_Product_UploadDataController.ProductWrapper> listOfRecords = new List<OC_Product_UploadDataController.ProductWrapper>();
            Integer i = Integer.valueOf((Math.random() * 100));
            // Case 1 - All Values Not Null
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 2 - ProductModel is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 3 - TechnologyStandard is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, '', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 4 - HardwarePlatform is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues),'', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 5 - PrimNo is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 6 - GA is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 7 - EOM is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             i = Integer.valueOf((Math.random() * 100));
            // Case 8 - EOS is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            i = Integer.valueOf((Math.random() * 100));
            // Case 9 - All values empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', '', 'Test-Prod-Version-000'+i, '', '', '', '', '', ''));
            
            i = Integer.valueOf((Math.random() * 100));
            // Case 10 - ProductModel is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 11 - TechnologyStandard is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, '', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 12 - HardwarePlatform is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues),'', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 13 - PrimNo is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 14 - GA is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            
            // Case 15 - EOM is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             
            // Case 16 - EOS is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            
            // Case 17 - All values empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', '', 'Test-Prod-Version-000'+i, '', '', '', '', '', ''));
            
            return listOfRecords;
        }
        
        public List<OC_Product_UploadDataController.ProductWrapper> generateRecordsWithAllPosibilitiesNullVersion(){
            List<OC_Product_UploadDataController.ProductWrapper> listOfRecords = new List<OC_Product_UploadDataController.ProductWrapper>();
            Integer i = Integer.valueOf((Math.random() * 100));
            // Case 1 - All Values Not Null
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 2 - ProductModel is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 3 - TechnologyStandard is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', '', generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 4 - HardwarePlatform is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues),'', ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 5 - PrimNo is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 6 - GA is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 7 - EOM is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             i = Integer.valueOf((Math.random() * 100));
            // Case 8 - EOS is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            i = Integer.valueOf((Math.random() * 100));
            // Case 9 - All values empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, '', '', '', '', '', '', ''));
            
            i = Integer.valueOf((Math.random() * 100));
            // Case 10 - ProductModel is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 11 - TechnologyStandard is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', '', generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 12 - HardwarePlatform is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues),'', ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 13 - PrimNo is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 14 - GA is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            
            // Case 15 - EOM is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             
            // Case 16 - EOS is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), ''+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            
            // Case 17 - All values empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, '', '', '', '', '', '', ''));
            
            return listOfRecords;
        }
        
        public List<OC_Product_UploadDataController.ProductWrapper> generateRecordsWithAllNegativeTestCases(){
            List<OC_Product_UploadDataController.ProductWrapper> listOfRecords = new List<OC_Product_UploadDataController.ProductWrapper>();
            Integer i = Integer.valueOf((Math.random() * 100));
            // Case 1 - Product Name is NULL 
            listOfRecords.add(createRecord('', 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 2 - Release Name is NULL 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 3 - Version Name is NULL 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 4 - Invalid GA date Format 
            //listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '12/12/2012', generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 5 - Invalid EOM date Format 
            //listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '12/12/2012', generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 6 - Invalid EOS date Format 
            //listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), '12/12/2012'));
            i = Integer.valueOf((Math.random() * 100));
            // Case 7 - Invalid Hardware 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), 'InvalidHW', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 8 - Invalid Technology Standard 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, 'InvalidTS', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Above Same cases for Same values
            // Case 1 - Product Name is NULL 
            listOfRecords.add(createRecord('', 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
  
            // Case 2 - Release Name is NULL 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, '', 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 3 - Version Name is NULL 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, '', generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 4 - Invalid GA date Format 
            //listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '12/12/2012', generateRandomDate(), generateRandomDate()));
            
            // Case 5 - Invalid EOM date Format 
            //listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '12/12/2012', generateRandomDate()));
            
            // Case 6 - Invalid EOS date Format 
            //listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), '12/12/2012'));
            
            // Case 7 - Invalid Hardware 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), 'InvalidHW', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 8 - Invalid Technology Standard 
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, 'InvalidTS', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));

            return listOfRecords;
        }
        
        public List<OC_Product_UploadDataController.ProductWrapper> generateRecordsWithAllPositiveTestCases(){
            List<OC_Product_UploadDataController.ProductWrapper> listOfRecords = new List<OC_Product_UploadDataController.ProductWrapper>();
            Integer i = Integer.valueOf((Math.random() * 100));
            // Case 1 - All Values Not Null
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 2 - ProductModel is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 3 - TechnologyStandard is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 4 - HardwarePlatform is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues),'', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 5 - PrimNo is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 6 - GA is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            i = Integer.valueOf((Math.random() * 100));
            // Case 7 - EOM is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             i = Integer.valueOf((Math.random() * 100));
            // Case 8 - EOS is empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            i = Integer.valueOf((Math.random() * 100));
            // Case 9 - All values empty for different Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', '', '', '', '', ''));
            
            i = Integer.valueOf((Math.random() * 100));
            // Case 10 - ProductModel is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 11 - TechnologyStandard is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 12 - HardwarePlatform is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues),'', 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 13 - PrimNo is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), '', generateRandomDate(), generateRandomDate(), generateRandomDate()));
            
            // Case 14 - GA is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, '', generateRandomDate(), generateRandomDate()));
            
            // Case 15 - EOM is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), '', generateRandomDate()));
             
            // Case 16 - EOS is empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, 'Test Service Model' + i, 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, generateRandomPicklists(technologyStandardPicklistValues), generateRandomPicklists(hardwarePlatformPicklistValues), 'Test-Prod-Version-000'+i+'-PrimNo-000'+i, generateRandomDate(), generateRandomDate(), ''));
            
            // Case 17 - All values empty for same Product
            listOfRecords.add(createRecord('Test-Product-000'+i, '', 'Test-Prod-Release-000'+i, 'Test-Prod-Version-000'+i, '', '', '', '', '', ''));
            
            return listOfRecords;
        }
        
        public OC_Product_UploadDataController.ProductWrapper createRecord(String Name, String ProductModel, String ProductRelease, String ProductVersion, String TechnologyStandard, String HardwarePlatform, String PrimNo, String GA, String EOM, String EOS){
            // Constructor Coverage
            OC_Product_UploadDataController.ProductWrapper pw = new OC_Product_UploadDataController.ProductWrapper();
            return new OC_Product_UploadDataController.ProductWrapper(Name, ProductModel, ProductRelease, ProductVersion, TechnologyStandard, HardwarePlatform, PrimNo, GA, EOM, EOS);
        }
        
        public String generateRandomDate(){
            Integer rangeSize = Date.parse('1900-01-01').daysBetween(Date.parse('2030-12-31')) + 1;
            Decimal daysToAdd = rangeSize * math.Random();
            Date result = Date.parse('1900-01-01').addDays(daysToAdd.intValue());
            return result.year() + '-' + result.month() + '-' + result.day();
        }
        
        public String generateRandomPicklists(List<String> listOfPicklistValues){
            Double randomNumber = Math.random(); 
            Integer arrayLength = listOfPicklistValues.size(); 
            Integer randomIndex = (randomNumber *(arrayLength-1)).intValue();
            return listOfPicklistValues[randomIndex];
        }
    }

}