/*******************************************************************
* @author: Anurkiti
* @date: 2019-13-06
* @description: U-0900
                1. Controller calss for CloneOpportunity Component
********************************************************************/
public with sharing class CloneOpportunityController {
	/****************************************************************
	 * @author: Anukriti
	 * @date: 2019-13-06
	 * @param: Id oppId,
	 * @return Boolean
	 * @description: Stage 1-4 are valida stages for cloning the opportunity. So, this method check if stage is valid
	 * or not
	 *****************************************************************/
	@AuraEnabled
	public static Boolean isValidStage(Id oppId) {
		Boolean isClone = false;
		try {
			List<Opportunity> oppList = [
				SELECT ID, StageName
				FROM Opportunity
				WHERE Id = :oppId
				LIMIT 1
			];
			if (
				GlobalConstants.validCloneStage.indexOf(oppList.get(0).StageName) != -1
			) {
				isClone = true;
			}
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.CloneOpportunityController,
						GlobalConstants.isValidStage,
						GlobalConstants.CloneOpportunityController,
						true,
						e
					)
				)
			);
		}
		return isClone;
	}
}