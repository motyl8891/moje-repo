/****************************************************************
* @author: Manu Singhal
* @date: 14-03-2020
* @User Story: 1581
* @description: This class will be called when dev types will be submitted for approval.

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			16-07-2020				U-1991 - Profile related condition updated with "AccessSettings__c" custom setting

*****************************************************************/    
public without sharing class UpdateDeviationTypeGroupsController {
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story: 1826
* @description: This method will check that the button should be clicked by only memebers of 'MELA Commercial Director'.
*****************************************************************/   
    @AuraEnabled
    public static String groupMemberCheck(String parentId)
    {
        String message = GlobalConstants.BLANK;
        try{ 
            Proposal__c prop = [select id,DeviationsPreApproved__c,Overall_EBD_Approval_Status__c,Primary__c,
                                Opportunity__r.StageName,Opportunity__r.MarketArea__c,
                                Opportunity__r.Owner.FirstName,Opportunity__r.Owner.LastName
                                from Proposal__c where id =: parentId Limit 1];
            if(GlobalConstants.validStages.contains(prop.Opportunity__r.StageName)) {
                message = GlobalConstants.message1; }
            else{            
                if(prop.Overall_EBD_Approval_Status__c != null && (
                    GlobalConstants.Pending.equals(prop.Overall_EBD_Approval_Status__c)|| GlobalConstants.APPROVED.equals(prop.Overall_EBD_Approval_Status__c)
                   || GlobalConstants.Rejected.equals(prop.Overall_EBD_Approval_Status__c))) {
                       message = GlobalConstants.message2;
                   }else if(!prop.Primary__c) {
                       message = GlobalConstants.message3; }
                else{
                    Set<id> grpMemberIdSet = new Set<id>();  
                    set<String> grupNameSet = new Set<String>();
                    String publicGroupName = GlobalConstants.BLANK;
                    String owner = GlobalConstants.BLANK;
                    if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MOAI))
                        {
                            publicGroupName = GlobalConstants.CommercialDirectors;
                        }
                        if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MMEA))
                        {
                            publicGroupName = GlobalConstants.PriceManagersCUCommercialDirector;
                        }
                         if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MANA))
                        {
                            publicGroupName = GlobalConstants.MANAPriceManagers;
                        }
                       if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MNEA))
                        {
                             owner = prop.Opportunity__r.Owner.FirstName + GlobalConstants.SPACE + 
                                 prop.Opportunity__r.Owner.LastName;
                        }
                        if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MELA))
                        {
                            publicGroupName = GlobalConstants.MELADSPriceManagers;
                            grupNameSet.add(GlobalConstants.MELACommercialDirectors);
                        }
                        grupNameSet.add(publicGroupName);
						grupNameSet.add(GlobalConstants.EBD_requesters);
                    for(GroupMember grpMember : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name IN: grupNameSet
                                                 Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                     grpMemberIdSet.add(grpMember.UserOrGroupId); }
                    List<User> user = [SELECT Id, FirstName, LastName FROM User WHERE Id  =: UserInfo.getUserId() Limit 1 ];

                     String userName = user[0].FirstName + GlobalConstants.SPACE + user[0].LastName;
                    //U-1991
                    if((grpMemberIdSet.isEmpty() || 
                        !grpMemberIdSet.contains(UserInfo.getUserId())) &&
                       userName != owner && 
                       !AccessSettings__c.getInstance().CanRequestOrRecallDeviationApprovals__c) {
                           message = GlobalConstants.message4; }
                    else if(grpMemberIdSet.contains(UserInfo.getUserId()) || AccessSettings__c.getInstance().CanRequestOrRecallDeviationApprovals__c || userName == owner){
                        Boolean flag = updateMAandBAStatus(parentId);
                        if(flag) {
                            message = GlobalConstants.message5; }
                        else {
                            message = GlobalConstants.message6; }
                    }
                }
            }
        }
        catch(Exception e) {
            message = GlobalConstants.message6;
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                       GlobalConstants.opptyPofileCheck, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        }
        return message;        
    }            
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story: 1826
* @description: This method will update MA/BA Status.
*****************************************************************/   
    @AuraEnabled
    public static Boolean updateMAandBAStatus(String parentId){        
        Boolean isUpdated = false;
        try 
        {
            List<DeviationTypeGroup__c> devTypeGrpList = new List<DeviationTypeGroup__c>();
            Boolean flag = false;
            for(DeviationTypeGroup__c devTypeGrp : [Select Id,MAStatus__c,BAStatus__c,MA_Approver__c,BA_Approver__c 
                                                    from DeviationTypeGroup__c
                                                    where Proposal__c =: parentId
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])       
            { 
                flag = false;
                if((devTypeGrp.MAStatus__c == GlobalConstants.To_be_Requested  || 
                    GlobalConstants.Cancelled.equals(devTypeGrp.MAStatus__c)) && devTypeGrp.MA_Approver__c != null)
                {
                    devTypeGrp.MAStatus__c = GlobalConstants.Pending;
                    flag = true;
                }
                if((devTypeGrp.BAStatus__c == GlobalConstants.To_be_Requested || 
                    GlobalConstants.Cancelled.equals(devTypeGrp.BAStatus__c)) && devTypeGrp.BA_Approver__c != null)               
                {
                    devTypeGrp.BAStatus__c = GlobalConstants.Pending;
                    flag = true;
                }
                if(flag) {
                    devTypeGrpList.add(devTypeGrp); }
            }
            if(!devTypeGrpList.isEmpty()){
                Proposal__c prop = new Proposal__c(Id= parentId);
                prop.RequestedDeviationsApproval__c = true;
                prop.Requestor__c = UserInfo.getUserId();
                Database.update(prop);
                isUpdated = true;
                Database.update(devTypeGrpList);
            }
        }
        catch(Exception e) {isUpdated = false;  EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                                        GlobalConstants.updateSubmitForApprovalFlag, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
                           }
        return isUpdated;
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story: 1826
* @description: This method will check that the button should be clicked by only memebers of 'MELA Commercial Director'.
*****************************************************************/   
   @AuraEnabled
    public static String groupMemberCheckOnRecall(String parentId)
    {
        String message = GlobalConstants.BLANK;
        try{                 
            Proposal__c prop = [select id,DeviationsPreApproved__c,Overall_EBD_Approval_Status__c,
                                Primary__c,Opportunity__r.StageName,Opportunity__r.MarketArea__c,
                                Opportunity__r.Owner.FirstName,Opportunity__r.Owner.LastName
                                from Proposal__c where id =: parentId Limit 1];
            if(GlobalConstants.validStages.contains(prop.Opportunity__r.StageName)) {
                message = GlobalConstants.message7; }
            /**else{            
                if(prop.Overall_EBD_Approval_Status__c != null && (GlobalConstants.APPROVED.equals(prop.Overall_EBD_Approval_Status__c)
                   || GlobalConstants.Rejected.equals(prop.Overall_EBD_Approval_Status__c))) {
                       message = GlobalConstants.message2;
                   }else if(!prop.Primary__c) { 
                       message = GlobalConstants.message3; }**/
                else{
                    Set<id> grpMemberIdSet = new Set<id>();   
                    set<String> grupNameSet = new Set<String>();
                    //String publicGroupName = GlobalConstants.BLANK;
                    String owner = GlobalConstants.BLANK;
                    if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MOAI))
                        {
                           // publicGroupName = GlobalConstants.CommercialDirectors;
                            grupNameSet.add(GlobalConstants.CommercialDirectors);
                        }
                        if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MMEA))
                        {
                           /* publicGroupName = GlobalConstants.PriceManagersCUCommercialDirector;
                            publicGroupName = GlobalConstants.MMEACMHead;
                            publicGroupName = GlobalConstants.MMEACUCommercialDirectors;*/
                            grupNameSet.add(GlobalConstants.PriceManagersCUCommercialDirector);
                            grupNameSet.add(GlobalConstants.MMEACMHead);
                            grupNameSet.add(GlobalConstants.MMEACUCommercialDirectors);
                            
                        }
                         if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MANA))
                        {
                           // publicGroupName = GlobalConstants.MANAPriceManagers;
                            grupNameSet.add(GlobalConstants.MANAPriceManagers);
                        }
                       if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MNEA))
                        {
                             owner = prop.Opportunity__r.Owner.FirstName + GlobalConstants.SPACE + prop.Opportunity__r.Owner.LastName;
                        }
                        if(prop.Opportunity__r.MarketArea__c.equalsIgnoreCase(GlobalConstants.MELA))
                        {
                           // publicGroupName = GlobalConstants.MELADSPriceManagers;
                            grupNameSet.add(GlobalConstants.MELACommercialDirectors);
                            grupNameSet.add(GlobalConstants.MELADSPriceManagers);
                        }
                       // grupNameSet.add(publicGroupName);
						grupNameSet.add(GlobalConstants.EBD_requesters);
						grupNameSet.add(GlobalConstants.MELA_Sales_Operations);
                    for(GroupMember grpMember : [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name IN: grupNameSet
                                                 Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                     grpMemberIdSet.add(grpMember.UserOrGroupId); }
                    List<User> user = [SELECT Id, FirstName, LastName FROM User WHERE Id  =: UserInfo.getUserId() Limit 1 ];

                     String userName = user[0].FirstName + GlobalConstants.SPACE + user[0].LastName;
                    //U-1991
                    if((grpMemberIdSet.isEmpty() || !grpMemberIdSet.contains(UserInfo.getUserId())) && 
                       userName != owner && 
                       !AccessSettings__c.getInstance().CanRequestOrRecallDeviationApprovals__c) {
                           message = GlobalConstants.message8; }
                    else if(grpMemberIdSet.contains(UserInfo.getUserId()) ||
                            AccessSettings__c.getInstance().CanRequestOrRecallDeviationApprovals__c || userName == owner){
                        Boolean flag = recallPendingApprovals(parentId);
                        if(flag) {
                            message = GlobalConstants.message9; }
                        else {
                            message = GlobalConstants.message10; }
                    }
                }
            //}
        }
        catch(Exception e) {
            message = GlobalConstants.message6;
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                       GlobalConstants.opptyPofileCheck, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        }
        return message;        
    }        
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story: 1826
* @description: This method will recall all the pending approvals.
*****************************************************************/   
    @AuraEnabled
    public static Boolean recallPendingApprovals(String parentId){
        Boolean isUpdated = false;       
        try 
        {
            List<DeviationTypeGroup__c> devTypeGrpList = new List<DeviationTypeGroup__c>();
            Proposal__c p = new Proposal__c();
            p.id = parentId ;
            system.debug('parentid'+p.Id);
            Boolean flag = false;
            for(DeviationTypeGroup__c devTypeGrp : [Select Id,MAStatus__c,BAStatus__c,BAApprovalDate__c,
                                                    ApprovalDate__c,MAApprovalDate__c 
                                                    from DeviationTypeGroup__c
                                                    where Proposal__c =: parentId
                                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])       
            { 
                flag = false;
                if(devTypeGrp.MAStatus__c!=null && 
                   (GlobalConstants.Pending.equals(devTypeGrp.MAStatus__c) ||
                       GlobalConstants.PREAPPROVED.equals(devTypeGrp.MAStatus__c)))
                {
                    devTypeGrp.MAStatus__c = GlobalConstants.Cancelled;
                    devTypeGrp.MAComments__c = null;
                    devTypeGrp.MAApprovalDate__c = null;
                    devTypeGrp.ApprovalDate__c = null;
                    flag = true;
                }
                if(devTypeGrp.BAStatus__c!=null && 
                   (GlobalConstants.Pending.equals(devTypeGrp.BAStatus__c) ||
                   GlobalConstants.PREAPPROVED.equals(devTypeGrp.BAStatus__c)))
                {
                    devTypeGrp.BAStatus__c = GlobalConstants.Cancelled;
                    devTypeGrp.BAComments__c = null;
                    devTypeGrp.BAApprovalDate__c = null;
                    devTypeGrp.ApprovalDate__c = null;
                    flag = true;
                } 
                if(flag) {
                    devTypeGrpList.add(devTypeGrp); }
            }
            if(!devTypeGrpList.isEmpty()){
                isUpdated = true;
                database.update(devTypeGrpList,false); 
            }
            system.debug('parentid1'+p.Id);
                system.debug('prop');
                p.AllBDGSDeviationsarePreApproved__c = false;
                p.DeviationsPreApproved__c = false;
                p.BDGSPreApprovalComments__c = '';
                p.PreApprovalComments__c = '';
                p.Overall_EBD_Approval_Status__c = GlobalConstants.Cancelled;
                database.update(p);
        }
        catch(Exception e) {isUpdated = false; EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                                        GlobalConstants.updateSubmitForApprovalFlag, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
                           }
        return isUpdated;
    }
}