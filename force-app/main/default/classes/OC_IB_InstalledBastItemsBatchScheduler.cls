/* Class Name : OC_IB_InstalledBastItemsBatchScheduler
* Description : Scheduler class for running the batch class "OC_IB_BatchProcessInstalledBaseItems
                to create installed base items records from staging object to actual object.
*/
public class OC_IB_InstalledBastItemsBatchScheduler implements schedulable {
 public void execute(SchedulableContext sc) {   
        Database.executebatch(new OC_IB_BatchProcessInstalledBaseItems(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi),1000);
    }
}