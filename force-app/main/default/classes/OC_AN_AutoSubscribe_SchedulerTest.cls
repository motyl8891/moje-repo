@isTest
public with sharing class OC_AN_AutoSubscribe_SchedulerTest{
    static testMethod void batchTest() {
    Test.StartTest();
    OC_AN_AutoSubscribeViaAsset_Scheduler sh1 = new OC_AN_AutoSubscribeViaAsset_Scheduler();
    String sch = '0 0 * * * ?'; 
    system.schedule('Test subscription Check', sch, sh1); 
    Test.stopTest(); 
    }
}