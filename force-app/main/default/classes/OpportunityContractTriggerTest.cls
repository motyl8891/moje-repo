/******************************************************************* 
* @author: Linda Pavare 
* @date:  2017-11-08
* @description: This is a test class for OpportunityContractInboundTrigger
********************************************************************/
@isTest
public class OpportunityContractTriggerTest{
    
    @testSetup
    static void createTestData(){
        //Account a;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),                                                             
                                                                       UserName = 'ericsson@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){

        List<Account> testAcc = new List<Account>();
        for(Integer i=1; i<=5;i++){
            //a = (Account)TestDataGenerator.createSObject(new Account(Name='Test Account'+i, SAP_S2P_ID__c=String.valueOf(i)),false);
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
            crg.MarketArea__c = GlobalConstants.MELA;
            crg.CRG_ID__c='HW1234'+i;
            crg.Name='testCRG'+i;
            insert crg;
            Account a = new Account();
            a.Name = 'Test Account'+i;
            a.SAP_S2P_ID__c=String.valueOf(i);
            a.CurrencyIsoCode = 'SEK';
            a.Visible__c = true;
            a.Customer_Tier__c = 'Tier 1';
            a.CustomerReportingGroup__c= crg.id;
            testAcc.add(a);
        }
        insert testAcc;
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contract> contrList = new List<Contract>();
        Integer i = 1;
        for(SObject acc: testAcc){
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
            oppList.add(opp);
            Contract contr = (Contract)TestDataGenerator.createSObject(new Contract(AccountId=acc.Id, Contract_ID__c = '234'+i, Status='Draft', OpportunityID__c=opp.OpportunityNumber__c));
            contrList.add(contr);
            i++;
        }
        insert oppList;
        insert contrList;
        
        List<OpportunityContractInbound__c> ooppContr = (List<OpportunityContractInbound__c>)TestDataGenerator.createSObjectList(new OpportunityContractInbound__c(),300,true);
        }
    }
    
    @isTest
    static void testEmptyContractId(){
        
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        oc.External_Id__c = '';
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oc2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        system.assertEquals('Given Contract Id is empty', oc2.Error_Msg__c);
        system.assertEquals(true, oc2.isError__c);
    }
    
    @isTest
    static void testValidButNonexistingOpportunityId()
    {
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        String oppId = o.OpportunityNumber__c;
         try{
                delete o;
            }
            catch(DmlException e){}
        
        
        
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        oc.External_Id__c = contr.Contract_ID__c;
        oc.Parent_Opportunity_Id__c = oppId;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oc2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
      //  system.assertEquals('Provided Opportunity Id(Parent Opportunity Id) doesn\'t exist in SF', oc2.Error_Msg__c);
        system.assertEquals(true, oc2.isError__c); 
    }
    
    @isTest
    static void testUpdateExistingContract(){
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        contr.Status = 'Draft';
        contr.Description = 'Nothing';
        contr.Name = 'Test';
        contr.OpportunityID__c = o.Id;
        update contr;
        
        String uniqueId = o.OpportunityNumber__c+contr.Contract_ID__c;
        Contract contractReference = new Contract(Contract_ID__c=contr.Contract_ID__c);
        Opportunity opportunityReference = new Opportunity(OpportunityNumber__c=o.OpportunityNumber__c);
        OpportunityContract__c rel = new OpportunityContract__c(Unique_Id__c=uniqueId, Contract__r=contractReference,Opportunity__r=opportunityReference);
        upsert rel Unique_Id__c;
        
        
        oc.External_Id__c = contr.Contract_ID__c;
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Valid';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        Contract c2 = [SELECT Id,Status,Description,Name FROM Contract WHERE Id =:contr.Id
                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals('Valid', c2.Status);
        System.assertEquals('Some link',c2.Description);
        System.assertEquals('Test Update', c2.Name);
        
        OpportunityContract__c ocr = [SELECT Id, Contract__r.Status, Contract__r.Description, Contract__r.Name
                                                  FROM OpportunityContract__c 
                                                  WHERE Unique_Id__c =:uniqueId
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals('Valid', ocr.Contract__r.Status);
        System.assertEquals('Some link',ocr.Contract__r.Description);
        System.assertEquals('Test Update', ocr.Contract__r.Name);
    }
    
    @isTest
    static void testnewContractCreation(){
        
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];     
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test';
        oc.External_Id__c = '222122';
        update oc;
        
        String uniqueId = o.OpportunityNumber__c+oc.External_Id__c;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
      //  System.assertEquals(0, [SELECT Id FROM Contract WHERE OpportunityID__c =:o.Id Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].size());
       // System.assertEquals(0, [SELECT Id FROM OpportunityContract__c Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].size());
        
        Contract c2 = [SELECT Id, Status, Description, Name FROM Contract WHERE OpportunityID__c =: o.Id
                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals('Draft', c2.Status);
        System.assertEquals('Some link',c2.Description);
        System.assertEquals('Test', c2.Name);
        
        OpportunityContract__c ocr = [SELECT Id, Contract__r.Status, Contract__r.Description, Contract__r.Name
                                                  FROM OpportunityContract__c 
                                                  WHERE Unique_Id__c =:uniqueId
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals('Draft', ocr.Contract__r.Status);
        System.assertEquals('Some link',ocr.Contract__r.Description);
        System.assertEquals('Test', ocr.Contract__r.Name);
        
    }
    
    @isTest
    static void testContractUpdateError(){
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        String uniqueId = o.OpportunityNumber__c+contr.Contract_ID__c;
        Contract contractReference = new Contract(Contract_ID__c=contr.Contract_ID__c);
        Opportunity opportunityReference = new Opportunity(OpportunityNumber__c=o.OpportunityNumber__c);
        OpportunityContract__c rel = new OpportunityContract__c(Unique_Id__c=uniqueId, Contract__r=contractReference,Opportunity__r=opportunityReference);
        upsert rel Unique_Id__c;
        
        contr.Status = 'Draft';
        contr.Description = 'Nothing';
        contr.Name = 'Test';
        contr.OpportunityID__c = o.Id;
        update contr;
        
        oc.External_Id__c = contr.Contract_ID__c;
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'SSSSS'; //invalid picklist value will cause error
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('There was an error when trying to upsert Contract:'));
        System.assertEquals(true, oppcontr2.isError__c);
        //System.assertEquals('Test Update', c2.Name);
        
    }
    
    @isTest
    static void testNewContractInsertError(){
        
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Hello won\'t work'; //invalid picklist value
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '22222';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Id FROM Contract WHERE OpportunityID__c =:o.Id
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].size());
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals(true, oppcontr2.isError__c);
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('There was an error when trying to upsert Contract'));
        
        
    }
    
    @isTest
    static void testBulkContractUpdateInsertion(){ 
        
        List<Contract> contrList = [SELECT Id, Contract_ID__c, Status, Description, Name, OpportunityID__c FROM Contract LIMIT 5];
        List<Opportunity> oppList = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 5];
        //NS
        /*List<OpportunityContractInbound__c> ocList = [SELECT Id, External_Id__c, Parent_Opportunity_Id__c, Status_Of_Business__c, Contract_Url__c, 
                                                      Contract_Name__c FROM OpportunityContractInbound__c LIMIT 5];*/
        
       // Set<Id> contrSet = (new Map<Id,Contract>(contrList)).keySet();  
        List<Contract> contUpdate = new List<Contract>();
        Integer oppCount = 0;
        for(Contract contr: contrList){
            contr.Status = 'Draft';
            contr.Description = 'Nothing '+ oppCount;
            contr.Name = 'Test ' +oppCount;
            contr.OpportunityID__c = oppList[oppCount].Id;
            contUpdate.add(contr);
            oppCount++;
        }
        update contUpdate;
        
        List<OpportunityContractInbound__c> ocUpdateList = new List<OpportunityContractInbound__c>();
        Integer contrIndex = 0;
        for(OpportunityContractInbound__c oc: [SELECT Id, External_Id__c, Parent_Opportunity_Id__c, Status_Of_Business__c, Contract_Url__c, 
                                              Contract_Name__c FROM OpportunityContractInbound__c LIMIT 5]){
            oc.External_Id__c = contrList[contrIndex].Contract_ID__c;
            oc.Parent_Opportunity_Id__c = oppList[contrIndex].OpportunityNumber__c;
            oc.Status_Of_Business__c = 'Valid';
            oc.Contract_Url__c = 'Some link';
            oc.Contract_Name__c = 'Test Update';
            ocUpdateList.add(oc);
            contrIndex++;
        }
        update ocUpdateList;
        
        Test.startTest();
        for(OpportunityContractInbound__c oc1: ocUpdateList){
            oc1.isProcessed__c = true;
            
        }
        update ocUpdateList;
        Test.stopTest();
        
        //NS
        //List<Contract> contr2list = [SELECT Description, Name FROM Contract LIMIT 5];
        for(Contract c: [SELECT Description, Name FROM Contract LIMIT 5]){
            
            System.assertEquals('Some link', c.Description);
            System.assertEquals('Test Update', c.Name);
        }   
    }
    
    @isTest
    static void testReferringOpportunities(){
        List<Opportunity> o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 3];     
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        oc.Parent_Opportunity_Id__c = o[0].OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '222122';
        oc.Referring_Opportunity_Ids__c = o[1].OpportunityNumber__c +' '+o[2].OpportunityNumber__c;
        update oc;
        
        Set<String> refIdSet = new Set<String>();
        refIdSet.add(o[1].OpportunityNumber__c+oc.External_Id__c);
        refIdSet.add(o[2].OpportunityNumber__c+oc.External_Id__c);
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        Contract c2 = [SELECT Id, Status, Description, Name FROM Contract WHERE OpportunityID__c =: o[0].Id
                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        Opportunity o1 = [SELECT Parent_Contract__c FROM Opportunity WHERE Id =: o[1].Id];
        Opportunity o2 = [SELECT Parent_Contract__c FROM Opportunity WHERE Id =: o[2].Id];
        System.assertEquals(c2.Id, o1.Parent_Contract__c);
        System.assertEquals(c2.Id, o2.Parent_Contract__c);
        
        List<OpportunityContract__c> insertedOppContractRelList = [SELECT Id FROM OpportunityContract__c
                                                                              WHERE Unique_Id__c IN: refIdSet
                                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals(2, insertedOppContractRelList.size());
        
    }
    
    @isTest
    static void testValidParentContract(){
        List<Contract> contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 2];
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        contr[0].Status = 'Draft';
        contr[0].Description = 'Nothing';
        contr[0].Name = 'Test';
        contr[0].OpportunityID__c = o.Id;
        update contr;
        
        String uniqueId = o.OpportunityNumber__c+contr[0].Contract_ID__c;
        Contract contractReference = new Contract(Contract_ID__c=contr[0].Contract_ID__c);
        Opportunity opportunityReference = new Opportunity(OpportunityNumber__c=o.OpportunityNumber__c);
        OpportunityContract__c rel = new OpportunityContract__c(Unique_Id__c=uniqueId, Contract__r=contractReference,Opportunity__r=opportunityReference);
        upsert rel Unique_Id__c;
        
        oc.External_Id__c = contr[0].Contract_ID__c;
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'In Approval Process';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.Parent_Contract_Id__c = contr[1].Contract_ID__c;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        Contract c2 = [SELECT Id,Parent_Contract__c FROM Contract WHERE Id =:contr[0].Id];
        System.assertEquals(c2.Parent_Contract__c, contr[1].Id); 
        
        OpportunityContract__c resContr = [SELECT Id, Contract__r.Parent_Contract__c FROM OpportunityContract__c 
                                           WHERE Unique_Id__c =: uniqueId
                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals(c2.Parent_Contract__c, resContr.Contract__r.Parent_Contract__c);
    }
    
   /* Commented out test methods for nonexisting Parent Contract Id validation
    @isTest
    static void testInvalidParentContract(){
        List<Contract> contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 2];
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        contr[0].Status = 'Draft';
        contr[0].Description = 'Nothing';
        contr[0].Name = 'Test';
        contr[0].OpportunityID__c = o.Id;
        update contr;
        
        oc.External_Id__c = contr[0].Contract_ID__c;
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'In Approval Process';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.Parent_Contract_Id__c = contr[1].Contract_ID__c;
        update oc;
        
        delete contr[1];
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id];
        System.assertEquals(true, oppcontr2.isError__c);
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('Given Parent Contract doesn\'t exist in Salesforce'));
        
    }*/
   /* 
    @isTest
    static void testInvalidParentContractForNewContract(){
        List<Contract> contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 2];
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        contr[0].Status = 'Draft';
        contr[0].Description = 'Nothing';
        contr[0].Name = 'Test';
        contr[0].OpportunityID__c = o.Id;
        update contr;
        
        oc.External_Id__c = 'h';
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'In Approval Process';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.Parent_Contract_Id__c = contr[1].Contract_ID__c;
        update oc;
        
        delete contr[1];
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id];
        System.assertEquals(true, oppcontr2.isError__c);
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('Given Parent Contract doesn\'t exist in Salesforce'));
        
        
    }*/
    @isTest
    static void testValidParentContractForNewContract(){
        
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
         
        oc.External_Id__c = 'c';
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.Parent_Contract_Id__c = contr.Contract_ID__c;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        String contrId = 'c';
        Contract oppcontr2 = [SELECT Id, Parent_Contract__r.Id FROM Contract WHERE Contract_Id__c =: contrId Limit 1];
        System.assertEquals(contr.Id, oppcontr2.Parent_Contract__r.Id); 
        
        String uniqueId = oc.Parent_Opportunity_Id__c+oc.External_Id__c;
        OpportunityContract__c resContr = [SELECT Id, Contract__r.Parent_Contract__c FROM OpportunityContract__c 
                                           WHERE Unique_Id__c =: uniqueId
                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals(contr.Id, resContr.Contract__r.Parent_Contract__c);
        
        
    }
    
    @isTest
    static void testContractsVLEsForExistingContract(){
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        Opportunity o = [SELECT Id, OpportunityNumber__c, Account.SAP_S2P_ID__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        List<Account> a = [SELECT Id, SAP_S2P_ID__c FROM Account WHERE SAP_S2P_ID__c !=: o.Account.SAP_S2P_ID__c LIMIT 2] ;
        List<OpportunityContractVLE__c> vleList = new List<OpportunityContractVLE__c>();
        for(Integer i = 0; i<2; i++){
            OpportunityContractVLE__c vle = new OpportunityContractVLE__c(Opportunity_Contract__c = oc.Id, 
                                                                              SoldToParty_Local_Id__c = a[i].SAP_S2P_ID__c,
                                                                              Ericsson_Company_Code__c = String.valueof(i),
                                                                              SoldToParty_Status__c = 'Status');
            vleList.add(vle);
        }
        insert vleList;
        
        contr.OpportunityID__c = o.Id;
        update contr;
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = contr.Contract_ID__c;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Contract WHERE Contract_ID__c =:oc.External_Id__c].size());

        //Contract c2 = [SELECT Id, Status, Description, Name FROM Contract WHERE OpportunityID__c =: o.Id];
        
        List<ContractValidForLegalEntity__c> vle1 = [SELECT ID,Sold_To_Party__c,Company_Code__c,Status__c FROM ContractValidForLegalEntity__c 
                                                     WHERE Sold_To_Party__c =:a[0].ID
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        List<ContractValidForLegalEntity__c> vle2 = [SELECT ID,Sold_To_Party__c,Company_Code__c,Status__c FROM ContractValidForLegalEntity__c 
                                                     WHERE Sold_To_Party__c =:a[1].ID
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        
        System.assert(true);
    }
    
    @isTest
    static void testContractsVLEsForNewContract(){
        
        Opportunity o = [SELECT Id, OpportunityNumber__c, Account.SAP_S2P_ID__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        List<Account> a = [SELECT Id, SAP_S2P_ID__c FROM Account WHERE SAP_S2P_ID__c !=: o.Account.SAP_S2P_ID__c LIMIT 2] ;
        List<OpportunityContractVLE__c> vleList = new List<OpportunityContractVLE__c>();
        for(Integer i = 0; i<2; i++){
            OpportunityContractVLE__c vle = new OpportunityContractVLE__c(Opportunity_Contract__c = oc.Id, 
                                                                              SoldToParty_Local_Id__c = a[i].SAP_S2P_ID__c,
                                                                              Ericsson_Company_Code__c = String.valueof(i),
                                                                              SoldToParty_Status__c = 'Status');
            vleList.add(vle);
        }
        insert vleList;
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '22222224';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        //Contract c2 = [SELECT Id, Status, Description, Name FROM Contract WHERE OpportunityID__c =: o.Id];
        List<ContractValidForLegalEntity__c> vle1 = [SELECT ID,Sold_To_Party__c,Company_Code__c,Status__c FROM ContractValidForLegalEntity__c 
                                                     WHERE Sold_To_Party__c =:a[0].ID
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        List<ContractValidForLegalEntity__c> vle2 = [SELECT ID,Sold_To_Party__c,Company_Code__c,Status__c FROM ContractValidForLegalEntity__c 
                                                     WHERE Sold_To_Party__c =:a[1].ID
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        
       System.assert(true);
    }
    /*
    @isTest
    static void testNonExistingReferringOpportunitiesError(){
        List<Opportunity> o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 3];     
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        oc.Parent_Opportunity_Id__c = o[0].OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '222122';
        oc.Referring_Opportunity_Ids__c = o[1].OpportunityNumber__c +' '+o[2].OpportunityNumber__c;
        update oc;
        
        delete o[1];
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id];
        System.assertEquals(true, oppcontr2.isError__c);
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('One or more Reffering Opportunities doesn\'t exist in Salesforce'));
        
    }*/
    
    @isTest
    static void testNonExistingS2PidInVLE(){
        Opportunity o = [SELECT Id, OpportunityNumber__c, Account.SAP_S2P_ID__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        List<Account> a = [SELECT Id, SAP_S2P_ID__c FROM Account WHERE SAP_S2P_ID__c !=: o.Account.SAP_S2P_ID__c LIMIT 2] ;
        List<OpportunityContractVLE__c> vleList = new List<OpportunityContractVLE__c>();
        for(Integer i = 0; i<2; i++){
            OpportunityContractVLE__c vle = new OpportunityContractVLE__c(Opportunity_Contract__c = oc.Id, 
                                                                              SoldToParty_Local_Id__c = String.valueof(a[i].SAP_S2P_ID__c),
                                                                              Ericsson_Company_Code__c = String.valueof(i),
                                                                              SoldToParty_Status__c = 'Status');
            vleList.add(vle);
        }
        vleList[1].SoldToParty_Local_Id__c = '11111111678';
        insert vleList;
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '22222224';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id];
        System.assertEquals(true, oppcontr2.isError__c);
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('Account with SAP S2P ID(SoldToParty Local Id): '+'11111111678' +' doesn\'t exist in SF. See the related Opportunity'));
    }
    
    @isTest
    static void testContractValidForLegalEntityInsertError(){
        Opportunity o = [SELECT Id, OpportunityNumber__c, Account.SAP_S2P_ID__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        List<Account> a = [SELECT Id, SAP_S2P_ID__c FROM Account WHERE SAP_S2P_ID__c !=: o.Account.SAP_S2P_ID__c LIMIT 2] ;
        List<OpportunityContractVLE__c> vleList = new List<OpportunityContractVLE__c>();
        for(Integer i = 0; i<2; i++){
            OpportunityContractVLE__c vle = new OpportunityContractVLE__c(Opportunity_Contract__c = oc.Id, 
                                                                              SoldToParty_Local_Id__c = String.valueof(a[i].SAP_S2P_ID__c),//??
                                                                              Ericsson_Company_Code__c = String.valueof(i),
                                                                              SoldToParty_Status__c = 'Statuszzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz');
            vleList.add(vle);
        }
        insert vleList;
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '22222224';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assert(true);
    }
    
    @isTest
    static void testExistingContractValidForLegalEntityUpdate(){
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        Opportunity o = [SELECT Id, OpportunityNumber__c, Account.SAP_S2P_ID__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        
        Account a = [SELECT Id, SAP_S2P_ID__c FROM Account WHERE SAP_S2P_ID__c !=: o.Account.SAP_S2P_ID__c LIMIT 1] ;
        ContractValidForLegalEntity__c cvfle = new ContractValidForLegalEntity__c(Contract__c = contr.Id,
                                                                                  Company_Code__c = '2221290',
                                                                                  Status__c = 'Status');
        Account accountreference = new Account(SAP_S2P_ID__c = a.SAP_S2P_ID__c);
        cvfle.Sold_To_Party__r = accountreference;
        insert cvfle;
        
        OpportunityContractVLE__c vle = new OpportunityContractVLE__c(Opportunity_Contract__c = oc.Id, 
                                                                              SoldToParty_Local_Id__c = a.SAP_S2P_ID__c,
                                                                              Ericsson_Company_Code__c = '2221290',
                                                                              SoldToParty_Status__c = 'UpdatedStatus');
        insert vle;
        
      //  contr.OpportunityID__c = o.Id;
      //  update contr;
        
        String uniqueId = o.OpportunityNumber__c+contr.Contract_ID__c;
        Contract contractReference = new Contract(Contract_ID__c=contr.Contract_ID__c);
        Opportunity opportunityReference = new Opportunity(OpportunityNumber__c=o.OpportunityNumber__c);
        OpportunityContract__c rel = new OpportunityContract__c(Unique_Id__c=uniqueId, Contract__r=contractReference,Opportunity__r=opportunityReference);
        upsert rel Unique_Id__c;
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = contr.Contract_ID__c;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Contract WHERE Contract_ID__c =:oc.External_Id__c
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].size());
        
        ContractValidForLegalEntity__c vleList1 = [SELECT Status__c FROM ContractValidForLegalEntity__c WHERE Id =:cvfle.Id
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assert(true);
    }
    
    @isTest
    static void testExistingContractValidForLegalEntityUpdateError(){
        Contract contr = [SELECT Id, Contract_ID__c FROM Contract LIMIT 1];
        Opportunity o = [SELECT Id, OpportunityNumber__c, Account.SAP_S2P_ID__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        List<Account> a = [SELECT Id, SAP_S2P_ID__c FROM Account WHERE SAP_S2P_ID__c !=: o.Account.SAP_S2P_ID__c LIMIT 2] ;
        ContractValidForLegalEntity__c cvfle = new ContractValidForLegalEntity__c(Contract__c = contr.Id,
                                                                                  Company_Code__c = '2221290',
                                                                                  Status__c = 'Status');
        Account accountreference = new Account(SAP_S2P_ID__c = a[0].SAP_S2P_ID__c);
        cvfle.Sold_To_Party__r = accountreference;
        insert cvfle;
        List<OpportunityContractVLE__c> vleList = new List<OpportunityContractVLE__c>();
        for(Integer i = 0; i<2; i++){
            OpportunityContractVLE__c vle = new OpportunityContractVLE__c(Opportunity_Contract__c = oc.Id, 
                                                                              SoldToParty_Local_Id__c = a[i].SAP_S2P_ID__c,
                                                                              Ericsson_Company_Code__c = String.valueof(i),
                                                                              SoldToParty_Status__c = 'Statustooooooooooooooooolooooooooooooooooooooooooooooonggggggggggg');
            vleList.add(vle);
        }
        insert vleList;
        contr.OpportunityID__c = o.Id;
        update contr;
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft';
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = contr.Contract_ID__c;
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        System.assertEquals(1, [SELECT Id FROM Contract WHERE Contract_ID__c =:oc.External_Id__c
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].size());
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assert(true);
    }
    
    @isTest
    static void testEmptyParentOpportunityId(){
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        oc.External_Id__c = '123';
        oc.Parent_Opportunity_Id__c = '';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        OpportunityContractInbound__c oc2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        system.assertEquals('Parent Opportunity Id is empty', oc2.Error_Msg__c);
        system.assertEquals(true, oc2.isError__c);
    } 
    @isTest
    static void testOppContractInsertError(){
        Opportunity o = [SELECT Id, OpportunityNumber__c FROM Opportunity LIMIT 1];
        OpportunityContractInbound__c oc = [SELECT Id FROM OpportunityContractInbound__c LIMIT 1];
        
        oc.Parent_Opportunity_Id__c = o.OpportunityNumber__c;
        oc.Status_Of_Business__c = 'Draft'; 
        oc.Contract_Url__c = 'Some link';
        oc.Contract_Name__c = 'Test Update';
        oc.External_Id__c = '2222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222';
        update oc;
        
        Test.startTest();
        oc.isProcessed__c = true;
        update oc;
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Id FROM OpportunityContract__c WHERE Opportunity__c =:o.Id
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].size());
        
        OpportunityContractInbound__c oppcontr2 = [SELECT Error_Msg__c, isError__c FROM OpportunityContractInbound__c WHERE Id =: oc.Id
                                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        System.assertEquals(true, oppcontr2.isError__c);
        System.assertEquals(true, oppcontr2.Error_Msg__c.contains('There was an error when trying to insert OpportunityContract__c record(s):'));
        
    }
}