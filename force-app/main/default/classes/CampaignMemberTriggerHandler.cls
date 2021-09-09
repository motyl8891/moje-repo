/******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This class is a handler class for CampaignMember Trigger (U-1032)
********************************************************************/
public class CampaignMemberTriggerHandler {
     /******************************************************************* 
* @author: Manu Singhal
* @date: 2019-06-20 
* @description: This method will be called before insertion from CampaignMember Trigger (U-1032)
********************************************************************/
    public static void OnBeforeInsert(List<CampaignMember> newCampaignMembers){
        CampaignMemberTriggerHelper.addStatustoCampaignMembers(newCampaignMembers);
    }
    public static void OnAfterInsert(List<CampaignMember> newCampaignMembers){
        CampaignMemberTriggerHelper.updateContactOnOpp(newCampaignMembers);
    }
}