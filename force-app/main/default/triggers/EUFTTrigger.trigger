trigger EUFTTrigger on EUFT__c (after update, after insert, after delete, before insert) {
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            EUFTTriggerHandler.onAfterUpdate(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        }
    }
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            EUFTTriggerHandler.onAfterInsert(trigger.New, trigger.Old, Trigger.NewMap, Trigger.OldMap);
        }
        else if(Trigger.isBefore){
            EUFTTriggerHandler.onBeforeInsert(trigger.New);
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isAfter){
            EUFTTriggerHandler.onAfterDelete(trigger.Old);
        }
    }
}