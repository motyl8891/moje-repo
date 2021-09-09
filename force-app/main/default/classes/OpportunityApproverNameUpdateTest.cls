@isTest(seeAllData = false)
private class OpportunityApproverNameUpdateTest{
    static testMethod void testUpdateApproverName(){
        Test.startTest();
        List<id> ids = new List<id>();
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        insert opp;
        opp.KAM__c = testUser.id;
        opp.CU_Head__c = testUser.id;
        update opp;
        ids.add(opp.id);

        OpportunityApproverNameUpdate.updateApproverName(ids);

        /*Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(opp.Id);
        app.setProcessDefinitionNameOrId('Standard_CU_Approval_Qualify_Opp_v4');
        app.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(app);*/
		OpportunityApproverNameUpdate.updateApproverName(null);
        Test.stopTest();
        System.assertEquals(true, opp.Id != null);
    }
}