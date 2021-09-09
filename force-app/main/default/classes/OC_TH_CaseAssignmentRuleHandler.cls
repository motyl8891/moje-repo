/**
* @File Name          : OC_TH_CaseAssignmentRuleHandler
* @Description        : Class to route the child cases to the appropriate queue's
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th July 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-07-20                 IBM                   Initial Version
* 1.1        2020-08-11                 IBM                   Bulkified the code
**/
public class OC_TH_CaseAssignmentRuleHandler {
    
    //This method will be invoked by process builder to route the child cases
    @InvocableMethod
    public static void saveCase(List<Id> caseId){
        
        list<Case> caseToUpdate = new list<Case>();
        //Fetching the assignment rules on case
        AssignmentRule AR = new AssignmentRule();
        
        AR = [select id from AssignmentRule where SobjectType =:OC_TH_Constants.caseLiteral and Active =:OC_TH_Constants.activeTrue limit 1];
        //Creating the DMLOptions for "Assign using active assignment rules" checkbox
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        if(AR != null){
            dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
        }
        //Bulkified the code for proper case routing
        for(Case caseInstance : [SELECT Id FROM Case WHERE Id IN :caseId ]){
        	caseInstance.setOptions(dmlOpts);
            caseToUpdate.add(caseInstance);
        }
        if(caseToUpdate != null){
            Database.update (caseToUpdate,false); 
        }  
    }
}