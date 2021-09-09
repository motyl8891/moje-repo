/**
 * Test class used for TradeComplianceHelper class
 */
@isTest
public class TradeComplianceHelperTest {

	private static final String countryH = 'testH';
	private static final String countryM = 'testM';
	private static final String countryL = 'testL';
	private static final String highRisk = 'High';
	private static final String mediumRisk = 'Medium';
	private static final String lowRisk = 'Low';

	/**
	 * Setup for test methods
	 * @return
	 */
	@testSetup static void setup() {

		Account acc;
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
		System.runAs(testUser) {
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			insert acc;
		}

		List<Country_Risk__c> countryRisk = new List<Country_Risk__c> {
			new Country_Risk__c(Name = countryH, Risk__c = highRisk),
			new Country_Risk__c(Name = countryM, Risk__c = mediumRisk),
			new Country_Risk__c(Name = countryL, Risk__c = lowRisk)
		};
		insert countryRisk;

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
		insert opp;
	}

	/**
	 * Method that tests if Sales Compliance Country Risk is set to High
	 */
	@isTest
	static void testHighRiskPositive() {

		Opportunity opp = [SELECT Id, Ship_To_Countries__c, Sales_Compliance_Country_Risk__c FROM Opportunity LIMIT 1];
		Opportunity opp2 = new Opportunity(Id = opp.Id);

		List<Opportunity> newOpportunities = new List<Opportunity> {opp};
		Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity>();
		oldOpportunitiesMap.put(opp2.Id, opp2);

		opp.Ship_To_Countries__c = countryH;
		opp2.Ship_To_Countries__c = '';
		TradeComplianceHelper.updateCountryRiskOpptys(newOpportunities, oldOpportunitiesMap);

		System.assertEquals(countryH, opp.Ship_To_Countries__c);
		System.assertEquals(highRisk, opp.Sales_Compliance_Country_Risk__c);

	}

	/**
	 * Method that tests if Sales Compliance Country Risk is set to Medium
	 */
	@isTest
	static void testMediumRiskPositive() {

		Opportunity opp = [SELECT Id, Ship_To_Countries__c, Sales_Compliance_Country_Risk__c FROM Opportunity LIMIT 1];
		Opportunity opp2 = new Opportunity(Id = opp.Id);

		List<Opportunity> newOpportunities = new List<Opportunity> {opp};
		Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity>();
		oldOpportunitiesMap.put(opp2.Id, opp2);

		opp.Ship_To_Countries__c = countryM;
		opp2.Ship_To_Countries__c = '';
		TradeComplianceHelper.updateCountryRiskOpptys(newOpportunities, oldOpportunitiesMap);

		System.assertEquals(countryM, opp.Ship_To_Countries__c);
		System.assertEquals(mediumRisk, opp.Sales_Compliance_Country_Risk__c);

	}

	/**
	 * Method that tests if Sales Compliance Country Risk is set to Low
	 */
	@isTest
	static void testLowRiskPositive() {

		Opportunity opp = [SELECT Id, Ship_To_Countries__c, Sales_Compliance_Country_Risk__c FROM Opportunity LIMIT 1];
		Opportunity opp2 = new Opportunity(Id = opp.Id);

		List<Opportunity> newOpportunities = new List<Opportunity> {opp};
		Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity>();
		oldOpportunitiesMap.put(opp2.Id, opp2);

		opp.Ship_To_Countries__c = countryL;
		opp2.Ship_To_Countries__c = '';
		TradeComplianceHelper.updateCountryRiskOpptys(newOpportunities, oldOpportunitiesMap);

		System.assertEquals(countryL, opp.Ship_To_Countries__c);
		System.assertEquals(lowRisk, opp.Sales_Compliance_Country_Risk__c);

	}

	/**
	 * Method that tests if Sales Compliance Country Risk is null if there are no countrys added to Ship To Countries
	 */
	@isTest
	static void testNoShipToCountry() {

		Opportunity opp = [SELECT Id, Ship_To_Countries__c, Sales_Compliance_Country_Risk__c FROM Opportunity LIMIT 1];
		Opportunity opp2 = new Opportunity(Id = opp.Id);

		List<Opportunity> newOpportunities = new List<Opportunity> {opp};
		Map<ID, Opportunity> oldOpportunitiesMap = new Map<ID, Opportunity>();
		oldOpportunitiesMap.put(opp2.Id, opp2);

		opp.Ship_To_Countries__c = '';
		opp2.Ship_To_Countries__c = '';
		TradeComplianceHelper.updateCountryRiskOpptys(newOpportunities, oldOpportunitiesMap);

		System.assertEquals('', opp.Ship_To_Countries__c);
		System.assertEquals(null, opp.Sales_Compliance_Country_Risk__c);

	}
}