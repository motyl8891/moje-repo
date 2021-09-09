/**
* @File Name          : OC_UtilityTest
* @Description        : Test Class for
*						OC_Utility
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2105
* @Created Date       : 6th April 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-06                 IBM                   Initial Version
**/

@isTest
public class OC_UtilityTest {
    
    /*U-2669 Archival of Staging Object Changes - begin*/
    @testsetup 
    static void setup(){
        List<String> SystemAdmin=new List<String>{OC_IB_constants.SystemAdmin};
        Id SystemAdminUserProfileId = [SELECT Id FROM Profile WHERE Name IN: SystemAdmin].Id;
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), OC_IB_constants.UserRoleDefaults, true);
        User SystemAdminUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = SystemAdminUserProfileId, UserRoleId = ocUserRole.Id, isActive = True), OC_IB_constants.UserDefaults, true);
        System.runAs(SystemAdminUser){ 
            List<OC_IB_IntegrationSobjectRecords__c> IntegSobjInsList = new List<OC_IB_IntegrationSobjectRecords__c>();
            List<OC_IB_IntegrationSobjectRecords__c> IntegSobjUpdList = new List<OC_IB_IntegrationSobjectRecords__c>(); 
            DateTime LMdate = DateTime.newInstance(2001, 7, 19, 10, 7, 12);
            DateTime CRdate = DateTime.newInstance(2001, 7, 19, 10, 7, 12);
            for ( Integer val = 0; val < 3; val++ ) {           
                OC_IB_IntegrationSobjectRecords__c sobj = new OC_IB_IntegrationSobjectRecords__c();
                sobj.Name = 'StgObjectTesting'+ String.valueOf(val);
                sobj.LastModifiedDate = LMdate;
                sobj.CreatedDate = CRdate;
                sobj.OC_IB_ActualObjectSyncStatus__c = OC_IB_Constants.syncSuccessStatus;  
                IntegSobjInsList.add( sobj );            
            }  
           	OC_Utility.DMLhandler(IntegSobjInsList,OC_IB_Constants.classArchiveStagingObjects,OC_IB_Constants.methodExecute,OC_IB_Constants.insertOps); 
            IntegSobjUpdList.add(IntegSobjInsList[2]);
            OC_Utility.DMLhandler(IntegSobjUpdList,OC_IB_Constants.classArchiveStagingObjects,OC_IB_Constants.methodExecute,OC_IB_Constants.updateOps);            
            System.assert(IntegSobjInsList!= null);
            system.assertEquals(IntegSobjInsList[0].Name,'StgObjectTesting0');
            system.assertEquals(IntegSobjInsList[1].Name,'StgObjectTesting1');
            system.assertEquals(IntegSobjUpdList[0].Name,'StgObjectTesting2');
        }
    }
    	static testmethod void DMLhandlerTestmethod(){
        List<String> syncStatusType=new List<String>{OC_IB_constants.syncSuccessStatus};
        List<OC_IB_IntegrationSobjectRecords__c> SobjectList = [SELECT id, name,LastModifiedDate,CreatedDate,OC_IB_ActualObjectSyncStatus__c from OC_IB_IntegrationSobjectRecords__c where OC_IB_ActualObjectSyncStatus__c IN:syncStatusType and Name like 'StgObjectTesting%'];
        Test.startTest();
		OC_Utility.DMLhandler(SobjectList,OC_IB_Constants.classArchiveStagingObjects,OC_IB_Constants.methodExecute,OC_IB_Constants.deleteOps);
        OC_Utility.DMLhandler(SobjectList,OC_IB_Constants.classArchiveStagingObjects,OC_IB_Constants.methodExecute,OC_IB_Constants.insertOps);
        OC_Utility.DMLhandler(SobjectList,OC_IB_Constants.classArchiveStagingObjects,OC_IB_Constants.methodExecute,OC_IB_Constants.updateOps);
        Test.stopTest();
    }
    /*U-2669 Archival of Staging Object Changes - ends*/
	static testMethod void getObjectPicklistValuestest(){
        
        test.startTest();
        OC_Utility.getObjectPicklistValues('OC_TH_Service_Milestone__c','OC_TH_Priority__c','toUpperCase');
        OC_Utility.getObjectPicklistValues('OC_TH_Service_Milestone__c','OC_TH_Priority__c','toLowerCase');
        OC_Utility.getObjectPicklistValues('OC_TH_Service_Milestone__c','OC_TH_Priority__c','');
        OC_Utility.getObjectPicklistValuesReverse('OC_TH_Service_Milestone__c','OC_TH_Priority__c');
        
        test.stopTest();      

    }
}