trigger EmployeeTrigger on Employee__c(
	before update,
	after insert,
	before insert,
	after update
) {
	DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
		'EmployeeTrigger ',
		'Employee__c'
	);
	if (Trigger.isInsert) {
		if (Trigger.isAfter) {
			EmployeeTriggerHandler.OnAfterInsert(Trigger.New);
		} else {
			EmployeeTriggerHandler.OnBeforeInsert(Trigger.New);
		}
		DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
			'Employee__c ',
			'EmployeeTrigger ',
			DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
		);
	}
	/*if(Trigger.isUpdate){
        if(Trigger.isBefore){
            EmployeeTriggerHandler.OnBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
        else{
             EmployeeTriggerHandler.OnAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
         }
    }*/
}