trigger SDOD_Lead_Trigger on SDOD_Lead__c(
	before insert,
	before update,
	after insert,
	after update
) {
	TriggerSettings__c mc = TriggerSettings__c.getInstance();
	if (Trigger.isbefore) {
		if (Trigger.isInsert) {
			SDODLeadTriggerHandler.AssigntoQueue(Trigger.new);
		}
	}
	if (Trigger.isAfter) {
		if (AvoidRecussion.isFirstRun()) {
			if (Trigger.isUpdate) {
				SDODLeadTriggerHandler.contributionValidtaion(Trigger.new);
			}
		}
		TriggerSettings__c mc = TriggerSettings__c.getInstance();
		if (!mc.SDODTriggerDisabled__c) {
			if (Trigger.isInsert) {
				SDODLeadTriggerHandler.AddAdditionalRecorder(Trigger.new);
			}
		}
	}
}