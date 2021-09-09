/**
 * @File Name          : OC_AN_InternalAutomationScheduler
 * @Description        : Scheduler class which will trigger automation in MC after specified time of delay.
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

global with sharing class OC_AN_InternalAutomationScheduler implements Schedulable {
    
    @TestVisible
    private static final String SCHEDULED_JOB_NAME_PRESET = 'OC_AN_';

    private Map<String, String> emailContentAndAccessToken;	


    public OC_AN_InternalAutomationScheduler(Map<String, String> argumentMap) {
        this.emailContentAndAccessToken = argumentMap;
        scheduleInSeconds(this, 20*60, this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));
    }

    
    global void execute(SchedulableContext SC) {
        try{
            deleteSchedule(this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));
            OC_AN_HandleCalloutWhenBulletinApproved.updateBulletin(this.emailContentAndAccessToken);
            OC_AN_HandleCalloutWhenBulletinApproved.startAutomationAndRunJourney(this.emailContentAndAccessToken);
        }catch(Exception e){
            System.debug('Exception in excute scheduled class for Bulletin ('+this.emailContentAndAccessToken+') exceptioin'+e);
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
    public static void scheduleInSeconds(Schedulable scheduledObject, Integer seconds, String bulletinId) {
        deleteSchedule(bulletinId);
        String cronString = getCronString(seconds);
        System.schedule(SCHEDULED_JOB_NAME_PRESET + bulletinId, cronString, scheduledObject);
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
    private static void schedule(Schedulable scheduledObject, String cronSchedule, String scheduledClassName) {
        deleteSchedule(scheduledClassName);
        System.schedule(SCHEDULED_JOB_NAME_PRESET + scheduledClassName, cronSchedule, scheduledObject);
    }

    /**
     * deleteSchedule will delete the scheduled bulletin name.
     *
     * ## scheduledClassName (String): scheduledClassName
     */
    public static void deleteSchedule(String bulletinName) {
        for (CronTrigger job : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :(SCHEDULED_JOB_NAME_PRESET + bulletinName)]) {
            System.abortJob(job.Id);
        }
    }

    @TestVisible
    private static String getCronString(Integer seconds) {
        Datetime nextRunTime = Datetime.now().addSeconds(seconds);
        String cronString = nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' +
                nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' +
                nextRunTime.month() + ' ? ' + nextRunTime.year();
        return cronString;
    }

}