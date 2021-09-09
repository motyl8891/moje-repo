/****************************************************************
* @author:Manu Singhal
* @date: 21-06-2019
* @User Story: 1032
* @description: This class is test class for CampaignMemberTriggerHelper
*****************************************************************/
@isTest(seeAllData = false)
private class CampaignMemberTriggerHelperTest 
{
    /******************************************************************* 
* @author: Manu Singhal
* @date: 21-06-2019 
* @description: This is a test method for addStatustoCampaignMembers.
********************************************************************/
    @isTest
    public static void addStatustoCampaignMembersTest()
    {
        List <CampaignMember> cmList = new List <CampaignMember>();
        List <Campaign> campList = new List <Campaign>();
          //Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          Account acc;
        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser2){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;  
        } 
        
        Contact con = (Contact)TestDataGenerator.createSObject(new Contact(FirstName = 'First', LastName = 'Last', Email = 'azaza@test.com', MailingCountry = 'Sweden'));
        con.AccountId = acc.id;
        insert con;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id, UserName = GlobalConstants.MarketoUserName),true);
        Campaign camp1 = new Campaign();
        camp1.Name = 'Test Camp1';
        camp1.CurrencyIsoCode = 'SEK';
        camp1.Type = GlobalConstants.OPERATIONAL;
        Campaign camp2 = new Campaign();
        camp2.Name = 'Test Camp2';
        camp2.CurrencyIsoCode = 'SEK';
        camp2.Type = GlobalConstants.LIVEEVENT;
        Campaign camp3 = new Campaign();
        camp3.Name = 'Test Camp3';
        camp3.CurrencyIsoCode = 'SEK';
        camp3.Type = GlobalConstants.WEBPERSONALIZATION;
        campList.add(camp1);
        campList.add(camp2);
        campList.add(camp3);
        System.runAs(testUser1)
        {  
            insert campList;  
            CampaignTriggerHelper.addCMStatustoCampaign(campList);
        }
        System.runAs(testUser)
        {
            CampaignMember cMember1 = new CampaignMember();
            cMember1.CampaignId = camp1.Id;
            cMember1.status = GlobalConstants.MEMBER;
            cMember1.ContactId = con.id;
            CampaignMember cMember2 = new CampaignMember();
            cMember2.CampaignId = camp2.Id;
            cMember2.CurrencyIsoCode = 'SEK';
            cMember2.ContactId = con.id;
            CampaignMember cMember3 = new CampaignMember();
            cMember3.CampaignId = camp3.Id;
            cMember3.CurrencyIsoCode = 'SEK';
            cMember3.ContactId = con.id;
            cmList.add(cMember1);
            cmList.add(cMember2);
            cmList.add(cMember3);  
            insert cmList;
            Test.startTest();
            CampaignMemberTriggerHandler.OnBeforeInsert(cmList);
            CampaignMemberTriggerHelper.addStatustoCampaignMembers(cmList);
            CampaignMemberTriggerHelper.addStatustoCampaignMembers(null);
            Test.stopTest();
            CampaignMember campMember  =  [Select Status from CampaignMember where id =:cMember1.id Limit 1];
            System.assertEquals('Sent',campMember.Status );
        }
    }
}