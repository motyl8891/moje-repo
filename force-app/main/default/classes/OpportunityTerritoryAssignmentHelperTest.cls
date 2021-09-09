/**
 * Test class used for OpportunityTerritoryAssignmentHelper class
 */
@isTest
public class OpportunityTerritoryAssignmentHelperTest {

    /**
     * Setup for test methods
     * @return
     */
    @testSetup static void setup() {

        List<Territory2Type> territory2List = [SELECT Id, DeveloperName, Priority, MasterLabel
                                               FROM Territory2Type
                                               WHERE isDeleted = false AND (Priority > 150 OR Priority < 50) limit 2];

        List<Territory2Model> terrModelObj = [SELECT Id, Name, DeveloperName
                                              FROM Territory2Model
                                              WHERE State = 'Active'];

        Territory2 territory2obj = new Territory2(DeveloperName = 'Test1',
                Territory2ModelId = terrModelObj.get(0).Id,
                Name = 'TestTerritory',
                Territory2TypeId = territory2List.get(0).Id);
        insert territory2obj;

        Territory2 territory2obj2 = new Territory2(DeveloperName = 'Test2',
                Territory2ModelId = terrModelObj.get(0).Id,
                Name = 'TestTerritory',
                Territory2TypeId = territory2List.get(1).Id);
        insert territory2obj2;

        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
            ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = territory2obj.Id, AssociationCause = 'Territory2Manual' );
            insert objObjectTerritory2Association;

            ObjectTerritory2Association objObjectTerritory2Association2 = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = territory2obj2.Id, AssociationCause = 'Territory2Manual' );
            insert objObjectTerritory2Association2;

            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Restricted_Opportunity__c = true, AccountId = acc.Id, Global_Frame__c = false, Territory2Id = null));
            insert opp;
        }
    }

    /**
     * Test Method that tests if Territory changes when Global Frame is changed to True
     * @return
     */
    static testMethod void testMaxPriorityTerritoryPositive() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true); 
        Opportunity opp = [Select Global_Frame__c, Territory2Id from Opportunity limit 1];
        System.assertEquals(false, opp.Global_Frame__c);
        opp.Global_Frame__c = true;
        opp.Restricted_Opportunity__c = false;
        opp.GCU_KAM__c = testUser.id;
        opp.KAM__c = testUser.id;
        update opp;
        System.assertEquals(true, opp.Global_Frame__c);
        
        List<Id> lIds = new List<Id>();
        Map<Id,Id> mIds = new Map<Id,Id>();
        OppTerrAssignLogicFilter hClass = new OppTerrAssignLogicFilter();
        
        lIds.add(opp.Id);
        mIds = hClass.getOpportunityTerritory2Assignments(lIds);
        
        List<Id> terrs = new List<Id>();
        for (String fieldName1 : mIds.values()) {
            terrs.add(fieldName1);
        }
        System.assert(mIds != null);
    }

    /**
     * Test Method that tests if Territory changes when Global Frame is changed to false
     * @return [description]
     */
    static testMethod void testMinPriorityTerritoryPositive() {
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true); 
        Opportunity opp = [Select Restricted_Opportunity__c, Global_Frame__c, Territory2Id from Opportunity limit 1];
        System.assertEquals(false, opp.Global_Frame__c);
        opp.Global_Frame__c = true;
        opp.Restricted_Opportunity__c = false;
        opp.GCU_KAM__c = testUser.id;
        opp.KAM__c = testUser.id;
        update opp;
        opp.Global_Frame__c = false;
        update opp;
        System.assertEquals(false, opp.Global_Frame__c);
    }
}