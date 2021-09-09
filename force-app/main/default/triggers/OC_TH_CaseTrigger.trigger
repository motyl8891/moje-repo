/* Class Name : OC_TH_CaseTrigger
* Description : Case trigger executes the logic written in OC_TH_CaseTriggerHandler class.
* Author      : IBM.
*/
trigger OC_TH_CaseTrigger on Case (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    TriggerSettings__c caseTriggerCustomSettings = TriggerSettings__c.getOrgDefaults();
    if(!caseTriggerCustomSettings.OC_CaseTriggerDisabled__c){
        TriggerDispatcher.Run(new OC_TH_CaseTriggerHandler());
    } 
}