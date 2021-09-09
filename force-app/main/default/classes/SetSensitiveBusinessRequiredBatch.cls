/*******************************************************************
* @author: Pallavi Patil
* @date: 2020-07-09
* @description: U-1985
********************************************************************/
global class SetSensitiveBusinessRequiredBatch implements Database.Batchable<sObject>, Schedulable{
 
   global void execute(SchedulableContext ctx){
        database.executeBatch(new SetSensitiveBusinessRequiredBatch(), 50);
    } 
    /****************************************************************
* @author: Pallavi Patil
* @date: 2020-07-09
* @param: Database.BatchableContext
* @description: Start Method of Batch
*****************************************************************/    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query='SELECT Approval_Valid_Until__c,Sign_Off_Type__c,Opportunity__r.stagename,Opportunity__r.Trade_Compliance_Status__c,Opportunity__r.Sensitive_Business_Status__c FROM Secondary_Approval__c where Approval_Valid_Until__c  < TODAY';
        return Database.getQueryLocator(query);
    }
    /****************************************************************
* @author: Pallavi Patil
* @date: 2020-07-09
* @param: Database.BatchableContext, List<Secondary_Approval__c> scope
* @description: Execute Method of Batch
*               1. updating trade compliance status and sensitive business status to Required
*****************************************************************/    
    global void execute(Database.BatchableContext BC, List<Secondary_Approval__c> saList){
         try{
        Map<id,opportunity> oppMap = new Map<id,opportunity>();
        for(Secondary_Approval__c sa : saList)
        {
            if((date.valueof(sa.Approval_Valid_Until__c) != null)
               && (sa.Opportunity__r.stagename == GlobalConstants.Qualify_Opportunity || sa.Opportunity__r.stagename == GlobalConstants.Define_CustomerValue || sa.Opportunity__r.stagename == GlobalConstants.Create_Proposal)){
                   if((sa.Sign_Off_Type__c ==GlobalConstants.Trade_Compliance && sa.Opportunity__r.Trade_Compliance_Status__c != GlobalConstants.Not_Required))
                   {
                       sa.Opportunity__r.Trade_Compliance_Status__c=GlobalConstants.REQUIRED;
                       oppMap.put(sa.Opportunity__c,sa.Opportunity__r);    
                   }
                   else if((sa.Sign_Off_Type__c ==GlobalConstants.Sensitive_BusinessStatus && sa.Opportunity__r.Sensitive_Business_status__c != GlobalConstants.Not_Required)) 
                   {
                       if(oppMap.containsKey(sa.Opportunity__c)){
                           oppMap.get(sa.Opportunity__c).Sensitive_Business_status__c=GlobalConstants.REQUIRED;
                       }
                       else{
                           sa.Opportunity__r.Sensitive_Business_status__c=GlobalConstants.REQUIRED;
                           oppMap.put(sa.Opportunity__c,sa.Opportunity__r);
                       }
                   }
               }
        }
        
       
            if(!oppMap.isEmpty()){
            update oppMap.values();
            } 
        }
       catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SetSensitiveBusinessRequiredBatch,   GlobalConstants.execute, GlobalConstants.SetSensitiveBusinessRequiredBatch, true, e)));
        }
                  
         
    }  
    
    /****************************************************************
* @author: Pallavi Patil
* @date: 2020-07-09
* @param: Database.BatchableContext
* @description: Finish Method of Batch
*****************************************************************/
    global void finish(Database.BatchableContext BC){
    } 
}