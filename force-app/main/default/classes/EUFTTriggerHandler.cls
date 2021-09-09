/****************************************************************
* @author: Shubham Kadam  
* @date: 09/10/2020
* @User Story: U-2039
* @description: This class will handle EUFTTrigger
*****************************************************************/
public without sharing class EUFTTriggerHandler {
    
    /****************************************************************
* @author: Shubham Jagatap  
* @date: 19/11/2020
* @User Story: U-2278
* @description: This method will be called from EUFTTrigger on Before insert
*****************************************************************/
    
    public static void onBeforeInsert(List<EUFT__c> newEUFT)
    {
        //U-2278
        EUFTTriggerHelper.updateCountryRisk(newEUFT);
    }
    
    /****************************************************************
* @author: Shubham Kadam  
* @date: 09/10/2020
* @User Story: U-2039
* @description: This method will be called from EUFTTrigger on after update
*****************************************************************/
    public static void onAfterUpdate(List<EUFT__c> newEUFT, List<EUFT__c> oldEUFT, 
                                     Map<ID, EUFT__c> newEUFTMap, Map<ID, EUFT__c> oldEUFTMap)
    {
        //U-2039
        EUFTTriggerHelper.updateSBSStatus(newEUFT, oldEUFTMap);
        
        //U-2386
        EUFTTriggerHelper.updateSensitiveBusinessStatus(newEUFT, oldEUFTMap, false, true);
        EUFTTriggerHelper.CallResetSecondaryApprovalStatusFromEUFT(newEUFT, oldEUFTMap);
        
        //U-2399
        EUFTTriggerHelper.updateManualSBStatusRequired(newEUFT);
    }
    
    /****************************************************************
* @author: Shubham Kadam  
* @date: 09/10/2020
* @User Story: U-2039
* @description: This method will be called from EUFTTrigger on after insert
*****************************************************************/
    public static void onAfterInsert(List<EUFT__c> newEUFT, List<EUFT__c> oldEUFT, 
                                     Map<ID, EUFT__c> newEUFTMap, Map<ID, EUFT__c> oldEUFTMap) 
    {
        //U-2039
        EUFTTriggerHelper.updateShipToCountries(newEUFT);  
        
        //U-2399
        EUFTTriggerHelper.updateManualSBStatusRequired(newEUFT);
        
        //U-2386
        EUFTTriggerHelper.updateSensitiveBusinessStatus(newEUFT, oldEUFTMap, true, false);
    }
    
    /****************************************************************
* @author: Shubham Kadam  
* @date: 09/10/2020
* @User Story: U-2039
* @description: This method will be called from EUFTTrigger on after delete
*****************************************************************/
    Public static void onAfterDelete(List<EUFT__c> oldEUFT)
    {
        //U-2039
        EUFTTriggerHelper.updateShipToCountries(oldEUFT);
    }    
}