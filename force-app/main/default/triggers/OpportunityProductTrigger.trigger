trigger OpportunityProductTrigger on OpportunityLineItem(
	after insert,
	after update,
	before insert,
	before update,
	before delete,
	after delete
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'OpportunityProductTrigger ',
		'OpportunityLineItem '
	);
	OpportunityProductTriggerHandler handler = new OpportunityProductTriggerHandler(
		Trigger.isExecuting,
		Trigger.size
	);

	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			handler.OnBeforeInsert(Trigger.New);
		} else {
			handler.OnAfterInsert(Trigger.New);
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
	} else if (Trigger.isDelete) {
		if (Trigger.isBefore) {
			handler.OnBeforeDelete(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		} else {
			handler.OnAfterDelete(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'OpportunityLineItem ',
		'OpportunityProductTrigger ',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}