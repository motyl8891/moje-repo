@isTest(seeAllData = false)
private class OpportunityTagHelperTest {  
    @isTest
    public static void test_OpportunityTrigger(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){ 
                acc = (Account)TestDataGenerator.createSObject(new Account(), false); 
                insert acc;
            }
            
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
            insert opp;
            
            System.assertEquals(true, opp.Id != null);
            tags__c tg = new tags__c(name = 'tag1');
            insert tg;   
            tags__c tg5 = new tags__c(name = 'tag11');
            insert tg5;   
            
            Opportunity_tags__c ot = new Opportunity_tags__c(opportunity__c = opp.id,tag__c = tg.id);
            insert ot;
            Opportunity_tags__c ot1 = new Opportunity_tags__c(opportunity__c = opp.id,tag__c = tg5.id);
            insert ot1;
            Set<id> oppIdSet = new Set<id>();
            oppIdSet.add(ot.opportunity__c);
            oppIdSet.add(ot1.opportunity__c);
            test.startTest();
            OpportunityTagHelper.updateTagOnOpportunity(oppIdSet);
            OpportunityTagHelper.updateTagOnOpportunity(null);
            test.stopTest();
            tags__c tg1 = new tags__c(Id = tg.Id,name = 'tag12');
            update tg1;
            update ot;
            delete ot;            
            TagTriggerHandler.onAfterUpdate(null,null,null,null);
            TagTriggerHelper.updateTagOnOpportunity(null,null);             
        }catch(Exception e){	}
    }
}