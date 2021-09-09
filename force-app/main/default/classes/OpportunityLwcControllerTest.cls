@isTest
public class OpportunityLwcControllerTest {
    
    public static testMethod void getOppsTest()
    { 
        try{
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
            Account acc = (Account)TestDataGenerator.createSObject(new Account(),false);
            crg.CRG_ID__c = '100001';
            crg.MarketArea__c = 'MANA';
            System.runAs(testUser){
                insert crg;
                acc.CustomerReportingGroup__c = crg.Id;
                insert acc;
            }
            Test.startTest();
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777888999', 
                                                                                           Locked_To_PP__c = true, Description = 'test desc'));
            insert opp;
            
            
            Purpose__c pr = new Purpose__c(Name = 'Other unclear purpose',RiskValue__c = 8);
            insert pr;
            
            Purpose__c pr2 = new Purpose__c(Name = 'Mobile Banking');
            pr2.RiskValue__c = 3;
            insert pr2;
            
            Secondary_Approval__c sc = new Secondary_Approval__c();
            sc.Opportunity__c = opp.Id;
            sc.MainPurpose__c = 'Other unclear purpose';
            sc.Approval_Status__c = GlobalConstants.APPROVED;
            sc.Approval_Rejection_Reason__c = GlobalConstants.APPROVED;
            insert sc;
            String str=sc.Id;
            OpportunityLwcController.getOpps(str);
            OpportunityLwcController.UpdateSecondaryApproval( sc.id,  'test',  true);
            OpportunityLwcController.UpdateSecondaryApproval( sc.id,  'test',  false);
            sc.Approval_Rejection_Reason__c = GlobalConstants.Approvedwithcondition;
            update sc;
            OpportunityLwcController.UpdateSecondaryApproval( sc.id,  'test',  true);
            OpportunityLwcController.UpdateSecondaryApproval( sc.id,  'test',  false);
            sc.Approval_Rejection_Reason__c = GlobalConstants.DismissedbySBteam;
            update sc;
            OpportunityLwcController.UpdateSecondaryApproval( sc.id,  'test',  true);
            OpportunityLwcController.UpdateSecondaryApproval( sc.id,  'test',  false);
            Test.stopTest();
        }catch(DMLException e){
            System.debug(e.getMessage());
        }
    }
}