/*******************************************************************
 * @author: Manu Singhal
 * @date: 2019-03-12
 * @description: U-1339
 ********************************************************************/
global class DeleteInactiveContactsBatch implements Database.Batchable<sObject>, Schedulable {
	/****************************************************************
	 * @author: Manu Singhal
	 * @date: 2019-03-12
	 * @param: SchedulableContext ctx
	 * @description: Execute Method of Scheduler
	 *****************************************************************/
	global void execute(SchedulableContext ctx) {
		database.executeBatch(new DeleteInactiveContactsBatch(), 50);
	}
	/****************************************************************
	 * @author: Manu Singhal
	 * @date: 2019-03-12
	 * @param: Database.BatchableContext
	 * @description: Start Method of Batch
	 *****************************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		//Date today = Date.today().addMonths(12);
		//String query='SELECT Id,Inactive__c,InactiveDate__c FROM Contact WHERE Inactive__c = true  and InactiveDate__c >= today';
		Date deleteDate = system.today().addMonths(-12);
		String query = 'SELECT Id,Inactive__c,InactiveDate__c FROM Contact WHERE Inactive__c = true  and InactiveDate__c <=:deleteDate';
		return Database.getQueryLocator(query);
	}
	/****************************************************************
	 * @author: Manu Singhal
	 * @date: 2019-03-12
	 * @param: Database.BatchableContext, List<Contact> contactList
	 * @description: Execute Method of Batch
	 *               1. Delete Invalid Contacts
	 *****************************************************************/
	global void execute(Database.BatchableContext BC, List<Contact> contactList) {
		if (!contactList.isEmpty()) {
			database.delete(contactList);
		}
	}
	/****************************************************************
	 * @author: Manu Singhal
	 * @date: 2019-03-12
	 * @param: Database.BatchableContext
	 * @description: Finish Method of Batch
	 *****************************************************************/
	global void finish(Database.BatchableContext BC) {
	}
}