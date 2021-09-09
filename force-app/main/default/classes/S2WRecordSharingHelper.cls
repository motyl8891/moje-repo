/******************************************************************************************
*
* @author       : Shubham Kadam
* @date         : 14-09-2020
* @description  : U-1989, U-1924 - Class to assign Sharing access to Opportunity Owner, Core OST Members, SDR Members
* @testClass    : S2WRecordSharingHelperTest

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------    
Shubham Kadam               14-09-2020          Original Version				

******************************************************************************************/
public without sharing class S2WRecordSharingHelper 
{
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 14-09-2020
* @param: oppId
* @description: U-1924 & U-1979 - This Method will grant access to Opportunity Owner, Core OST Members, SDR Members
*****************************************************************/
    public static void S2WRecordSharingWithMembers(set<ID> oppId)  
    {
        try 
        {
            //Grant access to all users of s2w 	
            Set<Id> editAccessSet=new Set<Id>();
            Set<Id> readAccessSet=new Set<Id>();
            List<Strategy2Win__Share> s2wShrs  = new List<Strategy2Win__Share>();
            
            //add Opportunity owner to EditAccessList
            for(Opportunity opp : [select Id, Name, OwnerId from Opportunity where Id IN : oppId 
                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                       editAccessSet.add(opp.OwnerId);
                                   }   
            
            List<Strategy2Win__c> s2wls = [select id, name from Strategy2Win__c where Opportunity__c IN : oppId 
                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            set<ID> s2wSetID=new set<ID>();
            for(Strategy2Win__c s2wRec : s2wls){
                s2wSetID.add(s2wRec.id);
            }
            
            //Revoke access from all users of s2w 	
            if(!s2wSetID.isEmpty()){
                List<Strategy2Win__Share> sharesToDelete = [SELECT Id FROM Strategy2Win__Share 
                                                            WHERE ParentId IN : s2wSetID and RowCause=:GlobalConstants.Manual 
                                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
                if(!sharesToDelete.isEmpty()){
                    Database.Delete(sharesToDelete, false);
                }
            }
            
            //add Core 3 to EditAccessList
            for(Opportunity_Sales_Team__c ostList : [Select Id, Name, Employee__r.Salesforce_User__c, Opportunity__c, Role__c from Opportunity_Sales_Team__c 
                                                     where Opportunity__c IN : oppId AND Role__c IN (:GlobalConstants.ACR, :GlobalConstants.CSR, :GlobalConstants.CFR) 
                                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                         editAccessSet.add(ostList.Employee__r.Salesforce_User__c);
                                                     }
            
            //add SDMs of SDP2 and SDP3 type to readAccessList
            for(Sales_Decision_Maker__c sdrList : [Select Id, Name, Sales_Decision_Record__r.Opportunity__c, Sales_Decision_Record__r.Name, 
                                                   Sales_Decision_Record__r.Sales_Decision_Type__c, Approver_Name__c 
                                                   from Sales_Decision_Maker__c where Sales_Decision_Record__r.Opportunity__c IN : oppId AND 
                                                   Sales_Decision_Record__r.Sales_Decision_Type__c In (:GlobalConstants.SDP2SubmitProposal, :GlobalConstants.SDP3SignContract)
                                                   Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                       readAccessSet.add(sdrList.Approver_Name__c); 
                                                   }
            //Removing repeted user ids
            for(Id sdrMemberId : editAccessSet) {
                if(readAccessSet.contains(sdrMemberId))
                    readAccessSet.remove(sdrMemberId);
            }
            
            for(Strategy2Win__c s2wList : s2wls)
            {
                for(Id memId : editAccessSet)
                {
                    //Assign access to new Opportunity Owner, core sales team member and OST members as SDM
                    Strategy2Win__Share s2wObj = new Strategy2Win__Share();
                    //ID of record being shared
                    s2wObj.ParentId = s2wList.Id;
                    //ID of user or group being granted access
                    s2wObj.UserOrGroupId = memId;
                    //access level
                    s2wObj.AccessLevel = GlobalConstants.Edit;
                    //Apex sharing reason for hiring manager and recruiter
                    s2wObj.RowCause = GlobalConstants.Manual;
                    //Add objects to list for insert
                    s2wShrs.add(s2wObj);
                }
                for(Id memId : readAccessSet)
                {
                    //Assign access to new SDM Approvers
                    Strategy2Win__Share s2wObj = new Strategy2Win__Share();
                    //ID of record being shared
                    s2wObj.ParentId = s2wList.Id;
                    //ID of user or group being granted access
                    s2wObj.UserOrGroupId = memId;
                    //access level
                    s2wObj.AccessLevel = GlobalConstants.Read;
                    //Apex sharing reason for hiring manager and recruiter
                    s2wObj.RowCause = GlobalConstants.Manual;
                    //Add objects to list for insert
                    s2wShrs.add(s2wObj);
                }
            }
            
            if(!s2wShrs.isEmpty()) {
                Database.insert(s2wShrs,false);
            }	
        }
        catch(Exception e)
        {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.S2WRecordSharingHelper, GlobalConstants.S2WRecordSharingWithMembers,
                                                                       GlobalConstants.S2WRecordSharingHelper, true, e)));
        }
    }	
}