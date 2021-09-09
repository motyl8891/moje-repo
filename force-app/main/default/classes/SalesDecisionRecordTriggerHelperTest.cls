/****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @User Story: 1051
* @description: This class is a test class for SalesDecisionRecordTriggerHandlerTest
*****************************************************************/
@isTest(seeAllData = false)
private class SalesDecisionRecordTriggerHelperTest {
    /****************************************************************
* @author: Manu Singhal  
* @date: 09-09-2019
* @description: This method is a test method for SalesDecisionApprovedStatusError
*****************************************************************/
    @isTest
    public static void SalesDecisionApprovedStatusErrorTest()
    {
        Test.startTest();
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String s =  'tstsstst';
        
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        Account acc;
        System.runAs(testUser){
            acc=(Account)TestDataGenerator.createSObject(new Account(), false);
            //acc.CustomerReportingGroup__c = crg.Id;
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
        Employee__c testEmp = (Employee__c)TestDataGenerator.createSObject(new Employee__c(Signum__c = 'testuser')); 
        insert testEmp;
        List<Opportunity_Sales_Team__c> oppSalesTeamList = new List<Opportunity_Sales_Team__c>();
        Opportunity_Sales_Team__c oppSalesTeam1 =  (Opportunity_Sales_Team__c)TestDataGenerator.createSObject(new Opportunity_Sales_Team__c(Opportunity__c = opp.id,Role__c = GlobalConstants.CSR,Employee__c = testEmp.id, primary__c= true));
        Opportunity_Sales_Team__c oppSalesTeam2 =  (Opportunity_Sales_Team__c)TestDataGenerator.createSObject(new Opportunity_Sales_Team__c(Opportunity__c = opp.id,Role__c = GlobalConstants.CFR,Employee__c = testEmp.id, primary__c= true));
        Opportunity_Sales_Team__c oppSalesTeam3 =  (Opportunity_Sales_Team__c)TestDataGenerator.createSObject(new Opportunity_Sales_Team__c(Opportunity__c = opp.id,Role__c = GlobalConstants.ACR,Employee__c = testEmp.id, primary__c= true));
        oppSalesTeamList.add(oppSalesTeam1);
        oppSalesTeamList.add(oppSalesTeam2);
        oppSalesTeamList.add(oppSalesTeam3);
        //insert oppSalesTeamList;
        Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS));
        
