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
public class OC_AN_MC_ID_Journey_UtilTest {
    static testMethod void testInternalCreation() {
        Map<String, String> sfmc_Config = new Map<String, String>();
        sfmc_Config.put('DeliveryProfile_Id','ee074fed-3564-eb11-b82f-f40343c954f0');
        String result = OC_AN_MC_ID_Journey_Util.getInternalJourneyRestBody('a0g1l000002dLKBAA2', 'TestABC', 2231, '044de2ca-a2ad-eb11-b836-f40343c98e90', sfmc_Config,'ED');
        System.debug('Resulting JSON: '+result);
        System.assertNotEquals(null, result, 'The resulting JSON data should not be null'+result);
    }

    
    static testMethod void testExternalCreation() {
        Map<String, String> sfmc_Config = new Map<String, String>();
        sfmc_Config.put('DeliveryProfile_Id','ee074fed-3564-eb11-b82f-f40343c954f0');
        String result = OC_AN_MC_ID_Journey_Util.getExternalJourneyRestBody('a0g1l000002dLKBAA2', 'TestABC', 2231, '044de2ca-a2ad-eb11-b836-f40343c98e90', sfmc_Config,'ED');
        System.debug('Resulting JSON: '+result);
        System.assertNotEquals(null, result, 'The resulting JSON data should not be null'+result);
    }

}