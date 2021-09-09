/****************************************************************
* @author: Pallavi Patil  
* @date: 11-11-2020
* @User Story: 2120
* @description: This class is a handler class for DeviationTrigger
*****************************************************************/
public class DeviationTriggerHandler {
    
    /****************************************************************
* @author: Pallavi Patil/Biswajit Sahoo
* @date: 11-11-2020/19-01-2021
* @param: U-2120 and U-2291
* @description: This method will handle after update operation 
*****************************************************************/
    public static void onAfterUpdate(List<Deviation__c> devList, Map<Id,Deviation__c> oldDevMap)
    {
        DeviationTriggerHelper.updateProductGroup(devList, oldDevMap);    
        DeviationTriggerHelper.updateProductGroupOnDeviation(devList,oldDevMap);
    }
    /****************************************************************
* @author: Pallavi Patil
* @date: 11-11-2020
* @param: U-2120
* @description: This method will handle after insert operation 
*****************************************************************/    
    public static void onAfterInsert(List<Deviation__c> devList, Map<Id,Deviation__c> oldDevMap)
    {
        DeviationTriggerHelper.updateProductGroup(devList, oldDevMap);
      }
    
}