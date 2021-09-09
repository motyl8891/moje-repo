/**
* @File Name          : OC_AN_BulletinTriggerHandler
* @Description        : This will be used to handle all the trigger events for 
OC_AN_Bulletin object. 
*			
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 03rd May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-03              	IBM               Initial Version
**/

public with sharing class OC_AN_BulletinTriggerHandler implements TriggerInterface {
    
    
    /**************************************************************************************************
* @Description : This method will handle the before insert for OC_AN_Bulletin.
* @Param       : newItems - List of new OC_AN_Bulletin records.
****************************************************************************************************/  
    
    public void BeforeInsert(List<OC_AN_Bulletin__c> newItems){
        
        Id bulletinRecordTypeId = Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Bulletin').getRecordTypeId();
        
        
        Integer BulletinCOuntCreatedToday =[Select id,name,OC_AN_Issue__c,
                                            OC_AN_Bulletin_Template__c from
                                            OC_AN_Bulletin__c where
                                            createdDate = Today
                                            AND RecordTypeId =: bulletinRecordTypeId].Size();
        
        for(OC_AN_Bulletin__c Bulletin : newItems)
        {
            if(Bulletin.RecordTypeId == bulletinRecordTypeId ){
                BulletinCOuntCreatedToday = BulletinCOuntCreatedToday + 1;
                Bulletin.OC_AN_Issue__c= String.valueof(Date.today())+'.'+BulletinCOuntCreatedToday;
            }
        }
        
        
        
    }
    public void BeforeDelete(Map<Id,Sobject> oldMap){}
    public void AfterDelete(Map<Id, SObject> oldItems){}
    public void AfterUnDelete(Map<Id, SObject> oldItems){}
    public void AfterInsert(Map<Id, SObject> newItems){
        
        Id LocalBulletinRecordTypeId = Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Local_Bulletin').getRecordTypeId();
    Id revisionBulletinRecordTypeId = Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName()
      .get('OC_AN_Revision')
      .getRecordTypeId();
        set<Id> ParentsBulletinId = new  set<Id>();
    set<Id> parentBulletinIdForRevisionBulletinRecordType = new Set<Id>();
        list<OC_AN_Bulletin__c > childBulletinList = new  list<OC_AN_Bulletin__c >();
        List<OC_AN_Bulletin__c> itemsToIterate = newItems.values();
        for(OC_AN_Bulletin__c Bulletin : itemsToIterate)
        {
            if(Bulletin.RecordTypeId==LocalBulletinRecordTypeId ){
                ParentsBulletinId.add(Bulletin.OC_AN_Parent_Bulletin__c);
            } else if (Bulletin.RecordTypeId==revisionBulletinRecordTypeId){
                parentBulletinIdForRevisionBulletinRecordType.add(Bulletin.OC_AN_Parent_Bulletin__c);
            }
        }
        for(OC_AN_Bulletin__c Bulletin :[Select id,OC_AN_Issue__c,(Select id,OC_AN_Issue__c from Bulletins__r
                                                                   where createdDate = Today AND RecordTypeId=:LocalBulletinRecordTypeId )
                                         from OC_AN_Bulletin__c where id IN: ParentsBulletinId]){
                                             Integer localVersionCount = Bulletin.Bulletins__r.Size();
                                             for(OC_AN_Bulletin__c CBulletin :Bulletin.Bulletins__r){
                                                 if(CBulletin.OC_AN_Issue__c == null){
                                                     CBulletin.OC_AN_Issue__c= Bulletin.OC_AN_Issue__c +'-L'+localVersionCount;
                                                     childBulletinList.add(CBulletin);
                                                 }
                                             }
                                             update childBulletinList;
                                         }
        

    for (OC_AN_Bulletin__c bulletinRecord : [
      SELECT
        Id,
        OC_AN_Issue__c,
        (
          SELECT Id, OC_AN_Issue__c
          FROM Bulletins__r
          WHERE RecordTypeId = :revisionBulletinRecordTypeId
        )
      FROM OC_AN_Bulletin__c
      WHERE id IN :parentBulletinIdForRevisionBulletinRecordType
    ]) {
      Integer revisionVersionCount = bulletinRecord.Bulletins__r.Size();
      for (OC_AN_Bulletin__c revisionBulletin : bulletinRecord.Bulletins__r) {
        if (String.isBlank(revisionBulletin.OC_AN_Issue__c)) {
          revisionBulletin.OC_AN_Issue__c = bulletinRecord.OC_AN_Issue__c + '-R' + revisionVersionCount;
          childBulletinList.add(revisionBulletin);
        }
      }
    }
    update childBulletinList;
        
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        
    }
    
}