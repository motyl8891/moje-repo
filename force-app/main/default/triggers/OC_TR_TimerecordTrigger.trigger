trigger OC_TR_TimerecordTrigger on OC_TR_TimeRecord__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    
    TriggerSettings__c triggerSettingsCs = TriggerSettings__c.getOrgDefaults();
    if(!triggerSettingsCs.OC_TR_TimeRecordTriggerDisabled__c){
       OC_TR_TriggerDispatcher.Run(new OC_TR_TimeRecordTriggerHandler());
    }
     
}