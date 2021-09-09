@isTest
public class OC_TR_SCH_TREmailRemindersTest {
    
    @testsetup 
    static void setup(){
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        List<OC_TR_TimeRecord__c> timeRecList = new List<OC_TR_TimeRecord__c>();
        
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.OC_TR_EmployeeNumber__c = '12366630'; 
        testuser.OC_TR_EmployeeCompanyCode__c = '5470';
        insert testuser;
        System.runAs(testuser){
            OC_TR_TimeRecord__c timeRecord1 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today(),
                                                                       RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                       OC_TR_TimeSpent__c = '1' ,
                                                                       OC_TR_Active__c = true,
                                                                       OC_TR_Status__c = 'Not Submitted',
                                                                       OC_TR_LegalForm__c ='07');
            timeRecList.add(timeRecord1);
            insert timeRecord1;
        }
    }    
     
    Static testmethod  Void sendReminderEmailTest1(){
        List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                               isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '12366630'
                               ORDER BY createddate LIMIT 1 ];
        
        System.runAs(userList[0]){
            List<OC_TR_TimeRecord__c> timeRecordRecList = [ SELECT id,OC_TR_PostingDate__c,OwnerId,OC_TR_Status__c,OC_TR_LegalForm__c
                                                           FROM OC_TR_TimeRecord__c LIMIT 1 ];
            Test.startTest();
            OC_TR_HelperUtil.SetCustomerCompCode(timeRecordRecList);
            if(timeRecordRecList != null && timeRecordRecList.size() >=1){
                timeRecordRecList[0].OC_TR_LegalForm__c = '11';
            	update timeRecordRecList[0];
            }
            OC_TR_SCH_TimeReportingEmailReminders batchScheduler = new OC_TR_SCH_TimeReportingEmailReminders ();
            batchScheduler.execute(null);
            Test.stopTest();
        }
        
    }    
    
    
}