/****************************************************************
* @author: Pallavi Patil
* @date: 1/8/2020
* @User Story: U-1321
*****************************************************************/
public class EarlyStartHandler {
    /****************************************************************
* @author: Pallavi Patil
* @date:  1/8/2020
*****************************************************************/
    public static void onBeforeInsert(List<EarlyStart__c> newEarlystart)
    {
        EarlyStartHelper.updateParentOppOnCreation(newEarlystart);
        EarlyStartHelper.updateCurrencyFromES(newEarlystart);
        //U-1930
        EarlyStartHelper.setApprovers(newEarlystart,null,true);
        //U-0887
        EarlyStartHelper.setApproversOnExtension(newEarlystart);
        //U-2190
       EarlyStartHelper.getSignumofUser(newEarlystart,null,true); 
    }
    public static void onAfterInsert(List<EarlyStart__c> newEarlystart,Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap){
        EarlyStartHelper.updateExtensionFromES(newEarlystartMap,oldEarlystartMap,true);
        EarlyStartHelper.updateESFromExtension(newEarlystartMap,oldEarlystartMap);
        // EarlyStartHelper.updateESStatusFromExtension(newEarlystartMap,oldEarlystartMap);          
    }   
    /****************************************************************
* @author: Richa Gupta
* @date:  10/18/2020
* @UserStory:1930
*****************************************************************/
    public static void onBeforeUpdate(List<EarlyStart__c> newEarlystart,Map<id,EarlyStart__c> oldEarlystartMap){
       map<string,string>mapofupdatedfields= GlobalConstants.returnUserValue();
        for(EarlyStart__c es:newEarlystart){
            if(es.RecalculateApprovers__c!=oldEarlystartMap.get(es.id).RecalculateApprovers__c
               ||es.Estimated_Cost_for_Early_Start_Scope__c!=oldEarlystartMap.get(es.id).Estimated_Cost_for_Early_Start_Scope__c
               ||es.Reason_for_Early_Start__c!=oldEarlystartMap.get(es.id).Reason_for_Early_Start__c
               ||es.BAPartofEarlyStartScope__c!=oldEarlystartMap.get(es.id).BAPartofEarlyStartScope__c
               ||es.Commodities__c!=oldEarlystartMap.get(es.id).Commodities__c){
                   EarlyStartHelper.setApprovers(newEarlystart,oldEarlystartMap,false); 
               }
            //U-1910
            if(es.Reason_for_Early_Start__c!=oldEarlystartMap.get(es.id).Reason_for_Early_Start__c
               ||es.Commodities__c!=oldEarlystartMap.get(es.id).Commodities__c
               ||es.BAPartofEarlyStartScope__c!=oldEarlystartMap.get(es.id).BAPartofEarlyStartScope__c){
               EarlyStartHelper.disappearApprovers(newEarlystart, oldEarlystartMap);
               }
            //U-2190
            for(string s:mapofupdatedfields.keyset()){
                if(es.get(s)!=oldEarlystartMap.get(es.id).get(s)){
                 EarlyStartHelper.getSignumofUser(newEarlystart,oldEarlystartMap,false);  
                }
            }
        }
    }
    /****************************************************************
* @author: Pallavi Patil
* @date:  1/8/2020
*****************************************************************/
    public static void onAfterUpdate(Map<id,EarlyStart__c> newEarlystartMap,Map<id,EarlyStart__c> oldEarlystartMap)
    {
        EarlyStartHelper.updateParentOpp(newEarlystartMap,oldEarlystartMap);
        EarlyStartHelper.updateESFromExtension(newEarlystartMap,oldEarlystartMap);
        EarlyStartHelper.updateExtensionFromES(newEarlystartMap,oldEarlystartMap,false);
        // EarlyStartHelper.updateESStatusFromExtension(newEarlystartMap,oldEarlystartMap);
        //EarlyStartHelper.checking((newEarlystartMap,oldEarlystartMap)
        
    }
}