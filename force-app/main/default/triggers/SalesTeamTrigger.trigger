trigger SalesTeamTrigger on Opportunity_Sales_Team__c(
	before insert,
	after insert,
	before update,
	after update,
    after delete
) {
	SalesTeamTriggerHandler Handler = new SalesTeamTriggerHandler();
	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			Handler.onBeforeInsert(Trigger.New);
		} else {
			Handler.onAfterInsert(Trigger.New);
		}
	}
	if (Trigger.isUpdate) {
		if (Trigger.isBefore) {
			Handler.onBeforeUpdate(Trigger.New, Trigger.oldMap);
		} else {
			Handler.onAfterUpdate(Trigger.New, Trigger.oldMap);
		}
	}
    if (Trigger.isDelete) {
		if (Trigger.isAfter) {
			Handler.onAfterDelete(Trigger.old);
		} 
	}
}