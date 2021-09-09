/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-07 
* @description: This batch class will update Lead Name this batch class should only be run sandbox to scramble the Name (U-1010)
********************************************************************/
global class UpdateLeadName implements Database.Batchable<sObject> 
{
 
    global Database.QueryLocator start(database.BatchableContext bc)
    {
        String query = GlobalConstants.leadQuery;
        return Database.getQueryLocator(query);
    }
    global void execute(database.BatchableContext bc,List<Lead> Scope)
    {
        List<Lead> lead = new List<Lead>();
         Integer count = 10000;
        for(Lead l: Scope)
        {
            l.Lastname= GlobalConstants.LEAD + GlobalConstants.DASH + String.valueof(count); 
            lead.add(l);
            count++;
           
        }
           if(!GlobalConstants.salesforceBaseURL.contains(GlobalConstants.baseURL))
         {
          database.update(lead, false);
          }
        
    }
        global void finish(database.BatchableContext bc){
      
        } 
}