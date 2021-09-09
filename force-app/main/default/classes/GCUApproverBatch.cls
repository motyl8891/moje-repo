global class GCUApproverBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
	global void execute(SchedulableContext ctx) {
		database.executeBatch(new GCUApproverBatch(), 1);
	}

	global final String query;

	global GCUApproverBatch() {
		query = 'SELECT Id, GCU_Commercial_Head__c, GCU_Head__c, ApproversChanged__c FROM CustomerUnit__c WHERE ApproversChanged__c = true';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(
		Database.BatchableContext BC,
		List<CustomerUnit__c> scope
	) {
		Map<Id, GCUApprovers> mapGCUApprovers = new Map<Id, GCUApprovers>();
		for (CustomerUnit__c changedCU : scope) {
			changedCU.ApproversChanged__c = false;
			mapGCUApprovers.put(
				changedCU.ID,
				new GCUApprovers(
					changedCU.GCU_Head__c,
					changedCU.GCU_Commercial_Head__c
				)
			);
		}
		List<Opportunity> opptyList = new List<Opportunity>();
		if (mapGCUApprovers != null) {
			opptyList = CustomerUnitApproverHelper.updateOpptyGCUUsers(
				mapGCUApprovers
			);
		}
		update opptyList;
		update scope;
	}

	global void finish(Database.BatchableContext BC) {
	}
}