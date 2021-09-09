/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-07 
* @description: This batch class will update Account Name this batch class should only be run sandbox to scramble the Name(U-1010)
********************************************************************/
global class UpdateAccountName implements Database.Batchable<sObject> 
{
 
    global Database.QueryLocator start(database.BatchableContext bc)
    {
        String query = GlobalConstants.accountQuery;
        return Database.getQueryLocator(query);
    }
    global void execute(database.BatchableContext bc,List<Account> Scope)
    {
        List<Account> acc = new List<Account>();
         Integer count = 10000;
        for(Account a: Scope)
        {
        
            a.Name = GlobalConstants.ACC + GlobalConstants.DASH + String.valueof(count);
            acc.add(a);
            count++;
        }
         if(!GlobalConstants.salesforceBaseURL.contains(GlobalConstants.baseURL))
         {
          database.update(acc, false);
         }
    }
        global void finish(database.BatchableContext bc){
        
        } 
}