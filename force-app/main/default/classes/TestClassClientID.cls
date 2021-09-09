public class TestClassClientID {

      public static String getClientIdAndSecret(String developerName){
        
        String clientIdAndSecret ;
        
        OC_AN_AlertsAndNotification__MDT grantType = [SELECT 
                                             ID,Values__c
                                             FROM OC_AN_AlertsAndNotification__MDT
                                             WHERE DeveloperName =: developerName
                                             LIMIT 1];
        clientIdAndSecret = grantType.Values__c;
        system.debug('clientIdAndSecret====>'+clientIdAndSecret);
        return clientIdAndSecret;
    }
    
    
}