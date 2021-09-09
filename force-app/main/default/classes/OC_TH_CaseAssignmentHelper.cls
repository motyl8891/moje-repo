/* Class Name : OC_TH_CaseAssignmentHelper
* Description : This class handles CaseAssignment logic.
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 04 Jun 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-04                 IBM                   Initial Version
**/ 
public with sharing class OC_TH_CaseAssignmentHelper {
    /**** U-2773 || Aayush Sachdeva || Handler method for assigning a new case to Queue using Routing Rules ****/
    public static void caseQueueAssignment (Set<Id> caseRecords) {
        Map<Id,List<OC_TH_Routing_Rules__c>> caseWithRulesMap = new Map<Id,List<OC_TH_Routing_Rules__c>>();
        List<Case> caseOwnerChange = new List<Case>();
        Map<Id,String> caseQueueMap = new Map<Id,String>();
        Map<String,Id> queueMap = new Map<String,Id>();
        try{
            //Fetching new case records
            List<Case> caseList = [select id,OC_TH_LI_CSR__c,OC_TH_Node_Type__c,OC_TH_Main_Asset_Type__c,AssetId,Asset.RecordType.Name,Asset.Product2Id,Asset.Product2.name,Tech_OC_TH_Node_Type_Text__c,Tech_OC_TH_Component_Type_Text__c,Tech_OC_TH_Solution_Type_Text__c,Priority,OC_TH_Contract_Type__c,AccountId,Account.MarketArea__c,Account.CU_Customer_Unit__c,Account.BillingCountry,Account.CNS_Queue__c,OC_TH_Standard_CSR_Assignment_Check__c from case where Id IN :caseRecords];
            /*Fetching all active initial routing rules sorted in descending order of Total Relevance Points without sharing enforced through System Utility Class*/
            List<OC_TH_Routing_Rules__c> routingRuleList = OC_SystemUtility.GetRoutingRulesList();       
            if(!routingRuleList.isempty()){
                for(Case ca:caseList){  
                    /*Concatenating '#' at the beginning and ending of the Product Code for the new Case Record,
                         to ensure that the Product comparison b/w Case and Routing Rule is done correctly*/
                    String nodeTypeProduct ='#'+ca.Tech_OC_TH_Node_Type_Text__c+'#';
                    String nodeComponentProduct ='#'+ca.Tech_OC_TH_Component_Type_Text__c+'#';
                    String solutionType ='#'+ca.Tech_OC_TH_Solution_Type_Text__c+'#';
                    system.debug('nodeTypeProduct'+nodeTypeProduct);
                    for(OC_TH_Routing_Rules__c rules:routingRuleList){
                      /*  system.debug('Tech_OC_TH_Service_To_Party_ID__c--'+rules.Name + rules.Tech_OC_TH_Service_To_Party_ID__c);
                        system.debug('OC_TH_Customer_Market_Area__c--'+rules.Name + rules.OC_TH_Customer_Market_Area__c);
                        system.debug('OC_TH_Customer_Country__c--'+rules.Name + rules.OC_TH_Customer_Country__c);
                        system.debug('nodeTypeProduct--'+ nodeTypeProduct);
                        system.debug('rules.OC_TH_Logic_Operator_Customer__c--'+rules.OC_TH_Logic_Operator_Customer__c.equals('Equal'));
                        system.debug('Condition1' + (String.isBlank(rules.OC_TH_Customer_Market_Area__c)|| (String.isNotBlank(ca.Account.MarketArea__c) && rules.OC_TH_Customer_Market_Area__c.contains(ca.Account.MarketArea__c))));
                        system.debug('Condition2' + (String.isBlank(rules.OC_TH_Customer_CU__c) || (String.isNotBlank(ca.Account.CU_Customer_Unit__c) && rules.OC_TH_Customer_CU__c.contains(ca.Account.CU_Customer_Unit__c))));
                        system.debug('Condition3' + (String.isBlank(rules.OC_TH_CSR_Priority_txt__c) || (String.isNotBlank(ca.Priority) && rules.OC_TH_CSR_Priority_txt__c.contains(ca.Priority))));
                        system.debug('Condition4' + (String.isBlank(rules.OC_TH_NodeTypeProduct__c)|| (String.isNotBlank(nodeTypeProduct) && rules.OC_TH_NodeTypeProduct__c.contains(nodeTypeProduct))));
                        system.debug('Condition5' + (String.isBlank(rules.Tech_OC_TH_Service_To_Party_ID__c) || (rules.OC_TH_Logic_Operator_Customer__c.equals('Equal') && rules.Tech_OC_TH_Service_To_Party_ID__c.contains(ca.AccountId)) || rules.OC_TH_Logic_Operator_Customer__c.equals('Not Equal') && !(rules.Tech_OC_TH_Service_To_Party_ID__c.contains(ca.AccountId))));
                        system.debug('Condition6' + (String.isBlank(rules.OC_TH_Customer_Country__c) || (rules.OC_TH_Logic_Operator_Country__c.equals('Equal') && rules.OC_TH_Customer_Country__c.equals(ca.Account.BillingCountry)) || rules.OC_TH_Logic_Operator_Country__c.equals('Not Equal') && !(rules.OC_TH_Customer_Country__c.equals(ca.Account.BillingCountry))));
                        
                        /* Searching for matching routing rules by comparing case fields to routing rule fields */
                        if((String.isBlank(rules.OC_TH_Customer_Market_Area__c)|| (String.isNotBlank(ca.Account.MarketArea__c) && rules.OC_TH_Customer_Market_Area__c.contains(ca.Account.MarketArea__c))) && (String.isBlank(rules.OC_TH_Customer_CU__c) || (String.isNotBlank(ca.Account.CU_Customer_Unit__c) && rules.OC_TH_Customer_CU__c.contains(ca.Account.CU_Customer_Unit__c))) && (String.isBlank(rules.OC_TH_CSR_Priority_txt__c) || (String.isNotBlank(ca.Priority) && rules.OC_TH_CSR_Priority_txt__c.contains(ca.Priority))) && (String.isBlank(rules.OC_TH_NodeTypeProduct__c)|| (String.isNotBlank(nodeTypeProduct) && rules.OC_TH_NodeTypeProduct__c.contains(nodeTypeProduct)))
                                && (String.isBlank(rules.OC_TH_NodeComponentProduct__c)|| (String.isNotBlank(nodeComponentProduct) && rules.OC_TH_NodeComponentProduct__c.contains(nodeComponentProduct))) && (String.isBlank(rules.OC_TH_SolutionProduct__c)|| (String.isNotBlank(solutionType) && rules.OC_TH_SolutionProduct__c.contains(solutionType))) && (String.isBlank(rules.OC_TH_Contract_Type__c) || (String.isNotBlank(ca.OC_TH_Contract_Type__c) && rules.OC_TH_Contract_Type__c.contains(ca.OC_TH_Contract_Type__c)))
                                && (String.isBlank(rules.Tech_OC_TH_Service_To_Party_ID__c) || (String.isNotBlank(rules.OC_TH_Logic_Operator_Customer__c) && rules.OC_TH_Logic_Operator_Customer__c.equals(OC_TH_Constants.equal) && rules.Tech_OC_TH_Service_To_Party_ID__c.contains(ca.AccountId)) || (String.isNotBlank(rules.OC_TH_Logic_Operator_Customer__c) && rules.OC_TH_Logic_Operator_Customer__c.equals(OC_TH_Constants.notEqual) && !(rules.Tech_OC_TH_Service_To_Party_ID__c.contains(ca.AccountId))))
                                && (String.isBlank(rules.OC_TH_Customer_Country__c) || (String.isNotBlank(rules.OC_TH_Logic_Operator_Country__c) && String.isNotBlank(ca.Account.BillingCountry) && rules.OC_TH_Logic_Operator_Country__c.equals(OC_TH_Constants.equal) && rules.OC_TH_Customer_Country__c.equals(ca.Account.BillingCountry)) || (String.isNotBlank(rules.OC_TH_Logic_Operator_Country__c) && String.isNotBlank(ca.Account.BillingCountry) && rules.OC_TH_Logic_Operator_Country__c.equals(OC_TH_Constants.notEqual) && !(rules.OC_TH_Customer_Country__c.equals(ca.Account.BillingCountry))))){
                                    /* Checking if Case ID already exists in the map*/
                                if(caseWithRulesMap.containsKey(ca.id)){
                                   List<OC_TH_Routing_Rules__c> routRule = caseWithRulesMap.get(ca.id);
                                   routRule.add(rules);
                                   /* Updating the list of matching routing rules in the map against the Case ID*/
                                   caseWithRulesMap.put(ca.id,routRule);
                                   system.debug('caseWithRulesMap----'+caseWithRulesMap);
                               }
                               else{
                                   List<OC_TH_Routing_Rules__c> RoutRuleLis = new List<OC_TH_Routing_Rules__c>();
                                   RoutRuleLis.add(rules);
                                   /* Creating a map of Case Id and matching Routing rule*/
                                   caseWithRulesMap.put(ca.id,RoutRuleLis);
                                   system.debug('caseWithRulesMap----'+caseWithRulesMap);   
                               }
                           }
                    }}
                for(Case ca:caseList){
                    if(!caseWithRulesMap.isempty() && caseWithRulesMap.containsKey(ca.Id)){
                        List<OC_TH_Routing_Rules__c> routingList = caseWithRulesMap.get(ca.id);
                        /* Checking if matching routing rules are more than one*/
                        if(routingList.size() > 1){
                            /* Saving the total relevance points value from the first routing rule */
                            Integer RelevencePnt = (Integer)routingList[0].OC_TH_Total_Relevance_Point__c ;
                            List<OC_TH_Routing_Rules__c> sortByPoints = new List<OC_TH_Routing_Rules__c>();
                            for(OC_TH_Routing_Rules__c routRul: routingList){
                                if(routRul.OC_TH_Total_Relevance_Point__c == RelevencePnt)
                                    /* Adding all the routing rule(s) with the highest relevance points to the list*/
                                    sortByPoints.add(routRul);
                                system.debug('sortByPoints----'+sortByPoints);
                            }
                            if(sortByPoints.size() > 1){
                                /* If there are more than 1 routing rules with the highest relevance points, then adding Account's CNS queue name in the map against Case ID*/
                                caseQueueMap.put(ca.id,ca.Account.CNS_Queue__c);
                            }
                            else{
                                /* If there is only 1 routing rule with the highest relevance points, then adding Routing Rule's target queue name in the map against Case ID */
                                caseQueueMap.put(ca.id,sortByPoints[0].OC_TH_Queue__r.name);}
                        }
                        else if(routingList.size() == 1){
                            /* If there is just one matching routing rule and the routing rule's target queue is 'Account CNS Queue', then the case will be assigned to Account's CNS queue. */
                            if(routingList[0].OC_TH_Queue__r.name.equals(OC_TH_Constants.accountCNSQueue)){
                                caseQueueMap.put(ca.id,ca.Account.CNS_Queue__c);
                            }
                            /* If there is just one matching routing rule then adding the routing rule's target queue's name to the map against Case ID  */
                            else {
                                caseQueueMap.put(ca.id,routingList[0].OC_TH_Queue__r.name);
                            }
                        }
                        system.debug('caseQueueMap----'+caseQueueMap);
                    }}
                /* Using 'caseQueueMap' to find out and update the case owner to the target queue*/
                if(!caseQueueMap.isempty()){
                    for (Group grp : [select Id,Name,type from Group where type ='Queue'and (Name IN:caseQueueMap.Values() OR Name =:OC_TH_Constants.getLICSRQueue)]){
                        queueMap.put(grp.name,grp.id);
                    }
                    system.debug('queueMap----'+queueMap);
                    for(Case ca:caseList){
                        if(caseQueueMap.containskey(ca.Id)){
                            if(ca.OC_TH_LI_CSR__c == True && ca.OC_TH_Standard_CSR_Assignment_Check__c == True && queueMap.containsKey(caseQueueMap.get(ca.Id))){
                                ca.OC_TH_Latest_Queue_Name__c = caseQueueMap.get(ca.Id);
                                ca.ownerId = queueMap.get(OC_TH_Constants.getLICSRQueue);//dummy queue
                                caseOwnerChange.add(ca);
                            }
                            if(ca.OC_TH_Standard_CSR_Assignment_Check__c == True && ca.OC_TH_LI_CSR__c == False){
                                ca.OwnerId = queueMap.get(caseQueueMap.get(ca.Id));
                                caseOwnerChange.add(ca);
                            }
                        }
                    }
                }}
            
            if(caseOwnerChange.size()>0){
                System.debug('Case owner finall check :--'+caseOwnerChange);
              	update caseOwnerChange;
            }}
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseAssignmentUtils,OC_TH_Constants.method_caseQueueAssignment,null, false, e));
        }   
    }
    
    public static void updateCaseWithAssetFields (List<Case> caseList){
        try{
            for(Case cas : caseList){
                if(cas.OC_TH_Main_Asset_Type__c.equals(OC_TH_Constants.getNodeType)){
                    cas.OC_TH_Node_Type__c = cas.AssetId;
                    cas.OC_TH_Component__c = null;
                    cas.OC_TH_Solution__c = null;
                }
                else if(cas.OC_TH_Main_Asset_Type__c.equals(OC_TH_Constants.getNodeComponent)){
                    cas.OC_TH_Node_Type__c = null;
                    cas.OC_TH_Component__c = cas.AssetId;
                    cas.OC_TH_Solution__c = null;
                } 
                else if(cas.OC_TH_Main_Asset_Type__c.equals(OC_TH_Constants.getSolution)){
                    cas.OC_TH_Node_Type__c = null;
                    cas.OC_TH_Component__c = null;
                    cas.OC_TH_Solution__c = cas.AssetId;
                }
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseAssignmentUtils,OC_TH_Constants.method_updateCaseWithAssetFields,null, false, e));
        }
        
        
    }
}