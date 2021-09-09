/****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description: This class will handle ProposalTrigger
*****************************************************************/
public with sharing class ProposalTriggerHandler {
    private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean isFromBachJob ;
    public static boolean isFromUploadAPI = false;
    
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description: This is Constructor for ProposalTriggerHandler
*****************************************************************/
    public ProposalTriggerHandler(boolean isExecuting, integer size) {
        this.isExecuting = isExecuting;
        batchSize = size;
    }
    
    /****************************************************************
* Proposal Trigger On Before Insert
* @param newProposals List of new Proposal objects
****************************************************************/
    public void onBeforeInsert(List<Proposal__c> newProposals) {
    }
    
    /****************************************************************
* Proposal Trigger On After Insert
* @param newProposals List of new Proposal objects
****************************************************************/
    public void onAfterInsert(List<Proposal__c> newProposals,Map<id,Proposal__c> newProposalMap, Map<ID, Proposal__c> oldProposalMap) {
        ProposalTriggerHandlerHelper.onePrimaryProposalAfterInsert(newProposals);
        ProposalTriggerHandlerHelper.triggerOpportunitiesUpdate(newProposals);
        ProposalTriggerHandlerHelper.updatePrimaryProposal(newProposalMap,oldProposalMap,true);
    }
    
    /****************************************************************
* Proposal Trigger On Before Update
* @param newProposals     List of new Proposal objects
* @param oldProposals     List of old Proposal objects
* @param newProposalsMap  Map containing new Proposal ID and new Proposal object
* @param oldProposalsMap  Map containing old Proposal ID and old Proposal object
****************************************************************/
    public void onBeforeUpdate( List<Proposal__c> newProposals, List<Proposal__c> oldProposals, Map<ID, Proposal__c> newProposalMap , Map<ID, Proposal__c> oldProposalMap ) {
        ProposalTriggerHandlerHelper.onePrimaryProposalBeforeUpdate(newProposalMap, oldProposalMap);
        ProposalTriggerHandlerHelper.setClosedWonMinorFlow(newProposalMap);
        //Added as part of U-1711 -- Anukriti
        ProposalTriggerHandlerHelper.recallDeviationApprovals(newProposals, oldProposalMap);
        //U-1846 -- Anukriti
        ProposalTriggerHandlerHelper.checkEditabilityOfPreApprovalField(newProposals, oldProposalMap);
    }
    
    /****************************************************************
* Proposal Trigger On After Update
* @param newProposals     List of new Proposal objects
* @param oldProposals     List of old Proposal objects
* @param newProposalsMap  Map containing new Proposal ID and new Proposal object
* @param oldProposalsMap  Map containing old Proposal ID and old Proposal object
****************************************************************/
    public void onAfterUpdate( List<Proposal__c> newProposals, List<Proposal__c> oldProposals, Map<ID, Proposal__c> newProposalMap , Map<ID, Proposal__c> oldProposalMap ) {
        ProposalTriggerHandlerHelper.updatePrimaryProposalProducts(newProposals, oldProposalMap);
        ProposalTriggerHandlerHelper.onePrimaryProposal(newProposalMap, oldProposalMap);
        ProposalTriggerHandlerHelper.triggerOpportunitiesUpdate(newProposals);
        //Added as part of U-1711 -- Anukriti
        ProposalTriggerHandlerHelper.recallDeviationApprovals(newProposals, oldProposalMap);
        //U-1846 -- Anukriti
        ProposalTriggerHandlerHelper.updateDeviationsToApproved(newProposals, oldProposalMap);
        ProposalTriggerHandlerHelper.updatePrimaryProposal(newProposalMap,oldProposalMap,false);
        //U-1928           
        ProposalTriggerHandlerHelper.postToChatter(newProposals, oldProposalMap);	}
}