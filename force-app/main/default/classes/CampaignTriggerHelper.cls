/******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This class is a helper class for CampaignTriggerHandler (U-1032)
********************************************************************/
public without sharing class CampaignTriggerHelper {
    /******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This method will add CampaignMemberStatus records to campaign if campaign is created by Marketo Sync User (U-1032)
********************************************************************/
 public static void addCMStatustoCampaign(List<Campaign> newCampaigns){ 
        Set<id> createdByIdSet = new Set<id>();
        Set<id> campIdSet = new Set<id>();
        Map<id,String> userWithUserNameMap = new Map<id,String>();
        List<CampaignMemberStatus> cmsListToInsert = new List<CampaignMemberStatus>();
        List<CampaignMemberStatus> cmsListToDelete = new List<CampaignMemberStatus>();
        String username;
        try{
            /*if(test.isRunningTest() == true)
                username = GlobalConstants.MarketoUserName;
            else */
                username = GlobalConstants.MarketoSyncUserName;
            for(Campaign camp : newCampaigns) 
            {
                createdByIdSet.add(camp.CreatedById);
            }
            if(!createdByIdSet.isEmpty())
            {
                for(User user:[SELECT Id,Username
                               FROM User where Id in: createdByIdSet
                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    userWithUserNameMap.put(user.id, user.Username);
                }
                for(Campaign camp : newCampaigns)
                {
                    if(userWithUserNameMap.get(camp.CreatedById) == username)
                    {
                        campIdSet.add(camp.id);
                        for(String status : GlobalConstants.campaignMemberStatus.split(GlobalConstants.SEMICOLON))
                        {        
                            CampaignMemberStatus cms = new CampaignMemberStatus();
                            cms.Label = status;
                            cms.CampaignId = camp.id;
                            if(status == GlobalConstants.MEMBER)
                                cms.IsDefault = true;
                            if(status == GlobalConstants.CONVERTED)
                                cms.HasResponded = true;
                            cmsListToInsert.add(cms);
                        } 
                    }
                }
                
            }
            if(!campIdSet.isEmpty())   
            {
                cmsListToDelete = [Select id from CampaignMemberStatus where CampaignId in :campIdSet
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            }  
            if(!cmsListToInsert.isEmpty())
                database.insert(cmsListToInsert);
            if(!cmsListToDelete.isEmpty())
                database.delete(cmsListToDelete);
        }
        catch(Exception e){  
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.CAMPAIGNTRIGGERHELPER, 
                                                                       GlobalConstants.ADDCMSSTATUSTOCAMPAIGN, GlobalConstants.CAMPAIGNTRIGGERHELPER, true, e)));
        }
    }
}