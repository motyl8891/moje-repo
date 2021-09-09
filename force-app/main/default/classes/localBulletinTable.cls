public with sharing class localBulletinTable {
    @AuraEnabled
    public static List<OC_AN_Bulletin_Account_Product__c> getData(){
        return [Select Id,
                OC_AN_Status__c,
                OC_AN_Sub_Status__c
                from OC_AN_Bulletin_Account_Product__c 
                where  OC_AN_Bulletin__c='a0g1l000002rGIQAA2'];
    }
}