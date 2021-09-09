/**
* @File Name          : OC_ContentControllerSubGSTClickTemp
* @Description        : This will serve the CPI Docuement click search for New UI. This method will be temporary as optimization for GST APIs in process for Metis and Forum results user stories
* @Author             : Rohit Gaba
* @Group              : OmniChannel - Service
* @Created Date       : 22nd April 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-04-22              Rohit Gaba               Initial Version
*            2021-02-23              Subashini Arulalan       U-2470 To Add the callout for sending clickURL to GST
*/   
public class OC_ContentControllerSubGSTClickTemp {
    //This class will be removed after GST APIs optimization
    //Get the CPI Docuement URL from GST Extranet API.
    /****************************************************************
    * @author: Subashini Arulalan
    * @date: 2020-12-16
    * @param added: GSTclickURL,gSTClickUpdateUrl
    * @description: LPAS-65 To Add the callout for sending clickURL to GST
    *****************************************************************/
       
        public static String updateClick(String uri, String uri_tree, String searchAs, String chatTranscriptId, String GSTclickURL) {
            String returnValue=null;
            try{
                
                Map<String, GST_API_Details__c> mapGSTCS = GST_API_Details__c.getAll();
                String profileId=UserInfo.getProfileId();
                User usr=[select id,FederationIdentifier from user where id=:UserInfo.getUserId() limit 1];
                String realUser=usr.FederationIdentifier.replace(GSTSearchConstantsUtility.AND_SIGN, GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT);
                String gstUserSignum=realUser;
                String returnedClickUrl=uri_tree;
                String headerVal = '';
                String siteId = Site.getSiteId();
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                
                //R2004, US-1617, 2020-03-19, Rohit Gaba To add the support of external Search to Internal User
                /*Security: Check first if user is external. If not, then only consider searchAs scenario.*/
                //ExtarnerGroup API Call with External User
                if(profileId.startsWith(mapGSTCS.get(GSTSearchConstantsUtility.CS_EXTERNAL_PROFILE).Value__c)){
                    request.setEndpoint(uri+GSTSearchConstantsUtility.USER_PARAM+gstUserSignum);
                    headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Community).Value__c;
                }
                //ExtarnerGroup API Call with Internal user posing as External User
                else if(!String.isBlank(searchAs) && searchAs == 'External'){
                    //NoRowException will be captured by catch block and will be logged.
                    usr=[select id,FederationIdentifier from user where contactid = :[Select ContactId from LiveChatTranscript where Id = :chatTranscriptId limit 1 ].ContactId limit 1];
                    realUser=usr.FederationIdentifier.replace(GSTSearchConstantsUtility.AND_SIGN, 
                                                              GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT);
                    gstUserSignum = realUser;
                    request.setEndpoint(uri+GSTSearchConstantsUtility.USER_PARAM+gstUserSignum);
                    headerVal=mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Console).Value__c;
                }
                //R2004, US-1667, 2020-03-18 Rohit Gaba Internal Users should see correct CPI endpoints, a ExtranetGroup API call facilitated as External Users
                //ExtarnerGroup API Call with Internal user
                else{
                    gstUserSignum = mapGSTCS.get(GSTSearchConstantsUtility.CS_INTERNAL_USER_SIGNUM).Value__c;
                    request.setEndpoint(uri+GSTSearchConstantsUtility.USER_PARAM+mapGSTCS.get(GSTSearchConstantsUtility.CS_INTERNAL_USER_SIGNUM).Value__c);
                    if(siteId != null){
                        headerVal=mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Community).Value__c;
                    }    
                    else{
                        headerVal=mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Console).Value__c;
                    }
                }
                //U-2470 Subashini - Addeded to form the click URL send to GST 
                Integer indexNumber = GSTclickURL.indexOf(GSTSearchConstantsUtility.getclickurl_Index);
                GSTclickURL = GSTclickURL.substring(0,indexNumber) + GSTSearchConstantsUtility.clickurl_realuser + GSTSearchConstantsUtility.EQUAL_SIGN_REPLACEMENT +
                realUser + GSTSearchConstantsUtility.clickurl_user + GSTSearchConstantsUtility.EQUAL_SIGN_REPLACEMENT +
				gstUserSignum + GSTclickURL.substring(indexNumber);
            
                String gSTClickUpdateUrl = mapGSTCS.get(GSTSearchConstantsUtility.CS_BASE_URL).Value__c + GSTclickURL +GSTSearchConstantsUtility.TOKEN_PARAM + mapGSTCS.get(GSTSearchConstantsUtility.CS_TOKEN_PARAM).Value__c;
			    // U-2470 changes ends here                               
                request.setHeader(GSTSearchConstantsUtility.AUTHORIZATION, GSTSearchConstantsUtility.BASIC + EncodingUtil.base64Encode(Blob.valueOf(mapGSTCS.get(GSTSearchConstantsUtility.CS_Click_Base_URL_USR).Value__c + GSTSearchConstantsUtility.COLON + mapGSTCS.get(GSTSearchConstantsUtility.CS_Click_Base_URL_PWD).Value__c)));
                request.setHeader(GSTSearchConstantsUtility.HEADER_TOKEN_PARAM,mapGSTCS.get(GSTSearchConstantsUtility.CS_HEADER_TOKEN_PARAM).Value__c);
                request.setHeader(mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Header).Value__c,headerVal);
                request.setMethod(GSTSearchConstantsUtility.GET);
                HttpResponse response = http.send(request);
    
                if (response.getStatusCode() == 200) {
                    returnedClickUrl=response.getBody();
                }
                
                //LPAS-65 Subashini - Addeded the callout part to send click URL to GST
                Http http1 = new Http();
                HttpRequest request1 = new HttpRequest();
                
                request1.setEndpoint(gSTClickUpdateUrl);
                request1.setMethod(GSTSearchConstantsUtility.GET);
                request1.setHeader(GSTSearchConstantsUtility.HEADER_TOKEN_PARAM,mapGSTCS.get(GSTSearchConstantsUtility.CS_HEADER_TOKEN_PARAM).Value__c);
                //Added by Subashini Arulalan for GST connection
                request1.setHeader(mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Header).Value__c,headerVal);
			    HttpResponse response1 = http1.send(request1);
               //LPAS-65 changes - ends here
               
                returnValue=returnedClickUrl;
            }
            catch(Exception e){
                EventLog.createLogFuture(Json.serialize(new EventLog.Error(GSTSearchConstantsUtility.CustomSearchResultsListController,GSTSearchConstantsUtility.updateClick, GSTSearchConstantsUtility.CustomSearchResultsListController, true, e))); 
                returnValue=GSTSearchConstantsUtility.HASH;
            }
            return returnValue;
        }
    }