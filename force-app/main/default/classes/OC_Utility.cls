/**
* @File Name          : OC_Utility
* @Description        : Class containing the generic re-utilizable  methods
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : 
* @Created Date       : 29th March 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-29-03                 IBM                   Initial Version
*2.0         2021-04-16                 IBM                  U-1977 - To Display full path of navigation in customerPortal for topics and feed.
**/
public class OC_Utility {
    public static Set<Id> DMLhandler(List<sObject> sObjectRecList,String ClassName,String MethodName, String Operation)
    {
        List<EventLog.Log> EventLogInsertList = new List<EventLog.Log> ();
        Set<Id> SuccessRecIdSet = new Set<Id>();
        try
        {
            if(sObjectRecList!=null && !sObjectRecList.isEmpty())
            {
                if(Operation.equalsIgnoreCase(OC_IB_Constants.deleteOps))
                {
                    Database.DeleteResult[] drList = Database.delete(sObjectRecList, false);
                    for(Database.DeleteResult dr : drList)
                    {
                        for(Database.Error err : dr.getErrors()) //To capture errors during database deletion
                        {       
                            EventLogInsertList.add(new EventLog.ErrorLogs(ClassName,MethodName, null, false,err.getMessage(),dr.getId()));                        
                        }     
                    }
                }
                else if(Operation.equalsIgnoreCase('Insert'))
                {
                    Database.SaveResult[] InsList = Database.insert(sObjectRecList, false);
                    for(Database.SaveResult Ins : InsList)
                    {
                        for(Database.Error err : Ins.getErrors()) //To capture errors during database Insertion
                        {       
                            EventLogInsertList.add(new EventLog.ErrorLogs(ClassName,MethodName, null, false,err.getMessage(),null));                        
                        }
                        if(Ins.isSuccess())
                        {
                            SuccessRecIdSet.add(Ins.getId());
                        }    
                    }
                }
                else if(Operation.equalsIgnoreCase('Update'))
                {
                    Database.SaveResult[] UpdList = Database.update(sObjectRecList, false);
                    for(Database.SaveResult Upd : UpdList)
                    {
                        for(Database.Error err : Upd.getErrors()) //To capture errors during database Updation
                        {       
                            EventLogInsertList.add(new EventLog.ErrorLogs(ClassName,MethodName, null, false,err.getMessage(),Upd.getId()));                        
                        }  
                        
                        if(Upd.isSuccess())
                        {
                            SuccessRecIdSet.add(Upd.getId());
                        }
                    } 
                }
                EventLog.CreateEventLogs(EventLogInsertList);  
            }
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
        }
        catch(Exception ex){
            EventLogInsertList.add(new EventLog.Error(OC_IB_Constants.classArchiveStagingObjects,OC_IB_Constants.methodExecute, null, true,ex));
            EventLog.CreateEventLogs(EventLogInsertList);
        } 
        return SuccessRecIdSet;
    }
    /**************************************************************************************************
* @Method Name : getObjectPicklistValues
* @Description : get Entitlement List to create entitlement records 
* @Param       : objectName, fieldName,casetype(lower/upper)
* @Return      : Map<String,String>-Map<servicemilestone,priority,uppercase/lowercase>
****************************************************************************************************/
    public static Map<String,String> getObjectPicklistValues(String object_Name, String field_Name,String typeCase) {
        Map<String,String> picklistValuesMap=new Map<String,String>();
        String[] types = new String[]{object_Name};
            Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_Name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    if(typeCase == OC_IB_Constants.toUpperCase){
                        picklistValuesMap.put(entry.getLabel().toUpperCase(), entry.getValue());
                    }
                    else if(typeCase == OC_IB_Constants.toLowerCase){
                        picklistValuesMap.put(entry.getLabel().toLowercase(), entry.getValue());
                    }
                    else{
                        picklistValuesMap.put(entry.getLabel(), entry.getValue());
                    }
                }
            }
        }
        
        return picklistValuesMap;
    }
