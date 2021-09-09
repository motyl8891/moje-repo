/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-07 
* @description: This batch class will update Opportunity Name. this batch class should only be run sandbox to scramble the Name(U-1010)
    
********************************************************************/
global class UpdateOpportunityName implements Database.Batchable<sObject> 
{
 
    global Database.QueryLocator start(database.BatchableContext bc)
    {
        String query = GlobalConstants.oppQuery;
        return Database.getQueryLocator(query);
    }
    global void execute(database.BatchableContext bc,List<Opportunity> Scope)
    {
       
        List<Opportunity> opp = new List<Opportunity>();
        Integer count = 10000;
         for(Opportunity o: Scope){
             o.Name = GlobalConstants.OPP + GlobalConstants.DASH + String.valueof(count); 
             opp.add(o);
             count++;
         }
         TriggerHandler.enable=false;
         if(!GlobalConstants.salesforceBaseURL.contains(GlobalConstants.baseURL))
         {
          database.update(opp, false);
         }
    }
        global void finish(database.BatchableContext bc){
        TriggerHandler.enable=true;
        } 
}