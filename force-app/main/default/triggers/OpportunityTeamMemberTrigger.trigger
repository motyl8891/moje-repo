trigger OpportunityTeamMemberTrigger on OpportunityTeamMember(
	after insert,
	after update,
	before insert,
	before update,
	before delete,
	after delete
) {
	/*DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow('OpportunityTeamMemberTrigger ', 'OpportunityTeamMember ');

    OpportunityTeamMemberTriggerHandler handler = new OpportunityTeamMemberTriggerHandler(Trigger.isExecuting, Trigger.size);

    if( Trigger.isInsert ){
        if(Trigger.isBefore){
            handler.OnBeforeInsert(trigger.New);
        }else{
            handler.OnAfterInsert(trigger.New);
        }
    }else if ( Trigger.isUpdate ){
        if(Trigger.isBefore){
            handler.OnBeforeUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }else{
            handler.OnAfterUpdate(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    }else if ( Trigger.isDelete ){
        if(Trigger.isBefore){
            handler.OnBeforeDelete(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }else{
            handler.OnAfterDelete(trigger.New ,trigger.Old,Trigger.NewMap,Trigger.OldMap);
        }
    }
DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus('OpportunityTeamMember ', 'OpportunityTeamMemberTrigger ', DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow);
*/
}