/**
* @File Name          : OC_AN_MC_Automation_Helper
* @Description        : This class will be used to create all the automation activities in MC.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2106
* @Created Date       : 20th May 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-20                 IBM                   Initial Version
* 2.0        2021-07-05                 IBM                   Modified as a part of D-4138
**/
public with sharing class OC_AN_MC_Automation_Helper{
    /**************************************************************************************************
* @Method Name : createSQLQuery_ID
* @Description : Creates SQL Activity based on the buletinId
* @Param       : accessToken - accessToken from MC
* @Param       : BulletinId - Id for the SQL activity needs to be created
* @Param       : flowType - Decided whether it is external or internal
* @Param       : config - MC configurations
* @Param       : step2_targetkey - Target Key
* @Param       : step2_targetName - Target Name 
* @Return      : String
****************************************************************************************************/
    public static String createSQLQuery_ID(String accessToken, id BulletinId, string flowType, Map<string, String> config, String step2_targetkey, String step2_targetName,List<OC_AN_Bulletin_Account_Product__c> productRecords){
        OC_AN_MC_AutomationActivityUtils.accessToken = accessToken;
        string sqlQuery_Step1;
        string step1_targetkey;
        string step1_targetName;
        string customerkey_step1 = flowType + OC_AN_Constants.step1 + BulletinId;
        string name_step1 = flowType + OC_AN_Constants.step1 + BulletinId;
        if(!productRecords.isEmpty()){
            sqlQuery_Step1 = config.get(flowType + OC_AN_Constants.query_Step_1_WithProduct)+'\'' + BulletinId + '\'';
		}else{
            sqlQuery_Step1 = config.get(flowType + OC_AN_Constants.query_Step_1)+'\'' + BulletinId + '\'';
        }
        step1_targetkey = config.get(flowType + OC_AN_Constants.step_1_DE_Target_CustomerKey);
       		step1_targetName = config.get(flowType + OC_AN_Constants.step_1_DE_Target_Name);
        
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(customerkey_step1, name_step1, sqlQuery_Step1, step2_targetkey, step2_targetName, 'Overwrite');
        return OC_AN_MC_AutomationActivityUtils.createSQLActivity(new List<String>{envelop_Step1});
    }
    
    /**************************************************************************************************
* @Method Name : createAutomationProcess_Id
* @Description : Creates Automation Process
* @Param       : accessToken - accessToken from MC
* @Param       : BulletinId - Id for the SQL activity needs to be created
* @Param       : flowType - Decided whether it is external or internal
* @Param       : NewObjId_Step1 - Target Key
* @Param       : step2_targetName - Target Name
* @Return      : String
****************************************************************************************************/
    public static String createAutomationProcess_Id(String accessToken, String BulletinId, string flowType, String NewObjId_Step1, String targetName /*, String DE_ID, String EmailID*/){
        OC_AN_MC_AutomationActivityUtils.accessToken = accessToken;
        
        string name_step1 = flowType + OC_AN_Constants.step1 + BulletinId;
        
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 1', NewObjId_Step1, NewObjId_Step1, name_step1, name_step1);
        return OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, flowType, envelop_Step1);
    }
    
    /**************************************************************************************************
* @Method Name : createSQLQuery_ED
* @Description : Creates SQL Activity based on the buletinId for external distribution
* @Param       : accessToken - accessToken from MC
* @Param       : BulletinId - Id for the SQL activity needs to be created
* @Param       : flowType - Decided whether it is external or internal
* @Param       : NewObjId_Step1 - Target Key
* @Param       : step2_targetName - Target Name
* @Return      : String
****************************************************************************************************/
    public static String createSQLQuery_ED(String CustomerKey, String accessToken, String BulletinId, string flowType, Map<string, String> config, String step2_targetkey, String step2_targetName, List<OC_AN_Bulletin_Account_Product__c> productRecords){
        OC_AN_MC_AutomationActivityUtils.accessToken = accessToken;
        
        string sqlQuery ;
        string customerkey_step1 = step2_targetkey + OC_AN_Constants.sql;
        string name_step1 = flowType + OC_AN_Constants.step3 + BulletinId;
        if(!productRecords.isEmpty()){
         sqlQuery = config.get(flowType + OC_AN_Constants.SQLActivity_Query);
        }else{
         sqlQuery = config.get(flowType + OC_AN_Constants.SQLActivity_Query_WithoutProduct);
        }
        String sqlQuery_Step1 = sqlQuery.replace('{{BulletinId}}', BulletinId);
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(customerkey_step1, name_step1, sqlQuery_Step1, step2_targetkey, step2_targetName, 'Overwrite');
        
        return OC_AN_MC_AutomationActivityUtils.createSQLActivity(new List<String>{envelop_Step1});
    }
    
        /**************************************************************************************************
* @Method Name : createSQLQuery_EDArchive
* @Description : Creates SQL Activity based on the buletinId for external distribution
* @Param       : accessToken - accessToken from MC
* @Param       : BulletinId - Id for the SQL activity needs to be created
* @Param       : flowType - Decided whether it is external or internal
* @Param       : NewObjId_Step1 - Target Key
* @Param       : step2_targetName - Target Name
* @Return      : String
****************************************************************************************************/
    public static String createSQLQuery_EDArchive(String CustomerKey, String accessToken, String BulletinId, string flowType, Map<string, String> config, String step2_targetkey, String step2_targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken = accessToken;
        
        string sqlQuery ;
        string customerkey_finalStep = config.get(OC_AN_Constants.ED_FINAL_STEP_CustomerKey);
        string name_finalstep = flowType + BulletinId;
     
         sqlQuery = config.get(OC_AN_Constants.ED_FINAL_STEP_QUERY);
        
        String sqlQuery_finalStep = sqlQuery+BulletinId;
        String envelop_finalStep = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(name_finalstep, name_finalstep, sqlQuery_finalStep, customerkey_finalStep, 'ExternalUsers_Archive', 'Append');
        
        return OC_AN_MC_AutomationActivityUtils.createSQLActivity(new List<String>{envelop_finalStep});
    }
    
    /**************************************************************************************************
* @Method Name : createAutomationProcess_ED
* @Description : Creates Automation Process for external distribution
* @Param       : accessToken - accessToken from MC
* @Param       : BulletinId - Id for the SQL activity needs to be created
* @Param       : flowType - Decided whether it is external or internal
* @Param       : NewObjId_Step1 - Target Key
* @Param       : step2_targetName - Target Name
* @Return      : String
****************************************************************************************************/
    public static String createAutomationProcess_ED(String accessToken, String BulletinId, string flowType, Map<string, String> config, String activityObjObjID, String NewObjId_Step1, String targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken = accessToken;
        
        String automationActivityToReturn ;
        
        string name_step1 = flowType + '_step1_' + BulletinId;
        string step1_activityObjID = config.get(flowType + '_Step1_ObjectID');
        string step1_customerkey = config.get(flowType + '_Step1_CustomerKey');
        string step1_name = config.get(flowType + '_Step1_Name');
        
        List<OC_AN_Bulletin_Account_Product__c> recProdcuctRecord =  [SELECT Id FROM OC_AN_Bulletin_Account_Product__c 
                                                                      WHERE OC_AN_Bulletin__c =:BulletinId
                                                                      AND RecordTypeId =: OC_AN_Constants.recTypeId_AccPrdForBulletin_Product];
        string step2_activityObjID;
        string step2_customerkey;
        string step2_name;
        
        string step3_activityObjID;
        string step3_customerkey;
        string step3_name;
        
        if(!recProdcuctRecord.isEmpty()){
            step2_activityObjID = config.get(flowType + '_Step2_ObjectID');
            step2_customerkey = config.get(flowType + '_Step2_CustomerKey');
            step2_name = config.get(flowType + '_Step2_Name');
            
            step3_activityObjID = config.get(flowType + '_Step3_ObjectId_WithProduct');
            step3_customerkey   = config.get(flowType + '_Step3_CustomerKey_WithProduct');
            step3_name          = config.get(flowType + '_Step3_TargetName_WithProduct');
             
        } else{
            step2_activityObjID = config.get(flowType + '_Step2_ObjectID_WithoutProduct');
            step2_customerkey = config.get(flowType + '_Step2_CustomerKey_WithoutProduct');
            step2_name = config.get(flowType + '_Step2_Name_WithoutProduct');
        }
        
        if(!recProdcuctRecord.isEmpty()){
            String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 1', step1_activityObjID, step1_activityObjID, step1_customerkey, step1_name);
            String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 2', step2_activityObjID, step2_activityObjID, step2_customerkey, step2_name);
            String envelop_Step3 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 3', step3_activityObjID, step3_activityObjID, step3_customerkey, step3_name);
            String envelop_Step4 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 4', NewObjId_Step1, activityObjObjID, targetName, targetName);
            automationActivityToReturn =  OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, flowType, envelop_Step1 + envelop_Step2 + envelop_Step3 + envelop_Step4);
        }else{
            String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 1', step1_activityObjID, step1_activityObjID, step1_customerkey, step1_name);
            String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 2', step2_activityObjID, step2_activityObjID, step2_customerkey, step2_name);
            String envelop_Step3 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 3', NewObjId_Step1, activityObjObjID, targetName, targetName);
            automationActivityToReturn =  OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, flowType, envelop_Step1 + envelop_Step2 + envelop_Step3);
        }
        
        return automationActivityToReturn;
    }
    
    /**************************************************************************************************
* @Method Name : createAutomationProcess_ED
* @Description : Creates Automation Process for external distribution
* @Param       : accessToken - accessToken from MC
* @Param       : BulletinId - Id for the SQL activity needs to be created
* @Param       : flowType - Decided whether it is external or internal
* @Param       : NewObjId_Step1 - Target Key
* @Param       : step2_targetName - Target Name
* @Return      : String
****************************************************************************************************/
    public static String createAutomationProcess_EDFinal(String accessToken, String BulletinId, string flowType, Map<string, String> config, String activityObjObjID, String NewObjId_Step1, String targetName,String ObjectId_FinalStep){
        OC_AN_MC_AutomationActivityUtils.accessToken = accessToken;
        system.debug('ObjectId_FinalStep inside automation helper====>'+ObjectId_FinalStep);
        String automationActivityToReturn ;
        
        string name_step1 = flowType + '_step1_' + BulletinId;
        string step1_activityObjID = config.get(flowType + '_Step1_ObjectID');
        string step1_customerkey = config.get(flowType + '_Step1_CustomerKey');
        string step1_name = config.get(flowType + '_Step1_Name');
        
        List<OC_AN_Bulletin_Account_Product__c> recProdcuctRecord =  [SELECT Id FROM OC_AN_Bulletin_Account_Product__c 
                                                                      WHERE OC_AN_Bulletin__c =:BulletinId
                                                                      AND RecordTypeId =: OC_AN_Constants.recTypeId_AccPrdForBulletin_Product];
        string step2_activityObjID;
        string step2_customerkey;
        string step2_name;
        
        string step3_activityObjID;
        string step3_customerkey;
        string step3_name;
        
        if(!recProdcuctRecord.isEmpty()){
            step2_activityObjID = config.get(flowType + '_Step2_ObjectID');
            step2_customerkey = config.get(flowType + '_Step2_CustomerKey');
            step2_name = config.get(flowType + '_Step2_Name');
            
            step3_activityObjID = config.get(flowType + '_Step3_ObjectId_WithProduct');
            step3_customerkey   = config.get(flowType + '_Step3_CustomerKey_WithProduct');
            step3_name          = config.get(flowType + '_Step3_TargetName_WithProduct');
             
        } else{
            step2_activityObjID = config.get(flowType + '_Step2_ObjectID_WithoutProduct');
            step2_customerkey = config.get(flowType + '_Step2_CustomerKey_WithoutProduct');
            step2_name = config.get(flowType + '_Step2_Name_WithoutProduct');
        }
        
        if(!recProdcuctRecord.isEmpty()){
            String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 1', step1_activityObjID, step1_activityObjID, step1_customerkey, step1_name);
            String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 2', step2_activityObjID, step2_activityObjID, step2_customerkey, step2_name);
            String envelop_Step3 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 3', step3_activityObjID, step3_activityObjID, step3_customerkey, step3_name);
            String envelop_Step4 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 4', NewObjId_Step1, activityObjObjID, targetName, targetName);
            String envelop_Step5 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 5', NewObjId_Step1, ObjectId_FinalStep, targetName, targetName);
            automationActivityToReturn =  OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, flowType, envelop_Step1 + envelop_Step2 + envelop_Step3 + envelop_Step4 + envelop_Step5);
        }else{
            String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 1', step1_activityObjID, step1_activityObjID, step1_customerkey, step1_name);
            String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 2', step2_activityObjID, step2_activityObjID, step2_customerkey, step2_name);
            String envelop_Step3 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 3', NewObjId_Step1, activityObjObjID, targetName, targetName);
            String envelop_Step4 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('Step 4', 'targetName', ObjectId_FinalStep, 'targetName', 'targetName');
            automationActivityToReturn =  OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, flowType, envelop_Step1 + envelop_Step2 + envelop_Step3 + envelop_Step4);
        }
        
        return automationActivityToReturn;
    }
    
}