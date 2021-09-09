/*******************************************************************
 * @author: Bhushan K
 * @date: 2019-11-05
 * @description: This is the controller class for the Custom Pre Chat Form
 ********************************************************************/
public class PreChatFormApexController {
	@AuraEnabled
	public static Contact searchForEmail() {
		Contact con = [
			SELECT Id, Email, Queue_Name__c, FirstName, LastName
			FROM Contact
			WHERE Email = :UserInfo.getUserEmail()
			LIMIT 1
		];
		system.debug('contact--->' + con);
		return con;
	}
}