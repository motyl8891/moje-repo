/**
 * @File Name          : MC_AN_EventDefinitionVoTest
 * @Description        : Test class for MC_AN_EventDefinitionVo.
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
public class MC_AN_EventDefinitionVoTest {
    
    @IsTest
    public static void MC_AN_EventDefinitionVo_Test() {
        Map<String,String> arguments = new Map<String,String>();
        arguments.put(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID, 'arg1');
        arguments.put(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_DATA_EXTENSION_ID, 'arg2');
        arguments.put(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_AUTOMATION_ID, 'arg3');
        String returnedJson = MC_AN_EventDefinitionVo.populate(arguments, 'internalEventDefination');
        System.assertNotEquals(null, returnedJson, 'No json was returned');
    }
}