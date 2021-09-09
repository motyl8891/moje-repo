/******************************************************************************************
*
* @author       : Shubham Kadam
* @date         : 09/10/2020
* @description  : U-2039
* @testClass    : EUFTTriggerHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------    
Shubham Kadam               09/10/2020          Original Version                
Shubham Kadam               14/12/2020          U-2399 updateManualSBStatusRequired Method Created
******************************************************************************************/
public without sharing class EUFTTriggerHelper 
{
    Public static Boolean euftFlag = true;
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 09/10/2020
* @param: newEUFT, oldEUFTMap
* @description: U-2039 
*****************************************************************/
    public static void updateSBSStatus(List<EUFT__c> newEUFT, Map<ID, EUFT__c> oldEUFTMap)  
    {
        try 
        {
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            Set<Id> oppIdSet = new Set<Id>();
            Set<Id> allOppIdSet = new Set<Id>();
            for(EUFT__c euftObj : newEUFT) {
                if(euftObj.ExemptionKeys__c != null && euftObj.ExemptionKeys__c != oldEUFTMap.get(euftObj.Id).ExemptionKeys__c) {
                    oppIdSet.add(euftObj.Opportunity__c); 
                }        
                allOppIdSet.add(euftObj.Opportunity__c);
            }
            //Map<Id,Opportunity> mapOppIDwithOpp = new Map<Id,Opportunity>([Select ID, Name, ManualSBStatusRequired__c, SBSPilot__c,Proposal_Count__c ,Sales_Compliance_Country_Risk__c,Trade_Classifications__c 
            // from Opportunity where ID IN : allOppIdSet
            // Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);

            List<opportunity> oppList = [Select Id, Name, StageName, SBSStatus__c From Opportunity where Id IN: oppIdSet 
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            if(!oppList.isEmpty()) {
                for(Opportunity opp : oppList) {
                    if((opp.SBSStatus__c == GlobalConstants.Successful || opp.SBSStatus__c == GlobalConstants.PartiallyCompleted || opp.SBSStatus__c == GlobalConstants.Failed) /*&& (opp.StageName == GlobalConstants.Create_Proposal || 
                                                                          opp.StageName == GlobalConstants.Negotiate_and_Close)*/)
                    {
                        opp.SBSStatus__c = GlobalConstants.TriggerRequired;
                        opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED; //U-2386
                        opp.SBSMessage__c = null;
                        opp.SBSResult__c = null;
                        oppUpdateList.add(opp);
                    }
                }				
            }
            
            if(!allOppIdSet.isEmpty()) {
                List<Opportunity> euftOppList = [Select Id, Name, ManualSBStatusRequired__c, SBSPilot__c,Proposal_Count__c ,Sales_Compliance_Country_Risk__c,Trade_Classifications__c,
                                                 (select Id, Name, Opportunity__c, ExemptionKeys__c,TechnologyRiskThreshold__c from EUFTs__r ) 
                                                 from Opportunity where Id IN: allOppIdSet 
                                                 Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                for(Opportunity opp : euftOppList)
                {Boolean thresholdFlag = false;
                 Boolean hasExemptionKey=false;
                 
                 for(EUFT__c eu : opp.EUFTs__r)
                 {
                     
                     if(eu.ExemptionKeys__c != null){
                         hasExemptionKey = true;
                     }
                     if(eu.TechnologyRiskThreshold__c >= 0 && eu.TechnologyRiskThreshold__c <= 10){
                         thresholdFlag = true;
                     }
                 }
                 
                 if(!(hasExemptionKey || (opp.Proposal_Count__c > 0 &&
                                          ((opp.Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_CAMEL || 
                                            opp.Sales_Compliance_Country_Risk__c == GlobalConstants.MEDIUM_CAMEL) ||
                                           (opp.Sales_Compliance_Country_Risk__c == GlobalConstants.CAMEL_LOW && 
                                            (opp.Trade_Classifications__c == GlobalConstants.DEFENSE 
                                             || opp.Trade_Classifications__c == GlobalConstants.GOVERNMENT)))&& thresholdFlag)))
                 {
                     opp.SBSAutomationRequired__c = false;
                     oppUpdateList.add(opp);
                 }
                 else{
                     opp.SBSAutomationRequired__c = true;
                     oppUpdateList.add(opp);
                 }
                 
                }
            }
            
            if(!oppUpdateList.isEmpty()){
                database.update(oppUpdateList); 
            }
        }
        catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EUFTTriggerHelper, 
                                                                       GlobalConstants.updateSBSStatus,
                                                                       GlobalConstants.EUFTTriggerHelper, 
                                                                       true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 13/10/2020
* @param: newEUFT
* @description: U-2184 Update Ship_To_Countries__c with the countries of EUFTs 
*****************************************************************/
    public static void updateShipToCountries(List<EUFT__c> newEUFT)  
    {
        try 
        {
            Set<Id> oppIdSet = new Set<Id>();
            List<String> oglistOfCountries = new List<String>();
            Set<String> setOfCountries = new Set<String>();
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            
            for(EUFT__c euftObj : newEUFT)
            {
                oppIdSet.add(euftObj.Opportunity__c);
            }
            List<Opportunity> oppList = [Select Id, Name, Ship_To_Countries__c,
                                         (select Id, Name, Opportunity__c, EUFT__r.BillingCountryCode from EUFTs__r ) 
                                         from Opportunity where Id IN: oppIdSet 
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            
            for(Opportunity opp : oppList)
            {
                for(EUFT__c euftObj : opp.EUFTs__r)
                {
                    if(euftObj.EUFT__r.BillingCountryCode != GlobalConstants.BLANK) {
                        setOfCountries.add(euftObj.EUFT__r.BillingCountryCode);
                    }                    
                }
                oglistOfCountries.addAll(setOfCountries);
                opp.Ship_To_Countries__c = String.join(oglistOfCountries,GlobalConstants.SEMICOLON);
                oppUpdateList.add(opp);    
            }
            
            if(!oppUpdateList.isEmpty()) {
                database.update(oppUpdateList);
            }
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EUFTTriggerHelper, 
                                                                       GlobalConstants.updateShipToCountries,
                                                                       GlobalConstants.EUFTTriggerHelper, 
                                                                       true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Jagatap
* @date: 19/11/2020
* @param: newEUFT
* @description: U-2184 Update Country Risk of EUFTs from Custom Setting
*****************************************************************/
    public static void updateCountryRisk(List<EUFT__c> newEUFT)  
    {
        List<Country_Risk__c> countryRiskCustomSetting = [Select Id,Name, RiskValue__c from Country_Risk__c];
        Set<String> countryCodes = new Set<String>();
        map<Id,String> mapAccountBillingCountry = new map<Id,String>();
        Set<Id> setAccountId = new Set<Id>();
        List<Account> listAccount = new List<Account>();
        
        try
        {
            for(Country_Risk__c cr : countryRiskCustomSetting){
                countryCodes.add(cr.Name);
            }
            for(EUFT__c euftObj : newEUFT){
                setAccountId.add(euftObj.EUFT__c);                   
            }
            listAccount = [select Id, Name, BillingCountryCode from Account where Id in :setAccountId];
            for(Account acc : listAccount){
                if(acc.BillingCountryCode!=null){
               //mapAccountBillingCountry.put(acc.Id,acc.BillingCountry.substringAfter(GlobalConstants.COMMA).replaceAll( '\\s+', ''));
               mapAccountBillingCountry.put(acc.Id,acc.BillingCountryCode);
                }
            }
            for(EUFT__c euftObj : newEUFT){  
                if(countryCodes.contains(mapAccountBillingCountry.get(euftObj.EUFT__c))){          
                    euftObj.Country_Risk_Number__c = Country_Risk__c.getValues(mapAccountBillingCountry.get(euftObj.EUFT__c)).RiskValue__c;  
                }
            }
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EUFTTriggerHelper, 
                                                                       GlobalConstants.updateCountryRisk,
                                                                       GlobalConstants.EUFTTriggerHelper, 
                                                                       true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 14-12-2020
* @param: newEUFT
* @description: U-2399 This Method will Set the ManualSBStatusRequired__c to true, 
if the newly added EUFT has a non-empty Consolidated Block List
*****************************************************************/
    public static void updateManualSBStatusRequired(List<EUFT__c> newEUFT)  
    {
        try 
        {
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            Set<ID> oppSet = new Set<ID>();
            Set<ID> accSet = new Set<ID>();
            
            for(EUFT__c eu : newEUFT) {
                oppSet.add(eu.Opportunity__c);
                accSet.add(eu.EUFT__c);
            }
            
            Map<Id,Opportunity> mapOppIDwithOpp = new Map<Id,Opportunity>([Select ID, Name, ManualSBStatusRequired__c, SBSPilot__c,Sales_Compliance_Country_Risk__c,Trade_Classifications__c,
                                                                           UseCase__c,Purpose__c,SBSStatus__c,Proposal_Count__c from Opportunity where ID IN : oppSet
                                                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            Map<Id,Account> mapAccIDWithAcc = new Map<Id,Account>([Select ID, Name, ConsolidatedBlockList__c from Account where ID IN : accSet
                                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            
            Map<Id,List<EUFT__c>> mapOppWithEUFT = new Map<Id,List<EUFT__c>>();
            Map<Id,EUFT__c> mapOppWithEUFT_Threashold = new Map<Id,EUFT__c>();
           /* Map<Id,EUFT__c> mapOppWithEUFT_ConsolBlockList = new Map<Id,EUFT__c>();*/
            Map<Id,EUFT__c> mapOppWithEUFT_ThreasholdBetween0to10 = new Map<Id,EUFT__c>();
            Map<Id,EUFT__c> mapOppWithEUFT_ExemptionKey = new Map<Id,EUFT__c>();
            for(Opportunity opp :[Select Id, Name, ManualSBStatusRequired__c, SBSPilot__c,Proposal_Count__c ,Sales_Compliance_Country_Risk__c,Trade_Classifications__c,
                                  (select Id, Name, Opportunity__c, ExemptionKeys__c,TechnologyRiskThreshold__c,EUFT__r.ConsolidatedBlockList__c from EUFTs__r ) 
                                  from Opportunity where Id IN: oppSet 
                                  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
                                      for(EUFT__c eu : opp.EUFTs__r){
                                          if(eu.TechnologyRiskThreshold__c > 10) {
                                              mapOppwithEUFT_Threashold.put(eu.Opportunity__c, eu); 
                                          }
                                          if(eu.TechnologyRiskThreshold__c <= 10 && eu.TechnologyRiskThreshold__c >= 0) {
                                              mapOppWithEUFT_ThreasholdBetween0to10.put(eu.Opportunity__c, eu); 
                                          }
                                          /*if(eu.EUFT__r.ConsolidatedBlockList__c != null) {
                                              mapOppWithEUFT_ConsolBlockList.put(eu.Opportunity__c, eu); 
                                          }*/
                                          if(eu.ExemptionKeys__c != null ) {
                                              mapOppWithEUFT_ExemptionKey.put(eu.Opportunity__c, eu); 
                                          }
                                      }
                                      mapOppWithEUFT.put(opp.id, opp.EUFTs__r);     
                                  }
            
            for(EUFT__c eu : newEUFT) {
                if(mapAccIDWithAcc.containsKey(eu.EUFT__c) && mapOppIDwithOpp.containsKey(eu.Opportunity__c) /*&& 
                   mapAccIDWithAcc.get(eu.EUFT__c).ConsolidatedBlockList__c != null*/ && mapOppWithEUFT_ExemptionKey.containsKey(eu.Opportunity__c) && mapOppIDwithOpp.get(eu.Opportunity__c).SBSPilot__c) {
                       Opportunity opp = mapOppIDwithOpp.get(eu.Opportunity__c);
                       opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED; //U-2386
                       opp.ManualSBStatusRequired__c = true;  //set ManualSBStatusRequired__c flag U-2386
                       // OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(opp);   //U-2391
                       oppUpdateList.add(opp);
                   }
                else{
                    if(mapOppIDwithOpp.containsKey(eu.Opportunity__c) && mapOppIDwithOpp.get(eu.Opportunity__c).SBSPilot__c 
                       && !(mapOppIDwithOpp.get(eu.Opportunity__c).Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_LOWER || (mapOppIDwithOpp.get(eu.Opportunity__c).Trade_Classifications__c == GlobalConstants.GOVERNMENT || mapOppIDwithOpp.get(eu.Opportunity__c).Trade_Classifications__c == GlobalConstants.DEFENSE) ||
                            (mapOppIDwithOpp.get(eu.Opportunity__c).UseCase__c != null && mapOppIDwithOpp.get(eu.Opportunity__c).UseCase__c.contains(GlobalConstants.Other)) || (mapOppIDwithOpp.get(eu.Opportunity__c).Purpose__c != null && mapOppIDwithOpp.get(eu.Opportunity__c).Purpose__c.contains(GlobalConstants.PURPOSE_SURVEILLANCE))
                            || mapOppWithEUFT_Threashold.containsKey(eu.Opportunity__c) /*|| mapAccIDWithAcc.get(eu.EUFT__c).ConsolidatedBlockList__c != null*/)) 
                    {  
                        Opportunity opp = new Opportunity();
                        opp.id = eu.Opportunity__c;
                        opp.ManualSBStatusRequired__c = false;
                        //OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(opp);   //U-2391
                        //check if not trigger Required
                        if(!((mapOppIDwithOpp.get(eu.Opportunity__c).Proposal_Count__c > 0 || mapOppWithEUFT_ExemptionKey.containsKey(eu.Opportunity__c)) && 
                             ((mapOppIDwithOpp.get(eu.Opportunity__c).Sales_Compliance_Country_Risk__c == GlobalConstants.HIGH_CAMEL || 
                               mapOppIDwithOpp.get(eu.Opportunity__c).Sales_Compliance_Country_Risk__c == GlobalConstants.MEDIUM_CAMEL) ||
                              (mapOppIDwithOpp.get(eu.Opportunity__c).Sales_Compliance_Country_Risk__c == GlobalConstants.CAMEL_LOW && 
                               (mapOppIDwithOpp.get(eu.Opportunity__c).Trade_Classifications__c == GlobalConstants.DEFENSE 
                                || mapOppIDwithOpp.get(eu.Opportunity__c).Trade_Classifications__c == GlobalConstants.GOVERNMENT))) &&
                             (mapOppWithEUFT_ThreasholdBetween0to10.containsKey(eu.Opportunity__c) || mapOppWithEUFT_ExemptionKey.containsKey(eu.Opportunity__c)) )){
                                 opp.Sensitive_Business_Status__c = GlobalConstants.NotRequired;
                             }
                        oppUpdateList.add(opp);
                    }  
                }
            }
            
            if(!oppUpdateList.isEmpty()){
                database.update(oppUpdateList); 
            }
        }
        catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EUFTTriggerHelper, 
                                                                       GlobalConstants.updateManualSBStatusRequired,
                                                                       GlobalConstants.EUFTTriggerHelper, 
                                                                       true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 17-12-2020
* @param: newEUFT, oldEUFTMap, isInsert, isUpdate
* @description: U-2386 This Method will Set the Sensitive Business Status on Opportunity
*****************************************************************/
    public static void updateSensitiveBusinessStatus(List<EUFT__c> newEUFT, Map<ID, EUFT__c> oldEUFTMap, boolean isInsert, boolean isUpdate)  
    {
        try 
        {
            List<Opportunity> oppUpdateList = new List<Opportunity>();
            Set<ID> oppSet = new Set<ID>();
            
            for(EUFT__c eu : newEUFT) {
                oppSet.add(eu.Opportunity__c);
            }
            
            Map<Id,Opportunity> mapOppIDwithOpp = new Map<Id,Opportunity>([Select ID, Name, SBSPilot__c,Sensitive_Business_Status__c from Opportunity where ID IN : oppSet
                                                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
            for(EUFT__c eu : newEUFT) {
                Opportunity opp = mapOppIDwithOpp.get(eu.Opportunity__c);
                if(isInsert && mapOppIDwithOpp.containsKey(eu.Opportunity__c) && mapOppIDwithOpp.get(eu.Opportunity__c).SBSPilot__c &&
                   eu.TechnologyRiskThreshold__c != null && eu.TechnologyRiskThreshold__c > 10) 
                {
                    opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                    opp.ManualSBStatusRequired__c = true;  //set ManualSBStatusRequired__c flag U-2386
                    //OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(opp);   //U-2391
                    oppUpdateList.add(opp);
                }
                else if(isUpdate && mapOppIDwithOpp.containsKey(eu.Opportunity__c) && mapOppIDwithOpp.get(eu.Opportunity__c).SBSPilot__c){
                    if(eu.TechnologyRiskThreshold__c != null && //eu.TechnologyRiskThreshold__c != oldEUFTMap.get(eu.Id).TechnologyRiskThreshold__c && 
                       eu.TechnologyRiskThreshold__c > 10)
                    {
                        opp.Sensitive_Business_Status__c = GlobalConstants.REQUIRED;
                        opp.ManualSBStatusRequired__c = true;  //set ManualSBStatusRequired__c flag U-2386
                        //OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(opp);  //U-2391
                        oppUpdateList.add(opp);	
                    }
                    else{
                        euftFlag = false;
                    }
                } 
            }
            
            if(!oppUpdateList.isEmpty()){
                database.update(oppUpdateList);
            }
        }
        catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.EUFTTriggerHelper, 
                                                                       GlobalConstants.updateManualSBStatusRequired,
                                                                       GlobalConstants.EUFTTriggerHelper, 
                                                                       true, e)));
        }
    }
    
    /****************************************************************
* @author: Shubham Jagatap
* @date: 14-12-2020
* @param: newEUFT, oldEUFTMap
* @description: U-2385 Call Reset Secondary Approval Status
************************************************************************/
    public static void CallResetSecondaryApprovalStatusFromEUFT(List<EUFT__c> newEUFT, Map<ID, EUFT__c> oldEUFTMap)  
    {
        try 
        {
            Set<String> oppIdSet = new Set<String>();
            Set<String> secApprovalSet = new Set<String>();
            for(EUFT__c eu:newEUFT){
                if(eu.ExemptionKeys__c != oldEUFTMap.get(eu.id).ExemptionKeys__c || eu.TechnologyRiskThreshold__c != oldEUFTMap.get(eu.id).TechnologyRiskThreshold__c){
                    oppIdSet.add(eu.Opportunity__c);
                }
            }
            for(Opportunity opp :[SELECT id,Name, ActiveSensitiveBusinessApproval__c from Opportunity where id in : oppIdSet]){
                if(opp.ActiveSensitiveBusinessApproval__c != null)
                {
                    secApprovalSet.add(opp.ActiveSensitiveBusinessApproval__c);
                }
            }
            if(!secApprovalSet.isEmpty()){
                OpportunityTriggerHepler2.ResetSecondaryApprovalStatus(secApprovalSet);
            }
        }
        catch(Exception e)
        {
            
        }
    }
    
}