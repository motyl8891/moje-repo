/**
* @File Name          : OC_AN_ProductSelectionControllerTest
* @Description        : Test Class for
*						OC_AN_ProductSelectionController
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10              	IBM               Initial Version
* 1.1        2021-06-11              	IBM               Improvement on Product Selection
**/


@IsTest
public class OC_AN_ProductSelectionControllerTest{
    
    @testsetup 
    static void setup(){
        Id migrationProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationProfileId;
        testuser.IsActive = true;  
        insert testuser;
        OC_AN_Bulletin_Template__c bTemplate = new OC_AN_Bulletin_Template__c(
            OC_AN_Delay_In_Hours__c = 5
            , OC_AN_Internal_Text__c = 'Internal Text'
            , OC_AN_Template__c = 'Template'
            , OC_AN_Type__c = 'Emergency Problem'
        ); 
        OC_AN_Bulletin__c bulletinRec = new OC_AN_Bulletin__c(
            Name = 'Test Bulletin' 
        );

        Product2 productRec = (Product2) OC_TestDataGenerator.createSObject(new Product2(
             OC_MD_Product_type__c = OC_AN_Constants.PRODUCT_TYPE
             , Product_Code_Number__c = 'P001'
             , Name = 'Test0001'
        ));

        Product2 productRec1 = (Product2) OC_TestDataGenerator.createSObject(new Product2(
             OC_MD_Product_type__c = OC_AN_Constants.PRODUCT_TYPE
             , Product_Code_Number__c = 'P002'
             , Name = 'Test0002'
        ));
        OC_MD_ProductAttributes__c releaseRecord = new OC_MD_ProductAttributes__c(
            RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release
            , Name = 'Release 1'
        );
        OC_MD_ProductAttributes__c releaseRecord1 = new OC_MD_ProductAttributes__c(
            RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release
            , Name = 'Release 2'
        );

        OC_MD_ProductAttributes__c versionRecord = new OC_MD_ProductAttributes__c(
            RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Version, 
            Name = 'Version 1'
        );

        OC_AN_Bulletin_Account_Product__c bap = new OC_AN_Bulletin_Account_Product__c(
                OC_AN_Bulletin__c =bulletinRec.Id);
           

        System.runAs(testUser){ 
            insert bTemplate;
            bulletinRec.OC_AN_Bulletin_Template__c = bTemplate.Id;      
            insert bulletinRec;
            insert productRec;
            insert productRec1;
            bap.OC_AN_Product__c = productRec1.Id;            
            releaseRecord1.OC_MD_Product__c = productRec1.Id;
            insert releaseRecord1;
            bap.OC_AN_Release__c = releaseRecord1.Id;
            insert bap;
            releaseRecord.OC_MD_Product__c = productRec.Id;
            insert releaseRecord;
            versionRecord.OC_MD_Parent__c = releaseRecord.Id;
            insert versionRecord;
        }
    }
    
    @isTest
    static void testmethod1(){
        Test.startTest();
        OC_AN_ProductSelectionController.ProductSelectionWrapper wrapper= new OC_AN_ProductSelectionController.ProductSelectionWrapper();
        wrapper.isCompleted = false;
        wrapper.offsetCount = 0;
        OC_AN_ProductSelectionController.getProducts(wrapper);
         wrapper.offsetCount = 1;
        OC_AN_ProductSelectionController.getProducts(wrapper);
        wrapper.offsetCount = 2;
        OC_AN_ProductSelectionController.getProducts(wrapper);
        wrapper.offsetCount = 4;
        OC_AN_ProductSelectionController.getProducts(wrapper);
        wrapper.offsetCount = 400;
        OC_AN_ProductSelectionController.getProducts(wrapper);
        OC_AN_Bulletin__c bulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c WHERE Id != null LIMIT 1];
        OC_MD_ProductAttributes__c versionRecord = [SELECT Id,Name, OC_MD_Parent__c, OC_MD_Parent__r.OC_MD_Product__c
         FROM OC_MD_ProductAttributes__c WHERE RecordTypeId =:OC_AN_Constants.recTypeId_PrdAttribute_Version  Order By Name  LIMIT 1];
         OC_MD_ProductAttributes__c releaseRecord = [SELECT Id,Name, OC_MD_Product__c
         FROM OC_MD_ProductAttributes__c WHERE RecordTypeId =:OC_AN_Constants.recTypeId_PrdAttribute_Release  Order By Name  LIMIT 1];
        Product2 productrec = [SELECT Id,Name From Product2 Order By Name ASC LIMIT 1];

        String inputJson = '{"selected":{}, "deselected":{}}';
        OC_AN_ProductSelectionController.saveProductSelection(inputJson,bulletinRecord.Id);
        inputJson = '{"selected":{"'+versionRecord.Id
        +'":{"Id":"'+versionRecord.Id
        +'", "OC_MD_Parent__r":{ "OC_MD_Product__c":"'+productrec.Id+'", "Id":"'+releaseRecord.Id
        +'" },  "OC_MD_Parent__c":"'+releaseRecord.Id+'", "Name":"'+versionRecord.Name
        +'", "selectedState":"checked" } }, "deselected":{ } }';
        System.assertEquals(OC_AN_ProductSelectionController.saveProductSelection(inputJson,bulletinRecord.Id), 'success');
        System.assertEquals(OC_AN_ProductSelectionController.saveProductSelection(inputJson,bulletinRecord.Id), 'success');
        inputJson = '{"selected":{"'+releaseRecord.Id
        +'":{"Id":"'+releaseRecord.Id
        +'","OC_MD_Product":"'+productrec.Id+'", "Name":"'+releaseRecord.Name
        +'", "selectedState":"checked" } }, "deselected":{ } }';
        System.assertEquals(OC_AN_ProductSelectionController.saveProductSelection(inputJson,bulletinRecord.Id), 'success');
        
         inputJson = '{"selected":{"'+productrec.Id
        +'":{"Id":"'+productrec.Id
        +'","Name":"'+productrec.Name
        +'", "selectedState":"checked" } }, "deselected":{ } }';
        System.assertEquals(OC_AN_ProductSelectionController.saveProductSelection(inputJson,bulletinRecord.Id), 'success');
        
        OC_AN_ProductSelectionController.getCurrentBulletinProducts(bulletinRecord.Id);
        Test.stopTest();
    }
    
}