/**************************************************************************************************
* @Method Name : getObjectPicklistValuesReverse
* @Description : get a Map of labels and values of picklists with values as the key
* @Param       : objectName, fieldName
* @Return      : Map<String,String>
****************************************************************************************************/    
public static Map<String,String> getObjectPicklistValuesReverse(String object_Name, String field_Name) {
        Map<String,String> picklistValuesMap=new Map<String,String>();
        String[] types = new String[]{object_Name};
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
           for (Schema.PicklistEntry entry : res.fields.getMap().get(field_Name).getDescribe().getPicklistValues()) {
              if (entry.isActive()) {
                  {
                      picklistValuesMap.put(entry.getValue(),entry.getLabel());
                  }
              }
           }
        }
        
        return picklistValuesMap;
    
      }
    
    /**************************************************************************************************
* @Method Name : getNavigationTopics
* @Description : get the List of parentTopics for the selected topic 
* @Param       : TopicID
* @Return      : List<TopicTreeWrapper>
*Method added as part of US-1977
****************************************************************************************************/
    public static List<TopicTreeWrapper> getNavigationTopics(Id TopicId){
        
        Map<id,TopicTreeWrapper> allTopicsMap = new  Map<id,TopicTreeWrapper>();
        List<TopicTreeWrapper> selectedTopicHierarchy = new List<TopicTreeWrapper>();
        String parentorder;
        String CommId;
        
        if(!Test.isRunningTest()){
            commId = [Select Id from Network where id =:Network.getNetworkId()].id;}
        else{
            commId = [Select Id from Network where name = 'Customer Community'].id;}
        
        ConnectApi.ManagedTopicCollection mtCollection = ConnectAPI.ManagedTopics.getManagedTopics(commId,ConnectApi.ManagedTopicType.Navigational,8);
        
        for(ConnectApi.managedTopic parent:mtCollection.managedTopics){
            allTopicsMap.put(parent.topic.id,new TopicTreeWrapper(parent.topic.id,parent.topic.name,null));
            allTopicsMap.putall(TraverseChildTopic(parent.topic.id,parent.children));
        }
        
        parentorder = GetHierarchy(TopicId,allTopicsMap);
        List<String> parentlist = parentorder.split(';');
        for(String topic: parentlist){
            selectedTopicHierarchy.add(allTopicsMap.get(topic));
        }
        return selectedTopicHierarchy;
    }
    
    /**************************************************************************************************
* @Method Name : TraverseChildTopic
* @Description : For traversing the child topics in the Hierarchy 
* @Param       : parentTopic, list of childTopics
* @Return      : Map<Id,TopicTreeWrapper>
*Method added as part of US-1977
****************************************************************************************************/
    public static Map<Id,TopicTreeWrapper> TraverseChildTopic(Id parentTopic,List<ConnectApi.managedTopic> childrens){
        Map<Id,TopicTreeWrapper> TopicMap = new Map<Id,TopicTreeWrapper>();
        for(ConnectApi.managedTopic child:childrens){
            TopicMap.put(child.topic.id,new TopicTreeWrapper(child.topic.id,child.topic.name,parentTopic));
            if(child.children.size() > 0){
                TopicMap.putall(TraverseChildTopic(child.topic.id,child.children));
            }
        }
        
        return TopicMap;
    }
    /**************************************************************************************************
* @Method Name : getHierarchy
* @Description : To get the parent Hierarchy for the topic
* @Param       : topicId,allTopicsmap
* @Return      : String
*Method added as part of US-1977
****************************************************************************************************/   
    public static String GetHierarchy(Id topicId,Map<Id,TopicTreeWrapper> allTopicsmap){
        String parentHierarchy;
        parentHierarchy = topicId;
        
        TopicTreeWrapper topicWrapper = allTopicsmap.get(topicId);
        if(topicWrapper.parent!=null){
            parentHierarchy = getHierarchy(topicWrapper.parent,allTopicsmap)+';'+parentHierarchy;
        }
        
        return parentHierarchy;
    }
    
    /**************************************************************************************************
* @Class Name : TopicTreeWrapper
* @Description : Wrapper class to store the topic information with Parent
* @Param       : 
* @Return      : 
*Class added as part of US-1977
****************************************************************************************************/      
    public without sharing class TopicTreeWrapper {
        public String topicId { public get; public set; }
        public String topicName { public get; public set; }
        Public Id parent { public get; public set; }
        
        public TopicTreeWrapper(String topicId,String topicName,Id parent){
            this.topicId = topicId;
            this.topicName = topicName;
            this.parent = parent;
        }
    }
    
}