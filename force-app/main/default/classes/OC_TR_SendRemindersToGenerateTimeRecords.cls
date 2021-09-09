/**
* @File Name          : OC_TR_SendRemindersToGenerateTimeRecords
* @Description        : Batch class to send reminders to users for Time Record Generation
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-11                 IBM                   Initial Version

**/ 
public Without Sharing class OC_TR_SendRemindersToGenerateTimeRecords implements Database.Batchable <Sobject> {
    
    public Database.Querylocator start(Database.BatchableContext bc) {
        String soqlQuery = 'SELECT Id,Name,isActive,Email FROM User';
        if(!Test.isRunningTest()){
        soqlQuery = soqlQuery + ' WHERE profile.name ='+  '\''+ OC_TR_Constants.profile_ServiceUser + '\''+
                    ' AND isActive= True ';
        } else{
            soqlQuery = soqlQuery + ' WHERE OC_TR_EmployeeNumber__c = '+'\''+12366630+'\''+ ' LIMIT 1';
        }          
        
         return database.getQueryLocator(soqlQuery);    
    }
    public Void execute(Database.BatchableContext bc, List<User> serviceUserList) {
        OC_TR_TimeRecording__mdt timeRecordMdt = [SELECT Id, DeveloperName, OC_TR_Value1__c 
                                                      FROM OC_TR_TimeRecording__mdt
                                                      WHERE DeveloperName =: OC_TR_Constants.OC_TR_EmailReminder_From_EmailAddress ]; 
       OC_TR_HelperUtil.SendEmailToUsers(OC_TR_HelperUtil.CheckIfTimeRecordsAreCreatedByEngineers(serviceUserList),OC_TR_Constants.emailTemp_GenerateTimeRecords,timeRecordMdt.OC_TR_Value1__c);
       
    }
    public void finish(Database.BatchableContext bc) { 
        
    }
}