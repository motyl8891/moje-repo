global class UpdateTradeComplianceOnOpp implements Database.Batchable<sObject> {	
    Map<id,Account> accounts = new Map<id,Account>();
    List<Account> parentAccount = new List<Account>(); 
    List<Opportunity> oppsToUpdateList = new List<Opportunity>();
    String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
    String oppStageDefineCustomerValue = GlobalConstants.Define_CustomerValue;
    String oppStageCreateProposal = GlobalConstants.Create_Proposal;
    String oppStageNegotiateandClose = GlobalConstants.Negotiate_and_Close;
    global final string str ;
    global UpdateTradeComplianceOnOpp(Map<id,Account> acctMap) 
    {
		accounts = acctMap;
    parentAccount =  accounts.values();
    str = GlobalConstants.UpdateTradeComplianceOnOppQuery;
    }
   
	    global Database.QueryLocator start(Database.BatchableContext BC) { 
	        return DataBase.getQueryLocator(str);    
    } 
    global void execute(Database.BatchableContext BC , List <Opportunity> scope) {
        Boolean sensitiveFlag = false;
       List<String> sensitiveCountryList = new List<String>();
       List<String> shipToCountrySet = new List<String>();
       Map<Account, List<Opportunity>> accWithOpptyListMap = new Map<Account, List<Opportunity>>();
        for(Country_Risk__c countryRisk : [Select TC_Sensitivy_Class__c,Name from Country_Risk__c 
                                          where TC_Sensitivy_Class__c =: GlobalConstants.SENSITIVE
                                          Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                sensitiveCountryList.add(countryRisk.Name);
            }   
        for (account acct : parentAccount){
            accWithOpptyListMap.put(acct,oppsToUpdateList);
        for (opportunity opp :scope){
             if(opp.Ship_To_Countries__c != null)
                    {
                        shipToCountrySet = opp.Ship_To_Countries__c.split(GlobalConstants.SEMICOLON);
                        for(string str : shipToCountrySet)
                        {
                            if(sensitiveCountryList.contains(str))
                                sensitiveFlag  = true;
                        }
                    }
            if(opp.AccountId==acct.id && (opp.stagename == oppStageQualifyOppty ||opp.stagename == oppStageDefineCustomerValue ||
           opp.stagename == oppStageCreateProposal||opp.stagename == oppStageNegotiateandClose))
                {
        if ((acct.Trade_Classification__c == GlobalConstants.DEFENSE)|| (acct.Trade_Classification__c == GlobalConstants.GOVERNMENT)){ 
                oppsToUpdateList.add(new Opportunity( Id = opp.Id,Trade_Compliance_Status__c = GlobalConstants.REQUIRED)); 
            	 //OpportunityUtils.sendEmailToAllOpptysForTradeCompliance(accWithOpptyListMap);
                }else 
                    if(!sensitiveFlag && opp.Trade_Classifications__c != GlobalConstants.GOVERNMENT && opp.Trade_Classifications__c != GlobalConstants.DEFENSE && acct.Trade_Classification__c == GlobalConstants.CIVIL)
                    {
                        oppsToUpdateList.add(new Opportunity( Id = opp.Id,Trade_Compliance_Status__c = GlobalConstants.NotRequired)); 
                    }     
                    
                }  
        }Database.update(oppsToUpdateList,false);
        }}
global void finish(Database.BatchableContext BC){ 
} 
}