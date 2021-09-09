trigger EarlyStartTrigger on EarlyStart__c (before insert,after insert, after update,before update) {
    if( Trigger.isInsert ){
        if(Trigger.isBefore){
            EarlyStartHandler.onBeforeInsert(trigger.New);
        }else {
            EarlyStartHandler.onAfterInsert(trigger.New,Trigger.NewMap, Trigger.OldMap);
        }
    }
    if(Trigger.isUpdate){
        if(Trigger.isBefore){
          EarlyStartHandler.onBeforeUpdate(trigger.New, trigger.OldMap);
        }
        if(Trigger.isAfter){
            EarlyStartHandler.onAfterUpdate(trigger.NewMap, trigger.oldMap);
        }
    }
}