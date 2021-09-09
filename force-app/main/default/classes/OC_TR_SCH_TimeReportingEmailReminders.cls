/**
* @File Name          : OC_TR_SCH_TimeReportingEmailReminders
* @Description        : Scheduler class to schedule OC_TR_SendRemindersToGenerateTimeRecords Batch
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-11                 IBM                   Initial Version

**/ 
public class OC_TR_SCH_TimeReportingEmailReminders implements Schedulable {

    public void execute (SchedulableContext sc){ 
        
       Database.executeBatch(new OC_TR_SendRemindersToGenerateTimeRecords(),500); 
        
    }
    
}