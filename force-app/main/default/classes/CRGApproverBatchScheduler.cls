/******************************************************************* 
* @author: Nils Blums
* @date: 2018-08-22
* @description: This class is a Scheduler class for CRGApproverBatch class
********************************************************************/
public class CRGApproverBatchScheduler
{
    /****************************************************************
    * @author: Nils Blums
    * @date: 2018-08-22
    * @param: 
    * @return: void
    * @description: This method is scheduled method and contains jobs to schedule
    *****************************************************************/
    public static String scheduleBatches(String sch1, String batchName)
	{
		CRGApproverBatch c1 = new CRGApproverBatch();
		return System.schedule(batchName, sch1, c1);
	}
}