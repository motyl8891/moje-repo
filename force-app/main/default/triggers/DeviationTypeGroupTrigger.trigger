trigger DeviationTypeGroupTrigger on DeviationTypeGroup__c(
	after update,
	before update,
    after insert
) {
	if (Trigger.isAfter && Trigger.isUpdate) {
		new DeviationTypeGroupHandler()
			.onAfterUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
	}
	if (Trigger.isBefore && Trigger.isUpdate) {
		new DeviationTypeGroupHandler()
			.onBeforeUpdate(Trigger.New, Trigger.Old, Trigger.NewMap, Trigger.OldMap);
	}
   if (Trigger.isAfter && Trigger.isInsert) {
		new DeviationTypeGroupHandler()
			.onAfterInsert(Trigger.New); 
	}
}