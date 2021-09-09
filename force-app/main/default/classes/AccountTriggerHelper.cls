/****************************************************************
* @author: Manu Singhal  
* @date: 11-10-2019
* @description: This class is a helper class for AccountTrigger and will be called from AccountTriggerHandler(U-0913)
*****************************************************************/
public class AccountTriggerHelper {
    /****************************************************************
* @author: Manu Singhal  
* @date: 11-10-2019
* @param: newAccountsMap, oldAccountsMap
* @description: This method will check if the oppty is eligible for trade compliance email based on billing country and trade classification(U-0913)
*****************************************************************/
 
    /* public static void sendEmailNotificationForTradeCompliance(Map<ID, Account> newAccountsMap , Map<ID, Account> oldAccountsMap)
    {
        try
        {
            String oppStageCreateProposal = System.Label.Sales_Stage_3_Create_Proposal;
            String oppStageNegotiateandClose = System.Label.Sales_Stage_4_Negotiate_and_Close;
            List<String> sensitiveCountryList = new List<String>();
            Set<id> accountIdSet = new Set<id>();
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            List<Opportunity> oppToSendEmail = new List<Opportunity>();
            Map<Account, List<Opportunity>> accWithOpptyListMap = new Map<Account, List<Opportunity>>();
            List<Opportunity> opptyList = new List<Opportunity>(); 
            String billingCountry;
            for(Country_Risk__c countryRisk : [Select TC_Sensitivy_Class__c,Name from Country_Risk__c 
                                               where TC_Sensitivy_Class__c =: GlobalConstants.SENSITIVE
                                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                sensitiveCountryList.add(countryRisk.Name);
            }            
            for(Account acc : newAccountsMap.values())
            {
                if(acc.BillingCountry != null)
                {
                    billingCountry = acc.BillingCountry.substringBefore(GlobalConstants.COMMA);
                }
                if((acc.BillingCountry != oldAccountsMap.get(acc.id).BillingCountry &&
                    (sensitiveCountryList.contains(billingCountry)))||
                   (acc.Trade_Classification__c != oldAccountsMap.get(acc.id).Trade_Classification__c &&
                    (acc.Trade_Classification__c == GlobalConstants.GOVERNMENT || 
                     acc.Trade_Classification__c == GlobalConstants.DEFENSE)))
                {
                    accountIdSet.add(acc.id);
                }                    
            }
            if(!accountIdSet.isEmpty())
            {
                for(Opportunity opp : [select id, StageName,Name, AccountId,Trade_Compliance_Status__c,Owner.Name,
                                       Account.BillingCountry , Account.Trade_Classification__c, Account.Name
                                       from Opportunity 
                                       where AccountId in : accountIdSet
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(GlobalConstants.OpenStage.contains(opp.StageName))
                    {     
                        if(accWithOpptyListMap.containsKey(newAccountsMap.get(opp.AccountId)))
                        {
                            opptyList = accWithOpptyListMap.get(newAccountsMap.get(opp.AccountId));
                            opptyList.add(opp);
                            accWithOpptyListMap.put(newAccountsMap.get(opp.AccountId),opptyList);
                        }
                        else
                        {
                            opptyList = new List<Opportunity>();
                            opptyList.add(opp);
                            accWithOpptyListMap.put(newAccountsMap.get(opp.AccountId),opptyList);
                        }
                    }
                    opp.Trade_Compliance_Status__c = GlobalConstants.REQUIRED;
                    oppToUpdateList.add(opp);
                }
            }  
            if(!oppToUpdateList.isEmpty())
                update oppToUpdateList;   
            if(!accWithOpptyListMap.isEmpty())
                OpportunityUtils.sendEmailToAllOpptysForTradeCompliance(accWithOpptyListMap);
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ACCOUNTTRIGGERHELPER, 
                                                                       GlobalConstants.sendEmailNotificationForTradeCompliance, GlobalConstants.ACCOUNTTRIGGERHELPER, true, e)));
        }   
    }*/
    /****************************************************************
* @author: Manu Singhal  
* @date: 20-11-2019
* @param: newAccountsMap, oldAccountsMap
* @description: This method will update oppty trade compliance based on billing country, trade classification.(D-2203)
*****************************************************************/
 /*   public static void updateTradeComplianceOnOppty(Map<ID, Account> newAccountsMap , Map<ID, Account> oldAccountsMap)
    {
        try
        {
            List<String> sensitiveCountryList = new List<String>();
            Set<id> accountIdSet = new Set<id>();
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            Set<String> shipToCountrySet;
            String billingCountry;
            Boolean sensitiveFlag;
            for(Country_Risk__c countryRisk : [Select TC_Sensitivy_Class__c,Name from Country_Risk__c 
                                               where TC_Sensitivy_Class__c =: GlobalConstants.SENSITIVE
                                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                sensitiveCountryList.add(countryRisk.Name);
            }            
            for(Account acc : newAccountsMap.values())
            {
                if(acc.BillingCountry != null)
                {
                    billingCountry = acc.BillingCountry.substringBefore(GlobalConstants.COMMA);
                }
                if(acc.BillingCountry != oldAccountsMap.get(acc.id).BillingCountry ||
                   acc.Trade_Classification__c != oldAccountsMap.get(acc.id).Trade_Classification__c)
                {
                    if(!sensitiveCountryList.contains(billingCountry) 
                      && acc.Trade_Classification__c != GlobalConstants.GOVERNMENT
                      && acc.Trade_Classification__c != GlobalConstants.DEFENSE)
                    {  
                        accountIdSet.add(acc.id);
                    }
                }
            }
            if(!accountIdSet.isEmpty())
            {
                for(Opportunity opp : [select id,Ship_To_Countries__c, AccountId,
                                       Trade_Compliance_Status__c,Trade_Classifications__c
                                       from Opportunity 
                                       where AccountId in : accountIdSet
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    sensitiveFlag = false;
                    if(opp.Ship_To_Countries__c != null)
                    {
                        shipToCountrySet = new Set<String>(opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON));
                        for(string str : shipToCountrySet)
                        {
                            if(sensitiveCountryList.contains(str))
                                sensitiveFlag  = true;
                        }
                    }
                    if(!sensitiveFlag && opp.Trade_Classifications__c != GlobalConstants.GOVERNMENT 
                       && opp.Trade_Classifications__c != GlobalConstants.DEFENSE)
                    {
                        opp.Trade_Compliance_Status__c = GlobalConstants.NotRequired;
                        oppToUpdateList.add(opp);
                    }     
                }
            }  
            if(!oppToUpdateList.isEmpty())
                update oppToUpdateList;  
        }
        catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ACCOUNTTRIGGERHELPER, 
                                                                       GlobalConstants.updateTradeComplianceOnOppty, GlobalConstants.ACCOUNTTRIGGERHELPER, true, e)));
        }   
    }*/
    //NS P2 Fix - 
    /*Public AccountTriggerHelper(){
       }*/
 }