trigger CampaignMemberTrigger on CampaignMember(before insert,after insert) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'CampaignMemberTrigger ',
		'CampaignMember '
	);

	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			CampaignMemberTriggerHandler.OnBeforeInsert(Trigger.New);
		}
        if (Trigger.isAfter) {
            system.debug('**********************5555***************^^^^^^^^^^^^');
			CampaignMemberTriggerHandler.OnAfterInsert(Trigger.New);
            system.debug('************************6666*************^^^^^^^^^^^^');
		}
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'CampaignMember ',
		'CampaignMemberTrigger ',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}