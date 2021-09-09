/****************************************************************
* @author: Shubham Kadam 
* @date: 14-09-2020
* @User Story: U-1989, U-1924
* @description: This class is a test class for S2WRecordSharingHelper
*****************************************************************/
@isTest
public class S2WRecordSharingHelperTest {
    
    /****************************************************************
* @author: Shubham Kadam 
* @date: 14-09-2020
* @description: This method is a test method for S2WRecordSharingWithMembers
*****************************************************************/
    @isTest
    public static void S2WRecordSharingWithMembersTest()
    {
        try 
        { 
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;           
            Account acc;
            
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson778@test.com'+System.currentTimeMillis()),true);
            
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='Test Opp',AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Forecast__c='Exclude', Anticipated_Deal_Value__c = 500, 
                                                                                           Description='test', CloseDate= system.today()));  
            insert opp;
            
            Strategy2Win__c s2w = new Strategy2Win__c();
            s2w.Opportunity__c = opp.Id;
            s2w.Commercials__c = 'Test';
            s2w.CompetitorAnalysisHowToBeat__c = 'Test';
            s2w.CustomerDecisionMakers__c = 'Test';
            s2w.CustomerKIEvaluationCriteria__c = 'Test';
            s2w.Fulfillment__c = 'Test';
            s2w.NegotiationCloseDealPlan__c = 'Test';
            s2w.OpportunityCompellingEvent__c = 'Test';
            s2w.Solution__c = 'Test';
            s2w.WhyEricssonValueProposition__c = 'Test';
            insert s2w;
            
            Employee__c empObj = new Employee__c(
                Name = 'test emp',                                      
                First_Name__c = 'test',                                    
                Salesforce_User__c = testUser.Id,                          
                Last_Name__c = 'emp',                                    
                Email__c = 'ericsson777@test.com',                       
                Status__c = 'Active',
                Signum__c = 'test1234'                                     
            );
            insert empObj;
            
            Employee__c empObj1 = new Employee__c(
                Name = 'test emp',                                      
                First_Name__c = 'test',                                    
                Salesforce_User__c = testUser1.Id,                          
                Last_Name__c = 'emp',                                    
                Email__c = 'ericsson778@test.com',                       
                Status__c = 'Active',
                Signum__c = 'test1235'                                     
            );
            insert empObj1;
            
            Opportunity_Sales_Team__c ostObj = new Opportunity_Sales_Team__c(
                Opportunity__c = opp.Id,
                Employee__c = empObj.Id,
                Role__c = 'ACR',
                Primary__c = true
            );
            insert ostObj;
            
            Opportunity_Sales_Team__c ostObj1 = new Opportunity_Sales_Team__c(
                Opportunity__c = opp.Id,
                Employee__c = empObj1.Id,
                Role__c = 'CSR',
                Primary__c = true
            );
            insert ostObj1;
            
            Sales_Decision_Record__c sdrObj = new Sales_Decision_Record__c(
                Name = 'SDP2',
                Sales_Decision_Type__c = 'SDP2 Submit Proposal',
                Sales_Decision_Date__c = Date.valueOf('2020-09-15'),
                Opportunity__c = opp.Id
            );
            insert sdrObj;
            
            Sales_Decision_Maker__c sdmObj1 = new Sales_Decision_Maker__c(
                Approver_Role__c = 'Commercials; Fulfillment; Solution',
                Approver_Name__c = testUser1.Id,
                Approval_Status__c = 'To be Requested',
                Sales_Decision_Record__c = sdrObj.Id
            );
            insert sdmObj1;
            
            Sales_Decision_Maker__c sdmObj2 = new Sales_Decision_Maker__c(
                Approver_Role__c = 'KAM; CU Head',
                Approver_Name__c = testUser.Id,
                Approval_Status__c = 'To be Requested',
                Sales_Decision_Record__c = sdrObj.Id
            );
            insert sdmObj2;
            
            s2w.OpportunityCompellingEvent__c = '-test\n-test\n-test';
            update s2w;
            
            set<ID> oppSetID=new set<ID>();
            oppSetID.add(opp.Id);
            
            Test.startTest();
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
            S2WRecordSharingHelper.S2WRecordSharingWithMembers(null);
            delete sdmobj2;
            delete ostObj1;
            Test.stopTest();
        }    
        catch (DMLException e) {
        }
    }
}