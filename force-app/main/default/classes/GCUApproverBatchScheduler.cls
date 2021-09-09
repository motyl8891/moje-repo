/******************************************************************* 
* @author: Linda Kalasnikova
* @date: 2018-08-07
* @description: This class is a Scheduler class for GCUApproverBatch class and will be invoked only manually through dev console to schedule the batch jobs
********************************************************************/
public class GCUApproverBatchScheduler{ 

    /****************************************************************
    * @author: Linda Kalasnikova
    * @date: 2018-08-07
    * @param: 
    * @return: void
    * @description: This method is scheduled method and contains jobs to schedule
    *****************************************************************/
    public static String scheduleBatches(String sch1, String batchName){
        GCUApproverBatch c1 = new GCUApproverBatch();
        return System.schedule(batchName, sch1, c1);
    }
}