/**
* @File Name          : OC_GST_SCH_BATCH_GSTForumIntegration
* @Description        : Batch cum Schedule class to pick Forum data and send to GST for Indexing
* @Author             : Richa Gupta
* @Group              : OmniChannel - Service
* @Created Date       : 1st May 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-5-17              Richa Gupta               Initial Version
**/
global class OC_GST_SCH_BATCH_GSTForumIntegration implements Database.Batchable<Sobject>,Database.AllowsCallouts,Schedulable {
    global Boolean isFullBatchExecuted = false; //This boolean determines whether custom metadata should be updated
    global Datetime lastRefreshDateBatch;
    
/****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: none
* @description: Default constructor
*****************************************************************/    

    public OC_GST_SCH_BATCH_GSTForumIntegration() {
		isFullBatchExecuted = false;
    }
    
/****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: lastRefreshDate
* @description: This method takes the date from which it has to pick forum data and send to GST
*****************************************************************/    

    public OC_GST_SCH_BATCH_GSTForumIntegration(Datetime lastRefreshDate) {        
        isFullBatchExecuted = true;
        lastRefreshDateBatch = lastRefreshDate;
    }


    /****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: Database.BatchableContext
* @description: Start method which is invoked by Schedule class to execute every half and hour
*******************************************************************/     

    global Database.QueryLocator start(Database.BatchableContext bc) {
        //Below metadata stored the information of GST
        Map<String, GST_API_Details__c> gstAPISettings = GST_API_Details__c.getAll();
        String scheduleJobName = '%'+gstAPISettings.get('OC_GST_Schedule_Job_Name').value__c+'%';
        Datetime lastScheduleRun ;
        if (isFullBatchExecuted){
            lastScheduleRun = lastRefreshDateBatch;
        }else{
            //Fetch the last execution of the schedule class which sent the data to GST
            list<CronTrigger> scheduleClassInfo = new list <CronTrigger>([SELECT CronJobDetailId,EndTime,
                                                                                Id,NextFireTime,PreviousFireTime,StartTime,State,
                                                                                TimesTriggered 
                                                                                FROM 
                                                                                CronTrigger 
                                                                                WHERE 
                                                                                CronJobDetail.Name LIKE :scheduleJobName ORDER BY PreviousFireTime DESC NULLS LAST LIMIT 2]);

            String customSetDate = String.valueOf(gstAPISettings.get('OC_GST_Last_GST_Sync').Value__c);
            String dateTemp = customSetDate.substringBefore(' ');
            String timeTemp = customSetDate.substringAfter(' ');
            list<String> dateBReak = dateTemp.split('-');
            list<String> timeBReak = timeTemp.split(':');
            Datetime customSettingDate = DateTime.newInstanceGmt(Integer.valueOf(dateBReak[0]), Integer.valueOf(dateBReak[1]), Integer.valueOf(dateBReak[2]), Integer.valueOf(timeBReak[0]), Integer.valueOf(timeBReak[1]), Integer.valueOf(timeBReak[2]));

            //If previous execution of the class has happened
            if(!scheduleClassInfo.isEmpty()) {
                    if(scheduleClassInfo[1].PreviousFireTime != null){//If the class has been executed
                        lastScheduleRun = scheduleClassInfo[1].PreviousFireTime > customSettingDate ? scheduleClassInfo[1].PreviousFireTime : customSettingDate;
                    } else {
                        //If the class has been scheduled but not yet executed even once
                        lastScheduleRun = customSettingDate;
                    }
                }else {
                    //If there is no previous run of the schedule class take the time from Custom Setting
                    lastScheduleRun = customSettingDate;
                } 
            }
                
        String communityId = gstAPISettings.get('OC_GST_CommunityId').Value__c;
        String query = 'Select id,title, body, CommentCount,HasVerifiedComment,LikeCount,Type,CreatedById,BestCommentId,IsRichText,createdDate,(Select id,commentbody,createddate from FeedComments where SystemModstamp > :lastScheduleRun AND commentbody != null),(Select id,Topic.Name from TopicAssignments where SystemModstamp > :lastScheduleRun) from FeedItem where SystemModstamp > :lastScheduleRun AND Type = \'QuestionPost\' AND NetworkScope =:communityId LIMIT 5000000';                      
        return Database.getQueryLocator(query);
    }

/****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: Database.BatchableContext, scope
* @description: execute method to send to scope to gst
*******************************************************************/ 

    global void execute(Database.BatchableContext bc, List<Sobject> scope){
        // process each batch of records with the sub query
        
        OC_GST_GSTForumIntegration GSTintegrationclass = new OC_GST_GSTForumIntegration();
        GSTintegrationclass.sendDataToGST(scope);
    }


/****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: Database.BatchableContext
* @description: finish method which updates metadata with full refresh date
*******************************************************************/
        
    global void finish(Database.BatchableContext bc){
        //Update the GST API Details metadata with latest refresh date only in the case of full data sent
        if(isFullBatchExecuted){
            GST_API_Details__c gstAPISettings = GST_API_Details__c.getInstance('OC_GST_Last_GST_Sync');
            gstAPISettings.Value__c = String.valueOfgmt(datetime.now());
            update gstAPISettings;
        }
    } 
    
/****************************************************************
* @author: Richa Gupta
* @date: 2020-05-1
* @param: SchedulableContext
* @description: schedule method to call the batch class every half an hour
*******************************************************************/
    
    global void execute(SchedulableContext SC) {
      Integer batchSize = Integer.valueOf(GST_API_Details__c.getInstance('OC_GST_ForumIndexing_BatchSize').Value__c);  
      OC_GST_SCH_BATCH_GSTForumIntegration gstForumInstance = new OC_GST_SCH_BATCH_GSTForumIntegration(); 
      Database.executebatch(gstForumInstance,batchSize); 
      
      /* Scheduled to execute every 30 min
        OC_GST_SCH_BATCH_GSTForumIntegration c1 = new OC_GST_SCH_BATCH_GSTForumIntegration ();
        String sch1 = '0 0 * ? * * *';
        System.schedule('OC_GST_GSTForumIndexing1',  sch1, c1);
        
        OC_GST_SCH_BATCH_GSTForumIntegration c2 = new OC_GST_SCH_BATCH_GSTForumIntegration ();
        String sch2 = '0 30 * ? * * *';
        System.schedule('OC_GST_GSTForumIndexing2',  sch2, c2);
      */
   }  
}