/*******************************************************************
 * @author: Bhushan K
 * @date: 2019-12-15
 * @description: This test class is for the class PreChatFormApexController
 ********************************************************************/
@isTest
private class PreChatFormApexControllerTest {
	@testSetup
	static void setupTestData() {
        
        
        Profile integrationUserProfile = [SELECT Id FROM Profile WHERE Name =: 'Integration User Profile' LIMIT 1];
        UserRole ocUserRole = (UserRole) OC_TestDataGenerator.createSObject(new UserRole(), 'OC_TestDataGenerator.UserRoleDefaults', true);
        User integrationUser = (User) OC_TestDataGenerator.createSObject(new User(ProfileID = integrationUserProfile.Id, UserRoleId = ocUserRole.Id, FederationIdentifier = 'OCINTGR', isActive = True), 'OC_TestDataGenerator.IntegrationUserDefaults', true);
        Account tempAccount;
        Contact con= new Contact(Firstname='test123', Lastname = 'testlastname', Email =UserInfo.getUserEmail(), MailingCountry='Cuba');
        System.runAs(integrationUser){
            tempAccount = (Account) OC_TestDataGenerator.createSObject(new Account(), 'OC_TestDataGenerator.AccountDefaults', true);            
            con.AccountId=tempAccount.id;
            insert con;
		}

	}
	static testMethod void testsearchForEmail() {
		List<Account> ac = [SELECT Id, Name FROM Account];
		System.assertEquals(true, ac.size() > 0);
        List<Contact> Contact=  [SELECT Id, LastName, Name, Email from Contact where Email =:UserInfo.getUserEmail() Limit 1];
		System.assertEquals(true, Contact.size() > 0);
        if(Contact.size() > 0)
        {
			PreChatFormApexController obj01 = new PreChatFormApexController();
			PreChatFormApexController.searchForEmail();
		}
	}
}