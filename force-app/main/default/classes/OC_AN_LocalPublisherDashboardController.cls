public class OC_AN_LocalPublisherDashboardController {
    @AuraEnabled(cacheable=true)
    public static List<OC_AN_Bulletin_Account_Product__c> getBulletinsToDisplay() {
        List<OC_AN_Bulletin_Account_Product__c> bulletinDisplayList = new List<OC_AN_Bulletin_Account_Product__c>();
        Set<Id> accountIdList = new Set<Id>();
        for(OC_AN_Group_Member__c groupMemberRecord : [
        SELECT
          Id,
          OC_AN_Account__c
        FROM OC_AN_Group_Member__c
        WHERE
          OC_AN_Local_Publisher__c = TRUE
          AND RecordTypeId = :OC_AN_Constants.recordTypeId_LocalPublisher
          AND OC_AN_User__c = :UserInfo.getUserId()
          AND OC_AN_Account__r.Account_Type__c = :OC_AN_Constants.service
          AND OC_AN_Account__r.RecordTypeId = :OC_AN_Constants.recTypeId_forServiceAccount
        ]) {
            accountIdList.add(groupMemberRecord.OC_AN_Account__c);
        }
        system.debug('accountIdList'+accountIdList);
        for(OC_AN_Bulletin_Account_Product__c bapRecord : [
        SELECT Id, OC_AN_Bulletin__c, OC_AN_Bulletin__r.Name, OC_AN_Account__c, OC_AN_Account__r.Name,
            OC_AN_Status__c
        FROM OC_AN_Bulletin_Account_Product__c
        WHERE
          OC_AN_Account__c IN :accountIdList
          AND OC_AN_Bulletin__c != null
          AND OC_AN_Bulletin__r.RecordTypeId != :OC_AN_Constants.OC_AN_RecordTypeId_Local_Bulletin
          AND (OC_AN_Bulletin__r.OC_AN_Current_Status__c = 'Internally Published'
          OR OC_AN_Bulletin__r.OC_AN_Current_Status__c = 'Externally Published')
          AND OC_AN_Status__c = ''
      ]){
            bulletinDisplayList.add(bapRecord);
        }
        system.debug('bulletinDisplayList--> '+bulletinDisplayList);
        return bulletinDisplayList;
    }
    
    
   // public List<ColumnWrapper> getFieldsToDisplay() {}
    public class ColumnWrapper{
        
        
    }
}