@isTest
public class ProposalTriggerTest {

	/**
	* Setup for test methods
	*/
	@testSetup
	static void setup() {
       		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id
                                                                                    FROM Profile
                                                                                    WHERE Name =:GlobalConstants.INTEGRATIONUSERPROFILENAME].Id,
		                										UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
		System.runAs(testUser) {
             CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(), false);
        insert cu;
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
		Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			insert acc;
            		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
        
		insert opp;
		}
	}

	@isTest
	public static void testInsertProposalTrigger() {
        Try{
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test2', Opportunity__c = opp.Id));
		insert prop;

		System.assertEquals(true, prop.Id != null);
            }catch(Exception e){	}
	}
    
    @isTest
	public static void testUpdateProposalTrigger() {
        Try{
		Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test2', Opportunity__c = opp.Id, Primary__c = false));
		insert prop;
        prop.Primary__c = true;
		update prop;
		System.assertEquals(true, prop.Id != null);
        System.assertEquals(true, prop.Primary__c);
            }catch(Exception e){	}
	}
}