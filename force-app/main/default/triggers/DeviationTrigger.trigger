trigger DeviationTrigger on Deviation__c(after insert,after Update)     
{
if (Trigger.isAfter) {
    if (Trigger.isInsert){
			DeviationTriggerHandler.onAfterInsert(Trigger.New,Trigger.OldMap);
		}
	}
	//update operation
	if (Trigger.isUpdate){
			DeviationTriggerHandler.onAfterUpdate(Trigger.New,Trigger.OldMap);
		}
	}