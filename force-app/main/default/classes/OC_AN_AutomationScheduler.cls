/**
 * @File Name          : OC_AN_AutomationScheduler
 * @Description        : Generic class to shcedule automation activity for internal and external
 *                          distribution in MC.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/
global with sharing class OC_AN_AutomationScheduler implements Schedulable{
	@TestVisible
	private String SCHEDULED_JOB_NAME_PRESET;
	private Map<String, String> emailContentAndAccessToken;
	private String flowType;
	public OC_AN_AutomationScheduler(Map<String, String> argumentMap, String flowType, String jobName){
		this.emailContentAndAccessToken = argumentMap;
		this.flowType = flowType;
		this.SCHEDULED_JOB_NAME_PRESET = jobName;
		OC_AN_AlertsAndNotification__mdt timeDealyForSchduler = OC_AN_AlertsAndNotification__mdt.getInstance('OC_AN_DelayTimeForSchedulerJob');
		if (timeDealyForSchduler.OC_AN_Value1__c != null){
			scheduleInSeconds(this, Integer.valueOf(timeDealyForSchduler.OC_AN_Value1__c), this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));
		}
	}

	global void execute(SchedulableContext SC){
		try{
			deleteSchedule(this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));

			if (this.flowType == OC_AN_Constants.FLOWTYPE_INTERNAL){
				OC_AN_HandleCalloutWhenBulletinApproved.startAutomationAndRunJourney(this.emailContentAndAccessToken);
				OC_AN_HandleCalloutWhenBulletinApproved.updateBulletin(this.emailContentAndAccessToken);
			} else if (this.flowType == OC_AN_Constants.FLOWTYPE_EXTERNAL){
				OC_AN_HandleExtCalloutBulletin.startAutomationAndRunJourney(this.emailContentAndAccessToken);
			}
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_AutomationScheduler, OC_AN_Constants.execute, null, false, e));
		}
	}

	/**
	 * schedule will schedule the object to exeute once time only after the elapsed seconds. This method
	 * can be called several times since it will delete the object in question before schedule it again.
	 *
	 * Note: The name needs to be different or the call will delete a scheduled object that was supposed to execute.
	 *
	 * ## scheduledObject (Schedulable): scheduledObject The object that will be executed, needs to implelent Scheduble, aka have a execure mehtod.
	 * ## seconds (Integer): seconds Number of seconds to wait before execution
	 * ## scheduledClassName (String): scheduledClassName The class name to scheudle.
	 */
	public void scheduleInSeconds(Schedulable scheduledObject, Integer seconds, String bulletinId){
		deleteSchedule(bulletinId);
		String cronString = getCronString(seconds);
		System.schedule(this.SCHEDULED_JOB_NAME_PRESET + bulletinId, cronString, scheduledObject);
	}

	/**
	 * Will do a delete of the scheduled object and then add it, note that the name needs to be uniqe.
	 * Cron schedule look like Seconds Minutes Hours Day_of_month Month Day_of_week
	 *
	 * @param scheduledObject Scheduled object
	 * @param cronSchedule  Seconds Minutes Hours Day_of_month Month Day_of_week
	 * @param scheduledClassName Class name
	 */
	@TestVisible
	private void schedule(Schedulable scheduledObject, String cronSchedule, String scheduledClassName){
		deleteSchedule(scheduledClassName);
		System.schedule(this.SCHEDULED_JOB_NAME_PRESET + scheduledClassName, cronSchedule, scheduledObject);
	}

	/**
	 * deleteSchedule will delete the scheduled bulletin name.
	 *
	 * ## scheduledClassName (String): scheduledClassName
	 */
	public void deleteSchedule(String bulletinName){
		for (CronTrigger job : [SELECT Id
		                        FROM CronTrigger
		                        WHERE CronJobDetail.Name = :(this.SCHEDULED_JOB_NAME_PRESET + bulletinName)]){
			System.abortJob(job.Id);
		}
	}

	@TestVisible
	private static String getCronString(Integer seconds){
		Datetime nextRunTime = Datetime.now().addSeconds(seconds);
		String cronString = nextRunTime.second()+' ' + nextRunTime.minute()+' ' + nextRunTime.hour()+' ' + nextRunTime.day()+' ' + nextRunTime.month()+' ? ' + nextRunTime.year();
		return cronString;
	}
}