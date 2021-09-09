/******************************************************************************************
*       @author       : Ananth
*       @date         : 2/18/2020
@Class Name   : ProposalIncomeStatement


Modification Log   :
------------------------------------------------------------------------------------------
* Ver         Date                     Developer           User Story    Modification
------------------------------------------------------------------------------------------
* 1.0                                Ananth                U-2298        Initial Version  
******************************************************************************************/
global class ProposalIncomeStatement {
    static private String successResponse = GlobalConstants.RESPONSE_SUCCESS_PROPOSAL_INBOUND;
    static private String errorResponse = GlobalConstants.RESPONSE_ERROR_PROPOSAL_INBOUND;
    static private String logNameRequest = GlobalConstants.LOG_NAME_REQUEST_PROPOSAL_INBOUND;
    static private String logNameResponse = GlobalConstants.LOG_NAME_RESPONSE_PROPOSAL_INBOUND;
    static private String logNameError = GlobalConstants.LOG_NAME_ERROR_PROPOSAL_INBOUND;
    private static final String STANDARD_OPPTY_PD = GlobalConstants.STANDARDOPPTYPD;
    private static final String FRAME_AMENDEMNT_OPPTY_PP = GlobalConstants.FRAME_AMENDEMNT_OPPTY_PP;
    private static final String FRAME_AMENDEMNT_OPPTY_PD = GlobalConstants.FRAMEAMENDEMNTOPPTYPD;
    private static final String STANDARD_OPPTY_PP = GlobalConstants.STANDARD_OPPTY_PP;
    private static Boolean isThreshold = false;
    private static String pdGrpName;
    private static String pdGrpBusinessArea;
    private static String pdGrpEscalationLevel;
    global class proposalHeader {
        webservice String opportunityNumber;
        webservice String proposalName;
        webservice String proposalNumber;
        webservice String proposalVersionNumber;
    }
    global class incomeStatementDetails {
        webservice List < annualDetails > annualDetails;
    }
    global class annualDetails {
        webservice String adjustmentsToCostOfSales;
        webservice String businessArea;
        webservice String commodity;
        webservice String costOfSales;
        webservice String discounts;
        webservice String grossPrice;
        webservice String incentives;
        webservice Boolean isRecurring;
        webservice String marketAreaOpex;
        webservice String marketContribution;
        webservice String mitigationCost;
        webservice String netPrice;
        webservice String netSalesValue;
        webservice String productArea;
        webservice String productCodeNumber;
        webservice String productGroup;
        webservice String productLine;
        webservice String riskExposureCostafterMitigations;
        webservice String scenarioDiscounts;
        webservice String unadjustedMarginAfterRisk;
        webservice String unadjustedMarginBeforeRisk;
        webservice String unitPrice;
        webservice String year;
        
    }
    webservice static String insertProposalIncomeStatement(proposalHeader proposalHeader, incomeStatementDetails incomeStatementDetails) {
        Proposal__c inbProposal = null;
        list<Proposal__c> existingSFProList=[select id,CurrencyIsoCode from Proposal__c where Proposal_Id__c=:proposalHeader.proposalNumber and Version__c=:proposalHeader.proposalVersionNumber];
        if (existingSFProList.size() > 0) {
            inbProposal = existingSFProList[0];
        } else {
            EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal, logNameResponse, false, errorResponse + GlobalConstants.SPACE + GlobalConstants.Opportunity_Not_Found_in_Salesforce)));
            return errorResponse + GlobalConstants.SPACE + GlobalConstants.Opportunity_Not_Found_in_Salesforce;
        }   
        List < IncomeStatementDetail__c > pProdList = new List < IncomeStatementDetail__c > ();
        //get the correct Product__c record type id and assign it to the Products
        Id productRecordTypeId = GlobalConstants.PREMIUM_PROPOSAL_Prod_recordTypeId_PD;
        for (annualDetails pp: incomeStatementDetails.annualDetails) {
            IncomeStatementDetail__c inbProduct = new IncomeStatementDetail__c();
            inbProduct.CurrencyIsoCode = inbProposal.CurrencyIsoCode;
            if (!String.isBlank(pp.productCodeNumber))
                inbProduct.ProductCodeNumber__c = pp.productCodeNumber;
            if (!String.isBlank(pp.costofSales))
                inbProduct.CostofSales__c = Decimal.valueOf(pp.costofSales);
            if (!String.isBlank(pp.grossPrice))
                inbProduct.GrossPrice__c = Decimal.valueOf(pp.grossPrice);
            if (!String.isBlank(pp.adjustmentsToCostOfSales))
                inbProduct.AdjustementstoCostofSales__c = Decimal.valueOf(pp.adjustmentsToCostOfSales);
            if (!String.isBlank(pp.mitigationCost))
                inbProduct.MitigationCost__c = Decimal.valueOf(pp.mitigationCost);
            if (!String.isBlank(pp.riskexposureCostafterMitigations))
                inbProduct.RiskExposureCostAfterMitigations__c = Decimal.valueOf(pp.riskexposureCostafterMitigations);              
            if (!String.isBlank(pp.marketAreaOpex))
                inbProduct.MarketAreaOpex__c = Decimal.valueOf(pp.marketAreaOpex);
            if (!String.isBlank(pp.marketcontribution))
                inbProduct.MarketContribution__c = Decimal.valueOf(pp.marketcontribution);
            if (!String.isBlank(pp.year))
                inbProduct.Year__c = Decimal.valueOf(pp.year);              
            if (!String.isBlank(pp.discounts))
                inbProduct.Discounts__c = Decimal.valueOf(pp.discounts);
            if (!String.isBlank(pp.unitPrice))
                inbProduct.UnitPrice__c = Decimal.valueOf(pp.unitPrice);
            if (!String.isBlank(pp.scenarioDiscounts))
                inbProduct.ScenarioDiscounts__c = Decimal.valueOf(pp.scenarioDiscounts);    
            if (!String.isBlank(pp.incentives))
                inbProduct.Incentives__c = Decimal.valueOf(pp.incentives);              
            if (!String.isBlank(pp.productLine))
                inbProduct.ProductLine__c = pp.productLine;
            if (!String.isBlank(pp.productGroup))
                inbProduct.ProductGroup__c = pp.productGroup;
            if (!String.isBlank(pp.productArea))
                inbProduct.Name = pp.productArea;
            if (!String.isBlank(pp.businessArea))
                inbProduct.BusinessArea__c = pp.businessArea;
            if (!String.isBlank(pp.commodity))
                inbProduct.Commodity__c = pp.commodity;
            if (!String.isBlank(pp.netSalesValue))
                inbProduct.NetSalesValue__c = Decimal.valueOf(pp.netSalesValue);
            if (!String.isBlank(pp.unadjustedMarginAfterRisk))
                inbProduct.UnadjustedMarginAfterRisk__c = Decimal.valueOf(pp.unadjustedMarginAfterRisk);
            if (!String.isBlank(pp.unadjustedMarginBeforeRisk))
                inbProduct.UnadjustedMarginBeforeRisk__c = Decimal.valueOf(pp.unadjustedMarginBeforeRisk);
            if (!String.isBlank(pp.netPrice))
                inbProduct.NetPrice__c = Decimal.valueOf(pp.netPrice);
                inbProduct.IsRecurring__c =pp.isRecurring;
            inbProduct.Proposal__c = inbProposal.Id;
            pProdList.add(inbProduct);
        }
        insert pProdList;
        return successResponse;
    }
}