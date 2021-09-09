@isTest(seeAllData = false)
private class OppSummaryComponentProposalTest 
{
    private static Profile p;
    private static List<User> userlist = new List<User>();
    @isTest
     /****************************************************************
    * @author: Aditya
    * @date: 2019-05-16
    * @description: This test method will retrieve the  Primary Proposal details based on the opportunity . 
    *****************************************************************/ 
    public static void  getProposaltest()
	{
        Try{
        Profile p= [select id from Profile where Name='Ericsson Sales User'];
        List<User> userlist = [Select id from User where ProfileId =: p.id Limit 1];
        //insert testuser;
        PriceBook2 pb2 = (PriceBook2)TestDataGenerator.createSObject(new PriceBook2(), false);
        pb2.Name = GlobalConstants.PriceBook2Name_Default;
        insert pb2;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser)
		{  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp1.Forecast__c = 'Exclude';
        insert opp1;
      /*  Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp2.Forecast__c = 'Exclude';
        insert opp2;*/
        Proposal__c pp1 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp1.Id));
        pp1.Primary__c=True;
        pp1.Approved_Stage__c='4. Negotiate and Close';
        pp1.Is_Closed_Won__c=false;
       // Proposal__c pp2= (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp2.Id));
       // pp2.Primary__c=True;
        insert pp1;
        //insert pp2;
        Proposal__c pp3 = new Proposal__c();
        Proposal__c pp4 = new Proposal__c();
        Test.startTest();
        pp3=OppSummaryComponentProposalController.getProposal(opp1.id);
        pp4=OppSummaryComponentProposalController.getProposal(null);
        Test.stopTest();
        //Assert to check if pp1 is the primary Proposal
        System.assertEquals(pp1.Id, pp3.Id);
		}catch(Exception e){	}
	}
}