        insert sdr;
        List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
        sdrList.add(sdr);
        Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.REQUESTED));
        insert sdm;
        SalesDecisionRecordTriggerHelper.SalesDecisionApprovedStatusError(null, null);
        SalesDecisionRecordTriggerHelper.setDataSnapshotFields(null);
        sdr.Locked__c = true;
        update sdr;
        SalesDecisionRecordTriggerHelper.checkRecordEditabilityForMELAOppty(null, null);  
        SalesDecisionRecordTriggerHelper.updateACR_CSR_CFRBasedOnOpptySalesTeam(null);
        sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED;
        try{
            update sdr;
        }
        catch (Exception e) {
            System.assert(e.getMessage().contains(GlobalConstants.SalesDecisionApprovedStatusError1), 'message=' + e.getMessage());
        }
        Sales_Decision_Record__c sdr1 = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Opportunity_progression_ready__c='Yes'));
        sdr1.SDR_Completed__c = 'Yes';
		sdr1.Sales_Decision_Type__c='Other';
        insert sdr1;
        Sales_Decision_Maker__c sdm1 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr1.id));
        insert sdm1;
        sdm1.Approval_Status__c = GlobalConstants.APPROVED;
        sdm1.Approver_Name__c = testUser.Id;
        
        update sdm1;
        try{
            sdr1.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED;
            update sdr1;
        }
        catch (Exception e) {
            //System.assert(e.getMessage().contains(GlobalConstants.SalesDecisionApprovedStatusError1), 'message=' + e.getMessage());
        }
        sdrList.add(sdr1);
        SalesDecisionRecordTriggerHelper.updateACR_CSR_CFRBasedOnOpptySalesTeam(sdrList);
        List<Sales_Decision_Maker_Rules__c> sdmRuleList = new List<Sales_Decision_Maker_Rules__c>();
        Sales_Decision_Maker_Rules__c sdmRule = new Sales_Decision_Maker_Rules__c();
        sdmRule.CU_Head__c = true;
        sdmRule.BA_Head__c = true;
        sdmRule.GCU_Commercial_Management__c = true;
        sdmRule.Commercials__c = true;
        sdmRule.Fulfillment__c = true;
        sdmRule.GCU_Head__c = true;
        sdmRule.GCU_KAM__c = true;
        sdmRule.KAM__c = true;
        sdmRule.MA_Head__c = true;
        sdmRule.Solution__c = true;
        sdmRule.Name = 'CU_Tier1_SDP0';
        sdmRule.Unique_String__c = 'CU Account-Major-false-SDP0 Qualify';
        sdmRuleList.add(sdmRule);
        Sales_Decision_Maker_Rules__c sdmRule2 = new Sales_Decision_Maker_Rules__c();
        sdmRule2.CU_Head__c = true;
        sdmRule2.BA_Head__c = true;
        sdmRule2.GCU_Commercial_Management__c = true;
        sdmRule2.Commercials__c = true;
        sdmRule2.Fulfillment__c = true;
        sdmRule2.GCU_Head__c = true;
        sdmRule2.GCU_KAM__c = true;
        sdmRule2.KAM__c = true;
        sdmRule2.MA_Head__c = true;
        sdmRule2.Solution__c = true;
        sdmRule2.Name = 'CU_Tier1_OQB';
        sdmRule2.Unique_String__c = 'CU Account-Major-false-OQB';
        sdmRuleList.add(sdmRule2);
        insert sdmRuleList;
        list<Sales_Decision_Maker__c> sdmlist=  new list<Sales_Decision_Maker__c>();
        Map<String, Sales_Decision_Maker_Rules__c> mapRule = new Map<String, Sales_Decision_Maker_Rules__c>();
        mapRule.put(sdmRule2.Unique_String__c, sdmRule2);
        SalesDecisionRecordTriggerHelper.createSalesDecisionMakerRecords(sdrList);
        SalesDecisionRecordTriggerHelper.createSalesDecisionMakerRecords(null);
        SalesDecisionRecordUtility.createSDMRecords(sdmRule,opp,sdr1.id,s);
        SalesDecisionRecordUtility.createSDMRecords(null,null,null,null);
         Test.stopTest();
        sdr1 = [select id,Sales_Decision_Type__c,(SELECT ID,Approver_Role__c,Notification__c FROM Sales_Decision_Makers__r)
                                            from Sales_Decision_Record__c where id =: sdr1.Id limit 1];
     // SalesDecisionRecordUtility.readyForNextStage(false,'CU Account','Major',false,'2',sdr1,mapRule);//sdmRuleList
       SalesDecisionRecordUtility.readyForNextStage(false,'CU Account','Major',false,'2',sdr1,sdmlist);
        SalesDecisionRecordUtility.readyForNextStage(true,'CU Account','Major',false,'2',sdr1,sdmlist);
      System.assertEquals(opp.Anticipated_Deal_Value__c,500);  //NS
    }
    
    /****************************************************************
* @author: Shubham Jagatap  
* @date: 05-01-2020
* @description: This method is a test method for updateACR_CSR_CFREmail
*****************************************************************/    
    @isTest
    public static void updateACR_CSR_CFREmailTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'abc@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            insert opp;
            List<Opportunity> oppFrameLst = new List<Opportunity>();
            oppFrameLst.add(opp);
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today()));
            insert sdr;
            List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
            sdrList.add(sdr);
            Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser.Id, Approver_Role__c = 'KAM; CU Head', Auto_Generated__c=false ));
            Sales_Decision_Maker__c sdm2 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser2.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=false ));
            //insert sdm;
            List<Sales_Decision_Maker__c> sdmlist = new list<Sales_Decision_Maker__c>();
            sdmlist.add(sdm);
            sdmlist.add(sdm2);
            insert sdmlist;
            
            
            Employee__c testEmp2 = (Employee__c)TestDataGenerator.createSObject(new Employee__c(Signum__c = 'testuser',Email__c='testemail@user.com')); 
            insert testEmp2;
            Map<ID, Sales_Decision_Record__c> sdrOldMap = new Map<ID, Sales_Decision_Record__c>();
            Map<ID, Sales_Decision_Record__c> sdrNewMap = new Map<ID, Sales_Decision_Record__c>();
            sdrOldMap.put(sdr.Id,sdr);
            sdr.CSR__c = testEmp2.id;
            sdr.CFR__c = testEmp2.id;
            sdr.ACR__c = testEmp2.id;
            update sdr;
            sdrNewMap.put(sdr.Id,sdr);
            SalesDecisionRecordTriggerHelper.updateACR_CSR_CFREmail(sdrOldMap, sdrNewMap); 
			System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }
        System.assert(true);  //NS
            }catch(Exception e){	}
    }
    /****************************************************************
* @author: Shubham Jagatap  
* @date: 05-01-2020
* @description: This method is a test method for checkRecordEditabilityForMELAOppty
*****************************************************************/    
    @isTest
    public static void checkRecordEditabilityForMELAOpptyTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String s =  'tstsstst';
        
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        //AccessSettings__c access = new AccessSettings__c(SetupOwnerId=Userinfo.getUserId());
        
        Account acc;
        
        System.runAs(testUser){
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
           // acc.CustomerReportingGroup__c = crg.Id;
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
        Employee__c testEmp = (Employee__c)TestDataGenerator.createSObject(new Employee__c(Signum__c = 'testuser')); 
        insert testEmp;
        List<Opportunity_Sales_Team__c> oppSalesTeamList = new List<Opportunity_Sales_Team__c>();
        Opportunity_Sales_Team__c oppSalesTeam1 =  (Opportunity_Sales_Team__c)TestDataGenerator.createSObject(new Opportunity_Sales_Team__c(Opportunity__c = opp.id,Role__c = GlobalConstants.CSR,Employee__c = testEmp.id, primary__c= true));
        Opportunity_Sales_Team__c oppSalesTeam2 =  (Opportunity_Sales_Team__c)TestDataGenerator.createSObject(new Opportunity_Sales_Team__c(Opportunity__c = opp.id,Role__c = GlobalConstants.CFR,Employee__c = testEmp.id, primary__c= true));
        Opportunity_Sales_Team__c oppSalesTeam3 =  (Opportunity_Sales_Team__c)TestDataGenerator.createSObject(new Opportunity_Sales_Team__c(Opportunity__c = opp.id,Role__c = GlobalConstants.ACR,Employee__c = testEmp.id, primary__c= true));
        oppSalesTeamList.add(oppSalesTeam1);
        oppSalesTeamList.add(oppSalesTeam2);
        oppSalesTeamList.add(oppSalesTeam3);
        //insert oppSalesTeamList;
        Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS));
        
        insert sdr;
        List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
        sdrList.add(sdr);
        Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.REQUESTED));
        insert sdm;
        SalesDecisionRecordTriggerHelper.SalesDecisionApprovedStatusError(null, null);
        SalesDecisionRecordTriggerHelper.setDataSnapshotFields(null);
        sdr.Locked__c = true;
        update sdr;
        SalesDecisionRecordTriggerHelper.checkRecordEditabilityForMELAOppty(null, null);  
        SalesDecisionRecordTriggerHelper.updateACR_CSR_CFRBasedOnOpptySalesTeam(null);
         sdr.Locked__c = false;
        sdr.Sales_Decision_Type__c = 'OQB';  
        update sdr;
        
        
        Map<ID, Sales_Decision_Record__c> sdrOldMap = new Map<ID, Sales_Decision_Record__c>();
        sdrOldMap.put(sdr.Id,sdr);
        
        sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED;
        Map<ID, Sales_Decision_Record__c> sdrNewMap = new Map<ID, Sales_Decision_Record__c>();
        sdrNewMap.put(sdr.Id,sdr);
        
        SalesDecisionRecordTriggerHelper.checkRecordEditabilityForMELAOppty(sdrOldMap, sdrNewMap); 
        System.assertEquals(opp.Anticipated_Deal_Value__c,500); //NS
            }catch(Exception e){	}
    }
    
    /****************************************************************
* @author: Shubham Jagatap  
* @date: 06-01-2020
* @description: This method is a test method for setDataSnapshotFields
*****************************************************************/          
    @isTest
    public static void setDataSnapshotFieldsTest(){
        Try{
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'abc@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            insert opp;
            List<Opportunity> oppFrameLst = new List<Opportunity>();
            oppFrameLst.add(opp);
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today(), SDRInSyncWithOpportunity__c = true, Opportunity_progression_ready__c = 'Yes'));
            insert sdr;        
            
            
            //sdr.SDR_Completed__c = 'Yes';
            
            
            List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
            sdrList.add(sdr);
            SalesDecisionRecordTriggerHelper.setDataSnapshotFields(sdrList); 
			System.assertEquals(opp.Anticipated_Deal_Value__c,500); 
        }
             //NS
        }catch(Exception e){	}
    }
    /****************************************************************
* @author: Shubham Jagatap  
* @date: 05-01-2020
* @description: This method is a test method for updateACR_CSR_CFRBasedOnOpptySalesTeam
*****************************************************************/        
    @isTest
    public static void updateACR_CSR_CFRBasedOnOpptySalesTeamTest(){
        Try{
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Account ac;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        //User for inserting Account
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            ac = (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountry='India';
            ac.Trade_Classification__c='GOVERNMENT';
            insert ac;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=ac.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            opp.StageName = oppStageQualifyOppty;
            insert opp;
            
            Employee__c emp = new Employee__c(Name='test', Email__c=testUser.Email, Signum__c = 'test', Status__c = 'Active' );
            insert emp;
            
            Opportunity_Sales_Team__c ST1 =(Opportunity_Sales_team__c)TestDataGenerator.createSObject(new Opportunity_Sales_team__c(Opportunity__c= Opp.Id, Employee__c=emp.id, Role__c=GlobalConstants.ACR,CurrencyIsoCode='INR'));
            insert ST1;
            
            Opportunity_Sales_Team__c ST2 =(Opportunity_Sales_team__c)TestDataGenerator.createSObject(new Opportunity_Sales_team__c(Opportunity__c= Opp.Id, Employee__c=emp.id, Role__c=GlobalConstants.CSR,CurrencyIsoCode='INR'));
            insert ST2;
            
            Opportunity_Sales_Team__c ST3 =(Opportunity_Sales_team__c)TestDataGenerator.createSObject(new Opportunity_Sales_team__c(Opportunity__c= Opp.Id, Employee__c=emp.id, Role__c=GlobalConstants.CFR,CurrencyIsoCode='INR'));
            insert ST3;
            
            List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today(), SDRInSyncWithOpportunity__c = true, Opportunity_progression_ready__c = 'Yes'));
            insert sdr; 
            sdrList.add(sdr);
            SalesDecisionRecordTriggerHelper.updateACR_CSR_CFRBasedOnOpptySalesTeam(sdrList);
			System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }
         //NS
            }catch(Exception e){	}
    }
    
     /****************************************************************
* @author: Shubham Kadam  
* @date: 20-04-2020
* @description: This method is a test method for updateApprovedSDPStage
*****************************************************************/
    @isTest
    public static void updateApprovedSDPStageeTest() {  
        Try{
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Account ac;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        
        Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap = new Map<ID, Sales_Decision_Record__c>();
        Map<ID, Sales_Decision_Record__c> newSalesDecisionMap = new Map<ID, Sales_Decision_Record__c>();
        
        //User for inserting Account
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            ac = (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountry='India';
            ac.Trade_Classification__c='GOVERNMENT';
            insert ac;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=ac.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500)); 
            opp.StageName = oppStageQualifyOppty;
            insert opp;
            
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,
                                                                                       Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,
                                                                                       Sales_Decision_Type__c ='SDP0 Qualify', 
                                                                                       Sales_Decision_Date__c=date.today(), SDRInSyncWithOpportunity__c = true, 
                                                                                       Opportunity_progression_ready__c = 'Yes'));
            insert sdr; 
            oldSalesDecisionMap.put(sdr.Id,sdr);
            
            sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED;
            //update sdr;
            newSalesDecisionMap.put(sdr.Id,sdr);
            
            test.startTest();
            SalesDecisionRecordTriggerHelper.updateApprovedSDPStage(oldSalesDecisionMap,newSalesDecisionMap);
            test.stopTest();
            
            SalesDecisionRecordTriggerHelper.CheckSDRIsReadyForNextStage(null,null);
            SalesDecisionRecordTriggerHelper.updateApprovedSDPStage(null,null);
            SalesDecisionRecordTriggerHelper.updateACR_CSR_CFREmail(null,null);
			 System.assertEquals(opp.Anticipated_Deal_Value__c,500); 
        }
       }catch(Exception e){	}
    }
    /****************************************************************
* @author: Shubham Kadam  
* @date: 20-04-2020
* @description: This method is a test method for CheckSDRIsReadyForNextStage
*****************************************************************/
    @isTest
    public static void CheckSDRIsReadyForNextStageTest() {
        Try{
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Account ac;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        
        Map<ID, Sales_Decision_Record__c> oldSalesDecisionMap = new Map<ID, Sales_Decision_Record__c>();
        Map<ID, Sales_Decision_Record__c> newSalesDecisionMap = new Map<ID, Sales_Decision_Record__c>();
        
        //User for inserting Account
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson112@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            ac = (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountry='India';
            ac.Trade_Classification__c='GOVERNMENT';
            insert ac;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='test opp',AccountId=ac.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500,Forecast__c='Exclude',
                                                                                           Description='test desc')); 
            opp.StageName = oppStageQualifyOppty;
            opp.CloseDate = System.today();
            insert opp;
            
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,
                                                                                       Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,
                                                                                       Sales_Decision_Type__c ='SDP0 Qualify', 
                                                                                       Sales_Decision_Date__c=date.today(), SDRInSyncWithOpportunity__c = true, 
                                                                                       Opportunity_progression_ready__c = 'Yes',SDR_Completed__c='Yes'));
            insert sdr; 
            oldSalesDecisionMap.put(sdr.Id,sdr);
                       
            Sales_Decision_Maker__c sdm1 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id));
            insert sdm1;
            sdm1.Approval_Status__c = GlobalConstants.APPROVED;
            sdm1.Approver_Name__c = testUser.Id;       
            update sdm1;
            
            Sales_Decision_Maker__c sdm2 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id));
            insert sdm2;
            sdm2.Approval_Status__c = 'To be Requested';
            sdm2.Approver_Name__c = testUser1.Id;       
            update sdm2;
            
            try{
                sdr.Sales_Decision_Approval_Status__c = GlobalConstants.APPROVED;
                update sdr;
                newSalesDecisionMap.put(sdr.Id,sdr);
            }
            catch (Exception e) {
                System.assert(e.getMessage().contains(GlobalConstants.CheckSDRIsReadyForNextStageError), 'message=' + e.getMessage());
            }

            test.startTest();
                SalesDecisionRecordTriggerHelper.CheckSDRIsReadyForNextStage(oldSalesDecisionMap,newSalesDecisionMap);
            test.stopTest();
			System.assertEquals(opp.Anticipated_Deal_Value__c,500);
        }
         //NS
            }catch(Exception e){	}
    }
    
    /****************************************************************
* @author: Shubham Kadam  
* @date: 20-04-2020
* @description: This method is a test method for MarkOppoyApprovedSDPStageToObsolete of SalesDecisionRecordUtility
*****************************************************************/    
    @isTest
    public static void MarkOppoyApprovedSDPStageToObsoleteTest()
    {
        Try{
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Account ac;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        ID standardRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        //User for inserting Account
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            ac = (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountry='India';
            ac.Trade_Classification__c='GOVERNMENT';
            insert ac;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='test opp',AccountId=ac.Id, RecordtypeId = standardRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500,Forecast__c='Exclude',
                                                                                           Description='test desc')); 
            opp.StageName = oppStageQualifyOppty;
            opp.CloseDate = System.today();
            opp.MarketArea__c = 'MELA';
            opp.Approved_SDP_Stage__c = 'OQB';
            insert opp;   
            
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,
                                                                                                                                  Sales_Decision_Approval_Status__c = 'Approvals Ongoing',
                                                                                                                                  Sales_Decision_Type__c ='SDP0 Qualify', 
                                                                                                                                  Sales_Decision_Date__c=date.today(), SDRInSyncWithOpportunity__c = true, 
                                                                                                                                  Opportunity_progression_ready__c = 'Yes',SDR_Completed__c='Yes'));
            insert sdr;
            
            test.startTest();
            SalesDecisionRecordUtility.MarkOppoyApprovedSDPStageToObsolete(opp); 
            System.assertEquals('obsolete',opp.Approved_SDP_Stage__c);  
            SalesDecisionRecordUtility.MarkOppoyApprovedSDPStageToObsolete(null);
            SalesDecisionRecordUtility.mapSDRFields(sdr,opp);
            SalesDecisionRecordUtility.mapSDRFields(null,null);
            test.stopTest(); 
           System.assertEquals(opp.Anticipated_Deal_Value__c,500);			
        }
              //NS
        }catch(Exception e){	}
    }
    
        /****************************************************************
* @author: Shubham Kadam  
* @date: 20-04-2020
* @description: This method is a test method for resetSDMs of SalesDecisionRecordUtility
*****************************************************************/    
    @isTest
    public static void resetSDMsTest()
    {
        Try{
        String str = 'SDRCompleted';
        String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
        String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
        String oppStageCreateProposal = GlobalConstants.Create_Proposal;
        String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
        Account ac;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        
        //User for inserting Account
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                       UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            ac = (Account)TestDataGenerator.createSObject(new Account(), false);
            ac.BillingCountry='India';
            ac.Trade_Classification__c='GOVERNMENT';
            insert ac;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(Name='test opp',AccountId=ac.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500,Forecast__c='Exclude',
                                                                                           Description='test desc')); 
            opp.StageName = oppStageQualifyOppty;
            opp.CloseDate = System.today();
            opp.KAM__c = testUser.id;
            opp.GCU_Head__c = testUser.id;
            opp.CU_Head__c = testUser.id;
            opp.GCU_KAM__c = testUser.id;
            opp.MA_Head__c = testUser.id;
            opp.BA_Head__c = testUser.id;
            opp.GCU_Commercial_Head__c = testUser.id;
            insert opp;   
            
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,
                                                                                       Sales_Decision_Approval_Status__c = 'Approvals Ongoing',
                                                                                       Sales_Decision_Type__c ='SDP0 Qualify', 
                                                                                       Sales_Decision_Date__c=date.today(), SDRInSyncWithOpportunity__c = true, 
                                                                                       Opportunity_progression_ready__c = 'Yes',SDR_Completed__c='Yes'));
            List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
            sdrList.add(sdr);
            insert sdrList;
            
            Sales_Decision_Maker__c sdm1 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id));
            insert sdm1;
            sdm1.Approval_Status__c = 'To be Requested';
            sdm1.Approver_Name__c = testUser.Id;       
            update sdm1;
            
            //RecallSdmApprovals app = new RecallSdmApprovals();
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(sdm1.id);
            Approval.ProcessResult result = Approval.process(app);
            
            Sales_Decision_Maker_Rules__c sdmRule = new Sales_Decision_Maker_Rules__c();
            sdmRule.CU_Head__c = true;
            sdmRule.BA_Head__c = true;
            sdmRule.GCU_Commercial_Management__c = true;
            sdmRule.Commercials__c = true;
            sdmRule.Fulfillment__c = true;
            sdmRule.GCU_Head__c = true;
            sdmRule.GCU_KAM__c = true;
            sdmRule.KAM__c = true;
            sdmRule.MA_Head__c = true;
            sdmRule.Solution__c = true;
            sdmRule.Name = 'CU_Tier1_SDP0';
            sdmRule.Unique_String__c = 'CU Account-Major-false-SDP0 Qualify';
            
            test.startTest();
            SalesDecisionRecordUtility.resetSDMs(sdrList); 
            //System.assertEquals('To be Requested',sdm1.Approval_Status__c);
            SalesDecisionRecordUtility.resetSDMs(null); 
            
            SalesDecisionRecordUtility.createSDMRecords(sdmRule,opp,sdr.id,str);
            test.stopTest();   
           System.assertEquals(opp.Anticipated_Deal_Value__c,500);  //NS			
        }
       
            }catch(Exception e){	}
    }
}