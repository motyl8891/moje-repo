/* Description : Test class for OC_TH_CaseTeamMemberComponentController.
* Author      : Subashini Arulalan
*
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0      2021-03-18         Subashini Arulalan       Initial Version as part of U-2585
*/

@isTest
public class OC_TH_CaseTeamMemberComponentTest {
    Public Static List<Case> caseList = new List<Case>();
    Public Static List<Account> accountList = new List<Account>();
    Public Static List<Asset> assetList = new List<Asset>();
    Public Static List<Contact> contactList = new List<Contact>();
    public Static List<Case> colabCaseList = new List<Case>();
    Public Static List<Task> taskList = new List<Task>();
    Public Static List<PermissionSetAssignment> psAssignmtList = new List<PermissionSetAssignment>();
    
    Public Static Id assetRecordTypeId= Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getNodeTypeRecordType).getRecordTypeId();
    Public Static Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
    Public Static Id collaborationRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getCollaborationCsrRecordType).getRecordTypeId();   
    @testSetup
    static void setup(){
        
        Id serviceprofileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id;
        User testuser = (User)TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = serviceprofileId;
        testuser.Email = 'testuserteamMem@test.com';
        insert testuser;        
        
        User testuser1 = (User)TestDataGenerator.createSObject(new User());
        testuser1.UserName = 'ericssontest@test.com'+System.currentTimeMillis();
        testuser1.ProfileId = serviceprofileId;
        testuser1.Email = 'testuserteamMem1@test.com';
        insert testuser1;
        
        User testuser2 = (User)TestDataGenerator.createSObject(new User());
        testuser2.UserName = 'ericssontestt@test.com'+System.currentTimeMillis();
        testuser2.ProfileId = serviceprofileId;
        testuser2.Email = 'testuserteamMem2@test.com';
        insert testuser2;
        
        Id permisnSetId = [SELECT Id from PermissionSet WHERE Label = 'Ericsson Service Support Engineer'].Id;
        
        
        PermissionSetAssignment permissionSetUser1 = new PermissionSetAssignment();
        permissionSetUser1.AssigneeId = testuser.Id;
        permissionSetUser1.PermissionSetId = permisnSetId; 
        
        PermissionSetAssignment permissionSetUser2 = new PermissionSetAssignment();
        permissionSetUser2.AssigneeId = testuser1.Id;
        permissionSetUser2.PermissionSetId = permisnSetId; 
        
        PermissionSetAssignment permissionSetUser3 = new PermissionSetAssignment();
        permissionSetUser3.AssigneeId = testuser2.Id;
        permissionSetUser3.PermissionSetId = permisnSetId;
        
        psAssignmtList.add(permissionSetUser1);
        psAssignmtList.add(permissionSetUser2);
        psAssignmtList.add(permissionSetUser3);
        
        insert psAssignmtList;
        
        System.runAs(testuser){
            
            accountList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accountList[0].Account_Type__c = 'Service';
            accountList[0].Name = 'TestAccount001';
            insert accountList;
            system.assertEquals(accountList.size(), 1);
            
            contactList = OC_TestDataGenerator.createSObjectList(new Contact(),1);
            if(!accountList.isEmpty()){
                contactList[0].FirstName = '001testing';
                contactList[0].LastName = 'TestCon0011';
                contactList[0].phone='4352787188';
                contactList[0].AccountId = accountList[0].id;
                contactList[0].Email = 'xyz@ibm.com';
                contactList[0].MailingCountry = 'India';     
                insert contactList;
                system.assertEquals(contactList.size(),1);
                
            }  
            assetList = OC_TestDataGenerator.createSObjectList(new Asset(),1);
            if(!accountList.isEmpty()){
                assetList[0].name = 'afg001';
                assetList[0].AccountId = accountList[0].id;
                assetList[0].RecordTypeId = assetRecordTypeId;
                insert assetList;
                system.assertEquals(assetList.size(),1);
            }
                      
            if(!accountList.isEmpty() && !contactList.isEmpty() && !assetList.isEmpty()){
                
                Case case1 = new Case(Subject = 'parent Case',
                                      AccountId = accountList[0].id,
                                      ContactId = contactList[0].id,
                                      Status = 'Registered',
                                      Priority = '1',
                                      Type = '901',
                                      OC_TH_Main_Asset_Type__c='Node Type',
                                      AssetId = assetList[0].id,
                                      ownerId =testuser.id,
                                      RecordTypeId = standardRecordType,
                                      OC_TH_Customer_Description__c = 'Testing test cases 001');
                
                caseList.add(case1);
                insert caseList;
            }
        }
    }
    @isTest
    static void testCaseTeamMember(){
        
        List<User> userList = [SELECT id,Name,createddate,isActive, Email FROM User WHERE Email  = 'testuserteamMem1@test.com' OR Email  = 'testuserteamMem2@test.com'];
        List<User> RunAsUser = [SELECT id,Name,createddate,isActive, Email FROM User where Email  = 'testuserteamMem@test.com'];       
        List<Case> csList = [SELECT Id,Priority,Type,Status,CreatedDate,OC_TH_Service_Contract__c,Subject FROM Case WHERE Subject = 'parent Case'];
        try{
            System.runAs(RunAsUser[0]){
                if(!csList.isEmpty()){
                    Map<String, OC_TH_Case_TeamRole__mdt> mapRoleId = OC_TH_Case_TeamRole__mdt.getAll();
                    CaseTeamMember caseteam = new CaseTeamMember();
                    caseteam.MemberId = userList[0].id;
                    caseteam.parentId = csList[0].Id;
                    caseteam.TeamRoleId = mapRoleId.get('Team_Member').RoleId__c;
                    insert caseteam;
                    CaseTeamMember caseteam1 = new CaseTeamMember();
                    caseteam1.MemberId = userList[1].id;
                    caseteam1.parentId = csList[0].Id;
                    caseteam1.TeamRoleId = mapRoleId.get('Former_Team_Member').RoleId__c;
                    insert caseteam1;

                }
                test.startTest();
                    OC_TH_CaseTeamMemberComponentController.getRelatedList(csList[0].Id);
                test.stopTest();
            }
        }Catch (Exception ex){}
        
    }
}