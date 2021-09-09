/**
 * @File Name          : OC_AN_ExternalAutomationScheduler
 * @Description        : Scheduler class which will trigger external flow classes after specified time of delay.
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
global with sharing class OC_AN_ExternalAutomationScheduler implements Schedulable{
	private Map<String, String> emailContentAndAccessToken;
	private static final String SCHEDULED_JOB_NAME_PRESET = OC_AN_Constants.JOB_NAME_EXTERNAL_DELAY;
	public OC_AN_ExternalAutomationScheduler(Map<String, String> argumentsMap){
		this.emailContentAndAccessToken = argumentsMap;
		scheduleInSeconds(this, this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));
	}

	global void execute(SchedulableContext sc){
		try{
			deleteSchedule(this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));

			OC_AN_HandleExtCalloutBulletin.mcRestCallouts(this.emailContentAndAccessToken.get(OC_AN_HandleExtCalloutBulletin.BULLETIN_ID));
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_AutomationScheduler, OC_AN_Constants.execute, null, false, e));
		}
	}

	/**
	 * deleteSchedule will delete the scheduled bulletin name.
	 *
	 * ## scheduledClassName (String): scheduledClassName
	 */
	public void deleteSchedule(String bulletinName){
		for (CronTrigger job : [SELECT Id
		                        FROM CronTrigger
		                        WHERE CronJobDetail.Name = :(SCHEDULED_JOB_NAME_PRESET + bulletinName)]){
			System.abortJob(job.Id);
		}
	}

	public void scheduleInSeconds(Schedulable scheduledObject, String bulletinId){
		OC_AN_Bulletin__c bullitenDelay = [Select id, OC_AN_Delay__c
		                                   from OC_AN_Bulletin__c
		                                   where Id = :this.emailContentAndAccessToken.get(OC_AN_HandleExtCalloutBulletin.BULLETIN_ID)];
        if(bullitenDelay.OC_AN_Delay__c != null && bullitenDelay.OC_AN_Delay__c < 0.4){
            bullitenDelay.OC_AN_Delay__c = 0.4;
        }
        
		if (bullitenDelay.OC_AN_Delay__c != null){
			Decimal delayInhours = bullitenDelay.OC_AN_Delay__c;

			Integer t = (Integer)(60 * delayInhours * 60);

			Integer hour = t / 3600;
			t = Math.mod(t, 3600);

			Integer min = t / 60;
			t = Math.mod(t, 60);

			String cronString = getCronString(hour, min);
			System.schedule(SCHEDULED_JOB_NAME_PRESET + bulletinId, cronString, scheduledObject);
		}
	}

	@TestVisible
	public static String getCronString(Integer hour, Integer minutes){
		datetime currentTime = System.now(); 
		currentTime = currentTime.addHours(hour); 
		currentTime = currentTime.addMinutes(minutes); 
		
		String day = string.valueOf(currentTime.day());
		String month = string.valueOf(currentTime.month());
		String hours = string.valueOf(currentTime.hour());
		String minute = string.valueOf(currentTime.minute());
		String year = string.valueOf(currentTime.year());
		String strSchedule = '0 ' + minute + ' ' + hours + ' ' + day + ' ' + month + ' ?' + ' ' + year;		
		return strSchedule;
	}
}