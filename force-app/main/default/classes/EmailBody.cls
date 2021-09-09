public class EmailBody {
    public static String emailJson(String bulletinId,Map<String,String> internalUserBody){
        
        OC_AN_Bulletin__c bulletin = [Select Id,Name,OC_AN_Body_Of_Bulletin__c,OC_AN_Internal_Body_Of_Bulletin__c from OC_AN_Bulletin__c where Id=:bulletinId LIMIT 1];
        
        if(bulletin==null || bulletin.OC_AN_Body_Of_Bulletin__c== ''){
            return'';
        }else{       
            OC_AN_MC_CreateEmail_JSON obj = new OC_AN_MC_CreateEmail_JSON();
            
            OC_AN_MC_CreateEmail_JSON.Channels channel= new OC_AN_MC_CreateEmail_JSON.Channels();
            channel.email=true;
            channel.web=false;
            
            OC_AN_MC_CreateEmail_JSON.Views views = new OC_AN_MC_CreateEmail_JSON.Views();
            views.html = new OC_AN_MC_CreateEmail_JSON.Html();
            views.html.content = bulletin.OC_AN_Body_Of_Bulletin__c;
            obj.content = bulletin.OC_AN_Body_Of_Bulletin__c;
            
            if (String.isNotBlank(bulletin.OC_AN_Internal_Body_Of_Bulletin__c)){  
                views.html.content += internalUserBody.get(OC_AN_Constants.OC_AN_Bull_Internal_Body_begin) + bulletin.OC_AN_Internal_Body_Of_Bulletin__c +internalUserBody.get(OC_AN_Constants.OC_AN_Bull_Internal_Body_end);
                obj.content += internalUserBody.get(OC_AN_Constants.OC_AN_Bull_Internal_Body_begin) + bulletin.OC_AN_Internal_Body_Of_Bulletin__c +internalUserBody.get(OC_AN_Constants.OC_AN_Bull_Internal_Body_end);
            }
            // List<OC_AN_Bulletin_Account_Product__c> productList = [SELECT Name,OC_AN_Product__r.Name,
            //                                                        OC_AN_Release__c,
            //                                                        OC_AN_Release__r.Name,
            //                                                        OC_AN_Verison__c,
            //                                                        OC_AN_Verison__r.Name
            //                                                        FROM OC_AN_Bulletin_Account_Product__c
            //                                                        WHERE OC_AN_Bulletin__c =:bulletinId
            //                                                        AND OC_AN_Product__c!= null
            //                                                        AND RecordTypeId = '0121l000000DgjnAAC'
            //                                                       ];//Record Type Id for bulletin type
            
            // if(!productList.isEmpty())
            // {
            //     String productDetails = '<head><style>table, th, td {border: 1px solid black;}</style></head><body><table><tr><th>Product</th><th>Release</th><th>Version</th></tr>';
            //     for(OC_AN_Bulletin_Account_Product__c bullProdList :productList){
                    
            //         productDetails +='<tr><td>'+bullProdList.OC_AN_Product__r.Name+'</td><td>';
            //         if(String.isNotBlank(bullProdList.OC_AN_Release__c)){
            //             productDetails +=bullProdList.OC_AN_Release__r.Name;
            //         }
            //         productDetails +='</td> <td>';
            //         if(String.isNotBlank(bullProdList.OC_AN_Verison__c)){
            //             productDetails +=bullProdList.OC_AN_Verison__r.Name;
            //         }
            //         productDetails +='</td> </tr>';
            //     }
            //     productDetails +='</table></body>';
            //     views.html.content += + '<br/>' +productDetails;
            // }
            views.html.content += + '<br/>' +internalUserBody.get(OC_AN_Constants.OC_AN_Email_Subscription_Body);
            obj.content += + '<br/>' +internalUserBody.get(OC_AN_Constants.OC_AN_Email_Subscription_Body);
            
            views.text = new OC_AN_MC_CreateEmail_JSON.Text();
            OC_AN_MC_CreateEmail_JSON.Text textContent= new OC_AN_MC_CreateEmail_JSON.Text();
            textContent.content = bulletin.Name;
            views.subjectline= textContent;
            views.preheader = new OC_AN_MC_CreateEmail_JSON.Text();
            
            // obj.name=bulletin.Name+'_'+bulletin.Id;
            obj.name=bulletin.Id;
            obj.channels = channel;
            // obj.content = views.html.content;
            obj.views=views;
            obj.AssetType = new OC_AN_MC_CreateEmail_JSON.AssetType();
            obj.AssetType.name = OC_AN_Constants.BlockAssetTypeName;
            obj.AssetType.id= OC_AN_Constants.BlockAssetTypeId;
            system.debug('JSON.serialize ==>' +JSON.serialize(obj));
            return  JSON.serialize(obj);
        }
    }
}