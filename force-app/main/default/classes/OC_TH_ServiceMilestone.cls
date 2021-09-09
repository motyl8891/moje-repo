/* Class Name : OC_TH_ServiceMilestone
* Description : Class is used for calculation of case milestone by implementing standard Support.MilestoneTriggerTimeCalculator interface.
* Author      : IBM.
*/
public with sharing class OC_TH_ServiceMilestone implements Support.MilestoneTriggerTimeCalculator{
 public Integer calculateMilestoneTriggerTime(String caseId, String milestoneTypeId){
     Integer i = 1;
      system.debug('  ####### case milestone :'+ Limits.getQueries()); 
     List<Case> caseList = [SELECT Id,Priority,OC_TH_Remedy1__c,OC_TH_Solution1__c,OC_TH_CallBack1__c,OC_TH_Service_Contract__c,Type FROM Case WHERE Id=:caseId AND Type != '003' LIMIT 1]; 
     System.debug('case list in service milestone:--'+caseList);

        List<MilestoneType> milestoneList = [SELECT Name,CreatedDate FROM MilestoneType WHERE Id=:milestoneTypeId LIMIT 1];
        System.debug('milestone list in service milestone :-'+milestoneList);
        if(!milestoneList.isEmpty() && !caseList.isEmpty()){            
            if(milestoneList[0].Name == OC_TH_Constants.getRemedy1Milestone){               
                return Integer.ValueOf(caseList[0].OC_TH_Remedy1__c);     
            }
            if(milestoneList[0].Name == OC_TH_Constants.getSolution1Milestone){
                return Integer.ValueOf(caseList[0].OC_TH_Solution1__c);
            }
            if(milestoneList[0].Name == OC_TH_Constants.getCallback1Milestone){
                return Integer.ValueOf(caseList[0].OC_TH_CallBack1__c);                
            }            
        }
        return i;
 }
   
}