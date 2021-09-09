@isTest
public class CustomerUnitATSRecalcBatchTest {
    
    @isTest public static void executeTest(){
        Try{
            Account acc;
            List<account> accList = new List<account>();
            
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.Requires_ATS_Batch_Recalculation__c = true;
            	accList.add(acc);
                insert accList;
            }
            
            Test.startTest();
            Database.executeBatch(new CustomerUnitATSRecalcBatch());
            CustomerUnitATSRecalcBatchScheduler.scheduleBatches();
            Test.stopTest();
        }
        catch(Exception e){	}
    } 
}