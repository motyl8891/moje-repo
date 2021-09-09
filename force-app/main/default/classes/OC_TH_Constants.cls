/**
* @File Name          : OC_TH_Constants
* @Description        : Constants related to Ticket Handling Community UI
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 19 Jan 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-01-19                 IBM                   Initial Version
* 1.1        2021-02-16                 IBM                   Update Version
**/
public without sharing class OC_TH_Constants {
    
    public static void testConstants(){ 
        /*Added by Nagashree for U-31098*/
        System.assertNotEquals(null, OC_TH_QUEUELISTCONTROLLER);
        System.assertNotEquals(null, GETFETCHRECORDS);
    }
    
    public static final String TicketHandling = 'Ticket Handling';
    public static final String ticket_handling = 'cases';
    public static final String caseLiteral = 'Case'; 
    public static final Boolean activeTrue= true;
    public static final String caseType = 'Type';
    //public static final AssignmentRule caseAssignmentRule = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
    
    public static final String getStandardCsrRecordType = 'OC_TH_Standard_CSR';
    public static final String getCollaborationCsrRecordType = 'OC_TH_Collaboration_CSR';
    public static final String getCallback1Milestone = 'CALLBACK1';
    public static final String getRemedy1Milestone = 'REMEDY1';
    public static final String getSolution1Milestone = 'SOLUTION1';
    public static final String getRficRecordType ='OC_MD_Request_for_Info';
    public static final String getRemedyRecordType = 'OC_MD_Remedy';
    public static final String getAnswerRecordType= 'OC_MD_Answer';
    public static final String getStatusRequested= 'Requested';
    public static final String getStatusAnswered= 'Answered';
    public static final String getStatusAccepted= 'Accepted';
    public static final String getStatusRejected= 'Rejected';
    public static final String method_shareCaseWithPublicGroup = 'shareCaseWithPublicGroup';
    public static final String Apxcls_CaseMilestoneUtils= 'OC_TH_CaseMilestoneHelper';
    public static final String method_updateCaseRemedyCallbackSolutionField= 'updateCaseRemedyCallbackSolutionField';
    public static final String method_updateCaseMilestoneValuesOnCase= 'updateServiceMilestoneValuesOnCase';
    public static final String method_completeMilestone ='completeMilestone';
    public static final String method_startMilestone ='startMilestone';
    public static final string sla_OC_TH_ServiceMilestone = 'OC_TH_ServiceMilestone';
    public static final string getEmergencyPriority = '1';
    public static final string getHighPriority = '3';
    public static final string getMediumPriority = '5';
    public static final string getlowPriority = '9';
    public static final string getMilestoneAlertGreen = 'Green';
    public static final string getEmgTime = 'Emergency_WarningTime';
    public static final string getHighTime = 'High_WarningTime';
    public static final string getMediumTime = 'Medium_WarningTime';
    public static final string getLowTime = 'Low_WarningTime';
    public static final String getStatusOpen= 'Open';
    public static final String getStatusInfoProvided= 'Info provided';
    public static final String getStatusInfoAccepted= 'Info accepted';
    public static final string method_updateMilestoneAlertOnCase='updateMilestoneAlertOnCase';
    //Added by Subashini as part of U-2585
    public static final string getInvestigationLeaderId ='Investigation_Leader';
    public static final string getFormerInvestigationLeaderId ='Former_Investigation_Leader';
    public static final string getTeamMemberId ='Team_Member';
    public static final string getFormerTeamMemberId='Former_Team_Member';
    public static final string containsFormer='Former';
    public static final string Apxcls_CaseTeamMember ='OC_TH_CaseTeamMember';
    public static final string method_standardCSRInsertCheck ='standardCSRInsertCheck';
    public static final string method_CollaborationCSRInsertCheck ='CollaborationCSRInsertCheck';
    public static final string method_caseUpdateCheck='caseUpdateCheck';
    public static final string method_taskInsertCheck='taskInsertCheck';
    public static final string method_taskUpdateCheck='taskUpdateCheck';
    //Added by Aishwarya as part of U-2692
    public static final String getCustomerCommunityPlusCustomUserProfile= 'Customer Community Plus Custom User';
    public static final String getFeedItemVisibilityAllUser= 'AllUsers';
    /*Added by Aishwarya - As part of US-2948 LICSR*/
    public static final String getEricssonServiceProfile = 'Ericsson Service';
    public static final string getEricssonLiServiceUserPermissionSet = 'OC_TH_Ericsson_LI_Service_User';
    public static final string getEricssonLiCommunityUserPermissionSet = 'OC_TH_Ericsson_LI_community_user';
    public static final string getLICSRPublicGroup = 'LICSR';
    public static final string Apxcls_caseCheckLI_CSR = 'OC_TH_CaseCheckLI_CSR';
    public static final string method_basedOnQueueAssignment ='caseCheckLI_CSR';
    public static final string method_sendEmailtoPublicGroup = 'sendEmailtoPublicGroup';
    public static final string Apxcls_userHelperClass = 'OC_TH_UserTriggerHelper';
    public static final string method_updateAddLiUserToPermissionSet ='addLiUserToPermissionSet';
    public static final string method_updateAddUserToLicsrPublicGroup ='addUserToLicsrPublicGroup';
    public static final string method_updateRemoveLiUserFromPermissionSet ='removeLiUserFromPermissionSet';
    public static final string method_updateRemoveLiUserFromLIPublicGroup ='removeLiUserFromLIPublicGroup';
    public static final string method_updateAddUserToLiCountryPublicGroup ='addUserToLiCountryPublicGroup';
    public static final string method_updateDeleteUserFromPublicGroup ='deleteUserFromPublicGroup';
    //Added by monika bisht
    public static final string getQueue='Queue';
    public static final string getEdit='Edit';
    //Added by Aayush as part of U-2773
    public static final string getNodeType ='Node Type';
    public static final string getNodeComponent ='Node Component';
    public static final string getLICSRQueue='LI CSR Queue';
    public static final string getSolution='Solution';
    public static final string getNodeTypeRecordType = 'OC_MD_Node_Type';
    public static final string getNodeComponentRecordType = 'OC_MD_Node_Component';
    public static final string getSolutionRecordType = 'OC_MD_Solution';
    public static final String Apxcls_CaseAssignmentUtils= 'OC_TH_CaseAssignmentHelper';
    public static final String method_caseQueueAssignment ='caseQueueAssignment';
    public static final String method_updateCaseWithAssetFields ='updateCaseWithAssetFields';
    public static final String accountCNSQueue = 'Account CNS Queue';
    public static final string getTypeConsultation = '003';
    public static final string getTypeProblem = '002';   
    /* Added By Rishabh - As part of U-2947 LICSR Cloning */
    public static final String getLICSRRecordType = 'OC_TH_LI_CSR_Partial_view'; 
    public static final String assetLiteral = 'AssetId';
    public static final String statusLiteral = 'Status'; 
    public static final String productDetailLiteral = 'OC_TH_Product_Details__c';
    public static final String method_partialCaseClone ='partialCaseClone';
    public static final String method_ownerContactChangeValidation ='ownerContactChangeValidation';
    public static final String method_ownerQueueChangeLICSR ='ownerQueueChangeLICSR';
    public static final String method_caseMirroringOnUpdate ='caseMirroringOnUpdate';
    public static final String apexClass_CaseMirroringLICSR ='OC_TH_CaseMirroringLICSR';
    public static final string getLICSRQueueDevName='OC_TH_LI_CSR_No_User_Queue';
    public static Final Id recordType_PartialCSR = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(getLICSRRecordType).getRecordTypeId();
    public static Final Id recordType_StandardCSR = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(getStandardCsrRecordType).getRecordTypeId();    
    public static Final Id recordType_CollaborationCSR = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(getCollaborationCsrRecordType).getRecordTypeId();    
    public static Final String standardGroupIdPrefix = '00G';
    public static Final String standardUserIdPrefix = '005';
    public static Final String permissionSetEricssonLI = 'OC_TH_Ericsson_LI_Service_User';
    public static final Boolean isLiCsrUser= false;
    public static final string milestonetype = 'Solution1';   
    /*Added by Aayush - As a part of U-2950*/
    public static final String equal= 'Equal';
    public static final String notEqual= 'Not Equal';
        
    /*Added by Aishwarya - As part of US-2925 */
    public static final Id getNodeTypeRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(getNodeTypeRecordType).getRecordTypeId();        
    public static final Id getNodeComponentRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(getNodeComponentRecordType).getRecordTypeId();
    public static final Id getSolutionRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(getSolutionRecordType).getRecordTypeId();
    public static final Id getAccountServiceRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAccountServiceRecordType).getRecordTypeId();
    public static final string getAccountTypeService = 'Service';
    public static final string getAccountServiceRecordType = 'OC_MD_Service_Account';
    public static final String getChecked= 'checked';
    public static final String getUnchecked= 'unchecked';
    public static final String getSelectedStatus = 'selected';
    public static final String getDeSelectedStatus = 'deselected';
    public static final String getJsonRecordId = 'Id';
    public static final String getJsonRecordName = 'Name';
    public static final String getJsonSelectedRecordStatus = 'selectedState';
    public static final string getProduct2 = 'Product2';
    public static final string getSuccess = 'Success';
    public static final string getError = 'Error';
    public static final string getErrorMessage = 'getErrorMessage';
    public static final string getErrorMessageWhenLocAndAccNull = 'getErrorMessageWhenLocAndAccNull';
    public static final string getHashTagDelimiter = '#';
    public static final string NotServiceElementRecordType = 'OC_MD_Service_Element'; 
    public static final string getBDAPermissionSet = 'Ericsson_Service_BDA';
    public static final string Apxcls_AccountProductSelection = 'OC_TH_AccountProductSelection';
    public static final string method_getProductRecordTypes = 'getProductRecordTypes';
    public static final string method_fetchSelectedAccountsOnly = 'fetchSelectedAccountsOnly';
    public static final string method_getLogicalOpeartorCustomerValues = 'getLogicalOpeartorCustomerValues';
    public static final string method_getRoutingRuleLogicalOperator = 'getRoutingRuleLogicalOperator';
    public static final string method_associateLogicalOperatorToRoutingRule = 'associateLogicalOperatorToRoutingRule';
    public static final string method_getProductName = 'getProductName';
    public static final string method_submitAccountDetails = 'submitAccountDetails';
    public static final string method_submitProduct2Details = 'submitProduct2Details';
    public static final string method_showErrorMessage = 'showErrorMessage';
    public static final string method_validationForLength = 'validationForLength';
    public static final string Apxcls_AccountProductSelectionHelper = 'OC_TH_AccountProductSelectionHelper';
    public static final string method_checkSelectedState = 'checkSelectedState';
    public static final string method_AccountInsertion = 'AccountInsertion';
    public static final string method_associateProductsToRoutingRule = 'associateProductsToRoutingRule';
    public static final string method_productNodeType = 'productNodeType';
    public static final string method_productNodeComponent = 'productNodeComponent';
    public static final string method_productSolution = 'productSolution';
    //Test class changes
    //public static final string selectedOperatorForTestClass = 'Equal';
    public static final string dummyJSONInputForTestClassLimitBreach = '{"selected":{"0011l00000vOt1BAAS":{"Id":"0011l00000vOt1BAAS","Name":"Account 1","selectedState":"checked","filtered":true},"0011l00000qdCv2AAE":{"Id":"0011l00000qdCv2AAE","Name":"Claro-BR","selectedState":"checked","filtered":true},"0011l00000z9dqmAAA":{"Id":"0011l00000z9dqmAAA","Name":"CTM Fixed MO","selectedState":"checked","filtered":true},"0011l00000rR7IjAAK":{"Id":"0011l00000rR7IjAAK","Name":"Telecom Company - 1 Service to Party","selectedState":"checked","filtered":true},"0011l00000zMNNXAA4":{"Id":"0011l00000zMNNXAA4","Name":"Telefonica","selectedState":"checked","filtered":true},"0011l00000qeeRBAAY":{"Id":"0011l00000qeeRBAAY","Name":"Test 4 Account","selectedState":"checked","filtered":true},"0011l00000vky46AAA":{"Id":"0011l00000vky46AAA","Name":"Test Account","selectedState":"checked","filtered":true},"0011l00000vky3IAAQ":{"Id":"0011l00000vky3IAAQ","Name":"Test Account2","selectedState":"checked","filtered":true},"0011l00000vky3mAAA":{"Id":"0011l00000vky3mAAA","Name":"Test Account4","selectedState":"checked","filtered":true},"0011l00000wVET2AAO":{"Id":"0011l00000wVET2AAO","Name":"Test ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc-WithoutSoldTo","selectedState":"checked","filtered":true},"0011l00000qeeQcAAI":{"Id":"0011l00000qeeQcAAI","Name":"test cl","selectedState":"checked","filtered":true}},"deselected":{}}';
    public static final string dummyJSONInputForTestClassNoLimitBreach ='{"selected":{"0011l00000qdCv2AAE":{"Id":"0011l00000qdCv2AAE","Name":"Claro-BR","selectedState":"checked","filtered":true},"0011l00000z9dqmAAA":{"Id":"0011l00000z9dqmAAA","Name":"CTM Fixed MO","selectedState":"checked","filtered":true},"0011l00000vky3IAAQ":{"Id":"0011l00000vky3IAAQ","Name":"Test Account2","selectedState":"checked","filtered":true},"0011l00000wVET2AAO":{"Id":"0011l00000wVET2AAO","Name":"Test ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc-WithoutSoldTo","selectedState":"checked","filtered":true}},"deselected":{"0011l00000vOt1BAAS":{"Id":"0011l00000vOt1BAAS","Name":"Account 1","selectedState":"unchecked","filtered":true}}}';
    /*Added by Aayush - As a part of U-2957*/
    public static final string getlist = 'List';
    public static final string getcount = 'Count';
    public static final string getEmailTemplate = 'OC_TH_LI_CSR_Temp';
    public static final string getPVC = 'PVC';
    public static final string getSTA = 'STA';
    
    /*Added by Nagashree  -As a part of U-3109*/
   public static final String queue = 'Queue';
    public static final String OC_TH_QUEUELISTCONTROLLER='OC_TH_queueListController';
    public static final String GETFETCHRECORDS = 'getFetchQueueRecords';
    /*Added by Monika */
    public static final String userId = '005';
    public static final String Apxcls_SystemUtility = 'OC_SystemUtility';
    /*Added by Nagashree -As a part of U-2926*/
   // public static final string contextIdentifier='TicketHandling';
   public static final String getStatus = 'Finished';
   public static final String getServiceAccountRecordType = 'OC_MD_Service_Account';
   public static final String orgWideDefaultAddress = 'noreply.salesforce@ericsson.com';
   /*Added by Monika */
   public static final String customNotificationType = 'OC_TH_On_Case_Creation_Notification';
    
    /*Added by Rishabh -As a part of D-4256*/
    public static final String method_CaseUpdateOnTaskChange ='CaseUpdateOnTaskChange';
    public static final String apexClass_OC_TH_CaseUpdateOnTaskChange ='OC_TH_CaseUpdateOnTaskChange';
    public static final String getWaitingOnCustomer = 'Customer';
    public static final String getTaskStatusAnswerAccepted = 'Answer Accepted';
    public static final String getTaskStatusRFICInfoProvided = 'RFIC Info Provided';
    public static final String getAnswerRejected = 'Answer Rejected';
    public static final String getTaskStatusRemedyAcepted = 'Remedy Accepted';
    public static final String getTaskStatusRemedyRejected = 'Remedy Rejected';
    public static final String getStatusAnalysis = 'Analysis';
    public static final String getStatusFinished = 'Finished';
    public static final Id getTaskRequestForInfoRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRficRecordType).getRecordTypeId();      
    public static final Id getTaskRemedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
    public static final Id getTaskAnswerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
    public static final Boolean activeFalse= false;
    public static final String getStringNull = null;
    public static final dateTime getDateTimeNull = null;
    
    public static final String getLIContactRecordType = 'OC_TH_LI_Contact';
    public static Final Id recordType_LIContact = Schema.SObjectType.OC_AN_Group_Member__c.getRecordTypeInfosByDeveloperName().get(getLIContactRecordType).getRecordTypeId();   
    
    
    /*Added by Aishwarya as part of U-2964 */
    public static final string Apxcls_OC_TH_CsrServiceMilestone = 'OC_TH_CsrServiceMilestone';
    public static final string method_getMilestoneDataFromParentID = 'getMilestoneDataFromParentID';
    public static final string method_noMilestoneMessage = 'noMilestoneMessage';
    
    /*Added by Aayush as part of U-3108 & U-2771 */
    public static final string getEmailTemplateRFIC = 'OC_TH_CSR_RFI_C';
    public static final string getEmailTemplateRemedy = 'OC_TH_CSR_Remedy';
    public static final string getEmailTemplateFormalAnswer = 'OC_TH_CSR_Formal_Answer';
    public static final string getRFICRequested = 'RFICRequested';
    public static final string getRemedyProvided = 'RemedyProvided';
    public static final string getAnswerProvided = 'AnswerProvided';
    public static final string getTicketCreated = 'TicketCreated';
    public static final string getTicketFinished = 'TicketFinished';
    public static final string getTicketCancelled = 'TicketCancelled';
	public static final string getEmailNotificationsEnabled = 'EmailNotificationsEnabled';
    public static final string gethtmlBody = 'htmlBody';
    public static final string getplainBody = 'plainBody';
    public static final string getsubject = 'subject';
    public static final string Apxcls_TaskTriggerHelper = 'OC_TH_TaskTriggerHelper';
    public static final string Apxcls_UserPreferencesController = 'OC_AN_UserPreferencesController';
    public static final string method_sendEmailNotifications = 'sendEmailNotifications';
    public static final string method_returnEmailTemplateBody = 'returnEmailTemplateBody';
    public static final string method_returnEmailBody = 'returnEmailBody';
    public static final string method_submitUserPreferences = 'submitUserPreferences';
    public static final string method_alertInsertion = 'alertInsertion';
    public static final string method_getEmailSettings = 'getEmailSettings';
    public static final string method_getEmailSettingsupdates = 'getEmailSettingsupdates';
    public static final string method_getEmailAlertSettings = 'getEmailAlertSettings';
    
    public static final string Apxcls_TaskTriggerHandler = 'OC_TH_TaskTriggerHandler';
    public static final string method_BeforeInsert = 'BeforeInsert';
}