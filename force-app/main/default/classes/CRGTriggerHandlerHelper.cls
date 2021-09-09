/**
* CustomerReportingGroupTrigger class Helper 
* Used to set correct Account Primary KAM based on Manager value
*/ 
public class CRGTriggerHandlerHelper {
    /**
* Method that updates Account Primary Kam based on Manager value
* @param customerReportingGroups Customer Reporting Group object List
*/
    public static void updateCRGAccountPrimaryKAM(List<CustomerReportingGroup__c> customerReportingGroups, 
                                                  Map<Id, CustomerReportingGroup__c> oldCRGMap) {
                                                      Try{
                                                      Map<Id, String> crgManagerMap = new Map<Id, String>();
                                                      Set<String> crgIdC = new Set<String>();
                                                      for (CustomerReportingGroup__c crg : customerReportingGroups) {
                                                          //updated if condition for U-1059 
                                                          //Updated by Anukriti Agrawal
                                                          if (crg.Manager__c != null && oldCRGMap != null && crg.Manager__c != oldCRGMap.get(crg.Id).Manager__c) {
                                                              crgManagerMap.put(crg.Id, crg.Manager__c);
                                                          }else if(crg.Manager__c != null && oldCRGMap == null) {
                                                              crgManagerMap.put(crg.Id, crg.Manager__c);
                                                          }
                                                      }
                                                      Map<String, Id> userSignums = findUserBySignum(crgManagerMap);
                                                      for (CustomerReportingGroup__c crg : customerReportingGroups) {
                                                          if (crgManagerMap.containsKey(crg.Id)) {
                                                              if (userSignums.containsKey(crgManagerMap.get(crg.Id))) {
                                                                  crg.Account_Primary_KAM__c = userSignums.get(crgManagerMap.get(crg.Id));
                                                                  //crg.Account_CU_Head__c = userSignums.get(crgManagerMap.get(crg.Id));
                                                              } else {
                                                                  crgIdC.add(crg.CRG_ID__c);
                                                              }
                                                          }
                                                      }
                                                          EventLog.createLog(new EventLog.Information('CRGTriggerHandlerHelper', 'updateCRGAccountPrimaryKAM', 'Account Primary KAM Assignment', true, 'Account Primary KAM was not found based on Manager for Customer Reporting Group with ID: ' + crgIdC));
                                                      }catch(Exception e){	}
                                                  }
    
