/******************************************************************* 
* @author: Gopi Krishna
* @date: 2019-02-01  
* @description: This class is a Handler class for OpportunityTagHelper
********************************************************************/
public with sharing class OpportunityTagTriggerHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    
    public opportunityTagTriggerHandler(boolean isExecuting, integer size){
        this.isExecuting = isExecuting;
        batchSize = size;
    }
    
    public void onAfterInsert(List<Opportunity_tags__c> newOppTags){
        Try{                      
            Set<Id> setParentOpportunityIds = new Set<Id>();
            for(Opportunity_tags__c ot : newOppTags) {
                setParentOpportunityIds.add(ot.Opportunity__c);           
            }
            OpportunityTagHelper.updateTagOnOpportunity(setParentOpportunityIds);
        }catch(Exception e){	}
    }
    
    public void onAfterUpdate(List<Opportunity_tags__c> newOppTags, List<Opportunity_tags__c> oldOppTags, Map<ID, Opportunity_tags__c> newOppTagsMap, Map<ID, Opportunity_tags__c> oldOppTagsMap){
        Try{
            Set<Id> setParentOpportunityIds = new Set<Id>();
            for(Opportunity_tags__c ot : newOppTags) {
                setParentOpportunityIds.add(ot.Opportunity__c);           
            }
            OpportunityTagHelper.updateTagOnOpportunity(setParentOpportunityIds);
        }catch(Exception e){	}
    }
    
    public void onAfterDelete( List<Opportunity_tags__c> newOppTags, List<Opportunity_tags__c> oldOppTags, Map<ID, Opportunity_tags__c> newOppTagsMap, Map<ID, Opportunity_tags__c> oldOppTagsMap){
        Try{
            Set<Id> setParentOpportunityIds = new Set<Id>();
            for(Opportunity_tags__c ot : oldOppTags) {
                setParentOpportunityIds.add(ot.Opportunity__c);           
            }
            OpportunityTagHelper.updateTagOnOpportunity(setParentOpportunityIds);
        }catch(Exception e){	}
    }
}