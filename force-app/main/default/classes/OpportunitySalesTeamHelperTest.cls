/****************************************************************
	* @author: Aditya Mohapatra     
	* @date: 2019-07-18
	* @param: null
	* @description: This method will test OpportunitySalesTeamHelper Method.
	*****************************************************************/
	@isTest(seeAllData = false)
	private class OpportunitySalesTeamHelperTest {
		
		static testMethod void testOppSalesteam(){
			
			Account acc;
			User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.INTEGRATIONUSERPROFILENAME].Id,signum__c ='signum1'  ,UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
			System.runAs(testUser){ 
				acc = (Account)TestDataGenerator.createSObject(new Account(), false); 
				insert acc;
			}
			
			Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
			Opportunity op = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
			insert op;
			
			 Employee__c emp = new Employee__c(First_Name__c = 'testfirst',last_name__c = 'test last',Email__c = 'test@gmail.com',signum__c = 'signum1');
			emp.Status__c = 'Active';
			insert emp;  
		   list<Opportunity_Sales_Team__c> ostlist = new list<Opportunity_Sales_Team__c>();
				
			Opportunity_Sales_Team__c ost1 = new Opportunity_Sales_Team__c(opportunity__c = op.id,Employee__c = emp.id,role__c = 'CSR');
			
			Opportunity_Sales_Team__c ost2 = new Opportunity_Sales_Team__c(opportunity__c = op.id,Employee__c = emp.id,role__c = 'CFR');
			ostlist.add(ost1);
			ostlist.add(ost2);
			insert ostlist;
			op.CSR_Signum__c = ost1.Employee__r.signum__c;
			op.Team_Assignment__c = ost1.role__c;
			op.CFR_Signum__c = ost2.Employee__r.signum__c;
			update op;
			
			OpportunitySalesTeamHelper.updateSalesteamOnOpportunity(ostlist);
			OpportunitySalesTeamHelper.insertOpportunityTeamMembersOnOpportunity(ostlist); 
		   /* Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
			Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
			insert opp;
			insert opp1;*/
			op.StageName = GlobalConstants.oppStageClosedLost;
			update op;
			Opportunity_Sales_Team__c ost = new Opportunity_Sales_Team__c(opportunity__c = op.id,Employee__c = emp.id,role__c = 'CSR');
			Opportunity_Sales_Team__c ost3 = new Opportunity_Sales_Team__c(opportunity__c = op.id,Employee__c = emp.id,role__c = 'CSR');
			Opportunity_Sales_Team__c ost4 = new Opportunity_Sales_Team__c(opportunity__c = op.id,Employee__c = emp.id,role__c = 'CSR');
			insert ost3;
            ostlist.add(ost);
			ostlist.add(ost3);
			 ostlist.add(ost4);
			 
			String msg;
			try{ insert ostlist;}
			catch(Exception e)
			{
				msg = e.getMessage();
			}
			OpportunitySalesTeamHelper.restrictSalesTeamOnClosedOppty(ostlist);
		   OpportunitySalesTeamHelper.restrictSalesTeamOnClosedOppty(null);
			ost3.role__c = 'Contract Manager';
			update ost3;      
		
			OpportunitySalesTeamHelper.clearSalesTeamAssignmentOnOppty(new List<Opportunity_Sales_Team__c>{ ost3, ost4});
			delete ost3;
			
		}
			@isTest
		public static void updatePrimaryCore3OnSDRTest()
		{
			Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;        
			User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
			Account acc;
			System.runAs(testUser){
				acc=(Account)TestDataGenerator.createSObject(new Account(), false);
				insert acc;
			} 
			CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
			crg.MarketArea__c = GlobalConstants.MELA;
			crg.CRG_ID__c='HW1234';
			crg.Name='testCRG';
			insert crg;
			acc.CustomerReportingGroup__c=crg.id;
			update acc;
			Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
			Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
			opp.KAM__c = testUser.id;
			opp.GCU_Head__c = testUser.id;
			opp.CU_Head__c = testUser.id;
			opp.Frame_End_Date__c = System.today()+1;
			opp.Frame_Start_Date__c = System.today()-1;
			System.runAs(testUser){
				insert opp;
			} 
			Employee__c testEmp = (Employee__c)TestDataGenerator.createSObject(new Employee__c(Signum__c = 'testuser', Email__c = 'testuser@testuser.com', name = 'testuser', Status__c = GlobalConstants.Active)); 
			insert testEmp;
			Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS));
			insert sdr;
			List<Opportunity_Sales_Team__c> oppSalesTeamList = new List<Opportunity_Sales_Team__c>();        
			Opportunity_Sales_Team__c st1 = new Opportunity_Sales_Team__c();
			st1.Opportunity__c  = opp.id;
			st1.Role__c  = GlobalConstants.ACR;
			st1.Employee__c = testEmp.id;
			st1.Primary__c = true;
			Opportunity_Sales_Team__c st2 = new Opportunity_Sales_Team__c();
			st2.Opportunity__c  = opp.id;
			st2.Role__c  = GlobalConstants.CSR;
			st2.Employee__c = testEmp.id;
			st2.Primary__c = true;
			Opportunity_Sales_Team__c st3 = new Opportunity_Sales_Team__c();
			st3.Opportunity__c  = opp.id;
			st3.Role__c  = GlobalConstants.CFR;
			st3.Employee__c = testEmp.id;
			st3.Primary__c = true;
			
			oppSalesTeamList.add(st1);
			oppSalesTeamList.add(st2);
			oppSalesTeamList.add(st3);
			insert oppSalesTeamList;
			Test.startTest();
			OpportunitySalesTeamHelper.updatePrimaryCore3OnSDR(oppSalesTeamList);
			OpportunitySalesTeamHelper.updatePrimaryCore3OnSDR(null);
			Test.stopTest();
		}
	}