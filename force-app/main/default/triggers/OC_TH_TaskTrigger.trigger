trigger OC_TH_TaskTrigger on Task (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    TriggerSettings__c taskTriggerCs = TriggerSettings__c.getOrgDefaults();
    if(!taskTriggerCs.OC_TaskTriggerDisabled__c){
        TriggerDispatcher.Run(new OC_TH_TaskTriggerHandler());
    }
      
}