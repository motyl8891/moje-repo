global class OC_AN_ExternalAutomationExecutionScheduler implements Schedulable {
    private static final String SCHEDULED_JOB_NAME_PRESET = OC_AN_Constants.JOB_NAME_EXTERNAL_DELAY;
	public List<Id> pABIdsList;
    public OC_AN_ExternalAutomationExecutionScheduler(List<Id> exertnalABIdsList) {
        // this.emailContentAndAccessToken = argumentsMap;
		// scheduleInSeconds(this, this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));
    }

    global void execute(SchedulableContext sc){
		try{
			// deleteSchedule(this.emailContentAndAccessToken.get(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID));
            OC_AN_BulletinServices.sendEmailViaJourney(pABIdsList);
			// OC_AN_HandleExtCalloutBulletin.mcRestCallouts(this.emailContentAndAccessToken.get(OC_AN_HandleExtCalloutBulletin.BULLETIN_ID));
		} catch (Exception e){
			EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_AutomationScheduler, OC_AN_Constants.execute, null, false, e));
		}
	}
}
