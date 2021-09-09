/**
* @File Name          : OC_GST_TRG_FeedItem
* @Description        : Trigger to pick Forum Posts take appropriate actions on them
* @Author             : Richa Gupta
* @Group              : OmniChannel - Service
* @Created Date       : 1st May 2020
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-17              Richa Gupta               Initial Version
* 2.0        2020-11-25             IBM                       D-3426/ U-1706 Forum On/Off
**/

trigger OC_GST_TRG_FeedItem on FeedItem(before insert, before update, before delete) {
    
    TriggerSettings__c FeedItemTriggerCustomSetting = TriggerSettings__c.getOrgDefaults();
    if(!FeedItemTriggerCustomSetting.OC_FeedItemTriggerDisabled__c){
        TriggerDispatcher.Run(new OC_GST_FeedItemTriggerHandler());
    }
}