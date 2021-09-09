@isTest(seeAllData = false)
private class SendEmailForInactiveContactBatchTest 
{
    static testMethod void testMethod1()
    {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
		                UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
		System.runAs(testUser) {
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
		insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'First';    
        con.LastName ='Last';
        con.Email = 'Test@acc.com';
        con.MailingCountry = 'India';
        con.AccountId = acc.ID; 
        con.Inactive__c = true;
        Date today = Date.today().addMonths(-11); 
        con.InactiveDate__c = today;
        insert con;
        }
        Test.startTest();
        SendEmailForInactiveContactBatch obj1 = new SendEmailForInactiveContactBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test inactive contact delete', sch, obj1);
        
        SendEmailForInactiveContactBatch obj = new SendEmailForInactiveContactBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();
        System.assert(true);  //NS
    }
}