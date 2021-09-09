@isTest
public class OC_TR_QueueQuickActionControllerTest {
@testsetup
    public static void setup(){
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name =: OC_TR_Constants.profile_ServiceUser].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.OC_TR_EmployeeNumber__c = '1236663'; 
        testuser.OC_TR_EmployeeCompanyCode__c = '547';
        testuser.UserRoleId = [Select Name, DeveloperName,  Id From UserRole WHERE Id != null LIMIT 1].Id; //Added for U-2886:Start
        insert testuser;
     
        //Added for U-2886:Start
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<Group> listOfPublicGroup = new List<Group>();
        Group publicGroupToInsert = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert.Name = 'A&N - Test Group';
        	publicGroupToInsert.Type = 'Queue';
            listOfPublicGroup.add(publicGroupToInsert);
        
            Group publicGroupToInsert2 = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert2.Name = 'A&N - Test Group2';
            listOfPublicGroup.add(publicGroupToInsert2);
            
        	if(!listOfPublicGroup.isEmpty()){
                insert listOfPublicGroup;
            } 
        
            GroupMember groupMemberToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            groupMemberToInsert.GroupId = listOfPublicGroup[0].Id;
            groupMemberToInsert.UserOrGroupId = testuser.Id;
            groupMemberListToInsert.add(groupMemberToInsert);
            
            GroupMember internalGroupToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            internalGroupToInsert.GroupId = listOfPublicGroup[0].Id;
            internalGroupToInsert.UserOrGroupId = publicGroupToInsert2.Id;
            groupMemberListToInsert.add(internalGroupToInsert);
            
            if(!groupMemberListToInsert.isEmpty()){
                insert groupMemberListToInsert;
            }
        //U-2886:End
        System.runAs(testuser){
             OC_TR_TimeRecord__c timeRecord = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today(),
                                                                  RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                  OC_TR_TimeSpent__c = '14',
                                                                  OC_TR_Active__c = true,
                                                                  OC_TR_ActivityName__c = 'Forum',
                                                                  OC_TR_Status__c = 'Not Submitted'); //Added Activity name field for U-2886
            insert timeRecord;
            //Added for U-2886:Start
            OC_TR_TimeRecord__c timeRecord1 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = Date.today(),
                                                                  RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                  OC_TR_TimeSpent__c = '14',
                                                                  OC_TR_Active__c = true,
                                                                  OC_TR_ActivityName__c = 'Chat',
                                                                  OC_TR_Status__c = 'Not Submitted');
            insert timeRecord1;
            //U-2886:End            
            
        }
        
    }
     @isTest
    static void queueQuickActionControllerTest1(){
         List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                               isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '1236663'
                               ORDER BY createddate LIMIT 1 ];
      
        Test.startTest();
        try{
            System.runAs(userList[0]){
                List<OC_TR_TimeRecord__c> timeRecList = [SELECT id,OC_TR_PostingDate__c,OC_TR_TimeSpent__c,OC_TR_ActivityName__c,
                                                           OC_TR_Active__c,OC_TR_Status__c FROM OC_TR_TimeRecord__c]; //Added Activity name field for U-2886
                List<Id> timeRecordId = new List<Id>();
                for(OC_TR_TimeRecord__c trId:timeRecList){
                   timeRecordId.add(trId.Id);
                }
                OC_TR_QueueQuickActionController.fetchQueuerecords(timeRecordId,userList[0].Id,null);
                
                OC_TR_QueueQuickActionController.fetchQueuerecords(null,userList[0].Id,null);
                OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(timeRecList[0].Id,'AMX1_CNS','AMX1_CNS',null);
                 //Added for U-2886:Start
                OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(null,'AMX1_CNS','AMX1_CNS',timeRecList); 
                OC_TR_QueueQuickActionController.fetchQueuerecords(null,userList[0].Id,userList[0].UserRoleId);
                 //U-2886:End
            }
       
            }
        catch(Exception e){
        }
        Test.stopTest();
    } 
     @isTest
    static void queueQuickActionControllerTest2(){
         List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                               isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '1236663'
                               ORDER BY createddate LIMIT 1 ];
      
        Test.startTest();
        try{
            System.runAs(userList[0]){
                  List<OC_TR_TimeRecord__c> timeRecList = [SELECT id,OC_TR_PostingDate__c,OC_TR_TimeSpent__c,
                                                           OC_TR_Active__c,OC_TR_Status__c FROM OC_TR_TimeRecord__c 
                                                           LIMIT 1]; 
                OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(null,'IBMO','IBMO',timeRecList);
                OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(null,'IBMO1','IBMO',timeRecList);
                
            }
       
            }
        catch(Exception e){
        }
        Test.stopTest();
    } 
    @isTest
    static void queueQuickActionControllerTest3(){
         List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                               isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '1236663'
                               ORDER BY createddate LIMIT 1 ];
      
        Test.startTest();
        try{
            System.runAs(userList[0]){
                  List<OC_TR_TimeRecord__c> timeRecList = [SELECT id,OC_TR_PostingDate__c,OC_TR_TimeSpent__c,
                                                           OC_TR_Active__c,OC_TR_Status__c FROM OC_TR_TimeRecord__c 
                                                           LIMIT 1]; 
                OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(timeRecList[0].Id,'AMX1_CNS123','AMX1_CNS123',null);
                //OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(null,'IBMO1',timeRecList);
                
            }
       
            }
        catch(Exception e){
        }
        Test.stopTest();
    } 
    @isTest
    static void queueQuickActionControllerTest4(){
         List<User> userList = [SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c,
                               isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '1236663'
                               ORDER BY createddate LIMIT 1 ];
      
        Test.startTest();
        try{
            System.runAs(userList[0]){
                  List<OC_TR_TimeRecord__c> timeRecList = [SELECT id,OC_TR_PostingDate__c,OC_TR_TimeSpent__c,
                                                           OC_TR_Active__c,OC_TR_Status__c FROM OC_TR_TimeRecord__c 
                                                           LIMIT 1]; 
                OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(null,'Test','Test',timeRecList);
                
            }
       
            }
        catch(Exception e){
        }
        Test.stopTest();
    } 
    
    
    @isTest
    public static void checkUtilityClass(){
        Test.startTest();
        OC_TR_Utility.generateSOQL('OC_TR_TimeRecordActivity__mdt', null);
        OC_TR_Utility.generateSOQL('OC_TR_TimeRecordActivity__mdt', new List<String> {'Id', 'Name'});
        OC_TR_Utility.convertUserTimeZoneDateToGMT(Date.today(), UserInfo.getTimeZone());
        OC_TR_HelperUtil.SendEmailToUsers(
            OC_TR_HelperUtil.CheckIfTimeRecordsAreCreatedByEngineers([SELECT Id,Name,isActive,Email FROM User  WHERE profile.name =: OC_TR_Constants.profile_ServiceUser AND isActive= True])
            ,OC_TR_Constants.emailTemp_GenerateTimeRecords
            , 'ericsson@test.com');
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void checkConstants(){
        Test.startTest();
        OC_TR_Constants.testConstants();
        Test.stopTest();
    }
}