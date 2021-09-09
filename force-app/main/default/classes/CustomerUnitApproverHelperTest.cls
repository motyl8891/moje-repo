@isTest(seeAllData = false)
private class CustomerUnitApproverHelperTest {
    @isTest
    static void testUpdateGCUApprovers() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                        UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU', GCU_Head__c = testUser.Id, GCU_Commercial_Head__c = testUser.Id ), false);
            insert cu;
            /**CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(GlobalCustomerUnit__c = cu.Id), false);
            insert crg;
            Account acc = (Account)TestDataGenerator.createSObject(new Account(CustomerReportingGroup__c = crg.Id), false);
            insert acc;**/
           CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
            crg.MarketArea__c = GlobalConstants.MELA;
            crg.CRG_ID__c='HW1235';
            crg.Name='testCRG1';
            insert crg;
           
            Account acc = new Account();
            acc.Name = 'Test Account1';
            acc.SAP_S2P_ID__c='1244';
            acc.CurrencyIsoCode = 'SEK';
            acc.Visible__c = true;
            acc.Customer_Tier__c = 'Tier 1';
            acc.CustomerReportingGroup__c= crg.id; 
            insert acc; 

            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
            insert opp;
            List<Opportunity> oppList = CustomerUnitApproverHelper.updateOpptyGCUUsers(new Map<Id, GCUApprovers> {cu.Id => new GCUApprovers(cu.GCU_Head__c, cu.GCU_Commercial_Head__c)});

            GCUApprovers gcuObj = new GCUApprovers(cu.GCU_Head__c, cu.GCU_Commercial_Head__c);
            String a = gcuObj.GCUHead;
            String b = gcuObj.GCUCommercialHead;
            System.assertEquals(a, cu.GCU_Head__c);
            System.assertEquals(b, cu.GCU_Commercial_Head__c);
        }

        List<CustomerUnit__c> cuList = [Select Id, Type__c from CustomerUnit__c];
        System.assertEquals(1, cuList.size());
        System.assertEquals('GCU', cuList.get(0).Type__c);
    }
}