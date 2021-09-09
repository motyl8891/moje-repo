trigger ProposalTrigger on Proposal__c(
	after insert,
	after update,
	before insert,
	before update
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'ProposalTrigger ',
		'Proposal__c '
	);

	ProposalTriggerHandler handler = new ProposalTriggerHandler(
		Trigger.isExecuting,
		Trigger.size
	);

	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			handler.OnBeforeInsert(Trigger.New);
		} else {
			handler.OnAfterInsert(Trigger.New, Trigger.NewMap, Trigger.OldMap);
		}
	} else if (Trigger.isUpdate) {
		if (Trigger.isBefore) {
			handler.OnBeforeUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		} else {
			handler.OnAfterUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'Proposal__c ',
		'ProposalTrigger ',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}