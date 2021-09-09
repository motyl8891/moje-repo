global class ProposalInboundV2{
    
    static private String successResponse = GlobalConstants.RESPONSE_SUCCESS_PROPOSAL_INBOUND;
    static private String errorResponse = GlobalConstants.RESPONSE_ERROR_PROPOSAL_INBOUND;
    static private String logNameRequest = GlobalConstants.LOG_NAME_REQUEST_PROPOSAL_INBOUND;
    static private String logNameResponse = GlobalConstants.LOG_NAME_RESPONSE_PROPOSAL_INBOUND;
    static private String logNameError = GlobalConstants.LOG_NAME_ERROR_PROPOSAL_INBOUND;
    private static final String STANDARD_OPPTY_PD = GlobalConstants.STANDARDOPPTYPD;
    private static final String FRAME_AMENDEMNT_OPPTY_PP = GlobalConstants.FRAME_AMENDEMNT_OPPTY_PP;
    private static final String FRAME_AMENDEMNT_OPPTY_PD = GlobalConstants.FRAMEAMENDEMNTOPPTYPD;
    private static final String STANDARD_OPPTY_PP = GlobalConstants.STANDARD_OPPTY_PP;
    private static Boolean isThreshold=false;
    private static String pdGrpName;
    private static String pdGrpBusinessArea;
    private static String pdGrpEscalationLevel;
    private static Integer nonDelegatedBA=0;
    private static Integer newComplexBA=0;
    private static Integer priceErosionBA=0;
    private static Integer pricePositioningBA=0;
    private static Integer incentiveBA=0;
    private static Integer comparisionPriceBA=0;
    private static Integer profitabilityBA=0;
    global class Proposal {
        webservice String approvedDate;
        webservice String approver;
        webservice String economicProfit;
        webservice String economicProfitPercent;
        webservice String grossPrice;
        webservice String unitPrice;
        webservice String netPrice;
        webservice String netSalesValue;
        webservice String opportunityNumber;
        webservice String projectStart;
        webservice String projectEnd;
        webservice String proposalName;
        webservice String proposalNumber;
        webservice String proposalVersionNumber;
        webservice String proposalLink;
        webservice String salesComplianceRiskScore;
        webservice String unadjustedMarginAfterRisk;
        webservice String unadjustedMarginBeforeRisk;
    }
    global class IncomeStatement {
        webservice List<Annual> annual;
    }  
    global class Annual {
        webservice String year;
        webservice String netPrice;
        webservice String netSalesValue;
        webservice String unadjustedMarginBeforeRisk;
        webservice String unadjustedMarginAfterRisk;
        webservice String economicProfit;
        webservice String economicProfitPercent;
    }
    global class Products
    {
        webservice List<Product> product;
    }
    global class Product {
        webservice String businessArea;
        webservice String commodity;
        webservice String netPrice;
        webservice String netSalesValue;
        webservice String productArea;
        webservice String productCodeNumber;
        webservice String productGroup;
        webservice String productLine;
        webservice String recurringNetSalesValue;
        webservice String unadjustedMarginAfterRisk;
        webservice String unadjustedMarginBeforeRisk;
    }
    
    /* global class ProductGroupDeviation {
webservice String name;
webservice String aaPriceObject;
webservice String aaPriceObjectPercent;
webservice String price;
webservice String pricePercent;
webservice String priceRecurring;
webservice String priceRecurringPercent;
webservice String productGroup;
webservice String unadjustedMarginAfterRisk;
webservice String unadjustedMarginAfterRiskPercent;
webservice String unadjustedMarginAfterRiskPercentEscalation;
webservice String businessarea;
webservice String escalationlevel;
webservice String question;
webservice String answer;
}*/
    
    global class CashFlow {
        webservice String status;
        webservice String breakEvenDate;
        webservice String isDeviatingFromEBD;
        webservice String Comment;
        webservice List<CashFlowKpi> kpis;
    }
    
    global class CashFlowKpi { 
        webservice String name;
        webservice String workingCapitalDays;
        webservice String customerDso;
        webservice String costofCapitalOverNetSales;
    }
    
    global class RiskAnalysis {
        webservice String status;
        webservice List<Risk> risks;
    }
    
    global class Risk {
        webservice String riskNumber;
        webservice String title;
        webservice String impactDescription;
        webservice String mitigationPlan;
        webservice String mitigationCost;
        webservice String quantifiable;
    }
    
    global class ContractEvaluation {
        webservice String status;
        webservice String opportunityContactTermsAndConditions;
        webservice String comment;
        webservice String ceLastUpdatedBy;
        webservice String cePreparedBy;
        webservice List<Escalation> escalation;
    }
    
    global class Escalation {
        webservice String termsAndConditionsNumber;
        webservice String question;
        webservice String answer;
        webservice String answerComments;
        webservice String contractQuestionCategory;
        webservice String deviationConsequence;
        //webservice String ceLastUpdatedBy;
        //webservice String cePreparedBy;
        webservice String deviationType;
        webservice String businessArea;
        webservice String comment;
    }
    global class Deviations{
        webservice Pricing pricing;
        webservice Profitability profitability;
        webservice CommercialTermsAndConditions commercialTermsAndConditions;
        webservice NonDelegatedAndComplexAndNewTechnologies nonDelegatedAndComplexAndNewTechnologies;
    }
    global class Pricing{
        webservice PriceErosion priceErosion;
        webservice PricePositioning pricePositioning;
        webservice Incentive incentive;
        webservice ComparisonPrice comparisonPrice;
    }
    global class PriceErosion{
        webservice List<ProductGroup> productGroup;
    }
    global class PricePositioning{
        webservice List<ProductGroup> productGroup;
    }
    global class Incentive{
        webservice List<ProductGroup> productGroup;
    }
    global class ComparisonPrice{
        webservice List<ProductGroup> productGroup;
    }
    global class Profitability{
        webservice UnAdjustedMarginAfterRisk unAdjustedMarginAfterRisk;
    }
    global class UnAdjustedMarginAfterRisk{
        webservice List<ProductGroup> productGroup;
    }
    global class CommercialTermsAndConditions{
        webservice CashFlow cashFlow;
        webservice ContractEvaluation contractEvaluation;
    }
    global class NonDelegatedAndComplexAndNewTechnologies{
        webservice List<Escalation> escalation;
        webservice String status;
    }
    global class ProductGroup{
        webservice String name;
        webservice String businessArea;
        webservice String escalationLevel;
        webservice String netDeviationEscalationLevel;
        webservice String effectiveNetDeviationEscalationLevel;
        webservice String aaPriceObjectEscalationLevel;
        webservice String sspsEscalationLevel;
    }
    webservice static String insertProposal(Proposal proposal,
                                            IncomeStatement incomeStatement,
                                            Products products,
                                            CashFlow cashFlow,
                                            RiskAnalysis riskAnalysis,
                                            ContractEvaluation contractEvaluation,
                                            Deviations deviations) {
                                                String uniqueId = GeneralUtils.generateRandomString(30);
                                                logNameRequest += GlobalConstants.SPACE + String.valueOf(uniqueId);
                                                EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound,GlobalConstants.upsertProposal, logNameRequest, false, JSON.serialize(proposal))));
                                                Savepoint sp = Database.setSavepoint();
                                                
                                                try {
                                                    Opportunity existingSFOpp = null;
                                                    List<Opportunity> existingSFOppList = [SELECT Id, Override_Deal_Value_and_Margin__c,MarketArea__c , Locked_to_PP__c, RecordType.Name, CurrencyIsoCode,Is_Pilot_Group__c,
                                                                                           (Select Id, Primary__c From Proposal__r)
                                                                                           FROM Opportunity
                                                                                           WHERE OpportunityNumber__c = :proposal.opportunityNumber];
                                                    if (existingSFOppList.size() > 0) {
                                                        existingSFOpp = existingSFOppList[0];
                                                    } else {
                                                        EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound,GlobalConstants.upsertProposal, logNameResponse, false, errorResponse +GlobalConstants.SPACE+GlobalConstants.Opportunity_Not_Found_in_Salesforce)));
                                                        return errorResponse +GlobalConstants.SPACE + GlobalConstants.Opportunity_Not_Found_in_Salesforce;
                                                    }
                                                    List<Proposal__c> existingProposalList = [SELECT Id FROM Proposal__c
                                                                                              WHERE Proposal_Id__c = :proposal.proposalNumber
                                                                                              AND Version__c = :proposal.proposalVersionNumber];
                                                    if (existingProposalList.size() > 0) {
                                                        EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound,GlobalConstants.upsertProposal, logNameResponse, false, successResponse + GlobalConstants.SPACE + GlobalConstants.Proposal_Version_already_exists_in_Salesforce)));
                                                        return successResponse + GlobalConstants.COLON + GlobalConstants.Proposal_Version_already_exists_in_Salesforce;
                                                    }
                                                    
                                                    // Create the proposal, which populates the master-detail relationship
                                                    // to Opportunity with the external ID reference to Opportunity Number
                                                    Proposal__c inbProposal = new Proposal__c(Opportunity__c = existingSFOpp.Id);
                                                    //setting RT Id to Premium Proposal
                                                    Id recordTypeId = GlobalConstants.PREMIUM_PROPOSALrecordTypeId_PD;
                                                    inbProposal.RecordTypeId = recordTypeId;
                                                    // Generate Proposal Unique ID using concatenation of Opportunity Number and SDP Value
                                                    inbProposal.Proposal_Unique_Id__c = proposal.proposalNumber + GlobalConstants.UNDERSCORE + proposal.proposalVersionNumber; 
                                                    //setting Proposal Currency to same as on Opportunity
                                                    inbProposal.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                    // Populate other proposal fields
                                                    if(proposal.proposalName != null && proposal.proposalName.length() > 80){proposal.proposalName = proposal.proposalName.subString(0,80);}
                                                    inbProposal.Name = proposal.proposalName; 
                                                    inbProposal.Proposal_Id__c = proposal.proposalNumber;          
                                                    inbProposal.Version__c = proposal.proposalVersionNumber;
                                                    //if(proposal.projectStart != null)inbProposal.Delivery_Start_Date__c = Date.valueOf(proposal.projectStart);
                                                    if(!String.isBlank(proposal.projectStart))inbProposal.Delivery_Start_Date__c = parseToDate(proposal.projectStart);
                                                    //if(proposal.projectEnd != null)inbProposal.Delivery_End_Date__c = Date.valueOf(proposal.projectEnd);
                                                    if(!String.isBlank(proposal.projectEnd))inbProposal.Delivery_End_Date__c = parseToDate(proposal.projectEnd);
                                                    if(!String.isBlank(proposal.netPrice))inbProposal.Net_Price__c = Decimal.valueOf(proposal.netPrice);
                                                    if(!String.isBlank(proposal.grossPrice))inbProposal.Gross_Price__c= Decimal.valueOf(proposal.grossPrice);
                                                    if(!String.isBlank(proposal.unitPrice))inbProposal.Unit_Price__c = Decimal.valueOf(proposal.unitPrice);
                                                    if(!String.isBlank(proposal.netSalesValue))inbProposal.Effective_Net_Price__c = Decimal.valueOf(proposal.netSalesValue);
                                                    if(!String.isBlank(proposal.unadjustedMarginBeforeRisk))inbProposal.UMBR__c = Decimal.valueOf(proposal.unadjustedMarginBeforeRisk);
                                                    if(!String.isBlank(proposal.unadjustedMarginAfterRisk))inbProposal.UMAR__c = Decimal.valueOf(proposal.unadjustedMarginAfterRisk);
                                                    if(!String.isBlank(proposal.economicProfit))inbProposal.Economic_Profit__c = Decimal.valueOf(proposal.economicProfit);
                                                    if(!String.isBlank(proposal.economicProfitPercent))inbProposal.Economic_Profit_Percent__c = Decimal.valueOf(proposal.economicProfitPercent);
                                                    if(!String.isBlank(proposal.salesComplianceRiskScore))inbProposal.Sensitive_Business_Value__c = proposal.salesComplianceRiskScore;
                                                    if(!String.isBlank(proposal.proposalLink))inbProposal.PD_Proposal_Link__c= proposal.proposalLink;
                                                    if(!String.isBlank(riskAnalysis.status))inbProposal.Risk_Analysis_Status__c = riskAnalysis.status; 
                                                    if(!String.isBlank(contractEvaluation.status))inbProposal.Contract_Evaluation_Status__c = contractEvaluation.status;
                                                    if(!String.isBlank(Deviations.NonDelegatedAndComplexAndNewTechnologies.status))inbProposal.NonDelAndComplexAndNewTechStatus__c = Deviations.NonDelegatedAndComplexAndNewTechnologies.status;
                                                    if(!String.isBlank(contractEvaluation.opportunityContactTermsAndConditions))inbProposal.Contract_Evaluation_Opp_Contact_T_Cs__c = contractEvaluation.opportunityContactTermsAndConditions;
                                                    if(contractEvaluation.comment != null && contractEvaluation.comment.length() > 131071){contractEvaluation.comment = contractEvaluation.comment.subString(0,131071);}
                                                    if(!String.isBlank(contractEvaluation.comment))inbProposal.Contract_Evaluation_Comment__c = contractEvaluation.comment;
                                                    if(!String.isBlank(contractEvaluation.ceLastUpdatedBy))inbProposal.Last_edited_by__c = contractEvaluation.ceLastUpdatedBy;
                                                    if(!String.isBlank(contractEvaluation.cePreparedBy))inbProposal.Prepared_By__c = contractEvaluation.cePreparedBy;
                                                    if(!String.isBlank(cashFlow.status))inbProposal.Cash_Flow_Status__c = cashFlow.status;
                                                    //if(cashFlow.breakEvenDate != null)inbProposal.Cash_Flow_Break_Even_Date__c = Date.valueOf(cashFlow.breakEvenDate);
                                                    if(!String.isBlank(cashFlow.breakEvenDate))inbProposal.Cash_Flow_Break_Even_Date__c = parseToDate(cashFlow.breakEvenDate);
                                                    if(!String.isBlank(cashFlow.isDeviatingFromEBD))inbProposal.Cashflow_IsDeviatingFromEBD__c = cashFlow.isDeviatingFromEBD;
                                                    if(cashFlow.Comment != null && cashFlow.Comment.length() > 131071){cashFlow.Comment = cashFlow.Comment.subString(0,131071);}                                             
                                                    if(!String.isBlank(cashFlow.Comment))inbProposal.Cashflow_Analysis_Comment__c = cashFlow.Comment;
                                                    //setting values from CashFlowKPI list to Proposal__c fields
                                                    if(cashFlow.kpis != null){
                                                        for(CashFlowKpi cfkpi: cashFlow.kpis){
                                                            if(cfkpi.Name== GlobalConstants.OPPORTUNITY){
                                                                if(!String.isBlank(cfkpi.workingCapitalDays)){
                                                                    Decimal toroundWrkgCapDays = Decimal.valueof((cfkpi.workingCapitalDays).trim());
                                                                    Decimal roundedWrkgCapDays = toroundWrkgCapDays.setScale(0, RoundingMode.HALF_UP);
                                                                    inbProposal.Cash_Flow_Opp_WCD__c = String.valueof(roundedWrkgCapDays);
                                                                }
                                                                if(!String.isBlank(cfkpi.costOfCapitalOverNetSales)){                       
                                                                    
                                                                    Decimal toroundCashFlwOppCoCNetSales = Decimal.valueof((cfkpi.costOfCapitalOverNetSales).trim());
                                                                    Decimal roundedCashFlwOppCoCNetSales = 100*toroundCashFlwOppCoCNetSales.setScale(8, RoundingMode.HALF_UP);
                                                                    inbProposal.Cash_Flow_Opp_CoC_Net_Sales__c = String.valueof(roundedCashFlwOppCoCNetSales) + GlobalConstants.PERCENT;
                                                                }
                                                                if(!String.isBlank(cfkpi.customerDso)){
                                                                    Decimal toroundCustDso = Decimal.valueof((cfkpi.customerDso).trim());
                                                                    Decimal roundedCustDso = toroundCustDso.setScale(0, RoundingMode.HALF_UP);
                                                                    inbProposal.Cash_Flow_Opportunity_Customer_DSO__c = String.valueof(roundedCustDso);
                                                                }
                                                            }
                                                            else if(cfkpi.Name== GlobalConstants.CU_Target){
                                                                if(!String.isBlank(cfkpi.workingCapitalDays))inbProposal.Cash_Flow_CU_Target_WCD__c = cfkpi.workingCapitalDays;
                                                            }
                                                            else if(cfkpi.Name== GlobalConstants.YTD_Value){
                                                                if(!String.isBlank(cfkpi.workingCapitalDays)){
                                                                    Decimal toroundWrkgCapDays = Decimal.valueof((cfkpi.workingCapitalDays).trim());
                                                                    Decimal roundedWrkgCapDays = toroundWrkgCapDays.setScale(0, RoundingMode.HALF_UP);
                                                                    inbProposal.Cash_Flow_YTD_Value_WCD__c = String.valueof(roundedWrkgCapDays);
                                                                }
                                                                if(!String.isBlank(cfkpi.customerDso)){
                                                                    Decimal toroundCustDso = Decimal.valueof((cfkpi.customerDso).trim());
                                                                    Decimal roundedCustDso = toroundCustDso.setScale(0, RoundingMode.HALF_UP);
                                                                    inbProposal.Cash_Flow_YTD_Value_Customer_DSO__c = String.valueof(roundedCustDso);
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    //set Opportunity Locked to PP to true
                                                    if (existingSFOpp.RecordType.Name == FRAME_AMENDEMNT_OPPTY_PD || existingSFOpp.RecordType.Name == STANDARD_OPPTY_PD) {
                                                        EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal, logNameResponse, false, errorResponse + GlobalConstants.SPACE + GlobalConstants.Incorrect_Opportunity_Record_Type_PD)));
                                                        return errorResponse + GlobalConstants.SPACE + GlobalConstants.Incorrect_Opportunity_Record_Type_PD;
                                                    } else {
                                                        setLockedToPP(existingSFOpp);
                                                    }
                                                    
                                                    //Determine if related Opportunity is in approval process or not and assign Primary value
                                                    //Primary = true if Opportunity is not in approval process, else if Opportunity is in approval process, Primary = false
                                                    List<ProcessInstance> piList = [SELECT Id, TargetObjectId, Status
                                                                                    FROM ProcessInstance
                                                                                    WHERE TargetObjectId =: existingSFOpp.Id];
                                                    Boolean isInApprovalProcess = false;
                                                    
                                                    if(piList.size()>0){
                                                        for(ProcessInstance pi: piList){
                                                            if(pi.Status == GlobalConstants.Pending) {
                                                                
                                                                isInApprovalProcess=true;
                                                                break;
                                                            }
                                                            
                                                        } 
                                                    }
                                                    
                                                    List<Proposal__c> oppProposalList = [SELECT Id FROM Proposal__c WHERE Opportunity__c = : existingSFOpp.Id];
                                                    Map<Proposal__c, List<Product__c>> versionZeroMap = new Map<Proposal__c, List<Product__c>>();
                                                    if (oppProposalList.size() == 0 && !isInApprovalProcess) {
                                                        versionZeroMap = ProposalUtils.createVersionZero(existingSFOpp.Id);
                                                    }
                                                    
                                                    if (!isInApprovalProcess) {
                                                        //updating all existing related to opportunity proposals to primary false // not needed anymore - logic for unchecking moved to Proposal Trigger in defect 1385
                                                        /*for (Proposal__c oppProp : existingSFOpp.Proposal__r) {
oppProp.Primary__c = false;
}
update existingSFOpp.Proposal__r;*/
                                                        
                                                        //checking inbound proposal as primary
                                                        inbProposal.Primary__c = true;
                                                        
                                                        //updating opportunity with primary proposal number
                                                        existingSFOpp.Primary_Proposal_Number__c = proposal.proposalNumber;
                                                        update existingSFOpp;
                                                    } else {
                                                        inbProposal.Primary__c = false;
                                                    }
                                                    insert inbProposal;
                                                    
                                                    // Insert the new list of products from inbound proposal message
                                                    List<Product__c> pProdList = new List<Product__c>();
                                                    //get the correct Product__c record type id and assign it to the Products
                                                    Id productRecordTypeId = GlobalConstants.PREMIUM_PROPOSAL_Prod_recordTypeId_PD;
                                                    for (Product pp : products.product) {
                                                        Product__c inbProduct = new Product__c();
                                                        inbProduct.RecordTypeId = productRecordTypeId;
                                                        //setting Proposal Currency to same as on Opportunity
                                                        inbProduct.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                        //setting other Product__c fields
                                                        if(!String.isBlank(pp.productCodeNumber))inbProduct.Product_Code__c = pp.productCodeNumber;
                                                        if(!String.isBlank(pp.productLine))inbProduct.Product_Line__c = pp.productLine;
                                                        if(!String.isBlank(pp.productGroup))inbProduct.Product_Group__c = pp.productGroup;
                                                        if(!String.isBlank(pp.productArea))inbProduct.Name = pp.productArea;
                                                        if(!String.isBlank(pp.businessArea))inbProduct.Business_Area__c = pp.businessArea;
                                                        if(!String.isBlank(pp.commodity))inbProduct.Commodity__c = pp.commodity;
                                                        if(!String.isBlank(pp.netSalesValue))inbProduct.Commodity_Value__c = Decimal.valueOf(pp.netSalesValue);
                                                        if(!String.isBlank(pp.unadjustedMarginAfterRisk))inbProduct.UMAR__c = Decimal.valueOf(pp.unadjustedMarginAfterRisk);
                                                        if(!String.isBlank(pp.unadjustedMarginBeforeRisk))inbProduct.UMBR__c = Decimal.valueOf(pp.unadjustedMarginBeforeRisk);
                                                        if(!String.isBlank(pp.recurringNetSalesValue))inbProduct.Recurring_Net_Sales_Value__c = Decimal.valueOf(pp.recurringNetSalesValue);
                                                        if(!String.isBlank(pp.netPrice))inbProduct.Net_Price__c = Decimal.valueOf(pp.netPrice);
                                                        inbProduct.Proposal__c = inbProposal.Id;
                                                        pProdList.add(inbProduct);
                                                    }
                                                    insert pProdList;
                                                    
                                                    List<Proposal__c> propList = new List<Proposal__c>();
                                                    if (inbProposal.Primary__c == true && (versionZeroMap != null && !versionZeroMap.isEmpty())) {
                                                        propList.add(inbProposal);
                                                        ProposalUtils.replaceProducts_queryProductsFirst(propList);
                                                    }else if(!existingSFOpp.Override_Deal_Value_and_Margin__c && inbProposal.Primary__c == true){
                                                        propList.add(inbProposal);
                                                        ProposalUtils.replaceProducts_queryProductsFirst(propList);
                                                    }
                                                    
                                                    //// Insert Deviation__c records from inbound proposal message
                                                    /* List<Deviation__c> deviationInsertList = new List<Deviation__c>();
for(ProductGroupDeviation pgd :productGroupDeviation){
Deviation__c inbDeviation = new Deviation__c();
inbDeviation.Proposal__c = inbProposal.Id;
inbDeviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
if(!String.isBlank(pgd.productGroup))inbDeviation.Product_Group__c = pgd.productGroup;
if(!String.isBlank(pgd.price))inbDeviation.Price__c = Decimal.valueOf(pgd.price);
if(!String.isBlank(pgd.pricePercent))inbDeviation.Price_Percent__c = Decimal.valueOf(pgd.pricePercent);
if(!String.isBlank(pgd.priceRecurring))inbDeviation.Price_Recurring__c = Decimal.valueOf(pgd.priceRecurring);
if(!String.isBlank(pgd.priceRecurringPercent))inbDeviation.Price_Recurring_Percent__c = Decimal.valueOf(pgd.priceRecurringPercent);
if(!String.isBlank(pgd.aaPriceObject))inbDeviation.AA_Price_Object__c = Decimal.valueOf(pgd.aaPriceObject);
if(!String.isBlank(pgd.aaPriceObjectPercent))inbDeviation.AA_Price_Object_Percent__c = Decimal.valueOf(pgd.aaPriceObjectPercent);
if(!String.isBlank(pgd.unadjustedMarginAfterRisk))inbDeviation.UMAR__c = Decimal.valueOf(pgd.unadjustedMarginAfterRisk);
if(!String.isBlank(pgd.unadjustedMarginAfterRiskPercent))inbDeviation.UMAR_Percent__c = Decimal.valueOf(pgd.unadjustedMarginAfterRiskPercent);
if(!String.isBlank(pgd.unadjustedMarginAfterRiskPercentEscalation))inbDeviation.UMAR_Percent_Escalation__c = pgd.unadjustedMarginAfterRiskPercentEscalation; 
deviationInsertList.add(inbDeviation);
}
insert deviationInsertList;*/
                                                    
                                                    //// Insert Deviation__c records from inbound proposal message
                                                    List<Deviation__c> deviationList = new List<Deviation__c>();
                                                    if(Deviations.pricing != null)
                                                    {
                                                        if(Deviations.pricing.priceErosion != null && Deviations.pricing.priceErosion.productGroup != null)
                                                        {
                                                            for(ProductGroup productgroup : Deviations.pricing.priceErosion.productGroup)
                                                            {
                                                                Deviation__c deviation = new Deviation__c();
                                                                deviation.Proposal__c = inbProposal.Id;
                                                                deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                                deviation.DeviationType__c = GlobalConstants.Price_Erosion;
                                                                if(!String.isBlank(productgroup.name))deviation.Product_Group__c = productgroup.name;
                                                                if(!String.isBlank(productgroup.businessArea))deviation.BusinessArea__c = productgroup.businessArea;
                                                                if(!String.isBlank(productgroup.escalationLevel))deviation.EscalationLevel__c = productgroup.escalationLevel;
                                                                if(productgroup.escalationLevel == GlobalConstants.Threshold_1) {
                                                                    if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                    }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                                }
                                                                if(productgroup.escalationLevel == GlobalConstants.Threshold_2) {
                                                                    deviation.ApprovingUnit__c = productgroup.businessArea;
                                                                    isThreshold=true;
                                                                    pdGrpName=productgroup.name;
                                                                    pdGrpBusinessArea=productgroup.businessArea;
                                                                    pdGrpEscalationLevel=productgroup.escalationLevel;
                                                                }
                                                                deviationList.add(deviation);
                                                            }
                                                            if(isThreshold && priceErosionBA==0){
                                                                deviationList.add(VisualizeDeviation.createMARecord(inbProposal, existingSFOpp, pdGrpName, pdGrpBusinessArea, pdGrpEscalationLevel, GlobalConstants.Price_Erosion));
                                                                isThreshold=false;pdGrpName=GlobalConstants.BLANK;pdGrpBusinessArea=GlobalConstants.BLANK;pdGrpEscalationLevel=GlobalConstants.BLANK;priceErosionBA++;
                                                            }
                                                        } 
                                                        if(Deviations.pricing.pricePositioning != null && Deviations.pricing.pricePositioning.productGroup != null)
                                                        {
                                                            for(ProductGroup productgroup : Deviations.pricing.pricePositioning.productGroup)
                                                            {
                                                                Deviation__c deviation = new Deviation__c();
                                                                deviation.Proposal__c = inbProposal.Id;
                                                                deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                                deviation.DeviationType__c = GlobalConstants.Price_Positioning;
                                                                if(!String.isBlank(productgroup.name))deviation.Product_Group__c = productgroup.name;
                                                                if(!String.isBlank(productgroup.businessArea))deviation.BusinessArea__c = productgroup.businessArea;
                                                                if(!String.isBlank(productgroup.escalationLevel))deviation.EscalationLevel__c = productgroup.escalationLevel;
                                                                if(productgroup.escalationLevel == GlobalConstants.Threshold_1) {
                                                                    if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                    }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                                }
                                                                if(productgroup.escalationLevel == GlobalConstants.Threshold_2) {
                                                                    deviation.ApprovingUnit__c = productgroup.businessArea;
                                                                    isThreshold=true;
                                                                    pdGrpName=productgroup.name;
                                                                    pdGrpBusinessArea=productgroup.businessArea;
                                                                    pdGrpEscalationLevel=productgroup.escalationLevel;
                                                                }
                                                                deviationList.add(deviation);
                                                            }
                                                            if(isThreshold && pricePositioningBA==0){
                                                                deviationList.add(VisualizeDeviation.createMARecord(inbProposal, existingSFOpp, pdGrpName, pdGrpBusinessArea, pdGrpEscalationLevel, GlobalConstants.Price_Positioning));
                                                                isThreshold=false;pdGrpName=GlobalConstants.BLANK;pdGrpBusinessArea=GlobalConstants.BLANK;pdGrpEscalationLevel=GlobalConstants.BLANK;pricePositioningBA++;
                                                            }
                                                        }
                                                        if(Deviations.pricing.incentive != null && Deviations.pricing.incentive.productGroup != null)
                                                        {
                                                            for(ProductGroup productgroup : Deviations.pricing.incentive.productGroup)
                                                            {
                                                                Deviation__c deviation = new Deviation__c();
                                                                deviation.Proposal__c = inbProposal.Id;
                                                                deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                                deviation.DeviationType__c = GlobalConstants.Incentive;
                                                                if(!String.isBlank(productgroup.name))deviation.Product_Group__c = productgroup.name;
                                                                if(!String.isBlank(productgroup.businessArea))deviation.BusinessArea__c = productgroup.businessArea;
                                                                if(!String.isBlank(productgroup.escalationLevel))deviation.EscalationLevel__c = productgroup.escalationLevel;
                                                                if(productgroup.escalationLevel == GlobalConstants.Threshold_1) {
                                                                    if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                    }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                                }
                                                                if(productgroup.escalationLevel == GlobalConstants.Threshold_2) {
                                                                    deviation.ApprovingUnit__c = productgroup.businessArea;
                                                                    isThreshold=true;
                                                                    pdGrpName=productgroup.name;
                                                                    pdGrpBusinessArea=productgroup.businessArea;
                                                                    pdGrpEscalationLevel=productgroup.escalationLevel;
                                                                }
                                                                deviationList.add(deviation);
                                                            }
                                                            if(isThreshold && incentiveBA==0){
                                                                deviationList.add(VisualizeDeviation.createMARecord(inbProposal, existingSFOpp, pdGrpName, pdGrpBusinessArea, pdGrpEscalationLevel, GlobalConstants.Incentive));
                                                                isThreshold=false;pdGrpName=GlobalConstants.BLANK;pdGrpBusinessArea=GlobalConstants.BLANK;pdGrpEscalationLevel=GlobalConstants.BLANK;incentiveBA++;
                                                            }
                                                        } 
                                                        if(Deviations.pricing.comparisonPrice != null && Deviations.pricing.comparisonPrice.productGroup != null)
                                                        {
                                                            for(ProductGroup productgroup : Deviations.pricing.comparisonPrice.productGroup)
                                                            {
                                                                Deviation__c deviation = new Deviation__c();
                                                                deviation.Proposal__c = inbProposal.Id;
                                                                deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                                deviation.DeviationType__c = GlobalConstants.Comparison_Price;
                                                                if(!String.isBlank(productgroup.name))deviation.Product_Group__c = productgroup.name;
                                                                if(!String.isBlank(productgroup.businessArea))deviation.BusinessArea__c = productgroup.businessArea;
                                                                if(!String.isBlank(productgroup.netDeviationEscalationLevel))deviation.NetDeviationEscalationLevel__c = productgroup.netDeviationEscalationLevel;
                                                                if(!String.isBlank(productgroup.effectiveNetDeviationEscalationLevel))deviation.EffectiveNetDeviationEscalationLevel__c = productgroup.effectiveNetDeviationEscalationLevel;
                                                                if(!String.isBlank(productgroup.aaPriceObjectEscalationLevel))deviation.AAPriceObjectEscalationLevel__c = productgroup.aaPriceObjectEscalationLevel;
                                                                if(!String.isBlank(productgroup.sspsEscalationLevel))deviation.SSPSEscalationLevel__c = productgroup.sspsEscalationLevel;
                                                                if(productgroup.effectiveNetDeviationEscalationLevel == GlobalConstants.Threshold_1 || productgroup.netDeviationEscalationLevel== GlobalConstants.Threshold_1 || productgroup.aaPriceObjectEscalationLevel== GlobalConstants.Threshold_1 || productgroup.sspsEscalationLevel== GlobalConstants.Threshold_1) {
                                                                    if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                    }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                                }
                                                                if(productgroup.effectiveNetDeviationEscalationLevel == GlobalConstants.Threshold_2 || productgroup.netDeviationEscalationLevel== GlobalConstants.Threshold_2 || productgroup.aaPriceObjectEscalationLevel== GlobalConstants.Threshold_2 || productgroup.sspsEscalationLevel== GlobalConstants.Threshold_2) {
                                                                    deviation.ApprovingUnit__c = productgroup.businessArea;
                                                                    isThreshold=true;
                                                                    pdGrpName=productgroup.name;
                                                                    pdGrpBusinessArea=productgroup.businessArea;
                                                                    pdGrpEscalationLevel=productgroup.escalationLevel;
                                                                }
                                                                deviationList.add(deviation);
                                                            }
                                                            if(isThreshold && comparisionPriceBA==0){
                                                                deviationList.add(VisualizeDeviation.createMARecord(inbProposal, existingSFOpp, pdGrpName, pdGrpBusinessArea, pdGrpEscalationLevel, GlobalConstants.Comparison_Price));
                                                                isThreshold=false;pdGrpName=GlobalConstants.BLANK;pdGrpBusinessArea=GlobalConstants.BLANK;pdGrpEscalationLevel=GlobalConstants.BLANK;comparisionPriceBA++;
                                                            }
                                                        }   
                                                    }
                                                    if(Deviations.profitability != null && Deviations.profitability.unAdjustedMarginAfterRisk != null && Deviations.profitability.unAdjustedMarginAfterRisk.productGroup != null)
                                                    { 
                                                        for(ProductGroup productgroup : Deviations.profitability.unAdjustedMarginAfterRisk.productGroup)
                                                        {
                                                            Deviation__c deviation = new Deviation__c();
                                                            deviation.Proposal__c = inbProposal.Id;
                                                            deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            deviation.DeviationType__c = GlobalConstants.UMAR;
                                                            if(!String.isBlank(productgroup.name))deviation.Product_Group__c = productgroup.name;
                                                            if(!String.isBlank(productgroup.businessArea))deviation.BusinessArea__c = productgroup.businessArea;
                                                            if(!String.isBlank(productgroup.escalationLevel))deviation.EscalationLevel__c = productgroup.escalationLevel;
                                                            if(productgroup.escalationLevel == GlobalConstants.Threshold_1) {
                                                                if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                                
                                                            }
                                                            if(productgroup.escalationLevel == GlobalConstants.Threshold_2) {
                                                                deviation.ApprovingUnit__c = productgroup.businessArea;
                                                                isThreshold=true;
                                                                pdGrpName=productgroup.name;
                                                                pdGrpBusinessArea=productgroup.businessArea;
                                                                pdGrpEscalationLevel=productgroup.escalationLevel;
                                                            }
                                                            deviationList.add(deviation);
                                                        }
                                                        if(isThreshold && profitabilityBA==0){
                                                            deviationList.add(VisualizeDeviation.createMARecord(inbProposal, existingSFOpp, pdGrpName, pdGrpBusinessArea, pdGrpEscalationLevel, GlobalConstants.UMAR));
                                                            isThreshold=false;pdGrpName=GlobalConstants.BLANK;pdGrpBusinessArea=GlobalConstants.BLANK;pdGrpEscalationLevel=GlobalConstants.BLANK;profitabilityBA++;
                                                        }
                                                    }
                                                    if(Deviations.commercialTermsAndConditions != null && Deviations.commercialTermsAndConditions.cashFlow != null)
                                                    {
                                                        if(!String.isBlank(Deviations.commercialTermsAndConditions.cashFlow.isDeviatingFromEBD) && Deviations.commercialTermsAndConditions.cashFlow.isDeviatingFromEBD.toLowerCase() == GlobalConstants.TrueVal)
                                                        {
                                                            //record for visualization
                                                            Deviation__c deviation = new Deviation__c();
                                                            deviation.Proposal__c = inbProposal.Id;
                                                            if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                            }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                            deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            deviation.IsdeviationfromEBD__c = Deviations.commercialTermsAndConditions.cashFlow.isDeviatingFromEBD;
                                                            deviation.DeviationType__c = GlobalConstants.EBDTC;
                                                            deviationList.add(deviation);
                                                        }
                                                    }
                                                    //if(Deviations.commercialTermsAndConditions != null && Deviations.commercialTermsAndConditions.contractEvaluation.escalation != null&&)
                                                    if(Deviations.commercialTermsAndConditions != null && Deviations.commercialTermsAndConditions.contractEvaluation!= null && Deviations.commercialTermsAndConditions.contractEvaluation.escalation != null)
                                                    {  
                                                        for(Escalation escalation : Deviations.commercialTermsAndConditions.contractEvaluation.escalation)
                                                        {
                                                            Deviation__c deviation = new Deviation__c();
                                                            deviation.Proposal__c = inbProposal.Id;
                                                            deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            if(!String.isBlank(escalation.businessArea))deviation.BusinessArea__c = escalation.businessArea;
                                                            if(!String.isBlank(escalation.deviationType))deviation.DeviationType__c = escalation.deviationType;
                                                            if(!String.isBlank(escalation.question))deviation.Question__c = escalation.question;
                                                            if(!String.isBlank(escalation.answer))deviation.Answer__c = escalation.answer;
                                                            if(!String.isBlank(escalation.answerComments))deviation.Comment__c = escalation.answerComments;
                                                            if(escalation.deviationType== GlobalConstants.BCTC) {
                                                                deviation.DeviationType__c = escalation.deviationType;
                                                                deviation.ApprovingUnit__c = GlobalConstants.Ref_Sales_Directive;
                                                            }else if(escalation.deviationType.contains(GlobalConstants.EBDTCMS)) {
                                                                deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;
                                                                deviation.DeviationType__c = GlobalConstants.EBDTCMS;   
                                                            }else if(escalation.deviationType.contains(GlobalConstants.EBDTC)) {
                                                                deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;
                                                                deviation.DeviationType__c = escalation.deviationType;
                                                            }
                                                            if(!String.isBlank(escalation.contractQuestionCategory))deviation.ContractCategory__c = escalation.contractQuestionCategory;
                                                            if(!String.isBlank(escalation.deviationConsequence))deviation.DeviationConsequence__c  = escalation.deviationConsequence;  
                                                            if(!String.isBlank(escalation.termsAndConditionsNumber))deviation.TermsAndConditionsNumber__c  = escalation.termsAndConditionsNumber;  
                                                            deviationList.add(deviation);                                                            
                                                        }
                                                    }
                                                    if(Deviations.nonDelegatedAndComplexAndNewTechnologies != null && Deviations.nonDelegatedAndComplexAndNewTechnologies.escalation != null)
                                                    {
                                                        for(Escalation escalation : Deviations.nonDelegatedAndComplexAndNewTechnologies.escalation)
                                                        {
                                                            Deviation__c deviation = new Deviation__c();
                                                            deviation.Proposal__c = inbProposal.Id;
                                                            deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            deviation.ApprovingUnit__c = escalation.businessArea;
                                                            if(!String.isBlank(escalation.businessArea))deviation.BusinessArea__c = escalation.businessArea;
                                                            if(!String.isBlank(escalation.deviationType))deviation.DeviationType__c = escalation.deviationType;
                                                            if(!String.isBlank(escalation.question))deviation.Question__c = escalation.question;
                                                            if(!String.isBlank(escalation.comment))deviation.Comment__c = escalation.comment;  
                                                            if(!String.isBlank(escalation.deviationConsequence))deviation.DeviationConsequence__c  = escalation.deviationConsequence;  
                                                            deviationList.add(deviation); 
                                                            if(nonDelegatedBA==0 || newComplexBA==0) {
                                                                //create extra record for MA
                                                                deviation = new Deviation__c();
                                                                deviation.Proposal__c = inbProposal.Id;
                                                                deviation.CreatedBySalesforce__c = true;
                                                                deviation.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                                if(String.isBlank(existingSFOpp.MarketArea__c)){deviation.ApprovingUnit__c = GlobalConstants.GCU;
                                                                }else {deviation.ApprovingUnit__c = existingSFOpp.MarketArea__c;}
                                                                if(!String.isBlank(escalation.businessArea))deviation.BusinessArea__c = escalation.businessArea;
                                                                if(escalation.deviationType.contains(GlobalConstants.ND)) {
                                                                    deviation.DeviationType__c = GlobalConstants.ND;nonDelegatedBA=1;
                                                                }else if(escalation.deviationType.contains(GlobalConstants.NCT)) {
                                                                    deviation.DeviationType__c = GlobalConstants.NCT;newComplexBA=1;
                                                                }else {
                                                                    deviation.DeviationType__c = escalation.deviationType;
                                                                }
                                                                if(!String.isBlank(escalation.question))deviation.Question__c = escalation.question;
                                                                if(!String.isBlank(escalation.answerComments))deviation.Comment__c = escalation.answerComments;
                                                                if(!String.isBlank(escalation.comment))deviation.Comment__c = escalation.comment;  
                                                                if(!String.isBlank(escalation.deviationConsequence))deviation.DeviationConsequence__c  = escalation.deviationConsequence;  
                                                                deviationList.add(deviation);     
                                                            }
                                                        }
                                                    }
                                                    insert deviationList;
                                                    DeviationTypeUtility.createDevTypes(inbProposal.id,existingSFOpp.Is_Pilot_Group__c);
                                                    //// Insert Risk__c records from inbound proposal message
                                                    List<Risk__c> riskInsertList = new List<Risk__c>();
                                                    if(riskAnalysis.risks != null){
                                                        for(Risk rsk: riskAnalysis.risks){
                                                            Risk__c newRisk = new Risk__c();
                                                            newRisk.Proposal__c = inbProposal.Id;
                                                            newRisk.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            if(!String.isBlank(rsk.riskNumber))newRisk.Name = rsk.riskNumber;
                                                            if(!String.isBlank(rsk.title))newRisk.Risk_Title__c = rsk.title;
                                                            if(rsk.impactDescription != null && rsk.impactDescription.length() > 131071){rsk.impactDescription = rsk.impactDescription.subString(0,131071);}
                                                            if(!String.isBlank(rsk.impactDescription))newRisk.Impact_Description__c = rsk.impactDescription;
                                                            if(!String.isBlank(rsk.mitigationPlan))newRisk.Mitigation_Plan__c = rsk.mitigationPlan;
                                                            if(!String.isBlank(rsk.mitigationCost))newRisk.Mitigation_Cost__c = Decimal.valueOf(rsk.mitigationCost);
                                                            if(!String.isBlank(rsk.quantifiable))newRisk.Quantifiable__c = Boolean.valueOf(rsk.quantifiable);
                                                            riskInsertList.add(newRisk);                
                                                        }
                                                        insert riskInsertList;}
                                                    
                                                    //// Insert ContractEscalation__c records from inbound proposal message
                                                    List<ContractEscalation__c> contrEscInsertList = new List<ContractEscalation__c>();
                                                    if(contractEvaluation.escalation != null){
                                                        for(Escalation esc: contractEvaluation.escalation){
                                                            ContractEscalation__c contrEsc = new ContractEscalation__c();
                                                            contresc.Proposal__c = inbProposal.Id;
                                                            contresc.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            if(!String.isBlank(esc.termsAndConditionsNumber))contrEsc.Name = esc.termsAndConditionsNumber;
                                                            if(!String.isBlank(esc.question))contrEsc.Question__c = esc.question;
                                                            if(!String.isBlank(esc.answer))contrEsc.Answer__c = esc.answer;
                                                            if(!String.isBlank(esc.answerComments))contrEsc.Question_Comment__c = esc.answerComments;
                                                            if(!String.isBlank(esc.contractQuestionCategory))contrEsc.Contract_Category__c = esc.contractQuestionCategory;
                                                            if(!String.isBlank(esc.deviationConsequence))contrEsc.Consequences__c = esc.deviationConsequence;
                                                            //if(!String.isBlank(esc.ceLastUpdatedBy))contrEsc.Last_edited_by__c = esc.ceLastUpdatedBy;
                                                            //if(!String.isBlank(esc.cePreparedBy))contrEsc.Prepared_By__c = esc.cePreparedBy;
                                                            if(!String.isBlank(esc.deviationType))contrEsc.CE_DeviationType__c = esc.deviationType;
                                                            contrEscInsertList.add(contrEsc);
                                                        }
                                                        insert contrEscInsertList;}
                                                    //if( != null)
                                                    //Insert IncomeStatement__c records from inbound proposal message
                                                    List<IncomeStatement__c> incomeSttmntInsertList = new List<IncomeStatement__c>();
                                                    if(incomeStatement.annual != null){
                                                        for(Annual a: incomeStatement.annual){
                                                            IncomeStatement__c newic = new IncomeStatement__c();
                                                            newic.Proposal__c = inbProposal.Id;
                                                            newic.CurrencyIsoCode = existingSFOpp.CurrencyIsoCode;
                                                            if(!String.isBlank(a.year))newic.Name = a.year;
                                                            if(!String.isBlank(a.netPrice))newic.Net_Price__c = Decimal.valueOf(a.netPrice);
                                                            if(!String.isBlank(a.netSalesValue))newic.Net_Sales__c = Decimal.valueOf(a.netSalesValue);
                                                            if(!String.isBlank(a.unadjustedMarginAfterRisk))newic.UMAR__c = Decimal.valueOf(a.unadjustedMarginAfterRisk);
                                                            if(!String.isBlank(a.unadjustedMarginBeforeRisk))newic.UMBR__c = Decimal.valueOf(a.unadjustedMarginBeforeRisk);
                                                            if(!String.isBlank(a.economicProfit))newic.Economic_Profit__c = Decimal.valueOf(a.economicProfit);
                                                            if(!String.isBlank(a.economicProfitPercent))newic.Economic_Profit_Percent__c = Decimal.valueOf(a.economicProfitPercent);
                                                            incomeSttmntInsertList.add(newic);
                                                        }
                                                    }
                                                    insert incomeSttmntInsertList;
                                                    
                                                    logNameResponse += GlobalConstants.SPACE + String.valueOf(uniqueId);
                                                    EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal, logNameResponse, false, successResponse)));
                                                    return successResponse;
                                                } catch (Exception e) {
                                                    Database.rollback(sp);
                                                    EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal, logNameError, true, e)));
                                                    return errorResponse + GlobalConstants.SPACE + e.getMessage();
                                                }
                                            }
    
    /**
* Method that sets Locked To PP field on Opportunity to true or throws an error if record type is PD
* @param opp Opportunity for Proposal
*/
    private static void setLockedToPP(Opportunity opp) {
        if (opp.Locked_to_PP__c == false && (opp.RecordType.Name == FRAME_AMENDEMNT_OPPTY_PP || opp.RecordType.Name == STANDARD_OPPTY_PP)) {
                opp.Locked_to_PP__c = true;
            } /*else {
opp.Locked_to_PP__c = false;
}*/
    }   
    private static Date parseToDate(String dateTimeStr){      
        String dateStr = dateTimeStr.SubStringBefore(GlobalConstants.SPACE);
        String replacedDate = dateStr.replace(GlobalConstants.SLASH, GlobalConstants.SEMICOLON);
        String[] datePartsString = replacedDate.split(GlobalConstants.SEMICOLON);
        Integer day = Integer.valueOf(datePartsString[1]);
        Integer month = Integer.valueOf(datePartsString[0]);
        Integer year = Integer.valueOf(datePartsString[2]);
        return Date.newInstance(year, month, day);
    }
}