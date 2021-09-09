@isTest
public class Territorry2ControllerTest {
  @isTest
    public static void runTerritoryAssignmentRulesTest(){
        
         User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        Account acc;
         List<id> accIdSet = new List<id>(); 
        test.startTest();
          Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
        System.runAs(testUser){
            acc= (Account)TestDataGenerator.createSObject(new Account(), false);
            acc.name='Acc1';
           insert acc;
        }
        accIdSet.add(acc.id);
        Territorry2Controller.runTerritorryRuleFuture(accIdSet,userinfo.getSessionId());
         test.stopTest();
    }
    
}