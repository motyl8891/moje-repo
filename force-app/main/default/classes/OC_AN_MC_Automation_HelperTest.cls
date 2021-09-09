/**
 * @File Name          : OC_AN_MC_Automation_HelperTest
 * @Description        : Test class for OC_AN_MC_Automation_Helper.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/

@IsTest
public  class OC_AN_MC_Automation_HelperTest {
    
    public TestMethod static void createSQLQuery_ID_Test(){
        Map<String,String> config = new Map<String,String>();
        List<OC_AN_Bulletin_Account_Product__c> productRecords=new List<OC_AN_Bulletin_Account_Product__c>();
        String flowType = 'flowType';
        config.put(flowType + '_Query_Step_1', 'std');
		config.put(flowType + '_Step_1_DE_Target_CustomerKey', 'sdf');
		config.put(flowType + '_Step_1_DE_Target_Name', 'sdf');
        String result = OC_AN_MC_Automation_Helper.createSQLQuery_ID('accessToken', (Id)'a0g1l000002qkRVAAY', flowType, config, 'step2_targetkey', 'step2_targetName',productRecords);
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    public TestMethod static void createAutomationProcess_Id_Test(){
        Map<String,String> config = new Map<String,String>();
        String flowType = 'flowType';
        config.put(flowType + '_Query_Step_1', 'std');
        config.put(flowType + '_Step_1_DE_Target_CustomerKey', 'sdf');
        config.put(flowType + '_Step_1_DE_Target_Name', 'sdf');
        String result = OC_AN_MC_Automation_Helper.createAutomationProcess_Id('accessToken', (Id)'a0g1l000002qkRVAAY', flowType, 'NewObjId_Step1', 'targetName');
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    public TestMethod static void createSQLQuery_ED_Test(){
        Map<String,String> config = new Map<String,String>();
        List<OC_AN_Bulletin_Account_Product__c> productRecords=new List<OC_AN_Bulletin_Account_Product__c>();
        String flowType = 'flowType';
        config.put(flowType + '_SQLActivity_Query_WithoutProduct', 'std');
        String result = OC_AN_MC_Automation_Helper.createSQLQuery_ED('CustomerKey', 'accessToken', (Id)'a0g1l000002qkRVAAY', flowType, config, 'step2_targetkey', 'step2_targetName',productRecords);
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    public TestMethod static void createAutomationProcess_ED_Test(){
        Map<String,String> config = new Map<String,String>();
        String flowType = 'flowType';
        config.put(flowType + '_Step1_ObjectID', 'std');
        config.put(flowType + '_Step1_CustomerKey', 'sdf');
        config.put(flowType + '_Step2_ObjectID', 'sdf');
        config.put(flowType + '_Step2_CustomerKey', 'std');
        config.put(flowType + '_Step1_Name', 'sdf');
        config.put(flowType + '_Step2_Name', 'sdf');
        String result = OC_AN_MC_Automation_Helper.createAutomationProcess_ED('accessToken', (Id)'a0g1l000002qkRVAAY', flowType, config, 'activityObjObjID', 'NewObjId_Step1', 'targetName');
        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    public TestMethod static void createSQLQuery_Test(){
        Map<String,String> config = new Map<String,String>();
        List<OC_AN_Bulletin_Account_Product__c> productRecords=new List<OC_AN_Bulletin_Account_Product__c>();
        String flowType = 'flowType';
        config.put(flowType + '_Query_Step_1', 'std');
        config.put(flowType + '_Step_1_DE_Target_CustomerKey', 'sdf');
        config.put(flowType + '_Step_1_DE_Target_Name', 'sdf');
        config.put(flowType + '_Query_Step_2', 'std');
       /* String result = OC_AN_MC_Automation_Helper.createSQLQuery('accessToken', (Id)'a0g1l000002qkRVAAY', flowType, config, 'step2_targetkey', 'step2_targetName',productRecords);
        System.assertNotEquals(null, result, 'Result should not be null');*/
    }

    public TestMethod static void createAutomationProcess_Test(){
        Map<String,String> config = new Map<String,String>();
        String flowType = 'flowType';
        /*String result = OC_AN_MC_Automation_Helper.createAutomationProcess('accessToken', (Id)'a0g1l000002qkRVAAY', flowType, 'NewObjId_Step1', 'NewObjId_Step2');
        System.assertNotEquals(null, result, 'Result should not be null');*/
    }


}