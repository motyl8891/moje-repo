/*******************************************************************
* @author: Anurkiti
* @date: 2019-13-06
* @description: U-0900
				1. Test Class for CloneOpportunityController

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			23-07-2020				U-1903 - Replaced Hard coded values by global constants

********************************************************************/
@isTest
public class CloneOpportunityControllerTest {
    
    @testSetup static void setup() {  
         //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            Account acc;
            System.runAs(testUser){
                acc= (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }

        // Create a custom price book
        PriceBook2 customPB = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        customPB.Name = GlobalConstants.PriceBook2Name_Default;	//1903
        customPB.IsActive = true;
        insert customPB; 
        Test.startTest();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp1.RecordTypeId =GlobalConstants.frameOppRecordTypeId;   //U-1903
        opp1.Forecast__c = GlobalConstants.EXCLUDE;        //U-1903
        insert opp1;
        Test.stopTest();
    }
    
	@isTest
    public static void  isValidStageTest(){
        Try{
        List<Opportunity> opList = [SELECT ID FROM Opportunity];
        Boolean value;
        Test.startTest();
        if(opList.size() > 0) {
            value = CloneOpportunityController.isValidStage(opList.get(0).Id);
        }
        CloneOpportunityController.isValidStage(null);
        Test.stopTest();
        system.assertEquals(True, value); //NS P2 Fix - 
            }catch(Exception e){	}
    }   
        


}