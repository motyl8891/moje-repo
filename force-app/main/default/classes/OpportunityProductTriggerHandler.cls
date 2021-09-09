public class OpportunityProductTriggerHandler{
	private boolean isExecuting = false;
    private integer batchSize = 0;
    public static boolean isFromBachJob ;
    public static boolean isFromUploadAPI=false;
    
    public OpportunityProductTriggerHandler(boolean isExecuting, integer size){
        this.isExecuting = isExecuting;
        batchSize = size;
    }
            
    public void onBeforeInsert(List<OpportunityLineItem> newOppProducts) {
        Try{
        system.debug('OpportunityProduct Trigger On Before Insert');
		
        OpportunityProductTriggerHandlerHelper.RestrictDuplicateOppProduct(newOppProducts);
            }catch(Exception e){	}
    }
    public void onAfterInsert(List<OpportunityLineItem> newOppProducts){
        Try{
        system.debug('OpportunityProduct Trigger On After Insert');
        //OpportunityLineItemHelper.updateSignumOnOpportunity(newOppProducts);
        OpportunityProductTriggerHandlerHelper.triggerOpportunitiesUpdate(newOppProducts);
        OpportunityProductTriggerHandlerHelper.triggerOpportunitiesApprovedSdpStageInsert(newOppProducts);
    	}catch(Exception e){	}
        }
    public void onBeforeUpdate( List<OpportunityLineItem> newOppProducts, List<OpportunityLineItem> oldOppProducts, Map<ID, OpportunityLineItem> newOppProductMap , Map<ID, OpportunityLineItem> oldOppProductMap ){
        Try{
        system.debug('OpportunityProduct Trigger On Before Update ');
            }catch(Exception e){	}
    }
    public void onAfterUpdate( List<OpportunityLineItem> newOppProducts, List<OpportunityLineItem> oldOppProducts, Map<ID, OpportunityLineItem> newOppProductMap , Map<ID, OpportunityLineItem> oldOppProductMap ){
        Try{
        system.debug('OpportunityProduct Trigger On After Update ');
        OpportunityProductTriggerHandlerHelper.calculateLeadDomain(newOppProducts);
        //OpportunityLineItemHelper.updateSignumOnOpportunity(newOppProducts);
        OpportunityProductTriggerHandlerHelper.triggerOpportunitiesUpdate(newOppProducts);
        OpportunityProductTriggerHandlerHelper.triggerOpportunitiesApprovedSdpStageUpdate(newOppProducts,oldOppProductMap);
            }catch(Exception e){	}
    }
    public void onBeforeDelete( List<OpportunityLineItem> newOppProducts, List<OpportunityLineItem> oldOppProducts, Map<ID, OpportunityLineItem> newOppProductMap , Map<ID, OpportunityLineItem> oldOppProductMap ){
        Try{
        system.debug('OpportunityProduct Trigger On Before Update ');
        OpportunityProductTriggerHandlerHelper.validateOnDelete(oldOppProducts);
            }catch(Exception e){	}
    }
    public void onAfterDelete( List<OpportunityLineItem> newOppProducts, List<OpportunityLineItem> oldOppProducts, Map<ID, OpportunityLineItem> newOppProductMap , Map<ID, OpportunityLineItem> oldOppProductMap ){
        Try{
        system.debug('OpportunityProduct Trigger On After Update ');
        //OpportunityLineItemHelper.updateSignumOnOpportunity(oldOppProducts);
        OpportunityProductTriggerHandlerHelper.triggerOpportunitiesUpdate(oldOppProducts);
        OpportunityProductTriggerHandlerHelper.triggerOpportunitiesApprovedSdpStageDelete(oldOppProducts);
            }catch(Exception e){	}
    }
}