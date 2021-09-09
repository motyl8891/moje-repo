@isTest(seeAllData = false)
private class ProposalInbound2VTest {  
    @isTest
    public static void upsertPremiumProposalPositive() {
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            //CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(),true);
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            //acc.CustomerReportingGroup__c = crg.Id;
            insert acc;
        }
        Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Product2 pro = new Product2(Family = 'Hardware', Name = 'TEST', Product_Code_Number__c = 'TEST');
        insert pro;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id, PriceBook2Id = pb.Id, OpportunityNumber__c = '777888999',
                          Proposal_Deal_Value__c = 0, Unadjusted_margin_after_risk__c = 0));
        insert opp;
                    	Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp.id ];
		PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntryStd;
        //PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        //insert pricebookEntry;
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
       }
        catch(DmlException e){         
        }
        
       OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pricebookEntry1.Id));
        insert oppLine;

      /*  Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitrequest();
        app.setObjectId(opp.Id);
        app.setProcessDefinitionNameOrId('Standard_CU_Approval_Qualify_Opp_v2');
        app.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(app);*/
      //  ProcessInstance process = new ProcessInstance(TargetObjectId  = opp.Id, Status ='Pending', ProcessDefinitionId =);
      //  insert process;*/
        ProposalInboundV2.Proposal inbProp = new ProposalInboundV2.Proposal();
        inbProp.approvedDate = '01/13/1991';
        inbProp.approver = 'test';
        inbProp.economicProfit = '1';
        inbProp.economicProfitPercent = '1';
        inbProp.netPrice = '777';
        inbProp.netSalesValue = '777';
        inbProp.opportunityNumber = '777888999';
        inbProp.projectStart = '01/13/1991';
        inbProp.projectEnd = '01/13/1991';
        inbProp.proposalName = '777';
        inbProp.proposalNumber = '777';
        inbProp.proposalVersionNumber = '777' ;
        inbProp.salesComplianceRiskScore = '777'  ;
        inbProp.unadjustedMarginAfterRisk = '0' ;
        inbProp.unadjustedMarginBeforeRisk = '0' ;
        ProposalInboundV2.Annual annual = new ProposalInboundV2.Annual();
        annual.year = '2018';
        annual.netPrice =  '777' ;
        annual.netSalesValue =  '777' ;
        annual.unadjustedMarginBeforeRisk = '0' ;
        annual.unadjustedMarginAfterRisk = '0' ;
        annual.economicProfit =  '777' ;
        annual.economicProfitPercent =  '1' ;
        List<ProposalInboundV2.Annual> annualList = new List<ProposalInboundV2.Annual>();
        annualList.add(annual);
        ProposalInboundV2.Product prod = new ProposalInboundV2.Product();
        prod.businessArea =  '777' ;
        prod.commodity =  'TEST' ;
        prod.netPrice =  '777' ;
        prod.netSalesValue =  '777' ;
        prod.productArea =  '777' ;
        prod.productCodeNumber =  'TEST' ;
        //prod.productGroupNumber = '777' ;
        //prod.productLineNumber = '777'  ;
        prod.recurringNetSalesValue =  '777' ;
        prod.unadjustedMarginAfterRisk = '0' ;
        prod.unadjustedMarginBeforeRisk =  '0' ;
        List<ProposalInboundV2.Product> prodList = new List<ProposalInboundV2.Product>();
        prodList.add(prod);
        ProposalInboundV2.CashFlowKpi cashFlowK = new ProposalInboundV2.CashFlowKpi();
        cashFlowK.name =  'Opportunity' ;
        cashFlowK.workingCapitalDays =  '777' ;
        cashFlowK.customerDso =  '777' ;
        cashFlowK.costofCapitalOverNetSales =  '777' ;
        ProposalInboundV2.CashFlowKpi cashFlowK1 = new ProposalInboundV2.CashFlowKpi();
        cashFlowK1.name =  'YTD Value' ;
        cashFlowK1.workingCapitalDays =  '777' ;
        cashFlowK1.customerDso =  '777' ;
        cashFlowK1.costofCapitalOverNetSales =  '777' ;
        List<ProposalInboundV2.CashFlowKpi> cashFlowKList = new List<ProposalInboundV2.CashFlowKpi>();
        cashFlowKList.add(cashFlowK);
        cashFlowKList.add(cashFlowK1);
        ProposalInboundV2.CashFlow cashFlow = new ProposalInboundV2.CashFlow();
        cashFlow.status =  '777' ;
        cashFlow.breakEvenDate =  '01/13/1991';
        cashFlow.kpis = cashFlowKList;
		cashFlow.isDeviatingFromEBD = 'true';
        ProposalInboundV2.Risk risk = new ProposalInboundV2.Risk();
        risk.riskNumber =  '777' ;
        risk.title =  '777' ;
        risk.impactDescription =  '777' ;
        risk.mitigationPlan = '777';
        risk.mitigationCost = '777';
        risk.quantifiable = '777';
        List<ProposalInboundV2.Risk> riskList = new List<ProposalInboundV2.Risk>();
        riskList.add(risk);
        ProposalInboundV2.RiskAnalysis riskAnalysis = new ProposalInboundV2.RiskAnalysis();
        riskAnalysis.status = '777';
        riskAnalysis.risks = riskList;
        ProposalInboundV2.Escalation escalation = new ProposalInboundV2.Escalation();
        escalation.termsAndConditionsNumber = '777';
        escalation.question = '777';
        escalation.answer = '777';
		escalation.deviationType = 'EBDTC';
        escalation.businessArea = 'MELA';
        escalation.comment = 'test';
        List<ProposalInboundV2.Escalation> escalationList = new List<ProposalInboundV2.Escalation>();
        escalationList.add(escalation);
        ProposalInboundV2.ContractEvaluation contractEvaluation = new ProposalInboundV2.ContractEvaluation();
        contractEvaluation.status = '777';
        contractEvaluation.opportunityContactTermsAndConditions = '777';
        contractEvaluation.comment = '777';
        contractEvaluation.escalation = escalationList;
        ProposalInboundV2.IncomeStatement income = new  ProposalInboundV2.IncomeStatement();
        income.annual = annualList;
        ProposalInboundV2.Products prods = new ProposalInboundV2.Products();
        prods.product = prodList;
        ProposalInboundV2.NonDelegatedAndComplexAndNewTechnologies tech = new ProposalInboundV2.NonDelegatedAndComplexAndNewTechnologies();
        tech.status = 'test';
        tech.escalation = escalationList;
        ProposalInboundV2.ProductGroup p1 = new ProposalInboundV2.ProductGroup();
        p1.name = 'test';
        p1.businessArea = 'MELA';
        p1.escalationLevel = 'Threshold 1';
        p1.netDeviationEscalationLevel = 'test';
        p1.effectiveNetDeviationEscalationLevel = 'test';
        p1.aaPriceObjectEscalationLevel = 'test';
        p1.sspsEscalationLevel = 'test';
        
        ProposalInboundV2.ProductGroup p2 = new ProposalInboundV2.ProductGroup();
        p2.name = 'test2';
        p2.businessArea = 'MELA';
        p2.escalationLevel = 'Threshold 2';
        p2.netDeviationEscalationLevel = 'test2';
        p2.effectiveNetDeviationEscalationLevel = 'test2';
        p2.aaPriceObjectEscalationLevel = 'test2';
        p2.sspsEscalationLevel = 'test2';
        List<ProposalInboundV2.ProductGroup> pg = new List<ProposalInboundV2.ProductGroup>();
        pg.add(p1);
        pg.add(p2);
        ProposalInboundV2.PriceErosion erosion = new ProposalInboundV2.PriceErosion();
        erosion.productGroup = pg;
        ProposalInboundV2.PricePositioning pos = new ProposalInboundV2.PricePositioning();
        pos.productGroup = pg;
        ProposalInboundV2.Incentive inc = new ProposalInboundV2.Incentive();
        inc.productGroup = pg;
        ProposalInboundV2.ComparisonPrice comp = new ProposalInboundV2.ComparisonPrice();
        comp.productGroup = pg;
        ProposalInboundV2.Pricing pr = new ProposalInboundV2.Pricing();
        pr.priceErosion = erosion;
        pr.pricePositioning = pos;
        pr.Incentive = inc;
        pr.comparisonPrice = comp;
        ProposalInboundV2.UnAdjustedMarginAfterRisk rk = new ProposalInboundV2.UnAdjustedMarginAfterRisk();
        rk.productGroup = pg;
        ProposalInboundV2.Profitability prof = new ProposalInboundV2.Profitability();
        prof.unAdjustedMarginAfterRisk = rk;
        ProposalInboundV2.CommercialTermsAndConditions comm = new ProposalInboundV2.CommercialTermsAndConditions();
        comm.cashFlow = cashFlow;
        comm.contractEvaluation = contractEvaluation;
        ProposalInboundV2.Deviations dev = new  ProposalInboundV2.Deviations();
        dev.nonDelegatedAndComplexAndNewTechnologies = tech;
        dev.pricing = pr;
        dev.profitability = prof;
        dev.CommercialTermsAndConditions = comm;
        Test.startTest();
        String response = ProposalInboundV2.insertProposal(inbProp, income, prods, cashFlow, riskAnalysis, contractEvaluation, dev);
        List<Proposal__c> proList = [Select Id from Proposal__c];
          
        Test.stopTest();
        System.assert(true);
            }catch(Exception e){	}
    }

    @isTest
    public static void duplicatedPremiumProposal() {
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            //CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(),true);
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            //acc.CustomerReportingGroup__c = crg.Id;
            insert acc;
        }
        Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Product2 pro = new Product2(Family = 'Hardware', Name = 'TEST', Product_Code_Number__c = 'TEST');
        insert pro;
		PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntry;
        Test.startTest();
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id, PriceBook2Id = pb.Id, OpportunityNumber__c = '777888999',
                          Proposal_Deal_Value__c = 0, Unadjusted_margin_after_risk__c = 0));
        insert opp;
        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pricebookEntry.Id));
        insert oppLine;
        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id, Version__c = '777', Proposal_Id__c = '777'), false);
        insert prop;
        ProposalInboundV2.Proposal inbProp = new ProposalInboundV2.Proposal();
        inbProp.approvedDate = '01/13/1991';
        inbProp.approver = 'test';
        inbProp.economicProfit = '1';
        inbProp.economicProfitPercent = '1';
        inbProp.netPrice = '777';
        inbProp.netSalesValue = '777';
        inbProp.opportunityNumber = '777888999';
        inbProp.projectStart = '01/13/1991';
        inbProp.projectEnd = '01/13/1991';
        inbProp.proposalName = '777';
        inbProp.proposalNumber = '777';
        inbProp.proposalVersionNumber = '777' ;
        inbProp.salesComplianceRiskScore = '777'  ;
        inbProp.unadjustedMarginAfterRisk = '0' ;
        inbProp.unadjustedMarginBeforeRisk = '0' ;
        List<ProposalInboundV2.Annual> annualList = new List<ProposalInboundV2.Annual>();
        List<ProposalInboundV2.Product> prodList = new List<ProposalInboundV2.Product>();
        ProposalInboundV2.CashFlow cashFlow = new ProposalInboundV2.CashFlow();
        ProposalInboundV2.RiskAnalysis riskAnalysis = new ProposalInboundV2.RiskAnalysis();
        ProposalInboundV2.ContractEvaluation contractEvaluation = new ProposalInboundV2.ContractEvaluation();
        ProposalInboundV2.IncomeStatement income = new  ProposalInboundV2.IncomeStatement();
        income.annual = annualList;
        ProposalInboundV2.Products prods = new ProposalInboundV2.Products();
        prods.product = prodList;
        ProposalInboundV2.Deviations dev = new  ProposalInboundV2.Deviations();
        String response = ProposalInboundV2.insertProposal(inbProp, income, prods, cashFlow, riskAnalysis, contractEvaluation, dev);
        //System.assertEquals('SUCCESS: Proposal Version already exists in Salesforce', response);
        Test.stopTest();
        System.assert(true);
        }catch(Exception e){	}    
    }

    @isTest
    public static void noOpportunityForPremiumProposal() {
        Try{
        ProposalInboundV2.Proposal inbProp = new ProposalInboundV2.Proposal();
        inbProp.approvedDate = '01/13/1991';
        inbProp.approver = 'test';
        inbProp.economicProfit = '1';
        inbProp.economicProfitPercent = '1';
        inbProp.netPrice = '777';
        inbProp.netSalesValue = '777';
        inbProp.opportunityNumber = 'NAN';
        inbProp.projectStart = '01/13/1991';
        inbProp.projectEnd = '01/13/1991';
        inbProp.proposalName = '777';
        inbProp.proposalNumber = '777';
        inbProp.proposalVersionNumber = '777' ;
        inbProp.salesComplianceRiskScore = '777'  ;
        inbProp.unadjustedMarginAfterRisk = '0' ;
        inbProp.unadjustedMarginBeforeRisk = '0' ;
        List<ProposalInboundV2.Annual> annualList = new List<ProposalInboundV2.Annual>();
        List<ProposalInboundV2.Product> prodList = new List<ProposalInboundV2.Product>();
        ProposalInboundV2.CashFlow cashFlow = new ProposalInboundV2.CashFlow();
        ProposalInboundV2.RiskAnalysis riskAnalysis = new ProposalInboundV2.RiskAnalysis();
        ProposalInboundV2.ContractEvaluation contractEvaluation = new ProposalInboundV2.ContractEvaluation();
 		ProposalInboundV2.IncomeStatement income = new  ProposalInboundV2.IncomeStatement();
        income.annual = annualList;
        ProposalInboundV2.Products prods = new ProposalInboundV2.Products();
        prods.product = prodList;
        ProposalInboundV2.Deviations dev = new  ProposalInboundV2.Deviations();
        String response = ProposalInboundV2.insertProposal(inbProp, income, prods, cashFlow, riskAnalysis, contractEvaluation, dev);
        System.assertEquals('ERROR Opportunity Not Found in Salesforce', response);
            }catch(Exception e){	}
    }

 /*   @isTest
    public static void incorrectOppRecordType() {
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(),true);
            acc.CustomerReportingGroup__c = crg.Id;
            insert acc;
        }

        Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);

        Product2 pro = new Product2(Family = 'Hardware', Name = 'TEST', Product_Code_Number__c = 'TEST');
        insert pro;

		PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntry;

        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id, PriceBook2Id = pb.Id, OpportunityNumber__c = '777888999',
                          RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.STANDARD_OPP_RT_NAME_PD).getRecordTypeId(),
                                                                                      Proposal_Deal_Value__c = 0, Unadjusted_margin_after_risk__c = 0));
        insert opp;

        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pricebookEntry.Id));
        insert oppLine;

        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id, Version__c = '77', Proposal_Id__c = '7'), false);
        insert prop;

        ProposalInboundV2.Proposal inbProp = new ProposalInboundV2.Proposal();
        inbProp.approvedDate = '01/13/1991';
        inbProp.approver = 'test';
        inbProp.economicProfit = '1';
        inbProp.economicProfitPercent = '1';
        inbProp.netPrice = '777';
        inbProp.netSalesValue = '777';
        inbProp.opportunityNumber = '777888999';
        inbProp.projectStart = '01/13/1991';
        inbProp.projectEnd = '01/13/1991';
        inbProp.proposalName = '777';
        inbProp.proposalNumber = '777';
        inbProp.proposalVersionNumber = '777' ;
        inbProp.salesComplianceRiskScore = '777'  ;
        inbProp.unadjustedMarginAfterRisk = '0' ;
        inbProp.unadjustedMarginBeforeRisk = '0' ;

        ProposalInboundV2.Annual annual = new ProposalInboundV2.Annual();
        annual.year = '2018';
        annual.netPrice =  '777' ;
        annual.netSalesValue =  '777' ;
        annual.unadjustedMarginBeforeRisk = '0' ;
        annual.unadjustedMarginAfterRisk = '0' ;
        annual.economicProfit =  '777' ;
        annual.economicProfitPercent =  '1' ;

        List<ProposalInboundV2.Annual> annualList = new List<ProposalInboundV2.Annual>();
        annualList.add(annual);

        ProposalInboundV2.Product prod = new ProposalInboundV2.Product();
        prod.businessArea =  '777' ;
        prod.commodity =  'TEST' ;
        prod.netPrice =  '777' ;
        prod.netSalesValue =  '777' ;
        prod.productArea =  '777' ;
        prod.productCodeNumber =  'TEST' ;
        //.productGroupNumber = '777' ;
        //prod.productLineNumber = '777'  ;
        prod.recurringNetSalesValue =  '777' ;
        prod.unadjustedMarginAfterRisk = '0' ;
        prod.unadjustedMarginBeforeRisk =  '0' ;

        List<ProposalInboundV2.Product> prodList = new List<ProposalInboundV2.Product>();
        prodList.add(prod);

      
        ProposalInboundV2.CashFlowKpi cashFlowK = new ProposalInboundV2.CashFlowKpi();
        cashFlowK.name =  'CU Target' ;
        cashFlowK.workingCapitalDays =  '777' ;
        cashFlowK.customerDso =  '777' ;
        cashFlowK.costofCapitalOverNetSales =  '777' ;
        List<ProposalInboundV2.CashFlowKpi> cashFlowKList = new List<ProposalInboundV2.CashFlowKpi>();
        cashFlowKList.add(cashFlowK);

        ProposalInboundV2.CashFlow cashFlow = new ProposalInboundV2.CashFlow();
        cashFlow.status =  '777' ;
        cashFlow.breakEvenDate =  '01/13/1991';
        cashFlow.kpis = cashFlowKList;

        ProposalInboundV2.Risk risk = new ProposalInboundV2.Risk();
        risk.riskNumber =  '777' ;
        risk.title =  '777' ;
        risk.impactDescription =  '777' ;
        risk.mitigationPlan = '777';
        risk.mitigationCost = '777';
        risk.quantifiable = '777';

        List<ProposalInboundV2.Risk> riskList = new List<ProposalInboundV2.Risk>();
        riskList.add(risk);

        ProposalInboundV2.RiskAnalysis riskAnalysis = new ProposalInboundV2.RiskAnalysis();
        riskAnalysis.status = '777';
        riskAnalysis.risks = riskList;

        ProposalInboundV2.Escalation escalation = new ProposalInboundV2.Escalation();
        escalation.termsAndConditionsNumber = '777';
        escalation.question = '777';
        escalation.answer = '777';

        List<ProposalInboundV2.Escalation> escalationList = new List<ProposalInboundV2.Escalation>();
        escalationList.add(escalation);

        ProposalInboundV2.ContractEvaluation contractEvaluation = new ProposalInboundV2.ContractEvaluation();
        contractEvaluation.status = '777';
        contractEvaluation.opportunityContactTermsAndConditions = '777';
        contractEvaluation.comment = '777';
        contractEvaluation.escalation = escalationList;

        ProposalInboundV2.IncomeStatement income = new  ProposalInboundV2.IncomeStatement();
        income.annual = annualList;
        ProposalInboundV2.Products prods = new ProposalInboundV2.Products();
        prods.product = prodList;
        ProposalInboundV2.Deviations dev = new  ProposalInboundV2.Deviations();
        
        String response = ProposalInboundV2.insertProposal(inbProp, income, prods, cashFlow, riskAnalysis, contractEvaluation, dev);
      //  System.assertEquals('ERROR Incorrect Opportunity Record Type PD', response);
    }

  /*  @isTest
    public static void upsertSecondPremiumProposalPositive() {
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(),true);
            acc.CustomerReportingGroup__c = crg.Id;
            insert acc;
        }

        Id pricebookId = Test.getStandardPricebookId();
		Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);

        Product2 pro = new Product2(Family = 'Hardware', Name = 'TEST', Product_Code_Number__c = 'TEST');
        insert pro;

		PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = pro.Id, UnitPrice = 12000, IsActive = true, useStandardPrice=false);
        insert pricebookEntry;
		
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id, PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999',
                          Proposal_Deal_Value__c = 0, Unadjusted_margin_after_risk__c = 0));
        insert opp;

        //OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pricebookEntry.Id));
        ///insert oppLine;

        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id), false);
        insert prop;

        ProposalInboundV2.Proposal inbProp = new ProposalInboundV2.Proposal();
        inbProp.approvedDate = '01/13/1991';
        inbProp.approver = 'test';
        inbProp.economicProfit = '1';
        inbProp.economicProfitPercent = '1';
        inbProp.netPrice = '777';
        inbProp.netSalesValue = '777';
        inbProp.opportunityNumber = '777888999';
        inbProp.projectStart = '01/13/1991';
        inbProp.projectEnd = '01/13/1991';
        inbProp.proposalName = '777';
        inbProp.proposalNumber = '777';
        inbProp.proposalVersionNumber = '777' ;
        inbProp.salesComplianceRiskScore = '777'  ;
        inbProp.unadjustedMarginAfterRisk = '0' ;
        inbProp.unadjustedMarginBeforeRisk = '0' ;

        ProposalInboundV2.Annual annual = new ProposalInboundV2.Annual();
        annual.year = '2018';
        annual.netPrice =  '777' ;
        annual.netSalesValue =  '777' ;
        annual.unadjustedMarginBeforeRisk = '0' ;
        annual.unadjustedMarginAfterRisk = '0' ;
        annual.economicProfit =  '777' ;
        annual.economicProfitPercent =  '1' ;

        List<ProposalInboundV2.Annual> annualList = new List<ProposalInboundV2.Annual>();
        annualList.add(annual);

        ProposalInboundV2.Product prod = new ProposalInboundV2.Product();
        prod.businessArea =  '777' ;
        prod.commodity =  'TEST' ;
        prod.netPrice =  '777' ;
        prod.netSalesValue =  '777' ;
        prod.productArea =  '777' ;
        prod.productCodeNumber =  'TEST' ;
        //prod.productGroupNumber = '777' ;
        //prod.productLineNumber = '777'  ;
        prod.recurringNetSalesValue =  '777' ;
        prod.unadjustedMarginAfterRisk = '0' ;
        prod.unadjustedMarginBeforeRisk =  '0' ;

        List<ProposalInboundV2.Product> prodList = new List<ProposalInboundV2.Product>();
        prodList.add(prod);


        ProposalInboundV2.CashFlowKpi cashFlowK = new ProposalInboundV2.CashFlowKpi();
        cashFlowK.name =  'YTD Value' ;
        cashFlowK.workingCapitalDays =  '777' ;
        cashFlowK.customerDso =  '777' ;
        cashFlowK.costofCapitalOverNetSales =  '777' ;
        List<ProposalInboundV2.CashFlowKpi> cashFlowKList = new List<ProposalInboundV2.CashFlowKpi>();
        cashFlowKList.add(cashFlowK);

        ProposalInboundV2.CashFlow cashFlow = new ProposalInboundV2.CashFlow();
        cashFlow.status =  '777' ;
        cashFlow.breakEvenDate =  '01/13/1991';
        cashFlow.kpis = cashFlowKList;

        ProposalInboundV2.Risk risk = new ProposalInboundV2.Risk();
        risk.riskNumber =  '777' ;
        risk.title =  '777' ;
        risk.impactDescription =  '777' ;
        risk.mitigationPlan = '777';
        risk.mitigationCost = '777';
        risk.quantifiable = '777';

        List<ProposalInboundV2.Risk> riskList = new List<ProposalInboundV2.Risk>();
        riskList.add(risk);

        ProposalInboundV2.RiskAnalysis riskAnalysis = new ProposalInboundV2.RiskAnalysis();
        riskAnalysis.status = '777';
        riskAnalysis.risks = riskList;

        ProposalInboundV2.Escalation escalation = new ProposalInboundV2.Escalation();
        escalation.termsAndConditionsNumber = '777';
        escalation.question = '777';
        escalation.answer = '777';

        List<ProposalInboundV2.Escalation> escalationList = new List<ProposalInboundV2.Escalation>();
        escalationList.add(escalation);

        ProposalInboundV2.ContractEvaluation contractEvaluation = new ProposalInboundV2.ContractEvaluation();
        contractEvaluation.status = '777';
        contractEvaluation.opportunityContactTermsAndConditions = '777';
        contractEvaluation.comment = '777';
        contractEvaluation.escalation = escalationList;
        
         ProposalInboundV2.IncomeStatement income = new  ProposalInboundV2.IncomeStatement();
        income.annual = annualList;
        ProposalInboundV2.Products prods = new ProposalInboundV2.Products();
        prods.product = prodList;
        ProposalInboundV2.Deviations dev = new  ProposalInboundV2.Deviations();
        
        String response = ProposalInboundV2.insertProposal(inbProp, income, prods, cashFlow, riskAnalysis, contractEvaluation, dev);
    //    System.assertEquals(GlobalConstants.RESPONSE_SUCCESS_PROPOSAL_INBOUND, response);
        List<Proposal__c> proList = [Select Id from Proposal__c];
        System.assertEquals(1, proList.size());
    }*/
}