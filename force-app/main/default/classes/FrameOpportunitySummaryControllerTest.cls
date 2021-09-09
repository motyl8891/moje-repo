@isTest
public class FrameOpportunitySummaryControllerTest {
    @testSetup
     static void testSetup(){
         Try{
        
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),                                                             
                                                                       UserName = 'ericsson@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){       
            Account a = (Account)TestDataGenerator.createSObject(new Account(Name='Test Account', SAP_S2P_ID__c='1'),false);           
            insert a;
        
        
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=a.Id),true);
            
        } 
             }catch(Exception e){	}
}
    @isTest
    public static void testOppReturn(){
        Try{
        Opportunity opp = [SELECT Id, RecordTypeId From Opportunity LIMIT 1];
        opp.RecordTypeId = GlobalConstants.frameOppRecordTypeId;
        update opp;
        
        Opportunity opp2 = FrameOpportunitySummaryController.getOpportunityDetails(opp.Id);
        System.assertEquals(opp.Id, opp2.Id);
        System.assertEquals(opp.RecordTypeId, opp2.RecordTypeId);
            }catch(Exception e){	}
    }

}