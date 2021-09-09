/**
* @File Name          : OC_IB_UpdateExistingAssetsTest
* @Description        : Test class for the Batch Class OC_IB_BatchToUpdateExistingAsset to update the existing assets one time as part of new design change for Ibase integration framework
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2103
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-02-15                 IBM                   Initial Version
**/
@isTest
public class OC_IB_UpdateExistingAssetsTest {
    @testsetup
    static void setup(){
        Id integrationprofileId = [Select Id FROM Profile WHERE Name='Integration User profile'].Id;
        List<User> testUserList = new List<User> ();
        User testUser = (User)OC_TestDataGenerator.createSObject(new User());
        
        testUser.UserName = 'ericsson@test.com';
        testUser.Email='integrationuser@invalid.com';
        testUser.ProfileId = integrationprofileId;
        insert testUser;
        system.assertEquals(testUser.UserName,'ericsson@test.com');
        System.runAs(testUser){ 
           OC_TestDataGenerator.insertIntegrationRecords();
         }
    }
    
    //to cover OC_IB_BatchToUpdateExistingAsset 
    static testMethod void testBatchToUpdateExistingAsset() {
        Test.startTest();
        OC_IB_BatchToUpdateExistingAsset batchInboundProcessor = new OC_IB_BatchToUpdateExistingAsset();
        Database.executeBatch(batchInboundProcessor);
        Test.stopTest();
    }
    //to cover OC_IB_UpdateExistingAssetsScheduler
    static testmethod void scedulerMethodforUpdateExistingAsset(){
        Test.startTest();
        OC_IB_UpdateExistingAssetsScheduler assetsSch=new OC_IB_UpdateExistingAssetsScheduler();
        assetsSch.execute(null);
        Test.stopTest();
        
    }
}