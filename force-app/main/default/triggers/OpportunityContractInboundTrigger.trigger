/***********************************************************************************
 * @author: Linda Pavare
 * @date: 2017-11-08
 * @description: This trigger invokes functionalities that should run after DML activity on Opportunity Contract Inbound records
 **********************************************************************************/
trigger OpportunityContractInboundTrigger on OpportunityContractInbound__c(
	before update
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'OpportunityContractInboundTrigger ',
		'OpportunityContractInbound__c '
	);
	if (Trigger.isBefore) {
		if (Trigger.isInsert) {
		}

		if (Trigger.isUpdate) {
			ContractFromOpportunityContractHelper.updateCreateContractFromOppContract(
				Trigger.newMap,
				Trigger.oldMap
			);
		}

		if (Trigger.isDelete) {
		}
	} /*else if(Trigger.isAfter){

                                if(Trigger.isInsert){
                                }

                                if(Trigger.isUpdate){
                                }

                                if(Trigger.isDelete){
                                }
                }*/

	DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
		'OpportunityContractInbound__c ',
		'OpportunityContractInboundTrigger ',
		DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
	);

}