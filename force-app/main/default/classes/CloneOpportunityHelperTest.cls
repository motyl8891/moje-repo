/** 
 * Test class for CloneOpportunityHelperTest 
 * Added to include in the package 2019-07-01
 */
@isTest(seeAllData=false)
private without sharing class CloneOpportunityHelperTest { 
	private static final Id INTEGRATION_PROFILE_ID = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME);
	
	private static final String USERNAME = 'ericsson777@test.com' + System.currentTimeMillis();
    //U-1903
	/*private static final RecordType STANDARD_OPPTY_RECORDTYPE =  [SELECT Id, DeveloperName 
	                                                              FROM RecordType 
	                                                              WHERE DeveloperName =:System.Label.Record_Type_Developer_Name_Standard_Opportunity_Create  limit 1];*/
    private static final Id STANDARD_OPPTY_RECORDTYPE = GlobalConstants.standardCreateOppRecordTypeId;
    /*private static final RecordType FRAME_AMENDMENT_OPPTY_RECORDTYPE = [SELECT Id, DeveloperName
                                                FROM RecordType
                                                WHERE DeveloperName =: System.Label.Record_Type_Developer_Name_Frame_Amendment_Opportunity_Create Limit 1];*/
    private static final Id FRAME_AMENDMENT_OPPTY_RECORDTYPE = GlobalConstants.frameCreateOppRecordTypeId;
	/**
	 * Method that tests if Cloned Opportunity fields will reset
	 */
	@isTest
	static void test_clonedOpptyReset() {
		Account acc;
		User testUser = (User)TestDataGenerator.createSObject(
				new User(ProfileId = INTEGRATION_PROFILE_ID, UserName = USERNAME), true);
		System.runAs(testUser) {
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			Database.insert(acc);
		}
        
		Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        //U-1903
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(
		                      new Opportunity(RecordTypeId = STANDARD_OPPTY_RECORDTYPE,   
		                                      AccountId = acc.Id,
		                                      Proposal_Ready_for_Decision__c = true,
		                                      Auto_Rejection_Reason__c = 'Test',
		                                      Salesforce_SDP3_Status__c = 'Pending',
		                                      Salesforce_SDP2_Status__c = 'Pending',
		                                      Legacy_SDP2_Status__c = 'Test',
		                                      Legacy_SDP3_Status__c = 'Test',
		                                      Proposal_Deal_Value__c = 1111,
                                              Proposal_Gross_Price__c = 2222,
                                              Deal_Value__c = 100,
                                              Amount = 4567
		                                     ));

		Database.insert(opp);

		Opportunity opp2 = opp.clone();
        System.assertEquals(true, opp2.Proposal_Ready_for_Decision__c);
		System.assertEquals('Test', opp2.Auto_Rejection_Reason__c);
		System.assertEquals('Pending', opp2.Salesforce_SDP3_Status__c);
		System.assertEquals('Pending', opp2.Salesforce_SDP2_Status__c);
		System.assertEquals('Test', opp2.Legacy_SDP2_Status__c);
		System.assertEquals('Test', opp2.Legacy_SDP3_Status__c);
		System.assertEquals(1111, opp2.Proposal_Deal_Value__c);
        System.assertEquals(2222, opp2.Proposal_Gross_Price__c);
		System.assertEquals(4567, opp2.Amount);
        
        List<Opportunity> newOpportunities = new List<Opportunity>();
		newOpportunities.add(opp2);
		
		//Database.insert(opp2);
        //system.debug('Cloned==>'+opp2.isclone());
        //system.debug('Opp2Rec==>'+opp2.RecordTypeId);
		Database.insert(newOpportunities);
        

		test.startTest();

        CloneOpportunityHelper.resetClonedOppties(newOpportunities);
        test.stopTest();
		 Opportunity cloneOppty = [SELECT Proposal_Ready_for_Decision__c, Auto_Rejection_Reason__c, Salesforce_SDP3_Status__c,
		                          Salesforce_SDP2_Status__c, Legacy_SDP2_Status__c, Legacy_SDP3_Status__c,Proposal_Deal_Value__c,
                                  Amount, Proposal_Gross_Price__c
		                          FROM Opportunity
		                          WHERE Id = : newOpportunities[0].Id limit 1];
		        
		System.assertEquals(false, newOpportunities[0].Proposal_Ready_for_Decision__c);
		System.assertEquals(null, newOpportunities[0].Auto_Rejection_Reason__c);
		System.assertEquals(null, newOpportunities[0].Salesforce_SDP3_Status__c);
		System.assertEquals(null, newOpportunities[0].Salesforce_SDP2_Status__c);
		System.assertEquals(null, newOpportunities[0].Legacy_SDP2_Status__c);
		System.assertEquals(null, newOpportunities[0].Legacy_SDP3_Status__c);
		System.assertEquals(null, newOpportunities[0].Proposal_Deal_Value__c);
        System.assertEquals(null, newOpportunities[0].Proposal_Gross_Price__c); 
		System.assertEquals(null, newOpportunities[0].Amount);
	}
   
    @isTest
    static void testFrameAmendmentOpp(){
        Account acc;
		User testUser = (User)TestDataGenerator.createSObject(
				new User(ProfileId = INTEGRATION_PROFILE_ID, UserName = USERNAME), true);
		System.runAs(testUser) {
              acc = (Account)TestDataGenerator.createSObject(new Account(), false);
			Database.insert(acc);
		}

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        //U-1903
		Opportunity opp = (Opportunity)TestDataGenerator.createSObject(
		                      new Opportunity(RecordTypeId = FRAME_AMENDMENT_OPPTY_RECORDTYPE,
		                                      AccountId = acc.Id,
		                                      Proposal_Ready_for_Decision__c = true,
		                                      Auto_Rejection_Reason__c = 'Test',
		                                      Salesforce_SDP3_Status__c = 'Pending',
		                                      Salesforce_SDP2_Status__c = 'Pending',
		                                      Legacy_SDP2_Status__c = 'Test',
		                                      Legacy_SDP3_Status__c = 'Test',
		                                      Proposal_Deal_Value__c = 1111,
                                              Proposal_Gross_Price__c = 2222,
                                              Amount = 4567
		                                     ));

		Database.insert(opp);
		Opportunity opp2 = opp.clone();

        System.assertEquals(true, opp2.Proposal_Ready_for_Decision__c);
		System.assertEquals('Test', opp2.Auto_Rejection_Reason__c);
		System.assertEquals('Pending', opp2.Salesforce_SDP3_Status__c);
		System.assertEquals('Pending', opp2.Salesforce_SDP2_Status__c);
		System.assertEquals('Test', opp2.Legacy_SDP2_Status__c);
		System.assertEquals('Test', opp2.Legacy_SDP3_Status__c);
		System.assertEquals(1111, opp2.Proposal_Deal_Value__c);
        System.assertEquals(2222, opp2.Proposal_Gross_Price__c);
		System.assertEquals(4567, opp2.Amount);
        
		List<Opportunity> newOpportunities = new List<Opportunity>();
		newOpportunities.add(opp2);
		

		Database.insert(newOpportunities);
        test.startTest();

        CloneOpportunityHelper.resetClonedOppties(newOpportunities);
       
		Opportunity cloneOppty = [SELECT Proposal_Ready_for_Decision__c, Auto_Rejection_Reason__c, Salesforce_SDP3_Status__c,
		                          Salesforce_SDP2_Status__c, Legacy_SDP2_Status__c, Legacy_SDP3_Status__c,Proposal_Deal_Value__c,
                                  Amount, Proposal_Gross_Price__c
		                          FROM Opportunity
		                          WHERE Id = : newOpportunities.get(0).Id limit 1];
 		test.stopTest();
		
		System.assertEquals(false, newOpportunities[0].Proposal_Ready_for_Decision__c);
		System.assertEquals(null, newOpportunities[0].Auto_Rejection_Reason__c);
		System.assertEquals(null, newOpportunities[0].Salesforce_SDP3_Status__c);
		System.assertEquals(null, newOpportunities[0].Salesforce_SDP2_Status__c);
		System.assertEquals(null, newOpportunities[0].Legacy_SDP2_Status__c);
		System.assertEquals(null, newOpportunities[0].Legacy_SDP3_Status__c);
		System.assertEquals(null, newOpportunities[0].Proposal_Deal_Value__c);
        System.assertEquals(null, newOpportunities[0].Proposal_Gross_Price__c); 
		System.assertEquals(null, newOpportunities[0].Amount);

        
    }
}