@isTest
public class OC_TR_ConstantsTest {

    @isTest(seeAllData = false)
    static void testConstantsInitialization(){
        Test.startTest();
        OC_TR_Constants.testConstants();  
        Database.executeBatch(new OC_TR_SendRemindersToGenerateTimeRecords(),500); 
        Test.stopTest();
    }
    
}