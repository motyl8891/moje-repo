trigger SecondaryApprovalTrigger on Secondary_Approval__c (after insert, before insert, after update, before update) {

SecondaryApprovalTriggerHandler handler = new SecondaryApprovalTriggerHandler();

	if (TriggerHandler.enable)
	{
		if( Trigger.isInsert ){
			if(Trigger.isBefore){
				handler.onBeforeInsert(trigger.New);
			}
            else{
                handler.onAfterInsert(trigger.New);
            }
		}
		else if ( Trigger.isUpdate ){
			if(Trigger.isBefore){
				handler.onBeforeUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
			}
            else{
                handler.onAfterUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
            }
		}
	}
}