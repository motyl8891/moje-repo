/* Class Name : OC_TR_GenerateTimeRecordController
* Description : Controller class for lightning component OC_TR_GenerateTimeRecord.
*/
public Without Sharing class OC_TR_GenerateTimeRecordController { 
   @AuraEnabled public  Boolean overrideTimeRecAlert {public get;public set;}
   @AuraEnabled public  List<OC_TR_TimeRecord__c> timeRecListToUpsert {public get;public set;}
    /**************************************************************************************
    * @Description  Fetches the names of activities from metadata
    * @Return       List of activity names for which time records can be generated 
    *******************************************************************/
    @AuraEnabled
    Public Static List<String> fetchActivityOptions(){
        List<String> activityOptions = new List<String>(); 
        for(OC_TR_TimeRecordActivity__mdt mdtRec :  [SELECT Id,OC_TR_ActivityName__c
                                                     FROM OC_TR_TimeRecordActivity__mdt
                                                     ORDER BY OC_TR_ActivityName__c
                                                    ]){
                                                        activityOptions.add(mdtRec.OC_TR_ActivityName__c);  
                                                    }
        /*try{
        
        } Catch (Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_GENERATETIMERECORDCONTROLLER,OC_TR_Constants.Method_FetchActivityOptions,null, false, e));
        }  */  
        
        return activityOptions;    
    }
    
     /**************************************************************************************
    * @Description  Fetches the time records to be upserted and sets the parameter overrideTimeRecAlert
    * @Param        selDate - Date for which ericsson engineer wants to generate time record
    * @Param        selActivities - List of activities for which ericsson engineer wants to generate time record
    * @Return       Object of OC_TR_GenerateTimeRecordController which holds the values for variables 
    *               overrideTimeRecAlert,timeRecListToUpsert
    *******************************************************************/
   @AuraEnabled
    Public Static OC_TR_GenerateTimeRecordController validateTimeRecordGeneration(Date selDate,String selActivities){
        List<OC_TR_TimeRecord__c> timeRecList = OC_TR_ActivitiesProcessor.processActivityRecords(selDate,selActivities);
    
        OC_TR_GenerateTimeRecordController controllerObj;
        try{
        controllerObj = new OC_TR_GenerateTimeRecordController();
        
        if(timeRecList!=null && !timeRecList.isEmpty()){
            System.debug('came in');
            controllerObj.timeRecListToUpsert = timeRecList; 
            for(OC_TR_TimeRecord__c tr : timeRecList){
                if(tr.Id!=null){
                    controllerObj.overrideTimeRecAlert = true;
                    break;
                }else {
                    controllerObj.overrideTimeRecAlert = false;
                }
            }   
        }else{
          controllerObj.overrideTimeRecAlert = false;
          controllerObj.timeRecListToUpsert = timeRecList;  
        }
        }
        catch(Exception e){
           EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_GENERATETIMERECORDCONTROLLER,OC_TR_Constants.Method_ValidateTimeRecordGeneration,null, false, e));
        }
        return controllerObj;
    }
    /**************************************************************************************
    * @Description  validates whether the logged in service engineer is allowed to generate time record
    * @Return       Boolean value (true/false)
    *******************************************************************/    
   @AuraEnabled
    Public Static Boolean verifyLoggedInUserEmployeeDetails(){
        
        Boolean validateLoggedInUserEmployeeDetails;
        try{
            User userDetails = [SELECT Id, OC_TR_EmployeeCompanyCode__c, OC_TR_EmployeeNumber__c FROM User where id =: USERINFO.getUserId() AND isActive=true LIMIT 1];
            
            if(userDetails.OC_TR_EmployeeCompanyCode__c != null && userDetails.OC_TR_EmployeeNumber__c != null){
                validateLoggedInUserEmployeeDetails = true;  
            }else{
                validateLoggedInUserEmployeeDetails = false;
            }
        }
        catch(Exception e){
         EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_GENERATETIMERECORDCONTROLLER,OC_TR_Constants.VERIFYLOGGEDINUSEREMPLOYEEDETAILS,null, false, e));
        }
        return validateLoggedInUserEmployeeDetails;
    }
    /**************************************************************************************
    * @Description : calls the handler method to Upsert validated list of time records 
    * @Param       : timeRecList - list of time records to be upserted
   *  @Return      : Successfully upserted time records list
    *******************************************************************/  
    @AuraEnabled
    Public Static List<OC_TR_TimeRecord__c> generateTimeRecords(List<OC_TR_TimeRecord__c> timerecList){
        return (OC_TR_ActivitiesProcessor.upsertTimeRecords(timerecList));  
    }
    
    @AuraEnabled
    public static List<OC_TR_TimeRecord__c> updateTimeRecords (List<OC_TR_TimeRecord__c> timeRecToUpdateList,List<OC_TR_TimeRecord__c> generatedTimeRecList, boolean submitTimeRecord,boolean getOnlyUpdatedTimeRecList) {
        Map<Id,OC_TR_TimeRecord__c> maptimeRecidToTimeRec = new Map<Id,OC_TR_TimeRecord__c> ();
        List<OC_TR_TimeRecord__c> timeRecordsUpdateList = new List<OC_TR_TimeRecord__c>();
        List<OC_TR_TimeRecord__c> returnUpdatedTRList = new List<OC_TR_TimeRecord__c>();
        List<Id> timeRecIdList = new List<Id>();
        
        try{
        if(submitTimeRecord){
            for(OC_TR_TimeRecord__c timerecord : timeRecToUpdateList)
            {
                timerecord.OC_TR_Status__c = OC_TR_Constants.Submitted;
                timeRecordsUpdateList.add(timerecord);
            }
            update timeRecordsUpdateList;
        }else if(!getOnlyUpdatedTimeRecList){
            update timeRecToUpdateList;
        }
        
        
        if(!generatedTimeRecList.isEmpty()){
            for(OC_TR_TimeRecord__c timerecord : generatedTimeRecList){
                timeRecIdList.add(timerecord.Id);
            }
             returnUpdatedTRList = getupdatedTimeRecords(timeRecIdList);
        }
        
        }catch(DmlException dmlExcp){
            throw new AuraHandledException (dmlExcp.getMessage());
        }    
        Catch(Exception excp){
            throw new AuraHandledException (excp.getMessage());
        }
         return returnUpdatedTRList;
    }
    
     @AuraEnabled
     public static List<OC_TR_TimeRecord__c> getupdatedTimeRecords (List<Id> timeRecList){
         List<OC_TR_TimeRecord__c> returnUpdatedTRList = new List<OC_TR_TimeRecord__c>();
         
         returnUpdatedTRList = [SELECT Id,Name,OC_TR_PostingDate__c,OC_TR_ActivityName__c,OC_TR_TimeSpent__c,
                                       OC_TR_Status__c,OC_TR_Organization__c 
                                FROM  OC_TR_TimeRecord__c 
                                WHERE Id in:timeRecList
                              ];
         return returnUpdatedTRList;
     }
     
}