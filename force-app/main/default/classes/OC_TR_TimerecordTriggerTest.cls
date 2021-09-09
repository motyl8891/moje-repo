@isTest
public class OC_TR_TimerecordTriggerTest{
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
            Id salesAccRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Partner_Account').getRecordTypeId();
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            accSales.RecordTypeId = salesAccRtId;
            accSales.Account_Type__c = 'Sales';
            insert accSales;
            
            Account acc = (Account)OC_TestDataGenerator.createSObject(new Account());
            acc.Account_Type__c = 'Service';
            acc.ParentId = accSales.Id;
            acc.RecordTypeId = salesAccRtId;
            insert acc;
            
            accList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accList[0].Account_Type__c = 'Subdivision';
            accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('OC_MD_Service_Account').getRecordTypeId();
            accList[0].ParentID = acc.Id;
            conList = OC_TestDataGenerator.createSObjectList(new Contact(),2);
            if(accList!=null && !accList.isEmpty() && conList!=null && !accList.isEmpty() ){
                conList[0].AccountId = acc.Id;
                conList[1].AccountId = acc.Id;
				insert conList;
                system.assertEquals(conList.size(), 2);
            }
            for(integer i=0;i<2;i++){
                serviceContract contract = (serviceContract)TestDataGenerator.createSObject(new serviceContract());
                contract.Name = contract.Name+i;
                contract.AccountId = acc.id;
                //contract.P_Code__c = '456'+i;
                contract.OC_MD_Assignment_ID__c = '123';
                servContractList.add(contract);
            }
            insert servContractList;
            system.assertEquals(servContractList.size(), 2);
            /* Added for TR-Manual TH - Begin */
            serviceContract contract3 = servContractList[0].clone();
            contract3.Name = contract3.Name+'2';
            insert contract3;
            OC_TR_TimeRecord__c timeRecord1 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                       RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                       OC_TR_TimeSpent__c = '14', 
                                                                       OC_TR_ServiceToAccount__c = acc.id,
                                                                       OC_TR_ObjectIdCon__c = servContractList[0].id , 
                                                                       OC_TR_Status__c = 'Not Submitted',
                                                                       OC_TR_LegalForm__c= '08',
                                                                       OC_TR_Active__c = true
                                                                      );
            
            OC_TR_TimeRecord__c timeRecord2 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                       RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Chat').getRecordTypeId(),
                                                                       OC_TR_TimeSpent__c = '1', 
                                                                       OC_TR_ServiceToAccount__c = acc.id,
                                                                       OC_TR_ObjectIdCon__c = servContractList[0].id , 
                                                                       OC_TR_Status__c = 'Not Submitted',
                                                                       OC_TR_LegalForm__c= '11',
                                                                       OC_TR_Active__c = true);
            OC_TR_TimeRecord__c timeRecord3 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                       RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                       OC_TR_TimeSpent__c = '1', 
                                                                       OC_TR_Status__c = 'Not Submitted',
                                                                       OC_TR_LegalForm__c= '07',
                                                                       OC_TR_Active__c = true,
                                                                       OC_TR_Organization__c='Test IBMO',
                                                                       OC_TR_ZZOrgNew__c ='1234',
                                                                       OC_TR_Customer_CC__c='1234');
            OC_TR_TimeRecord__c timeRecord4 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                       RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                       OC_TR_TimeSpent__c = '1', 
                                                                       OC_TR_Status__c = 'Not Submitted',
                                                                       OC_TR_LegalForm__c= '07',
                                                                       OC_TR_Active__c = true,
                                                                       OC_TR_Organization__c='Test IBMO',
                                                                       OC_TR_ZZOrgNew__c ='1234',
                                                                       OC_TR_Customer_CC__c='1234');
            OC_TR_TimeRecord__c timeRecord5 = new OC_TR_TimeRecord__c (OC_TR_PostingDate__c = currentDate,
                                                                       RecordTypeId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get('Forum').getRecordTypeId(),
                                                                       OC_TR_TimeSpent__c = '28', 
                                                                       OC_TR_Status__c = 'Not Submitted',
                                                                       OC_TR_LegalForm__c= '07',
                                                                       OC_TR_Active__c = true,
                                                                       OC_TR_Organization__c='Test IBMO',
                                                                       OC_TR_ZZOrgNew__c ='1234',
                                                                       OC_TR_Customer_CC__c='1234');
            timeRecordList.add(timeRecord1);
            timeRecordList.add(timeRecord2);
            timeRecordList.add(timeRecord3);
            timeRecordList.add(timeRecord4);
            timeRecordList.add(timeRecord5);
            insert timeRecordList;
            
            /* Added for TR-Manual TH - End */
            
        }   
    }
    
    @isTest
    static void timeRecordBeforeInsertAndAfterUpdateTest(){
        List<OC_TR_TimeRecord__c> timeRecUpdList = new List<OC_TR_TimeRecord__c> ();
        List<OC_TR_TimeRecord__c> timeRecList = new List<OC_TR_TimeRecord__c> ();
        List<User> userList = [ SELECT id,Name,createddate,OC_TR_EmployeeNumber__c,
                               OC_TR_EmployeeCompanyCode__c,isActive
                               FROM User WHERE OC_TR_EmployeeNumber__c = '1236663'
                               ORDER BY createddate LIMIT 1 ];
        
        List<Account> accountRecList = [ SELECT id,ownerId,Account_Type__c, Name,ParentId,Visible__c 
                                        FROM Account 
                                        WHERE ParentId != null ];
        
        //List<Assignment_ID__c> assignmentIdList = [ SELECT id FROM Assignment_ID__c ];
        
        List<ServiceContract> servContractRecList = [ SELECT id,Name,ownerId,Account.Name,CreatedDate,
                                                     //P_Code__c,
                                                     //Assignment_ID__r.Name,
                                                     OC_MD_Assignment_ID__c 
                                                     FROM ServiceContract 
                                                     WHERE Name Like '%Test%' ORDER BY createddate];
        timeRecList = [Select Id,OC_TR_TimeSpent__c,OC_TR_Employee_Number__c,CreatedDate,
                                                     OC_Tech_TR_ConcatenateEmpNoPostDate__c,OC_TR_Active__c,
                                                     OC_TR_PostingDate__c,OC_TR_Status__c,OC_Tech_TR_PostingDate__c
                                                     FROM OC_TR_TimeRecord__c ORDER BY CreatedDate];
        Test.startTest();
        system.runAs(userList[0]){
		try{
           OC_TR_TimeRecord__c fetchedTimeRecord = [SELECT Id FROM OC_TR_TimeRecord__c 
                                                     WHERE OC_TR_ObjectIdCon__c =: servContractRecList[0].Id 
                                                     LIMIT 1];
             
            fetchedTimeRecord.OC_TR_ObjectIdCon__c = servContractRecList[2].Id;//Modified for TR-Manual TH
            //fetchedTimeRecord.OC_TR_ServiceToAccount__c = accountRecList[1].Id; // Commented for TR-Manual TH
            fetchedTimeRecord.OC_TR_ZCostAlloc__c = 'K';  
            fetchedTimeRecord.OC_TR_Organization__c = 'Test';
            fetchedTimeRecord.OC_TR_ZZOrgNew__c = '123';
            fetchedTimeRecord.OC_TR_LegalForm__c= '07';
            fetchedTimeRecord.OC_TR_Status__c = 'Submitted';
            fetchedTimeRecord.OC_TR_TimeSpent__c = '14';
            update fetchedTimeRecord; 
            delete fetchedTimeRecord;
        
	    }catch(Exception excp){}
        }
        System.runAs(userList[0]){
            timeRecList[3].OC_TR_Status__c = OC_TR_Constants.Submitted;
            update timeRecList[3];
            timeRecList[4].OC_TR_Status__c = OC_TR_Constants.Submitted;
            timeRecUpdList.add(timeRecList[4]);
            OC_TR_ValidationsUtility.ValidateAgentTimeSpentOnTimeRecord(timeRecUpdList);
        }
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void checkEmailReminder(){
        Test.startTest();
         Database.executeBatch(new OC_TR_SendRemindersToGenerateTimeRecords(),500); 
        Test.stopTest();
    }
    
    @isTest(SeeAllData = false)
    public static void testScheduleEmailReminder(){
        Test.startTest();
        OC_TR_SCH_TimeReportingEmailReminders sh1 = new OC_TR_SCH_TimeReportingEmailReminders();
		String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, sh1);
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