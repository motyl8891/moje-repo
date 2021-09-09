/*******************************************************************
* @author: Anurkiti
* @date: 2019-07-10
* @description: U-1059 U-1287
                1. Update Kam, CU head, GCU Commercial Head, GCU Head, GCU KAm on Opportunity
********************************************************************/
global class CRGAndGCUApproverBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
	Map<Id, CustomerReportingGroup__c> CRGMap = new Map<Id, CustomerReportingGroup__c>();
	Set<Id> updateAccIdSet = new Set<Id>();
	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-07-10
	 * @param: SchedulableContext ctx
	 * @description: Execute Method of Scheduler
	 *****************************************************************/
	global void execute(SchedulableContext ctx) {
		database.executeBatch(new CRGAndGCUApproverBatch(), 1);
	}
	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-07-10
	 * @param: Database.BatchableContext
	 * @description: Start Method of Batch
	 *****************************************************************/
	global Database.QueryLocator start(Database.BatchableContext BC) {
		List<CustomerUnit__c> CUList = [
			SELECT
				Id,
				GCU_Commercial_Head__c,
				GCU_Head__c,
				GCU_KAM__c,
				ApproversChanged__c
			FROM CustomerUnit__c
			WHERE ApproversChanged__c = true
			LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
		];
		CRGMap = new Map<Id, CustomerReportingGroup__c>(
			[
				SELECT
					Id,
					Account_Primary_KAM__c,
					Account_CU_Head__c,
					Update_Opportunity_Approvers__c,
					GlobalCustomerUnit__c,
					GlobalCustomerUnit__r.ApproversChanged__c,
					GlobalCustomerUnit__r.GCU_Commercial_Head__c,
					GlobalCustomerUnit__r.GCU_Head__c,
					GlobalCustomerUnit__r.GCU_KAM__c
				FROM CustomerReportingGroup__c
				WHERE
					Update_Opportunity_Approvers__c = true
					OR GlobalCustomerUnit__c IN :CUList
				LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
			]
		);
		Set<Id> CRGSet = CRGMap.keySet();
		String query = 'SELECT Id, CustomerReportingGroup__c FROM Account WHERE CustomerReportingGroup__c IN : CRGSet';
		return Database.getQueryLocator(query);
	}
	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-07-10
	 * @param: Database.BatchableContext, List<Account> accList
	 * @description: Execute Method of Batch
	 *               1. Update fields on Opp
	 *****************************************************************/
	global void execute(Database.BatchableContext BC, List<Account> accList) {
		Map<Id, Id> accIdToCRGMap = new Map<Id, Id>();
		for (Account acc : accList) {
			accIdToCRGMap.put(acc.Id, acc.CustomerReportingGroup__c);
		}
		Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>(
			[
				SELECT Id, AccountId
				FROM Opportunity
				WHERE
					StageName IN :GlobalConstants.validCloneStage
					AND AccountId IN :accIdToCRGMap.keySet()
				LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
			]
		);

		if (!opptyMap.isEmpty()) {
			for (Opportunity opp : opptyMap.values()) {
				if (
					CRGMap.get(accIdToCRGMap.get(opp.AccountId))
						.Update_Opportunity_Approvers__c
				) {
					opp.KAM__c = CRGMap.get(accIdToCRGMap.get(opp.AccountId))
						.Account_Primary_KAM__c;
					opp.CU_Head__c = CRGMap.get(accIdToCRGMap.get(opp.AccountId))
						.Account_CU_Head__c;
				}
				if (
					CRGMap.get(accIdToCRGMap.get(opp.AccountId)).GlobalCustomerUnit__c !=
					null &&
					CRGMap.get(accIdToCRGMap.get(opp.AccountId))
						.GlobalCustomerUnit__r.ApproversChanged__c
				) {
					opp.GCU_Commercial_Head__c = CRGMap.get(
							accIdToCRGMap.get(opp.AccountId)
						)
						.GlobalCustomerUnit__r.GCU_Commercial_Head__c;
					opp.GCU_Head__c = CRGMap.get(accIdToCRGMap.get(opp.AccountId))
						.GlobalCustomerUnit__r.GCU_Head__c;
					opp.GCU_KAM__c = CRGMap.get(accIdToCRGMap.get(opp.AccountId))
						.GlobalCustomerUnit__r.GCU_KAM__c;
				}
			}
			Set<Id> successOppIds = new Set<Id>();
			Database.SaveResult[] srList = Database.update(opptyMap.values(), false);
			for (Database.SaveResult sr : srList) {
				if (sr.isSuccess()) {
					successOppIds.add(sr.getId());
				}
			}
			opptyMap.keySet().removeAll(successOppIds);
			Set<Id> errorOppIds = opptyMap.keySet();
			for (Id opId : errorOppIds) {
				if (accIdToCRGMap.containsKey(opptyMap.get(opId).AccountId)) {
					accIdToCRGMap.remove(opptyMap.get(opId).AccountId);
				}
			}
			updateAccIdSet.addAll(accIdToCRGMap.keyset());
		}
	}
	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-07-10
	 * @param: Database.BatchableContext
	 * @description: Finish Method of Batch
	 *****************************************************************/
	global void finish(Database.BatchableContext BC) {
		Map<Id, CustomerReportingGroup__c> crgMap = new Map<Id, CustomerReportingGroup__c>();
		Map<Id, CustomerUnit__c> cuMap = new Map<Id, CustomerUnit__c>();
		for (Account acc : [
			SELECT
				ID,
				CustomerReportingGroup__c,
				CustomerReportingGroup__r.GlobalCustomerUnit__c
			FROM Account
			WHERE ID IN :updateAccIdSet
			LIMIT :(Limits.getLimitQueryRows() - Limits.getQueryRows())
		]) {
			if (acc.CustomerReportingGroup__c != null) {
				CustomerReportingGroup__c crg = new CustomerReportingGroup__c(
					Id = acc.CustomerReportingGroup__c
				);
				crg.Update_Opportunity_Approvers__c = false;
				if (!crgMap.containsKey(crg.Id)) {
					crgMap.put(crg.Id, crg);
				}
			}
			if (acc.CustomerReportingGroup__r.GlobalCustomerUnit__c != null) {
				CustomerUnit__c cu = new CustomerUnit__c(
					Id = acc.CustomerReportingGroup__r.GlobalCustomerUnit__c
				);
				cu.ApproversChanged__c = false;
				if (!cuMap.containsKey(cu.Id)) {
					cuMap.put(cu.Id, cu);
				}
			}
		}

		update crgMap.values();
		update cuMap.values();
	}
}