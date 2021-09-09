/**
* @File Name          : OC_ForumAccessControllerTest
* @Description        : Test Class for
*						OC_ForumAccessController (Direct)
*
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 18th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-18              Rohit Gaba               Initial Version
**/
@isTest
public class OC_ForumAccessControllerTest {
    
    
    //PS Assignment - Unassignment
    @isTest static void test_assign_unassign_PS() {
        Account customerAccount = [SELECT Id, OC_UAM_Forum_Visibility__c FROM Account WHERE Name = 'Test Partner Account' LIMIT 1];
        
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Integration' AND LastName = 'Testing' LIMIT 1];
        
        if(customerAccount != NULL){
            customerAccount.OC_UAM_Forum_Visibility__c = true;
            update customerAccount;
            System.runAs(runningUser){
            	OC_ForumAccessController.getRecords(new List<Id>{[SELECT Id FROM User WHERE AccountId = :customerAccount.Id LIMIT 1].Id});
            }
			System.assertEquals(true, [SELECT Id FROM PermissionSetAssignment where PermissionSetId = :[Select Id, Name from PermissionSet where Name = :OC_Org_Defaults__c.getOrgDefaults().OC_Forum_Visibility_PermissionSetName__c LIMIT 1].Id AND AssigneeId IN :[Select Id from User where AccountId = :customerAccount.Id]].size() > 0);
            
            customerAccount.OC_UAM_Forum_Visibility__c = false;
            update customerAccount;
            System.runAs(runningUser){
            	OC_ForumAccessController.getRecords(new List<Id>{customerAccount.Id});
            }
            System.assertEquals(true, [SELECT Id FROM PermissionSetAssignment where PermissionSetId = :[Select Id, Name from PermissionSet where Name = :OC_Org_Defaults__c.getOrgDefaults().OC_Forum_Visibility_PermissionSetName__c LIMIT 1].Id AND AssigneeId IN :[Select Id from User where AccountId = :customerAccount.Id]].size() == 0);
            
            customerAccount.OC_UAM_Forum_Visibility__c = true;
            update customerAccount;
            System.runAs(runningUser){
            	OC_ForumAccessController.getRecords(new List<Id>{customerAccount.Id});
            }
            
            System.assertEquals(true, [SELECT Id FROM PermissionSetAssignment where PermissionSetId = :[Select Id, Name from PermissionSet where Name = :OC_Org_Defaults__c.getOrgDefaults().OC_Forum_Visibility_PermissionSetName__c LIMIT 1].Id AND AssigneeId IN :[Select Id from User where AccountId = :customerAccount.Id]].size() > 0);
        }
    }

    
    
    @testSetup public static void setup(){
        
        Profile integrationUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Integration User Profile' LIMIT 1];
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), 'OC_TestDataGenerator.UserRoleDefaults', true);
        User integrationUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = integrationUserProfile.Id, UserRoleId = ocUserRole.Id, FederationIdentifier = 'OCINTGR', isActive = True), 'OC_TestDataGenerator.IntegrationUserDefaults', true);
        System.runAs(integrationUser){
            Account tempAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.AccountDefaults', true);
            
            Account tempPartnerAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.PartnerAccountDefaults', true);
            tempPartnerAccount.IsPartner = true;
            update tempPartnerAccount;
            
            OC_TestDataGenerator.insertCustomSettingsData();
            
            Profile serviceUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Ericsson Service' LIMIT 1];
            User serviceUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = serviceUserProfile.Id, FederationIdentifier = 'OCSERVC', isActive = True), 'OC_TestDataGenerator.UserDefaults', true);
            
            Profile communityPortalUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Customer Community Plus Custom User' LIMIT 1];
            User communityUser = (User) OC_TestDataGenerator.createSObject(new User(), 'OC_TestDataGenerator.PartnerUserDefaults');
            Contact tempPartnerContact = (Contact) OC_TestDataGenerator.createSObject(new Contact(AccountId = tempPartnerAccount.Id, Email = communityUser.Email), 'OC_TestDataGenerator.PartnerContactDefaults', true);
            
            communityUser.ContactId = tempPartnerContact.Id;
            communityUser.ProfileId = communityPortalUserProfile.Id;
            communityUser.FederationIdentifier = 'OCPARTN';
            communityUser.isActive = True;
            
            OC_TestDataGenerator.createSObject(communityUser, true);
        }
    }
}