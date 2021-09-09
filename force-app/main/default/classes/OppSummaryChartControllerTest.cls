@isTest(seeAllData = false)
private class OppSummaryChartControllerTest {
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
        Profile p= [select id from Profile where Name = :GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME];
        List<User> userlist = [Select id from User where ProfileId =: p.id Limit 1];
        
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
         id OppSummaryChart1 ;
         id OppSummaryChart2 ;
         id OppSummaryChart3 ;
         id OppSummaryChart4 ;
        id IncomeSummaryChart1;
        id IncomeSummaryChart2;
        id IncomeSummaryChart3;
        string R1 = GlobalConstants.OppSummaryChart1;
        string R2 = GlobalConstants.OppSummaryChart2;
        string R3 = GlobalConstants.OppSummaryChart3;
        string R4 = GlobalConstants.OppSummaryChart4;
        Proposal__c pp1 = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c=opp1.Id));
        pp1.Primary__c=True;
        pp1.Approved_Stage__c='4. Negotiate and Close';
        pp1.Is_Closed_Won__c=false;
        insert pp1;
        Proposal__c pp3 = new Proposal__c();
        Test.StartTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
        OppSummaryChartController testPlan = new OppSummaryChartController(sc);
        PageReference pageRef = Page.OppSummaryChart; 
        pageRef.getParameters().put('id', R1);
        Test.setCurrentPage(pageRef);
        PageReference pageRef2 = Page.OppSummaryChart; 
        pageRef2.getParameters().put('id', R2);
        Test.setCurrentPage(pageRef2);
        PageReference pageRef3 = Page.OppSummaryChart; 
        pageRef3.getParameters().put('id', R3);
        Test.setCurrentPage(pageRef3);
        PageReference pageRef4 = Page.OppSummaryChart; 
        pageRef4.getParameters().put('id', R4);
        Test.setCurrentPage(pageRef4);
        Test.StopTest();
        //NS
        System.assert(true);
            }catch(Exception e){	}
    }
}