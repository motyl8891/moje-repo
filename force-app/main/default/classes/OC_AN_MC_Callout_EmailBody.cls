/**
* @File Name          : OC_AN_MC_Callout_EmailBody
* @Description        : Added for Email Body Creation in Json format
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : U-2763, U-2782
* @Created Date       : 07th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-07                 IBM                   Initial Version
**/
public class OC_AN_MC_Callout_EmailBody {
    public static String emailJson(String bulletinId, Map<String,String> internalUserBody) {
        OC_AN_Bulletin__c bulletin = [SELECT Id, Name, OC_AN_Body_Of_Bulletin__c, OC_AN_Internal_Body_Of_Bulletin__c FROM OC_AN_Bulletin__c WHERE Id=:bulletinId LIMIT 1];
        if(bulletin==null || bulletin.OC_AN_Body_Of_Bulletin__c== '') {
            return'';
        } else {       
            OC_AN_MC_CreateEmail_JSON.Channels channel= new OC_AN_MC_CreateEmail_JSON.Channels();
            channel.email=true;
            channel.web=false;
            
            OC_AN_MC_CreateEmail_JSON.Views views = new OC_AN_MC_CreateEmail_JSON.Views();
            views.html = new OC_AN_MC_CreateEmail_JSON.Html();
            views.html.content = bulletin.OC_AN_Body_Of_Bulletin__c;
            
            if (String.isNotBlank(bulletin.OC_AN_Internal_Body_Of_Bulletin__c)){  
                views.html.content += internalUserBody.get(OC_AN_Constants.OC_AN_Bull_Internal_Body_begin) + bulletin.OC_AN_Internal_Body_Of_Bulletin__c +internalUserBody.get(OC_AN_Constants.OC_AN_Bull_Internal_Body_end);
            }
            if(internalUserBody.containsKey(OC_AN_Constants.OC_AN_Email_Subscription_Body)){
                views.html.content += + '<br/>' +internalUserBody.get(OC_AN_Constants.OC_AN_Email_Subscription_Body);
            }
            views.text = new OC_AN_MC_CreateEmail_JSON.Text();
            OC_AN_MC_CreateEmail_JSON.Text textContent= new OC_AN_MC_CreateEmail_JSON.Text();
            textContent.content = bulletin.Name;
            views.subjectline= textContent;
            views.preheader = new OC_AN_MC_CreateEmail_JSON.Text();
            
            OC_AN_MC_CreateEmail_JSON obj = new OC_AN_MC_CreateEmail_JSON();
            obj.name=bulletin.Id;
            obj.content=views.html.content;
            obj.channels = channel;
            
            obj.AssetType = new OC_AN_MC_CreateEmail_JSON.AssetType();
            obj.AssetType.name = OC_AN_Constants.BlockAssetTypeName;
            obj.AssetType.id= OC_AN_Constants.BlockAssetTypeId;
            
            return  JSON.serialize(obj);
        }
    }
}