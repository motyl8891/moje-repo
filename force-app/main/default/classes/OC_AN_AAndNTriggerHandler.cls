/**
* @File Name          : OC_AN_AAndNTriggerHandler 
* @Description        : This will be used to handle all the trigger events for 
	                    OC_AN_Bulletin_Account_Product__C object.

* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10                 IBM               Initial Version
**/

public with sharing class OC_AN_AAndNTriggerHandler implements TriggerInterface {

    public void BeforeInsert(List<SObject> newItems){}
   
   /**************************************************************************************************
   * @Description : This method will handle the before delete for OC_AN_Bulletin_Account_Product__C.
   * @Param       : newItems - List of new OC_AN_Bulletin_Account_Product__C records.
   ****************************************************************************************************/    
    public void BeforeDelete(Map<Id,Sobject> oldMap){
        for(OC_AN_Bulletin_Account_Product__c apb : [SELECT Id,OC_AN_Bulletin__r.OC_AN_Current_Status__c, OC_AN_Bulletin__r.OC_AN_Technical_Reviewer__c, OC_AN_Bulletin__r.OC_AN_Editorial_Review__c FROM OC_AN_Bulletin_Account_Product__c
                                                                    WHERE Id IN: oldMap.keySet()]){
            
            if(apb.OC_AN_Bulletin__r.OC_AN_Current_Status__c != OC_AN_Constants.DRAFT && 
               ((apb.OC_AN_Bulletin__r.OC_AN_Current_Status__c != OC_AN_Constants.INTECHNICALREVIEW && apb.OC_AN_Bulletin__r.OC_AN_Technical_Reviewer__c != UserInfo.getUserId()) 
                || (apb.OC_AN_Bulletin__r.OC_AN_Current_Status__c != OC_AN_Constants.INEDITORIALREVIEW && apb.OC_AN_Bulletin__r.OC_AN_Editorial_Review__c != UserInfo.getUserId())))
            {
                OC_AN_Bulletin_Account_Product__c actualRecord = (OC_AN_Bulletin_Account_Product__c) oldMap.get(apb.Id);
                    actualRecord.addError(Label.OC_AN_RestrictTheDeletionOfRelatedRecordsForBulletin);
            }             
		}            
  	}
    
    
    /**************************************************************************************************
   * @Description : This method will handle the before delete for OC_AN_Bulletin_Account_Product__C.
   * @Param       : oldItems - Map of old OC_AN_Bulletin_Account_Product__C records.
   ****************************************************************************************************/  
    
    public void AfterDelete(Map<Id, SObject> oldItems){
        
        Set<Id> bulletinId = new Set<Id>(); 
        
        Map<Id,OC_AN_Bulletin__c> bulletinIdToRecord = new Map<Id,OC_AN_Bulletin__c>();
        
        List<OC_AN_Bulletin_Account_Product__c> itemsToIterate = oldItems.values();
        
        for(OC_AN_Bulletin_Account_Product__c oc : itemsToIterate ){
            bulletinId.add(oc.OC_AN_Bulletin__c);            
        }
        
        for(OC_AN_Bulletin__c oc :  OC_AN_Utility.getBulletinRelatedRecord(OC_AN_Constants.recTypeId_Account,bulletinId) ){
                                         if(oc.Bulletin_Account_Products__r.isEmpty()){
                                             OC_AN_Bulletin__c bullrec = new OC_AN_Bulletin__c(id = oc.id);
                                             bullrec.OC_AN_IsExternal__c = false;
                                             bulletinIdToRecord.put(oc.Id,bullrec); 
                                         } 
                                     }
        for(OC_AN_Bulletin__c oc :  OC_AN_Utility.getBulletinRelatedRecord(OC_AN_Constants.recTypeId_PublicGroup,bulletinId) ){ 
                                         if(oc.Bulletin_Account_Products__r.isEmpty()){
                                             OC_AN_Bulletin__c bullrec = new OC_AN_Bulletin__c(id = oc.id);
                                             bullrec.OC_AN_IsInternal__c = false;
                                             bulletinIdToRecord.put(oc.Id,bullrec); 
                                         } 
                                     }
        if(!bulletinIdToRecord.isEmpty()){
            update bulletinIdToRecord.values();
        }

    }
    
    
   public void AfterUnDelete(Map<Id, SObject> oldItems){}
   public void AfterInsert(Map<Id, SObject> newItems){}
   public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
       
       
       Set<Id> accountId = new Set<Id>();
       
       Map<Id,OC_AN_Bulletin_Account_Product__c> oldBulltinAttributesMap = new Map<Id,OC_AN_Bulletin_Account_Product__c>();
       Map<Id,List<AccountTeamMember>> accountIdToTeamMemberId = new Map<Id,List<AccountTeamMember>>();

       for(OC_AN_Bulletin_Account_Product__c oc : (List<OC_AN_Bulletin_Account_Product__c>) oldItems.values()){
           oldBulltinAttributesMap.put(oc.Id,oc);
       }
       
       List<OC_AN_Bulletin_Account_Product__c> itemsToIterate = newItems.values();
       
       for(OC_AN_Bulletin_Account_Product__c oc :itemsToIterate){
           
           if(oldBulltinAttributesMap.get(oc.Id).OC_AN_Status__C != 'Hold' && oc.OC_AN_Sub_Status__c == 'Message Applicable, but I want to modify' 
              && oc.RecordTypeId == OC_AN_Constants.recTypeId_Account){
                  accountId.add(oc.OC_AN_Account__c);
              }
           
       }
       
      /* for(AccountTeamMember accountTeamMemberList : [SELECT AccountId,UserId,TeamMemberRole FROM 
                                                       AccountTeamMember WHERE AccountId IN :accountId 
                                                      AND TeamMemberRole = 'Local Publisher']){
                                                          
                                                         accountIdToTeamMemberId.put(accountTeamMemberList.AccountId,accountTeamMemberList); 
                                                      }
       
       
       for(OC_AN_Bulletin_Account_Product__c oc :itemsToIterate){
           accountIdToTeamMemberId.get(oc.OC_AN_Account__c)
         if(!listcontains)
              
       } */
       
       
       
       
       
   }

    /**************************************************************************************************
   * @Description : This method will handle the after update for OC_AN_Bulletin_Account_Product__C.
   * @Param       : oldItems - Map of old OC_AN_Bulletin_Account_Product__C records, newItems -Map of new OC_AN_Bulletin_Account_Product__C records 
   ****************************************************************************************************/ 
   public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        try {
            List<Id> AlertsIdsList = new List<Id>();
            List<OC_AN_Bulletin_Account_Product__c> itemsToIterate = newItems.values();
            for(OC_AN_Bulletin_Account_Product__c AlertRecord : itemsToIterate) {
                if(
                    AlertRecord.OC_AN_Status__c == 'Send'
                    && AlertRecord.OC_AN_isExternallyDistributed__c == false
                    && !String.IsBlank(AlertRecord.OC_AN_Bulletin__c)
                ) {
                    AlertsIdsList.add(AlertRecord.Id);
                }
            }
            if(AlertsIdsList != null || !AlertsIdsList.isEmpty()) {
                OC_AN_ExtAutomationExecScheduler scheduler = new OC_AN_ExtAutomationExecScheduler(AlertsIdsList);
            } 
        } catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(OC_AN_Constants.OC_AN_AAndNTriggerHandler, OC_AN_Constants.AfterUpdate,OC_AN_Constants.OC_AN_AAndNTriggerHandler, true, e)));
        }
   }
    
    
}