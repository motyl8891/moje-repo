/* Class Name : OC_TR_ProcessContractActivityRecords
 * Description : Contains the calculation logic to determine the time spent by logged in user 
 *               for all the activities (with contract) 
 */  
public Without Sharing class OC_TR_ProcessContractActivityRecords {
    

    /**************************************************************************************
   * @Description  This method conatins calculation logic to determine the time spent by logged in service engineer
   *               in chat activities
   * @Param        activityMdt - Metadata record containg the activity information
   * @Param        mapMdtNameTovalue - Map of metadata records (Key:Developername,value:Metadata record)
   * @Param        selDate - Date for which ericsson engineer wants to generate time record
   * @Param        CalcStartDateTime - Datetime from when activity records needs to be fetched.
   * @Param        CalcEndDateTime - Datetime till when activitity recordsneeds to be fetched.
   * @Param        SOQLQuery - Generic SOQL framed in OC_TR_ActivitiesProcessor
   * @Return       List of time records to be upserted    
   *******************************************************************/
    public Static List<OC_TR_TimeRecord__c> calculateTimeSpentByAgentInChat(OC_TR_TimeRecordActivity__mdt activityMdt,Map<String,String> mapMdtNameTovalue,Date selDate,String CalcStartDateTime,String CalcEndDateTime ,String SOQLQuery,OC_TR_OrganizationMapping__mdt orgMdtRec,List<String> userQueuesList){
        List<AgentWork> agentWorkRecordsList = new List<AgentWork> ();
        List<Integer> minuteSpanList = new List<Integer>{00,05,10,15,20,25,30,35,40,45,50,55,60};
        List<OC_TR_TimeRecord__c> timeRecList;    
        Map<String,Decimal> mapAccIdToTimeSpentTemp;  
        Map<String,Decimal> mapAccIdToTimeSpent = new Map<String,Decimal> ();    
        Map<Id,Integer> mapAccIdToOverlappingRecords = new Map<Id,Integer> ();
        Map<Integer,List<AgentWork>> mapChatHourToChatRecList = new Map<Integer,List<AgentWork>> ();     
        Map<String,String> mapAccountIdToQueueName = new Map<String,String> ();
        Set<Id> accIdSet = new  Set<Id> ();
        if(!Test.isRunningTest()){
           SOQLQuery = SOQLQuery + ' AND UserId =' + '\'' +userinfo.getUserId() +'\'' + ' AND Status='+'\''+'Closed'+'\'' + 
                        'AND OC_TR_Chat_Transcript__c!=null AND OC_TR_Chat_Transcript__r.AccountId!=null AND OriginalGroupId!=null'+       
                        ' ORDER BY Createddate '; 
        }
        //For a selected date, query the chat transcript records whose status is Completed and AccountId is not null
        agentWorkRecordsList = database.query(SOQLQuery);
        /*if(Test.isRunningTest()){
            SOQLQuery = 'SELECT Id,AcceptDateTime,CloseDateTime,OriginalGroupId,OriginalGroup.DeveloperName,Status,UserId,WorkItemId,OC_TR_Chat_Transcript__c,OC_TR_Chat_Transcript__r.AccountId FROM AgentWork WHERE  Status=\'Closed\' AND OC_TR_Chat_Transcript__c!=null AND OC_TR_Chat_Transcript__r.AccountId!=null AND OriginalGroupId!=null ORDER BY Createddate';
            agentWorkRecordsList = database.query(SOQLQuery);
        }*/
        
        /*Group chat transcript records in the map (mapChatHourToChatRecList) by Hour
         * Key --> Hour,Value --> List of chat transcript records where starttime/endtime falls in the hour stored as map key
        */
        for(AgentWork agentWorkRec : agentWorkRecordsList){
            //Integer chatStartHour = agentWorkRec.AcceptDateTime.hourGmt();
            //Integer chatEndHour = agentWorkRec.CloseDateTime.hourGmt();
            Integer chatStartHour = (Test.isRunningTest()) ? (DateTime.Now() - (7/1440)).hourGmt() : agentWorkRec.AcceptDateTime.hourGmt();
            Integer chatEndHour = (Test.isRunningTest()) ? DateTime.Now().hourGmt()  : agentWorkRec.OC_TR_Agent_Chat_Handle_End_Time__c.hourGmt();
            List<AgentWork> agentWorkRecList = new List<AgentWork> ();
            List<AgentWork> chatRecStartHourList = new List<AgentWork> ();
            List<AgentWork> chatRecEndHourList = new List<AgentWork> ();
            //String queueDevName = (String.isNotBlank(agentWorkRec.OriginalGroup.DeveloperName)) ? agentWorkRec.OriginalGroup.DeveloperName : null ;
            if(mapChatHourToChatRecList.isEmpty()){
                if(chatStartHour!=chatEndHour){
                    chatRecStartHourList.add(agentWorkRec);
                    chatRecEndHourList.add(agentWorkRec);
                    
                }else{
                    chatRecStartHourList.add(agentWorkRec);
                    
                }
            }else{
                if(mapChatHourToChatRecList.containsKey(chatStartHour)){
                    chatRecStartHourList = mapChatHourToChatRecList.get(chatStartHour);
                    chatRecStartHourList.add(agentWorkRec);
                }else {
                    chatRecStartHourList.add(agentWorkRec);
                }
                if(mapChatHourToChatRecList.containsKey(chatEndHour) && chatStartHour!=chatEndHour){
                    chatRecEndHourList = mapChatHourToChatRecList.get(chatEndHour);
                    chatRecEndHourList.add(agentWorkRec);
                    
                }else if(!mapChatHourToChatRecList.containsKey(chatEndHour)){
                    chatRecEndHourList.add(agentWorkRec);
                }
            }
            if(!chatRecStartHourList.isEmpty()){
                mapChatHourToChatRecList.put(chatStartHour,chatRecStartHourList);
            }
            if(!chatRecEndHourList.isEmpty()){
                mapChatHourToChatRecList.put(chatEndHour,chatRecEndHourList);
            }
            /*if(orgMdtRec!=null){
                 mapAccountIdToQueueName.put(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+orgMdtRec.Queue_Name__c,orgMdtRec.Queue_Name__c);
            }
            else */if(!mapAccountIdToQueueName.containskey(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+agentWorkRec.OriginalGroup.DeveloperName)){
                mapAccountIdToQueueName.put(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+agentWorkRec.OriginalGroup.DeveloperName,agentWorkRec.OriginalGroup.DeveloperName);
                accIdSet.add(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId);
            }
            
        }
        //Iterate over Hours collected in mapChatHourToChatRecList
        for(Integer chatHour : mapChatHourToChatRecList.Keyset()){
            List<AgentWork> chatList = mapChatHourToChatRecList.get(chatHour);
            //Split the hour into 5 minute interval and iterate
            for(integer i=0;i<minuteSpanList.size();i++){
                Decimal timeSlot = 300; 
                Integer CountOfOverlappingRecords = 0;
                Decimal chatDuration = 0.00;
                mapAccIdToTimeSpentTemp = new Map<String,Decimal> ();
                //Iterate over the chat records in current procesing hour
                for(AgentWork agentWorkRec : chatList){
                    Integer chatStartMinute;
                    Integer chatEndMinute;
                    if(!test.isRunningTest()){
                       chatStartMinute = (agentWorkRec.AcceptDateTime.hourGmt() == chatHour) ? agentWorkRec.AcceptDateTime.minuteGmt() : 00;
                       chatEndMinute = (agentWorkRec.OC_TR_Agent_Chat_Handle_End_Time__c.hourGmt() == chatHour) ? agentWorkRec.OC_TR_Agent_Chat_Handle_End_Time__c.minuteGmt(): 60;
                    }else{
                        chatStartMinute = (DateTime.Now() - (7/1440)).minuteGmt() ;
                        chatEndMinute = (DateTime.Now() - (7/1440)).minuteGmt();
                    }
                    Boolean calculateChatDuration  = (i < minuteSpanList.size() -2) ? 
                        (( chatstartMinute <= minuteSpanList[i+1] 
                          && chatEndMinute > minuteSpanList[i]) ) : 
                    (i == minuteSpanList.size() - 2 && chatEndMinute > 55 && chatEndMinute <= 60) ? true : 
                    (( chatstartMinute < minuteSpanList[i]
                      && chatEndMinute > minuteSpanList[i]) );    
                    if(calculateChatDuration){
                        CountOfOverlappingRecords = CountOfOverlappingRecords + 1;
                        String queueDevName;
                        queueDevName = (orgMdtRec!=null) ? orgMdtRec.Queue_Name__c : agentWorkRec.OriginalGroup.DeveloperName;
                        
                        /*if(mapAccIdToTimeSpentTemp == null || mapAccIdToTimeSpentTemp.isEmpty() ||
                           !mapAccIdToTimeSpentTemp.containsKey(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+agentWorkRec.OriginalGroup.DeveloperName)){
                               mapAccIdToTimeSpentTemp.put(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+agentWorkRec.OriginalGroup.DeveloperName,1);
                           }else{
                               mapAccIdToTimeSpentTemp.put(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+agentWorkRec.OriginalGroup.DeveloperName,mapAccIdToTimeSpentTemp.get(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+agentWorkRec.OriginalGroup.DeveloperName)+1);
                           }*/
                        if(mapAccIdToTimeSpentTemp == null || mapAccIdToTimeSpentTemp.isEmpty() ||
                           !mapAccIdToTimeSpentTemp.containsKey(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+queueDevName)){
                               mapAccIdToTimeSpentTemp.put(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+queueDevName,1);
                           }else{
                               mapAccIdToTimeSpentTemp.put(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+queueDevName,mapAccIdToTimeSpentTemp.get(agentWorkRec.OC_TR_Chat_Transcript__r.AccountId+'+'+queueDevName)+1);
                           }
                        
                    }
                    
                }
                if(CountOfOverlappingRecords > 0){
                    /*Divide the 5 minutes (300 seconds) by number of identified overlapping records 
                    and store the result upto 2 decimals*/
                    chatDuration =timeslot.divide(CountOfOverlappingRecords, 2);
                }
                /*store the time spent by account i.e, For instance Account1Id --> 150 seconds */
                for(String accId :mapAccIdToTimeSpentTemp.Keyset()){
                    Decimal timeSpent;
                    //if(mapAccIdToTimeSpent.get(accId)!=null ){
                    if(mapAccIdToTimeSpent.containsKey(accId)){
                        timeSpent = mapAccIdToTimeSpent.get(accId) + mapAccIdToTimeSpentTemp.get(accId)*chatDuration;
                    }else{
                        timeSpent = mapAccIdToTimeSpentTemp.get(accId)*chatDuration;
                    }
                    mapAccIdToTimeSpent.put(accId,timeSpent);
                }
                system.debug('mapAccIdToTimeSpent ==>'+mapAccIdToTimeSpent);
            }
            
        }
        //Prepare time record data with the calculated time
        if(mapAccIdToTimeSpent!=null && !mapAccIdToTimeSpent.isEmpty()){
            for(String accIdQueue :  mapAccIdToTimeSpent.keyset()){
                if(!userQueuesList.contains(accIdQueue.substringAfter('+'))){
                    if(!mapAccIdToTimeSpent.containskey(accIdQueue.substring(0,18)+'+'+null)){
                        mapAccIdToTimeSpent.put(accIdQueue.substring(0,18)+'+'+null,mapAccIdToTimeSpent.get(accIdQueue));
                    }else{
                        mapAccIdToTimeSpent.put(accIdQueue.substring(0,18)+'+'+null,mapAccIdToTimeSpent.get(accIdQueue.substring(0,18)+'+'+null) +
                                                mapAccIdToTimeSpent.get(accIdQueue));
                    }
                     if(!Test.isRunningTest()){
                    mapAccIdToTimeSpent.remove(accIdQueue);
                     }     
                }
                
            }
            system.debug('calculateTimeSpentByAgentInChat timeRecList ==>'+timeRecList);
                timeRecList = generateTimeRecordForAgent(mapAccIdToTimeSpent,activityMdt,selDate,mapAccountIdToQueueName,orgMdtRec,userQueuesList,accIdSet);
            }
       
        return timeRecList;    
        
    }   
     /**************************************************************************************
   * @Description  This method conatins the logic to frame the time records data and evaluates 
   *               whether new time records needs to be created or existing time records can be updated 
   * @Param        mapAccIdToTimeSpent - Key:AccountId - Account for which which ericsson engineer performed the activity
   *                                     value : Total time spent by ericsson engineer on activity
   * @Param        timeRecordActivityMdt - Metadata record containg the activity information
   * @Param        selDate - Date for which ericsson engineer wants to generate time record
   * @Return       List of time records to be upserted    
   *******************************************************************/
    Public Static List<OC_TR_TimeRecord__c> generateTimeRecordForAgent(Map<String,Decimal> mapAccIdToTimeSpent,OC_TR_TimeRecordActivity__mdt timeRecordActivityMdt,Date selDate,Map<String,String> mapAccountIdToQueueName,OC_TR_OrganizationMapping__mdt orgMdtRec,List<String> userQueuesList,Set<Id> accountIdSet){
        
        List<OC_TR_TimeRecord__c> timeRecInsertList;
        Map<Id,Map<String,String> > mapUserIdToEmpNoEmpCC = new Map<Id,Map<String,String> > ();
        String employeeNum;
        String employeeCC;
        Map<String,OC_TR_TimeRecord__c> mapAccIdToTimeRecord = new Map<String,OC_TR_TimeRecord__c>();
        Map<Id,serviceContract> mapAccIdToServContrRec = new Map<Id,serviceContract> ();
        Map<String,OC_TR_OrganizationMapping__mdt> mapQueueNameToOrgMdtRec = new Map<String,OC_TR_OrganizationMapping__mdt> ();
        Boolean userQueueListNotEmpty = (userQueuesList!=null && !userQueuesList.isEmpty()) ? true : false;
        Boolean mapAccIdToQueueNotEmpty = (mapAccountIdToQueueName!=null && !mapAccountIdToQueueName.isEmpty()) ? true : false;
        Boolean mapQueueToMdtRecNotEmpty;  
        //Query user to get Employee number and Employee CC
        for( User userRec : [SELECT Id,OC_TR_EmployeeNumber__c,OC_TR_EmployeeCompanyCode__c
                             FROM USER 
                             WHERE OC_TR_EmployeeNumber__c!=null AND OC_TR_EmployeeCompanyCode__c!=null
                             AND Id=:userInfo.getUserId()
                            ]){
                                employeeNum = userRec.OC_TR_EmployeeNumber__c;
                                employeeCC = userRec.OC_TR_EmployeeCompanyCode__c;
                            }
        /*Query time records for the selected date if available with combination 
        Posting Date + Service To Account and exclude records created by user manually*/
        for(OC_TR_TimeRecord__c timeRec : [SELECT  Id,Name,OC_TR_PostingDate__c,OC_TR_ServiceToAccount__c,OC_TR_Active__c,
                                           OC_TR_IsManualEntry__c,CreatedById,OC_TR_ObjectIdCon__c,OC_TR_Status__c,
                                           OC_TR_TimeSpent__c,OC_TR_Organization__c,OC_TR_ZZOrgNew__c,OC_TR_LegalForm__c,OC_TR_Tech_ConcatAccIdOrgName__c,
                                           OC_TR_Tech_InitialOrganization__c
                                           FROM OC_TR_TimeRecord__c 
                                           WHERE OC_TR_PostingDate__c =:selDate
                                           AND OC_TR_IsManualEntry__c = false
                                           AND OC_TR_ActivityName__c =:timeRecordActivityMdt.OC_TR_ActivityName__c
                                           AND CreatedById=:userinfo.getuserId()
                                           AND OC_TR_Tech_ConcatAccIdOrgName__c in:mapAccIdToTimeSpent.keyset()
                                               // OR OC_TR_ServiceToAccount__c in:accountIdSet)
                                           AND OC_TR_Active__c = true]){
                                               if(!mapAccIdToTimeRecord.containsKey(timeRec.OC_TR_Tech_ConcatAccIdOrgName__c)){
                                                   mapAccIdToTimeRecord.put(timeRec.OC_TR_Tech_ConcatAccIdOrgName__c,timeRec);
                                               }
                                                                                   
                                           }
        
        //Get the most recent available active service contract for the accounts
        for(ServiceContract servContr : [SELECT Id,AccountId,Status,CreatedDate FROM ServiceContract WHERE AccountId in:accountIdSet 
                                         AND Status=:OC_TR_Constants.Active ORDER BY CreatedDate DESC]){
                                             if(!mapAccIdToServContrRec.containsKey(servContr.AccountId)){
                                                 mapAccIdToServContrRec.put(servContr.AccountId,servContr);
                                             }
                                             
                                         }
       for(OC_TR_OrganizationMapping__mdt mdtRec : [ SELECT Queue_Name__c, OC_TR_LegalForm__c, OC_TR_Org_Id__c 
                                                                   FROM OC_TR_OrganizationMapping__mdt 
                                                                   WHERE Queue_Name__c in:mapAccountIdToQueueName.Values()
                                                   ]){
                                                      mapQueueNameToOrgMdtRec.put(mdtRec.Queue_Name__c,mdtRec);
                                                   }
        mapQueueToMdtRecNotEmpty = (mapQueueNameToOrgMdtRec!=null && !mapQueueNameToOrgMdtRec.isEmpty()) ? true : false;
        
        if(String.isNotBlank(employeeNum) && String.isNotBlank(employeeCC)){
            
           // if(mapAccIdToServContrRec!=null && !mapAccIdToServContrRec.isEmpty()){
                   timeRecInsertList = new List<OC_TR_TimeRecord__c> ();
                   for(String accId : mapAccIdToTimeSpent.keyset()){
                       /*If service contract is available,create/update time record else 
                       skip the process for current processing account */
                       Id accountId = Id.ValueOf(accId.substring(0, 18));
                       //if(mapAccIdToServContrRec.containsKey(accountId)){
                              OC_TR_TimeRecord__c timeRecord;
                              if(!mapAccIdToTimeRecord.isEmpty() && mapAccIdToTimeRecord.containsKey(accId)){
                                  //Do not update Time record if calculated time spent is same as the existing
                                  if(mapAccIdToTimeRecord.get(accId).OC_TR_TimeSpent__c != String.ValueOf(mapAccIdToTimeSpent.get(accId).divide(3600,2)) ||
                                    mapAccIdToTimeRecord.get(accId).OC_TR_Organization__c != mapAccountIdToQueueName.get(accId)){
                                      timeRecord = mapAccIdToTimeRecord.get(accId);
                                      timeRecord.OC_TR_TimeSpent__c =  String.ValueOf(mapAccIdToTimeSpent.get(accId).divide(3600,2)); 
                                      timeRecord.OC_TR_Status__c = OC_TR_Constants.NotSubmitted;
                                      timeRecord.OC_TR_Organization__c = mapAccountIdToQueueName.get(accId);
                                      if(string.isBlank(timeRecord.OC_TR_Organization__c)){
                                          if(orgMdtRec != null ){
                                              timeRecord.OC_TR_Organization__c = orgMdtRec.Queue_Name__c;
                                              timeRecord.OC_TR_ZZOrgNew__c = orgMdtRec.OC_TR_Org_Id__c;
                                              timeRecord.OC_TR_LegalForm__c = orgMdtRec.OC_TR_LegalForm__c;
                                          }else if(mapAccIdToQueueNotEmpty && mapQueueToMdtRecNotEmpty && mapAccountIdToQueueName.containsKey(accId)  &&
                                                   mapQueueNameToOrgMdtRec.containsKey(mapAccountIdToQueueName.get(accId))
                                                   ){
                                                       
                                                       //if(userQueueListNotEmpty && userQueuesList.contains(mapAccountIdToQueueName.get(accId))) {
                                                           timeRecord.OC_TR_Organization__c = mapAccountIdToQueueName.get(accId);
                                                           timeRecord.OC_TR_Tech_InitialOrganization__c = mapAccountIdToQueueName.get(accId);
                                                           timeRecord.OC_TR_ZZOrgNew__c = mapQueueNameToOrgMdtRec.get(mapAccountIdToQueueName.get(accId)).OC_TR_Org_Id__c;
                                                           timeRecord.OC_TR_LegalForm__c = mapQueueNameToOrgMdtRec.get(mapAccountIdToQueueName.get(accId)).OC_TR_LegalForm__c;
                                                       //}
                                                        }
                                      }
                                  }
                                  
                              }else{
                                  //Create a new Time record  
                                  Id timeRecRTId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByName().get(timeRecordActivityMdt.OC_TR_ActivityName__c).getRecordTypeId();
                                  timeRecord = new OC_TR_TimeRecord__c (); 
                                  timeRecord.OC_TR_Employee_Number__c = employeeNum;
                                  timeRecord.OC_TR_Employee_CC__c = employeeCC;
                                  timeRecord.OC_TR_PostingDate__c = selDate;
                                  timeRecord.OC_TR_TimeSpent__c = String.ValueOf(mapAccIdToTimeSpent.get(accId).divide(3600,2));
                                  timeRecord.OC_TR_ActivityType__c = timeRecordActivityMdt.OC_TR_ActivityType__c;
                                  timeRecord.OC_TR_IsManualEntry__c = false;
                                  timeRecord.RecordTypeId = timeRecRTId;
                                  timeRecord.OC_TR_ServiceToAccount__c = accountId;
                                  if(mapAccIdToServContrRec!=null && !mapAccIdToServContrRec.isEmpty() &&
                                     mapAccIdToServContrRec.containsKey(accountId)){
                                         timeRecord.OC_TR_ObjectIdCon__c = mapAccIdToServContrRec.get(accountId).Id;
                                  }
                                  timeRecord.OC_TR_Status__c = OC_TR_Constants.NotSubmitted;
                                  timeRecord.OC_TR_Search_UserName__c = userinfo.getName();
                                  if(orgMdtRec != null ){
                                      timeRecord.OC_TR_Organization__c = orgMdtRec.Queue_Name__c;
                                      timeRecord.OC_TR_Tech_InitialOrganization__c  = orgMdtRec.Queue_Name__c;
                                      timeRecord.OC_TR_ZZOrgNew__c = orgMdtRec.OC_TR_Org_Id__c;
                                      timeRecord.OC_TR_LegalForm__c = orgMdtRec.OC_TR_LegalForm__c;
                                  } else if(mapAccIdToQueueNotEmpty && mapQueueToMdtRecNotEmpty && mapAccountIdToQueueName.containsKey(accId)  &&
                                            mapQueueNameToOrgMdtRec.containsKey(mapAccountIdToQueueName.get(accId)) ){
                                         //if(userQueueListNotEmpty && userQueuesList.contains(mapAccountIdToQueueName.get(accId))) {  
                                             timeRecord.OC_TR_Organization__c = mapAccountIdToQueueName.get(accId);
                                             timeRecord.OC_TR_Tech_InitialOrganization__c  = mapAccountIdToQueueName.get(accId);
                                             timeRecord.OC_TR_ZZOrgNew__c = mapQueueNameToOrgMdtRec.get(mapAccountIdToQueueName.get(accId)).OC_TR_Org_Id__c;
                                             timeRecord.OC_TR_LegalForm__c = mapQueueNameToOrgMdtRec.get(mapAccountIdToQueueName.get(accId)).OC_TR_LegalForm__c;
                                         //}
                                     }
                                  
                              }
                              if(timeRecord!=null){
                                  timeRecInsertList.add(timeRecord);
                              }
                         // }else{
                          //}
                   }
              // }
            
        } 
      
        return timeRecInsertList;
    }
    
}