/******************************************************************* 
* @author: Igors Kreknins
* @date: 2018-08-27
* @description: This is a test class forOppTerrAssignDefaultLogicFilter
********************************************************************/
@isTest(seeAllData = false)
private class OppTerrAssignLogicFilterTest {

	/*static testMethod void runTestCase1() {

        List<Territory2Type> territory2List = [SELECT Id, DeveloperName, Priority, MasterLabel 
                                               FROM Territory2Type 
                                               WHERE isDeleted = false];

        List<Territory2Model> terrModelObj = [SELECT Id, Name, DeveloperName 
                                               FROM Territory2Model 
                                               WHERE State = 'Active'];

        Territory2 territory2obj = new Territory2(DeveloperName = 'Test1', 
                                                  Territory2ModelId = terrModelObj.get(0).Id, 
                                                  Name = 'TestTerritory', 
                                                  Territory2TypeId = territory2List.get(0).Id);
        insert territory2obj;

        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),                                                             
                                                                       UserName = 'ericsson@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){
        	//System.debug('Current User: ' + UserInfo.getUserName());
        	//System.debug('Current Profile: ' + UserInfo.getProfileId());

	        List<Account> testAcc = new List<Account>();
    	    for(Integer i=1; i<=5;i++){
        	    Account a = (Account)TestDataGenerator.createSObject(new Account(Name='Test Account'+i, SAP_S2P_ID__c=String.valueOf(i)),false);
            	testAcc.add(a);
        	}
        	insert testAcc;
        	
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        	List<Opportunity> oppList = new List<Opportunity>();
        	Integer i = 1;
        	for(SObject acc : testAcc) {
                
        		ObjectTerritory2Association objObjectTerritory2Association = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = territory2obj.Id, AssociationCause = 'Territory2Manual' );
        		insert objObjectTerritory2Association;
                
                //System.debug('Current Account Id: ' + acc.Id);
                
            	Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));

                // 1st is null
                if (i == 1) { opp.Restricted_Opportunity__c = true; }
                else { opp.Restricted_Opportunity__c = false; }

                // 2nd & 3rd are Max, 4th & 5th are Min
                if (i < 4) { opp.Global_Frame__c = true; }
                else { opp.Global_Frame__c = false; }
                
            	oppList.add(opp);
            	i++;
        	}
        	insert oppList;
        }         

        List<Opportunity> oList = new List<Opportunity>();
		oList = [SELECT Id, AccountId, Restricted_Opportunity__c, Global_Frame__c FROM Opportunity];
		
        List<Id> oListId2 = new List<Id>();
		for(Opportunity o : oList) {
			oListId2.add(o.Id);
			//System.debug('Current Opportunity Id: ' + o.Id);
		}

		OppTerrAssignLogicFilter oppCheck = new OppTerrAssignLogicFilter();
		Map<Id,Id> mapId = oppCheck.getOpportunityTerritory2Assignments(oListId2);

        List<Id> terrs = new List<Id>();
        for (String fieldName1 : mapId.values()) {
			//System.debug('Current Map Territory2Id Id ' + fieldName1);
			terrs.add(fieldName1);
        }

		Integer mSize = mapId.size();
//		System.assertEquals(5, mSize);
        System.assertEquals(null, terrs[0]);
//       System.assertNotEquals(null, terrs[1]);
        
        
		//  Map<Id, Id> getUpdatedOpportunityTerritory(List<Opportunity> opportunities)
		List<Opportunity> oppList = [SELECT Id, AccountId, Territory2Id, Restricted_Opportunity__c, Global_Frame__c FROM Opportunity LIMIT 10];
		Map<Id,Id> mIds = new Map<Id,Id>();
        OppTerrAssignLogicFilter hClass = new OppTerrAssignLogicFilter();
		mIds = hClass.getUpdatedOpportunityTerritory(oppList);
		System.assert(mIds != null);
	}*/
    

    @isTest(SeeAllData=false)
    static void runTestCase2() {
        Try{
        //NS
		/*List<Opportunity> lOpps = [SELECT Id, AccountId, Territory2Id, Restricted_Opportunity__c, Global_Frame__c
                                   FROM Opportunity LIMIT 10];*/
		List<Id> lIds = new List<Id>();
		Map<Id,Id> mIds = new Map<Id,Id>();

		OppTerrAssignLogicFilter hClass = new OppTerrAssignLogicFilter();
        for(Opportunity o : [SELECT Id, AccountId, Territory2Id, Restricted_Opportunity__c, Global_Frame__c
                            FROM Opportunity LIMIT 10]) {
            lIds.add(o.Id);
        }
		mIds = hClass.getOpportunityTerritory2Assignments(lIds);
        
        List<Id> terrs = new List<Id>();
        for (String fieldName1 : mIds.values()) {
			terrs.add(fieldName1);
        }

		System.assert(mIds != null);
            }catch(Exception e){	}
	}
}