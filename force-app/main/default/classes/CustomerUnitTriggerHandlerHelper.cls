/**
* CustomerUnitTrigger class Helper class 
* Used to set correct Account CU Head for related Customer Reporting Group
*/
public class CustomerUnitTriggerHandlerHelper {
    
    /**
* Method that sets correct CRG Account CU Head when CU object Responsible Signum changes
* @param newCustomerUnits   updates Customer Units
* @param oldCustomerUnitMap old Customer Units
*/
    public static void updateAccountCUHead(List<CustomerUnit__c> newCustomerUnits, Map<ID, CustomerUnit__c> oldCustomerUnitMap) {
        Try{
        Map<Id, String> responsibleSignums = new Map<Id, String>();
        for (CustomerUnit__c newCustomerUnit : newCustomerUnits) {
            CustomerUnit__c oldCustomerUnit = oldCustomerUnitMap.get(newCustomerUnit.Id);
            if (newCustomerUnit.ResponsibleSignum__c != oldCustomerUnit.ResponsibleSignum__c && newCustomerUnit.ResponsibleSignum__c != null) {
                responsibleSignums.put(newCustomerUnit.Id, newCustomerUnit.ResponsibleSignum__c);
            }
        }
        if (!responsibleSignums.isEmpty()) {
            setAccountCuHead(responsibleSignums);
        }}catch(Exception e){	}
    }
    
    /**
* Method that sets correct CRG Account CU Head when new CU object is created
* @param newCustomerUnits List of Customer Units
*/
    public static void updateNewCUAccountCUHead(List<CustomerUnit__c> newCustomerUnits) {
        Try{
        Map<Id, String> responsibleSignums = new Map<Id, String>();
        for (CustomerUnit__c newCustomerUnit : newCustomerUnits) {
            if (newCustomerUnit.ResponsibleSignum__c != null) {
                responsibleSignums.put(newCustomerUnit.Id, newCustomerUnit.ResponsibleSignum__c);
            }
        }
        if (!responsibleSignums.isEmpty()) {
            setAccountCuHead(responsibleSignums);
        }
            }catch(Exception e){	}
    }
    
    /**
* Method that sets CRG Account CU Head based on Customer Unit Responsible Signum value
* @param responsibleSignums  Map with key as Customer Unit Id and value Responsible Signum
*/
    public static void setAccountCuHead(Map<Id, String> responsibleSignums)
    {
        Map<String, Id> userSignums               = findUsersBySignum(responsibleSignums);
        List<CustomerReportingGroup__c> cuCrgList = findCuCrgList    (responsibleSignums);
        Set<String> crgIdC = new Set<String>();
        for(CustomerReportingGroup__c crg : cuCrgList)
        {
            if(crg.GlobalCustomerUnit__c != null && userSignums.containsKey(responsibleSignums.get(crg.GlobalCustomerUnit__c)))
            {
                crg.Account_CU_Head__c = userSignums.get(responsibleSignums.get(crg.GlobalCustomerUnit__c));
            }
            else if(crg.GlobalCustomerUnit__c == null)
            {
                if(crg.CustomerUnit__c != null && userSignums.containsKey(responsibleSignums.get(crg.CustomerUnit__c)))
                {
                    crg.Account_CU_Head__c = userSignums.get(responsibleSignums.get(crg.CustomerUnit__c));
                }
                else
                {
                    crgIdC.add(crg.CRG_ID__c);
                }
            }
            else
            {
                crgIdC.add(crg.CRG_ID__c);
            }
        }
        EventLog.createLog(new EventLog.Information('CustomerUnitTriggerHandlerHelper', 'setAccountCuHead', 'Account CU Head Assignment', true, 'Account CU Head was not found based on GCU Responsible Signum for Customer Reporting Group with ID: ' + crgIdC));
        update cuCrgList;
    }
    
    /**
* Method that finds Users based on Responsible Signum value
* @param  responsibleSignums Map with key as Customer Unit Id and value Responsible Signum
* @return                    Map with key Responsible Signum and value Id of User
*/
    private static Map<String, Id> findUsersBySignum(Map<Id, String> responsibleSignums) {
        Map<String, Id> userSignums = new Map<String, Id>();
        for (User u : [Select Id, Signum__c FROM User WHERE Signum__c IN : responsibleSignums.values()]) {
            userSignums.put(u.Signum__c, u.Id);
        }
        return userSignums;
    }
    
