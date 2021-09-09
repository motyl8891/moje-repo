public without sharing class OppSummaryComponentProposalController {
	@AuraEnabled
	public static Proposal__c getProposal(Id OppID) {
		Proposal__c p;
		try {
			p = [
				SELECT Id
				FROM proposal__c
				WHERE primary__c = true AND Opportunity__c = :OppID
				LIMIT 1
			];
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.OppController,
						GlobalConstants.getAllOLI,
						GlobalConstants.OppController,
						true,
						e
					)
				)
			);
		}
		return p;
	}
}