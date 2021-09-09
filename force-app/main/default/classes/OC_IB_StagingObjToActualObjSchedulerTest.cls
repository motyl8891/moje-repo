/**
* @File Name          : OC_IB_StagingObjToActualObjSchedulerTest
* @Description        : Test Class for
*						OC_IB_StagingObjToActualObjScheduler (Direct)
*						OC_IB_BATCH_StagedDataProcessor (Direct)
*						OC_IB_StagedObjToActualObjMappingHandler (Direct)
*						OC_IB_Utility (Direct)
*						OC_IB_Constants (Direct)
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 10th September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.1        2021-02-15                 IBM                   Updated Version
**/
@istest
public class OC_IB_StagingObjToActualObjSchedulerTest {
    static testmethod void scedulerMethod(){
        OC_TestDataGenerator.insertCustomSettingsData();
        Test.startTest();
        OC_IB_StagingObjToActualObjScheduler batchScheduler=New OC_IB_StagingObjToActualObjScheduler();
        batchScheduler.execute(null);
        Test.stopTest();
    } 
    
    static testmethod void scedulerMethodforinstalledbaseItems(){
        OC_TestDataGenerator.insertCustomSettingsData();
        Test.startTest();
        OC_IB_InstalledBastItemsBatchScheduler IBitemsSch=new OC_IB_InstalledBastItemsBatchScheduler();
        IBitemsSch.execute(null);
        Test.stopTest();
        
    }
    
}