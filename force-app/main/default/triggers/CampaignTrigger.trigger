trigger CampaignTrigger on Campaign(after insert) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'CampaignTrigger',
		'Campaign'
	);
	if (Trigger.isInsert) {
		if (Trigger.isAfter) {
			CampaignTriggerHandler.OnAfterInsert(Trigger.New);
		}
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'Campaign',
		'CampaignTrigger',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);
}