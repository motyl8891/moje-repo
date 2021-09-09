/*******************************************************************************
* @author:  Andrejs Veliks 
* @date:    2017-11-07
* @description: This is the web-service class for working with 
                Opportunity_Contract_Inbound
********************************************************************************/
global without sharing class OpportunityContractUpsert_WS { 
 
    static String finalErrorMsg='';
    static private String successResponse = GlobalConstants.RESPONSE_SUCCESS_OPPORTUNITY_CONTRACT_UPSERT;
    static private String errorResponse = GlobalConstants.RESPONSE_ERROR_OPPORTUNITY_CONTRACT_UPSERT;
    static private String logNameRequest = GlobalConstants.LOG_NAME_REQUEST_OPPORTUNITY_CONTRACT_UPSERT;
    static private String logNameResponse = GlobalConstants.LOG_NAME_RESPONSE_OPPORTUNITY_CONTRACT_UPSERT;
    static private String logNameError = GlobalConstants.LOG_NAME_ERROR_OPPORTUNITY_CONTRACT_UPSERT;

    /*******************************************************************************
    * @author:  Andrejs Veliks
    * @date:    2017-11-07
    * @description: This is class for working with data for 
                    Opportunity_Contract_Inbound
    ********************************************************************************/
    global class OpportunityContract{
       
        webservice String ParentOpportunityID;
        webservice String ContractID;
        webservice String ContractAdmin;
        webservice String ContractClassification;
        webservice String ContractName;
        webservice String ContractUrl;
        webservice String ContractOwner;
        webservice String ContractSigningPartyID;
        webservice List<OpportunityContract_VLE> OpportunityContracts_VLE;
        webservice String EricssonSigningPartyID;
        webservice String ParentContractID;
        webservice String AgreementStatus;
        webservice String ContractStatusOfBusiness;
        webservice String AgreementStage;
        webservice String ModifiedDate;
        webservice String LoadDate;
        webservice String SequenceId;
        webservice String DeleteFlag;
        
        webservice List<String> ReferringOpportunityID;
        
    }

    /*******************************************************************************
    * @author:  Andrejs Veliks
    * @date:    2017-11-07
    * @description: This is class for working with data for 
                    Opportunity Contract VLE
    ********************************************************************************/
    global without sharing class OpportunityContract_VLE{                  
        webservice String SoldtopartyLocalID;
        webservice String EricssonCompanyCode;
        webservice String SoldtopartyStatus; 
    }   

    /****************************************************************
    * @author: Andrejs Veliks
    * @date: 2017-11-07
    * @param: opportunityContract 
    * @return String ok
    * @description: This method will update data from web service 
    * and store in Opportunity Contract Inbound custom object in SF
    *****************************************************************/
    webservice static String upsertOpportunityContract(OpportunityContract opportunityContract){
        try{

            String uniqueId = GeneralUtils.generateRandomString(30);
            logNameRequest+=' '+String.valueOf(uniqueId);
            EventLog.createLogFuture(Json.serialize(new EventLog.Information('OpportunityContractUpsert_WS', 'upsertOpportunityContract',logNameRequest, false, JSON.serialize(opportunityContract))));
            
            OpportunityContractInbound__c oc = new OpportunityContractInbound__c();
            OpportunityContractVLE__c[] ocProdLs = new List<OpportunityContractVLE__c>();
            String checkString = '';
            //String ErrFieldMsg='';
            String OppResult ='';
            
            String ocid;
            
            
            
            oc.Parent_Opportunity_Id__c = (GeneralUtils.checkFieldMsg(
                                              opportunityContract.ParentOpportunityID, 
                                             'ParentOpportunityID', 
                                              255,
                                             'OpportunityContractWS',
                                             'upsertOpportunityContract')).getokResult();

            oc.External_Id__c = (GeneralUtils.checkFieldMsg(
                							  opportunityContract.ContractID, 
                                             'ContractID', 
                                              255,
                                             'OpportunityContractWS',
                                             'upsertOpportunityContract')).getokResult();
            oc.Contract_Admin__c = (GeneralUtils.checkFieldMsg(
                							  opportunityContract.ContractAdmin, 
                                             'ContractAdmin', 
                                              255,
                                             'OpportunityContractWS',
                                             'upsertOpportunityContract')).getokResult();
                    
            oc.Classification__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ContractClassification, 
                                    'ContractClassification', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Contract_Name__c  = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ContractName, 
                                    'ContractName', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Contract_Url__c   = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ContractUrl, 
                                    'ContractUrl', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Contract_Admin__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ContractOwner, 
                                    'ContractOwner', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Contract_Signing_Party_Id__c = (GeneralUtils.checkFieldMsg(
                                               opportunityContract.ContractSigningPartyID, 
                                               'ContractSigningPartyID', 
                                               255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Ericsson_Signing_Party_Id__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.EricssonSigningPartyID, 
                                    'EricssonSigningPartyID', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Parent_Contract_Id__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ParentContractID, 
                                    'ParentContractID', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Contract_Stage__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.AgreementStatus, 
                                    'AgreementStatus', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Status_Of_Business__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ContractStatusOfBusiness, 
                                    'ContractStatusOfBusiness', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Agreement_Stage__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.AgreementStage, 
                                    'AgreementStage', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Ext_Modified_Date__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.ModifiedDate, 
                                    'ModifiedDate', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Ext_Load_Date__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.LoadDate, 
                                    'LoadDate', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Ext_Sequence_Id__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.SequenceId, 
                                    'SequenceId', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            oc.Ext_Delete_Flag__c = (GeneralUtils.checkFieldMsg(
                                    opportunityContract.DeleteFlag, 
                                    'DeleteFlag', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
            
             // Recently added by adding 28-02-2018
           
            
            if (OpportunityContract.ReferringOpportunityID != null) {
               for (String oppIDs: OpportunityContract.ReferringOpportunityID ){
                OppResult +=oppIDs+' ';         
                } 
            }
                                    
            
            oc.Referring_Opportunity_Ids__c = OppResult;
            //=============================================
            

            if ( finalErrorMsg != '' ) {
               if (finalErrorMsg.length()>32767){
                      finalErrorMsg=finalErrorMsg.substring(0, 32766); 
                   }  
              oc.Error_Msg__c=finalErrorMsg;   
            }

            oc.isProcessed__c = False;
            oc.isError__c = False; 
            oc.Import_DT__c = datetime.now();
            insert oc;

            ocid = oc.Id;

            Integer pErrCnt=0;

            System.debug(oc.id+'  Error_MSg; '+oc.Error_Msg__c);

            if (oc.Error_Msg__c != null){
                pErrCnt=oc.Error_Msg__c.length();
            }

            for (OpportunityContract_VLE cvle: OpportunityContract.OpportunityContracts_VLE ){
               OpportunityContractVLE__c ocProdS = new OpportunityContractVLE__c();
               
               ocProdS.Opportunity_Contract__c    = ocid;          

               ocProdS.SoldToParty_Local_Id__c   = (GeneralUtils.checkFieldMsg(
                                    cvle.SoldtopartyLocalID, 
                                    'SoldtopartyLocalID', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
               
               ocProdS.Ericsson_Company_Code__c   = (GeneralUtils.checkFieldMsg(
                                    cvle.EricssonCompanyCode, 
                                    'EricssonCompanyCode', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();
               
               ocProdS.SoldToParty_Status__c   = (GeneralUtils.checkFieldMsg(
                                    cvle.SoldtopartyStatus, 
                                    'SoldtopartyStatus', 
                                    255,
                                    'OpportunityContractWS',
                                    'upsertOpportunityContract')).getokResult();

               ocProdLs.Add(ocProdS);

            }

            insert ocProdLs;

            oc.isProcessed__c = true;

            if (pErrCnt!=finalErrorMsg.length()){
                   if (finalErrorMsg.length()>32767){
                      finalErrorMsg=finalErrorMsg.substring(0, 32766); 
                   }
                   oc.Error_Msg__c=finalErrorMsg;   
              } 
            
            String errmsg;

            try{            
                update oc;
            }
            catch(Exception e){            
                errmsg=e.getMessage();
                System.debug('Something went wrong: '+ errmsg);            
            } 

            GeneralUtils.saveExceptions();
            
            logNameResponse+=' '+String.valueOf(uniqueId);
            EventLog.createLogFuture(Json.serialize(new EventLog.Information('OpportunityContractUpsert_WS', 'upsertOpportunityContract',logNameResponse, false, successResponse)));
            return successResponse;
        }catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error('OpportunityContractUpsert_WS', 'upsertOpportunityContract',logNameError, true, e)));
            System.debug(LoggingLevel.ERROR, 'OpportunityContractUpsert_WS Get error = ' + e.getMessage());
            return errorResponse+' '+e.getMessage();
        }
    }

}