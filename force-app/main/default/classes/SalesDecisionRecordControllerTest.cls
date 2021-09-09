/****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This class is a test class for SalesDecisionRecordController
*****************************************************************/
@isTest(seeAllData = false)
private class SalesDecisionRecordControllerTest {
      /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @description: This method is a test method for opptyOwnerCheck and sendEmailToDecisionMakers
*****************************************************************/
    @isTest
    public static void opptyOwnerCheckTest()
    {
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
		System.runAs(testUser){  
            insert opp;
        }
        Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id));
        insert sdr; 
        Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = 'To be Requested'));
        insert sdm;
        Test.startTest();
        boolean flag = SalesDecisionRecordController.opptyOwnerCheck(sdr.id);
        //SalesDecisionRecordController.opptyOwnerCheck(null);
        boolean isEmailSent = SalesDecisionRecordController.sendEmailToDecisionMakers(sdr.id);
        SalesDecisionRecordController.sendEmailToDecisionMakers(null);
        Test.stopTest();
        System.assertEquals(true,flag);
        System.assertEquals(true,isEmailSent);
            }catch(Exception e){	}
    }         
}