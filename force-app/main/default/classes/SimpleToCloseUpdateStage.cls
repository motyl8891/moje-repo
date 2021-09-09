/****************************************************************
* @author: Pallavi Patil
* @date: 13-05-2019
* @User Story: 0891
* @description: This class will call from OpportunityTriggerHelper 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

*****************************************************************/
public without sharing class SimpleToCloseUpdateStage implements Queueable{  
    public Set<Id> frameOpptyIdSet = new Set<id>();
    public Set<Id> standOpptyIdSet = new Set<id>();
    
    /****************************************************************
* @author: Pallavi Patil
* @date: 13-05-2019
* @description: This method is a Constructor and will be called from OpportunityTriggerHelper
*****************************************************************/
    public SimpleToCloseUpdateStage(Set<id> frameOpptyIdSet, Set<id> standOpptyIdSet) {    
        this.frameOpptyIdSet = frameOpptyIdSet; 
        this.standOpptyIdSet = standOpptyIdSet; 
    }  
    /****************************************************************
* @author: Pallavi Patil
* @date: 13-05-2019
* @description: This method is a Queueable method
*****************************************************************/
    public void execute(QueueableContext context) { 
     
        try{
            if(standOpptyIdSet!=null){
                if(!standOpptyIdSet.isEmpty()){
                    Set<Id> oppIds = new Set<id>(); 
                    oppIds.addAll(standOpptyIdSet);
                    oppIds.addAll(frameOpptyIdSet);
                    updateSdrOppChild(oppIds);
                    updateSecApprovalStatus(oppIds);
                    updateEsApprovalStatus(oppIds);    
                    //updateSimpleOppStage(oppIds);
                }
                if(frameOpptyIdSet!=null){
                    if(!frameOpptyIdSet.isEmpty()){
                        updateSimpleOppStage(frameOpptyIdSet);
                    }
                }
            }
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SimpleToCloseUpdateStage,GlobalConstants.execute, GlobalConstants.SimpleToCloseUpdateStage, true, e)));
        }
    }
    /****************************************************************
* @author: Pallavi Patil
* @date: 13-05-2019
* @description: This method is updating simple child's stage.
*****************************************************************/
    public static void updateSimpleOppStage(Set<Id> frameOpptyIdSet){
        List<Opportunity> simpleOpptyListToUpdate = new List<Opportunity>();
        try{
            for(Opportunity frameOpty : [SELECT Id,StageName,CloseDate,(SELECT Id,StageName,CloseDate,recordtype.name FROM Child_Subsequent_Opportunities__r where recordTypeid =: GlobalConstants.simpleOppRecordTypeId  
                                                                        Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()))  
                                         FROM Opportunity where Id in: frameOpptyIdSet 
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {  
                for(Opportunity simpleOpty : frameOpty.Child_Subsequent_Opportunities__r){
                    simpleOpty.CloseDate = system.today();
                    simpleOpty.stagename = frameOpty.stagename;
                    simpleOpptyListToUpdate.add(simpleOpty); 
                }
            }
            if(!simpleOpptyListToUpdate.isEmpty()){
                Database.update(simpleOpptyListToUpdate); 
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SimpleToCloseUpdateStage,GlobalConstants.updateSimpleOppStage, GlobalConstants.SimpleToCloseUpdateStage, true, e)));
        }
    }
    public static void updateSdrOppChild(Set<Id> oppIds){
        //Id simpleOppRecordTypeId = System.Label.Record_Type_ID_Simple_Opportunity;
        List<Sales_Decision_Record__c> sdrListUpdate = new List<Sales_Decision_Record__c>();
        List<Sales_Decision_Maker__c> sdmListUpdate = new List<Sales_Decision_Maker__c>();
        try{
            //U-1903
            for(Sales_Decision_Record__c sdr : [SELECT Id,Sales_Decision_Approval_Status__c,
                                                (SELECT ID,Approval_Status__c FROM Sales_Decision_Makers__r WHERE Approval_Status__c != :GlobalConstants.APPROVED)
                                                FROM Sales_Decision_Record__c 
                                                WHERE opportunity__c IN :oppIds and (Sales_Decision_Approval_Status__c = :GlobalConstants.INPROGRESS
                                                                                     OR Sales_Decision_Approval_Status__c = :GlobalConstants.APPROVALSONGOING)
                                                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
            {
                sdr.Sales_Decision_Approval_Status__c = GlobalConstants.Cancelled;
                
                for(Sales_Decision_Maker__c sdm:sdr.Sales_Decision_Makers__r){
                    sdm.Approval_Status__c = GlobalConstants.Cancelled;
                    sdmListUpdate.add(sdm);
                }
                sdrListUpdate.add(sdr);                                                          
            } 
            if(!sdmListUpdate.isEmpty()){
                database.update(sdmListUpdate);                     
            }
            if(!sdrListUpdate.isEmpty()){
                database.update(sdrListUpdate); 
            }   
        } 
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SimpleToCloseUpdateStage,GlobalConstants.updateSdrOppChild, GlobalConstants.SimpleToCloseUpdateStage, true, e)));
        }
    }
    public static void updateSecApprovalStatus(Set<Id> oppIds){
        List<Secondary_Approval__c> saListUpdate = new List<Secondary_Approval__c>();
        
        try{ //U-1903
            List<Secondary_Approval__c> saList=[SELECT Id,Approval_Status__c FROM Secondary_Approval__c 
                                                WHERE opportunity__c IN :oppIds and Approval_Status__c = :GlobalConstants.Pending
                                                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            List<id> saIdList=new List<id>();
            for(Secondary_Approval__c sa:saList){
                saIdList.add(sa.id);
            }
            for(Secondary_Approval__c sa:saList){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                if(pwr!= null){
                     //NS
                    for(ProcessInstanceWorkitem workItem:[ SELECT Id,ProcessInstance.TargetObjectId
                                                          FROM ProcessInstanceWorkitem 
                                                          WHERE ProcessInstance.TargetObjectId in :saIdList
                                                          AND ProcessInstance.Status = :GlobalConstants.Pending Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        if(workItem.ProcessInstance.TargetObjectId ==sa.Id){
                            pwr.setAction(GlobalConstants.Removed);pwr.setWorkItemId(workItem.id);
                            Approval.ProcessResult result = Approval.process(pwr);sa.Approval_Status__c = GlobalConstants.Cancelled;saListUpdate.add(sa);                                               
                        }
                    }
                    
                }
            } 

            if(!saListUpdate.isEmpty()){database.update(saListUpdate); 
            }
        } 
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SimpleToCloseUpdateStage,GlobalConstants.updateSecApprovalStatus, GlobalConstants.SimpleToCloseUpdateStage, true, e)));
        }
    }
    public static void updateEsApprovalStatus(Set<Id> oppIds){
        List<EarlyStart__c> esListUpdate = new List<EarlyStart__c>();
        
        try{ //U-1903
            List<EarlyStart__c> esList=[SELECT Id,Early_Start_Status__c FROM EarlyStart__c 
                                                WHERE opportunity__c IN :oppIds and Early_Start_Status__c = :GlobalConstants.PENDINGAPPROVAL
                                                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            List<id> esIdList=new List<id>();
            for(EarlyStart__c es:esList){
                esIdList.add(es.id);
            }
            for(EarlyStart__c es:esList){
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                if(pwr!= null){
                    //NS
                    for(ProcessInstanceWorkitem workItem:[ SELECT Id,ProcessInstance.TargetObjectId
                                                          FROM ProcessInstanceWorkitem 
                                                          WHERE ProcessInstance.TargetObjectId in :esIdList
                                                          AND ProcessInstance.Status = :GlobalConstants.Pending Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        if(workItem.ProcessInstance.TargetObjectId ==es.Id){
                            //U-1903
                            pwr.setAction(GlobalConstants.Removed);pwr.setWorkItemId(workItem.id);Approval.ProcessResult result = Approval.process(pwr);
                            es.Early_Start_Status__c = GlobalConstants.Cancelled;esListUpdate.add(es); 
                            break;
                        }
                    }
                    
                }
            } 
            if(!esListUpdate.isEmpty()){
                database.update(esListUpdate); 
            }
        } 
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SimpleToCloseUpdateStage,GlobalConstants.updateEsApprovalStatus, GlobalConstants.SimpleToCloseUpdateStage, true, e)));
        }
    }
    
}