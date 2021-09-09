trigger S2WRecordSharingTrigger on Strategy2Win__c (after insert,after update) {
	if(Trigger.isInsert ){
        if(Trigger.isAfter){
            S2WRecordSharingHandler.onAfterInsert(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        }
    }
	if(Trigger.isUpdate){
        if(Trigger.isAfter){
            S2WRecordSharingHandler.onAfterUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        }
    }
}