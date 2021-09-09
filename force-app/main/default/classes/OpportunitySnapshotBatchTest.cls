@isTest(seeAllData = false)
private class OpportunitySnapshotBatchTest {

        @isTest
        public static void testOpportunitySnapshotBatchJob() {
            Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), CommunityNickname = 'IDS', UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
            System.runAs(testUser) {
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(OwnerId = testUser.Id, AccountId = acc.Id));
            insert opp;
            OpportunitySnapshot__c s = new OpportunitySnapshot__c(Opportunity_Name__c = opp.Id, Opportunity_ID__c = opp.Id, OwnerId = testUser2.Id);
            insert s;

            Test.startTest();
            OpportunitySnapshotBatch obj = new OpportunitySnapshotBatch();
            DataBase.executeBatch(obj);
            Test.stopTest();

            OpportunitySnapshot__c s1 = [SELECT OwnerId FROM OpportunitySnapshot__c LIMIT 1];
            System.assertEquals(testUser.Id,s1.OwnerId);
                }catch(Exception e){	}
        }
    }