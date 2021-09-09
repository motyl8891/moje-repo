/******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This class is a helper class for CampaignMemberTriggerHandler (U-1032)
********************************************************************/
public without sharing class CampaignMemberTriggerHelper {
    /******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This method will update the status of CampaignMamber according to Campaign type(U-1032)
********************************************************************/
public static void addStatustoCampaignMembers(List<CampaignMember> newCampaignMembers){
        Map<CampaignMember,id> cmWithCampaignIdMap = new Map<CampaignMember,id>();
        Map<id,String> campIdWithTypeMap = new Map<id,String>();
    	String username;
        try{           
                username = GlobalConstants.MarketoSyncUserName;
            if(UserInfo.getUserName() != username)
            {
                for(CampaignMember campMember : newCampaignMembers)
                {
                    cmWithCampaignIdMap.put(campMember, campMember.CampaignId);
                }
            }
            if(!cmWithCampaignIdMap.isEmpty())
            {
                for(Campaign camp:[Select id,Type from Campaign where id in: cmWithCampaignIdMap.values()
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    campIdWithTypeMap.put(camp.id,camp.Type);
                } 
            }
            if(!campIdWithTypeMap.isEmpty())
            {
                for(CampaignMember campMember : newCampaignMembers)
                {
                    String campType = campIdWithTypeMap.get(cmWithCampaignIdMap.get(campMember));
                    if(campType == GlobalConstants.EMAILNEWSLETTER || campType == GlobalConstants.EMAILSEND || campType == GlobalConstants.LISTIMPORT || campType == GlobalConstants.MULTIEMAILSEND || campType == GlobalConstants.NURTURE || campType == GlobalConstants.ONLINEADVERTISING
                      || campType == GlobalConstants.OPERATIONAL || campType == GlobalConstants.WEBCONTENT || campType == GlobalConstants.WEBFORM)
                        campMember.Status = GlobalConstants.MEMBER;
                    else if(campType == GlobalConstants.LIVEEVENT ||campType == GlobalConstants.TRADESHOW || campType == GlobalConstants.WEBINAR )
                        campMember.Status = GlobalConstants.INVITED;
                    else if(campType == GlobalConstants.WEBPERSONALIZATION)
                        campMember.Status = GlobalConstants.VIEWED;
                }
            }
        }
        catch(Exception e){  
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.CAMPAIGNMEMBERTRIGGERHELPER, 
                                                                       GlobalConstants.ADDSTATUSTOCAMPAIGNMEMBERS, GlobalConstants.CAMPAIGNMEMBERTRIGGERHELPER, true, e)));
        }   
    }
    
    /******************************************************************* 
* @author: 
* @date: 2021-01-21 
* @description: This method will update the status of CampaignMamber according to Campaign type(U-1032)
********************************************************************/
    public static void updateContactOnOpp(List<CampaignMember> newCampaignMembers){
        // Map<Id,Map<Id,Datetime>> conCmpMap=new Map<Id,Map<Id,Datetime>>();
        Map<Id,Id> conIdCmpIdMap=new Map<Id,Id>();
        try{  
            conIdCmpIdMap = OpportunityUtils.contactID2CampaignIDMap(newCampaignMembers);
            
          /*  for(CampaignMember cmp: newCampaignMembers) {                
                if(conCmpMap!=null){
                    if(conCmpMap.containsKey(cmp.ContactId)){
                        Map<Id,Datetime> cmpMap=conCmpMap.get(cmp.ContactId);
                        cmpMap.put(cmp.CampaignId,cmp.LastModifiedDate);
                        conCmpMap.put(cmp.ContactId,cmpMap);    
                    }
                    else{
                        Map<Id,Datetime> cmpMap=new Map<Id,Datetime>();
                        cmpMap.put(cmp.CampaignId,cmp.LastModifiedDate);
                        conCmpMap.put(cmp.ContactId,cmpMap);    
                    }
                }
                else{
                    Map<Id,Datetime> cmpMap=new Map<Id,Datetime>();
                    cmpMap.put(cmp.CampaignId,cmp.LastModifiedDate);
                    conCmpMap.put(cmp.ContactId,cmpMap);    
                }
            }System.debug('conCmpMap : '+conCmpMap);
            
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
                conIdCmpIdMap.put(conId,cmpIdFlag);
            } */
            System.debug('conIdCmpIdMap: '+conIdCmpIdMap);
            
			List<Opportunity> toUpdateOpp = new List<Opportunity>();
           // SET<ID> keys = conIdCmpIdMap.keyset();
              for(OpportunityContactRole ocr : [SELECT Id, OpportunityId, ContactId from OpportunityContactRole  
                                               where ContactId in : conIdCmpIdMap.keySet() AND 
                                               (Opportunity.StageName =:GlobalConstants.oppStage1 OR Opportunity.StageName =:GlobalConstants.oppStg2 OR Opportunity.StageName =:GlobalConstants.oppStg3 OR Opportunity.StageName =:GlobalConstants.oppStg4)
                                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                 {
                     Opportunity  uopp = new Opportunity (id = ocr.OpportunityId, CampaignId = conIdCmpIdMap.get(ocr.ContactId) );
                     toUpdateOpp.add(uopp);
                 }
            
            update toUpdateOpp;
            
        }
        catch(Exception e){  
            system.debug('******************************* '+e);
        }   
    }
    
    
    
    
    
    
    
}