@isTest
private class RelatedOpportunityControllerTest {
    @testSetup public static void setup(){
        //try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            Account acc;
            System.runAs(testUser){
                acc= (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            Test.startTest();
            Opportunity opp0 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId));  
            insert opp0; 
            Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId));  
            insert opp1;    
            Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId));  
            opp2.Parent_Original_Opportunity__c=opp1.Id;
            insert opp2;    
            Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId));  
            opp3.Parent_Original_Opportunity__c=opp2.id;
            insert opp3;
            Test.stopTest();
        /*}catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error('RelatedOpportunityControllerTest','setup','RelatedOpportunityControllerTest', true, e)));
        }*/
    }
    @isTest static void testGetNoRelatedOpp() {    
        Test.startTest();
        List<Opportunity> opps=[Select id from Opportunity Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        RelatedOpportunityWrapper relatedOpportunityWrapper=RelatedOpportunityController.getRelatedOpps(opps[0].id);
        Test.stopTest();
        System.assertEquals(true,relatedOpportunityWrapper.idVal!=null);
    } 
    @isTest static void testGetAllChildOpp() {    
        Test.startTest();
        List<Opportunity> opps=[Select id from Opportunity Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        RelatedOpportunityWrapper relatedOpportunityWrapper=RelatedOpportunityController.getRelatedOpps(opps[1].id);
        Test.stopTest();
        System.assertEquals(true,relatedOpportunityWrapper.idVal!=null);
    } 
    @isTest static void testGetParentChildOpp() {    
        Test.startTest();
        List<Opportunity> opps=[Select id from Opportunity Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        RelatedOpportunityWrapper relatedOpportunityWrapper=RelatedOpportunityController.getRelatedOpps(opps[2].id);
        Test.stopTest();
        System.assertEquals(true,relatedOpportunityWrapper.idVal!=null);
    } 
    @isTest static void testGetAllParentOpp() {    
        Test.startTest();
        List<Opportunity> opps=[Select id from Opportunity Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        RelatedOpportunityWrapper relatedOpportunityWrapper=RelatedOpportunityController.getRelatedOpps(opps[3].id);
        Test.stopTest();
        System.assertEquals(true,relatedOpportunityWrapper.idVal!=null);
    } 
}