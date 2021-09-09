public class OC_AN_DeleteScheduler {
    public void deleteScgeduled(String bulletinName){
        
        for (CronJobDetail job:[SELECT Id, Name, JobType FROM CronJobDetail])  {
            System.abortJob(job.Id);
        }
        
    }}