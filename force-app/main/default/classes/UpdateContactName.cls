/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-07 
* @description: This batch class will update Contact Name this batch class should only be run sandbox to scramble the Name(U-1010)
********************************************************************/
global class UpdateContactName implements Database.Batchable<sObject> 
{
 
    global Database.QueryLocator start(database.BatchableContext bc)
    {
        String query = GlobalConstants.contactQuery;
        return Database.getQueryLocator(query);
    }
    global void execute(database.BatchableContext bc,List<Contact> Scope)
    {
        List<Contact> con= new List<Contact>();
        Integer count = 10000;
        for(Contact c: Scope)
        {
            c.LastName= GlobalConstants.CON + GlobalConstants.DASH + String.valueof(count); 
            con.add(c);
            count++;
        }
            if(!GlobalConstants.salesforceBaseURL.contains(GlobalConstants.baseURL))
         {
          database.update(con, false);
         }
        
    }
        global void finish(database.BatchableContext bc){
        } 
}