    /**
* Method that finds all related CRG to certain Customer Unit
* @param  responsibleSignums Map with key as Customer Unit Id and value Responsible Signum
* @return                    List of Customer Reporting Groups
*/
    private static List<CustomerReportingGroup__c> findCuCrgList(Map<Id, String> responsibleSignums) {
        
        List<CustomerReportingGroup__c> cuCrgList = new List<CustomerReportingGroup__c>();
        Try{
        for (CustomerReportingGroup__c crg : [Select Id, CRG_ID__c, Account_CU_Head__c, CustomerUnit__c, GlobalCustomerUnit__c
                                              FROM CustomerReportingGroup__c
                                              WHERE CustomerUnit__c IN : responsibleSignums.keySet() OR GlobalCustomerUnit__c IN : responsibleSignums.keySet()]) {
                                                  cuCrgList.add(crg);
                                              }
            }catch(Exception e){	}
        return cuCrgList;
    }
    
    public static void markAsRequireATSRecalc(Map<ID, CustomerUnit__c> newCustomerUnitMap , Map<ID, CustomerUnit__c> oldCustomerUnitMap){
        Try{
        Set<Id> cuIdsForUpdateSet = new Set<Id>();
        for(CustomerUnit__c cu: newCustomerUnitMap.values()){
            if(
                (cu.AP_Lower_Limit__c != oldCustomerUnitMap.get(cu.Id).AP_Lower_Limit__c)
                || 	
                (cu.AP_Upper_Limit__c != oldCustomerUnitMap.get(cu.Id).AP_Upper_Limit__c)
            ){
                cuIdsForUpdateSet.add(cu.Id);
            }
        }
        if(cuIdsForUpdateSet.size() >0)markAccountsATSFlags(cuIdsForUpdateSet);
            }catch(Exception e){	}
    }
    
    @future (callout=true)
    private static void markAccountsATSFlags(Set<Id> cuIdSet){
        Try{
        //NS
        //List<CustomerUnit__c> cuList = [SELECT Id, (select id from Customer_Reporting_Groups__r) FROM CustomerUnit__c WHERE Id IN: cuIdSet];
        Set<Id> crgIdSet = new Set<Id>();
        for(CustomerUnit__c cu: [SELECT Id, (select id from Customer_Reporting_Groups__r) FROM CustomerUnit__c WHERE Id IN: cuIdSet]){
            for(CustomerReportingGroup__c crg: cu.Customer_Reporting_Groups__r){
                crgIdSet.add(crg.Id);
            }
        }
        
        //NS
        //List<CustomerReportingGroup__c> crgList = [SELECT Id, (select id from Accounts__r) FROM CustomerReportingGroup__c WHERE Id IN: crgIdSet];
        Set<Id> accIdSet = new Set<Id>();
        List<Account> accToUpdateList = new List<Account>();
        for(CustomerReportingGroup__c crg: [SELECT Id, (select id from Accounts__r) FROM CustomerReportingGroup__c WHERE Id IN: crgIdSet]){
            for(Account acc: crg.Accounts__r){
                acc.Requires_ATS_Batch_Recalculation__c = true;
                accToUpdateList.add(acc);
            }
        }
        
        try{
            update accToUpdateList;
        }catch (Exception e){
            EventLog.createLog(new EventLog.Error('CustomerUnitTriggerHandlerHelper', 'makeOppPublishCalloutFuture', 'CustomerUnitTriggerHandlerHelper_triggerOpportunitiesUpdate', true, e));
            System.debug(LoggingLevel.ERROR, 'CustomerUnitTriggerHandlerHelper error =' + e.getMessage());
        }
            }catch(Exception e){	}
    }
    
    //implemented as a fix to defect 1309 to re-trigger ATS flag re-calc on related Opportunities
    public static void triggerOpportunitiesUpdate(Set<Id> accIdSet){
        
        //NS
        //List<Account> accList = [SELECT Id, (select id from Opportunities) FROM Account WHERE Id IN: accIdSet];
        Set<Id> oppIdSet = new Set<Id>();
        for(Account acc: [SELECT Id, (select id from Opportunities) FROM Account WHERE Id IN: accIdSet]){
            for(Opportunity opp: acc.Opportunities){
                oppIdSet.add(opp.Id);
            }
        }
        
        
        List<Opportunity> oppToUpdateList = new List<Opportunity>();
        for(Id oppId: oppIdSet){
            oppToUpdateList.add(new Opportunity(Id = oppId));
        }
        
        try{
            update oppToUpdateList;
        }catch (Exception e){
            EventLog.createLog(new EventLog.Error('CustomerUnitTriggerHandlerHelper', 'makeOppPublishCalloutFuture', 'CustomerUnitTriggerHandlerHelper_triggerOpportunitiesUpdate', true, e));
            System.debug(LoggingLevel.ERROR, 'CustomerUnitTriggerHandlerHelper error =' + e.getMessage());
        }
    }
    
