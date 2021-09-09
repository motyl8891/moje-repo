/******************************************************************* 
* @author: Anukriti Agrawal
* @date: 2019-16-07
* @description: This class is a Scheduler class for CRGAndGCUApproverBatch class and will be invoked only manually through dev console to schedule the batch jobs
********************************************************************/
public class CRGAndGCUApproverBatchScheduler {
/****************************************************************
    * @author: Anukriti Agrawal
    * @date: 2019-16-07
    * @param: 
    * @return: void
    * @description: This method is scheduled method and contains jobs to schedule
    *****************************************************************/
    public static String scheduleBatches(String sch1, String batchName){
        CRGAndGCUApproverBatch c1 = new CRGAndGCUApproverBatch();
        return System.schedule(batchName, sch1, c1);
    }
}