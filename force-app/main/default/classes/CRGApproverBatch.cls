global class CRGApproverBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
	global void execute(SchedulableContext ctx) {
		database.executeBatch(new CRGApproverBatch(), 1);
	}

	global final String query;
	global CRGApproverBatch() {
		query = 'SELECT Id, Account_Primary_KAM__c, Account_CU_Head__c, Update_Opportunity_Approvers__c FROM CustomerReportingGroup__c WHERE Update_Opportunity_Approvers__c = true';
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(
		Database.BatchableContext BC,
		List<CustomerReportingGroup__c> scope
	) {
		Map<Id, CRGApprovers> mapCRGApprovers = new Map<Id, CRGApprovers>();
		for (CustomerReportingGroup__c changedCRG : scope) {
			changedCRG.Update_Opportunity_Approvers__c = false;
			changedCRG.Valid_KAM_CU_Head_Approvers__c = false;
			mapCRGApprovers.put(
				changedCRG.ID,
				new CRGApprovers(
					changedCRG.Account_Primary_KAM__c,
					changedCRG.Account_CU_Head__c
				)
			);
		}

		List<Opportunity> opptyList = new List<Opportunity>();
		if (mapCRGApprovers != null) {
			opptyList = CustomerReportingGroupApproverHelper.updateOpptyCRGUsers(
				mapCRGApprovers
			);
		}

		update opptyList;
		update scope;
	}

	global void finish(Database.BatchableContext BC) {
	}
}