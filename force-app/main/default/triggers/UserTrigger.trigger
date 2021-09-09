/****************************************************************
* @author: Richa Gupta
* @date: 10-09-2020
* @User Story: 1999
* @description:Trigger on User
* ****************************************************************/
trigger UserTrigger on User (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerSettings__c userTriggerCustomSettings = TriggerSettings__c.getOrgDefaults();
    if(!userTriggerCustomSettings.User_Trigger_Disabled__c){
        TriggerDispatcher.Run(new UserTriggerHandler());
    }
}