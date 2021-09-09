@isTest
public class ProposalMessageControllerTest {
	@isTest
    public static void getProposalIdForDevTypeTest(){
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            //U-1903
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
            crg.MarketArea__c = GlobalConstants.MELA;
            crg.CRG_ID__c='HW1234';
            crg.Name='testCRG';
            insert crg;
           
			acc = new Account();
            acc.Name = 'Test Account';
            acc.SAP_S2P_ID__c=String.valueOf(1);
            acc.CurrencyIsoCode = 'SEK';
            acc.Visible__c = true;
            acc.Customer_Tier__c = 'Tier 1';
            acc.CustomerReportingGroup__c= crg.id;
            insert acc;
               // acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                //insert acc;
            } 

            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500,MarketArea__c='MELA'));  
            insert opp;
        	opp.MarketArea__c='MELA';
			update opp;
            Id ppRecordTypeId = GlobalConstants.Premium_Proposal_Record_Type_Id; //U-1903
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(
                new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true, recordTypeId=ppRecordTypeId));
            insert prop;  
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
        	Deviation__c devC=new Deviation__c(Proposal__c=prop.id,BusinessArea__c='BDGS',DeviationType__c='Comparison Price',Product_Group__c='Evolved Pack Core');
        	insert devC;
            //DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            //insert devtype;
        try{
        	ProposalMessageController.getProposalIdForDevType(null);    
        }catch(Exception e){  }
        String message =ProposalMessageController.getProposalIdForDevType(prop.id);
        System.assertEquals('For MELA BDGS Comparison Price: Check if Pricing KPI is as agreed upon',message);
    }
}