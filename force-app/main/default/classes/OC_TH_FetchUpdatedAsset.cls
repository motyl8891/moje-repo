/**
* @File Name          : OC_TH_FetchUpdatedAsset
* @Description        : Ticket Handling: This is the controller class for OC_TH_displayButton
                        to Fetch the upgraded Asset details                 
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 05 August 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-05                 IBM                  Initial Version
**/

public with sharing class OC_TH_FetchUpdatedAsset {
    /**********************************************************************
* @Description : This method returns updated records from Asset object of type Case.  
*****************************************************************************/
 
    @AuraEnabled
    public static Case updateRecord(Id recordid){
        try{
        Case records = [SELECT Id, Status, RecordType.DeveloperName, OC_TH_Node_Type__c, AssetId, Asset.Name, Asset.Product2.Name, OC_TH_Product__c, Asset.OC_TH_Version__c, 
                        OC_TH_Version__c, Asset.OC_TH_Release__c, OC_TH_Release__c,
                        OC_TH_Node_Type__r.Product2.Name, OC_TH_Node_Type__r.OC_TH_Release__c, 
                        OC_TH_Node_Type__r.OC_TH_Version__c from Case WHERE id=:recordid LIMIT 1];
        
        if(String.isNotBlank(recordid) && String.isNotEmpty(recordid) && records.AssetId!=null && records.Status!=OC_TH_Constants.getStatus 
           && records.RecordType.DeveloperName==OC_TH_Constants.getStandardCsrRecordType){
            //assign the latest upgraded records from asset object to case object
            
        	records.OC_TH_Product__c = records.Asset.Product2.Name;
            records.OC_TH_Release__c = records.Asset.OC_TH_Release__c;
            records.OC_TH_Version__c = records.Asset.OC_TH_Version__c;
           }
        update records;
        return records;
        }
        catch(Exception e){
            throw (e);
        }
    }
}