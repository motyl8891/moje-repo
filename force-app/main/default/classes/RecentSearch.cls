/**
 * @File Name          : RecentSearch.cls
 * @Description        : U-1146 (Fetching last 5 search for the respective User)
 * @Author             : Ankit Jain
 * @Group              :
 * @Last Modified By   : Ankit Jain
 * @Last Modified On   :
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    2019-9-16 16:02:32  		 Ankit Jain   			  Initial Version
 **/
public without sharing class RecentSearch {
	/****************************************************************
	 * @author: Ankit Jain
	 * @date: 2019-09-16
	 * @param:
	 * @description: This method is to fetch last 5 search details for specific User
	 *****************************************************************/
	@AuraEnabled
	public static List<GstCustomSearch__c> recentsearchresult() {
		List<GstCustomSearch__c> searchlist;
		try {
			String userID = UserInfo.getUserId();
			//String sessionID=UserInfo.getSessionId();
			searchlist = [
				SELECT id, Search_String__c
				FROM GstCustomSearch__c
				WHERE CreatedById = :userID
				ORDER BY CreatedDate DESC
				LIMIT 5
			];
			System.debug('searchlist' + searchlist.size());
			return searchlist;
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GSTSearchConstantsUtility.RECENTSEARCH,
						GSTSearchConstantsUtility.RECENTSEARCHRESULT,
						GSTSearchConstantsUtility.RECENTSEARCH,
						true,
						e
					)
				)
			);
			return searchlist;
		}
	}
}