/**
 * @File Name          : OC_AN_ExtAutomationExecScheduler
 * @Description        : Controller class for scheduling the external job after time delay
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2109
 * @Created Date       : 20 Aug 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-08-20                 IBM                   Initial Version
 **/

global class OC_AN_ExtAutomationExecScheduler implements Schedulable {
    private static final String SCHEDULED_JOB_NAME_PRESET = OC_AN_Constants.JOB_NAME_EXTERNAL_DELAY;
	public List<Id> pABIdsList;
    public OC_AN_ExtAutomationExecScheduler(List<Id> exertnalPABIdsList) {
        this.pABIdsList = exertnalPABIdsList;
		if(!String.isBlank(exertnalPABIdsList[0])) System.schedule(SCHEDULED_JOB_NAME_PRESET + 'BAPExternalAutomation' + exertnalPABIdsList[0], OC_AN_ExternalAutomationScheduler.getCronString(0,20), this);
    }
    global void execute(SchedulableContext sc) {
		try{
			deleteSchedule(SCHEDULED_JOB_NAME_PRESET + 'BAPExternalAutomation' + pABIdsList[0]);
            OC_AN_BulletinServices.sendEmailViaJourney(pABIdsList);
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_AutomationScheduler, OC_AN_Constants.execute, null, false, e));
		}
	}

    public void deleteSchedule(String JobName){
		for (CronTrigger job : [SELECT Id
		                        FROM CronTrigger
		                        WHERE CronJobDetail.Name = :(JobName)]){
			System.abortJob(job.Id);
		}
	}
}