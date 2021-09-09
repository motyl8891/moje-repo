@isTest(seeAllData = false)
private class CustomerReportingGroupApproverHelperTest
{
    @isTest
    static void testUpdateCRGApprovers()
    {
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
                                                                                    
            System.runAs(testUser)
            {
                CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(Account_Primary_KAM__c = testUser.Id, Account_CU_Head__c = testUser.Id ), false);
                insert crg;
                
                //acc = (Account)TestDataGenerator.createSObject(new Account(CustomerReportingGroup__c = crg.Id), false);
                acc= new Account();
                
            acc.Name = 'Test Account';
            acc.SAP_S2P_ID__c=String.valueOf(1);
            acc.CurrencyIsoCode = 'SEK';
            acc.Visible__c = true;
            acc.Customer_Tier__c = 'Tier 1';
            acc.CustomerReportingGroup__c= crg.id;
                
                insert acc;
                
                Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
                Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
                insert opp;
                
                List<Opportunity> oppList = CustomerReportingGroupApproverHelper.updateOpptyCRGUsers(new Map<Id, CRGApprovers>
                {
                    crg.Id => new CRGApprovers(crg.Account_Primary_KAM__c, crg.Account_CU_Head__c)
                });
                
                CRGApprovers crgObj = new CRGApprovers(crg.Account_Primary_KAM__c, crg.Account_CU_Head__c);
                String a = crgObj.CRGAccountPrimaryKAM;
                String b = crgObj.CRGAccountCUHead;
                System.assertEquals(a, crg.Account_Primary_KAM__c);
                System.assertEquals(b, crg.Account_CU_Head__c);
        }
        
        List<CustomerReportingGroup__c> crgList = [Select Id from CustomerReportingGroup__c];
        System.assertEquals(1, crgList.size());
    }
}