    public static void recalculateCUGCUTargets(List<CustomerReportingGroup__c> customerReportingGroups) {
        
        try{
            Set<Id> cuIdsSet = new Set<Id>();
            for (CustomerReportingGroup__c crg : customerReportingGroups) {
                cuIdsSet.add(crg.CustomerUnit__c);
            }
            
            Set<Id> gcuIdsSet = new Set<Id>();
            for (CustomerReportingGroup__c crg : customerReportingGroups) {
                gcuIdsSet.add(crg.GlobalCustomerUnit__c);
            }
            
            //NS
            //List<CurrencyType> currTypeList = [SELECT IsoCode, ConversionRate from CurrencyType];
            Map<String, Decimal> currToRateMap = new Map<String, Decimal>();
            for(CurrencyType ct: [SELECT IsoCode, ConversionRate from CurrencyType]){
                currToRateMap.put(ct.IsoCode, ct.ConversionRate);
            }
            
            queryAndUpdateTargetsOnCU(cuIdsSet, currToRateMap);
            queryAndUpdateTargetsOnGCU(gcuIdsSet, currToRateMap); 
        }catch (Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error('CRGTriggerHandlerHelper', 'recalculateCUGCUTargets', 'CRGTriggerHandlerHelper Error', true, e)));
            System.debug(LoggingLevel.ERROR, 'CRGTriggerHandlerHelper Get error = ' + e.getStackTraceString());
            throw new UtilException(e.getMessage());
        }
    }
    
    private static void queryAndUpdateTargetsOnCU(Set<Id> cuIdsSet, Map<String, Decimal> currToRateMap){
        Try{
        List<CustomerUnit__c> cuWithCrgList = [
            SELECT Id, CurrencyIsoCode,  
            (Select Id,
             CurrencyIsoCode, 
             Q1_NY_Target__c,
             Q1_Target__c,
             Q2_NY_Target__c,
             Q2_Target__c,
             Q3_NY_Target__c,
             Q3_Target__c,
             Q4_NY_Target__c,
             Q4_Target__c, 
             Annual_Target__c, 
             Next_Year_Annual_Target__c
             From Customer_Reporting_Groups__r) 
            FROM CustomerUnit__c WHERE Id IN:cuIdsSet];
        
        for(CustomerUnit__c cu: cuWithCrgList){
            Decimal q1target = 0;
            Decimal q1NYtarget = 0;
            Decimal q2target = 0;
            Decimal q2NYtarget = 0;
            Decimal q3target = 0;
            Decimal q3NYtarget = 0;
            Decimal q4target = 0;
            Decimal q4NYtarget = 0;
            Decimal annualTarget = 0;
            Decimal annualNYTarget = 0;
            
            for(CustomerReportingGroup__c crg: cu.Customer_Reporting_Groups__r){
                Decimal crgConversionRate = currToRateMap.get(crg.CurrencyIsoCode);
                if(crg.Q1_Target__c != null)q1target+=crg.Q1_Target__c/crgConversionRate;
                if(crg.Q1_NY_Target__c != null)q1NYtarget+=crg.Q1_NY_Target__c/crgConversionRate;
                if(crg.Q2_Target__c != null)q2target+=crg.Q2_Target__c/crgConversionRate;
                if(crg.Q2_NY_Target__c != null)q2NYtarget+=crg.Q2_NY_Target__c/crgConversionRate;
                if(crg.Q3_Target__c != null)q3target+=crg.Q3_Target__c/crgConversionRate;
                if(crg.Q3_NY_Target__c != null)q3NYtarget+=crg.Q3_NY_Target__c/crgConversionRate;
                if(crg.Q4_Target__c != null)q4target+=crg.Q4_Target__c/crgConversionRate;
                if(crg.Q4_NY_Target__c != null)q4NYtarget+=crg.Q4_NY_Target__c/crgConversionRate;
                if(crg.Annual_Target__c != null)annualTarget+=crg.Annual_Target__c/crgConversionRate;
                if(crg.Next_Year_Annual_Target__c != null)annualNYTarget+=crg.Next_Year_Annual_Target__c/crgConversionRate;
            }
            Decimal cuConversionRate = currToRateMap.get(cu.CurrencyIsoCode);
            cu.Q1_Target__c = q1target*cuConversionRate;
            cu.Q1_NY_Target__c = q1NYtarget*cuConversionRate;
            cu.Q2_Target__c = q2target*cuConversionRate;
            cu.Q2_NY_Target__c = q2NYtarget*cuConversionRate;
            cu.Q3_Target__c = q3target*cuConversionRate;
            cu.Q3_NY_Target__c = q3NYtarget*cuConversionRate;
            cu.Q4_Target__c = q4target*cuConversionRate;
            cu.Q4_NY_Target__c = q4NYtarget*cuConversionRate;
            cu.Annual_CU_Target__c = annualTarget*cuConversionRate;
            cu.Next_Year_s_Annual_CU_Target__c = annualNYTarget*cuConversionRate;
        }
        
        update cuWithCrgList;
            }catch(Exception e){	}
    }
    
    private static void queryAndUpdateTargetsOnGCU(Set<Id> gcuIdsSet, Map<String, Decimal> currToRateMap){
        Try{
        List<CustomerUnit__c> cuWithCrgList = [
            SELECT Id,CurrencyIsoCode, 
            (Select Id,
             CurrencyIsoCode, 
             Q1_NY_Target__c,
             Q1_Target__c,
             Q2_NY_Target__c,
             Q2_Target__c,
             Q3_NY_Target__c,
             Q3_Target__c,
             Q4_NY_Target__c,
             Q4_Target__c, 
             Annual_Target__c, 
             Next_Year_Annual_Target__c
             From Customer_Reporting_Groups1__r) 
            FROM CustomerUnit__c WHERE Id IN:gcuIdsSet];
        
        for(CustomerUnit__c cu: cuWithCrgList){
            Decimal q1target = 0;
            Decimal q1NYtarget = 0;
            Decimal q2target = 0;
            Decimal q2NYtarget = 0;
            Decimal q3target = 0;
            Decimal q3NYtarget = 0;
            Decimal q4target = 0;
            Decimal q4NYtarget = 0;
            Decimal annualTarget = 0;
            Decimal annualNYTarget = 0;
            
            for(CustomerReportingGroup__c crg: cu.Customer_Reporting_Groups1__r){
                Decimal crgConversionRate = currToRateMap.get(crg.CurrencyIsoCode);
                if(crg.Q1_Target__c != null)q1target+=crg.Q1_Target__c/crgConversionRate;
                if(crg.Q1_NY_Target__c != null)q1NYtarget+=crg.Q1_NY_Target__c/crgConversionRate;
                if(crg.Q2_Target__c != null)q2target+=crg.Q2_Target__c/crgConversionRate;
                if(crg.Q2_NY_Target__c != null)q2NYtarget+=crg.Q2_NY_Target__c/crgConversionRate;
                if(crg.Q3_Target__c != null)q3target+=crg.Q3_Target__c/crgConversionRate;
                if(crg.Q3_NY_Target__c != null)q3NYtarget+=crg.Q3_NY_Target__c/crgConversionRate;
                if(crg.Q4_Target__c != null)q4target+=crg.Q4_Target__c/crgConversionRate;
                if(crg.Q4_NY_Target__c != null)q4NYtarget+=crg.Q4_NY_Target__c/crgConversionRate;
                if(crg.Annual_Target__c != null)annualTarget+=crg.Annual_Target__c/crgConversionRate;
                if(crg.Next_Year_Annual_Target__c != null)annualNYTarget+=crg.Next_Year_Annual_Target__c/crgConversionRate;
            }
            Decimal cuConversionRate = currToRateMap.get(cu.CurrencyIsoCode);
            cu.Q1_Target__c = q1target*cuConversionRate;
            cu.Q1_NY_Target__c = q1NYtarget*cuConversionRate;
            cu.Q2_Target__c = q2target*cuConversionRate;
            cu.Q2_NY_Target__c = q2NYtarget*cuConversionRate;
            cu.Q3_Target__c = q3target*cuConversionRate;
            cu.Q3_NY_Target__c = q3NYtarget*cuConversionRate;
            cu.Q4_Target__c = q4target*cuConversionRate;
            cu.Q4_NY_Target__c = q4NYtarget*cuConversionRate;
            cu.Annual_CU_Target__c = annualTarget*cuConversionRate;
            cu.Next_Year_s_Annual_CU_Target__c = annualNYTarget*cuConversionRate;
        }
        
        update cuWithCrgList;
            }catch(Exception e){	}
    }
    
    /**
* Method that finds Users based on Manager value
* @param  responsibleSignums Map with key as Customer Reporting Group Id and value Manager
* @return                    Map with key Manager and value Id of User
*/
    public static Map<String, Id> findUserBySignum(Map<Id, String> responsibleSignums) {
        Map<String, Id> userSignums = new Map<String, Id>();
        for (User u : [Select Id, Signum__c FROM User WHERE Signum__c IN : responsibleSignums.values()]) {
            userSignums.put(u.Signum__c, u.Id);
        }
        return userSignums;
    }
    /****************************************************************
* @author: Manu Singhal,Ankit Jain
* @date: 14-07-2020
* @param: newCustomerReportingGroups,oldCustomerReportingGroupMap
* @description: U-1921 & U-1990 This method will remove CRG sharing if CAG is removed from CRG.
*****************************************************************/
    public static void removeCRGSharing(List<CustomerReportingGroup__c> newCustomerReportingGroups,Map<ID, CustomerReportingGroup__c> oldCustomerReportingGroupMap) {
        try{
            Set<id> crgIdSet = new Set<id>();      
            for(CustomerReportingGroup__c crg:newCustomerReportingGroups){
                if(crg.CustomerAccountGroup__c != oldCustomerReportingGroupMap.get(crg.id).CustomerAccountGroup__c && crg.CustomerAccountGroup__c == null)
                    crgIdSet.add(crg.id);			
            }
            if(!crgIdSet.isEmpty()){
                List<CustomerReportingGroup__Share> crgShareListToDelete = [select id,ParentId from CustomerReportingGroup__Share where ParentId IN: crgIdSet and RowCause=:GlobalConstants.Manual Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(!crgShareListToDelete.isEmpty())
                    delete crgShareListToDelete;
            }
        }catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.CRGTriggerHandlerHelper, GlobalConstants.removeCRGSharing, 
                                                                                        GlobalConstants.CRGTriggerHandlerHelper, true, e)));}
    }   
}