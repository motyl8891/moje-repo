@isTest
public class OC_TH_ServiceMilestoneTest {
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    Public Static List<ServiceContract> serviceContractList = new List<ServiceContract>();
    Public Static List<OC_MD_Installed_Base_Item__c> ibItemList = new List<OC_MD_Installed_Base_Item__c>();
    Public Static List<Entitlement> entitlementList = new List<Entitlement>();
    Public Static List<OC_TH_Service_Milestone__c> serviceMilstnList = new List <OC_TH_Service_Milestone__c>();
    
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();

    @testSetup
    
    static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuser@test.com';
        
        insert testuser;
        
        Id permisnSetId = [SELECT Id from PermissionSet WHERE Label = 'Ericsson Service Support Engineer'].Id;   
        if(!testuser.IsActive){
        PermissionSetAssignment permissionSetList = new PermissionSetAssignment();
        permissionSetList.AssigneeId = testuser.Id;
        permissionSetList.PermissionSetId = permisnSetId; 
        insert permissionSetList; 
        }
        
        System.runAs(testuser){
            
            accountList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accountList[0].Account_Type__c = 'Service';
            accountList[0].Name = 'TestAccount';
            insert accountList;
            
            contactList = OC_TestDataGenerator.createSObjectList(new Contact(),1);
            contactList[0].FirstName = '001testing';
            contactList[0].LastName = 'TestCon1';
            contactList[0].phone='4567890999';
            contactList[0].AccountId = accountList[0].id;
            contactList[0].Email = 'xyz@ibm.com';
            contactList[0].MailingCountry = 'India';     
            insert contactList;
            
            entitlementList = OC_TestDataGenerator.createSObjectList(new Entitlement(),1);
            entitlementList[0].Name = 'TestEntitlement001';
            entitlementList[0].AccountId = accountList[0].id;
            insert entitlementList;
            
            
           serviceContractList = OC_TestDataGenerator.createSObjectList(new ServiceContract(),1);
           serviceContractList[0].Name = '0005104220Test - GSM, WCDMA' ;
           serviceContractList[0].AccountId = accountList[0].id;
           serviceContractList[0].StartDate = date.today();
           serviceContractList[0].EndDate = date.today();
           serviceContractList[0].OC_TH_Entitlement__c = entitlementList[0].Id;
           insert serviceContractList;
            
           OC_TH_Service_Milestone__c serviceMlistn = new OC_TH_Service_Milestone__c (OC_TH_Service_Contract__c=serviceContractList[0].id,
                                                                                     OC_TH_Priority__c = '1',
                                                                                     OC_TH_Remedy1__c = '30',
                                                                                     OC_TH_Solution1__c ='60',
                                                                                     OC_TH_CallBack1__c ='90'
                                                                                     );
          insert serviceMlistn;  
            
           assetList = OC_TestDataGenerator.createSObjectList(new Asset(),1);
           assetList[0].name = 'afg001';
           assetList[0].AccountId = accountList[0].id;
           assetList[0].RecordTypeId = assetRecordTypeId;
           insert assetList;
            
 	 	  ibItemList  = OC_TestDataGenerator.createSObjectList(new OC_MD_Installed_Base_Item__c(),1);     
          ibItemList[0].Name = 'Ibitemtest001';
          ibItemList[0].OC_MD_Asset__c = assetList[0].id ;
          ibItemList[0].OC_MD_Service_Contract__c = serviceContractList[0].id;
          insert ibItemList;
            
         caseList = OC_TestDataGenerator.createSObjectList(new Case(),1);
         caseList[0].RecordTypeId = standardRecordType;   
         caseList[0].Subject = 'Test Case with Entitlement for Milestone ';
         caseList[0].AccountId = accountList[0].id;
         caseList[0].Status = 'Registered' ;
         caseList[0].Priority = '1';
         caseList[0].Type = 'Issue'; 
         caseList[0].OC_TH_Main_Asset_Type__c='Node Type';
         caseList[0].AssetId = assetList[0].id;
         caseList[0].EntitlementId = entitlementList[0].id;
         caseList[0].ContactId = contactList[0].id;
         caseList[0].OC_TH_Customer_Description__c = 'Testing test cases 001';
         caseList[0].OC_TH_Installed_Base_Item__c= ibItemList[0].id;
         insert caseList;

        }
    }
    
    @isTest
    static void TestRemedycalculateMilestoneTriggerTime(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                                FROM User WHERE Email  = 'testuser@test.com'
                                ORDER BY createddate LIMIT 1 ];
        
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        
        List<Asset> assetList = [SELECT Name, AccountId, RecordTypeId FROM Asset WHERE Name = 'afg001' LIMIT 1 ];
        
 		List<Entitlement> entlmntList = [Select Name, AccountId FROM Entitlement WHERE Name ='TestEntitlement001' LIMIT 1]; 
        
        List<Contact> conList	=	[SELECT FirstName, LastName,Phone, Email FROM Contact WHERE LastName ='TestCon1' LIMIT 1];
        
 		List <OC_MD_Installed_Base_Item__c> ibItemList = [SELECT id, Name,OC_MD_Asset__c, OC_MD_Service_Contract__c FROM OC_MD_Installed_Base_Item__c WHERE Name ='Ibitemtest001'];       
        
        
        
     	Case case1 = new Case (RecordTypeId = standardRecordType,
                               Subject = 'Test Case with Entitlement for Milestone ', 
                               AccountId = accList[0].id,
                               Status = 'Registered',
       					       Priority = 'High', 
                               Type = 'Issue',
                               OC_TH_Main_Asset_Type__c='Node Type',
                               AssetId = assetList[0].id,
                               EntitlementId = entlmntList[0].id,
         					   ContactId = conList[0].id,
                               OC_TH_Customer_Description__c = 'Testing test cases 001',
                               OC_TH_Installed_Base_Item__c= ibItemList[0].id);   
       
       Id caseId = case1.id;
        
       
       MilestoneType remedy1Milstn = [SELECT Id, Name, Description FROM MilestoneType WHERE Name= 'REMEDY1' LIMIT 1 ]; 

       Test.startTest();
        
        System.runAs(userList[0]){
            try{
     
            OC_TH_ServiceMilestone SLAtime = new OC_TH_ServiceMilestone ();
            SLAtime.calculateMilestoneTriggerTime (CaseId , remedy1Milstn.Id );
            }Catch (Exception ex){}
            
        }
       
    } 
    
	@isTest
    static void TestSolutioncalculateMilestoneTriggerTime(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                                FROM User WHERE Email  = 'testuser@test.com'
                                ORDER BY createddate LIMIT 1 ];
        
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        
        List<Asset> assetList = [SELECT Name, AccountId, RecordTypeId FROM Asset WHERE Name = 'afg001' LIMIT 1 ];
        
 		List<Entitlement> entlmntList = [Select Name, AccountId FROM Entitlement WHERE Name ='TestEntitlement001' LIMIT 1]; 
        
        List<Contact> conList	=	[SELECT FirstName, LastName,Phone, Email FROM Contact WHERE LastName ='TestCon1' LIMIT 1];
        
 		List <OC_MD_Installed_Base_Item__c> ibItemList = [SELECT id, Name,OC_MD_Asset__c, OC_MD_Service_Contract__c FROM OC_MD_Installed_Base_Item__c WHERE Name ='Ibitemtest001'];       
        
        
        
     	Case case1 = new Case (RecordTypeId = standardRecordType,
                               Subject = 'Test Case with Entitlement for Milestone ', 
                               AccountId = accList[0].id,
                               Status = 'Registered',
       					       Priority = 'High', 
                               Type = 'Issue',
                               OC_TH_Main_Asset_Type__c='Node Type',
                               AssetId = assetList[0].id,
                               EntitlementId = entlmntList[0].id,
         					   ContactId = conList[0].id,
                               OC_TH_Customer_Description__c = 'Testing test cases 001',
                               OC_TH_Installed_Base_Item__c= ibItemList[0].id);   
       
       Id caseId = case1.id;

       MilestoneType solution1Milstn = [SELECT Id, Name, Description FROM MilestoneType WHERE Name= 'SOLUTION1' LIMIT 1 ]; 
       Test.startTest();
        
        System.runAs(userList[0]){
            try{
            OC_TH_ServiceMilestone SLAtime = new OC_TH_ServiceMilestone ();
            SLAtime.calculateMilestoneTriggerTime (CaseId , solution1Milstn.id );
    	    
            }Catch (Exception ex){}
            
        }
    }          

    @isTest
    static void TestCallbackcalculateMilestoneTriggerTime(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email
                                FROM User WHERE Email  = 'testuser@test.com'
                                ORDER BY createddate LIMIT 1 ];
        
        List<Account> accList = [SELECT Id, Name, Account_Type__c FROM Account WHERE Account_Type__c = 'Service' LIMIT 1 ];
        
        List<Asset> assetList = [SELECT Name, AccountId, RecordTypeId FROM Asset WHERE Name = 'afg001' LIMIT 1 ];
        
 		List<Entitlement> entlmntList = [Select Name, AccountId FROM Entitlement WHERE Name ='TestEntitlement001' LIMIT 1]; 
        
        List<Contact> conList	=	[SELECT FirstName, LastName,Phone, Email FROM Contact WHERE LastName ='TestCon1' LIMIT 1];
        
 		List <OC_MD_Installed_Base_Item__c> ibItemList = [SELECT id, Name,OC_MD_Asset__c, OC_MD_Service_Contract__c FROM OC_MD_Installed_Base_Item__c WHERE Name ='Ibitemtest001'];       
        
        
        
     	Case case1 = new Case (RecordTypeId = standardRecordType,
                               Subject = 'Test Case with Entitlement for Milestone ', 
                               AccountId = accList[0].id,
                               Status = 'Registered',
       					       Priority = 'High', 
                               Type = 'Issue',
                               OC_TH_Main_Asset_Type__c='Node Type',
                               AssetId = assetList[0].id,
                               EntitlementId = entlmntList[0].id,
         					   ContactId = conList[0].id,
                               OC_TH_Customer_Description__c = 'Testing test cases 001',
                               OC_TH_Installed_Base_Item__c= ibItemList[0].id);   
       
       Id caseId = case1.id;
        
        MilestoneType callback1Milstn = [SELECT Id, Name, Description FROM MilestoneType WHERE Name= 'CALLBACK1' LIMIT 1 ]; 
       Test.startTest();
        
        System.runAs(userList[0]){
            try{
                
            OC_TH_ServiceMilestone SLAtime = new OC_TH_ServiceMilestone ();
            SLAtime.calculateMilestoneTriggerTime (CaseId , callback1Milstn.id );
    	    
            }Catch (Exception ex){}
            
        }
    }

}