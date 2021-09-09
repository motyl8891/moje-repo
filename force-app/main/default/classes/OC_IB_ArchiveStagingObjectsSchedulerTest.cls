/**
* @File Name          : OC_IB_ArchiveStagingObjectsSchedulerTest
* @Description        : Test Class for Scheduler class OC_IB_ArchiveStagingObjectsScheduler
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2105, U-2669
* @Created Date       : 13th March 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-03-13                 IBM                   Initial Version
* 1.1		 2021-04-19					IBM					  Calling 'ArchiveSobjectSchedulermethod' in scheduler class
**/
@istest
public class OC_IB_ArchiveStagingObjectsSchedulerTest
{
    @testSetup static void setup() {
        OC_TestDataGenerator.insertCustomSettingsData();
    }
    public static testMethod void testschedule()
    {
        List<String> SystemAdmin=new List<String>{OC_IB_constants.SystemAdmin};
        Id SystemAdminUserProfileId = [SELECT Id FROM Profile WHERE Name IN:SystemAdmin].Id;
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), OC_IB_constants.UserRoleDefaults, true);
        User SystemAdminUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = SystemAdminUserProfileId, UserRoleId = ocUserRole.Id, isActive = True), OC_IB_constants.UserDefaults, true);
        System.runAs(SystemAdminUser){ 
            Test.StartTest();
            OC_IB_ArchiveStagingObjectsScheduler schedobj=new OC_IB_ArchiveStagingObjectsScheduler();
        	schedobj.execute(null);
            OC_IB_ArchiveStagingObjectsScheduler.ArchiveSobjectSchedulermethod();
            Test.stopTest();   
        }
    }
}