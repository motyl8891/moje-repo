/****************************************************************
* @author: Shubham Kadam  
* @date: 14/09/2020
* @User Story: U-1979
* @description: This class will handle S2WRecordSharingTrigger
*****************************************************************/
public without sharing class S2WRecordSharingHandler {
    /****************************************************************
* @author: Shubham Kadam  
* @date: 14/09/2020
* @User Story: U-1989, U-1924
* @description: This method will be called from S2WRecordSharingTrigger on after insert
*****************************************************************/
    public static void onAfterInsert(List<Strategy2Win__c> newS2W, List<Strategy2Win__c> oldS2W, 
                                     Map<ID, Strategy2Win__c> newS2WMap, Map<ID, Strategy2Win__c> oldS2WMap){
            //U-1979
            set<ID> oppSetID=new set<ID>();
            for(Strategy2Win__c s2w : newS2W) {
                oppSetID.add(s2w.Opportunity__c); 
            }
            if(!oppSetID.isEmpty()) {
                S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
            }  
     }
    
    /****************************************************************
* @author: Shubham Kadam  
* @date: 14/09/2020
* @User Story: U-1989, U-1924
* @description: This method will be called from S2WRecordSharingTrigger on after update
*****************************************************************/
    public static void onAfterUpdate(List<Strategy2Win__c> newS2W, List<Strategy2Win__c> oldS2W, 
                                     Map<ID, Strategy2Win__c> newS2WMap, Map<ID, Strategy2Win__c> oldS2WMap){
            //U-1979
            set<ID> oppSetID=new set<ID>();
            for(Strategy2Win__c s2w : newS2W) {
                oppSetID.add(s2w.Opportunity__c); 
            }
            if(!oppSetID.isEmpty()) {
                S2WRecordSharingHelper.S2WRecordSharingWithMembers(oppSetID);
            }           
    }    
}