/* Class Name : OC_TR_QueueQuickActionController
* Description : This class is used to Fetch/Update the Queue details on OC_TR_TimeRecord__c object. 
*/ 
public Without Sharing class OC_TR_QueueQuickActionController {
    /**************************************************************************************
* @Description  This method will update the queuename on OC_TR_TimeRecord__c object based  
on the supplied valid OC_TR_TimeRecord__c Id and QueueName.
* @Param		ID - OC_TR_TimeRecord__c Id , String - queueName String, String - ChatqueueName String 
* @Example     
* OC_TR_QueueQuickActionController.updateQueueNameOnTimeRecord(XXXXXXXXXXXXXXX ,'QueueName').
**************************************************************************************/
    @AuraEnabled
    public  Static void updateQueueNameOnTimeRecord(Id timeRecId,String selQueue,String chatselQueue,List<OC_TR_TimeRecord__c> timeRecList){
        try{
            List<OC_TR_TimeRecord__c> timeRecUpdateList = new List<OC_TR_TimeRecord__c> ();
            List<OC_TR_OrganizationMapping__mdt> orgMdtRec = new List<OC_TR_OrganizationMapping__mdt> ();
            List<OC_TR_OrganizationMapping__mdt> chatOrgMdtRec = new List<OC_TR_OrganizationMapping__mdt> (); //Added for U-2886
            Boolean chatOrgMdtNotEmpty = false;
            Boolean otherOrgMdtNotEmpty = false;
            if(!String.IsBlank(selQueue)){
                /*orgMdtRec  = [ SELECT Queue_Name__c, OC_TR_LegalForm__c, OC_TR_Org_Id__c 
FROM OC_TR_OrganizationMapping__mdt 
WHERE Queue_Name__c =:selQueue];*/
                orgMdtRec = getOrgDetailsFromMdt(selQueue);
                chatOrgMdtRec = getOrgDetailsFromMdt(chatselQueue); //Added for U-2886
                chatOrgMdtNotEmpty = (chatOrgMdtRec!=null && !chatOrgMdtRec.isEmpty())? true:false;
                otherOrgMdtNotEmpty = (orgMdtRec!=null && !orgMdtRec.isEmpty())? true:false;
                if(timeRecId!=null){
                    OC_TR_TimeRecord__c tr = [select id,OC_TR_ZZOrgNew__c,OC_TR_Organization__c from OC_TR_TimeRecord__c where id=:timeRecId LIMIT 1];
                    if(orgMdtRec!=null && !orgMdtRec.isEmpty()){
                        tr.OC_TR_ZZOrgNew__c = orgMdtRec[0].OC_TR_Org_Id__c;
                        tr.OC_TR_Organization__c = selQueue;
                        tr.OC_TR_LegalForm__c = orgMdtRec[0].OC_TR_LegalForm__c;
                        timeRecUpdateList.add(tr);
                        
                    }else{
                        tr.OC_TR_ZZOrgNew__c = null;
                        tr.OC_TR_Organization__c = selQueue;
                        timeRecUpdateList.add(tr);
                    }    
                }    
                else if(timeRecList!=null && !timeRecList.isEmpty()){
                    if(chatOrgMdtNotEmpty || otherOrgMdtNotEmpty){
                        for(OC_TR_TimeRecord__c timeRecord : timeRecList){
                            //Added if else condition for U-2886
                            if(timeRecord.OC_TR_ActivityName__c.equalsIgnoreCase(OC_TR_Constants.Chat) && String.isNotBlank(chatselQueue) && chatOrgMdtNotEmpty){
                                timeRecord.OC_TR_ZZOrgNew__c = chatOrgMdtRec[0].OC_TR_Org_Id__c;
                                timeRecord.OC_TR_Organization__c = chatselQueue;
                                timeRecord.OC_TR_LegalForm__c = chatOrgMdtRec[0].OC_TR_LegalForm__c;
                                timeRecUpdateList.add(timeRecord);
                            }
                            else if(otherOrgMdtNotEmpty){
                                timeRecord.OC_TR_ZZOrgNew__c = orgMdtRec[0].OC_TR_Org_Id__c;
                                timeRecord.OC_TR_Organization__c = selQueue;
                                timeRecord.OC_TR_LegalForm__c = orgMdtRec[0].OC_TR_LegalForm__c;
                                timeRecUpdateList.add(timeRecord);
                            }
                        }
                    }else{
                        //timeRecList[0].addError(Label.OC_TR_ErrorMsg_WhenSelectedOrgUpdateOnTimeRecordFails);
                        timeRecList[0].OC_TR_Organization__c = selQueue;
                        timeRecList[0].OC_TR_ZZOrgNew__c = null;
                        timeRecUpdateList.add(timeRecList[0]);
                    }        
                } 
            }
            update timeRecUpdateList;
        }
        catch(DmlException dmlExcp){       
            throw new AuraHandledException (dmlExcp.getMessage());  
        }  
        catch(Exception excp){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_QUEUEQUICKACTIONCONTROLLER,OC_TR_Constants.UPDATEQUEUENAMEONTIMERECORD,null, false, excp));
            throw new AuraHandledException (excp.getMessage());
        }        
    }
    /**************************************************************************************
* @Description  This method will fetch all the queuenames which the user is part of 
based on the supplied valid OC_TR_TimeRecord__c Id .
* @Param		List<ID> - OC_TR_TimeRecord__c Id - List of TimeRecord Id's
* @Return       Map of ActivityType as String and QueueNames as List of Strings
* @Example     
* OC_TR_QueueQuickActionController.fetchQueuerecords(XXXXXXXXXXXXXXX).
**************************************************************************************/
    @AuraEnabled
    public  Static Map<String,List<String>> fetchQueuerecords(List<Id> timeRecId,Id userRecId, Id roleId){
        Set<Id> groupIdSet = new Set<Id>();
        Set<Id> currentUserGroupIds = new Set<Id>();
        List<String> QueueNamesList = new List<String>();
        List<String> finalQueueList = new List<String>();
        //Added for U-2886:Start
        List<String> chatActivityList = new List<String>();  
        List<String> otherActivityList = new List<String>();
        Map<String,List<String>> chatActivityMap = new Map<String,List<String>>();
        Map<String,List<String>> otherActivityMap = new Map<String,List<String>>();
        Map<String,List<String>> finalQueueMap = new Map<String,List<String>>();
        Boolean addChatQueues = false;
        Boolean addNonChatQueues = false;
        //U-2886:End
        Id userId = (timeRecId!=null) ? userInfo.getUserId() : userRecId;
        Id userRoleId = (timeRecId!=null) ? userInfo.getUserRoleId() : roleId;
        String groupSoqlQuery;  
        try{
            Id allInternalUsersGrpId = [SELECT Id,Developername,Type FROM Group where developername='AllInternalUsers' LIMIT 1].id;
            currentUserGroupIds.add(allInternalUsersGrpId);
            groupSoqlQuery = 'SELECT Id,name,RelatedId,Type FROM Group WHERE Type='+'\''+OC_TR_Constants.queue+'\'';
            if(userRoleId != null){
                groupSoqlQuery +=  ' OR RelatedId='+'\''+userRoleId+'\'';
            }
            for(Groupmember grpMem : [select Id, UserorGroupId,Group.Name,group.relatedId 
                                      FROM GroupMember 
                                      WHERE UserorGroupId=:userId
                                      OR UserorGroupId=:userRoleId
                                     ]){
                                         currentUserGroupIds.add(grpMem.GroupId);
                                     }
            
            for(Group grp : database.query(groupSoqlQuery) ){
                if(grp.Type.equalsignoreCase('Queue')){
                    groupIdSet.add(grp.id); 
                }else if(!grp.Type.equalsignoreCase('Regular') || grp.RelatedId == userRoleId){
                    currentUserGroupIds.add(grp.Id);
                }              
            }
            
            for(Groupmember grpMem : [select Id, UserorGroupId,Group.Name,group.relatedId 
                                      FROM GroupMember 
                                      WHERE UserorGroupId in:currentUserGroupIds
                                     ]){
                                         currentUserGroupIds.add(grpMem.GroupId);
                                     }

            for(Groupmember grpMem : [select Id, UserorGroupId,Group.Name,Group.Type,Group.DeveloperName 
                                      FROM GroupMember 
                                      WHERE GroupId in:groupIdSet
                                      ORDER BY Group.DeveloperName
                                     ]){
                                         if((currentUserGroupIds.contains(grpmem.UserorGroupId) ||
                                             currentUserGroupIds.contains(grpMem.GroupId) ) 
                                            && !QueueNamesList.contains(grpMem.group.developername) 
                                           ){
                                               QueueNamesList.add(grpMem.group.developername);
                                           }
                                     }
            /*Added '&&' condition in if Statement and Added the below code for U-2886:Start*/
            
            if(timeRecId!=null && !timeRecId.isEmpty()){
                //OC_TR_TimeRecord__c tr = [select id,ownerId,OC_TR_ActivityName__c from OC_TR_TimeRecord__c where id In:timeRecId LIMIT 1]; **commenting for U-2886**
                
                List<OC_TR_TimeRecord__c> trList = [select id,ownerId,OC_TR_ActivityName__c from OC_TR_TimeRecord__c where id In:timeRecId];
                List<String> chatTranscript= new List<String>{OC_TR_Constants.LiveChatTranscript};
                 for(OC_TR_TimeRecord__c tr:trList){
                     if(!addChatQueues && tr.OC_TR_ActivityName__c.equals(OC_TR_Constants.Chat)){
                         addChatQueues = true;
                     }
                     else if(!addNonChatQueues && !tr.OC_TR_ActivityName__c.equals(OC_TR_Constants.Chat)){
                         addNonChatQueues = true;
                     }
                     else if(addChatQueues && addNonChatQueues){
                         break;
                     }
                  }   
                if(addChatQueues){
                    for(QueueSobject chatData:[Select Id,Queue.DeveloperName,SobjectType from QueueSobject where SobjectType IN:chatTranscript AND Queue.DeveloperName IN:QueueNamesList]){
                        chatActivityList.add(chatData.Queue.DeveloperName);
                        chatActivityMap.put(OC_TR_Constants.Chat,chatActivityList);
                    }
                }
                if(addNonChatQueues){
                    for(QueueSobject nonChatData:[Select Id,Queue.DeveloperName,SobjectType from QueueSobject where SobjectType NOT IN:chatTranscript AND Queue.DeveloperName IN:QueueNamesList]){
                        otherActivityList.add(nonChatData.Queue.DeveloperName);
                        otherActivityMap.put(OC_TR_Constants.otherActivity,otherActivityList);  
                    }
                } 
                if(trList[0].ownerId == USERINFO.getUserId()){
                    //  finalQueueList = QueueNamesList;   **commenting for U-2886**
                    finalQueueMap.putAll(chatActivityMap); 
                    finalQueueMap.putAll(otherActivityMap);
                }
                // else(trList[0].ownerId != USERINFO.getUserId()){ **commenting for U-2886**
                else{
                    finalQueueList.add(OC_TR_Constants.errorMessage);
                    finalQueueMap.put(OC_TR_Constants.unauthorizedUser,finalQueueList);
                } 
            }else{
                finalQueueMap.put(OC_TR_Constants.AllActivity,QueueNamesList);
                return finalQueueMap;
            }
        }
        catch (Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_QUEUEQUICKACTIONCONTROLLER,OC_TR_Constants.FETCHQUEUERECORDS,null, false, e));
        }
        // return finalQueueList ; **commenting for U-2886**
        return finalQueueMap;
        //U-2886:End
    }
    @AuraEnabled
    public  Static List<OC_TR_OrganizationMapping__mdt> getOrgDetailsFromMdt(String queueName){
        List<OC_TR_OrganizationMapping__mdt> orgMdtRec  = new List<OC_TR_OrganizationMapping__mdt> ();
        orgMdtRec =   [ SELECT Queue_Name__c, OC_TR_LegalForm__c, OC_TR_Org_Id__c 
                       FROM OC_TR_OrganizationMapping__mdt 
                       WHERE Queue_Name__c =:queueName];
        return orgMdtRec; 
    }  
}