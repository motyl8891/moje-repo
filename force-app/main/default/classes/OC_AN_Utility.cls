/**
* @File Name          : OC_AN_Utility 
			           (Controller class for OC_AN_BulletinAccountSelection,OC_AN_BulletinProductSelection,
						OC_AN_InternalDistribution) 
* @Description        : This class will be used to verify the record editibility for the logged in user.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10                 IBM               Initial Version
**/

public class OC_AN_Utility {
    
   /**************************************************************************************************
   	* @Description : This method will verify the bulletin status and record editibility access for the user.
   	* @Param       : bulletinId - Id of the bulletin for which the status and record editability to be checked.
    * @Return      : Current status of the bulletin.
   ****************************************************************************************************/  
    
    @AuraEnabled
    public static String verifyBulletinStatusAndRecordEditability(Id bulletinId){        
        String currentStatus;    
        try{
        OC_AN_Bulletin__c bulletin = [SELECT Id,OC_AN_Current_Status__c, OC_AN_Technical_Reviewer__c, OC_AN_Editorial_Review__c FROM OC_AN_Bulletin__c WHERE Id =: bulletinId];
        if( bulletin.OC_AN_Current_Status__c == OC_AN_Constants.INTECHNICALREVIEW && bulletin.OC_AN_Technical_Reviewer__c == UserInfo.getUserId() ){
            currentStatus = OC_AN_Constants.DRAFT;
        }else if( bulletin.OC_AN_Current_Status__c == OC_AN_Constants.INEDITORIALREVIEW && bulletin.OC_AN_Editorial_Review__c == UserInfo.getUserId() ){
            currentStatus = OC_AN_Constants.DRAFT;            
        }else{
            currentStatus = bulletin.OC_AN_Current_Status__c;
        }
            } catch(Exception e){
                EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_Utility,OC_AN_Constants.verifyBulletinStatusAndRecordEditability,OC_AN_Constants.OC_AN_Utility, false, e));
            }
        return currentStatus;
    }
    
    
   /**************************************************************************************************
  	 * @Description : Generic Method to fetch the OC_AN_Bulletin__c and its related records.
   	 * @Param       : recordTypeId - RecordTypeId of OC_AN_Bulletin_c child record.
   	 * @Param       : bulletinId   - RecordId of the bulletin.
   	 * @Return      : List of OC_AN_Bulletin__C and its child records.
   ****************************************************************************************************/
    
    public static List<OC_AN_Bulletin__c> getBulletinRelatedRecord(String recordTypeId,Set<Id> bulletinId){
        
        List<OC_AN_Bulletin__c> bulletinList = new List<OC_AN_Bulletin__c>();
        
        try{
            bulletinList = [SELECT Id , OC_AN_IsInternal__c,OC_AN_IsExternal__c, (SELECT Id,RecordTypeId FROM Bulletin_Account_Products__r 
                                                  WHERE RecordTypeId =: recordTypeId )
                                     FROM OC_AN_Bulletin__c WHERE Id IN :bulletinId] ;
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_Utility,OC_AN_Constants.getBulletinRelatedRecord,OC_AN_Constants.OC_AN_Utility, false, e));
        }
        
        return bulletinList;
    } 
    
    
}