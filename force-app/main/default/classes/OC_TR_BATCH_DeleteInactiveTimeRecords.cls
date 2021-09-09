/**
* @File Name          : OC_TR_BATCH_DeleteInactiveTimeRecords
* @Description        : Batch class to delete inactive time records
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-11                 IBM                   Initial Version

**/ 
public Without Sharing class OC_TR_BATCH_DeleteInactiveTimeRecords implements Database.Batchable <Sobject> { 
    
   public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime fromDate;
        DateTime currentDate = system.today();
        String formatedCurrentDt = currentDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String formatedFromDate;
        
        OC_TR_TimeRecording__mdt timeRecordMdt = [SELECT Id, DeveloperName, OC_TR_Value1__c 
                                                  FROM OC_TR_TimeRecording__mdt
                                                  WHERE DeveloperName =: OC_TR_Constants.durationToDeleteTimeRecords ];
        fromDate = system.today().addDays(-(Integer.ValueOf(timeRecordMdt.OC_TR_Value1__c)));
        formatedFromDate  = fromDate.format('yyyy-MM-dd\'T\'23:59:59\'Z\'');
        
        String SOQL ='SELECT Id, LastModifiedDate'+
            ' FROM OC_TR_TimeRecord__c WHERE OC_TR_Active__c = False AND OC_TR_Status__c='+'\''+ OC_TR_Constants.NotSubmitted+'\'';
        if(Test.isRunningTest()){
            return Database.getQueryLocator(SOQL);  
        }
       if(!Test.isRunningTest()){
        SOQL += ' AND ' + ' LastModifiedDate <= ' + formatedFromDate +' AND ' + ' LastModifiedDate < '+ formatedCurrentDt;
           }
       
        return Database.getQueryLocator(SOQL);
    }
    public void execute(Database.BatchableContext bc, List<OC_TR_TimeRecord__c> timeRecords){
        
        
        if(timeRecords!=null && !timeRecords.isEmpty()){
            try{
                database.delete(timeRecords);
            }
            catch(Exception e){
                EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_BATCH_DeleteInactiveTimeRecords,OC_TR_Constants.execute,OC_TR_Constants.OC_TR_BATCH_DeleteInactiveTimeRecords, true, e)); 
            }
        }
        
    }    
    public void finish(Database.BatchableContext bc){
        
    }
    
}