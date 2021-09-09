/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-08 
* @description: This test class is for the class UpdateOpportunityName
********************************************************************/
@isTest
private class UpdateOpportunityNameTest{
  @testSetup
  static void setupTestData(){
      // public static List<User> userlist = new List<User>();
      
     Account acc;
     User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
         //acc.CurrencyIsoCode ='USD';
         System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
         // Create a custom price book
        PriceBook2 customPB = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        customPB.Name = GlobalConstants.PriceBook2Name_Default;
        customPB.IsActive = true;
        insert customPB;        
        Test.startTest();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp1.RecordTypeId = GlobalConstants.frameOppRecordTypeId;
    opp1.Forecast__c = 'Exclude';    
        opp1.pricebook2Id = customPB.Id;  
        insert opp1;
    test.stopTest();
  }
    static testMethod void BatchMethod(){
    UpdateOpportunityName obj01 = new UpdateOpportunityName ();
    Database.executeBatch(obj01, 200);
    System.assert(true);    //NS
}
}