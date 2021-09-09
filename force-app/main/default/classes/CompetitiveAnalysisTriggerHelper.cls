/****************************************************************
 * @author: Richa Gupta
 * @date: 28-11-2019
 * @User Story: 1267
 * @description: This class is a helper class for CompetitiveAnalysisTriggerHandler
 *****************************************************************/
public class CompetitiveAnalysisTriggerHelper {
	/****************************************************************
	 * @author: Richa Gupta
	 * @date: 29-11-2019
	 * @param: newCompetitiveAnalysisList
	 * @description: This method will set key Competitor on Opportunity on the basis of first CompetetiveAnalaysis.(U-1267)
	 *****************************************************************/
	public static void setKeyCompetitor(
		List<CompetitiveAnalysis__c> newCompetitiveAnalysis,
		Map<ID, CompetitiveAnalysis__c> oldCompetitiveAnalysisMap
	) {
		try {
			Set<Id> oppIds = new Set<Id>();
			Map<Id, CompetitiveAnalysis__c> oppToCAMap = new Map<Id, CompetitiveAnalysis__c>();
			if (Trigger.isInsert || Trigger.isUpdate) {
				for (CompetitiveAnalysis__c ca : newCompetitiveAnalysis) {
					if (
						Trigger.isUpdate &&
						ca.Competitor__c !=
						oldCompetitiveAnalysisMap.get(ca.Id).Competitor__c
					) {
						oppIds.add(ca.Opportunity__c);
					} else if (Trigger.isInsert) {
						oppIds.add(ca.Opportunity__c);
					}
				}
			} else if (Trigger.isDelete) {
				for (CompetitiveAnalysis__c ca : oldCompetitiveAnalysisMap.values()) {
					oppIds.add(ca.Opportunity__c);
				}
			}
			if (oppIds.size() > 0) {
				for (CompetitiveAnalysis__c ca : [
					SELECT
						ID,
						Opportunity__c,
						Competitor__c,
						Opportunity__r.Key_Competitor__c
					FROM CompetitiveAnalysis__c
					WHERE Opportunity__c IN :oppIds
					ORDER BY createdDate ASC
				]) {
					if (!oppToCAMap.containsKey(ca.Opportunity__c)) {
						oppToCAMap.put(ca.Opportunity__c, ca);
					}
				}
				List<Opportunity> oppListUpdate = new List<Opportunity>();
				for (Id oppId : oppToCAMap.keySet()) {
					Opportunity opp = new Opportunity(Id = oppId);
					if (
						!oppToCAMap.get(oppId)
							.Competitor__c.equalsIgnoreCase(
								oppToCAMap.get(oppId).Opportunity__r.Key_Competitor__c
							)
					) {
						opp.Key_Competitor__c = oppToCAMap.get(oppId).Competitor__c;
						oppListUpdate.add(opp);
					}
				}
				if (Trigger.isDelete) {
					for (Id oppId : oppIds) {
						if (!oppToCAMap.containsKey(oppId)) {
							Opportunity opp = new Opportunity(Id = oppId);
							opp.Key_Competitor__c = '';
							oppListUpdate.add(opp);
						}
					}
				}
				if (oppListUpdate.size() > 0) {
					update oppListUpdate;
				}
			}
		} catch (Exception e) {
			EventLog.createLogFuture(
				Json.serialize(
					new EventLog.Error(
						GlobalConstants.CompetitiveAnalysisTriggerHelper,
						GlobalConstants.setKeyCompetitor,
						GlobalConstants.CompetitiveAnalysisTriggerHelper,
						true,
						e
					)
				)
			);
		}
	}
}