global class CustomerUnitTextUpdate implements Database.Batchable<sObject>, Database.Stateful {
	global Integer recordsProcessed = 0;

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(
			'SELECT Id, CustomerUnit__c, Customer_Unit_Text__c, CustomerUnit__r.Name FROM CustomerReportingGroup__c'
		);
	}

	global void execute(
		Database.BatchableContext BC,
		List<CustomerReportingGroup__c> crg
	) {
		List<CustomerReportingGroup__c> newCRG = new List<CustomerReportingGroup__c>();
		for (CustomerReportingGroup__c g : crg) {
			CustomerReportingGroup__c newG = new CustomerReportingGroup__c();
			newG.Id = g.Id;
			if (!String.isBlank(g.CustomerUnit__c)) {
				newG.Customer_Unit_Text__c = g.CustomerUnit__r.Name;
			} else {
				newG.Customer_Unit_Text__c = '';
			}
			newCRG.add(newG);
			recordsProcessed = recordsProcessed + 1;
		}
		if (newCRG.size() > 0) {
			update newCRG;
		}
	}

	global void finish(Database.BatchableContext BC) {
		System.debug(recordsProcessed + ' records processed');
	}
}