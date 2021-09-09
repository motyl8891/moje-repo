trigger CustomerUnitTrigger on CustomerUnit__c(
	after insert,
	after update,
	before insert,
	before update
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'CustomerUnitTrigger ',
		'CustomerUnit__c '
	);

	CustomerUnitTriggerHandler handler = new CustomerUnitTriggerHandler(
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
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'CustomerUnit__c ',
		'CustomerUnitTrigger ',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}