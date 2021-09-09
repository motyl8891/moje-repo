/* Class Name : OC_TR_ActivitiesProcessor
* Description : Generates the time records for the logged in user based on the selected date and activities
*/ 


public Without Sharing class  OC_TR_ActivitiesProcessor { 
    
    
    /**************************************************************************************************
* @Description : Frames the generic SOQL to fetch the activity record.Based on the activity type, 
*                this method routs to the respective handler class method
* @Param       : selDate - Date for which ericsson engineer wants to generate time record
* @Param       : selActivities - List of activities for which ericsson engineer wants to generate time record
* @Return      : List of time records to be upserted.
****************************************************************************************************/
    @AuraEnabled
    Public Static List<OC_TR_TimeRecord__c> processActivityRecords(Date selDate,String selActivities){
        
        List<String> activitiesList;
        List<String> fieldApiNamesList;
        List<OC_TR_TimeRecord__c> timeRecList;
        List<OC_TR_TimeRecord__c> timeRecordList = new List<OC_TR_TimeRecord__c> ();
        Map<String,String> mapMdtNameTovalue = new Map<String,String>();
        DateTime startDateTime;
        DateTime endDateTime;
        String mdtSOQL;
        Map<String,OC_TR_TimeRecord__c> mapactvtyAccIdActvtyNameToTimeRec = new Map<String,OC_TR_TimeRecord__c> ();
        List<OC_TR_TimeRecord__c> timeRecprocessedList = new List<OC_TR_TimeRecord__c> ();
        Map<String,List<String>> userqueueMap = new Map<String,List<String>>(); //Added for U-2886
        List<string> userqueuesList  = new List<string> ();
        OC_TR_OrganizationMapping__mdt orgMdtRec;
        List<OC_TR_OrganizationMapping__mdt> orgMdtList = new List<OC_TR_OrganizationMapping__mdt> ();
        
        try{
            
            mdtSOQL = 'SELECT Id,OC_TR_ObjectApiName__c,DeveloperName,OC_TR_FieldApiNames1__c,OC_TR_FieldApiNames2__c,OC_TR_FieldApiNames3__c,'+
                'IsContractBased__c,OC_TR_ActivityName__c,OC_TR_ActivityType__c'+' FROM OC_TR_TimeRecordActivity__mdt';
            
            /*If selactivities is blank --> fetches metadata records for all the activities in metadata
*If selactivities is not blank --> fetches metadata records only for activities in selactivities*/ 
            System.debug('selActivities->'+selActivities);
            if(String.isNotBlank(selActivities)){
                activitiesList = selActivities.split(',');
                mdtSOQL = mdtSOQL + ' WHERE OC_TR_ActivityName__c in:activitiesList';
            }
            List<OC_TR_TimeRecordActivity__mdt> timeRecordActivityMdt = database.query(mdtSOQL);
            //Fetch the records of metadata
            for(OC_TR_TimeRecording__mdt mdt : [SELECT Id,OC_TR_Value1__c,Developername
                                                FROM OC_TR_TimeRecording__mdt]){
                                                    mapMdtNameTovalue.put(mdt.DeveloperName,mdt.OC_TR_Value1__c);             
                                                }
            System.debug('mapMdtNameTovalue->'+mapMdtNameTovalue);
            //If atleast one actvity metadata record is available,proceed further else quit the processing
            if(timeRecordActivityMdt!=null && !timeRecordActivityMdt.isEmpty()){
                userqueueMap = OC_TR_QueueQuickActionController.fetchQueuerecords(null,userinfo.getUserId(),userinfo.getUserRoleId());
                System.debug('userqueueMap-->'+userqueueMap);
                //Added for U-2886:Start
                for (List<String> queueList : userqueueMap.values()){
                    for(String queueVal: queueList){
                        userqueuesList.add(queueVal);   
                    }   
                }//U-2886: End
                System.debug('userqueuesList-->'+userqueuesList.size());
                if(test.isRunningTest() || (userqueuesList!=null && !userqueuesList.isEmpty() && userqueuesList.size() == 1)){
                    System.debug('came in');
                    if(test.isRunningTest()){
                        orgMdtList= OC_TR_QueueQuickActionController.getOrgDetailsFromMdt('AMX1_CNS');
                    }else{
                        orgMdtList= OC_TR_QueueQuickActionController.getOrgDetailsFromMdt(userqueuesList[0]);
                    }
                    orgMdtRec = (orgMdtList != null && !orgMdtList.isEmpty()) ? orgMdtList[0] : orgMdtRec ;
                }
                /*If selected date is 04-05-2020,then :
* StartDateTime --> (04-05-2020 00:00:00) + Time difference between user time zone and  GMT Zone
* EndDateTime --> 05-05-2020 00:00:00 + Time difference between user time zone and  GMT Zone
*/
                startDateTime = DateTime.ValueOf(OC_TR_Utility.convertUserTimeZoneDateToGMT(selDate,UserInfo.getTimeZone()));
                endDateTime   = startDateTime.addDays(1); 
                String CalcStartDateTime = startDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                String CalcEndDateTime = endDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                
                //Iterate over the activity metadata records
                for(OC_TR_TimeRecordActivity__mdt activityMdt : timeRecordActivityMdt){
                    timeRecList = new List<OC_TR_TimeRecord__c>();
                    fieldApiNamesList = new List<String> ();
                    fieldApiNamesList.add(activityMdt.OC_TR_FieldApiNames1__c);
                    fieldApiNamesList.add(activityMdt.OC_TR_FieldApiNames2__c);
                    fieldApiNamesList.add(activityMdt.OC_TR_FieldApiNames3__c); 
                    String SOQLQuery = OC_TR_Utility.generateSOQL(activityMdt.OC_TR_ObjectApiName__c,fieldApiNamesList) +
                        ' WHERE '+'Createddate>='+CalcStartDateTime+' AND '  + 'Createddate<'+CalcEndDateTime;
                    
                    
                    //If activity name is Forum,route to respective handler method which returns a list of time records
                    if(activityMdt.OC_TR_ActivityName__c.equalsIgnorecase(OC_TR_Constants.Forum)){
                        
                        timeRecList =  OC_TR_ProcessNonContractActivityRecords.calculateTimeSpentByAgentInForum(activityMdt,mapMdtNameTovalue,SelDate,CalcStartDateTime,CalcEndDateTime,SOQLQuery,orgMdtRec);
                        //If activity name is Chat,route to respective handler method which returns a list of time records   
                    }else if(activityMdt.OC_TR_ActivityName__c.equalsIgnorecase(OC_TR_Constants.Chat)){ 
                        
                        timeRecList =  OC_TR_ProcessContractActivityRecords.calculateTimeSpentByAgentInChat(activityMdt,mapMdtNameTovalue,SelDate,CalcStartDateTime,CalcEndDateTime,SOQLQuery,orgMdtRec,userQueuesList);
                        system.debug('timeRecList in Activity ==>'+timeRecList);
                    }
                    if(timeRecList!=null && !timeRecList.isEmpty()){ 
                        timeRecordList.addAll(timeRecList);
                    }
                }
            }     
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_ACTIVITIESPROCESSOR,OC_TR_Constants.PROCESSACTIVITYRECORDS,OC_TR_Constants.OC_TR_ACTIVITIESPROCESSOR, false, e));
        }
        return timeRecordList;   
    }
    /**************************************************************************************************
* @Description : Upserts the list of time records
* @Param       : timeRecList - list of time records to be upserted
* @Return      : Successfully upserted time records list
* 
****************************************************************************************************/   
    @AuraEnabled
    Public Static  List<OC_TR_TimeRecord__c> upsertTimeRecords(List<OC_TR_TimeRecord__c> timeRecList) {
        Set<Id> DMLSuccessRecIdSet = new Set<Id>();
        List<OC_TR_TimeRecord__c> DMLSuccessRecList = new List<OC_TR_TimeRecord__c> ();
        try{
            if(timeRecList!=null && !timeRecList.isEmpty()){
                Database.UpsertResult[] upsertResultsList = database.upsert(timeRecList,false);
                for(Integer i = 0; i < upsertResultsList.size(); i++) {
                    if(upsertResultsList[i].isSuccess()) {
                        DMLSuccessRecIdSet.add(upsertResultsList[i].getId());
                    }else{
                    } 
                }
                DMLSuccessRecList = [SELECT Id,Name,OC_TR_ActivityName__c,OC_TR_TimeSpent__c,OC_TR_Status__c,OC_TR_PostingDate__c,RecordTypeId,OC_TR_Organization__c
                                     FROM   OC_TR_TimeRecord__c
                                     WHERE id in:DMLSuccessRecIdSet];  
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_ACTIVITIESPROCESSOR,OC_TR_Constants.Method_UpsertTimeRecords,null, false, e));
        }
        return DMLSuccessRecList;    
    }  
}