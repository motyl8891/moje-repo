/**
* @File Name          : OC_TR_ScheduleClassToDeleteInactiveTR
* @Description        : Scheduler class to schedule OC_TR_BATCH_DeleteInactiveTimeRecords Batch
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-11                 IBM                   Initial Version

**/ 
public Without Sharing class OC_TR_ScheduleClassToDeleteInactiveTR implements Schedulable {  
    
    public void execute (SchedulableContext sc){ 
        
        OC_TR_BATCH_DeleteInactiveTimeRecords deleteInactiveTR = new OC_TR_BATCH_DeleteInactiveTimeRecords();
        
        Database.executeBatch(deleteInactiveTR,500); 
    }
    
}