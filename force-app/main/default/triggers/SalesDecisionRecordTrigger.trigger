trigger SalesDecisionRecordTrigger on Sales_Decision_Record__c(
	before update,
	after insert,
	before insert,
	after update
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'SalesDecisionRecordTrigger ',
		'Sales_Decision_Record__c  '
	);

	if (Trigger.isInsert) {
		if (Trigger.isAfter) {
			SalesDecisionRecordTriggerHandler.OnAfterInsert(Trigger.New);
		} else {
			SalesDecisionRecordTriggerHandler.OnBeforeInsert(Trigger.New);
		}
	}
	if (Trigger.isUpdate) {
		if (Trigger.isBefore) {
			SalesDecisionRecordTriggerHandler.OnBeforeUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		} else {
			SalesDecisionRecordTriggerHandler.OnAfterUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'Sales_Decision_Record__c',
		'SalesDecisionRecordTrigger',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}