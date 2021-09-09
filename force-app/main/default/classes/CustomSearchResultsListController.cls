/**
* @File Name          : CustomSearchResultsListController.cls
* @Description        : U-1278 (Handelling link click with thumbs up/down on search result component)
* @Author             : Ankit Jain
* @Group              : 
* @Last Modified By   : Ankit Jain
* @Last Modified On   : 
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0    2019-9-16 16:02:32  		 Ankit Jain   			  Initial Version
  		 2020-03-19					 Rohit Gaba				  To add the support of external Search to Internal User
		 2020-05-08                  Rohit Gaba		          R20_06 D-2836 ExtranetAPIClickFix(U-1663)
		 2020-12-02                  Janani					  Retrieve the data from the Custom Setting  - OC_Console_UtilityItem_Placeholder__c
         2021-02-23                  Subashini Arulalan       U-2470 To Add Realuser and User parameters in the clickURL sent to GST
**/
public without sharing class CustomSearchResultsListController {
	/****************************************************************
* @author: Ankit Jain
* @date: 2019-09-16
* @param: communitySearchId
* @description: This method sends the title click to GST API

* @Modification: Rohit Gaba
* @date: 2020-03-19
* @param added: searchAs, chatTranscriptId
* @description: R2004, US-1617 To add the support of external Search to Internal User

* @Modification: Janani
* @date: 2020-12-02
* @method added: getServiceConsolePlaceholders
* @description: Retrieve the data from the Custom Setting  - OC_Console_Placeholder__c
*****************************************************************/
	@AuraEnabled
	public static String updateClick(
		String communitySearchId,
		String searchAs,
		String chatTranscriptId
	) {
		String returnValue = null;
		try {
			CustomSearchController.SearchResultWrapper searchResultWrapper = (CustomSearchController.SearchResultWrapper) JSON.deserialize(
				communitySearchId,
				CustomSearchController.SearchResultWrapper.class
			);
			Map<String, GST_API_Details__c> mapGSTCS = GST_API_Details__c.getAll();
			String profileId = UserInfo.getProfileId();
			User usr = [
				SELECT id, FederationIdentifier
				FROM user
				WHERE id = :UserInfo.getUserId()
				LIMIT 1
			];
			String realUser = usr.FederationIdentifier.replace(
				GSTSearchConstantsUtility.AND_SIGN,
				GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
			);
			String gstUserSignum = realUser;
			String returnedClickUrl = searchResultWrapper.uri_tree;
			String headerVal = '';
			String siteId = Site.getSiteId();
			Http http = new Http();
			HttpRequest request = new HttpRequest();

			Http http1 = new Http();
			HttpRequest request1 = new HttpRequest();

			//U-2470 Added by Subashini Arulalan
            String clickUrl =searchResultWrapper.x_clickurl;

			//R2004, US-1617, 2020-03-19, Rohit Gaba To add the support of external Search to Internal User
			//R20_06, D-2836, 2020-05-08, Rohit Gaba ExtranetAPIClickFix(U-1663)
			/*Security: Check first if user is external. If not, then only consider searchAs scenario.*/
			//ExtarnerGroup API Call with External User
			if (
				profileId.startsWith(
					mapGSTCS.get(GSTSearchConstantsUtility.CS_EXTERNAL_PROFILE).Value__c
				)
			) {
				request1.setEndpoint(
					searchResultWrapper.uri +
					GSTSearchConstantsUtility.USER_PARAM +
					gstUserSignum
				);
				headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Community)
					.Value__c;
			} else if (!String.isBlank(searchAs) && searchAs == 'External') {
				//R20_06, D-2836, 2020-05-08, Rohit Gaba ExtranetAPIClickFix(U-1663)
				//ExtarnerGroup API Call with Internal user posing as External User
				//NoRowException will be captured by catch block and will be logged.
				usr = [
					SELECT id, FederationIdentifier
					FROM user
					WHERE
						contactid = :[
							SELECT ContactId
							FROM LiveChatTranscript
							WHERE Id = :chatTranscriptId
							LIMIT 1
						]
						.ContactId
					LIMIT 1
				];
                // LPAS-65, 2020-12-03, Subashini Arulalan Changes made to capture the realuser value and gstUserSignum 
				realUser = usr.FederationIdentifier.replace(
					GSTSearchConstantsUtility.AND_SIGN,
					GSTSearchConstantsUtility.AND_SIGN_REPLACEMEENT
				);
                gstUserSignum = realUser;
				request1.setEndpoint(
					searchResultWrapper.uri +
					GSTSearchConstantsUtility.USER_PARAM +
					gstUserSignum
				);
				headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Console)
					.Value__c;
			} else {
				//R2004, US-1667, 2020-03-18 Rohit Gaba Internal Users should see correct CPI endpoints, a ExtranetGroup API call facilitated as External Users
				//R20_06, D-2836, 2020-05-08, Rohit Gaba ExtranetAPIClickFix(U-1663)
				//ExtarnerGroup API Call with Internal user
				
				//LPAS-65, 2020-12-03, Subashini Arulalan Added the gstUserSignum variable to get the value for internalUser search 
				gstUserSignum = mapGSTCS.get(GSTSearchConstantsUtility.CS_INTERNAL_USER_SIGNUM)
						.Value__c;
				request1.setEndpoint(
					searchResultWrapper.uri +
					GSTSearchConstantsUtility.USER_PARAM +
					mapGSTCS.get(GSTSearchConstantsUtility.CS_INTERNAL_USER_SIGNUM)
						.Value__c
				);
				if (siteId != null) {
					headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Community)
						.Value__c;
				} else {
					headerVal = mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Console)
						.Value__c;
				}
			}
			//U-2470 Added by Subashini Arulalan for sending params to clicklogs callout
            Integer indexNumber = clickUrl.indexOf(GSTSearchConstantsUtility.getclickurl_Index);
            clickUrl = clickUrl.substring(0,indexNumber) + GSTSearchConstantsUtility.clickurl_realuser + GSTSearchConstantsUtility.EQUAL_SIGN_REPLACEMENT +
                realUser + GSTSearchConstantsUtility.clickurl_user + GSTSearchConstantsUtility.EQUAL_SIGN_REPLACEMENT +
                gstUserSignum + clickUrl.substring(indexNumber);
                   
            String gSTClickUpdateUrl = mapGSTCS.get(GSTSearchConstantsUtility.CS_BASE_URL).Value__c +
                clickUrl +
                GSTSearchConstantsUtility.TOKEN_PARAM +
                mapGSTCS.get(GSTSearchConstantsUtility.CS_TOKEN_PARAM).Value__c;
            //U-2470 Ends here

			request1.setHeader(
				GSTSearchConstantsUtility.AUTHORIZATION,
				GSTSearchConstantsUtility.BASIC +
				EncodingUtil.base64Encode(
					Blob.valueOf(
						mapGSTCS.get(GSTSearchConstantsUtility.CS_Click_Base_URL_USR)
							.Value__c +
						GSTSearchConstantsUtility.COLON +
						mapGSTCS.get(GSTSearchConstantsUtility.CS_Click_Base_URL_PWD)
							.Value__c
					)
				)
			);
			request1.setHeader(
				GSTSearchConstantsUtility.HEADER_TOKEN_PARAM,
				mapGSTCS.get(GSTSearchConstantsUtility.CS_HEADER_TOKEN_PARAM).Value__c
			);
			//R20_06, D-2836, 2020-05-08, Rohit Gaba ExtranetAPIClickFix(U-1663)
			request1.setHeader(
				mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Header).Value__c,
				headerVal
			);
			request1.setMethod(GSTSearchConstantsUtility.GET);
			HttpResponse response1 = http1.send(request1);

			if (response1.getStatusCode() == 200) {
				returnedClickUrl = response1.getBody();
				Integer indexStartUriTree = gSTClickUpdateUrl.indexOf(
					GSTSearchConstantsUtility.URI_TREE_START
				);
				Integer indexEndUriTree = gSTClickUpdateUrl.indexOf(
					GSTSearchConstantsUtility.URI_TREE_END,
					indexStartUriTree
				);
				gSTClickUpdateUrl.replace(
					gSTClickUpdateUrl.substring(indexStartUriTree + 20, indexEndUriTree),
					EncodingUtil.urlEncode(
						returnedClickUrl,
						GSTSearchConstantsUtility.UTF_ENCODE
					)
				);
			}

			request.setEndpoint(gSTClickUpdateUrl);
			request.setMethod(GSTSearchConstantsUtility.GET);
			request.setHeader(
				GSTSearchConstantsUtility.HEADER_TOKEN_PARAM,
				mapGSTCS.get(GSTSearchConstantsUtility.CS_HEADER_TOKEN_PARAM).Value__c
			);
			//Added by Subashini Arulalan for GST connection
            request.setHeader(
				mapGSTCS.get(GSTSearchConstantsUtility.Referrer_Header).Value__c,
				headerVal
			);
			HttpResponse response = http.send(request);

			returnValue = returnedClickUrl;
			//return returnedClickUrl;
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GSTSearchConstantsUtility.CustomSearchResultsListController,
						GSTSearchConstantsUtility.updateClick,
						GSTSearchConstantsUtility.CustomSearchResultsListController,
						true,
						e
					)
				)
			);
			returnValue = GSTSearchConstantsUtility.HASH;
			//return GSTSearchConstantsUtility.HASH;
		}
		return returnValue;
	}

	/****************************************************************
	 * @author: Ankit Jain
	 * @date: 2019-12-5
	 * @param: communitySearchId
	 * @description: This method gets the URL to respective post
	 *****************************************************************/
	@AuraEnabled
	public static String updateForumClick(String communitySearchId) {
		String returnValue = null;
		try {
			CustomSearchController.SearchResultWrapper searchResultWrapper = (CustomSearchController.SearchResultWrapper) JSON.deserialize(
				communitySearchId,
				CustomSearchController.SearchResultWrapper.class
			);
			returnValue = searchResultWrapper.uri_tree;
			//return returnedClickUrl;
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GSTSearchConstantsUtility.CustomSearchResultsListController,
						GSTSearchConstantsUtility.updateForumClick,
						GSTSearchConstantsUtility.CustomSearchResultsListController,
						true,
						e
					)
				)
			);
			returnValue = GSTSearchConstantsUtility.HASH;
			//return GSTSearchConstantsUtility.HASH;
		}
		return returnValue;
	}

	/****************************************************************
	 * @author: Ankit Jain
	 * @date: 2019-09-16
	 * @param: communitySearchId,likeFlag
	 * @description: This method sends the like/dislike click to GST API
	 *****************************************************************/
	@AuraEnabled
	public static String updateLikeClick(
		String communitySearchId,
		Boolean likeFlag
	) {
		String returnValue = GSTSearchConstantsUtility.FAILED;
		try {
			CustomSearchController.SearchResultWrapper searchResultWrapper = (CustomSearchController.SearchResultWrapper) JSON.deserialize(
				communitySearchId,
				CustomSearchController.SearchResultWrapper.class
			);
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			Map<String, GST_API_Details__c> mapGSTCS = GST_API_Details__c.getAll();
			String gSTLikeDislikeUrl =
				mapGSTCS.get(GSTSearchConstantsUtility.CS_BASE_URL).Value__c +
				searchResultWrapper.x_clickurl +
				GSTSearchConstantsUtility.TOKEN_PARAM +
				mapGSTCS.get(GSTSearchConstantsUtility.CS_TOKEN_PARAM).Value__c;
			request.setEndpoint(
				gSTLikeDislikeUrl.replace(
					GSTSearchConstantsUtility.MISC_INITIAL,
					GSTSearchConstantsUtility.MISC_REPLACE +
					(likeFlag
						? GSTSearchConstantsUtility.POSITIVE
						: GSTSearchConstantsUtility.NEGATIVE) +
					GSTSearchConstantsUtility.MISC_REPLACE_REMAINING
				)
			);
			request.setHeader(
				GSTSearchConstantsUtility.HEADER_TOKEN_PARAM,
				mapGSTCS.get(GSTSearchConstantsUtility.CS_HEADER_TOKEN_PARAM).Value__c
			);
			request.setMethod(GSTSearchConstantsUtility.GET);
			HttpResponse response = http.send(request);
			if (response.getStatusCode() == 200) {
				returnValue = GSTSearchConstantsUtility.SUCCESS;
				//return GSTSearchConstantsUtility.SUCCESS;
				//  System.debug('Click Updated Successful'+response.getBody());
				/*GstCustomSearchResultAction__c gstCustomSearchResultAction=new GstCustomSearchResultAction__c();
gstCustomSearchResultAction.Abstract__c=searchResultWrapper.abstract_z;
gstCustomSearchResultAction.Search_Results_Date__c=searchResultWrapper.dater;
gstCustomSearchResultAction.Title__c=searchResultWrapper.title;
gstCustomSearchResultAction.Uritree__c=searchResultWrapper.uri_tree;
gstCustomSearchResultAction.Format__c=searchResultWrapper.format;
gstCustomSearchResultAction.User_Clicks__c=true;
Database.insert(gstCustomSearchResultAction);*/
			}
			// returnValue=GSTSearchConstantsUtility.FAILED;
			// return GSTSearchConstantsUtility.FAILED;
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GSTSearchConstantsUtility.CustomSearchResultsListController,
						GSTSearchConstantsUtility.updateLikeClick,
						GSTSearchConstantsUtility.CustomSearchResultsListController,
						true,
						e
					)
				)
			);
			returnValue = GSTSearchConstantsUtility.FAILED;
			//return GSTSearchConstantsUtility.FAILED;
			//Exception handelling code
			// throw new AuraHandledException(e.getMessage());
		}
		return returnValue;
	}
	
    /****************************************************************
	 * @Modification: Janani
     * @date: 2020-12-02
     * @method added: getServiceConsolePlaceholders
     * @description: Retrieve the data from the Custom Setting  - OC_Console_Placeholder__c
	 *****************************************************************/
    
    @AuraEnabled
    public static Map<String, OC_Console_Placeholder__c> getServiceConsolePlaceholders(){
        return OC_Console_Placeholder__c.getAll();
    }
}