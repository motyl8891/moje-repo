global without sharing class  OC_AN_AutoSubscribeViaAsset_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){

        OC_AN_AutoSubscribeBatchViaAsset myBatchObject = new OC_AN_AutoSubscribeBatchViaAsset();
        Id batchId = Database.executeBatch(myBatchObject);                  
    }
}