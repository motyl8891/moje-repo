@isTest
public class OC_TR_DeleteInactiveTimeRecordsTest {
    
    public static List<OC_TR_TimeRecord__c> timeRecordList = new List<OC_TR_TimeRecord__c> ();
    public static Date currentDate = system.today();
    public static List<Account> accList = new List<Account> ();
    public static List<Account> updateaccList = new List<Account> ();
    public static List<Contact> conList = new List<Contact> ();
    public static List<ServiceContract> servContractList = new List<ServiceContract> ();
    //public static List<Assignment_ID__c> assignmentIdList = new List<Assignment_ID__c>();
    
    @testsetup
     public static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.OC_TR_EmployeeNumber__c = '1236663'; 
        testuser.OC_TR_EmployeeCompanyCode__c = '547';
        insert testuser;
        
        System.runAs(testuser){
            
            /*assignmentIdList = TestDataGenerator.createSObjectList(new Assignment_ID__c(),2);
            
            for(Integer i=0 ; i<2 ;i++){
                assignmentIdList[i].Current_Date__c = Date.today();
                assignmentIdList[i].Start_Date__c = Date.today();
                assignmentIdList[i].End_Date__c     = Date.today() +10;
            }
            insert assignmentIdList;*/
            Id serviceAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
            Id salesAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
            
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            accSales.RecordTypeId = salesAccRtId;
            accSales.Account_Type__c = 'Sales';
            insert accSales;
            accList = TestDataGenerator.createSObjectList(new Account(),3);
            
            accList[0].Account_Type__c = 'Service';
            
            accList[1].Account_Type__c = 'Service';
            accList[2].Account_Type__c = 'Service';
            accList[2].RecordTypeId = serviceAccRtId;
            accList[2].MDM_Customer_Id__c = '5678123456';
            
            insert accList;
            accList[0].ParentId = accSales.Id;
            accList[1].ParentId = accSales.Id;
            update  accList;
            system.assertEquals(accList.size(), 3);
            
            conList = TestDataGenerator.createSObjectList(new Contact(),2);
            if(accList!=null && !accList.isEmpty() && conList!=null && !conList.isEmpty() ){
                conList[0].AccountId = accList[0].Id;
                conList[1].AccountId = accList[1].Id;
                conList[1].OwnerId = testuser.Id;
                insert conList;
                system.assertEquals(conList.size(), 2);
            }
            for(integer i=0;i<2;i++){
                serviceContract contract = (serviceContract)TestDataGenerator.createSObject(new serviceContract());
                contract.Name = contract.Name+i;
                contract.AccountId = accList[i].id;
                //contract.P_Code__c = '456'+i;
                contract.OC_MD_Assignment_ID__c = '123';
                servContractList.add(contract);
            }
            insert servContractList;
            system.assertEquals(servContractList.size(), 2);
            
        }   
    }
    
     @isTest
    static void inActiveTimeRecordDeletionTest(){
      
         List<User> userList = [ SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,
                                OC_TR_EmployeeCompanyCode__c,isActive
                                FROM User WHERE OC_TR_EmployeeNumber__c = '1236663'
                                ORDER BY createddate LIMIT 1 ];
         system.runAs(userList[0]){
        
        List<Account> accountRecList = [ SELECT id,ownerId,Account_Type__c, Name,ParentId,Visible__c 
                                         FROM Account 
                                         WHERE ParentId != null ];
        
        //List<Assignment_ID__c> assignmentIdList = [ SELECT id FROM Assignment_ID__c ];
        
        List<ServiceContract> servContractRecList = [ SELECT id,Name,ownerId,Account.Name,
                                                      OC_MD_Assignment_ID__c,
                                                      Account.Parent.MDM_Customer_Id__c  FROM ServiceContract 
                                                      WHERE Name Like '%Test%' ];
        OC_TR_TimeRecord__c timeRecord1 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                   RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                   OC_TR_TimeSpent__c = '14', 
                                                                   OC_TR_Active__c = false,
                                                                   OC_TR_ServiceToAccount__c = accountRecList[0].id,
                                                                   OC_TR_ObjectIdCon__c = servContractRecList[0].id , 
                                                                   OC_TR_Status__c = 'Not Submitted');
        
        OC_TR_TimeRecord__c timeRecord2 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                   RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                   OC_TR_TimeSpent__c = '1',
                                                                   OC_TR_Active__c = false,
                                                                   OC_TR_ServiceToAccount__c = accountRecList[0].id,
                                                                   OC_TR_ObjectIdCon__c = servContractRecList[0].id , 
                                                                   OC_TR_Status__c = 'Not Submitted');
        OC_TR_TimeRecord__c timeRecord3 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                   RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                   OC_TR_TimeSpent__c = '1',
                                                                   OC_TR_Active__c = false,
                                                                   OC_TR_Status__c = 'Not Submitted');
        OC_TR_TimeRecord__c timeRecord4 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                   RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                   OC_TR_TimeSpent__c = '1',
                                                                   OC_TR_Active__c = false,
                                                                   OC_TR_Status__c = 'Not Submitted');
        insert timeRecord4;
        
        OC_TR_TimeRecord__c timeRecord5 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                   RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                   OC_TR_TimeSpent__c = '1',
                                                                   OC_TR_Active__c = true,
                                                                  // OwnerId = '0051X000003tZVqQAM',
                                                                   OC_TR_Status__c = 'Not Submitted');
        insert timeRecord5;
        
        
        timeRecordList.add(timeRecord1);
        timeRecordList.add(timeRecord2);
        timeRecordList.add(timeRecord3);
        
        Test.startTest();
        //system.runAs(userList[0]){
            insert timeRecordList;
            OC_TR_ScheduleClassToDeleteInactiveTR batchScheduler = new OC_TR_ScheduleClassToDeleteInactiveTR();
            batchScheduler.execute(null);
            OC_TR_DeleteTimeRecordController.updateTimeRecordAsInactive(timeRecord4.Id,true);
            OC_TR_DeleteTimeRecordController.updateTimeRecordAsInactive(timeRecord5.Id,true);
            OC_TR_DeleteTimeRecordController.updateTimeRecordAsInactive(timeRecord5.Id,false);
             
        } 
        Test.stopTest();
         
        
    }
         
    @isTest(SeeAllData = false)
    public static void checkConstants(){
        Test.startTest();
        OC_TR_Constants.testConstants();
        Test.stopTest();
    }
}