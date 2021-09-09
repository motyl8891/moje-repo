/****************************************************************
* @author: Aditya Mohapatra  
* @date: 13-05-2020
* @User Story: 1475
* @description: This class will handle ABCTrigger
*****************************************************************/
public with sharing class ABCTriggerHandler {
    
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 
* @User Story: U-2070
* @description: 
*****************************************************************/
    public void onAfterUpdate(List<AntiBriberyCorruption__c> newABCList, List<AntiBriberyCorruption__c> oldABCList, 
                              Map<ID, AntiBriberyCorruption__c> newABCMap , Map<ID, AntiBriberyCorruption__c> oldABCMap) 
    {   
        ABCTriggerHelper.goToApprovalStep1(newABCList,newABCMap,oldABCMap,false);
        
        set<id>ABCrecset=new set<id>();
        for(AntiBriberyCorruption__c s:newABCList){
            if(s.ApprovalStatus__c!=null && s.ApprovalStatus__c.contains('Approved') && //change to pending
                   oldABCMap.get(s.Id).ApprovalStatus__c != s.ApprovalStatus__c){
                            ABCrecset.add(s.id);
                   }}
        if(!ABCrecset.isEmpty())   
        ABCTriggerHelper.populateApproverComments(ABCrecset);
   }
    
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story: U-1981
* @description: This method will call populateKamEmail, updatePartnerAccountFields, updateApprovalStatus  from ABCTriggerHelper
*****************************************************************/
    public void onBeforeUpdate(List<AntiBriberyCorruption__c> newABCList, List<AntiBriberyCorruption__c> oldABCList, 
                               Map<ID, AntiBriberyCorruption__c> newABCMap , Map<ID, AntiBriberyCorruption__c> oldABCMap) 
    {   
        ABCTriggerHelper.updatePartnerAccountFields(newABCList,newABCMap);
        ABCTriggerHelper.populateKamEmail(newABCList, newABCMap);
        ABCTriggerHelper.updateApprovalStatus(newABCList,oldABCMap);
        ABCTriggerHelper.checkAccountFields(newABCList,newABCMap, oldABCMap,false);
        
        
    }
    
    /****************************************************************
* @author: Aditya Mohapatra
* @date: 
* @User Story: U-2070
* @description: 
*****************************************************************/
    public void onAfterInsert(List<AntiBriberyCorruption__c> newABCList,  
                              Map<ID, AntiBriberyCorruption__c> newABCMap,Map<ID, AntiBriberyCorruption__c> oldABCMap) 
    {   
        ABCTriggerHelper.goToApprovalStep1(newABCList,newABCMap,oldABCMap,true);
    }
    
    /****************************************************************
* @author: Shubham Jagatap
* @date: 8/24/2020
* @User Story: U-1981
* @description: This method will call populateKamEmail, checkAccountFields  from ABCTriggerHelper
*****************************************************************/
    public void onBeforeInsert(List<AntiBriberyCorruption__c> newABCList, 
                               Map<ID, AntiBriberyCorruption__c> newABCMap,
                               Map<ID, AntiBriberyCorruption__c> oldABCMap ) 
    {   
        ABCTriggerHelper.populateKamEmail(newABCList, newABCMap);
        ABCTriggerHelper.checkAccountFields(newABCList,newABCMap, oldABCMap,true);
    }
}