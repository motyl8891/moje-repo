@isTest
private class EventLogTest 
{

    @isTest private static void createErrorLogFuture(){
        try 
        {
            Integer result = 1 / 0;
        }catch(Exception ex){
            Test.startTest();

            EventLog.Error logError = new EventLog.Error('EventLog_Test', 'createErrorLog', 'createErrorLog', true, ex);
            EventLog.createLogFuture(Json.serialize(logError));

            Test.stopTest();
            List<EventLog__c> lstLogsCreated = [SELECT Id, Type__c, Method__c
                                                    FROM EventLog__c WHERE Method__c = 'createErrorLog'
                                                   ];
            System.assertEquals(1, lstLogsCreated.size());
            System.assertEquals('Error', lstLogsCreated.get(0).Type__c);
        }
    }

    @isTest private static void createErrorLog(){
        try 
        {
            Integer result = 1 / 0;
        }catch(Exception ex){
            Test.startTest();

            EventLog.Error logError = new EventLog.Error('EventLog_Test', 'createErrorLog', 'createErrorLog', true, ex);
            EventLog.createLog(logError);

            Test.stopTest();
            List<EventLog__c> lstLogsCreated = [SELECT Id, Type__c, Method__c
                                                    FROM EventLog__c WHERE Method__c = 'createErrorLog'
                                                   ];
            System.assertEquals(1, lstLogsCreated.size());
            System.assertEquals('Error', lstLogsCreated.get(0).Type__c);
        }
    }

    @isTest private static void createInformationLogFuture() {
        Test.startTest();
        EventLog.Information logInfo = new EventLog.Information('EventLog_Test', 'createInformationLog', 'createErrorLog', true, 'createInformationLog');
        EventLog.createLogFuture(Json.serialize(logInfo));
        Test.stopTest();
        List<EventLog__c> lstLogsCreated = [SELECT Id, Type__c, Method__c,Message__c
                                                FROM EventLog__c WHERE Method__c = 'createInformationLog'
                                               ];
        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('Information', lstLogsCreated.get(0).Type__c);
        System.assertEquals('createInformationLog', lstLogsCreated.get(0).Message__c);
    }

    @isTest private static void createInformationLog() {
        Test.startTest();
        EventLog.Information logInfo = new EventLog.Information('EventLog_Test', 'createInformationLog', 'createErrorLog', true, 'createInformationLog');
        EventLog.createLog(logInfo);
        Test.stopTest();
        List<EventLog__c> lstLogsCreated = [SELECT Id, Type__c, Method__c,Message__c
                                                FROM EventLog__c WHERE Method__c = 'createInformationLog'
                                               ];
        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('Information', lstLogsCreated.get(0).Type__c);
        System.assertEquals('createInformationLog', lstLogsCreated.get(0).Message__c);
    }
    
    /****************************************************************
* @date: 2021-03-18
* @return: void <br>
* @description: Test method to handle Event Log creation for List of records.
* U-2669 :Added for Archival of Staging Objects
*****************************************************************/    
    @isTest private static void createEventLogs() {
        List<String> SystemAdmin=new List<String>{OC_IB_constants.SystemAdmin};
        Id SystemAdminUserProfileId = [SELECT Id FROM Profile WHERE Name IN: SystemAdmin].Id;
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), OC_IB_constants.UserRoleDefaults, true);
        User SystemAdminUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = SystemAdminUserProfileId, UserRoleId = ocUserRole.Id, isActive = True), OC_IB_constants.UserDefaults, true);
        System.runAs(SystemAdminUser){ 
            Test.startTest();
            List<EventLog.Log>  EventLogList = new List<EventLog.Log>();
            EventLog.ErrorLogs ErrInfo = new EventLog.ErrorLogs('ArchiveStagingObjects','execute','null',false,'Database Deletion Error','a0O7Z00000XYZwABCD');     
            EventLogList.add(ErrInfo);
            EventLog.CreateEventLogs(EventLogList);
            Test.stopTest();
        }
    }
}