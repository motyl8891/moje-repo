/**
* @File Name          : OC_CSM_SchedulerApexTest
* @Description        : Test Class for
*						OC_IB_InstalledBastItemsBatchScheduler (Direct)
*						OC_CSM_OutboundBatchScheduler (Direct)
*						OC_CSM_StagingObjToActualObjScheduler (Direct)
*						
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2011
* @Created Date       : 10th Novemeber 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                IBM                   Initial Version
* 1.1        2021-03-26                IBM                   U-2598 Contract Improvement
**/
@istest
public class OC_CSM_SchedulerApexTest {

	static testmethod void scedulerMethodforinstalledbaseItems(){
    OC_TestDataGenerator.insertCustomSettingsData();
    Test.startTest();
    OC_IB_InstalledBastItemsBatchScheduler IBitemsSch=new OC_IB_InstalledBastItemsBatchScheduler();
    IBitemsSch.execute(null);
    Test.stopTest();

}
    static testmethod void scedulerMethodCSMOutbound(){
    Test.startTest();
    OC_CSM_OutboundBatchScheduler csmOutBatch=new OC_CSM_OutboundBatchScheduler();
    csmOutBatch.execute(null);
    Test.stopTest();

}
    static testmethod void scedulerMethodCSMStagingRoActual(){
    OC_TestDataGenerator.insertCustomSettingsData();
    Test.startTest();
    OC_CSM_StagingObjToActualObjScheduler csmStaging=new OC_CSM_StagingObjToActualObjScheduler();
    csmStaging.execute(null);
    Test.stopTest();

}
}