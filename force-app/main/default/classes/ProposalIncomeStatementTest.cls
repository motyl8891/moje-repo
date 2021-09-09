@isTest(seeAllData = false)
private class ProposalIncomeStatementTest {
     @isTest
    public static void insertPremiumProposalPIncome() {
        Try{
             Test.setMock(HttpCalloutMock.class, new MockGSTHttpResponseGenerator());
            Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com' + System.currentTimeMillis()), true);
        System.runAs(testUser) {
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
        Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id, Version__c = '77',name='Test prop',Proposal_Id__c='123456'), false);
        insert prop;
            Proposal__c insertProp=[select id,Opportunity__c,Proposal_Id__c,Version__c,Name from Proposal__c];
            system.debug('insertProp'+insertProp);

            ProposalIncomeStatement.proposalHeader inPropHeader = new ProposalIncomeStatement.proposalHeader();
            inPropHeader.opportunityNumber = '35133919';
            inPropHeader.proposalName = 'Test Proposal 1';
            inPropHeader.proposalNumber = insertProp.Proposal_Id__c;
            inPropHeader.proposalVersionNumber = insertProp.Version__c;
             
            ProposalIncomeStatement.annualDetails annDetails = new ProposalIncomeStatement.annualDetails();
            annDetails.adjustmentsToCostOfSales = '77';
            annDetails.businessArea = 'BNEW';
            annDetails.commodity = '56';
            annDetails.discounts = '23';
            annDetails.grossPrice = '777';
            annDetails.incentives = '315';
            annDetails.isRecurring = true;
            annDetails.marketAreaOpex = '78';
            annDetails.marketContribution = '235';
            annDetails.mitigationCost = '134';
            annDetails.netPrice =  '777';
            annDetails.netSalesValue = '777';
            annDetails.productArea = 'PMIT';
            annDetails.productCodeNumber = '31';
            annDetails.productGroup = 'IT MS & ADM';
           annDetails.riskExposureCostafterMitigations = '100';
            annDetails.unitPrice = '214';
            annDetails.costOfSales = '322.234';
            annDetails.year = '2019'; 
            annDetails.scenarioDiscounts = '141.32';
            annDetails.productLine = 'Test Product Line';
            annDetails.unadjustedMarginAfterRisk = '214.4';
            annDetails.unadjustedMarginBeforeRisk = '134.41';
          
            List<ProposalIncomeStatement.annualDetails> annualDetailsList = new List<ProposalIncomeStatement.annualDetails>();
            annualDetailsList.add(annDetails);
            
            ProposalIncomeStatement.incomeStatementDetails  incomeStatementDetails= new ProposalIncomeStatement.incomeStatementDetails();
            incomeStatementDetails.annualDetails = annualDetailsList;
            
          
           /* Proposal__c prop  = new Proposal__c();
            prop.Proposal_Id__c = inPropHeader.proposalNumber;
            prop.Version__c   = inPropHeader.proposalVersionNumber;
            insert prop;*/
             Test.startTest();
            IncomeStatementDetail__c pprod = new IncomeStatementDetail__c();
            pprod.ProductCodeNumber__c = annDetails.productCodeNumber;
            pprod.CostofSales__c =  Decimal.valueOf(annDetails.costOfSales);
            pprod.GrossPrice__c = Decimal.valueOf(annDetails.grossPrice);
            pprod.AdjustementstoCostofSales__c =  Decimal.valueOf(annDetails.adjustmentsToCostOfSales);
            pprod.MitigationCost__c = Decimal.valueOf(annDetails.mitigationCost);
            pprod.RiskExposureCostAfterMitigations__c  =Decimal.valueOf(annDetails.riskExposureCostafterMitigations);
            pprod.MarketAreaOpex__c = Decimal.valueOf(annDetails.marketAreaOpex);
            pprod.MarketContribution__c = Decimal.valueOf(annDetails.marketContribution);
            pprod.Year__c = Decimal.valueOf(annDetails.year);
			pprod.Discounts__c =  Decimal.valueOf(annDetails.discounts);    
            pprod.UnitPrice__c = Decimal.valueOf(annDetails.unitPrice);
            pprod.ScenarioDiscounts__c = Decimal.valueOf(annDetails.scenarioDiscounts);
            pprod.Incentives__c = Decimal.valueOf(annDetails.incentives);
            pprod.ProductLine__c =  annDetails.productLine;
            pprod.ProductGroup__c = annDetails.productGroup;
            pprod.Name = annDetails.productArea;
            pprod.BusinessArea__c = annDetails.businessArea;
            pprod.Commodity__c = annDetails.commodity;
            pprod.NetSalesValue__c = Decimal.valueOf(annDetails.netSalesValue);
            pprod.UnadjustedMarginAfterRisk__c = Decimal.valueOf(annDetails.unadjustedMarginAfterRisk);
            pprod.UnadjustedMarginBeforeRisk__c = Decimal.valueOf(annDetails.unadjustedMarginBeforeRisk);
            pprod.NetPrice__c = Decimal.valueOf(annDetails.netPrice);  
            insert pprod;
            
            String response = ProposalIncomeStatement.insertProposalIncomeStatement(inPropHeader, incomeStatementDetails);
            Test.stopTest();
             System.assert(true);
        }
        catch(Exception ex)
        {system.debug('**error'+ex.getStackTraceString());
            
        }
    
    }
    

}