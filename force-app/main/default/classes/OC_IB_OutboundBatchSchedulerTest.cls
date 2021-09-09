/**
* @File Name          : OC_IB_OutboundBatchSchedulerTest
* @Description        : Test class for OC_PRD_OutboundScheduler,OC_PRD_OutboundReqProcessor
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2107
* @Created Date       : 20th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-20                 IBM                   U-2816 Initial Version
**/
@istest 
public class OC_IB_OutboundBatchSchedulerTest {
    
    static testmethod void scedulerMethod(){
        Test.startTest();
        OC_IB_OutboundBatchScheduler batchScheduler=New OC_IB_OutboundBatchScheduler();
        batchScheduler.execute(null);
        Test.stopTest();
    } 
    
    static testmethod void ProdscedulerMethod(){
        Test.startTest();
        OC_PRD_OutboundScheduler batchProdScheduler=New OC_PRD_OutboundScheduler();
        batchProdScheduler.execute(null);
        Test.stopTest();
    } 
    
    static testmethod void futureProdProcessorMethod(){
        Test.startTest();
        OC_PRD_OutboundReqProcessor.OC_PRD_Outbound_Authentication(null);
        Test.stopTest();
    } 
}