trigger TagTrigger on Tags__c(after update) {
	if (Trigger.isUpdate) {
		if (Trigger.isAfter) {
			TagTriggerHandler.OnAfterUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
	}
}