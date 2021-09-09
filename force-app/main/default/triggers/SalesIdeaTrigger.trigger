trigger SalesIdeaTrigger on SDOD_Lead__c (before insert, before update) {
    
    if(Trigger.isInsert ){
        if(Trigger.isBefore){
            SalesIdeaTriggerHandler.OnBeforeInsert(trigger.New);
        }
    }
	if(Trigger.isUpdate){
        if(Trigger.isBefore){
            SalesIdeaTriggerHandler.OnBeforeUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        }
    }
}