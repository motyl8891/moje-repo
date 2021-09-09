/*******************************************************************
* @author: Anurkiti
* @date: 2019-08-21
* @description: U-1108
1. Queueable class to handle Replace Products of Opp
********************************************************************/
public class AsyncReplaceProducts implements Queueable {
	List<Proposal__c> propList;

	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-08-21
	 * @description: Constructor
	 *****************************************************************/
	public AsyncReplaceProducts(List<Proposal__c> proposalList) {
		propList = proposalList;
	}

	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-08-21
	 * @description: Execute Method
	 *****************************************************************/
	public void execute(QueueableContext context) {
		try {
			ProposalUtils.replaceProducts_queryProductsFirst(propList);
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.AsyncReplaceProducts,
						GlobalConstants.execute,
						GlobalConstants.AsyncReplaceProducts,
						true,
						e
					)
				)
			);
		}
	}
}