/******************************************************************* 
* @author: Ankit Jain
* @date: 2021-01-19
* @description: This class is a helper class for OpportunityContactRoleTriggerHandler (U-1839)
********************************************************************/
public without sharing class OpportunityContactRoleTriggerHelper {
    /******************************************************************* 
* @author: Ankit Jain
* @date: 2021-01-19 
* @description: This method will update the status of OpportunityContactRole according to Campaign type(U-1032)
********************************************************************/
    public static void updateCampaignIdtoOpportunity(List<OpportunityContactRole> OpportunityContactRoles){
        try{
            
            Map<Id,Map<Id,Datetime>> conCmpMap=new Map<Id,Map<Id,Datetime>>();
            System.debug('conCmpMap: '+conCmpMap);
            // List<OpportunityContactRole> CmpList=[SELECT Id, OpportunityId, Opportunity.name, ContactId, Contact.name, CreatedDate, LastModifiedDate from OpportunityContactRole where ];
            Map<Id,Id> oppIdConIdMap=new Map<Id,Id>();
            for(OpportunityContactRole cmp: OpportunityContactRoles) {
                
                //if(conCmpMap!=null){
                if(conCmpMap.containsKey(cmp.OpportunityId)){
                    Map<Id,Datetime> cmpMap=conCmpMap.get(cmp.OpportunityId);
                    cmpMap.put(cmp.ContactId,cmp.LastModifiedDate);
                    conCmpMap.put(cmp.OpportunityId,cmpMap);    
                }
                else{
                    Map<Id,Datetime> cmpMap=new Map<Id,Datetime>();
                    cmpMap.put(cmp.ContactId,cmp.LastModifiedDate);
                    conCmpMap.put(cmp.OpportunityId,cmpMap);    
                }
                /*}
else{
Map<Id,Datetime> cmpMap=new Map<Id,Datetime>();
cmpMap.put(cmp.ContactId,cmp.LastModifiedDate);
conCmpMap.put(cmp.OpportunityId,cmpMap);    
}*/
            }
            
            System.debug('conCmpMap : '+conCmpMap);
            
            for(Id conId : conCmpMap.keySet()){
                System.debug('conId : '+conId);
                Map<Id,Datetime> cmpMap=conCmpMap.get(conId);
                Datetime flag;
                Id cmpIdFlag;
                for(Id cmpId: cmpMap.keySet()){
                    DateTime cmpDate=cmpMap.get(cmpId);
                    if(flag==null){
                        flag=cmpDate;
                        cmpIdFlag=cmpId;
                    }
                    else{
                        if(flag<cmpDate){
                            flag=cmpDate;
                            cmpIdFlag=cmpId;
                        }
                    }
                }
                System.debug('flag: '+flag);
                System.debug('cmpIdFlag: '+cmpIdFlag);
                oppIdConIdMap.put(conId,cmpIdFlag);
            }
            System.debug('oppIdConIdMap: '+oppIdConIdMap);
            
            List<Id> conIdList=New List<Id>();
            for(Id oppId: oppIdConIdMap.keyset()){
                conIdList.add(oppIdConIdMap.get(oppId));
            }
            System.debug('Inside updateCampaignIdtoOpportunity');
            String contct=OpportunityContactRoles[0].ContactId;
            List<CampaignMember> cmpOtherList=[SELECT Id, ContactId, Contact.name,CampaignId, Campaign.name, CreatedDate, LastModifiedDate  from CampaignMember where ContactId In :conIdList];
            if(cmpOtherList!=null){
                Map<Id,Id> conIdCmpIdMap=OpportunityUtils.contactID2CampaignIDMap(cmpOtherList);
                System.debug('conIdCmpIdMap: '+conIdCmpIdMap);
                List<Opportunity> toUpdateOpp=new List<Opportunity>();
                for(Id oppId:oppIdConIdMap.keyset()){
                    Id cmpId= conIdCmpIdMap.get(oppIdConIdMap.get(oppId));
                    if(cmpId!=null){
                        Opportunity uopp = new Opportunity (id = oppId, CampaignId = cmpId);
                        toUpdateOpp.add(uopp); 
                    }
                }
                System.debug('toUpdateOpp: '+toUpdateOpp);
                update toUpdateOpp;    
            }
        } 
        catch(Exception e){  
            EventLog.createLogFuture(Json.serialize(new EventLog.Error('OpportunityContactRoleTriggerHelper', 
                                                                       'updateCampaignIdtoOpportunity', 'OpportunityContactRoleTriggerHelper', true, e)));
        }   
    }
}