/**
 * @File Name          : OC_AN_MC_ID_Journey_UtilTest
 * @Description        : Test class for OC_AN_MC_ID_Journey_Util.
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
public class OC_AN_MC_Internal_Dist_JsonTest {
     
    public static final String JSON_TO_PARSE_REQUEST = '[{"keys":{"emailWithBulletinId":"abc.xyz@ericsson.coma0g1l000002qcDAAAY"},"values":{"user_Id":"0051l1114JhpSAAS","name":"ABC","last_Name":"XYZ","first_Name":"ABC","email":"abc.xyz@ericsson.com","bulletin_Id":"a0g1l000002qcDEAAY"}}]';

    static testMethod void testParsing() {
      	OC_AN_MC_Internal_Dist_Json.parse(JSON_TO_PARSE_REQUEST);
        System.assertNotEquals(null, 'Unable to parse the JSON');
    }
}