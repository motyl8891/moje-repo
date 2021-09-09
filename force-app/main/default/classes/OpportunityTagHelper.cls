/******************************************************************* 
* @author: Gopi Krishna
* @date: 2019-02-01  
* @description: This class is a helper class for Opportunity Tag
********************************************************************/
public without sharing class OpportunityTagHelper{    
    /****************************************************************
* @author: Manu Singhal
* @date: 29-10-2020
* @param: setParentOpportunityIds
* @description: D-3354 This will update the Tag on opportunity
*****************************************************************/
    @future  
    public static void updateTagOnOpportunity(Set<ID> setParentOpportunityIds){
        Try{
            List<Opportunity> oppToUpdateList = new List<Opportunity>();            
            Map<String, String> oppTagsMap = new Map<String, String>();              
            for(Opportunity_tags__c ot: [select id,opportunity__c,tag__c,tag__r.name from Opportunity_tags__c 
                                         where opportunity__c IN: setParentOpportunityIds])
            {                                        
                if(oppTagsMap.containsKey(ot.opportunity__c))
                {
                    String tagList = oppTagsMap.get(ot.opportunity__c);
                    tagList = tagList + ot.tag__r.name + GlobalConstants.NEWLINE;
                    oppTagsMap.put(ot.opportunity__c,tagList);
                }
                else{
                    String tagnames = ot.tag__r.name + GlobalConstants.NEWLINE;
                    oppTagsMap.put(ot.opportunity__c,tagnames); 
                }                                                
            }        
            if(!oppTagsMap.isEmpty()){
                for(Id opp: oppTagsMap.keyset())
                {
                    Opportunity opp1 = new Opportunity(Id = opp,tags__c=oppTagsMap.get(opp));
                    oppToUpdateList.add(opp1);
                }
            }
            if(!oppToUpdateList.isEmpty()){
                database.update(oppToUpdateList, false);
            }
        }catch(Exception e){ EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.TagTriggerHelper, GlobalConstants.updateTagOnOpportunity, 
                                                                       GlobalConstants.TagTriggerHelper, true, e)));}       
    }
}