global class OpportunitySnapshotBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
	global void execute(SchedulableContext ctx) {
		database.executeBatch(new OpportunitySnapshotBatch(), 1);
	}

	global final String query;

	global OpportunitySnapshotBatch() {
		query = 'Select Id, Opportunity_ID__c, OwnerId, Opportunity_Number__c, Opportunity_Name__r.OwnerId From OpportunitySnapshot__c';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(
		Database.BatchableContext BC,
		List<OpportunitySnapshot__c> scope
	) {
		List<OpportunitySnapshot__c> oppSList = new List<OpportunitySnapshot__c>();
		for (OpportunitySnapshot__c snapshot : scope) {
			if (snapshot.OwnerId != snapshot.Opportunity_Name__r.OwnerId) {
				snapshot.OwnerId = snapshot.Opportunity_Name__r.OwnerId;
				oppSList.add(snapshot);
			}
		}
		if (!oppSList.isEmpty()) {
			update oppSList;
		}
	}

	global void finish(Database.BatchableContext BC) {
	}
}