global class CustomerUnitATSRecalcBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
	global void execute(SchedulableContext ctx) {
		database.executeBatch(new CustomerUnitATSRecalcBatch(), 10);
	}

	global final String query;

	global CustomerUnitATSRecalcBatch() {
		query = 'SELECT Id FROM Account WHERE Requires_ATS_Batch_Recalculation__c = true';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<Account> scope) {
		System.debug('scope size ' + scope.size());
		Set<Id> accIdSet = new Set<Id>();
		for (Account acc : scope) {
			accIdSet.add(acc.Id);
			acc.Requires_ATS_Batch_Recalculation__c = false;
		}
		CustomerUnitTriggerHandlerHelper.triggerOpportunitiesUpdate(accIdSet);
		update scope;
	}

	global void finish(Database.BatchableContext BC) {
	}
}