    /****************************************************************
* @author: Manu Singhal,Ankit Jain
* @date: 20-07-2020
* @param: oldCRGMap,newCRGMap
* @description: D-1921 This method will update CRG sharing on changing CGR field value in  territory
*****************************************************************/
   public static void updateCuGcuSharing(List<CustomerUnit__c> newCustomerUnits,Map<ID, CustomerUnit__c> oldCustomerUnitMap){
        try{
            Map<id,List<id>> cuGroupMap = new Map<id,List<id>>();
            List<CustomerUnit__Share> cuShareListToInsert = new List<CustomerUnit__Share>(); 
            for(CustomerUnit__c cu:newCustomerUnits){
                if((cu.UpdateSharing__c == true && oldCustomerUnitMap.isEmpty())||(!oldCustomerUnitMap.isEmpty() && cu.UpdateSharing__c != oldCustomerUnitMap.get(cu.id).UpdateSharing__c && cu.UpdateSharing__c == true)){
                    if(cu.RecordTypeId == GlobalConstants.gcuRecordTypeId){
                        for(Territory2 territoryVal : [select Id, Territory2Type.DeveloperName, ParentTerritory2.Id, ParentTerritory2.Territory2Type.DeveloperName, ParentTerritory2.ParentTerritory2.Id, ParentTerritory2.ParentTerritory2.Territory2Type.DeveloperName, ParentTerritory2.ParentTerritory2.ParentTerritory2.Id, ParentTerritory2.ParentTerritory2.ParentTerritory2.Territory2Type.DeveloperName, Name, DeveloperName, CRG__c, CAG__c from Territory2 where Name =:GlobalConstants.GCUHYPHEN+cu.Name Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                            List<Id> relatedGroupList=new List<Id>();
                            relatedGroupList.add(territoryVal.Id);
                            relatedGroupList.add(territoryVal.ParentTerritory2.Id);
                            cuGroupMap.put(cu.id,relatedGroupList);
                        }
                    }
                    else if(cu.RecordTypeId == GlobalConstants.cuRecordTypeId && cu.Market_Area__c!=null){
                        for(Territory2 territoryVal : [select Id, Territory2Type.DeveloperName, ParentTerritory2.Id, ParentTerritory2.Territory2Type.DeveloperName, ParentTerritory2.ParentTerritory2.Id, ParentTerritory2.ParentTerritory2.Territory2Type.DeveloperName, ParentTerritory2.ParentTerritory2.ParentTerritory2.Id, ParentTerritory2.ParentTerritory2.ParentTerritory2.Territory2Type.DeveloperName, Name, DeveloperName, CRG__c, CAG__c from Territory2 where Name =:cu.Market_Area__c+' CU - '+cu.Name Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                            List<Id> relatedGroupList=new List<Id>();
                            relatedGroupList.add(territoryVal.Id);
                            relatedGroupList.add(territoryVal.ParentTerritory2.Id);
                            relatedGroupList.add(territoryVal.ParentTerritory2.ParentTerritory2.Id);
                            cuGroupMap.put(cu.id,relatedGroupList);
                        }
                    }  
                }                       
            }
            if(!cuGroupMap.isEmpty()){
                for(Id cuId : cuGroupMap.keySet()){
                    for(Group grpRec:[select id from group where RelatedId IN:cuGroupMap.get(cuId) and type=:GlobalConstants.TERRITORY Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                        CustomerUnit__Share  cuShare=new CustomerUnit__Share ();
                        cuShare.ParentId=cuId;
                        cuShare.UserOrGroupId=grpRec.Id;
                        cuShare.AccessLevel=GlobalConstants.Edit;
                        cuShare.RowCause=GlobalConstants.Manual;
                        cuShareListToInsert.add(cuShare);
                    } 
                }
            }
            if(!cuShareListToInsert.isEmpty())
                insert cuShareListToInsert;
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.CustomerUnitTriggerHandlerHelper, GlobalConstants.updateCuGcuSharing, 
                                                                                        GlobalConstants.CustomerUnitTriggerHandlerHelper, true, e)));}
    }   
}