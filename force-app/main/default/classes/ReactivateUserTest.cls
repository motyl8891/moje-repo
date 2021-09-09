/**
 * @File Name          : ReactivateUserTest.cls
 * @Description        : 
 * @Author             : Ananth Chilapally
 * @Group              : 
 * @Last Modified By   : Ananth Chilapally
 * @Last Modified On   : 2019-10-16 22:47:08
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2019-10-16   Ananth Chilapally     Initial Version
**/
@isTest(seeAllData = false) 
private class ReactivateUserTest 
{
static testMethod void reactivateMeNoUser() 
	{
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis(), Email='ericsson777@test.com'),true);
		testUser.IsActive =false;
		update testUser;
		
		Test.StartTest(); 

			PageReference pageRef = Page.ReactivateUser;
			Test.setCurrentPage(pageRef);
			ReactivateUser reacUsr = new ReactivateUser();
			reacUsr.showValue();
		Test.StopTest();
        System.assertEquals(true,reacUsr.emailoutput.contains('You do not have access to Salesforce.'));
	}
    static testMethod void reactivateMeOneUser() 
	{
		User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis(), Email='ericsson777@test.com'),true);
		testUser1.IsActive =false;
		update testUser1;
		
		Test.StartTest(); 

			PageReference pageRef1 = Page.ReactivateUser;
			Test.setCurrentPage(pageRef1);
			ReactivateUser reacUsr1 = new ReactivateUser();
			reacUsr1.hdnValue = 'ericsson777@test.com';
			reacUsr1.showValue();
		Test.StopTest();
		System.assertEquals(true,reacUsr1.emailoutput.contains('last login date was'));      
	}
	static testMethod void reactivateMeTwoUsers() 
	{
    
        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'testuser2@test.com'+System.currentTimeMillis(), Email='testuser2@test.com'),true);
		User testUser3 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'testuser2@test.com'+System.currentTimeMillis()+'.invalid', Email='testuser2@test.com'),true);
        
		Test.StartTest(); 

			PageReference pageRef2 = Page.ReactivateUser;
			Test.setCurrentPage(pageRef2);
			ReactivateUser reacUsr2 = new ReactivateUser();
			reacUsr2.hdnValue = 'testuser2@test.com';
			reacUsr2.showValue();
		Test.StopTest();
		System.assertEquals(true,reacUsr2.emailoutput.contains('users are associated with your email address.'));
	}    
}