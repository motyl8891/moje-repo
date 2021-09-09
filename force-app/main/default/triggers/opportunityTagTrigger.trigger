/*******************************************************************
 * @author: Gopi Krishna
 * @date: 2019-01-22
 * @description: This trigger used to call Handler class based on Events
 ********************************************************************/
trigger opportunityTagTrigger on Opportunity_Tags__c(
	after insert,
	after update,
	after delete
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'opportunityTagTrigger ',
		'Opportunity_Tags__c '
	);
	OpportunityTagTriggerHandler handler = new OpportunityTagTriggerHandler(
		Trigger.isExecuting,
		Trigger.size
	);

	if (Trigger.isInsert) {
		handler.onAfterInsert(Trigger.new);
	} else if (Trigger.isUpdate) {
		handler.onAfterUpdate(
			Trigger.new,
			Trigger.old,
			Trigger.newMap,
			Trigger.oldMap
		);
	} else if (Trigger.isDelete) {
		handler.onAfterDelete(
			Trigger.new,
			Trigger.old,
			Trigger.newMap,
			Trigger.oldMap
		);
	}
	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'Opportunity_Tags__c ',
		'opportunityTagTrigger ',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}