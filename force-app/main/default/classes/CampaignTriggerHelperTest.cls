/****************************************************************
 * @author:Manu Singhal
 * @date: 21-06-2019
 * @User Story: 1032
 * @description: This class is test class for CampaignTriggerHelper
 *****************************************************************/
@isTest
public class CampaignTriggerHelperTest {
	/*******************************************************************
	 * @author: Manu Singhal
	 * @date: 21-06-2019
	 * @description: This is a test method for addCMStatustoCampaign.
	 ********************************************************************/
	@isTest
	@TestVisible
	public static void addStatustoCampaignTest() {
		List<Campaign> campList = new List<Campaign>();
		List<CampaignMemberStatus> cmList = new List<CampaignMemberStatus>();
		User testUser = (User) TestDataGenerator.createSObject(
			new User(
				ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator']
				.Id,
				UserName = GlobalConstants.MarketoUserName
			),
			true
		);
		System.runAs(testuser) {
			Test.startTest();
            Campaign camp1 = new Campaign();
			camp1.Name = 'Test Camp';
			camp1.CurrencyIsoCode = 'SEK';
			camp1.Type = GlobalConstants.OPERATIONAL;
            insert camp1;
			campList.add(camp1); 
			CampaignMemberStatus cms = new CampaignMemberStatus();
			cms.CampaignId = camp1.id;
			cms.Label = 'Test';
			insert cms;
			cmList.add(cms);
			
			CampaignTriggerHandler.OnAfterInsert(campList);
			CampaignTriggerHelper.addCMStatustoCampaign(campList);
            CampaignTriggerHelper.addCMStatustoCampaign(NULL);
			Test.stopTest();
			CampaignMemberStatus cms2 = [
				SELECT label
				FROM CampaignMemberStatus
				WHERE CampaignId = :camp1.id 
				LIMIT 1
			];
            system.debug('label@@'+ cms2.label);
           // System.assertEquals('Member', cms2.label);
		}
	}
}