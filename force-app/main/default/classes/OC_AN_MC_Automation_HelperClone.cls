public class OC_AN_MC_Automation_HelperClone {
public static String createSQLQuery_ID(String accessToken, id BulletinId, string flowType, Map<string, String>config, String step2_targetkey, String step2_targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        
        
        string customerkey_step1 = flowType+'_step1_'+BulletinId;
        string name_step1= flowType+'_step1_'+BulletinId;
        string sqlQuery_Step1 =config.get(flowType+'_Query_Step_1')+'\''+ BulletinId + '\'';
        string step1_targetkey = config.get(flowType+'_Step_1_DE_Target_CustomerKey');
        string step1_targetName = config.get(flowType+'_Step_1_DE_Target_Name');
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(
            customerkey_step1, 
            name_step1,
            sqlQuery_Step1,
            step2_targetkey,
            step2_targetName,
            'Overwrite'
        );
        return OC_AN_MC_AutomationActivityUtils.createSQLActivity(new List<String>{envelop_Step1});                
    }

    public static String createAutomationProcess_Id(String accessToken, String BulletinId, string flowType, String NewObjId_Step1,String targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        
        string name_step1= flowType+'_step1_'+BulletinId;
        
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope(
            'Step 1',
            NewObjId_Step1,
            NewObjId_Step1,
            name_step1,
            name_step1
        );
        return OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, 
                                                                            flowType, 
                                                                            envelop_Step1);
        


    } 

    public static String createSQLQuery_ED(String CustomerKey, String accessToken, String BulletinId, string flowType, String config, String step2_targetkey, String step2_targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        
        
        //string customerkey_step1 = flowType+'_step1_'+BulletinId;
        string customerkey_step1 = step2_targetkey+'_sql';
        string name_step1= flowType+'_step3_'+BulletinId;
        //string sqlQuery_Step1 =config.get(flowType+'_Query_Step_1')+'\''+ BulletinId + '\'';
        //string step1_targetName = config.get(flowType+'_Step_1_DE_Target_Name');
        //string step1_targetKey = config.get(flowType+'_SQLActivity_TargetKey');
        //string sqlQuery_Step1 = config.get(flowType+'_SQLActivity_Query');
        string sqlQuery_Step1 ='Select Id as ContactId, Name,Email from Contact_Salesforce';
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(
            customerkey_step1, 
            name_step1,
            sqlQuery_Step1,
            step2_targetkey,
            step2_targetName,
            'Overwrite'
        );
       
        return OC_AN_MC_AutomationActivityUtils.createSQLActivity(new List<String>{envelop_Step1});                
    }

    public static String createAutomationProcess_ED( String accessToken, String BulletinId, string flowType, Map<string, String>config, String activityObjObjID,String NewObjId_Step1,String targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        
        string name_step1= flowType+'_step1_'+BulletinId;
        string step1_activityObjID = config.get(flowType+'_Step1_ObjectID');
        string step1_customerkey = config.get(flowType+'_Step1_CustomerKey');
        string step2_activityObjID = config.get(flowType+'_Step2_ObjectID');
        string step2_customerkey = config.get(flowType+'_Step2_CustomerKey');
        //String targetName = 'ExternalUser_' +BulletinId; 
       
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope(
            'Step 1',
            '9ec902f9-9b0f-4d88-ba8a-6a5fef503bb9',
            '9ec902f9-9b0f-4d88-ba8a-6a5fef503bb9',
            '9d1ab839-4d2a-41e5-adc7-d57298fc0338',
            'ED_Contact_Bulletin'
        );
        String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope(
            'Step 2',
            '812771e0-ba88-4645-941c-8587c30039e1',
            '812771e0-ba88-4645-941c-8587c30039e1',
            'f6b56984-f90e-4c5b-873f-61daf227f43b',
            'ED_Contact_Preferences'
        );
         String envelop_Step3 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope(
            'Step 3',
            NewObjId_Step1,
            activityObjObjID,
            targetName,
            targetName
        );
        return OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, 
                                                                            flowType, 
                                                                            envelop_Step1+envelop_Step2+envelop_Step3);
        


    } 


    public static String createSQLQuery(String accessToken, id BulletinId, string flowType, Map<string, String>config, String step2_targetkey, String step2_targetName){
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        
        
        string customerkey_step1 = flowType+'_step1_'+BulletinId;
        string name_step1= flowType+'_step1_'+BulletinId;
        string sqlQuery_Step1 =config.get(flowType+'_Query_Step_1')+'\''+ BulletinId + '\'';
        string step1_targetkey = config.get(flowType+'_Step_1_DE_Target_CustomerKey');
        string step1_targetName = config.get(flowType+'_Step_1_DE_Target_Name');
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(
            customerkey_step1, 
            name_step1,
            sqlQuery_Step1,
            step1_targetkey,
            step1_targetName,
            'Update'
        );
        
        
        
        string customerkey_step2 = flowType+'_step2_'+BulletinId;
        string name_step2= flowType+'_step2_'+BulletinId;
        string sqlQuery_Step2 =config.get(flowType+'_Query_Step_2')+'\''+ BulletinId + '\'';
        
        
        String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope(
            customerkey_step2, 
            name_step2,
            sqlQuery_Step2,
            step2_targetkey,
            step2_targetName,
            'Overwrite'
        );
        System.debug(envelop_Step1+envelop_Step2);
        return OC_AN_MC_AutomationActivityUtils.createSQLActivity(new List<String>{envelop_Step1,envelop_Step2});                
    }


    
    
    public static String createAutomationProcess(String accessToken, String BulletinId, string flowType, String NewObjId_Step1,String NewObjId_Step2){
        OC_AN_MC_AutomationActivityUtils.accessToken=accessToken;
        
        string name_step1= flowType+'_step1_'+BulletinId;
        
        String envelop_Step1 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope(
            'Step 1',
            NewObjId_Step1,
            NewObjId_Step1,
            name_step1,
            name_step1
        );
        
        
        
        
        string name_step2= flowType+'_step2_'+BulletinId;
        
        String envelop_Step2 = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope(
            'Step 2',
            NewObjId_Step2,
            NewObjId_Step2,
            name_step2,
            name_step2
        );
        
        
        return OC_AN_MC_AutomationActivityUtils.createAutomationActivity(BulletinId, 
                                                                         flowType, 
                                                                         envelop_Step1+envelop_Step2);
        
    }
}