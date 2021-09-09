public without sharing class RelatedOpportunityController {
    
    @AuraEnabled
    public static RelatedOpportunityWrapper getRelatedOpps(Id idVal) {
        Boolean parentFlag=false;
        Boolean childFlag=false;
        String url=URL.getSalesforceBaseUrl().toExternalForm().replace(GlobalConstants.RelatedOpp_ReplacableURL,GlobalConstants.RelatedOpp_LightningURL);
        RelatedOpportunityWrapper relatedOpportunityWrapper=new RelatedOpportunityWrapper();
        try{
            Opportunity records = [SELECT Id,name,CloseDate,StageName,Margin__c,RecordTypeName__c,OpportunityNumber__c,Legacy_Estimated_Deal_Value__c,Parent_Original_Opportunity__c,(SELECT Id FROM Child_Subsequent_Opportunities__r where RecordTypeId !=:GlobalConstants.simpleOppRecordTypeId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())) FROM Opportunity where id =:idVal
                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(records.Parent_Original_Opportunity__c!=null){
                parentFlag=true;
            }
            if(records.Child_Subsequent_Opportunities__r.size()!=0){
                childFlag=true;
            }
            if(parentFlag && childFlag){
                relatedOpportunityWrapper =getParentChildOpps(idVal);
            }
            else{
                if(parentFlag==true){
                    relatedOpportunityWrapper =getParentOpps(idVal);
                }
                else if(childFlag==true){
                    relatedOpportunityWrapper = getChildOpps(idVal);
                }
                else{
                    relatedOpportunityWrapper = new RelatedOpportunityWrapper(records.Id,records.OpportunityNumber__c,records.name,records.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+records.Id+GlobalConstants.Opp_Record_view,records.CloseDate,records.StageName,records.Margin__c,records.RecordTypeName__c);
                }
            }    
        }catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.RelatedOpportunityController,
                                                                       GlobalConstants.getRelatedOpps,
                                                                       GlobalConstants.RelatedOpportunityController, true, e))); 
        }
        
        return relatedOpportunityWrapper;
    }
    /*public static RelatedOpportunityWrapper getParentOpp(Id idVal) {
List<Id> parentIdList= new List<Id>();
Opportunity parentRecords= [Select id,name,OpportunityNumber__c,Legacy_Estimated_Deal_Value__c,Parent_Original_Opportunity__c,Parent_Original_Opportunity__r.Id,Parent_Original_Opportunity__r.name,Parent_Original_Opportunity__r.OpportunityNumber__c,Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c from Opportunity where id=:idVal];
List<RelatedOpportunityWrapper> listRelatedOpportunityWrapper=new List<RelatedOpportunityWrapper>();
listRelatedOpportunityWrapper.add(new RelatedOpportunityWrapper(parentRecords.Id,parentRecords.OpportunityNumber__c,parentRecords.name,parentRecords.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>()));
RelatedOpportunityWrapper tgwc=new RelatedOpportunityWrapper(
parentRecords.Parent_Original_Opportunity__r.Id,parentRecords.Parent_Original_Opportunity__r.OpportunityNumber__c,parentRecords.Parent_Original_Opportunity__r.name,parentRecords.Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c,listRelatedOpportunityWrapper);
return tgwc;
}*/
    private static RelatedOpportunityWrapper getChildOpp(Id idVal) {
        String url=URL.getSalesforceBaseUrl().toExternalForm().replace(GlobalConstants.RelatedOpp_ReplacableURL,GlobalConstants.RelatedOpp_LightningURL);
        Opportunity opp = [select id,OpportunityNumber__c, Name,CloseDate,StageName,Margin__c,RecordTypeName__c,Legacy_Estimated_Deal_Value__c,(select id,OpportunityNumber__c, Name,CloseDate,StageName,Margin__c,RecordTypeName__c,Legacy_Estimated_Deal_Value__c from Child_Subsequent_Opportunities__r where RecordTypeId !=:GlobalConstants.simpleOppRecordTypeId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())) from Opportunity where id=:idVal
                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        RelatedOpportunityWrapper treeGripWrapper =new RelatedOpportunityWrapper(opp.Id,opp.OpportunityNumber__c,opp.Name,opp.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+opp.Id+GlobalConstants.Opp_Record_view,opp.CloseDate,opp.StageName,opp.Margin__c,opp.RecordTypeName__c);
        List<RelatedOpportunityWrapper> childOppList=new List<RelatedOpportunityWrapper>();
        for(Opportunity cso:opp.Child_Subsequent_Opportunities__r){
            childOppList.add(new RelatedOpportunityWrapper(cso.Id,cso.OpportunityNumber__c,cso.Name,cso.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+cso.Id+GlobalConstants.Opp_Record_view,cso.CloseDate,cso.StageName,cso.Margin__c,cso.RecordTypeName__c));
        }
        treeGripWrapper.childRelatedOpportunityWrapper=childOppList;
        return treeGripWrapper;
    }
    private static RelatedOpportunityWrapper getParentChildOpps(Id idVal) {
        String url=URL.getSalesforceBaseUrl().toExternalForm().replace(GlobalConstants.RelatedOpp_ReplacableURL,GlobalConstants.RelatedOpp_LightningURL);
        RelatedOpportunityWrapper childWrapper=getChildOpp(idVal);
        Opportunity parentRecords1= [Select Parent_Original_Opportunity__r.Id,Parent_Original_Opportunity__r.name,Parent_Original_Opportunity__r.CloseDate,Parent_Original_Opportunity__r.StageName,Parent_Original_Opportunity__r.Margin__c,Parent_Original_Opportunity__r.RecordTypeName__c,Parent_Original_Opportunity__r.OpportunityNumber__c,Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c from Opportunity where id=:idVal
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        List<RelatedOpportunityWrapper> listRelatedOpportunityWrapper=new List<RelatedOpportunityWrapper>();
        listRelatedOpportunityWrapper.add(childWrapper);
        return new RelatedOpportunityWrapper(parentRecords1.Parent_Original_Opportunity__r.Id,parentRecords1.Parent_Original_Opportunity__r.OpportunityNumber__c,parentRecords1.Parent_Original_Opportunity__r.name,parentRecords1.Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c,listRelatedOpportunityWrapper,url+parentRecords1.Parent_Original_Opportunity__r.Id+GlobalConstants.Opp_Record_view,parentRecords1.Parent_Original_Opportunity__r.CloseDate,parentRecords1.Parent_Original_Opportunity__r.StageName,parentRecords1.Parent_Original_Opportunity__r.Margin__c,parentRecords1.Parent_Original_Opportunity__r.RecordTypeName__c);
    }
    private static RelatedOpportunityWrapper getParentOpps(Id idVal) {
        String url=URL.getSalesforceBaseUrl().toExternalForm().replace(GlobalConstants.RelatedOpp_ReplacableURL,GlobalConstants.RelatedOpp_LightningURL);
        Opportunity parentRecords= [Select id,name,CloseDate,StageName,Margin__c,RecordTypeName__c,OpportunityNumber__c,Legacy_Estimated_Deal_Value__c,Parent_Original_Opportunity__c,Parent_Original_Opportunity__r.Id,Parent_Original_Opportunity__r.name,Parent_Original_Opportunity__r.CloseDate,Parent_Original_Opportunity__r.StageName,Parent_Original_Opportunity__r.Margin__c,Parent_Original_Opportunity__r.RecordTypeName__c,Parent_Original_Opportunity__r.OpportunityNumber__c,Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c from Opportunity where id=:idVal
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())	];
        List<RelatedOpportunityWrapper> listRelatedOpportunityWrapper=new List<RelatedOpportunityWrapper>();
        listRelatedOpportunityWrapper.add(new RelatedOpportunityWrapper(parentRecords.Id,parentRecords.OpportunityNumber__c,parentRecords.name,parentRecords.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+parentRecords.Id+GlobalConstants.Opp_Record_view,parentRecords.CloseDate,parentRecords.StageName,parentRecords.Margin__c,parentRecords.RecordTypeName__c));
        RelatedOpportunityWrapper relatedOpportunityWrapper=new RelatedOpportunityWrapper(
            parentRecords.Parent_Original_Opportunity__r.Id,parentRecords.Parent_Original_Opportunity__r.OpportunityNumber__c,parentRecords.Parent_Original_Opportunity__r.name,parentRecords.Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c,listRelatedOpportunityWrapper,url+parentRecords.Parent_Original_Opportunity__r.Id+GlobalConstants.Opp_Record_view,parentRecords.Parent_Original_Opportunity__r.CloseDate,parentRecords.Parent_Original_Opportunity__r.StageName,parentRecords.Parent_Original_Opportunity__r.Margin__c,parentRecords.Parent_Original_Opportunity__r.RecordTypeName__c);
        if(parentRecords.Parent_Original_Opportunity__r.Id!=null){
            Opportunity grandParentRecords= [Select Parent_Original_Opportunity__r.Id,Parent_Original_Opportunity__r.name,Parent_Original_Opportunity__r.CloseDate,Parent_Original_Opportunity__r.StageName,Parent_Original_Opportunity__r.Margin__c,Parent_Original_Opportunity__r.RecordTypeName__c,Parent_Original_Opportunity__r.OpportunityNumber__c,Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c from Opportunity where id=:parentRecords.Parent_Original_Opportunity__r.Id
                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(grandParentRecords.Parent_Original_Opportunity__r.Id!=null){
            	List<RelatedOpportunityWrapper> listRelatedOpportunityWrapper1=new List<RelatedOpportunityWrapper>();
            	listRelatedOpportunityWrapper1.add(relatedOpportunityWrapper);
            	relatedOpportunityWrapper = new RelatedOpportunityWrapper(grandParentRecords.Parent_Original_Opportunity__r.Id,grandParentRecords.Parent_Original_Opportunity__r.OpportunityNumber__c,grandParentRecords.Parent_Original_Opportunity__r.name,grandParentRecords.Parent_Original_Opportunity__r.Legacy_Estimated_Deal_Value__c,listRelatedOpportunityWrapper1,url+grandParentRecords.Parent_Original_Opportunity__r.Id+GlobalConstants.Opp_Record_view,grandParentRecords.Parent_Original_Opportunity__r.CloseDate,grandParentRecords.Parent_Original_Opportunity__r.StageName,grandParentRecords.Parent_Original_Opportunity__r.Margin__c,grandParentRecords.Parent_Original_Opportunity__r.RecordTypeName__c);
            }
        }
        return relatedOpportunityWrapper;
    }
    private static RelatedOpportunityWrapper getChildOpps(Id idVal) {
        String url=URL.getSalesforceBaseUrl().toExternalForm().replace(GlobalConstants.RelatedOpp_ReplacableURL,GlobalConstants.RelatedOpp_LightningURL);
        Opportunity opp = [select id,OpportunityNumber__c, Name,CloseDate,StageName,Margin__c,RecordTypeName__c,Legacy_Estimated_Deal_Value__c,(select id,OpportunityNumber__c, Name,CloseDate,StageName,Margin__c,RecordTypeName__c,Legacy_Estimated_Deal_Value__c from Child_Subsequent_Opportunities__r where RecordTypeId !=:GlobalConstants.simpleOppRecordTypeId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())) from Opportunity where id=:idVal
                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        RelatedOpportunityWrapper relatedOpportunityWrapper =new RelatedOpportunityWrapper(opp.Id,opp.OpportunityNumber__c,opp.Name,opp.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+opp.Id+GlobalConstants.Opp_Record_view,opp.CloseDate,opp.StageName,opp.Margin__c,opp.RecordTypeName__c);
        List<Id> childIdList=new List<Id>();
        List<RelatedOpportunityWrapper> childOppList=new List<RelatedOpportunityWrapper>();
        for(Opportunity cso:opp.Child_Subsequent_Opportunities__r){
            childIdList.add(cso.id);
            childOppList.add(new RelatedOpportunityWrapper(cso.Id,cso.OpportunityNumber__c,cso.Name,cso.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+cso.Id+GlobalConstants.Opp_Record_view,cso.CloseDate,cso.StageName,cso.Margin__c,cso.RecordTypeName__c));
        }
        relatedOpportunityWrapper.childRelatedOpportunityWrapper=childOppList;
        Map<Id,List<RelatedOpportunityWrapper>> furtherChildOppMap=new Map<Id,List<RelatedOpportunityWrapper>>();
        for(Opportunity cso:[select id,(select id,OpportunityNumber__c, Name,CloseDate,StageName,Margin__c,RecordTypeName__c,Legacy_Estimated_Deal_Value__c from Child_Subsequent_Opportunities__r where RecordTypeId !=:GlobalConstants.simpleOppRecordTypeId Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())) from Opportunity where id in :childIdList 
                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                 List<RelatedOpportunityWrapper> furtherChildOppList=new List<RelatedOpportunityWrapper>();
                                 for(Opportunity internalOpp:cso.Child_Subsequent_Opportunities__r){
                                     furtherChildOppList.add(new RelatedOpportunityWrapper(internalOpp.Id,internalOpp.OpportunityNumber__c,internalOpp.Name,internalOpp.Legacy_Estimated_Deal_Value__c,new List<RelatedOpportunityWrapper>(),url+internalOpp.Id+GlobalConstants.Opp_Record_view,internalOpp.CloseDate,internalOpp.StageName,internalOpp.Margin__c,internalOpp.RecordTypeName__c));
                                 }
                                 furtherChildOppMap.put(cso.id, furtherChildOppList);
                             }
        for(RelatedOpportunityWrapper row: childOppList){
            row.childRelatedOpportunityWrapper=furtherChildOppMap.get(row.idVal);
        }
        return relatedOpportunityWrapper;
    }
}