/*
* @File Name          : OC_TH_CaseUpdateOnTaskChange
* @Description        : This Class handles Case Updation based on the Creation of Task or Status update on task.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 13/08/2021 
* @Parameters         : Set<Id> taskId - Set of Task ID corresponding to which Case update has to be performed. 
*/
/*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-13               Rishabh              Initial Version - D-4256 */

public with sharing class OC_TH_CaseUpdateOnTaskChange { 
/**************************************************************************************************************************************
@ Description : This method handles Case Update Conditions picked from Task Process Main PB as moved all of case updation to this class
***************************************************************************************************************************************/
    public static void CaseUpdateOnTaskChange(set<Id> taskId){
        try{
            Set<Id> setWhatId = new Set<Id>();
            List<Case> updateCaseList = new List<Case>();
            Map<Id,Task> mapWhatIdAndTask = new Map<Id,Task>();
            Id standardRecordType =  OC_TH_Constants.recordType_StandardCSR;
            Set<Id> taskRecordTypeIdSet = new Set<Id>{OC_TH_Constants.getTaskRequestForInfoRecordType,OC_TH_Constants.getTaskAnswerRecordType,OC_TH_Constants.getTaskRemedyRecordType};
                
            for(Task taskRec : [SELECT Id,Status,WhatId,RecordTypeId,RecordType.developerName FROM Task WHERE
                                Id =: taskId AND Status != null AND RecordTypeId IN: taskRecordTypeIdSet])
            {
                if(taskRec.WhatId !=null){
                    setWhatId.add(taskRec.WhatId);
                    mapWhatIdAndTask.put(taskRec.WhatId,taskRec);
                }
            }
            
            for(Case caseRec : [SELECT ID,Status FROM Case WHERE ID IN: setWhatId AND RecordTypeId =: standardRecordType]){
                if(!mapWhatIdAndTask.isEmpty() && mapWhatIdAndTask.containsKey(caseRec.Id)){
                    Task taskRec = mapWhatIdAndTask.get(caseRec.Id);
                    if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getRficRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusRequested)){
                        caseRec.IsStopped = OC_TH_Constants.activeTrue;
                        caseRec.OC_TH_Waiting_on__c = OC_TH_Constants.getWaitingOnCustomer;
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getAnswerRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusAnswered)){
                        caseRec.IsStopped = OC_TH_Constants.activeTrue; 
                        caseRec.OC_TH_Waiting_on__c = OC_TH_Constants.getWaitingOnCustomer;
                        caseRec.OC_TH_Answered_Finished__c = OC_TH_Constants.getStatusAnswered;
                        caseRec.Status = OC_TH_Constants.getStatusAnswered;
                        caseRec.OC_MD_Answer_Provided__c = datetime.now();//Saradhambal
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getRemedyRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusAnswered)){
                        caseRec.OC_MD_Remedy_Provided__c = datetime.now();
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getAnswerRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusAccepted)){
                        caseRec.IsStopped = OC_TH_Constants.activeTrue; 
                        caseRec.OC_TH_Waiting_on__c = OC_TH_Constants.getStringNull;
                        caseRec.OC_TH_Task_Statuses__c = OC_TH_Constants.getTaskStatusAnswerAccepted;
                        caseRec.OC_TH_TaskId__c = taskRec.Id;
                        caseRec.Status = OC_TH_Constants.getStatusFinished;
                        caseRec.OC_TH_Answered_Finished__c = OC_TH_Constants.getStatusFinished;
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getRficRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusInfoProvided) && taskRec.WhatId != Null){
                        caseRec.IsStopped = OC_TH_Constants.activeFalse; 
                        caseRec.OC_TH_Waiting_on__c = OC_TH_Constants.getStringNull;
                        caseRec.OC_TH_Task_Statuses__c = OC_TH_Constants.getTaskStatusRFICInfoProvided; 
                        caseRec.OC_TH_TaskId__c = taskRec.Id;
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getAnswerRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusRejected)){
                        caseRec.IsStopped = OC_TH_Constants.activeFalse; 
                        caseRec.OC_TH_Waiting_on__c = OC_TH_Constants.getStringNull;
                        caseRec.OC_TH_Task_Statuses__c = OC_TH_Constants.getAnswerRejected;
                        caseRec.Status = OC_TH_Constants.getStatusAnalysis;
                        caseRec.OC_TH_TaskId__c = taskRec.Id;
                        caseRec.OC_MD_Answer_Provided__c = OC_TH_Constants.getDateTimeNull;//Saradhambal
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getRemedyRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusAccepted)){
                        caseRec.OC_TH_Task_Statuses__c = OC_TH_Constants.getTaskStatusRemedyAcepted;
                        caseRec.OC_MD_Remedy_Accepted__c = datetime.now();
                        caseRec.OC_TH_TaskId__c = taskRec.Id;
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getRemedyRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusRejected)){
                        caseRec.OC_TH_Task_Statuses__c = OC_TH_Constants.getTaskStatusRemedyRejected;
                        caseRec.OC_MD_Remedy_Provided__c = OC_TH_Constants.getDateTimeNull;
                        caseRec.OC_TH_TaskId__c = taskRec.Id;
                        updateCaseList.add(caseRec);
                    }
                    else if(taskRec.RecordType.developerName.equalsIgnoreCase(OC_TH_Constants.getRficRecordType) && taskRec.Status.equalsIgnoreCase(OC_TH_Constants.getStatusInfoAccepted)){
                        caseRec.IsStopped = OC_TH_Constants.activeFalse;
                        caseRec.OC_TH_Waiting_on__c = OC_TH_Constants.getStringNull;
                        updateCaseList.add(caseRec);
                    }
                }
            }
            if(!updateCaseList.isEmpty()){
                //Database.update(updateCaseList, false);
                update updateCaseList;
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.apexClass_OC_TH_CaseUpdateOnTaskChange,OC_TH_Constants.method_CaseUpdateOnTaskChange,null, false, e));
        }
    }
}