/**
 * @File Name          : CompetitiveAnalysisTriggerHandler.cls
 * @Description        : 
 * @Author             : Richa Gupta
 * @Group              : 
 * @Last Modified By   : Richa Gupta
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date           Author      	 Modification
 * 1.0    2019-11-28     Richa Gupta       Initial Version
**/

public class CompetitiveAnalysisTriggerHandler {
    public void onAfterInsert(List<CompetitiveAnalysis__c> newCompetitiveAnalysis,Map<ID, CompetitiveAnalysis__c> oldCompetitiveAnalysisMap){
		CompetitiveAnalysisTriggerHelper.setKeyCompetitor(newCompetitiveAnalysis,oldCompetitiveAnalysisMap);
    }
    public void onAfterUpdate(List<CompetitiveAnalysis__c> newCompetitiveAnalysis,Map<ID, CompetitiveAnalysis__c> oldCompetitiveAnalysisMap){
		CompetitiveAnalysisTriggerHelper.setKeyCompetitor(newCompetitiveAnalysis,oldCompetitiveAnalysisMap);         
    }
    public void onAfterDelete(List<CompetitiveAnalysis__c> newCompetitiveAnalysis,Map<ID, CompetitiveAnalysis__c> oldCompetitiveAnalysisMap){
		CompetitiveAnalysisTriggerHelper.setKeyCompetitor(newCompetitiveAnalysis,oldCompetitiveAnalysisMap);
    }
}