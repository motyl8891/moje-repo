trigger OpportunityContactRoleTrigger on OpportunityContactRole (after insert) {
    DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow = DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow(
        'OpportunityContactRoleTrigger ',
        'OpportunityContactRole '
    );
    
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            OpportunityContactRoleTriggerHandler.OnAfterInsert(Trigger.New);
        }
    }
    DHCT.DHC_StaticThresholdBreachCalculation.fetchRunTimeLimitStatus(
        'OpportunityContactRole ',
        'OpportunityContactRoleTrigger ',
        DHCT.DHC_StaticThresholdBreachCalculation.triggerFlow
    );
}