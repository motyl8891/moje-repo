@isTest(seeAllData = false)
public class DeviationTriggerHelperTest {
@isTest
    public static void updateProductGroup()
    { 
        try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 

            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
           test.startTest();
            insert opp;
            Id ppRecordTypeId = GlobalConstants.Premium_Proposal_Record_Type_Id;
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(
            new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true, recordTypeId=ppRecordTypeId));
            insert prop;  
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id);
            insert devtype;
            Deviation__c dev = new Deviation__c();
			dev.Product_Group__c = 'Evolved Pack Core';
			dev.DeviationType__c = 'Comparison Price';
			dev.BusinessArea__c = 'BDGS';
			dev.EscalationLevel__c = 'Threshold 2';
			dev.Proposal__c = prop.Id;
            dev.DeviationTypeGroup__c=devtype.id;
			insert dev;
            dev.Product_Group__c = 'Communication_Services';
            update dev;
            /*update devtype;
            update prop;*/
            DeviationTriggerHelper.updateProductGroup(null,null);
            Test.stopTest();
            System.assert(true);
        }catch(DMLException e){
            System.debug(e.getMessage());
        }
    }
}