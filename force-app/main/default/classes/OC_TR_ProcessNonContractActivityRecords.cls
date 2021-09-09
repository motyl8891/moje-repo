/* Class Name : OC_TR_ProcessNonContractActivityRecords
* Description : Contains the calculation logics to determine the time spent by logged in user 
*               for all the activities (without contract) 
*/ 
public Without Sharing class OC_TR_ProcessNonContractActivityRecords { 
    
    /**************************************************************************************
* @Description  This method conatins calculation logic to determine the time spent by logged in service engineer
*               in forum moderation
* @Param        activityMdt - Metadata record containg the activity information
* @Param        mapMdtNameTovalue - Map of metadata records (Key:Developername,value:Metadata record)
* @Param        selDate - Date for which ericsson engineer wants to generate time record
* @Param        CalcStartDateTime - Datetime from when activity records needs to be fetched.
* @Param        CalcEndDateTime - Datetime till when  activity records needs to be fetched.
* @Param        SOQLQuery - Generic SOQL framed in OC_TR_ActivitiesProcessor
* @Return       List of time records to be upserted    
*******************************************************************/
    public Static List<OC_TR_TimeRecord__c> calculateTimeSpentByAgentInForum( OC_TR_TimeRecordActivity__mdt activityMdt,Map<String,String> mapMdtNameTovalue,Date selDate,String CalcStartDateTime,String CalcEndDateTime ,String SOQLQuery,OC_TR_OrganizationMapping__mdt orgMdtRec){
        
        
        Map<Id,Decimal> mapuserIdToTimeSpent  = new Map<Id,Decimal> (); 
        List<FeedComment> feedCommentList = new List<FeedComment>();
        List<NetworkActivityAudit> networkActvtyRecList = new List<NetworkActivityAudit> ();
        List<OC_TR_TimeRecord__c> timeRecList; 
        Set<Id> feedItemId = new Set<Id>();
        Set<Id> moderatorUserIdSet = new Set<Id>();
        Map<Id,FeedComment> mapIdToFeedCommentRec = new Map<Id,FeedComment> (); 
        Map<String,Decimal> mapActionnameToBufferTime = new Map<String,Decimal>();
        //mapuserIdToTimeSpent = new Map<Id,Decimal> ();
        List<FeedRevision> feedRevisionList = new List<FeedRevision>();//Additional Moderation
        PermissionSet  moderatorPS = [SELECT Id, Label, Name from PermissionSet where Name =:OC_TR_Constants.ps_CommunityModerator LIMIT 1];
        //Get users assigned with moderator permission set
        for ( PermissionSetAssignment psa : [SELECT  Assignee.ID,PermissionSet.ID
                                             FROM PermissionSetAssignment  
                                             WHERE  PermissionSet.ID =:moderatorPS.Id]){
                                                 moderatorUserIdSet.add(psa.Assignee.ID);
                                             }
        //If logged in user is moderator execute the logic else skip the execution
        if(moderatorUserIdSet.Contains(userinfo.getUserId())){
            SOQLQuery = SOQLQuery + ' AND CreatedById='+'\'' +userinfo.getUserId() +'\'';
            
            if(!Test.isRunningTest()){
                networkActvtyRecList = database.query(SOQLQuery);
            }    
            String feedCommSOQL = 'SELECT FeedItemId,createddate,CommentBody,CreatedById FROM FeedComment'+
                ' WHERE '+'Createddate>='+CalcStartDateTime+' AND '  + 'Createddate<'+CalcEndDateTime+
                ' AND CreatedById='+'\'' +userinfo.getUserId() +'\'';    
            
            
             
            for(FeedComment feedComm : database.query(feedCommSOQL)){
                feedItemId.add(feedComm.FeedItemId);
                mapIdToFeedCommentRec.put(feedComm.Id,feedComm);
            }
            String CustomerCommunityId = System.Label.OC_CustomerCommunityId;
            Map<Id,FeedItem> mapIdToFeedItemRec = new Map<Id,FeedItem> ([SELECT Id,NetworkScope 
                                                                         FROM FeedItem
                                                                         WHERE Id in:feedItemId
                                                                         AND NetworkScope=:CustomerCommunityId]);
            //Collect feed comments that are made in community
            for(FeedComment feedComm : mapIdToFeedCommentRec.Values()){
                if(mapIdToFeedItemRec.ContainsKey(feedComm.FeedItemId)){
                    feedCommentList.add(feedComm);
                }
                
            }
            
            
            
            
            //Get the metdatda records where buffer time for forum activites is maintained
            for ( OC_T_ActivityBufferTime__mdt forumActBufferMdt: [SELECT Id,ObjectApiName__c,OC_TR_ActionName__c,OC_TR_BufferTime__c
                                                                   FROM OC_T_ActivityBufferTime__mdt
                                                                   WHERE ObjectApiName__c =:OC_TR_Constants.NetworkActivityAudit OR 
                                                                   ObjectApiName__c =:OC_TR_Constants.FeedComment OR
                                                                   ObjectApiName__c =:OC_TR_Constants.FeedRevision]){
                                                                       mapActionnameToBufferTime.put(forumActBufferMdt.OC_TR_ActionName__c.toUpperCase(),Decimal.ValueOf(forumActBufferMdt.OC_TR_BufferTime__c));
                                                                   }
            if(mapActionnameToBufferTime!=null && !mapActionnameToBufferTime.isEmpty()){
                
                if(feedCommentList!=null && !feedCommentList.isEMpty()){
                    /*Iterate over the feedcomments and calculate the time spent by agent 
                        by considering the respective buffer time avaiable in metadata */
                    for(FeedComment feedRec : feedCommentList){
                        Decimal timeSpentByAgent = 0.0;
                        
                        if(mapuserIdToTimeSpent!=null && !mapuserIdToTimeSpent.isEmpty() && 
                           mapuserIdToTimeSpent.containsKey(feedRec.CreatedById) && 
                           mapActionnameToBufferTime.containsKey(OC_TR_Constants.NewFeedComment.toUpperCase())){
                               timeSpentByAgent = mapuserIdToTimeSpent.get(feedRec.CreatedById) +
                                   mapActionnameToBufferTime.get(OC_TR_Constants.NewFeedComment.toUpperCase());
                           }else{
                               timeSpentByAgent = mapActionnameToBufferTime.get(OC_TR_Constants.NewFeedComment.toUpperCase());
                           }
                        if(timeSpentByAgent > 0){
                            mapuserIdToTimeSpent.put(feedRec.CreatedById,timeSpentByAgent);  
                        }
                        
                        
                    }
                }  
                
                //Additional Moderate Actvities -Begin
                String feedRevisionSOQL = ' SELECT Id, CreatedById, Createddate '+
                                          ' FROM FeedRevision '+ 
                                          ' WHERE CreatedById='+'\'' +userinfo.getUserId() +'\''+
                                          ' AND ' + 'Createddate>='+CalcStartDateTime+
                                          ' AND ' + 'Createddate<'+CalcEndDateTime+ 
                                          ' AND ' +' EditedAttribute = \'FeedCommentBody\''+
                                          ' AND OriginNetworkId='+'\''+mapMdtNameTovalue.get(OC_TR_Constants.CustomerCommunityId)+'\'';
            
            feedRevisionList = database.query(feedRevisionSOQL);
                
            if(!feedRevisionList.isEmpty()){
                
                    Decimal timeSpentByAgent = 0.0;
                    if(!mapuserIdToTimeSpent.isEmpty() && 
                       mapActionnameToBufferTime.containsKey(OC_TR_Constants.EditFeedComment.toUpperCase())){
                           timeSpentByAgent = mapuserIdToTimeSpent.get(feedRevisionList[0].CreatedById) +
                               (mapActionnameToBufferTime.get(OC_TR_Constants.EditFeedComment.toUpperCase()) * feedRevisionList.size());
                       }
                    else{
                        timeSpentByAgent = (mapActionnameToBufferTime.get(OC_TR_Constants.EditFeedComment.toUpperCase()) * feedRevisionList.size());
                    }
                    
                    if(timeSpentByAgent > 0){
                        mapuserIdToTimeSpent.put(feedRevisionList[0].CreatedById,timeSpentByAgent);  
                    }
                    
                }  
                //Additional Moderate Actvities - End 
                
                /*Iterate over the networkactivityaudit records and calculate the time spent by agent 
                  by considering the respective buffer time avaiable in metadata */
                if(networkActvtyRecList!=null && !networkActvtyRecList.isEmpty()){
                    for(NetworkActivityAudit moderationActionRec :  networkActvtyRecList){
                        Decimal timeSpentByAgent = 0.0;
                        
                        if(mapuserIdToTimeSpent!=null && !mapuserIdToTimeSpent.isEmpty() && 
                           mapuserIdToTimeSpent.containsKey(moderationActionRec.CreatedById) && 
                           mapActionnameToBufferTime.containsKey(moderationActionRec.Action.toUpperCase())){
                               
                               
                               timeSpentByAgent = mapuserIdToTimeSpent.get(moderationActionRec.CreatedById) +
                                   mapActionnameToBufferTime.get(moderationActionRec.Action.toUpperCase());
                               
                           }else if(mapActionnameToBufferTime.containsKey(moderationActionRec.Action.toUpperCase())){
                               timeSpentByAgent = mapActionnameToBufferTime.get(moderationActionRec.Action.toUpperCase());
                               
                           }
                        if(timeSpentByAgent > 0){
                            mapuserIdToTimeSpent.put(moderationActionRec.CreatedById,timeSpentByAgent);
                        }
                    } 
                    
                }   
            }
            //Prepare time record data with the calculated time from all the moderation activites
            if(mapuserIdToTimeSpent!=null && !mapuserIdToTimeSpent.isEmpty()){
                timeRecList = generateTimeRecordForAgent(mapuserIdToTimeSpent,activityMdt,selDate,orgMdtRec);
            }
            
            
        }
        
        return timeRecList;
    }
    
    /**************************************************************************************
* @Description  This method contains the logic to frame the data of time records 
* @Param        mapUserIdToTimeSpent - Key:UserId - Id of ericsson engineer who performed the activity
*                                     value : Total time spent by ericsson engineer on activity
* @Param        timeRecordActivityMdt - Metadata record containg the activity information
* @Param        selDate - Date for which ericsson engineer wants to generate time record
* @Return       List of time records to be upserted    
*******************************************************************/
    Public Static List<OC_TR_TimeRecord__c> generateTimeRecordForAgent(Map<Id,Decimal> mapUserIdToTimeSpent,OC_TR_TimeRecordActivity__mdt timeRecordActivityMdt,Date selDate,OC_TR_OrganizationMapping__mdt orgMdtRec){
        List<OC_TR_TimeRecord__c> timeRecInsertList;
        Map<Id,Map<String,String> > mapUserIdToEmpNoEmpCC = new Map<Id,Map<String,String> > ();
        String employeeNum;
        String employeeCC;
        List<OC_TR_TimeRecord__c> existingTimeRecList; 
        
        //Query user to get Employee number and Employee CC 
        for( User userRec : [SELECT Id,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c
                             FROM USER 
                             WHERE OC_TR_EmployeeNumber__c!=null AND OC_TR_EmployeeCompanyCode__c!=null
                             AND Id=:userInfo.getUserId()
                            ]){
                                
                                employeeNum = userRec.OC_TR_EmployeeNumber__c;
                                employeeCC = userRec.OC_TR_EmployeeCompanyCode__c;
                            }
        
        
        /*Query time record for the selected date if available with combination 
Posting Date + exclude records created by user manually*/
        for(OC_TR_TimeRecord__c timeRec : [SELECT  Id,Name,OC_TR_PostingDate__c,OC_TR_ServiceToAccount__c,OC_TR_IsManualEntry__c,OC_TR_TimeSpent__c,OC_TR_Active__c,CreatedDate
                                           FROM OC_TR_TimeRecord__c 
                                           WHERE OC_TR_PostingDate__c =:selDate
                                           AND OC_TR_IsManualEntry__c = false
                                           AND CreatedById=:userinfo.getuserId() 
                                           AND OC_TR_ActivityName__c =:timeRecordActivityMdt.OC_TR_ActivityName__c
                                           AND OC_TR_Active__c = true ORDER BY CreatedDate DESC LIMIT 1
                                          ]){
                                              
                                              existingTimeRecList = new List<OC_TR_TimeRecord__c>();
                                              existingTimeRecList.add(timeRec);                                
                                              
                                          }
        if(String.isNotBlank(employeeNum) && String.isNotBlank(employeeCC)){
            timeRecInsertList = new List<OC_TR_TimeRecord__c> ();
            OC_TR_TimeRecord__c timeRecord;
            //If a time record is available for the selected date,update the same record with new calculated time spent.
            if(existingTimeRecList!=null && !existingTimeRecList.isEmpty()){
                //Do not update Time record if calculated time spent is same as the existing 
                if(existingTimeRecList[0].OC_TR_TimeSpent__c != String.ValueOf(mapUserIdToTimeSpent.get(UserInfo.getuserId()))){
                    timeRecord = existingTimeRecList[0];
                    timeRecord.OC_TR_TimeSpent__c = String.ValueOf(mapUserIdToTimeSpent.get(UserInfo.getuserId()));
                    if(orgMdtRec != null ){
                        timeRecord.OC_TR_Organization__c = orgMdtRec.Queue_Name__c;
                        timeRecord.OC_TR_ZZOrgNew__c = orgMdtRec.OC_TR_Org_Id__c;
                        timeRecord.OC_TR_LegalForm__c = orgMdtRec.OC_TR_LegalForm__c;
                    }
                }
                //If a time record is unavailable for the selected date,create a new time record with calculated time spent.
            }else{
                Id timeRecRTId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get(timeRecordActivityMdt.OC_TR_ActivityName__c).getRecordTypeId();
                timeRecord = new OC_TR_TimeRecord__c ();
                timeRecord.OC_TR_Employee_Number__c = employeeNum;
                timeRecord.OC_TR_Employee_CC__c = employeeCC;
                timeRecord.OC_TR_PostingDate__c = selDate;
                timeRecord.OC_TR_TimeSpent__c = String.ValueOf(mapUserIdToTimeSpent.get(UserInfo.getuserId()));
                timeRecord.OC_TR_ActivityType__c = timeRecordActivityMdt.OC_TR_ActivityType__c;
                timeRecord.OC_TR_IsManualEntry__c = false;
                timeRecord.RecordTypeId = timeRecRTId;
                timeRecord.OC_TR_Status__c = OC_TR_Constants.NotSubmitted;
                timeRecord.OC_TR_Search_UserName__c = userinfo.getName();
                
                if(orgMdtRec != null ){
                    timeRecord.OC_TR_Organization__c = orgMdtRec.Queue_Name__c;
                    timeRecord.OC_TR_ZZOrgNew__c = orgMdtRec.OC_TR_Org_Id__c;
                    timeRecord.OC_TR_LegalForm__c = orgMdtRec.OC_TR_LegalForm__c;
                }
            }
            
            if(timeRecord!=null){
                timeRecInsertList.add(timeRecord);
            }
        }  
        return timeRecInsertList;
    }     
}