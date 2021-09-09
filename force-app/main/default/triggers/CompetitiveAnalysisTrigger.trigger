trigger CompetitiveAnalysisTrigger on CompetitiveAnalysis__c(
	after insert,
	after update,
	before insert,
	before update,
	before delete,
	after delete
) {
	CompetitiveAnalysisTriggerHandler handler = new CompetitiveAnalysisTriggerHandler();
	if (Trigger.isAfter) {
		if (Trigger.isInsert) {
			handler.onAfterInsert(Trigger.New, Trigger.OldMap);
		} else if (Trigger.isUpdate) {
			handler.onAfterUpdate(Trigger.New, Trigger.OldMap);
		} else if (Trigger.isDelete) {
			handler.onAfterDelete(Trigger.New, Trigger.OldMap);
		}
	}
}