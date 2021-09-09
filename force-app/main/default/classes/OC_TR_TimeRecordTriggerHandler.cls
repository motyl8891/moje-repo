/* Class Name : OC_TR_TimeRecordTriggerHandler
* Description : This class handles all the trigger events for OC_TR_TimeRecord__c object. 
*/

public Without Sharing class OC_TR_TimeRecordTriggerHandler implements OC_TR_TriggerInterface{
/**************************************************************************************
* @Description  This method validates the timespent of an agent and populates
				the search and description field values on OC_TR_TimeRecord__c  
				object before inserting the record into Database.
* @Param		List - OC_TR_TimeRecord__c List. 
**************************************************************************************/ 
    public void BeforeInsert(List<SObject> newItems) 
    {
        //system.debug('>>> Method Entry : BeforeInsert <<< ');
        List<OC_TR_TimeRecord__c> timeRecordnewList = (List<OC_TR_TimeRecord__c>)newItems;
        List<OC_TR_TimeRecord__c> validateTimeRecordsList = new  List<OC_TR_TimeRecord__c> ();
        List<OC_TR_TimeRecord__c> setCompanyCodeTimeRecList = new  List<OC_TR_TimeRecord__c> ();
        
        for(OC_TR_TimeRecord__c timeRec : timeRecordnewList){
            if(String.isNotBlank(timeRec.OC_TR_Status__c) && timeRec.OC_TR_Status__c.equalsIgnoreCase(OC_TR_Constants.Submitted)){
                validateTimeRecordsList.add(timeRec);   
            }
            if(String.isNotBlank(timeRec.OC_TR_LegalForm__c) ){
                setCompanyCodeTimeRecList.add(timeRec);
            }
        }
        if(validateTimeRecordsList!=null && !validateTimeRecordsList.isEmpty()){
            OC_TR_ValidationsUtility.ValidateAgentTimeSpentOnTimeRecord(validateTimeRecordsList);
        }
         if(!setCompanyCodeTimeRecList.isEmpty()){
            OC_TR_HelperUtil.SetCustomerCompCode(setCompanyCodeTimeRecList);
        }
        
        OC_TR_HelperUtil.prefillAccContractOnTimeRecord(timeRecordnewList);// Added for TR-Manual TH
        OC_TR_TimeRecordTriggerHelper.populateSearchFieldsOnTimeRecord(timeRecordnewList);
        OC_TR_TimeRecordTriggerHelper.populateDescriptionFieldOnTimeRecord(timeRecordnewList);
        
    }
 /**************************************************************************************
* @Description  This method validates the timespent of an agent and populates
				the search and description field values on OC_TR_TimeRecord__c  
				object before updating the record into Database.
* @Param		Map - OC_TR_TimeRecord__c oldMap and Map -OC_TR_TimeRecord__c newMap . 
**************************************************************************************/
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        List<OC_TR_TimeRecord__c> timeRecordnewList = (List<OC_TR_TimeRecord__c>)newItems.Values();
        Map<Id,OC_TR_TimeRecord__c> mapIdToNewTimeRec = (Map<Id,OC_TR_TimeRecord__c>) newItems;
        Map<Id,OC_TR_TimeRecord__c> mapIdToOldTimeRec = (Map<Id,OC_TR_TimeRecord__c>) oldItems;
        List<OC_TR_TimeRecord__c> validateTimeRecordsList = new  List<OC_TR_TimeRecord__c> ();
        List<OC_TR_TimeRecord__c> timeRecordListToPopulateSearchFields = new List<OC_TR_TimeRecord__c>();
        List<OC_TR_TimeRecord__c> timeRecordToPopulateDescriptionField = new List<OC_TR_TimeRecord__c>();
        List<OC_TR_TimeRecord__c> setCompanyCodeTimeRecList = new  List<OC_TR_TimeRecord__c> ();
        
        if(OC_TR_checkRecursive.runAgentTimeSpentPerDayValidationOnce()){
            for(OC_TR_TimeRecord__c tr : mapIdToNewTimeRec.Values()){
                if(String.isNotBlank(tr.OC_TR_Status__c) && tr.OC_TR_Status__c.equalsIgnoreCase(OC_TR_Constants.Submitted)){
                    validateTimeRecordsList.add(tr);
                }
                if(String.isNotBlank(tr.OC_TR_LegalForm__c) && (String.isBlank(mapIdToOldTimeRec.get(tr.Id).OC_TR_LegalForm__c) ||
                                                                tr.OC_TR_LegalForm__c != mapIdToOldTimeRec.get(tr.Id).OC_TR_LegalForm__c) ){
                    setCompanyCodeTimeRecList.add(tr);
                }
            }
            if(validateTimeRecordsList!=null && !validateTimeRecordsList.isEmpty()){
                OC_TR_ValidationsUtility.ValidateAgentTimeSpentOnTimeRecord(validateTimeRecordsList); 
            }
            for(OC_TR_TimeRecord__c timeRec : mapIdToOldTimeRec.Values()){
                if(String.isNotBlank(timeRec.OC_TR_Status__c) && timeRec.OC_TR_Status__c.equalsIgnoreCase(OC_TR_Constants.Submitted)
                   && timeRec!=mapIdToNewTimeRec.get(timeRec.Id) &&
                  mapIdToNewTimeRec.get(timeRec.Id).OC_TR_Active__c){
                       mapIdToNewTimeRec.get(timeRec.Id).OC_TR_Status__c = OC_TR_Constants.NotSubmitted;
                   }
                if(!timeRec.OC_TR_Active__c && timeRec!=mapIdToNewTimeRec.get(timeRec.Id)){
                    mapIdToNewTimeRec.get(timeRec.Id).OC_TR_Active__c = true;
                    mapIdToNewTimeRec.get(timeRec.Id).OC_TR_Status__c = OC_TR_Constants.NotSubmitted;
                }
            }   
            
            for(Id key : mapIdToNewTimeRec.keyset()){
            
            OC_TR_TimeRecord__c oldTimeRecord = (OC_TR_TimeRecord__c) mapIdToOldTimeRec.get(key);
            OC_TR_TimeRecord__c newTimeRecord = (OC_TR_TimeRecord__c) mapIdToNewTimeRec.get(key);
            
            if(oldTimeRecord != null && newTimeRecord != null && newTimeRecord.OC_TR_ObjectIdCon__c != null &&
               //(
               (oldTimeRecord.OC_TR_ObjectIdCon__c == null || 
               (oldTimeRecord.OC_TR_ObjectIdCon__c != newTimeRecord.OC_TR_ObjectIdCon__c)) 
               //|| oldTimeRecord.OC_TR_Case__c != newTimeRecord.OC_TR_Case__c) 
              ){
                   timeRecordListToPopulateSearchFields.add(newTimeRecord); 
               }  
            if(oldTimeRecord != null && newTimeRecord != null && 
               oldTimeRecord.OC_TR_ZCostAlloc__c != newTimeRecord.OC_TR_ZCostAlloc__c){
                   timeRecordToPopulateDescriptionField.add(newTimeRecord);
               }
            
        }
        if(timeRecordListToPopulateSearchFields !=null && !timeRecordListToPopulateSearchFields.isEmpty()){
            OC_TR_TimeRecordTriggerHelper.populateSearchFieldsOnTimeRecord(timeRecordListToPopulateSearchFields);
        } 
        if(timeRecordToPopulateDescriptionField !=null && !timeRecordToPopulateDescriptionField.isEmpty()){
            OC_TR_TimeRecordTriggerHelper.populateDescriptionFieldOnTimeRecord(timeRecordToPopulateDescriptionField);
        }
         if(!setCompanyCodeTimeRecList.isEmpty()){
            OC_TR_HelperUtil.SetCustomerCompCode(setCompanyCodeTimeRecList);
        } 
            
        }
        
    }
    
    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterInsert(Map<Id, SObject> newItems) {}
    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
    
}