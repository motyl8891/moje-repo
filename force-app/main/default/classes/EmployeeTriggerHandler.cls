public class EmployeeTriggerHandler {
 /****************************************************************
* @author: Aditya Mohapatra  
* @date: 17-09-2019
* @User Story: 0994
* @description: This method will be called from EmployeeTrigger on before insert
*****************************************************************/
    public static void OnBeforeInsert( List<Employee__c> newEmployee){
        {
        EmployeeTriggerHelper.setUserFromSignum(newEmployee);
            }
    }
  /****************************************************************
* @author: Aditya Mohapatra  
* @date: 17-09-2019
* @User Story: 0994
* @description: This method will be called from EmployeeTrigger on after insert
*****************************************************************/
    public static void OnAfterInsert( List<Employee__c> newEmployee){
        
       // SalesDecisionRecordTriggerHelper.createSDApproverRecords(newSalesDecision);
    }
     /****************************************************************
* @author: Aditya Mohapatra  
* @date: 17-09-2019
* @User Story: 0994
* @description: This method will be called from EmployeeTrigger on before update
*****************************************************************/
   /* public static void onBeforeUpdate( List<Employee__c> newEmployee, List<Employee__c> oldEmployee, Map<ID,Employee__c> newEmployeeMap , Map<ID,Employee__c> oldEmployeeMap){
        system.debug('Employee Trigger On Before Update ');
       // SalesDecisionRecordTriggerHelper.SalesDecisionApprovedStatusError(oldSalesDecisionMap,newSalesDecisionMap);
        //U-1271
        //SalesDecisionRecordTriggerHelper.checkRecordEditabilityForMELAOppty(oldSalesDecisionMap,newSalesDecisionMap);
    }*/
/****************************************************************
* @author: Aditya Mohapatra  
* @date: 17-09-2019
* @User Story: 0994
* @description: This method will be called from EmployeeTrigger on after update
*****************************************************************/
    /*public static void onAfterUpdate( List<Employee__c> newEmployee, List<Employee__c> oldEmployee, Map<ID,Employee__c> newEmployeeMap , Map<ID,Employee__c> oldEmployeeMap ){
        system.debug('Employee Trigger On After Update ');
       // SalesDecisionRecordTriggerHelper.updateApprovedSDPStage(newSalesDecision);
    }*/
}