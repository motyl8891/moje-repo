/****************************************************************
* @author: Manu Singhal  
* @date: 11-10-2019
* @description: This class is a handler class for AccountTrigger(U-0913)
*****************************************************************/
public class AccountTriggerHandler {
    /****************************************************************
* @author: Manu Singhal  
* @date: 11-10-2019
* @param: newAccounts,oldAccounts,newAccountsMap, oldAccountsMap
* @description: This method will be called after update of Accpunt(U-0913)
*****************************************************************/
    public static void onAfterUpdate( List<Account> newAccounts,  List<Account> oldAccounts, Map<ID, Account> newAccountsMap , Map<ID, Account> oldAccountsMap ){
        Map<id,Account> acctMap = new Map<id,Account>();
        //AccountTriggerHelper.sendEmailNotificationForTradeCompliance(newAccountsMap,oldAccountsMap);
        //D-2203
        // AccountTriggerHelper.UpdateTradeComplianceOnOpp(newAccountsMap,oldAccountsMap);
        for (Account acc :newAccounts){
            if(system.isFuture() || system.isBatch()) return;
            Account oldacc = oldAccountsMap.get(acc.id);
            if(acc.Trade_Classification__c != oldacc.Trade_Classification__c){
                acctmap.put(acc.id,acc);
                database.executeBatch(new UpdateTradeComplianceOnOpp(acctmap),1);
            }
        }
    }

    public static void onAfterInsert( List<Account> newAccounts ){
        list<ID> accID= new list<ID>();
          for(Account acc:newAccounts){
              if(acc.CustomerReportingGroup__c!=null){
                  accID.add(acc.id);
              }
          }
          if(!accID.isEmpty()){
            if(!Test.isRunningTest())
             Territorry2Controller.runTerritorryRuleFuture(accID,userinfo.getSessionId()) ;
          }
      
    }

}