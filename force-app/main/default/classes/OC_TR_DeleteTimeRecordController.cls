/**
* @File Name          : OC_TR_DeleteTimeRecordController
* @Description        : Controller class to deactivate the time records
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-11                 IBM                   Initial Version

**/ 
public Without Sharing class OC_TR_DeleteTimeRecordController {
    
    @AuraEnabled public String toastMsg {public get;public set;}
    @AuraEnabled public String toastType {public get;public set;}
    @AuraEnabled public Boolean displayDeleteConfirmAlert {public get;public set;}
    public  Static OC_TR_DeleteTimeRecordController timeRecordCntrlObj =  new OC_TR_DeleteTimeRecordController ();
    
    @AuraEnabled
    public Static OC_TR_DeleteTimeRecordController updateTimeRecordAsInactive(Id timeRecId,Boolean validateTRStatus){
        try{
            OC_TR_TimeRecord__c timeRec = [SELECT Id,OC_TR_Active__c,OwnerId 
                                           FROM OC_TR_TimeRecord__c 
                                           WHERE Id=:timeRecId 
                                           LIMIT 1];
            
            if(validateTRStatus){
                if(!timeRec.OC_TR_Active__c){
                    timeRecordCntrlObj.displayDeleteConfirmAlert = false;
                    timeRecordCntrlObj.toastMsg = System.Label.OC_TR_AlreadyDeleted;
                }else if(timeRec.OwnerId == userinfo.getUserId()){
                    timeRecordCntrlObj.displayDeleteConfirmAlert = true;
                }else{
                    timeRecordCntrlObj.toastType = OC_TR_Constants.toastTypeError;
                    timeRecordCntrlObj.toastMsg = System.Label.OC_TR_UnauthorizedToDelete;
                }
                return timeRecordCntrlObj;
                
            }
            
            else if(timeRec.OC_TR_Active__c){
                
                timeRec.OC_TR_Active__c = false;
                Update timeRec; 
                timeRecordCntrlObj.toastType = OC_TR_Constants.toastTypeSuccess;
                timeRecordCntrlObj.toastMsg = System.Label.OC_TR_DeleteSuccessful;
            }
            
        }
        catch(Exception excp){
            timeRecordCntrlObj.toastType = OC_TR_Constants.toastTypeError;
            timeRecordCntrlObj.toastMsg = excp.getMessage();
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.ApexCls_OC_TR_DeleteTimeRecordController,OC_TR_Constants.ApexMethod_updateTimeRecordAsInactive,OC_TR_Constants.deleteTimeRecord,false,excp));
        }
        return timeRecordCntrlObj;
    }
    
}