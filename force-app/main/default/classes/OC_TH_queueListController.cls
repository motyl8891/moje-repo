/**
 * @File Name      :OC_TH_queueListController
 * @Description    :Provide the data to the componenet in Lightning
 * @Author         :IBM
 * @Group          :OmniChannel - Service
 * @Created Date   :05th Aug 2021
 * ========================================================================================
 * Ver             Date             Author         Modification
 * ========================================================================================
 * 1.0           2021-08-05         IBM            Initial Version
**/
public class OC_TH_queueListController {
    /*The method to fetch all the Queue which is specific to case object in which the logged in user is a member*/
    @AuraEnabled
    public static Map<String, String> getFetchQueueRecords (String userIds)
    {
        Set<Id> currentUserGroupIds = new Set<Id>();
        Set<Id> groupIdSet = new Set<Id>();
        List<String> QueueNamesList = new List<String>();
        
        Map<String,String>CaseQueueMap =new Map<String,String>();
        List<Case>Cases=new List<Case>();
        
        Id userId =  userInfo.getUserId(); 
        
        String Queue=OC_TH_Constants.queue;
        String groupSoqlQuery;  
        try{
            Id allInternalUsersGrpId = [SELECT Id,Developername,Type FROM Group where developername='AllInternalUsers' LIMIT 1].id;
            currentUserGroupIds.add(allInternalUsersGrpId);
            groupSoqlQuery = 'SELECT Id,name,RelatedId,Type FROM Group WHERE Type='+'\''+OC_TH_Constants.queue+'\'' ;
            
             List<Case> CaseObj =new List<Case>();   
            
            
        
        for(Group grp : database.query(groupSoqlQuery) ){
                if(grp.Type.equalsignoreCase(OC_TH_Constants.queue)){
                    groupIdSet.add(grp.id);
                }
        }
        for(Groupmember grpMem : [select Id, UserorGroupId,Group.Name,group.relatedId 
                                      FROM GroupMember 
                                      WHERE UserorGroupId=:userId
                                  ]){
                                         currentUserGroupIds.add(grpMem.GroupId);
                                     }
        for(Group grp : database.query(groupSoqlQuery) ){
                if(grp.Type.equalsignoreCase(OC_TH_Constants.queue)){
                    groupIdSet.add(grp.id); 
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
        
        for(QueueSobject CaseQueue:[Select Id,Queue.DeveloperName,SobjectType from QueueSobject where SobjectType='Case' AND Queue.DeveloperName IN:QueueNamesList]){
             CaseQueueMap.put(CaseQueue.Queue.Id,CaseQueue.Queue.DeveloperName);
          
        }
        }
        catch(Exception e)
        {
              EventLog.createLog(new EventLog.Error(OC_TH_Constants.OC_TH_QUEUELISTCONTROLLER,OC_TH_Constants.GETFETCHRECORDS,null, false, e));

        }
        return CaseQueueMap;
    }

}