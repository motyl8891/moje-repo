/* Class Name : OC_TH_TaskTriggerHandler
* Description : This class handles all the trigger events for Task object. 
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 19 Jan 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-01-19                 IBM                   Initial Version
* 1.1        2021-02-16                 IBM                   U-2496 Users should not be able to have multiple open Answers/ remedy/ RFIs
* 1.2        2021-03-16              Subashini Arulalan       U-2585 - To Add Taskowners to caseteamember with respective roles
* 1.3 		 2021-08-19				 Aayush Sachdeva          U-3108 - Control over custom email notifications per Community User 
**/        

public with sharing class OC_TH_TaskTriggerHandler implements TriggerInterface{
    /**************************************************************************************
* @Description  This method auto-completes the case milestone 
when activity RFI-C,Answer or Remedy is
either in 'Requested' or 'Answered status 
on Task object after inserting the record into Database.                                  
* @Param        Map -Case oldMap and Map -Case newMap . 
**************************************************************************************/    
    
    public static void AfterInsert(Map<Id, SObject> newItems){
        System.debug('Pass afterInsert:-- '+newItems);
        Map<Id,Task> mapIdToNewTask = (Map<Id,Task>) newItems;
        Set<Id> setRficWhatId = new Set<Id>();
        Set<Id> setRemedyWhatId = new Set<Id>();
        Set<Id> setAnswerWhatId = new Set<Id>();
        Set<Id> setCloseRemedyWhatId = new Set<Id>();
        Set<Id> setWhatId = new  Set<Id>();
        Set<Id> setAutoCompleteCallback = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        Set<Id> setPartialViewId = new Set<Id>();
        Set<Id> setTaskId = new Set<Id>();
        DateTime completionDate = System.now();
        //Added as part of U-2585
        List<Task> TaskRecords = new List<Task>();
        
        for(Task taskWhatID : mapIdToNewTask.values()){
            System.debug('taskwhatId:--'+taskWhatID);
            // Added the if condition as part of U-2585
            if(taskWhatID.WhatId !=null){
                setWhatId.add(taskWhatID.WhatId);
            }
        }
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        
        List<Case> caseList = [SELECT ID,OC_MD_Remedy_Provided__c,RecordTypeId,OC_TH_LI_CSR__c FROM Case WHERE IsClosed != True AND ID IN: setWhatId AND RecordTypeId =: standardRecordType];
        System.debug('Case list after insert:--'+caseList);
        system.debug('  ####### case query:'+ Limits.getQueries());
        for(Case caseId : caseList){
                 setCaseId.add(caseId.Id);   
        }
        List<CaseMilestone> milestoneList = [SELECT Id,caseId,completionDate,IsCompleted FROM CaseMilestone caseMilestone WHERE caseId IN: setCaseId 
                                             AND caseMilestone.MilestoneType.Name =: OC_TH_Constants.getCallback1Milestone  AND completionDate = null];
        System.debug('Case  milestone :--'+milestoneList);
        system.debug('  ####### milestone query:'+ Limits.getQueries());
        /*fetch activity record types*/
        Id requestForInfoRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRficRecordType).getRecordTypeId();      
        Id remedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
        Id answerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
        /*Updated If() condition by Rishabh -As a part of D-4256*/
        if(OC_checkTriggerRecursive.runTaskTriggerValidationOnce()){   
            for(Task tsk : mapIdToNewTask.values()){ 
                System.debug('inside tak loop:--'+tsk);
                if(!caseList.isEmpty()){
                    for(Case cs : caseList){                          
                        if(tsk.WhatId == cs.Id){
                            /*Auto complete CALLBACK1 mileston when RFI-C activity is created with status = 'Requested'.*/
                            if(tsk.Status == OC_TH_Constants.getStatusRequested && tsk.RecordTypeId == requestForInfoRecordType ){
                                setRficWhatId.add(tsk.WhatId);  
                            }                           
                            /*Auto complete REMEDY1 mileston when remedy activity is created with status = 'Answered'.*/        
                            else if(tsk.Status == OC_TH_Constants.getStatusAnswered && tsk.RecordTypeId == remedyRecordType ){
                                setRemedyWhatId.add(tsk.WhatId);    
                            }                             
                            /*Auto complete SOLUTION1 mileston when answer activity is created with status = 'Answered'. */
                            else if(tsk.Status == OC_TH_Constants.getStatusAnswered && tsk.RecordTypeId == answerRecordType ){
                                setAnswerWhatId.add(tsk.WhatId);  
                            }      
                            /*if Remedy Provided field on case object is Null then automatically complete REMEDY1 when answer activity is created with status = 'Answered'.*/
                            if(cs.OC_MD_Remedy_Provided__c == null && tsk.Status == OC_TH_Constants.getStatusAnswered && tsk.RecordTypeId == answerRecordType){
                                setCloseRemedyWhatId.add(tsk.WhatId);     
                            }
                            /*Automatically complete CALLBACK1 milestone when Answer or Remedy activity is updated with status = 'Answered' Or 'Accepted'.*/
                            if(!milestoneList.isEmpty()){
                                for(CaseMilestone cm : milestoneList){
                                    if((tsk.RecordTypeId == answerRecordType || tsk.RecordTypeId == remedyRecordType) && tsk.Status == OC_TH_Constants.getStatusAnswered &&  cm.completionDate == null ){
                                        setAutoCompleteCallback.add(tsk.WhatId);   
                                    }     
                                }
                            }
                            
                            // U-2585 - ownerId check for task
                            if(tsk.OwnerId != null){
                                TaskRecords.add(tsk); 
                                System.debug('Task rec check :--'+TaskRecords);
                            }
                        }
                    }
                }  
                if(tsk.Status != null && tsk.RecordTypeId != null){
                    setTaskId.add(tsk.Id);
                }
            }
            // PB TO TRIGGER CHANGE
            if(!setTaskId.isEmpty()){
                OC_TH_CaseUpdateOnTaskChange.CaseUpdateOnTaskChange(setTaskId);
            }
            /*OC_TH_CaseMilestoneHelper class is used for updating milestone completion date.*/
            if (!setRficWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setRficWhatId, OC_TH_Constants.getCallback1Milestone, completionDate);  
            }
            if (!setRemedyWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setRemedyWhatId, OC_TH_Constants.getRemedy1Milestone, completionDate);
            }
            if (!setAnswerWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setAnswerWhatId, OC_TH_Constants.getSolution1Milestone, completionDate); 
            }
            if (!setCloseRemedyWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setCloseRemedyWhatId, OC_TH_Constants.getRemedy1Milestone, completionDate);
            }
            if (!setAutoCompleteCallback.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setAutoCompleteCallback, OC_TH_Constants.getCallback1Milestone, completionDate);
            }            
            /* U-2585 - Subashini Arulalan - OC_TH_CaseTeamMember class is used to add the Taskowner in caseTeamMember with respective role */
            if(!TaskRecords.isEmpty()){
                OC_TH_CaseTeamMember.taskInsertCheck(TaskRecords,setWhatId);
            }
            
        }  
        system.debug('herrrr in after insert');
    }
    /**************************************************************************************
* @Description  This method auto-completes the case milestone 
when activity RFI-C,Answer or Remedy is either
updated to 'Requested' or 'Answered status 
on Task object after updating the record into Database.                                          
* @Param        Map -Case oldMap and Map -Case newMap . 
**************************************************************************************/    
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        Map<Id,Task> mapIdToNewTask = (Map<Id,Task>) newItems;
        Map<Id,Task> mapIdToOldTask = (Map<Id,Task>) oldItems;
        DateTime completionDate = System.now();
        Set<Id> setRficWhatId = new Set<Id>();
        Set<Id> setRemedyWhatId = new Set<Id>();
        Set<Id> setRejectRemedyWhatId = new Set<Id>(); 
        Set<Id> setAnswerWhatId = new Set<Id>();
        Set<Id> setAnswerWhatIdRemedy = new Set<Id>();
        Set<Id> startAnswerWhatIdSet = new Set<Id>();
        Set<Id> startRemedyWhatIdSet = new Set<Id>();
        Set<Id> setWhatId = new  Set<Id>();
        Set<Id> setAutoCompleteCallback = new Set<Id>();
        Set<Id> setCaseId = new Set<Id>();
        Set<Id> setTaskId = new Set<Id>();
        //Added as part of U-2585
        List<Task> taskList = new List<Task>();
        Set<Id> stdcaseId = new Set<Id>();
        
        for(Task taskWhatID : mapIdToOldTask.values()){
            setWhatId.add(taskWhatID.WhatId);
        }
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        
        //Map<Id,Case> caseList = new Map<Id,Case>();
        List<Case> caseList = [SELECT ID,OC_MD_Remedy_Provided__c,RecordTypeId FROM Case WHERE IsClosed != True AND ID IN: setWhatId AND RecordTypeId =: standardRecordType];
        for(Case caseId :caseList){
            setCaseId.add(caseId.Id);
            //caseList.put(caseId.Id,CaseId);
        }
        List<CaseMilestone> milestoneList = [SELECT Id,caseId,completionDate,IsCompleted FROM CaseMilestone caseMilestone WHERE caseId IN: setCaseId 
                                             AND caseMilestone.MilestoneType.Name =: OC_TH_Constants.getCallback1Milestone  AND completionDate = null];
        
        /*Fetch record type of task object.*/
        Id getRequestForInfoRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRficRecordType).getRecordTypeId();      
        Id getRemedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
        Id getAnswerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
        
        if(OC_checkTriggerRecursive.runTicketHandlingAfterUpdateTask()){            
            for(Task updateActivity : mapIdToNewTask.values()){ 
                if(!caseList.isEmpty()){  
                    for(Case cs : caseList){ 
                        if(updateActivity.WhatId == cs.Id){
                            /*Automatically complete CALLBACK1 milestone when RFI-C activity is updated with status = 'Requested'.*/
                            if(updateActivity.Status == OC_TH_Constants.getStatusRequested && updateActivity.RecordTypeId == getRequestForInfoRecordType){
                                setRficWhatId.add(updateActivity.WhatId);
                                /* Added by Aayush Sachdeva | U-3108 | Send Email Notification to Contact based on their preferences*/
                                OC_TH_TaskTriggerHelper.sendEmailNotifications(updateActivity.Id,OC_TH_Constants.getRFICRequested);
                            }   
                            /*Automatically complete REMEDY1 milestone when remedy activity is updated with status = 'Answered' Or 'Accepted'.*/
                            if(updateActivity.RecordTypeId == getRemedyRecordType && (updateActivity.Status == OC_TH_Constants.getStatusAnswered || updateActivity.Status == OC_TH_Constants.getStatusAccepted)){
                                setRemedyWhatId.add(updateActivity.WhatId);
                                /* Added by Aayush Sachdeva | U-3108 | Send Email Notification to Contact based on their preferences*/
                                OC_TH_TaskTriggerHelper.sendEmailNotifications(updateActivity.Id,OC_TH_Constants.getRemedyProvided);

                            }      
                            /*Automatically reinstate REMEDY1 milestone when remedy activity is updated with status = 'Rejected'.*/
                            if(updateActivity.Status == OC_TH_Constants.getStatusRejected && updateActivity.RecordTypeId == getRemedyRecordType){                                   
                                setRejectRemedyWhatId.add(updateActivity.WhatId);                   
                            }
                            /*Automatically complete SOLUTION1 mileston when answer activity is updated with status = 'Answered' Or 'Accepted'.*/
                            if(updateActivity.RecordTypeId == getAnswerRecordType && (updateActivity.Status == OC_TH_Constants.getStatusAnswered || updateActivity.Status == OC_TH_Constants.getStatusAccepted)){
                                setAnswerWhatId.add(updateActivity.WhatId);
                                /* Added by Aayush Sachdeva | U-3108 | Send Email Notification to Contact based on their preferences*/
                                OC_TH_TaskTriggerHelper.sendEmailNotifications(updateActivity.Id,OC_TH_Constants.getAnswerProvided);
                            }
                            /*Automatically reinstate SOLUTION1 milestone when answer activity is updated with status = 'Rejected'.*/ 
                            if(updateActivity.Status == OC_TH_Constants.getStatusRejected && updateActivity.RecordTypeId == getAnswerRecordType){                
                                startAnswerWhatIdSet.add(updateActivity.WhatId);                  
                            }
                            /*Automatically complete REMEDY1 milestone when answer activity is updated with status = 'Answered' Or 'Accepted' if remedy provided date is NULL on case object.*/
                            if((updateActivity.Status == OC_TH_Constants.getStatusAnswered || updateActivity.Status == OC_TH_Constants.getStatusAccepted) && 
                               cs.OC_MD_Remedy_Provided__c == null && updateActivity.RecordTypeId == getAnswerRecordType){
                                   setAnswerWhatIdRemedy.add(updateActivity.WhatId);                     
                               }
                            /*Automatically reinstate REMEDY1 milestone when answer activity is updated with status = 'Rejected' and Case object remedy provided date is 'NULL'.*/
                            if(cs.OC_MD_Remedy_Provided__c == null && updateActivity.Status == OC_TH_Constants.getStatusRejected && updateActivity.RecordTypeId == getAnswerRecordType){                
                                startRemedyWhatIdSet.add(updateActivity.WhatId);                   
                            }
                            /*Automatically complete CALLBACK1 milestone when Answer or Remedy activity is updated with status = 'Answered' Or 'Accepted'.*/
                            if(!milestoneList.isEmpty()){
                                for(CaseMilestone cm : milestoneList){
                                    if((updateActivity.Status == OC_TH_Constants.getStatusAnswered || updateActivity.Status == OC_TH_Constants.getStatusAccepted) &&
                                       (updateActivity.RecordTypeId == getAnswerRecordType || updateActivity.RecordTypeId == getRemedyRecordType) && cm.completionDate == null ){
                                           setAutoCompleteCallback.add(updateActivity.WhatId);   
                                       }     
                                }
                            }
                            
                            //U-2585 - checks whether ownerId is changed or Task is closed
                            Task oldTaskValue = mapIdToOldTask.get(updateActivity.id);
                            if(updateActivity.OwnerId != null && (updateActivity.OwnerId != oldTaskValue.OwnerId || (updateActivity.Isclosed != oldTaskValue.IsClosed && updateActivity.Isclosed == true))){
                                taskList.add(updateActivity);
                                stdcaseId.add(updateActivity.WhatId);
                            }
                            if(updateActivity.Status != null && updateActivity.RecordTypeId != null && (updateActivity.Status != oldTaskValue.Status)){
                                setTaskId.add(updateActivity.Id);
                            }
                        }
                    }
                }
            } 
            // PB TO TRIGGER CHANGE
            if(!setTaskId.isEmpty()){
                OC_TH_CaseUpdateOnTaskChange.CaseUpdateOnTaskChange(setTaskId);
            }
            /*OC_TH_CaseMilestoneHelper class is used for updating milestone completion date.*/
            if (!setRficWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setRficWhatId, OC_TH_Constants.getCallback1Milestone, completionDate);
            }      
            if (!setRemedyWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setRemedyWhatId, OC_TH_Constants.getRemedy1Milestone, completionDate); 
            }      
            if (!setRejectRemedyWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.startMilestone(setRejectRemedyWhatId,OC_TH_Constants.getRemedy1Milestone);   
            }
            if (!setAnswerWhatId.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setAnswerWhatId, OC_TH_Constants.getSolution1Milestone, completionDate);
            }              
            if (!setAnswerWhatIdRemedy.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setAnswerWhatIdRemedy, OC_TH_Constants.getRemedy1Milestone, completionDate); 
            }     
            if (!startAnswerWhatIdSet.isEmpty()){           
                OC_TH_CaseMilestoneHelper.startMilestone(startAnswerWhatIdSet, OC_TH_Constants.getSolution1Milestone);
            }
            if (!startRemedyWhatIdSet.isEmpty()){
                OC_TH_CaseMilestoneHelper.startMilestone(startRemedyWhatIdSet, OC_TH_Constants.getRemedy1Milestone);
            }
            if (!setAutoCompleteCallback.isEmpty()){
                OC_TH_CaseMilestoneHelper.completeMilestone(setAutoCompleteCallback, OC_TH_Constants.getCallback1Milestone, completionDate);
            }
            /* U-2585 - Subashini Arulalan - OC_TH_CaseTeamMember class is used to add/update the Taskowner in caseTeamMember with respective role */
            if(!taskList.isEmpty()){
                OC_TH_CaseTeamMember.taskUpdateCheck(taskList, stdcaseId, mapIdToOldTask);
            }
            
        }
    }  
    /**************************************************************************************
* @Description  This method prevents user from creating duplicate task  
record for Case object.
* @Param        List -Case newItems. 
**************************************************************************************/ 
    
    public void BeforeInsert(List<SObject> newItems){
          System.debug('Pass before Insert:-- '+newItems);
           List<Task> listToNewTask = (List<Task>) newItems;
        List<Case> caseList = new List<Case>();
        Set<String> newTaskWhatId = new Set<String>();
        Set<String> newCaseId = new Set<String>();
        Set<Id> setClosedCaseId = new Set<Id>();
        set<Id> taskRecordTypeId = new Set<Id>();
        Map<Id,Task> mapRficTaskRecord = new Map<Id,Task>();
        Map<Id,Task> mapAnswerTaskRecord = new Map<Id,Task>();
        Map<Id,Task> mapRemedyTaskRecord = new Map<Id,Task>();
        Map<Id,Task> preventTaskForClosedCases = new Map<Id,Task>();
        
        /*Fetch record type of task object.*/
        Id getRequestForInfoRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRficRecordType).getRecordTypeId();      
        Id getRemedyRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getRemedyRecordType).getRecordTypeId();       
        Id getAnswerRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAnswerRecordType).getRecordTypeId();
        Id standardRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getStandardCsrRecordType).getRecordTypeId();
        taskRecordTypeId.add(getRequestForInfoRecordType);
        taskRecordTypeId.add(getAnswerRecordType);
        taskRecordTypeId.add(getRemedyRecordType);
        try{
        for(Task tsk : listToNewTask){          
            newTaskWhatId.add(tsk.WhatId);    
        }
        /*Fetch all task related cases.*/
        caseList = [SELECT Id,IsClosed FROM Case WHERE ID IN: newTaskWhatId AND RecordTypeId =: standardRecordType];
        for(Case cs : caseList){
            /*If condiditon to check closed Case.*/
            if(!cs.IsClosed){
                newCaseId.add(cs.Id);
            }
            else{
                setClosedCaseId.add(cs.Id); 
            }
        }
        for(Task tk : [SELECT Id,Status,WhatId,RecordTypeId,WhoId FROM Task WHERE WhatId IN: newCaseId AND Status IN('Requested','Open','Info provide','Answered') AND RecordTypeId IN: taskRecordTypeId]){  
            /*Map mapRficTaskRecord is used to fetch all activity RFI-C records with Requested,Open or Info provided status. */
            if((tk.Status == OC_TH_Constants.getStatusRequested || tk.status == OC_TH_Constants.getStatusOpen || tk.Status == OC_TH_Constants.getStatusInfoProvided) && tk.RecordTypeId == getRequestForInfoRecordType){
                mapRficTaskRecord.put(tk.WhatId,tk);
            }
            /*Map mapAnswerTaskRecord is used to fetch all activity Answer records with Answered or Open status. */
            else if((tk.Status == OC_TH_Constants.getStatusOpen || tk.Status == OC_TH_Constants.getStatusAnswered) && tk.RecordTypeId == getAnswerRecordType){
                mapAnswerTaskRecord.put(tk.WhatId,tk);
            }
            /*Map mapRemedyTaskRecord is used to fetch all activity Remedy records with Answered or Open status. */ 
            else if((tk.Status == OC_TH_Constants.getStatusOpen || tk.status == OC_TH_Constants.getStatusAnswered) && tk.RecordTypeId == getRemedyRecordType){
                mapRemedyTaskRecord.put(tk.WhatId,tk);
            } 
        }
        /*Map preventTaskForClosedCases is used to prevent task creation for closed cases.*/ 
        for(Task tkWhatId : [SELECT Id,Status,WhatId,RecordTypeId,WhoId FROM Task WHERE WhatId IN: setClosedCaseId]){
            preventTaskForClosedCases.put(tkWhatId.WhatId,tkWhatId);
        } 
        for(Task tskloop : listToNewTask){    
            if(!mapRficTaskRecord.isEmpty() && mapRficTaskRecord.containsKey(tskloop.WhatId)){
                if((tskloop.Status == OC_TH_Constants.getStatusRequested || tskloop.Status == OC_TH_Constants.getStatusOpen || tskloop.Status == OC_TH_Constants.getStatusInfoProvided) && tskloop.RecordTypeId == getRequestForInfoRecordType){
                    tskloop.AddError(System.Label.OC_TH_TaskDuplicateRFIC);
                }
                else if(tskloop.Status == OC_TH_Constants.getStatusInfoAccepted && tskloop.RecordTypeId == getRequestForInfoRecordType){
                    tskloop.AddError(System.Label.OC_TH_ClosedTask); 
                }
                else if((tskloop.Status == OC_TH_Constants.getStatusAccepted || tskloop.Status == OC_TH_Constants.getStatusRejected) && (tskloop.RecordTypeId == getAnswerRecordType || tskloop.RecordTypeId == getRemedyRecordType)){
                    tskloop.AddError(System.Label.OC_TH_PreventAnswerOrRemedyTaskClosure);   
                }
                else if((tskloop.Status == OC_TH_Constants.getStatusAnswered || tskloop.Status == OC_TH_Constants.getStatusOpen) && tskloop.RecordTypeId == getAnswerRecordType){
                    tskloop.AddError(System.Label.OC_TH_CloseRficToCreateAnswerTask);
                }
            }
            if(!mapAnswerTaskRecord.isEmpty() && mapAnswerTaskRecord.containsKey(tskloop.WhatId)){   
                if((tskloop.Status == OC_TH_Constants.getStatusAnswered || tskloop.Status == OC_TH_Constants.getStatusOpen) && tskloop.RecordTypeId == getAnswerRecordType){
                    tskloop.AddError(System.Label.OC_TH_TaskDuplicateAnswer);
                }
                else if(tskloop.Status == OC_TH_Constants.getStatusInfoAccepted && tskloop.RecordTypeId == getRequestForInfoRecordType){
                    tskloop.AddError(System.Label.OC_TH_ClosedTask); 
                }
                else if((tskloop.Status == OC_TH_Constants.getStatusAccepted || tskloop.Status == OC_TH_Constants.getStatusRejected) && (tskloop.RecordTypeId == getAnswerRecordType || tskloop.RecordTypeId == getRemedyRecordType)){
                    tskloop.AddError(System.Label.OC_TH_PreventAnswerOrRemedyTaskClosure);   
                }
                else if((tskloop.Status == OC_TH_Constants.getStatusOpen || tskloop.Status == OC_TH_Constants.getStatusRequested || tskloop.Status == OC_TH_Constants.getStatusInfoProvided) && tskloop.RecordTypeId == getRequestForInfoRecordType){
                    tskloop.AddError(System.Label.OC_TH_CloseAnswerToCreateRficTask);
                }     
            }
            if(!mapRemedyTaskRecord.isEmpty() && mapRemedyTaskRecord.containsKey(tskloop.WhatId)){
                if(tskloop.WhatId != Null && (tskloop.Status == OC_TH_Constants.getStatusAnswered || tskloop.Status == OC_TH_Constants.getStatusOpen) && tskloop.RecordTypeId == getRemedyRecordType){
                    tskloop.AddError(System.Label.OC_TH_TaskDuplicateRemedy);
                }
                else if((tskloop.Status == OC_TH_Constants.getStatusAccepted || tskloop.Status == OC_TH_Constants.getStatusRejected) && (tskloop.RecordTypeId == getRemedyRecordType || tskloop.RecordTypeId == getAnswerRecordType)){
                    tskloop.AddError(System.Label.OC_TH_PreventAnswerOrRemedyTaskClosure); 
                }
                else if(tskloop.Status == OC_TH_Constants.getStatusInfoAccepted && tskloop.RecordTypeId == getRequestForInfoRecordType){
                    tskloop.AddError(System.Label.OC_TH_ClosedTask); 
                }
            }
            if(!preventTaskForClosedCases.isEmpty() && preventTaskForClosedCases.containsKey(tskloop.WhatId)){
                if(tskloop.RecordTypeId == getAnswerRecordType ||tskloop.RecordTypeId == getRequestForInfoRecordType || tskloop.RecordTypeId == getRemedyRecordType){
                    tskloop.AddError(System.Label.OC_TH_PreventTaskCreationOnClosedCase);
                }
            }
            
        }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_TaskTriggerHandler,OC_TH_Constants.method_BeforeInsert,null, false, e));
        } 
        system.debug('herre!!!!!');
    }
    
    
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){}
    
    public void BeforeDelete(Map<Id, SObject> oldItems){}
    
    public void AfterDelete(Map<Id, SObject> oldItems){}
    
    public void AfterUndelete(Map<Id, SObject> oldItems){}
}