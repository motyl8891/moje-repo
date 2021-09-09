public class OC_Managedtopics {
    
    public void getNavigationTopics(){
        
        Map<id,TopicTreeWrapper> allTopicsMap = new  Map<id,TopicTreeWrapper>();
        List<TopicTreeWrapper> selectedTopicHierarchy = new List<TopicTreeWrapper>();
        String parentorder;
        
        String commId = [Select Id from Network where name = 'Customer Community'].id;
        ConnectApi.ManagedTopicCollection mtCollection = ConnectAPI.ManagedTopics.getManagedTopics(commId,ConnectApi.ManagedTopicType.Navigational,8);
        
        for(ConnectApi.managedTopic parent:mtCollection.managedTopics){
            allTopicsMap.put(parent.topic.id,new TopicTreeWrapper(parent.topic.id,parent.topic.name,null));
            allTopicsMap.putall(TraverseChildTopic(parent.topic.id,parent.children));
        }
        
        system.debug('allTopicsMap-----------'+allTopicsMap);
        system.debug('allTopicsMap size----------'+allTopicsMap.size());
        
        parentorder = getHierarchy('0TO1l000000DZN9GAO',allTopicsMap);
        system.debug('parentorder---------'+parentorder);
        
        List<String> parentlist = parentorder.split(';');
        system.debug('parentlist--------'+parentlist);
        
        for(String topicId: parentlist){
            selectedTopicHierarchy.add(allTopicsMap.get(topicId));
        }
        
        system.debug('listForTopic---------'+selectedTopicHierarchy);
    }
    
    public Map<Id,TopicTreeWrapper> TraverseChildTopic(Id parentTopic,List<ConnectApi.managedTopic> childrens){
        Map<Id,TopicTreeWrapper> TopicMap = new Map<Id,TopicTreeWrapper>();
        for(ConnectApi.managedTopic child:childrens){
            TopicMap.put(child.topic.id,new TopicTreeWrapper(child.topic.id,child.topic.name,parentTopic));
            if(child.children.size() > 0){
                TopicMap.putall(TraverseChildTopic(child.topic.id,child.children));
            }
        }
        
        return TopicMap;
    }
    
    public String getHierarchy(Id topicId,Map<Id,TopicTreeWrapper> allTopicsmap){
        String parentHierarchy;
        parentHierarchy = topicId;
        
        TopicTreeWrapper topicWrapper = allTopicsmap.get(topicId);
        if(topicWrapper.parent!=null){
            parentHierarchy = getHierarchy(topicWrapper.parent,allTopicsmap)+';'+parentHierarchy;
        }
        
        return parentHierarchy;
    }
    
    
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