/* Class Name : OC_AN_BulletinTrigger
* Description : Bulletin trigger executes the logic written in OC_AN_BulletinTriggerHandler class.
* Author      : IBM.
*/
trigger OC_AN_BulletinTrigger on OC_AN_Bulletin__c (before insert,after insert) {
    
    TriggerSettings__c triggerSettingsCs = TriggerSettings__c.getOrgDefaults();
    if(!triggerSettingsCs.OC_AN_AlertsNotificationTriggerDisabled__c){
       TriggerDispatcher.Run(new OC_AN_BulletinTriggerHandler());
    }

}