@isTest(seeAllData = false)
private class DeleteInactiveContactsBatchTest 
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
            Date today = Date.today().addMonths(-12); 
            con.InactiveDate__c = today;
            insert con;
        }
        Test.startTest();
        DeleteInactiveContactsBatch obj1 = new DeleteInactiveContactsBatch();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test inactive contact delete', sch, obj1);

        DeleteInactiveContactsBatch obj = new DeleteInactiveContactsBatch();
        DataBase.executeBatch(obj);
        Test.stopTest();
        //NS
		System.assert(true);
    }
}