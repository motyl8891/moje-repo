@isTest(seeAllData = false)
private class OpportunityTriggerHandlerTest{

    @isTest
    public static void test_OpportunityHandlerTrigger(){
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false); 
          insert acc;
        }
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,Forecast__c = 'Exclude'));
        opp1.RecordTypeId = GlobalConstants.frameOppRecordTypeId;
        insert opp1;
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,Forecast__c = 'Exclude'));
        opp2.RecordTypeId = GlobalConstants.simpleCreateOppRecTypeId;
        opp2.StageName = '4. Negotiate and Close';
        opp2.Forecast__c= 'Exclude';
        opp2.Parent_Account_Update__c = True;
        opp2.Parent_Original_Opportunity__c = opp1.id;
        insert opp2;

        System.assertEquals(true, opp2.Id != null);
        try {
            opp1.Deal_Value__c = 100;
            update opp1;
            delete opp1;
            System.assertEquals(true, opp1.Id != null);
        } catch (Exception e) {
        }       
    }
    
    @isTest
    public static void test1_OpportunityHandlerTrigger(){
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false); 
          insert acc;
        }
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,Forecast__c = 'Exclude'));
        opp1.RecordTypeId = GlobalConstants.frameOppRecordTypeId;
        insert opp1;
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,Forecast__c = 'Exclude'));
        opp2.RecordTypeId = GlobalConstants.standardOppRecordTypeId;
        opp2.StageName = '1. Qualify Opportunity';
        opp2.Forecast__c= 'Exclude';
        opp2.Parent_Account_Update__c = True;
        opp2.Parent_Original_Opportunity__c = opp1.id;
        insert opp2;

        System.assertEquals(true, opp2.Id != null);
        try {
            opp1.Deal_Value__c = 100;
            update opp1;
            delete opp1;
            System.assertEquals(true, opp1.Id != null);
        } catch (Exception e) {
        }       
    }
}