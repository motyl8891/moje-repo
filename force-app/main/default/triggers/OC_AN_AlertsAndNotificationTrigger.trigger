trigger OC_AN_AlertsAndNotificationTrigger on OC_AN_Bulletin_Account_Product__c (before delete, after delete, after update) {

    TriggerSettings__c triggerSettingsCs = TriggerSettings__c.getOrgDefaults();
    if(!triggerSettingsCs.OC_AN_AlertsNotificationTriggerDisabled__c){
       TriggerDispatcher.Run(new OC_AN_AAndNTriggerHandler());
    }
    
    
}