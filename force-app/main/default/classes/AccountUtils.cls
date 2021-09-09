/******************************************************************* 
* @author: Linda Pavare 
* @date: 2017-11-23 
* @description: This is Utility class  for Accounts
********************************************************************/
public with sharing class  AccountUtils {
    
    /****************************************************************
* @author: Linda Pavare
* @date: 2017-11-23
* @param: oppId
* @return: query result  
* @description: This method queries Accounts information by given Account Ids
*****************************************************************/   
    public static List<Account> getAccountInfoBySAPid(Set<Decimal> acc){
	        List<Account> accList = [SELECT Id, SAP_S2P_ID_Number__c FROM Account WHERE SAP_S2P_ID_Number__c IN: acc];
	        return accList;
    }

}