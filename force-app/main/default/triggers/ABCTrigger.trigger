trigger ABCTrigger on AntiBriberyCorruption__c (after update, before update,after insert, before insert) {
    if(Trigger.isUpdate){
        if(Trigger.isAfter) {
            new ABCTriggerHandler().onAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
        if(Trigger.isBefore) {
            new ABCTriggerHandler().onBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    }
    if(Trigger.isInsert){
        if(Trigger.isAfter) {
            new ABCTriggerHandler().onAfterInsert(trigger.New ,Trigger.NewMap,Trigger.OldMap);
        }
        if(Trigger.isBefore) {
            new ABCTriggerHandler().onBeforeInsert(trigger.New ,Trigger.NewMap,Trigger.OldMap);
        }
    }
}