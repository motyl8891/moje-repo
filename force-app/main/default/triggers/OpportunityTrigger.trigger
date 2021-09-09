trigger OpportunityTrigger on Opportunity(
	after insert,
	after update,
	before insert,
	before update,
	before delete,
	after delete
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'OpportunityTrigger',
		'Opportunity'
	);

	OpportunityTriggerHandler handler = new OpportunityTriggerHandler(
		Trigger.isExecuting,
		Trigger.size
	);

	if (TriggerHandler.enable) {
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
				handler.OnBeforeDelete(Trigger.old);
			}
			if (Trigger.isAfter) {
			}
		}
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'Opportunity',
		'OpportunityTrigger',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}