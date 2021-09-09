/******************************************************************************************
*
*      	@author       : Ankit Jain
*      	@date         : 26-06-2020
@description  : Helper Class for TagTrigger
@testClass    : OpportunityTagHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Ankit Jain					26-06-2020				U-2907 - updateTagOnOpportunity Method added

******************************************************************************************/

public without sharing class TagTriggerHelper {
    /****************************************************************
* @author: Ankit Jain
* @date: 26-06-2020
* @param: oldTagMap,newTagMap
* @description: D-2907 This method will update Tag On Opportunity on Tag name change
*****************************************************************/
    public static void updateTagOnOpportunity(Map<ID, Tags__c> oldTagMap , Map<ID, Tags__c> newTagMap){
        try {
            List<Tags__c> tagList=new List<Tags__c>();
            for(Tags__c tag : newTagMap.values()){
                tagList.add(tag);
            }           
            Set<Id> setParentOpportunityIds = new Set<Id>();
            for(Opportunity_tags__c oppTag: [select id,opportunity__c,tag__c,tag__r.name from Opportunity_tags__c where tag__c IN: tagList
                                             and Opportunity__r.StageName not in ('Closed Won','Closed Lost','Closed-Withdrawn','Closed-Duplicate')])
            {
                setParentOpportunityIds.add(oppTag.Opportunity__c);           
            }
            OpportunityTagHelper.updateTagOnOpportunity(setParentOpportunityIds);             
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TagTriggerHelper, GlobalConstants.updateTagOnOpportunity, 
                                                                       GlobalConstants.TagTriggerHelper, true, e)));
        }
    }
}