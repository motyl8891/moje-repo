/****************************************************************
 * @author: Manu Singhal
 * @date: 11-10-2019
 * @description: This is a trigger for Account object.(U-0913)
 *****************************************************************/
trigger AccountTrigger on Account(after update,after insert,before update,before insert) {
    DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
        'AccountTrigger',
        'Account'
    );

    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            AccountTriggerHandler.OnAfterUpdate(
                Trigger.New,
                Trigger.Old,
                Trigger.NewMap,
                Trigger.OldMap
            );
        }
       
    } if(Trigger.isInsert){
        if(Trigger.isAfter){
        AccountTriggerHandler.onAfterInsert(Trigger.New)   ; 
        }
    }
    DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
        'Account',
        'AccountTrigger',
        DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
    );

}