/**
* @File Name          : OC_AN_HandleCalloutWhenBulletinApproved
* @Description        : Below class OC_AN_HandleCalloutWhenBulletinApproved is called from Process Builder 'BulletinProcessMain'
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : U-2763, U-2782
* @Created Date       : 07th May 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-07                 IBM                   Initial Version
**/
public class TestDemo2{
    @future(callout=true)
    public static void say(){
//        OC_AN_HandleCalloutWhenBulletinApproved.mcRGestCallouts( new List<Id>{'a0g1l000002qOxUAAU'});
        
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/soap+xml; charset=utf-8');		      
        String requestBody = OC_AN_MC_AutomationActivityUtils.startAutomation(
            '2cca7db0-2c7d-4876-99e9-df4a1bee95db',
            'eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJYRWVKNXdvT2xXOFhrY09DRjloUkJrUkYiLCJjbGllbnRfaWQiOiJqYnVpYTN4OXBoeWk3eWdrbzJ5ZGZjdDMiLCJlaWQiOjUxMDAwMzQ1OSwic3RhY2tfa2V5IjoiUzUwIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciJ9.d7BNv32MITtVGB1jFonPuhn2wT831r-6at-KjBntaqY.k_knTpg8P1cUTdz3x4VvICICBdgXPdP4jHdsEsZZHE_eN_kHB9KWgWR-FhNDti5qKAC1Wk2BB1YlL8Igzy2RuzCNGJCLaBhPbIRzmSa_tNVJAunFpMICXTCj4dgQdrE27Fvjtp2e3sDoZu7JDW4vZXrt18xEzBZuirtf6IZAP_bSPazK3P4');
        System.debug('Request body to start Automation: '+requestBody);
        HttpResponse response = OC_IB_IntegrationBaseClass.RequestGenerationcallout(requestBody, 
                                                                                    headerMap,
                                                                                    'https://mcs82tyyyzfmk1mrbbjnd1m9f5l4.soap.marketingcloudapis.com/Service.asmx', 
                                                                                    'POST');
    }
}