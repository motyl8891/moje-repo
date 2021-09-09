/**
* @File Name          : OC_AN_UserPreferencesTriggerHandler
* @Description        : Trigger handler for user preferences
*                       U-2758 Alerts & Notification: Creation of User Prefrences.
* @Author             : IBM
* @Group              : 
* @Created Date       : 11th June 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-11             	IBM               Initial Version
*/
trigger OC_AN_UserPreferencesTrigger on OC_AN_User_Preferences__c (before insert) {
    if (Trigger.isInsert){
        if(Trigger.isBefore){
              new OC_AN_UserPreferencesTriggerHandler().onBeforeInsert(trigger.New);
        }
    }
  
}