/****************************************************************
 * @author: Anukriti
 * @date: 20-01-2020
 * @User Story: U-1578
 * @description: This is Trigger on Sales_Decision_Maker__c object
 *****************************************************************/
trigger SalesDecisionMakerTrigger on Sales_Decision_Maker__c(
	before delete,
	after update,
	before insert,
	before update,
    after insert,
    after delete
) {
	//delete operation
	if (Trigger.isDelete) {
		if (Trigger.isBefore) {
			SalesDecisionMakerHandler.OnBeforeDelete(Trigger.old);
		}
        if (Trigger.isAfter) {
			SalesDecisionMakerHandler.onAfterDelete(Trigger.old);
		} 
	}
	//Insert operation
	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			SalesDecisionMakerHandler.onBeforeInsert(Trigger.new);
		}
        if (Trigger.isAfter) {
			SalesDecisionMakerHandler.onAfterInsert(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
	}
	//update operation
	if (Trigger.isUpdate) {
		if (Trigger.isBefore) {
			SalesDecisionMakerHandler.onBeforeUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
		if (Trigger.isAfter) {
			SalesDecisionMakerHandler.onAfterUpdate(
				Trigger.New,
				Trigger.Old,
				Trigger.NewMap,
				Trigger.OldMap
			);
		}
	}
}