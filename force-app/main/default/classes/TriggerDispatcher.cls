/* Class Name : TriggerDispatcher
* Description :Generic Disptacher class for triggers. 
*/ 
public with sharing class TriggerDispatcher {
     public static void Run(TriggerInterface handler)
    {
       
      // Before trigger logic
        if (Trigger.IsBefore )
        {           
            if (Trigger.IsInsert)
                handler.BeforeInsert(trigger.new);
 
            if (Trigger.IsUpdate)
                handler.BeforeUpdate(trigger.newMap, trigger.oldMap);
 
            if (Trigger.IsDelete)
                handler.BeforeDelete(trigger.oldMap);
        }
         
        // After trigger logic
        if (Trigger.IsAfter)
        {        
            
            if (Trigger.IsInsert)
                handler.AfterInsert(Trigger.newMap); 
          
            if (Trigger.IsUpdate)
                handler.AfterUpdate(trigger.newMap, trigger.oldMap);  
               
            if (trigger.IsDelete)
                handler.AfterDelete(trigger.oldMap);
 
            if (trigger.isUndelete)
                handler.AfterUndelete(trigger.oldMap);
        }
    }

}