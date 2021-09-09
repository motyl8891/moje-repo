/**
 * @File Name          : OC_AN_MC_AutomationActivityUtilsTest
 * @Description        : Test class for OC_AN_MC_AutomationActivityUtils.
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
public class OC_AN_MC_AutomationActivityUtilsTest {
    

    public static TestMethod void getSoapQueryBodyEnvelopeTEST(){
        String returnEnv = OC_AN_MC_AutomationActivityUtils.getSoapQueryBodyEnvelope('CustomerKey', 'sqlActivityName', 'sqlQueryText', 'dataExtTargetCustKey', 'dataExtTargetName', 'TargetUpdateType');
        System.assertNotEquals(null, returnEnv, 'No envelope was generated');
    }

    public static TestMethod void getSoapAutomationTaskBodyEnvelopeTEST(){
        String returnEnv = OC_AN_MC_AutomationActivityUtils.getSoapAutomationTaskBodyEnvelope('automationTaskName', 'activityObjID', 'activityObjObjID', 'customerKey','activityObjName');
        System.assertNotEquals(null, returnEnv, 'No envelope was generated');
    }

    public static TestMethod void getSoapHeaderTEST(){
        OC_AN_MC_AutomationActivityUtils.accessToken = 'accessToken';
        String returnEnv = OC_AN_MC_AutomationActivityUtils.getSoapHeader('PREFORME');
        System.assertNotEquals(null, returnEnv, 'No envelope was generated');
    }

    public static TestMethod void createSQLActivityTEST(){
        List<String> arguments = new List<String>();
        arguments.add('Query1');
        arguments.add('Query2');
        String returnEnv = OC_AN_MC_AutomationActivityUtils.createSQLActivity(arguments);
        System.assertNotEquals(null, returnEnv, 'No envelope was generated');
    }


    public static TestMethod void createAutomationActivityTEST(){
        OC_AN_MC_AutomationActivityUtils.accessToken = 'accessToken';
        String returnEnv = OC_AN_MC_AutomationActivityUtils.createAutomationActivity('BulletinId', 'flowType', 'activityList');
        System.assertNotEquals(null, returnEnv, 'No envelope was generated');
    }
 
    public static TestMethod void startAutomationTEST(){
        OC_AN_MC_AutomationActivityUtils.accessToken = 'accessToken';
        String returnEnv = OC_AN_MC_AutomationActivityUtils.startAutomation('objectId', 'accessTokenAsParameter');
        System.assertNotEquals(null, returnEnv, 'No envelope was generated');
    }
}