/******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This class is a handler class for Campaign Trigger (U-1032)
********************************************************************/
public without sharing class CampaignTriggerHandler {
    /******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This method will be called after insertion from Campaign Trigger (U-1032)
********************************************************************/
    public static void OnAfterInsert(List<Campaign> newCampaigns){ 
        CampaignTriggerHelper.addCMStatustoCampaign(newCampaigns);
    }
}