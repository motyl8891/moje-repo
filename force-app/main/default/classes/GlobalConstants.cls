/**==
 * @author Nikolajs Jurickis
 * @date 2018-01-17
 * <br>
 * Global Constant class.<br>
 * Use this class to avoid hard-coding 
 */

public with sharing class GlobalConstants{

    // GENERAL // 
    public static final String BLANK = '';
    public static final String OpptyNotReadyString ='List of Fields that require attention :'+'\n';
    public static final String OpptyReadyString = 'Your Opportunity is ready for approval!';
    public static final String ImplicitParent = 'ImplicitParent';
    public static final String NEWLINE = '\r\n';
    public static final String COLON = ':';
    public static final String SPACE = ' ';
    public static final String CSR = 'CSR';
    public static final String CFR = 'CFR';
    public static final String ContractManager = 'Contract Manager';
    public static final String Lighthouse = 'Lighthouse';
    public static final String RB_PPMID_88159 = 'RB_PPMID_88159';
    // HTTP specific
    public static final String URL_ENCODING_SCHEME_DEFAULT = 'UTF-8';
    public static final String HTTP_METHOD_POST = 'POST';
    public static final String HTTP_METHOD_GET = 'GET';
    public static final String HTTP_HEADER_FIELD_NAME_AUTHORIZATION = 'Authorization';
    public static final String HTTP_HEADER_FIELD_AUTHORIZATION_VALUE_OAUTH = 'OAuth ';
    public static final String HTTP_HEADER_FIELD_AUTHORIZATION_VALUE_BEARER = 'Bearer ';
    public static final String HTTP_HEADER_FIELD_AUTHORIZATION_VALUE_BASIC = 'Basic ';
    public static final String HTTP_HEADER_FIELD_NAME_CONTENT_TYPE = 'Content-Type';
    public static final String HTTP_HEADER_FIELD_CONTENT_TYPE_VALUE_APPLICATION_JSON = 'application/json';
    public static final String HTTP_HEADER_FIELD_CONTENT_TYPE_VALUE_APPLICATION_XML = 'application/xml';
    
    public static final String AUTH_HEADER_JSON_AND_UTF8 = 'application/json;charset=UTF-8';
    public static final Integer HTTP_RESPONSE_CODE_SUCCESS = 200;
    public static final Integer HTTP_RESPONSE_CODE_ERROR_BAD_REQUEST = 400;
    public static final Integer HTTP_RESPONSE_CODE_ERROR = 401;
    public static final Integer HTTP_RESPONSE_CODE_ERROR_NOT_FOUND = 404;
    public static final Integer HTTP_RESPONSE_CODE_INTERNAL_SERVER_ERROR = 500;
    public static final String updateApprovedSDPStage = 'SDP Stage Update Exception';
    //Outbound Integrations for EBIP
    public static final String OPPORTUNITY_OUTBOUND = 'EI170607'; 
    
    //global links
    public static final String ORGANIZATION_URL = 'https://' + System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/'; 

    //ProposalInbound
    public static final String RESPONSE_SUCCESS_PROPOSAL_INBOUND = 'SUCCESS';
    public static final String RESPONSE_ERROR_PROPOSAL_INBOUND = 'ERROR';
    public static final String LOG_NAME_REQUEST_PROPOSAL_INBOUND = 'ProposalInbound Request';
    public static final String LOG_NAME_RESPONSE_PROPOSAL_INBOUND = 'ProposalInbound Response';
    public static final String LOG_NAME_ERROR_PROPOSAL_INBOUND = 'ProposalInbound Error';
    public static final Set<String> FINANC_COMPL_PROD_AREAS_SET = new Set<String>{'SBSS', 'PTEL', 'PTVM', 'PBRO'};
    public static final Set<String> FRAME_OPP_REC_TYPES_PP_SET = new Set<String>{'Frame / Amendment Opportunity', 'Frame / Amendment Opportunity.'};
    public static final Set<String> STANDARD_OPP_REC_TYPES_PP_SET = new Set<String>{'Standard Opportunity', 'Standard Opportunity.'};
    public static final String FRAME_OPP_RT_NAME_PD = 'Frame / Amendment Opportunity - PD';
    public static final String STANDARD_OPP_RT_NAME_PD = 'Standard Opportunity - PD';
    public static final String STANDARD_OPP_RT_NAME = 'Standard Opportunity';
    public static final String PREMIUM_DECISION_PRODUCT_RT_NAME = 'Premium Decision Product';
    public static final string PREMIUM_PROPOSAL_PRODUCT_RT_NAME = 'Premium Proposal Product';
    public static final String PREMIUM_DECISION_RT_NAME = 'Premium Decision';
    public static final string PREMIUM_PROPOSAL_RT_NAME = 'Premium Proposal';
    //U-1577
    public static final String Yesabove5millionSEK = 'Yes, above 5 million SEK';
    public static final String Yesbelow5millionSEK = 'Yes, below 5 million SEK';

    //OpportunityPublish - REMOVE THESE
    public static final String RESPONSE_SUCCESS_OPP_PUBLISH = 'SUCCESS';
    public static final String RESPONSE_ERROR_OPP_PUBLISH = 'ERROR';
    public static final String LOG_NAME_REQUEST_OPP_PUBLISH = 'OpportunityPublish Request';
    public static final String LOG_NAME_RESPONSE_OPP_PUBLISH = 'OpportunityPublish Response';
    public static final String LOG_NAME_ERROR_OPP_PUBLISH = 'OpportunityPublish Error';

    //OpportunityContractUpsert_WS
    public static final String RESPONSE_SUCCESS_OPPORTUNITY_CONTRACT_UPSERT = 'OK';
    public static final String RESPONSE_ERROR_OPPORTUNITY_CONTRACT_UPSERT = 'ERROR';
    public static final String LOG_NAME_REQUEST_OPPORTUNITY_CONTRACT_UPSERT = 'OpportunityContractUpsert_WS Request';
    public static final String LOG_NAME_RESPONSE_OPPORTUNITY_CONTRACT_UPSERT = 'OpportunityContractUpsert_WS Response';
    public static final String LOG_NAME_ERROR_OPPORTUNITY_CONTRACT_UPSERT = 'OpportunityContractUpsert_WS Error';

    //EarlyStartView
    public static final String START_NODE_OPPORTUNITY_XML = 'StartNode';
    public static final String RECORD_OPPORTUNITY_XML = 'Record';
    public static final String OPP_NUMBER_OPPORTUNITY_XML = 'OpportunityNumber';

    //PDMarginsCalculation
    public static final String HARDWARE_PRODUCT = 'HW';
    public static final String SOFTWARE_PRODUCT = 'SW';
    public static final String SERVICES_PRODUCT = 'CS';

    //OpportunityLineItems
    public static final Map<String, Integer> baPriorityMap;
    static
    {
        baPriorityMap = new Map<String, Integer>();
        baPriorityMap.put('BNEW', 1);
        baPriorityMap.put('BDGS', 2);
        baPriorityMap.put('BMAS', 3);
        baPriorityMap.put('BTEB', 4);
    }
    //constants for Opp Record Types
    public static final Id simpleOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Simple Opportunity').getRecordTypeId();
    public static final Id simpleCreateOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Simple Opportunity - Create').getRecordTypeId();
    public static final Id standardOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity').getRecordTypeId();
    public static final Id standardCreateOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Standard Opportunity - Create').getRecordTypeId();
    public static final Id frameCreateOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Frame / Amendment Opportunity - Create').getRecordTypeId();
    public static final Id frameOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Frame / Amendment Opportunity').getRecordTypeId();
    //cosntants for U-0959
    public static final List<String> validStage = new List<String>();
    static{
        validStage.add('Closed Lost');
        validStage.add('Closed-Duplicate');
        validStage.add('Closed-Withdrawn');
    }
    public static final String DIVISION_UNDEFINED = 'Division undefined';
    public static final String UPDATE_ERROR = 'Error in update';
    public static final String AT_LEAST_ONE_NON_ZERO_PRODUCT_VALUE_SIMPLE = 'You need to have at least one non-zero product value per Simple. If you want to delete the product from the Simple please click the arrow to the right on the line item';
    public static final String PRODUCT_VALUE_SHOULD_NOT_BE_ZERO= 'In order to create Simple Opportunities the Frame Opportunity needs to have at least one product with a non-zero value';
    public static final String VALID_STAGE_OF_FRAME = 'In order to create Simple Opportunities the Frame Opportunity cannot be in Stage Closed-Lost, Closed-Withdrawn or Closed-Duplicate.';
	public static final String QUARTER_SYMBOL = 'Q';
    public static final String NO_CHANGE = 'No Change';
    public static final String OppController = 'OppController';
    public static final String  insertOLI = 'insertOLI';
    public static final String getAllOLI = 'getAllOLI';
    public static final String removeOppLineItems = 'removeOppLineItems';
    public static final String MasscreateOLI = 'MasscreateOLI';
    public static final String getselectOptions = 'getselectOptions';
    public static final String createPridictions = 'createPridictions';
    public static final String reCreateOLI = 'reCreateOLI';
    public static final String SUCCESS = 'SUCCESS';
    public static final String ErrorInMassCreate = 'Error in mass create';
    public static final String ErrorInRegenerate = 'Error in Regenerate';
    public static final String updateOLI = 'updateOLI';
    public static final String getFrameData = 'getFrameData';
    public static final String ClosedLost = 'Closed Lost';
    public static final String ClosedDuplicate = 'Closed-Duplicate';
    public static final String ClosedWithdraw = 'Closed-Withdrawn';
    public static final String ClosedWon = 'Closed Won';
    public static final String frameName = 'frameName';
    public static final String STAGE4 ='4. Negotiate and Close';
    public static final String isPossibleToRegenerate ='isPossibleToRegenerate'; //D-1653
	 //Constants for U-0912
    public static final String OppSummaryComponentProposalController = 'Get Proposals from Opportunity';
    public static final String getProposal='Unable to fetch Primary Proposal'; 
    // COnstants for U-0985
    public static final String populateSalesOBTargetsandActualsOnNewOpp = 'Unable to fetch Sales OB Targets and Actuals Record';
     ////constants for D-1653
    public static final List<String> validStages = new List<String>();
    static{
        validStages.add('Closed Lost');
        validStages.add('Closed-Duplicate');
        validStages.add('Closed-Withdrawn');
        validStages.add('Closed Won');
    }
    public static final String getAllSimpleOpportunitiesOfFrame ='getAllSimpleOpportunitiesOfFrame'; //U-999 
    public static final String ForecastCategory =' In Forecast'; //U-999
    public static final String OpportunityChildSumDeaValuePercentHelper = 'OpportunityChildSumDeaValuePercentHelper'; //U-999 Novasuite
    public static final String simpleOpportunityHelper = 'simpleOpportunityHelper'; //US-0891
    public static final String sumOfSimpleChildOppsDealValueOnFrame = 'sumOfSimpleChildOppsDealValueOnFrame'; //U-999 Novasuite
    public static final Integer ZERO = 0; //U-999 Novauite	
    //U-1022
    public static final String updateMAHeadandBAHeads = 'updateMAHeadandBAHeads';
   //US-0891 
    public static final String simpleToCloseUpdate = 'simpleToCloseUpdate';
    public static final String setSensitiveBusinessStatus = 'setSensitiveBusinessStatus';
    public static final String setOpportunityOwner = 'setOpportunityOwner';
    public static final String OpportunityTriggerHelper = 'OpportunityTriggerHelper';
    public static final String SimpleToCloseUpdateStage ='SimpleToCloseUpdateStage';
    public static final String updateSimpleOppStage = 'updateSimpleOppStage';
    public static final String execute = 'execute';
    //U-1988
    public static final String updatePrimaryProposal = 'updatePrimaryProposal';
     public static final String Extension = 'Extension';
    
    //OpportunityTriggerHelper - VerifyOpportunityProgression
    public static final String VerifyOpportunityProgression = 'VerifyOpportunityProgression';
    
    //OpportunityTriggerHelper - updateOppChildApprovalStatus
    public static final String updateOppChildApprovalStatus = 'updateOppChildApprovalStatus';
    //U-2040
    public static final String createOppUseCase = 'createOppUseCase';
    
    //OpportunityTriggerHelper - setClosedWithdrawnReason
    public static final String setClosedWithdrawnReason = 'setClosedWithdrawnReason';
    
    //OpportunityTriggerHelper - refreshDealMarginValue
    public static final String  refreshDealMarginValue = 'refreshDealMarginValue';
    
    //OpportunityTriggerHelper - refreshDealMarginValue
    public static final String  setApprovedStage = 'setApprovedStage';
    
    //OpportunityChildSumDeaValuePercentHelper - sumChildOppsDealValueOnFrame
    public static final String sumChildOppsDealValueOnFrame = 'sumChildOppsDealValueOnFrame';
    
    //OpportunityTriggerHelper - checkForStage1
    public static final String newLine1 = '\n';
    public static final String List_of_Fields_that_require_attention = 'List of Fields that require attention :';
    public static final String Products = 'Products';
    public static final String Customer_Intent_to_Buy = 'Customer Intent to Buy';
    public static final String Local_Experience_and_Resources = 'Local Experience and Resources';
    public static final String Relations_With_Customer_Decision_Maker = 'Relations With Customer Decision Maker';
    public static final String Customer_Sourcing_Work = 'Customer Sourcing Work';
    public static final String Impact_Customer_and_RfQ = 'Impact Customer and RfQ';
    public static final String ThreePP_share_of_total_cost = '3PP share of total cost';
    public static final String Advantantage_Towards_The_Customer = 'Advantantage Towards The Customer';
    public static final String Extraordinary_Challenges_or_Risks = 'Extraordinary Challenges or Risks';
    public static final String Solid_Solution_And_References = 'Solid Solution And References';
    public static final String Non_Delegated_Business_c = 'Non Delegated Business__c';
    public static final String Confidence_To_Win_Winning_Value = 'Confidence To Win Winning Value';
    public static final String Will_Opp_Involve_Intermediate_Partner = 'Will Opportunity involve intermediate partner? found under Business Partner Review section';
    public static final String Ship_To_Countries = 'Ship-To And End Destination Countries found under Sensitive Business section';
    public static final String What_is_the_Technology_Risk = 'What is the Technology Risk? found under under Sensitive Business section';
    public static final String Trade_Classification = 'Trade Classifications found under Trade Compliance section';
    public static final String End_Customer = 'End Customer found under Sensitive Business section';
    public static final String Sensitive_Products_in_Scope = 'Trade Compliance Products in scope? found under Trade Compliance section';
    
    //OpportunityTriggerHelper - checkForStage2
    public static final String Estimated_Project_Start_Date = 'Estimated Project Start Date found under Key Dates section';
    public static final String Estimated_Project_End_Date = 'Estimated Project End Date found under Key Dates section';
    
    //OpportunityTriggerHelper - checkForStage3
    public static final String Sensitive_Business_Status = 'Sensitive Business approval via Secondary Approval section';
    public static final String Is_Extended_Warranty_SiA_included = 'Is Extended Warranty (SiA) included found under Financial Compliance Audit Scope section';
    public static final String Voucher_FoC_Items_Included = 'Incentives / Voucher / FoC included? found under Financial Compliance Audit Scope section';
    public static final String Consideration_Payable_To_Customer_Inclusive = 'Consideration payable to customer incl? found under Financial Compliance Audit Scope section';
    public static final String Trade_Compliance_Secondary_Approval = 'Trade Compliance approval via Secondary Approval section';
    public static final String Cashflow_Analysis_Status = 'Complete Cashflow Analysis in Premium Proposal';
    public static final String Risk_Assessment_Status = 'Complete Risk Assessment in Premium Proposal';
    public static final String MA_Head = 'MA Head';
    public static final String BA_Head = 'BA Head';
    public static final String Not_Required = 'Not Required';
    public static final String Approved_with_condition= 'Approved with Condition';
    public static final String Complete = 'Complete';
    
    //OpportunityTriggerHelper - checkForStage4
    public static final String I_Confirm_The_SB_Conditional_Adherence = 'I confirm the SB Conditional Adherence found under Sensitive Business, Trade Compliance section';
    
    //checkForClosedWon
    public static final String Valid_Contract = 'Add valid Agreement by setting the status "In Execution" in Sales CLM';
    public static final String Completed_Contract = 'Complete Agreement Evaluation in Premium Proposal';
    
    
    //U-1321
    public static final String EarlyStartHandler = 'EarlyStartHandler';
    public static final String onBeforeInsert = 'onBeforeInsert';
    public static final String EarlyStartHelper = 'EarlyStartHelper';
    public static final String updateParentOppOnCreation = 'updateParentOppOnCreation';
    public static final String updateParentOpp = 'updateParentOpp';
    //U-1651
    public static final String updateCheckBoxCLM = 'updateCheckBoxCLM';
    public static final String updateCheck=   'updateCheck';
    //U-1675
      public static final String checkFileInformation='checkFileInformation';
    public static final String DocumentInfoAgreementRequest='DocumentInfoAgreementRequest';
    public static final String getFileInformation='getFileInformation';
     // public static final String getselectOptions='getselectOptions';
        public static final String UpdateDocumentType=' UpdateDocumentType';
    //U-1413
    public static final String checkForStage1and2 = 'checkForStage1and2';
    public static final String checkForStage3 = 'checkForStage3';
    public static final String checkForClosedWon ='checkForClosedWon';
    public static final String checkForStage4 = 'checkForStage4';
    //U-1506
    public static final String updateOpportunityReadyForOQB ='updateOpportunityReadyForOQB';
    public static final String MELADS ='MELA DS';
    public static final String MELANMS ='MELA NMS';
    //U-1055
     public static final String setEndCustomer = 'setEndCustomer';
   // U-1002
    public static final String updateCloseDateofSimple = 'updateCloseDateofSimple';
	public static final String StageName = 'StageName';
    //U-1418
     public static final String checkLHRValue = 'checkLHRValue';
    //U-1267
    public static final String CompetitiveAnalysisTriggerHelper = 'CompetitiveAnalysisTriggerHelper';
    public static final String setKeyCompetitor = 'setKeyCompetitor';
    public static final String setForecastCategory ='setForecastCategory';
    public static final string CompetitiveAnalysisTriggerHandler= 'CompetitiveAnalysisTriggerHandler';
    public static final String onAfterInsert='onAfterInsert';
    public Static Final String onAfterUpdate='onAfterUpdate';
    public static final string onAfterDelete='onAfterDelete';
    //U-1484
   	public static final String SalesTeamTriggerHelper ='SalesTeamTriggerHelper';
    public static final String SetPrimaryFlag= 'SetPrimaryFlag';
    public static final String OnePrimarySalesTeamFlagBeforeUpdate='OnePrimarySalesTeamFlagBeforeUpdate';
    //U-1575 AND U-2084
   public static final String PartnerAccountController='PartnerAccountController';
   public static final String getPartnerAccount='getPartnerAccount';
    public static final String getPartnership='getPartnership';
   public static final String Partner = 'Partner'; 
   public static final String ericssonDotCom = 'ericsson.com';
   public static final String framelocation = ''; 
   public static final String showframe = 'showframe';
   public static final String PartnerPublicPage = 'PartnerPublicPage'; 
   public static final String checkframeapex = 'checkframeapex';
   
    //U -900
    public static final List<String> validCloneStage = new List<String>();
    
    public static boolean isCheckbox=false;
    static{
        validCloneStage.add('1. Qualify Opportunity');
        validCloneStage.add('2. Define Customer Value');
        validCloneStage.add('3. Create Proposal');
        validCloneStage.add('4. Negotiate and Close');
    }
	//U-1032
    public static final String  EMAILNEWSLETTER = 'Email Newsletter';
    public static final String  EMAILSEND = 'Email Send';
    public static final String  LISTIMPORT = 'List Import';
    public static final String  MULTIEMAILSEND = 'Multi-Email Send';
    public static final String  NURTURE = 'Nurture';
    public static final String  ONLINEADVERTISING = 'Online Advertising';
    public static final String  OPERATIONAL = 'Operational';
    public static final String  WEBCONTENT = 'Web Content';
    public static final String  WEBFORM = 'Web Form';
    public static final String  LIVEEVENT = 'Live Event';
    public static final String  TRADESHOW = 'Tradeshow';
    public static final String  WEBINAR = 'Webinar';
    public static final String  WEBPERSONALIZATION = 'Web Personalization';
    public static final String  MEMBER = 'Member';
    public static final String  INVITED = 'Invited';
    public static final String  VIEWED = 'Viewed';
    public static final String  CONVERTED = 'Converted';
	public static final String  SEMICOLON = ';';
    public static final String  CAMPAIGNMEMBERTRIGGERHELPER= 'CampaignMemberTriggerHelper';
    public static final String  ADDSTATUSTOCAMPAIGNMEMBERS= 'addStatustoCampaignMembers';
    public static final String  CAMPAIGNTRIGGERHELPER= 'CampaignTriggerHelper';
    public static final String  ADDCMSSTATUSTOCAMPAIGN= 'addCMStatustoCampaign';
    public static final String  MarketoUserName= 'marketo-salesforce@ericsson.com'+System.currentTimeMillis();
    public static final String CloneOpportunityController = 'CloneOpportunityController';
    public static final String isValidStage = 'isValidStage';
    //U-1060
    public static final String UPDATEFINANCIALCOMPLIANCEAUDITSCOPE = 'updateFinancialComplianceAuditScope';
    public static final String INSCOPE = 'IN SCOPE';
    public static final String OUTOFSCOPE = 'OUT OF SCOPE';
    public static final String YES = 'Yes';
    public static final String UNKNOWN = 'Unknown';
    public static final String UNDER = 'Under';
    public static final String LOW = 'LOW';
    //D-2243
    public static final String updateSensitiveBusinessStatus  = 'updateSensitiveBusinessStatus ';
    public static final String PENDINGAPPROVAL = 'Pending Approval';
	public static final String APPROVALINPROCESS = 'Approval in Progress';
	public static final String APPROVEDWITHCONDITIONS = 'Approved with Conditions';
	public static final String DISMISSED = 'Dismissed';    
       
    
    
    
    //D-1729
    public static final String OPPORTUNITYSALESTEAMHELPER = 'OpportunitySalesTeamHelper';
    public static final String RESTRICTSALESTEAMONCLOSEDOPPTY = 'restrictSalesTeamOnClosedOppty';
    // U-1070
    public static final String SDODLeadTrigger = 'SDODLeadTrigger';
    public static final String AddAdditionalRecorder = 'AddAdditionalRecorder';
    public static final String SDODLeadTriggerHandler = 'SDODLeadTriggerHandler';
    //U-1029
    public static final String EarlyStartOppViewHelper = 'EarlyStartOppViewHelper';
    public static final String updateCurrencyOnEarlyStart = 'updateCurrencyOnEarlyStart';
    //U-1082
    public static final String  OPENINGBRACKET = '(';
    public static final String  CLOSINGBRACKET = ')';
	//U -1108
    public static final Set<Id> frameStandRecordTypes = new Set<Id>();
    static{
        frameStandRecordTypes.add(System.Label.Record_Type_ID_Frame_Amendment_Opportunity);
        frameStandRecordTypes.add(System.Label.Record_Type_ID_Frame_Amendment_Opportunity_PD);
        frameStandRecordTypes.add(System.Label.Record_Type_ID_Standard_Opportunity);
        frameStandRecordTypes.add(System.Label.Record_Type_ID_Standard_Opportunity_PD);
    }
    public static final Set<Id> frameRecordTypes = new Set<Id>();
    static{
        frameRecordTypes.add(System.Label.Record_Type_ID_Frame_Amendment_Opportunity);
        frameRecordTypes.add(System.Label.Record_Type_ID_Frame_Amendment_Opportunity_PD);
	}
    public static final Set<Id> standRecordTypes = new Set<Id>();
    static{
		standRecordTypes.add(System.Label.Record_Type_ID_Standard_Opportunity);
        standRecordTypes.add(System.Label.Record_Type_ID_Standard_Opportunity_PD);
    }
    public static final String AsyncReplaceProducts = 'AsyncReplaceProducts';
	
	public static final String resetSDMs = 'resetSDMs';
    //U-1051
    public static final String SalesDecisionRecordTriggerHelper = 'SalesDecisionRecordTriggerHelper';
    public static final String SalesDecisionApprovedStatusError = 'SalesDecisionApprovedStatusError';
    public static final String SalesDecisionSnapshotError = 'SalesDecisionSnapshotError';
    public static final String createSDApproverRecords = 'createSDApproverRecords';
    public static final String KAM = 'KAM';
    public static final String CUHEAD = 'CU Head';
    public static final String GCUHEAD = 'GCU Head';
    public static final String REQUESTED = 'Requested';
    //U-1578
    public static final String TOBEREQUESTED = 'To be Requested';
    public static final String INPROGRESS = 'In progress';
    public static final String APPROVED = 'Approved';
    public static final String updateACR_CSR_CFRBasedOnOpptySalesTeam = 'updateACR_CSR_CFRBasedOnOpptySalesTeam';
    public static final String ACR = 'ACR';
    //U-1507
    public static final String updateACR_CSR_CFREmail = 'updateACR_CSR_CFREmail';
    //U-1186
    public static final String  SDP1InvestToWin = 'SDP1 Invest to Win';
    public static final String  SDP2SubmitProposal = 'SDP2 Submit Proposal';
    public static final String  SDP3SignContract = 'SDP3 Sign Contract';
    public static final String  ELIGIBLE = 'Eligible';
    public static final String  Ineligible = 'Ineligible';
    public static final String  createSDRecordsOnOpptyStageProgression = 'createSDRecordsOnOpptyStageProgression';
    public static final String  AUTOMATIC = 'Automatic';
    public static final String  SUPPORTTEXT = 'This Sales Decision Record has been auto-created by Salesforce and does not require any approvals from Sales Decision Makers in order to progress to the next Sales Stage.';
   //D-2023, U-1051
    public static final String checkRecordEditabilityForMELAOppty = 'checkRecordEditabilityForMELAOppty';
    public static final String MELA = 'MELA';
    public static final String OQB = 'OQB';
    public static final String SALESOPERATIONSPROFILE = '00e0Y000001VuiHQAS';
    public static final String ADMINPROFILE = '00e0Y000001j4Qe';
    public static final String INTEGRATIONUSERPROFILENAME = 'Integration User Profile';
    public static final String SalesDecisionRecordController = 'SalesDecisionRecordController';  
    public static final String opptyOwnerCheck = 'opptyOwnerCheck';
    public static final String sendEmailToDecisionMakers = 'sendEmailToDecisionMakers';
    public static final String NO = 'No';
    //U-1366
    public static final String  MAHEAD = 'MA Head';
    public static final String  BAHEAD = 'BA Head';
    public static final String  GCUCOMMERCIALHEAD = 'GCU Commercial Head';
    public static final String  COMMERCIALS = 'Commercials';
    public static final String  SOLUTION = 'Solution';
    public static final String  FULFILLMENT = 'Fulfillment';
    public static final String  GCUKAM = 'GCU KAM'; 
    public static final String  NULLVAL = 'NULL';
    public static final String  CUSTANDARDFRAMEOPPS = 'CU Account';
    public static final String  LOCALACCOUNTGCUOPP = 'GCU Account';
    public static final String  GCUFRAMEOPPTY = 'GCU Frame';
    public static final String  TIER3 = 'Minor';
    public static final String  TIER2 = 'Medium';
    public static final String  TIER1 = 'Major';
    public static final String  MEDIUM = 'MEDIUM';
    public static final String  HIGH = 'HIGH';
	    public static final String  MEDIUM_LOWER = 'medium';
    public static final String  HIGH_LOWER = 'high';
    public static final String  MEDIUM_CAMEL = 'Medium';
    public static final String  HIGH_CAMEL = 'High';
    public static final String  OVER = 'Over';
	    public static final String  BETWEEN = 'Between';
    public static final String  createSalesDecisionMakerRecords = 'createSalesDecisionMakerRecords';
    public static final String  DASH = '-';
    public static final String  SalesDecisionRecordUtility = 'SalesDecisionRecordUtility';
    public static final String  createSDMRecords = 'createSDMRecords';
    public static final String  UPDATEOPPORTUNITYTIER = 'updateOpportunityTier'; 
    //U-0913
    public static final String  LESSSENSITIVE = 'Less Sensitive';
    public static final String  SENSITIVE = 'Sensitive';
    public static final String  checkSensitiveProductsCheckbox = 'checkSensitiveProductsCheckbox';
    public static final String  sendEmailForTradeCompliance = 'sendEmailForTradeCompliance';
    public static final String  GOVERNMENT = 'Government';
    public static final String  CIVIL = 'Civil';
    public static final String  DEFENSE = 'Defense';
    public static final String  REQUIRED = 'Required';
    public static final String  SUDAN = 'Sudan';
    public static final String  sendEmailNotificationForTradeCompliance = 'sendEmailNotificationForTradeCompliance';
    public static final String  ACCOUNTTRIGGERHELPER = 'AccountTriggerHelper';
    public static final List<String> stageList = new List<String>();
    static{
        stageList.add(System.Label.Sales_Stage_Closed_Won);
        stageList.add(System.Label.Sales_Stage_2_Define_Customer_Value);
        stageList.add(System.Label.Sales_Stage_3_Create_Proposal);
        stageList.add(System.Label.Sales_Stage_4_Negotiate_and_Close);
    }
    public static final List<String> OpenStage = new List<String>();
    static{
        OpenStage.add(System.Label.Sales_Stage_1_Qualify_Opportunity);
        OpenStage.add(System.Label.Sales_Stage_2_Define_Customer_Value);
        OpenStage.add(System.Label.Sales_Stage_3_Create_Proposal);
        OpenStage.add(System.Label.Sales_Stage_4_Negotiate_and_Close);
    }
    public static final String COMMA = ',';
    public static final List<String> oppTypeForProgression = new List<String>();
    static{
        OpenStage.add(System.Label.Sales_Stage_1_Qualify_Opportunity);
        OpenStage.add(System.Label.Sales_Stage_2_Define_Customer_Value);
        OpenStage.add(System.Label.Sales_Stage_3_Create_Proposal);
        OpenStage.add(System.Label.Sales_Stage_4_Negotiate_and_Close);
    }
    //U-1383
    public static final String  ConfirmGCUChild = 'Confirm GCU Child';
	public static final String  QualifyGCUChild = 'Qualify GCU Child';    
    public static final String  GCUCommercialDirector = 'GCU Commercial Director';  
    public static final Map<String, String> mapStageToVal = new Map<String, String>();
    static{
        mapStageToVal.put(System.Label.Sales_Stage_1_Qualify_Opportunity, '1');
        mapStageToVal.put(System.Label.Sales_Stage_2_Define_Customer_Value, '2');
        mapStageToVal.put(System.Label.Sales_Stage_3_Create_Proposal, '3');
        mapStageToVal.put(System.Label.Sales_Stage_4_Negotiate_and_Close, '4');
        mapStageToVal.put(System.Label.Sales_Stage_Closed_Won, '5');
    }
    public static final String readyForNextStage = 'readyForNextStage';
    //D-2203
    public static final String NotRequired = 'Not Required';
    public static final String updateOppTradeCompliance = 'updateOppTradeCompliance';
    public static final String updateTradeComplianceOnOppty = 'updateTradeComplianceOnOppty'; 
	public static final Id extensionRecordTypeId = Schema.SObjectType.EarlyStart__c.getRecordTypeInfosByName().get('Extension').getRecordTypeId();
	public static final Id newearlyStartRecordTypeId = Schema.SObjectType.EarlyStart__c.getRecordTypeInfosByName().get('New Early Start').getRecordTypeId();    
    public static final String restrictDeletionOfAutoSDM = 'restrictDeletionOfAutoSDM';
    public static final STring SalesDecisonMakerHelper = 'SalesDecisonMakerHelper';
    public static final String reCalculateReadySDR = 'reCalculateReadySDR';
    public static final String Rejected = 'Rejected';
    public static final String unlockSDROppProposal = 'unlockSDROppProposal';
    public static final String lockSDROppProposal = 'lockSDROppProposal';
    public static final String SalesDecisionMakerHandler = 'SalesDecisionMakerHandler';
    public static final String onBeforeDelete = 'onBeforeDelete';
    public static final String mapSDRFields = 'mapSDRFields';
    public static final String SalesDecisionRecordTriggerHandler = 'SalesDecisionRecordTriggerHandler';
    public static final String onBeforeUpdate = 'onBeforeUpdate';
    public static final String oppStage1 = '1. Qualify Opportunity';
    public static final String refreshSDRInfo = 'refreshSDRInfo';
    
    //U-1756
    public static final String updateSDRAllConditionsNotes = 'updateSDRAllConditionsNotes';
   
    
    //U-1259
    public static final String SDODNewLeadController = 'SDODNewLeadController';
    public static final String updateLeads = 'updateLeads';
    public static final String DRecorded = 'D - Recorded';
    public static final String AoS = 'AoS';
    public static final String ErrorForSOG = '"What is the original project scope" is Only editable for AoS';
    //D-2511
    public static final String APPROVALSONGOING = 'Approvals Ongoing';
    public static final String updateSalesDecisionApprovalStatus = 'updateSalesDecisionApprovalStatus';
    //DisplayErrorOnSDR
    public static final String SDP0 = 'SDP0';
   // public static final Id standardOppRecordTypeId = System.Label.Record_Type_ID_Standard_Opportunity;
    //U-1581
    public static final String DeviationTypeUtility = 'DeviationTypeUtility';
    public static final String createDevTypes = 'createDevTypes';
    public static final String GCU = 'GCU';
    public static final String BTEB = 'BTEB';
    public static final String BDGS = 'BDGS';
    public static final String BMAS = 'BMAS';
    public static final String BNEW = 'BNEW'; 
    public static final String NonDelegated = 'Non-Delegated';
    public static final String NewandComplexTechnologies = 'New and Complex Technologies';
    public static final String NODEVIATION = 'No Deviation';
    public static final String NOTAPPLICABLE = 'Not Applicable';
    public static final String NoDeviationsIdentified = 'No Deviations Identified';
    public static final String Tier_1 = 'Tier 1';
    public static final String Tier_2 = 'Tier 2';
    public static final String Tier_3 = 'Tier 3';
    public static final String Tier_4 = 'Tier 4';
    public static final String UpdateDeviationTypeGroupsController = 'UpdateDeviationTypeGroupsController';
    public static final String  opptyPofileCheck = 'opptyPofileCheck';
    public static final String  updateSubmitForApprovalFlag = 'updateSubmitForApprovalFlag';
    public static final String  DeviationTypeGroupHandler = 'DeviationTypeGroupHandler';
	

    //U-1694
    public static final String  SecondaryApprovalTriggerHelper = 'SecondaryApprovalTriggerHelper';
    public static final String  calculatePurposeRisk = 'calculatePurposeRisk';
    public static final String  SecondaryApprovalTriggerHandler = 'SecondaryApprovalTriggerHandler';
    
    //OpportunityTriggerHelper - U-1694
    public static final String  calculateCountryRisk = 'calculateCountryRisk';
    
    public static final String  updateOppLineItems = 'updateOppLineItems';
   
    public static final String RelatedOpportunityController ='RelatedOpportunityController';
    public static final String getRelatedOpps = 'getRelatedOpps';   
    
    //OpportunityProductTriggerHandlerHelper
    public static final String  OpportunityProductTriggerHandlerHelper = 'OpportunityProductTriggerHandlerHelper';
	public static final String  validateOnDelete = 'validateOnDelete';
    public static final String  RestrictDuplicateOppProduct = 'RestrictDuplicateOppProduct';
    //SimpleToCloseUpdateStage
    public static final String  updateSdrOppChild = 'updateSdrOppChild';
    public static final String  updateSecApprovalStatus = 'updateSecApprovalStatus';  
    public static final String  updateEsApprovalStatus = 'updateEsApprovalStatus';
    public static final String  updateDevgrpApprovalStatus = 'updateDevgrpApprovalStatus';  
    
	//U-1668
	public static final String CheckSDRIsReadyForNextStage = 'CheckSDRIsReadyForNextStage';
    public static final String Other = 'Other';
    
    //U-1737
    public static final String updateOpportunityApprovedSdpStage = 'updateOpportunityApprovedSdpStage';
    public static final String MarkOppoyApprovedSDPStageToObsolate = 'MarkOppoyApprovedSDPStageToObsolate';
    public static final String updateApprovedSDPStageMethod = 'updateApprovedSDPStage';
    public static final String triggerOpportunitiesApprovedSdpStageInsert='triggerOpportunitiesApprovedSdpStageInsert';
    public static final String triggerOpportunitiesApprovedSdpStageUpdate='triggerOpportunitiesApprovedSdpStageUpdate';
    public static final String triggerOpportunitiesApprovedSdpStageDelete='triggerOpportunitiesApprovedSdpStageDelete';
    public static final String oppStg3 = '3. Create Proposal';
    public static final String oppStg4 = '4. Negotiate and Close';
    public static final String oppStg1 = '1. Qualify Opportunity';
    public static final String oppStg2 = '2. Define Customer Value';
    public static final String PPRequired='Required';
    public static final String obsolete='obsolete';
    public static final String SDPStageOQB='OQB';
    public static final String SDPStage1='SDP1 Invest to Win';
    public static final String SDPStage2='SDP2 Submit Proposal';
    public static final String SDPStage3='SDP3 Sign Contract';
    public static final String OppMELA='MELA';
    public static final String Minor='Minor';
    public static final String updateOpportunityStageChange='updateOpportunityStageChange';
    //U-1800
     public static final String  GCUCOMMERCIALMANAGEMENT = 'GCU Commercial Management';
    //U-1760
    public static final String Proposal_Sub_Date_NotFuture = 'Proposal Submission Date found under Key Dates section Should Not be in Future';
    public static final String Proposal_Sub_Date_NotNULLandNotPast = 'Proposal Submission Date found under Key Dates section should be provided and not in the past';
	
	//U-1711
    public static final String ProposalTriggerHandlerHelper = 'ProposalTriggerHandlerHelper';
    public static final String recallDeviationApprovals='recallDeviationApprovals';
    public static final String Cancelled = 'Cancelled';
    public static final String Pending = 'Pending';
    public static final String Removed = 'Removed';
    public static final String Active = 'Active';
    //D-1928
    public static final String TrueVal = 'true';
    public static final String updatePrimaryProposalClosedWon = 'updatePrimaryProposalClosedWon';
    //U-1819
    public static final String updateCloseDateandProposalSubDate = 'updateCloseDateandProposalSubDate';
    
    //U-1825
    public static final String setUsedForStageProgression = 'setUsedForStageProgression';
    //U-1826
    public static final String updateProposalEBDStatus='updateProposalEBDStatus';
    public static final String updateDeviationFields='updateDeviationFields';
    public static final String updateOverallEBDStatusonSDR='updateOverallEBDStatusonSDR'; 
    public static final String restrictEditOfSupportingMaterial='restrictEditOfSupportingMaterial';
    public static final String restrictEditOfMAFields='restrictEditOfMAFields';
    public static final String  restrictEditOfBAFields='restrictEditOfBAFields';  
    //U-1846
    public static final String checkEditabilityOfPreApprovalField='checkEditabilityOfPreApprovalField';
    public static final String updateDeviationsToApproved='updateDeviationsToApproved';
    //U-1695
     public static final String getRecordInformation= 'getRecordInformation';
         public static final String updateRecord='updateRecord';
     public static final String SDORERRORINFO='You cannot edit the record once sold or rejected';
    public static final String SDODERROR='Error While Saving. Please try Later!';
        
    //U-1846
	public static final String DeviationPreApprovedEditError = 'You do not have the permission to update this field, please reach out to Commercial Management.';
    //U-1859
    public static final String SetShipToCountries ='SetShipToCountries';
    public static final String EGYPT = 'EG';
    public static final String ANGOLA = 'AO';
    public static final String INDIA = 'IN';
    public static final String SWEDEN = 'SE';
    
    public static final String approvalAlreayRequested = 'This Action is not available, request for deviation approval already initiated.';
    //2907
 	public static final String TagTriggerHelper = 'TagTriggerHelper';
    public static final String updateTagOnOpportunity = 'updateTagOnOpportunity'; 
    
    //U-1989
    public static final String SalesIdeaTriggerHelper = 'SalesIdeaTriggerHelper';
    public static final String SalesIdeaTriggerHandler = 'SalesIdeaTriggerHandler';
    
    public static final String setSalesIdeaOwner = 'setSalesIdeaOwner';
    public static final String updateOpportunityOnSalesIdea = 'updateOpportunityOnSalesIdea';
    
    public static final String setOppDescriptionFromOpportunity = 'setOppDescriptionFromOpportunity';
    public static final String updatePreSalesAdjustmentStatus = 'updatePreSalesAdjustmentStatus';
    public static final String UpdateOpportunitySalesComplianceStatus = 'UpdateOpportunitySalesComplianceStatus';
    public static final String UpdateOpportunityTradeComplianceStatus = 'UpdateOpportunityTradeComplianceStatus';
    
    public static final String Sensitive_Business = 'Sensitive_Business';
    public static final String In_Progress = 'In Progress';
    Public static final string SOG = 'SOG';
    //U-1889
    public static final String OpportunityTriggerHepler2='OpportunityTriggerHepler2';
    public static final String Qualify_Opportunity=System.Label.Sales_Stage_1_Qualify_Opportunity;
    public static final String Define_CustomerValue = System.Label.Sales_Stage_2_Define_Customer_Value;
    public static final String Create_Proposal = System.Label.Sales_Stage_3_Create_Proposal;
    public static final String Negotiate_and_Close=System.Label.Sales_Stage_4_Negotiate_and_Close;
    public static final String oppStageClosedWon = System.Label.Sales_Stage_Closed_Won;
    public static final String oppStageClosedLost = System.Label.Sales_Stage_Closed_Lost;
    public static final String oppStageClosedDuplicate = System.Label.Sales_Stage_Closed_Duplicate;
    public static final String oppStageClosedWithdrawn = System.Label.Sales_Stage_Closed_Withdrawn;
    public static final String Product_Count_Changed='Product Count Changed'; 
    public static final String Product_Values_Changed='Product Values Changed';
    public static final String Product_Margin_Changed='Product Margin Changed';
    public static final String Close_Date_Changed='Close Date Changed';
    public static final String Forecast_Category_Changed='Forecast Category Changed';
    Public static final String recordTypeAssignment='recordTypeAssignment';
    Public static final String setCloseDateStageNameProductChange='setCloseDateStageNameProductChange';
    Public static final String updateOppDescriptionOnSecondaryApproval='updateOppDescriptionOnSecondaryApproval';
    Public static final String updatePrimaryProposalOnSDR='updatePrimaryProposalOnSDR';
    Public static final String updateOpportunityApprovedStage='updateOpportunityApprovedStage';
    Public static final String setOpportunityApprovers='setOpportunityApprovers';
    Public static final String setAccountAndCurrency='setAccountAndCurrency';
    public static final String SetSensitiveBusinessRequiredBatch='SetSensitiveBusinessRequiredBatch';
    public static final String EXCLUDE ='Exclude';
    public static final String MANA ='MANA';
    Public static RecordType getrecordtypeID(string sobjectt,string recordtypename){
        RecordType re=[select Id,Name from RecordType where sObjectType=:sobjectt and name=:recordtypename];
        return re;
 }
    Public static Id getProfileId(String profileName){
         Id profileId=[Select Id from Profile where name=:profileName].Id;  
        return profileId;
        }
    
    public static final String Trade_Compliance='Trade Compliance';
    public static final String Sensitive_BusinessStatus='Sensitive Business';
    //U-1921 & U-1990
    public static final String MANUAL = 'Manual';
    public static final String EDIT = 'Edit';
    public static final String TERRITORY = 'Territory';
    public static final String GCUHYPHEN = 'GCU - '; 
    public static final String TerritoryTriggerHelper = 'TerritoryTriggerHelper';
    public static final String updateCrgSharing = 'updateCrgSharing';
    public static final String updateSharing = 'updateSharing';
    public static final String getCrgMapAfterCagSplit = 'getCrgMapAfterCagSplit';
    public static final String getCrgMapAfterCrgSplit = 'getCrgMapAfterCrgSplit';
    public static final String createCrgGcuMap = 'createCrgGcuMap';
    public static final String AddCrgShareRecord = 'AddCrgShareRecord';
    public static final String updateGcuShareRecord = 'updateGcuShareRecord';
    
    public static final String campaignMemberStatus = System.Label.CampaignMemberStatus;
    public static final String MarketoSyncUserName = System.Label.MarketoSyncUserName;
    public static final String CloneOpportunityHelper = 'CloneOpportunityHelper';
    public static final String resetClonedOppties = 'resetClonedOppties';
    public static final String MELACommercialManagementId = System.Label.MELACommercialManagementId;
    public static final String error1 = 'You do not have the permission to update this field, please reach out to Commercial Management.';
    public static final String error2 = 'You do not have the permission to update this field. Only a member of the specified MA Approver group have permission to update this field.';
	public static final String error3 = 'You do not have the permission to update this field. Only a member of the specified BA Approver group have permission to update this field.';
	public static final string newEarlyStart = 'New Early Start';
    public static final string updateReasonForEarlyStart = 'Update Reason for Early Start';
    public static final string updateScopeOfEarlyStart = 'Update Scope of Early Start';
	public static final string updateEarlyStartDegree = 'Update Early Start Degree';
    public static final string updateCommodities = 'Update Commodities';
    public static final string updateBoQwithDeliveryObjectsAttachments = 'Update BoQ with Delivery Objects Attachments';	   
    public static final string updateScopeDescription = 'Update Scope Description';
    public static final string updateUpdatedTotalValueOfRelatedOpp = 'Update Updated Total Value of Related Opp';   
    public static final string Sales_Prediction_Max_Value = System.Label.Sales_Prediction_Max_Value;
    public static final string Max_Limit_of_Sales_Prediction_has_been_Reached = System.Label.Max_Limit_of_Sales_Prediction_has_been_Reached;
    public static final string Years = 'Years';
    public static final string Quarters = 'Quarters';
    public static final string SUCCESS1 ='SUCCESS-';
    public static final string Won = 'Won';
    public static final string Lost = 'Lost';
    public static final string Y = 'Y';
    public static final string accountQuery = 'select id, Name from Account';
    public static final string contactQuery = 'select id, Name from Contact';
    public static final string leadQuery = 'select id, Name from Lead';
    public static final string oppQuery = 'select id, Name from Opportunity';
    public static final string baseURL = 'https://ericsson.lightning.force.com';
    public static final string salesforceBaseURL = 'String.Valueof(URL.getSalesforceBaseUrl())';
    public static final string ACC = 'ACC';
    public static final string CON = 'CON';
    public static final string LEAD = 'Lead'; 
    public static final string OPP = 'Opp';
    public static final string message1 = 'Deviations cannot be requested since opportunity is closed';
	public static final string message2 = 'Deviation Approvals has already been requested';
	public static final string message3 = 'Proposal should be primary for EBD Deviation Approval Management.';
	public static final string message4 = 'You do not have the permission to request deviation approvals, please reach out to Commercial Management';
	public static final string message5 = 'Submitted For Approval successfully.';
	public static final string message6 = 'No deviation records found.';
    public static final string message7 = 'Deviations cannot be recalled since opportunity is closed';
	public static final string message8 = 'You do not have the permission to recall deviation approvals, please reach out to Commercial Management';
	public static final string message9 = 'Deviations recalled successfully.';
	public static final string message10 = 'No deviation records found to recall.';
    public static final string UpdateTradeComplianceOnOppQuery = 'SELECT Id,Ship_To_Countries__c,StageName,Trade_Compliance_Status__c,Trade_Classifications__c,AccountID FROM Opportunity WHERE AccountID in : parentAccount ';
    public static final string Opportunity = 'Opportunity';
    public static final string SalesDecisionApprovedStatusError1 = System.Label.SalesDecisionApprovedStatusError;
	public static final String CheckSDRIsReadyForNextStageError = System.Label.CheckSDRIsReadyForNextStageError;
	public static final String MELAOpptyError = System.label.MELAOpptyError;
    public static final String Recalled = 'Recalled';
	public static final String falseText = 'false';
    public static final String sogRecordTypeId = Schema.SObjectType.SDOD_Lead__c.getRecordTypeInfosByName().get('SOG').getRecordTypeId();
	public static final String aosRecordTypeId = Schema.SObjectType.SDOD_Lead__c.getRecordTypeInfosByName().get('AoS').getRecordTypeId();
	public static final String sensitiveBusinessRecordTypeId =  Schema.SObjectType.Secondary_Approval__c.getRecordTypeInfosByName().get('Sensitive Business').getRecordTypeId();
    public static final String PriceBook2Name_Default = System.Label.PriceBook2Name_Default;
    public static final String OppSummaryChart1 = System.Label.OppSummaryChart1;
	public static final String OppSummaryChart2 = System.Label.OppSummaryChart2;
	public static final String OppSummaryChart3 = System.Label.OppSummaryChart3;
	public static final String OppSummaryChart4 = System.Label.OppSummaryChart4;
    public static final string ERICSSONSALESUSERPROFILENAME = 'Ericsson Sales User';
    
    //U-1903
    public static final string UPSERT_CONTRACT_ERROR = 'There was an error when trying to upsert Contract: ';
    public static final string INSERT_CONTRACT_ERROR = 'There was an error when trying to insert OpportunityContract__c record(s): ';
    public static final string UPDATE_REFFERING_OPP_ERROR = 'There was an error when trying to update Referring Opportunity records: ';
    public static final string INSERTCONTRACTVALID_ERROR = 'There was an error when trying to insert ContractValidForLegalEntity records: ';
    public static final string UPSERT_CONTRACT_VALID_FOR_LEGAL_ENTITY_ERROR = 'There was an error when trying to upsert ContractValidForLegalEntity records: ';
    public static final string SalesTeamError = System.Label.SalesTeamError;
    public static final string updateSalesteamOnOpportunity = 'updateSalesteamOnOpportunity';
    public static final string CUBA = 'Cuba'; 
    public static final string MYANMAR = 'Myanmar';
    public static final string MMEA = 'MMEA';
    public static final string SDM_APPROVER_ALREADY_ADDED_ERROR = 'The Approver is already added to the SDM. Please add additional roles to that record instead.';
    public static final string Error_To_Restrict_Updation_for_Primary_Sales_Team_Member = System.Label.Error_To_Restrict_Updation_for_Primary_Sales_Team_Member;
    public static final string Error_Msg_for_Restrict_Deletion_of_SDM = System.Label.Error_Msg_for_Restrict_Deletion_of_SDM;
    public static final string SDOD_C_Stage = label.SDOD_C_Stage;
    public static final string CONTRIBUTION_ERROR = 'Contibution should not be greater than 100';
    public static final string QUEUE = 'Queue';
    public static final string CHAR_A = 'A';
    public static final string MNEA = 'MNEA';
    public static final string MOAI = 'MOAI';
    public static final string QUEUE_NOT_AVAILABLE_ERROR = 'Queue is not available with Customer Unit. Please contact the System Administrator to create the new Queue';
    public static final string CANNOT_UPDATE_LEAD_ERROR = 'You cannot update a Lead owned by a Queue, please take ownership of the record 1st'; 
    public static final string INACTIVE = 'Inactive';
    public static final string getEmployees = 'getEmployees';
    public static final string getHitsAcr ='getHitsAcr';
    public static final string getFilteredLeads = 'getFilteredLeads';
    public static final string getCU = 'getCU';
    public static final string UpdateCreatedBy = 'UpdateCreatedBy';
    public static final string InactiveContactEmailToOwner = 'InactiveContactEmailToOwner';
    public static final string SDOD_ORGANIZATION_TYPE_EA = 'SDOD%EA%';
    public static final string Premium_Proposal = 'Premium Proposal';
    public static final Id Premium_Proposal_Record_Type_Id = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get(GlobalConstants.Premium_Proposal).getRecordTypeId();
    public static final string MIGRATIONUSERPROFILENAME ='Migration User Profile';
    public static final string SYSTEMADMINPROFILENAME ='System Administrator';
    public static final string ERICSSON_SALES_USER_PROFILE_NAME ='Ericsson Sales User';
    public static final string PriceBook2Name_Default_Id = System.Label.PriceBook2Name_Default_Id;
    public static final string OpportunityPriceBookHelper = 'OpportunityPriceBookHelper';
    public static final string populatePriceBookIdOnNewOpp = 'populatePriceBookIdOnNewOpp';
    public static final String ProposalInbound_Get_error = 'ProposalInbound Get error = '; 
    public static final String Opportunity_Product_Delete_Validation_Error = System.Label.Opportunity_Product_Delete_Validation_Error;
    public static final String OpportunityProductTriggerHandlerHelper_Get_error = 'OpportunityProductTriggerHandlerHelper Get error = ';
    public static final String calculateLeadDomain = 'calculateLeadDomain';
    public static final String getLeadingDomain = 'getLeadingDomain';
    public static final String Bracket = '[';
    public static final String DuplicateOpportunityProduct = Label.DuplicateOpportunityProduct;
    public static final String GCU_KAM_Account_Primary_KAM_KAM = 'Please select an User for GCU KAM/Account Primary KAM/KAM';
    public static final String V0 = 'V0';
    public static final String ZERO_STRING ='0';
    public static final String ValidAccountResponsible_AccountPrimary_KAM_CU_Head_Error  = 'Please select a Valid Account Responsible/Account Primary KAM/CU Head';
    public static final String SIMPLEOPPORTUNITYNAME = 'Simple Opportunity';
    public static final String INSERT_FAILED_DUPLICATEVALUE_ERROR = 'Insert failed. First exception on row 0; first error: DUPLICATE_VALUE, duplicate value found: <unknown> duplicates value on record with id: <unknown>: []';
    public static final String CUSTOM_EXCEPTION_PRODUCT2ID_NOT_FOUND = 'Custom Exception: Product2Id not found for Product__c code: ';
    
    
    //ProposalInboundV2 class
    public static final String FRAME_AMENDEMNT_OPPTY_PP = System.Label.Record_Type_Name_Frame_Amendment_Opportunity;
    public static final String STANDARD_OPPTY_PP = System.Label.Record_Type_Name_Standard_Opportunity;
    public static final String CU_Target = 'CU Target';
    public static final String YTD_Value = 'YTD Value';
    public static final String Price_Erosion = 'Price Erosion';
    public static final String Threshold_1 = 'Threshold 1';
    public static final String Threshold_2 = 'Threshold 2';
    public static final String UMAR = 'UMAR';
    public static final String Price_Positioning = 'Price Positioning';
    public static final String Incentive = 'Incentive';
    public static final String Comparison_Price = 'Comparison Price';
    public static final String EBDTC = 'EBDTC';
    public static final String BCTC = 'BCTC';
    public static final String EBDTCMS = 'EBDTCMS';
    public static final String ND = 'ND'; 
    public static final String NCT = 'NCT';
    public static final String Opportunity_Tags = 'Opportunity Tags found under Opportunity Tags section';
    public static final String Close_Date = 'Close Date found under Key Dates section';
    public static final String SDP2 = 'SDP2';
    public static final String SDP3 = 'SDP3';
    public static final String ProposalInbound = 'ProposalInbound';
    public static final String upsertProposal = 'upsertProposal';
    public static final String ProposalUtils = 'ProposalUtils';
    public static final String createVersionZero = 'createVersionZero';
    public static final String ProposalUtils_createVersionZero = 'ProposalUtils_createVersionZero';
    public static final String replaceProducts = 'replaceProducts';
    public static final String ProposalUtils_replaceProducts = 'ProposalUtils_replaceProducts';
    public static final String Qualification_FrameworkWDR = 'Qualification Framework (WDR)';
    public static final String triggerOpportunitiesUpdate = 'triggerOpportunitiesUpdate';
    public static final String You_cannot_deletea_nonsimple_opportunity = 'You cannot delete a non-simple opportunity';
    public static final String Opportunity_Not_Found_in_Salesforce = 'Opportunity Not Found in Salesforce';
    public static final String Proposal_Version_already_exists_in_Salesforce = 'Proposal Version already exists in Salesforce';
    public static final String Ericsson_Sales_Operations = 'Ericsson Sales Operations';
    public static final String ProposalUtils_Get_error = 'ProposalUtils Get error = ';
    //public static final String ProductId_not_found_for_Product__c_code = 'Custom Exception: Product2Id not found for Product__c code: ';
    public static final String RelatedOpp_ReplacableURL = System.Label.RelatedOpp_ReplacableURL;
    public static final String RelatedOpp_LightningURL = System.Label.RelatedOpp_LightningURL;
    public static final String Opp_Record_view = System.Label.Opp_Record_view;
    public static final String SLASH = '/';
    public static final String UNDERSCORE = '_';
    public static final String PERCENT = '%';
    public static final String sdpStatusSDP2 = System.Label.Proposal_SDP2;
   // public static final String 35 = '35';
    public static final String Opportunity_Locked_to_PP = 'Opportunity Locked to PP';
    public static final String setClosedWonMinorFlow = 'setClosedWonMinorFlow';
    public static final String onePrimaryProposal = 'onePrimaryProposal';
    public static final String Incorrect_Opportunity_Record_Type_PD = 'Incorrect Opportunity Record Type PD'; 
    public static final String ProposalTriggerHandlerHelper_Get_error = 'ProposalTriggerHandlerHelper Get error = ';
    public static final String ProposalTriggerHandlerHelper_triggerOpportunitiesUpdate = 'ProposalTriggerHandlerHelper_triggerOpportunitiesUpdate';
    public static final String EmailAddressForTradeCompliance = System.Label.EmailAddressForTradeCompliance;
    public static final String Error_Only_One_Primary_Proposal = System.Label.Error_Only_One_Primary_Proposal;
    public static final String sdpValueSDP2 = System.Label.Proposal_SDP2;
    public static final String FRAMEAMENDEMNTOPPTYPD = System.Label.Record_Type_Name_Frame_Amendment_Opportunity_PD;
    public static final String STANDARDOPPTYPD = System.Label.Record_Type_Name_Standard_Opportunity_PD;
    public static final String Custom_Exception_Prodcode = 'Custom Exception: Product2Id not found for Product__c code: ';
    public static final String Custom_Exception = 'Custom Exception: Price Book Entry Id not found for key(Currency;Pricebook2Id;Product2Id): ';
    public static final String ppRecordTypeID1 = Schema.getGlobalDescribe().get('Proposal__c').getDescribe().getRecordTypeInfosByName().get(System.Label.Record_Type_Name_Premium_Proposal).getRecordTypeId();
    public static final Id productRecordTypeId1 = Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(GlobalConstants.PREMIUM_DECISION_PRODUCT_RT_NAME).getRecordTypeId();
    public static final Id recordTypeId_pd1 = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get(GlobalConstants.PREMIUM_DECISION_RT_NAME).getRecordTypeId();
    public static final Id PREMIUM_PROPOSALrecordTypeId_PD = Schema.SObjectType.Proposal__c.getRecordTypeInfosByName().get(GlobalConstants.PREMIUM_PROPOSAL_RT_NAME).getRecordTypeId();
    public static final Id PREMIUM_PROPOSAL_Prod_recordTypeId_PD =  Schema.SObjectType.Product__c.getRecordTypeInfosByName().get(GlobalConstants.PREMIUM_PROPOSAL_PRODUCT_RT_NAME).getRecordTypeId();
    public static final Id recordTypeId_PD;
    //recordTypeId_PD=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(GlobalConstants.STANDARD_OPP_RT_NAME_PD).getRecordTypeId();
    //U-1409	
 	public static final Id gcuRecordTypeId = Schema.SObjectType.CustomerUnit__c.getRecordTypeInfosByName().get('Global Customer Unit').getRecordTypeId();     
    public static final Id cuRecordTypeId = Schema.SObjectType.CustomerUnit__c.getRecordTypeInfosByName().get('Customer Unit').getRecordTypeId(); 
    public static final String CRGTriggerHandlerHelper = 'CRGTriggerHandlerHelper';
    public static final String removeCRGSharing = 'removeCRGSharing';
    public static final String CustomerUnitTriggerHandlerHelper = 'CustomerUnitTriggerHandlerHelper';
    public static final String updateCuGcuSharing = 'updateCuGcuSharing';
    public static final String KAM_Access_Group = 'KAM_Access_Group';
    public static final String Customer_Unit = 'Customer_Unit';
    
    public static String prefix = URL.getSalesforceBaseURL().toExternalForm().replace('https://', '').split('\\.')[0];
	public static final string OrgbaseURL ='https://' + prefix.removeEnd('--c').toLowerCase() + '.lightning.force.com';
    
    //U-1928
    public static final String postToChatter = 'postToChatter';
    public static final String EBD = 'EBD';
    public static final String MANA_Commercial_Management = 'MANA Commercial Management';
    public static final String CUWithSpace = ' CU ';
    public static final String NMSWithSpace = ' NMS ';
    public static final String DSWithSpace = ' DS ';
    public static final String MMEA_CM_Head = 'MMEA CM Head';
    public static final String MMEA_CU_Commercial_Directors = 'MMEA CU Commercial Directors';
    public static final String MNEA_CM_Head = 'MNEA CM Head';
    
    public static final String MOAI_EBD_Contractual_TnC = 'MOAI EBD Contractual T&C';
    public static final String Contractual = 'Contractual';
    public static final String MOAI_EBD_Commercial = 'MOAI EBD Commercial';
    public static final String CU_BHARTI = 'CU BHARTI, BSNL, BHUTAN & NEPAL';
    public static final String CU_MALAYSIA = 'CU MALAYSIA, SRI LANKA & BANGLADESH';
    public static final String CU_SINGAPORE = 'CU SINGAPORE, BRUNEI & PHILIPPINES';
    public static final String CU_AUSTRALIA = 'CU AUSTRALIA, NEW ZEALAND & FIJI';
    public static final String CU_INDONESIA = 'CU INDONESIA';
    public static final String CU_OTHER_MOAI = 'CU OTHER MOAI';
    public static final String CU_SERVICE_PROVIDERS_INDIA = 'CU SERVICE PROVIDERS INDIA';
    public static final String CU_WEST_INDIA = 'CU WEST INDIA (VODAFONE & IDEA)';
    public static final String CU_VIETNAM = 'CU VIETNAM AND MYANMAR'; 
    public static final String CU_THAILAND = 'CU THAILAND';
    
    public static final String MELA_DS_Strategic_Price_Manager = 'MELA DS Strategic Price Manager';
    public static final String MELA_DS_CM_Head = 'MELA DS CM Head';
    public static final String MELA_NMS_CM_Head = 'MELA NMS CM Head';
    public static final String MELA_DS_CM_Head_n_Head_of_Price_Mgmt = 'MELA DS CM Head & Head of Price Mgmt';
    public static final String MELA_NMS_Tactical_Managers = 'MELA NMS Tactical Managers';
    public static final String CU_UK_n_Ireland = 'CU UK & Ireland';
    public static final String MELA_DS_CU_CD_n_CU_HoDS= 'MELA DS CU CD & CU HoDS';
    public static final String CU_UKI = 'CU UKI';
    public static final String CU_EECA = 'CU EECA';
    public static final String CU_NCE = 'CU NCE';
    public static final String CU_SEM = 'CU SEM';
    public static final String CU_FBAT = 'CU FBAT';
    public static final String CU_LATAM_North = 'CU LATAM North';
    public static final String CU_Eastern_Europe = 'CU Eastern Europe & Central Asia';
    public static final String CU_Northern_n_Central_Europe = 'CU Northern & Central Europe';
    public static final String CU_South_East_Mediterranean = 'CU South East Mediterranean';
    public static final String CU_France_BeLux = 'CU France, BeLux, Algeria & Tunisia';
    public static final String CU_LATAM_North_n_Caribbean  = 'CU LATAM North & Caribbean';
    public static final String CU_LATAM_South = 'CU LATAM South';
    public static final String CU_Iberia = 'CU Iberia';
    public static final String CU_Western_Europe = 'CU Western Europe';
    public static final String CU_OTHER_MELA = 'CU OTHER MELA';
    public static final String MELA_Head_of_DS_n_MELA_DS_CM_Head = 'MELA Head of DS & MELA DS CM Head';
    public static final String BNEW_SPOCs = 'BNEW SPOCs';  
    public static final String BDGS_SPOCs = 'BDGS SPOCs'; 
    public static final String BMAS_SA_Head = 'BMAS SA Head';  
    public static final String BMAS_SPOCs = 'BMAS SPOCs';
    
    // U-1741
     public static final String ProposalMessageController = 'ProposalMessageController';
    public static final String getProposalIdForDevType = 'getProposalIdForDevType';
    public static final String  DEVIATIONTYPE_COMPARISONPRICE = 'Comparison Price';
    public static final String  DEVIATIONTYPE_ProfitabilityUM = 'Profitability (UM%)';
    public static final String  DEVIATIONTYPE_SoftwareSubscription = 'Software Subscription';
    public static final String EBD_requesters = 'EBD requesters';//U-1741 
    public static final String To_be_Requested = 'To be Requested';
    public static final String MELA_Sales_Operations = 'MELA Sales Operations';
    public static final String Ref_Sales_Directive = 'Ref. Sales Directive';
    public static final String  createDevType= 'createDevType';
    public static final String  TwoG_ThreeG_RAN_SW = '2G & 3G RAN SW';
    public static final String  RAN_HW_AND_HWAC = 'RAN HW & HWAC';
    public static final String  Indoor = 'Indoor';
    public static final String  ThreePP_Passive_Antenna_Systems= '3PP Passive Antenna Systems';
    public static final String  Other_RAN_HW= 'Other RAN HW';
    public static final String  Radio_Site= 'Radio Site';
    public static final String  Spare_Parts_Sales= 'Spare Parts Sales';
    public static final String  WL_switching= 'WL switching';
    public static final String  CDMA_HW_SW= 'CDMA HW/SW';
    public static final String  ThreePP_Support= '3PP Support';
    public static final String  NRO_Installation= 'NRO Installation';
    public static final String  NRO_SA_CW= 'NRO SA & CW';
    public static final String  Network_Rollout_CISCO= 'Network Rollout CISCO';
    public static final String  NRO_CDMA= 'NRO CDMA';
    public static final String  Consulting= 'Consulting';
    public static final String  System_Integration= 'System Integration';
    public static final String  BDGS_Other= 'BDGS Other';
    public static final String  NRO_In_house= 'NRO In-house';
    public static final String  NRO_Fiber= 'NRO Fiber';
    public static final String  ProductGroup_PassiveAntennaSystems= 'Passive Antenna Systems';
    public static final String  TRUEHASH= 'TRUE#';
    public static final String  UpperCase_TRUE= 'TRUE';
    public static final String  LowerCase_true= 'true';
    public static final String  BDGSHASH= 'BDGS#';
    public static final String  BNEWHASH= 'BNEW#';
    public static final String  HASHSSP= '#SSP';
    public static final String  HASHNet= '#Net';
   	public static final String  HASHEffective= '#Effective';
    public static final String  HASHAAP= '#AAP';
    public static final String  Communication_Services= 'Communication Services';
    public static final String  User_Management= 'User Management';
    public static final String  Evolved_Pack_Core= 'Evolved Pack Core';
    public static final String  BDGS_Software_Subscription= 'BDGS - Software Subscription';
    public static final String MELA_Effective_Message =  'For MELA BDGS Comparison Price: Check if Pricing KPI is as agreed upon';
    //U-1981
    public static final String ABCTriggerHandler='ABCTriggerHandler';
    public static final String ABCTriggerHelper='ABCTriggerHelper';
    public static final String MACO_MOAI='MACO MOAI';
    public static final String Submitting_request_for_approval = 'Submitting request for approval';
    public static final String ApprovedforStage2 = 'ApprovedforStage2';
    public static final String RecalledOrNotYetSubmitted = 'RecalledOrNotYetSubmitted';
    public static final String updateApprovalStatus = 'updateApprovalStatus';
    public static final String populateKamEmail = 'populateKamEmail';
    public static final String ABCTriggerHelperTest = 'ABCTriggerHelperTest';
    public static final String TestABCFlow = 'TestABCFlow';
    public static final String IndirectSalesScenarioSellWith = 'Indirect sales scenario,Sell with';
    public static final String goToApprovalStep1 = 'goToApprovalStep1';
    public static final String updateAccountFields = 'updateAccountFields';
    //public static final String ApprovedforStage2 = 'ApprovedforStage2';
    public static final String ApprovedforStage3 = 'ApprovedforStage3';
    public static final String ApprovedforStage4 = 'ApprovedforStage4';
     public static final String msgforStage2 = 'ABC Approval for Stage "Define customer value", found under Anti Bribery and Corruption section';
    public static final String msgforStage3 = 'ABC Approval for Stage "Create Proposal", found under Anti Bribery and Corruption section';
    public static final String msg1forStage4 = 'ABC Approval for Stage "Negotiate and Close", found under Anti Bribery and Corruption section';
    public static final String msg2forStage4 = 'Confirmation on the ABC Conditional Adherence in the ABC record, found under Anti Bribery and Corruption section';
   
    public static final String CommercialDirectors = 'Commercial Directors';
    public static final String PriceManagersCUCommercialDirector = 'Price Managers & CU Commercial Director';
    public static final String MANAPriceManagers = 'MANA Price Managers';
    public static final String MELADSPriceManagers = 'MELA DS Price Managers';
    public static final String MELACommercialDirectors = 'MELA Commercial Directors';
    public static final String ProposalTriggerHandler = 'ProposalTriggerHandler';
    public static final String MNEACMHead = 'MNEA CM Head';
    public static final String checkEditabilityOfPreApprovalFieldError = 'You are not allowed to check this checkbox';
    public static final String HASH = '#';
    public static final String ampersand = '&';
    public static final String MMEACMHead = 'MMEA CM Head';
    public static final String MMEACUCommercialDirectors = 'MMEA CU Commercial Directors';
    public static final String MELADSCUCDCUHoDS = 'MELA DS CU CD & CU HoDS';
    public static final String MANACommercialManagement = 'MANA Commercial Management';
    public static final String MELADSCMHeadHeadofPriceMgmt = 'MELA DS CM Head & Head of Price Mgmt';
    public static final String MELA_Head_of_DS_MELA_DS_CM_Head = 'MELA Head of DS & MELA DS CM Head';
    public static final String MELANMSTacticalManagers = 'MELA NMS Tactical Managers';
    
    
    // U-1997
    public static final String completeContractEval = 'Complete Contract Evaluation';
    //U-2033, U-2030
    public static final String PREAPPROVED = 'Pre-Approved';
    public static final String MANACOMMERCIALMGMT = 'MANA Commercial Management';
    public static final String AUTOPREAPPROVED = 'Automatically Pre-Approved';
    //U-1999
    public static final String UserTriggerHelper = 'UserTriggerHelper';
    public static final String updateSalesforceUser='updateSalesforceUser';
    public static final String mapUserToEmployee='mapUserToEmployee';
    //U-1795
    public static final String setParentOpportunityAsContractOpportunity='setParentOpportunityAsContractOpportunity';
    
    //U-1979
    public static final String S2WRecordSharingHandler = 'S2WRecordSharingHandler';
    public static final String S2WRecordSharingHelper = 'S2WRecordSharingHelper';
    public static final String S2WRecordSharingWithMembers = 'S2WRecordSharingWithMembers';
    public static final String Read = 'Read';
    public static final String SalesTeamTriggerHandler = 'SalesTeamTriggerHandler';
    public static final String CUCanada = 'CU Canada';
    public static final String CUEmergingBusiness = 'CU Emerging Business';
    
    //U-2039 && U-2035 && U-2072
    public static final String EUFTTriggerHandler = 'EUFTTriggerHandler';
    public static final String EUFTTriggerHelper = 'EUFTTriggerHelper';
    public static final String updateSBSStatus = 'updateSBSStatus';
    public static final String createEUFTRecord = 'createEUFTRecord';
    public static final String Successful = 'Successful';
    public static final String PartiallyCompleted = 'Partially Completed';
    public static final String Camel_Success = 'Success';
    public static final String Failed = 'Failed';
    public static final String Error_PurposeOrUsecase_CannotBeBlank = 'Purpose / Use Case should not be blank';
    public static final String Error_TechnologyRiskThreshold_CannotBeBlank = '  Technology Risk Threshold on any of the EUFTs should not be null';
    public static final String Error_UseCase_CannotBeBlank = 'Use Case should not be blank';
    public static final String Error_Purpose_CannotBeBlank = 'Purpose should not be blank';
    public static final String TriggerRequired = 'Trigger Required';
    public static final String CU_IOT = 'CU IOT';
    public static final String CAMEL_LOW = 'Low';
    public static final String sbsCalloutOnClosedWon = 'sbsCalloutOnClosedWon';
    public static final String SetSBSStatus = 'SetSBSStatus';
    public static final String SBS_Endpoint = 'callout:SBS';
    public static final String updateShipToCountries = 'updateShipToCountries';
    public static final String addErrorOnConfirmEndCustomer = 'addErrorOnConfirmEndCustomer';
    public static final String addErrorOnConfirmEndCustomerError1 = 'No EUFT Number found for EUFTs';
    public static final String addErrorOnConfirmEndCustomerError2 = 'Please Check "I confirm it is the correct End customer" Checkbox is Checked';
    //U-2171
    //public static final String  GOVERNMENT = 'Government Functions';
    //public static final String  CIVIL = 'Civil';
    //public static final String  DEFENSE = 'Armed Forces';
    //public static final String  SuppliersofMilitarySystems = 'Suppliers of Military Systems';
    //public static final String  GovernmentEntity_Utilities = 'Government Entity/Utilities';
    
    //U-1930
   public static final String setApprovers='setApprovers';
   public static final String CUSupplyHead='CU Supply Head';
   public static final String MAHeadorDelegate='MA Head or Delegate';
   public static final String TradeFinanceHeadofCustomerFinance='Trade Finance/Head of Customer Finance';
   public static final String BARepresentativeManagedServices='BA Representative - Managed Services';
   public static final String BARepresentativeDigital='BA Representative - Digital';
   public static final String BARepresentativeEmergingBusIOT='BA Representative - Emerging Bus. & IoT';
   public static final String BARepresentativeNetworks='BA Representative - Networks';
   public static final String All='All';
   public static final String Hardware='Hardware';
   public static final String Software='Software';
   public static final String LetterofCredit ='Letter of Credit / Financing Agreement not yet available and/or approved by GFFI Trade Finance';

   public static final String Other2='Other 2';
   public static final String Other3= 'Other 3';  
   //U-0887
   public static final String setApproversOnExtension='setApproversOnExtension'; 
   //U-2215 
   public static final String Services='Services';
    //U-2200
    public static final String BMAS_EBD_TnC = 'BMAS - EBD T&C';
    public static final String EBD_TnC = 'EBD T&C';
    public static final String BNEW_Non_Delegated = 'BNEW - Non-Delegated';
    public static final String BDGS_Non_Delegated = 'BDGS - Non-Delegated';
    public static final String BMAS_Non_Delegated = 'BMAS - Non-Delegated';
    public static final String BNEW_New_and_Complex_Technologies = 'BNEW - New and Complex Technologies';
    public static final String BDGS_New_and_Complex_Technologies = 'BDGS - New and Complex Technologies';
    public static final String BNEW_Non_Delegated_Commercial_Aspects = 'BNEW - Non-Delegated Commercial Aspects';
    public static final String BDGS_Non_Delegated_Commercial_Aspects = 'BDGS - Non-Delegated Commercial Aspects';
    public static final String BMAS_Non_Delegated_Commercial_Aspects = 'BMAS - Non-Delegated Commercial Aspects'; 
    //U-2173
	public static final String  IT_MS_ADM= 'IT MS & ADM';
    public static final String  IT= 'IT';
    public static final String  ITS= 'ITS';
	public static final String  BMASHASH= 'BMAS#';
   public static final String MELA_NMS_DS_CM_Head = 'MELA NMS/DS CM Head';
   public static final String NMS_Tactical_DS_Strategic_Price_Managers = 'MELA NMS Tactical/DS Str. Pr. Mgrs';
    //U-2270
    public static final String setSBSRiskValues = 'setSBSRiskValues';
    public static final String updateCountryRisk = 'updateCountryRisk';
	
	//D-3445
    public static final String SDP0Qualify = 'SDP0 Qualify';
	//U-2275
    //U-2381
    public static final String sensitiveBusinessApprovalSubmission = 'sensitiveBusinessApprovalSubmission';
    public static final String UPDATE_ASSOCIATED_TERRITORIES = 'upadteAssociatedTerritories';
    //U-2190
    public static final String getSignumofUser='getSignumofUser';
    public static Map<string,string> returnUserValue(){
       map<string,string>mapofupdatedfields=new map<string,string>();
            mapofupdatedfields.put('Other__c','Other_Signum__c');
            mapofupdatedfields.put('MA_Head_or_Delegate__c','MA_Head_or_Delegate_Signum__c');
            mapofupdatedfields.put('CU_Supply_Head__c','CU_Supply_Head_Signum__c');
            mapofupdatedfields.put('Early_Start_CSR__c','Early_Start_CSR_Signum__c');
            mapofupdatedfields.put('Early_Start_CFR__c','Early_Start_CFR_Signum__c');
            mapofupdatedfields.put('Early_Start_ACR__c','Early_Start_ACR_Signum__c');
            mapofupdatedfields.put('Trade_Finance__c','Trade_Finance_Signum__c');
            mapofupdatedfields.put('BA_Representative__c','BA_Representative_Signum__c');
            mapofupdatedfields.put('BA_Representative_Digital__c','BA_Representative_D_Signum__c');
            mapofupdatedfields.put('BA_Representative_Emerging_Bus_IOT__c','BA_Representative_EB_IOT_Signum__c');
            mapofupdatedfields.put('BA_Representative_Managed_Services__c','BA_Representative_MS_Signum__c');
            mapofupdatedfields.put('BA_Representative_Networks__c','BA_Representative_N_Signum__c');
            return mapofupdatedfields;
    }
    //U-2290
    public static final String activeSecondaryApprovalerrorMessage = 'You already have an active Secondary approval, type Sensitive Business related to your opportunity';
    
    //U-2399
    public static final String updateConsolidatedBlockListOnAccount = 'updateConsolidatedBlockListOnAccount';   
    public static final String updateManualSBStatusRequired = 'updateManualSBStatusRequired'; 
    public static final String callSBSCalloutOrApprovalProcess = 'callSBSCalloutOrApprovalProcess';
    public static final String sendEmailToAOForSBS = 'sendEmailToAOForSBS';
    public static final String OpportunityLwcController = 'OpportunityLwcController';        
    public static final String UpdateSecondaryApproval = 'UpdateSecondaryApproval';
    public static final String restrictCreationOfSecondaryApproval = 'restrictCreationOfSecondaryApproval';
    public static final String updateActiveSensitiveBusinessApprovalOnOpp = 'updateActiveSensitiveBusinessApprovalOnOpp';
    public static final String updateisActiveFlag = 'updateisActiveFlag';
    public static final String clearActiveSensitiveBusinessApprovalOnOpp = 'clearActiveSensitiveBusinessApprovalOnOpp';
    public static final String COMPLETED = 'Completed';
    public static final String PURPOSE_SURVEILLANCE = 'Surveillance that identifies individuals (Active)';
    public static final String ACCEPTED_APPROVAL = 'Accepted Approval';
    public static final String Approvedwithcondition = 'Approved with condition';
    public static final String AcceptedApprovalwithconditions = 'Accepted Approval with conditions';
    public static final String DismissedbySBteam = 'Dismissed by SB team';
    public static final String AcceptedDismissal = 'Accepted Dismissal';
    public static final String Submittedformanualapproval = 'Submitted for manual approval';
    //U-1910
     public static final String disappearApprovers='disappearApprovers';
	//U-2343
    public static final String RecallSDRApproval ='RecallSDRApproval';
	    //U-2193
    public static final String updateNickName = 'Please check FirstName and LastName of the User';
	
	//U-2316
	public static final String SdrSubmitForApprovalCtrl = 'SdrSubmitForApprovalCtrl';
    public static final String sendApprovaRequest = 'sendApprovaRequest';
    public static final String restrictApprovalForNameRole = 'Please check Sales Decision Makers|Approver Name and Role are required for all SDMs to submit for approval';
    public static final String restrictApprovalForSdrNotComplete = 'Review the errors on this page.|Please make sure that your Sales Decision Record is ready for Approval before you send out Approval Requests for the Sales Decision Makers. This is to make sure that Approvals are based on the correct Opportunity information.';
    public static final String AuraException = 'System.AuraHandledException';
    public static final String NoSdr = 'No';
    public static final String OtherSdr = 'Other';
	
	//U-2291 and U-2370
   public static final String DeviationTriggerHelper='DeviationTriggerHelper';
    public static final String updateProductGroup='updateProductGroup';
    public static final String BDGS_Comparison='BDGS - Comparison Price';
    public static final String BDGS_Comparison_MELA_Effective_Net_Price='BDGS-Comparison Price - MELA Effective Net Price';
 	public static final String DeviationTypeGroupHelper='DeviationTypeGroupHelper';
    public static final String updateProposalEBDStatus1='updateProposalEBDStatus1';
    public static final String updateQuesProdGroupsOnProposal='updateQuesProdGroupsOnProposal';
    public static final String updateProductGroupOnDeviation='updateProductGroupOnDeviation';
	public static final String leftSqaureBracket='[';
    public static final String rightSqaureBracket=']';
	
    //U-2129
    public static final String SDPMeetingInviteController='SDPMeetingInviteController';
    public static final String sendInviteURL='sendInviteURL';
    public static final String getSalesTeamEmails='getSalesTeamEmails' ;

   //U-2385
   public static final String Submittedforsemiautoapproval = 'Submitted for semi-auto approval';
   public static final String Submittedforautoapproval = 'Submitted for auto approval';
   public static final String Tobesubmitted = 'To be submitted'; 
}