@isTest
public class AccountUtilsTest {
    
	@testSetup
	static void createTestData(){
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id, UserName = 'ericsson@test.com'+System.currentTimeMillis()),true);
		System.runAs(testUser){       
            Account a = (Account)TestDataGenerator.createSObject(new Account(Name='Test Account', SAP_S2P_ID__c='12345'),true);
        }
	}
    
    @isTest
    static void testGetAccountInfoBySAPId(){
        
        Account a = [SELECT SAP_S2P_ID_Number__c FROM Account LIMIT 1];
        Decimal sapId = [SELECT SAP_S2P_ID_Number__c FROM Account LIMIT 1].SAP_S2P_ID_Number__c;
        Set<Decimal> accSet = new Set<Decimal>();
        accSet.add(sapId);
        List<Account> returnedAccList = AccountUtils.getAccountInfoBySAPid(accSet);
        Account testAccount = returnedAccList[0];
        System.assertEquals(a.SAP_S2P_ID_Number__c,testAccount.SAP_S2P_ID_Number__c);
    }
}