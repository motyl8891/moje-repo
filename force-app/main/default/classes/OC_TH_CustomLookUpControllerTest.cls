/**
* @File Name          : OC_TH_CustomLookUpControllerTest
* @Description        : Test Class for
*                       OC_TH_CustomLookUpController (Direct)
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : R20_08
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        R20_08                  IBM                      Initial Version
* 2.0        2020-08-31              IBM                      Test Class Improvement
**/
@isTest
public class OC_TH_CustomLookUpControllerTest {
    
    @testSetup static void testSetupData(){
        List<User> userList = new List<User>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), 'OC_TestDataGenerator.UserRoleDefaults', true);
        User migrationUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = migrationUserProfileId, UserRoleId = ocUserRole.Id, FederationIdentifier = 'OCINTGR', isActive = True), 'OC_TestDataGenerator.IntegrationUserDefaults', true);
        System.runAs(migrationUser){
            
            Account tempPartnerAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.PartnerAccountDefaults', true);
            tempPartnerAccount.IsPartner = true;
            update tempPartnerAccount;
            
            Profile communityPortalUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Customer Community Plus Custom User' LIMIT 1];
            User communityUser = (User) OC_TestDataGenerator.createSObject(new User(), 'OC_TestDataGenerator.PartnerUserDefaults');
            Contact tempPartnerContact = (Contact) OC_TestDataGenerator.createSObject(new Contact(AccountId = tempPartnerAccount.Id, Email = communityUser.Email), 'OC_TestDataGenerator.PartnerContactDefaults', true);
            
            communityUser.ContactId = tempPartnerContact.Id;
            communityUser.ProfileId = communityPortalUserProfile.Id;
            communityUser.FederationIdentifier = 'OCPARTN';
            communityUser.isActive = True;
            
            OC_TestDataGenerator.createSObject(communityUser, true);
            
            insert (new OC_Org_Defaults__c(OC_Extended_Lookup_Limit__c = 200, OC_Standard_Lookup_Limit__c = 5));
        }
        
    }
    
    
    @isTest static void fetchLookUpValuesTest1(){
        List<sObject> returnList;
        OC_TestDataGenerator.PartnerAccountDefaults tempPADefaults = new OC_TestDataGenerator.PartnerAccountDefaults();
        OC_TestDataGenerator.PartnerContactDefaults tempPCDefaults = new OC_TestDataGenerator.PartnerContactDefaults();
        User runningUser = [SELECT Id FROM User WHERE FirstName = 'OC Partner' AND LastName = 'Testing' LIMIT 1];
        
        Test.startTest();
        System.runAs(runningUser){
            returnList = OC_TH_CustomLookUpController.fetchLookUpValues('Test', 'Account', '',false, '');
            System.assertEquals(tempPADefaults.getFieldDefaults().get('Name'), returnList[0].get('Name'));
            returnList = OC_TH_CustomLookUpController.fetchLookUpValues('Test', 'Asset', '',false, '');
            System.assertEquals(0, returnList.size());
            returnList = OC_TH_CustomLookUpController.fetchLookUpValues('Test', 'Asset','', true, 'Name;Product2.Name');
            System.assertEquals(0, returnList.size());
            returnList = OC_TH_CustomLookUpController.fetchLookUpValues('Partner', 'Contact', '',false, '');
            System.assertEquals(true, ((String) returnList[0].get('Name')).contains(((String) tempPCDefaults.getFieldDefaults().get('FirstName'))));
            System.assertEquals(true, ((String) returnList[0].get('Name')).contains(((String) tempPCDefaults.getFieldDefaults().get('LastName'))));
        }
        Test.stopTest();
    }
    
    @isTest static void fetchLookUpValuesTest2(){
        List<sObject> returnList;
        Id dataManagerProfileId = [Select Id FROM Profile WHERE Name='Ericsson Service'].Id;
        List<User> testUserList = new List<User> ();
        User testuser = (User)TestDataGenerator.createSObject(new User());
        
        testuser.UserName = 'ericsson@test.com';
        testuser.Email='integrationuser@invalid.com';
        testuser.ProfileId = dataManagerProfileId;
        insert testuser;
        system.assertEquals(testuser.UserName,'ericsson@test.com');
        Test.startTest();
        System.runAs(testUser){
            returnList = OC_TH_CustomLookUpController.fetchLookUpValues('Test', 'Account', 'Sfdc_Ebip_Ibase_OutApi',false, '');
        }
        Test.stopTest();
    }    
}