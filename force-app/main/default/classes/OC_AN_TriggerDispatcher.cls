/**
* @File Name          : OC_AN_TriggerDispatcher 
* @Description        : Generic Disptacher class for Alerts and Notifications.

* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10                 IBM               Initial Version
**/

public class OC_AN_TriggerDispatcher {
    
     public static void Run(OC_AN_TriggerInterface handler)
    {
       
      // Before trigger logic
        if (Trigger.IsBefore )
        {
           /* if (Trigger.IsInsert)
                handler.BeforeInsert(trigger.new);
 
            if (Trigger.IsUpdate)
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap); */
 
            if (Trigger.IsDelete)
                handler.BeforeDelete(trigger.oldMap,trigger.old);
        }
         
        // After trigger logic
        if (Trigger.IsAfter)
        {
            /* if (Trigger.IsInsert)
                handler.AfterInsert(Trigger.newMap);
 
            if (Trigger.IsUpdate) 
                handler.AfterUpdate(trigger.newMap, trigger.oldMap);*/
 
            if (trigger.IsDelete)
                handler.AfterDelete(trigger.oldMap);
 
            /*if (trigger.isUndelete)
                handler.AfterUndelete(trigger.oldMap); */
        }
    }
}