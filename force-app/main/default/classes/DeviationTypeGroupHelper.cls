/****************************************************************
* @author: Manu Singhal  
* @date: 14-03-2020
* @User Story: 1581
* @description: This class will be called from DeviationTypeGroupHandler
*****************************************************************/
public  without Sharing class DeviationTypeGroupHelper{
    /****************************************************************
* @author: Anukriti Agrawal
* @date: 14-03-2020
* @User Story: 1581, U-1826	
* @description: This method will update Proposal's overall EBD Status.
*****************************************************************/    
    public static void updateProposalEBDStatus(List<DeviationTypeGroup__c> newDeviationsList, Map<ID, DeviationTypeGroup__c> oldDeviationsMap ) 
    { try{
        DeviationTypeGroup__c devType = newDeviationsList[0];
        if(devType.DeviationApprovalStatus__c != oldDeviationsMap.get(devType.Id).DeviationApprovalStatus__c) {
            Proposal__c prop=new Proposal__c(Id=devType.Proposal__c);
            if(GlobalConstants.Rejected.equals(devType.DeviationApprovalStatus__c)) {
                prop.Overall_EBD_Approval_Status__c = GlobalConstants.Rejected; 
                prop.RequestedDeviationApprovalDate__c	= null;
            }else if(GlobalConstants.TOBEREQUESTED.equals(devType.DeviationApprovalStatus__c)) {
                prop.Overall_EBD_Approval_Status__c = GlobalConstants.TOBEREQUESTED;
                prop.RequestedDeviationApprovalDate__c	= null;
               // prop.RequestedDate__c = system.today();
               
            }
            else if(GlobalConstants.Pending.equals(devType.DeviationApprovalStatus__c)) {
                prop.Overall_EBD_Approval_Status__c = GlobalConstants.Pending;
                prop.RequestedDate__c = system.today();
                prop.RequestedDeviationApprovalDate__c	= system.today();
            }
            else if(GlobalConstants.Cancelled.equals(devType.DeviationApprovalStatus__c)){
                prop.Overall_EBD_Approval_Status__c = GlobalConstants.Cancelled; 
                prop.RequestedDeviationApprovalDate__c = null;
                prop.RequestedDeviationsApproval__c=false;}            
            else if(GlobalConstants.APPROVED.equals(devType.DeviationApprovalStatus__c) || 
                    GlobalConstants.PREAPPROVED.equals(devType.DeviationApprovalStatus__c)) {
                List<DeviationTypeGroup__c> devTypeList = [SELECT ID,DeviationApprovalStatus__c FROM DeviationTypeGroup__c WHERE Proposal__c =: devType.Proposal__c 
                                                           AND (DeviationApprovalStatus__c=:GlobalConstants.Rejected OR DeviationApprovalStatus__c=:GlobalConstants.Pending OR DeviationApprovalStatus__c=:GlobalConstants.To_be_Requested) LIMIT 1];
                List<DeviationTypeGroup__c> devTypeList1 = [SELECT ID,DeviationApprovalStatus__c FROM DeviationTypeGroup__c WHERE Proposal__c =: devType.Proposal__c 
                                                            AND (DeviationApprovalStatus__c=:GlobalConstants.APPROVEDWITHCONDITIONS) LIMIT 1];
                
                if(devTypeList.isEmpty() && devTypeList1.isEmpty()) {
                    prop.Overall_EBD_Approval_Status__c = GlobalConstants.APPROVED; 
                    prop.ApprovedDate__c = system.today();
                }
                else if(devTypeList.isEmpty() && !devTypeList1.isEmpty()) {
                    prop.Overall_EBD_Approval_Status__c = GlobalConstants.APPROVEDWITHCONDITIONS; 
                    prop.ApprovedDate__c = system.today();
                }
            }
            else if(GlobalConstants.APPROVEDWITHCONDITIONS.equals(devType.DeviationApprovalStatus__c)) {
                List<DeviationTypeGroup__c> devTypeList = [SELECT ID,DeviationApprovalStatus__c 
                                                           FROM DeviationTypeGroup__c 
                                                           WHERE Proposal__c =: devType.Proposal__c 
                                                           AND (DeviationApprovalStatus__c=:GlobalConstants.Rejected OR 
                                                                DeviationApprovalStatus__c=:GlobalConstants.Pending OR
                                                                DeviationApprovalStatus__c=:GlobalConstants.To_be_Requested) LIMIT 1];
                if(devTypeList.isEmpty()) {
                    prop.Overall_EBD_Approval_Status__c = GlobalConstants.APPROVEDWITHCONDITIONS; 
                    prop.ApprovedDate__c = system.today();
                }
            }   
            Database.update(prop);
            updateOverallEBDStatusonSDR(devType.Proposal__c, prop.Overall_EBD_Approval_Status__c);
        }
    }catch(Exception e){
        EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                   GlobalConstants.updateProposalEBDStatus, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        
    }
    }
    /****************************************************************
* @author: Anukriti Agrawal
* @date: 14-03-2020
* @User Story: 1581, U-1826
* @description: This method will update SDR's overall EBD Status.
*****************************************************************/          
    @future
    public static void updateOverallEBDStatusonSDR(Id prop, String EBDStatus) 
    { try{
        List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
        for(Sales_Decision_Record__c sdr : [SELECT ID, Overall_EBD_Approval_Status__c 
                                            FROM Sales_Decision_Record__c 
                                            WHERE Primary_Proposal__c=: prop 
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
            sdr.Overall_EBD_Approval_Status__c = EBDStatus;
            sdrList.add(sdr);
        }
        database.update(sdrList);
    }catch(Exception e){
        EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                   GlobalConstants.updateOverallEBDStatusonSDR, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        
    }
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story:  U-1826
* @description: This method will update MA/BA related fields on updation of MA/BA Status
*****************************************************************/  
    public static void updateDeviationFields(List<DeviationTypeGroup__c> newDeviationsList, List<DeviationTypeGroup__c> oldDeviationsList, 
                                             Map<ID, DeviationTypeGroup__c> newDeviationsMap , Map<ID, DeviationTypeGroup__c> oldDeviationsMap ) 
    { try{
        List<DeviationTypeGroup__c> devTypeListToUpdate = new List<DeviationTypeGroup__c>();
        for(DeviationTypeGroup__c devType : newDeviationsList)
        {  
            if(devType.MAStatus__c != oldDeviationsMap.get(devType.Id).MAStatus__c && 
               devType.MAStatus__c == GlobalConstants.PREAPPROVED) {
                devType.MAApprovalDate__c = System.today();
                if(devType.BA_Approver__c == null){
                    devType.ApprovalDate__c = System.today();
                }
                if(devType.MAComments__c != GlobalConstants.AUTOPREAPPROVED){
                    devType.MA_Approved_By__c = UserInfo.getUserId();
                }                
                if(devType.BA_Approver__c != null && devType.BAStatus__c == GlobalConstants.Pending){
                    devType.BAStatus__c = GlobalConstants.PREAPPROVED;
                }                	
                devTypeListToUpdate.add(devType);
            }
            if(devType.BAStatus__c != oldDeviationsMap.get(devType.Id).BAStatus__c &&
               devType.BAStatus__c == GlobalConstants.PREAPPROVED) {
                devType.BAApprovalDate__c = System.today(); 
                devType.ApprovalDate__c = System.today();
                devTypeListToUpdate.add(devType);
            }
            //U-2174-Updating Approver Status 2 when Approver1 Status is updated from PreApproved to Pending
            if(devType.MAStatus__c != oldDeviationsMap.get(devType.Id).MAStatus__c &&
               oldDeviationsMap.get(devType.Id).MAStatus__c == GlobalConstants.PREAPPROVED &&
              devType.MAStatus__c == GlobalConstants.Pending) {
               devType.BAStatus__c = GlobalConstants.Pending;
               devType.BAApprovalDate__c = null;
               devType.MAApprovalDate__c = null;
               devType.ApprovalDate__c = null;
               devType.MAComments__c = '';
               devType.BAComments__c = '';   
               devTypeListToUpdate.add(devType);
               }
            if(devType.MAStatus__c != oldDeviationsMap.get(devType.Id).MAStatus__c && 
               devType.MAStatus__c != GlobalConstants.Pending &&  
               devType.MAStatus__c != GlobalConstants.Cancelled && 
               devType.MAStatus__c != GlobalConstants.PREAPPROVED) {
                devType.MA_Approved_By__c = UserInfo.getUserId();
                devType.MAApprovalDate__c = System.today();
                if(devType.BA_Approver__c == null)
                {
                    devType.ApprovalDate__c = System.today();
                }
                devTypeListToUpdate.add(devType);
            }
            if(devType.BAStatus__c != oldDeviationsMap.get(devType.Id).BAStatus__c && 
               devType.BAStatus__c != GlobalConstants.Pending &&  
               devType.BAStatus__c != GlobalConstants.Cancelled && 
               devType.BAStatus__c != GlobalConstants.PREAPPROVED) {
                devType.BA_Approved_By__c = UserInfo.getUserId();
                devType.BAApprovalDate__c = System.today(); 
                devType.ApprovalDate__c = System.today();
                devTypeListToUpdate.add(devType);
            }
            if(devTypeListToUpdate.isEmpty()) {
                database.update(devTypeListToUpdate); }
        }
        
    }catch(Exception e){
        EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                   GlobalConstants.updateDeviationFields, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        
    }}
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story:  U-1826
* @description: This method will restict editing of Supporting Material field
*****************************************************************/ 
    public static void restrictEditOfSupportingMaterial(List<DeviationTypeGroup__c> newDeviationsList, List<DeviationTypeGroup__c> oldDeviationsList, 
                                                        Map<ID, DeviationTypeGroup__c> newDeviationsMap , Map<ID, DeviationTypeGroup__c> oldDeviationsMap) 
    {try{
        set<String> grupNameSet = new Set<String>();
        Set<id> devTypeIdSet = new Set<id>();       
        String owner = GlobalConstants.BLANK;
        for(DeviationTypeGroup__c devType : newDeviationsList)
        {
            if(devType.SupportingMaterial__c != oldDeviationsMap.get(devType.Id).SupportingMaterial__c) {
                devTypeIdSet.add(devType.id); 
            }
        }
        For(DeviationTypeGroup__c devType : [select Id, MarketArea__c,Proposal__r.Opportunity__r.Owner.FirstName,
                                             Proposal__r.Opportunity__r.Owner.LastName 
                                             from DeviationTypeGroup__c
                                             where id IN : devTypeIdSet
                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) 
        {                       
            if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MOAI))
            {
                grupNameSet.add(GlobalConstants.CommercialDirectors);
                grupNameSet.add(GlobalConstants.MOAI_EBD_Commercial);
                grupNameSet.add(GlobalConstants.MOAI_EBD_Contractual_TnC);
            }
            if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MMEA))
            {
                grupNameSet.add(GlobalConstants.PriceManagersCUCommercialDirector);
                grupNameSet.add(GlobalConstants.MMEACUCommercialDirectors);
                grupNameSet.add(GlobalConstants.MMEACMHead);
            }
            if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MANA))
            {
                grupNameSet.add(GlobalConstants.MANAPriceManagers);
                grupNameSet.add(GlobalConstants.MANACommercialManagement);
            }
            if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MNEA))
            {
                grupNameSet.add(GlobalConstants.MNEACMHead);
                owner = devType.Proposal__r.Opportunity__r.Owner.FirstName + 
                    GlobalConstants.SPACE + devType.Proposal__r.Opportunity__r.Owner.LastName;                           
            }
            if(devType.MarketArea__c.equalsIgnoreCase(GlobalConstants.MELA))
            {
                grupNameSet.add(GlobalConstants.MELADSPriceManagers);
                grupNameSet.add(GlobalConstants.MELACommercialDirectors);
                grupNameSet.add(GlobalConstants.MELADSCUCDCUHoDS);
                grupNameSet.add(GlobalConstants.MELADSCMHeadHeadofPriceMgmt);
                grupNameSet.add(GlobalConstants.MELA_Head_of_DS_MELA_DS_CM_Head);
                grupNameSet.add(GlobalConstants.MELA_NMS_CM_Head);
                grupNameSet.add(GlobalConstants.MELANMSTacticalManagers);
            }
            grupNameSet.add(GlobalConstants.BNEW_SPOCs);
            grupNameSet.add(GlobalConstants.BDGS_SPOCs);
            grupNameSet.add(GlobalConstants.BMAS_SPOCs);
            grupNameSet.add(GlobalConstants.BMAS_SA_Head);
        }                   
        
        if(!devTypeIdSet.isEmpty())
        {
            
            for(GroupMember grpMember : [SELECT UserOrGroupId 
                                         FROM GroupMember 
                                         WHERE Group.Name IN: grupNameSet 
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                grupNameSet.add(grpMember.UserOrGroupId); }
            List<User> user = [SELECT Id, FirstName, LastName FROM User WHERE Id  =: UserInfo.getUserId() Limit 1 ];
            String userName = user[0].FirstName + GlobalConstants.SPACE + user[0].LastName;
            for(Id devId : devTypeIdSet)
            {
                if((grupNameSet.isEmpty() || !grupNameSet.contains(UserInfo.getUserId())) && userName != owner) {
                    newDeviationsMap.get(devId).addError(GlobalConstants.error1); }
            }            
        }
    }catch(Exception e){
        EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                   GlobalConstants.restrictEditOfSupportingMaterial, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        
    }
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story:  U-1826
* @description: This method will restrict editing of MA related fields  
*****************************************************************/ 
    public static void restrictEditOfMAFields(List<DeviationTypeGroup__c> newDeviationsList, List<DeviationTypeGroup__c> oldDeviationsList, 
                                              Map<ID, DeviationTypeGroup__c> newDeviationsMap , Map<ID, DeviationTypeGroup__c> oldDeviationsMap ) 
    { try{
        Map<id,Set<id>> grpIdWithMemberMap = new Map<id,Set<id>>();
        Map<id,String> devIdWithMAApproverMap = new Map<id,String>();
        Map<String,id> grpNameIdMap = new Map<String,id>();
        for(DeviationTypeGroup__c devType : newDeviationsList)
        {
            if(!devType.Pre_Approved__c) {
                if((devType.MAStatus__c != oldDeviationsMap.get(devType.Id).MAStatus__c && 
                    (GlobalConstants.APPROVED.equals(devType.MAStatus__c)||
                     GlobalConstants.Rejected.equals(devType.MAStatus__c)|| 
                     GlobalConstants.APPROVEDWITHCONDITIONS.equals(devType.MAStatus__c)))
                   || devType.MAConditions__c != oldDeviationsMap.get(devType.Id).MAConditions__c 
                   || devType.MAComments__c != oldDeviationsMap.get(devType.Id).MAComments__c ) {
                       devIdWithMAApproverMap.put(devType.id,devType.MA_Approver__c); }
            }
        }      
        if(!devIdWithMAApproverMap.isEmpty())
        {
            for(Group grp :[SELECT id,Name FROM Group where Name in : devIdWithMAApproverMap.values()
                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                grpNameIdMap.put(grp.Name, grp.id); }     
            if( !grpNameIdMap.isEmpty())
            {
                for(GroupMember grpMember : [SELECT GroupId,UserOrGroupId FROM GroupMember 
                                             WHERE GroupId =: grpNameIdMap.values() 
                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    
                    if(!grpIdWithMemberMap.containsKey(grpMember.GroupId)) 
                    {
                        grpIdWithMemberMap.put(grpMember.GroupId, new Set<id>());
                    }
                    grpIdWithMemberMap.get(grpMember.GroupId).add(grpMember.UserOrGroupId);
                }
                for(Id devId : devIdWithMAApproverMap.keySet())
                {                
                    if(grpIdWithMemberMap.isEmpty() || 
                       !grpIdWithMemberMap.get(grpNameIdMap.get(devIdWithMAApproverMap.get(devId))).contains(UserInfo.getUserId())) {
                        newDeviationsMap.get(devId).addError(GlobalConstants.error2); }
                }            
            }
        }}catch(Exception e){
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                       GlobalConstants.restrictEditOfMAFields, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
            
        }
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 10-06-2020
* @User Story:  U-1826
* @description: This method will restrict editing of BA related fields  
*****************************************************************/
    public static void restrictEditOfBAFields(List<DeviationTypeGroup__c> newDeviationsList, List<DeviationTypeGroup__c> oldDeviationsList, 
                                              Map<ID, DeviationTypeGroup__c> newDeviationsMap , Map<ID, DeviationTypeGroup__c> oldDeviationsMap ) 
    { try{
        Map<id,Set<id>> grpIdWithMemberMap = new Map<id,Set<id>>();
        Map<id,String> devIdWithMAApproverMap = new Map<id,String>();
        Map<String,id> grpNameIdMap = new Map<String,id>();
        for(DeviationTypeGroup__c devType : newDeviationsList)
        {
            if(!devType.Pre_Approved__c) {
                if(((devType.BAStatus__c != oldDeviationsMap.get(devType.Id).BAStatus__c) &&
                    (GlobalConstants.APPROVED.equals(devType.BAStatus__c) || 
                     GlobalConstants.Rejected.equals(devType.BAStatus__c) || 
                     GlobalConstants.APPROVEDWITHCONDITIONS.equals(devType.BAStatus__c)))             
                   || devType.BAConditions__c != oldDeviationsMap.get(devType.Id).BAConditions__c 
                   || devType.BAComments__c != oldDeviationsMap.get(devType.Id).BAComments__c ) {
                       devIdWithMAApproverMap.put(devType.id,devType.BA_Approver__c); }
            }
        }      
        if(!devIdWithMAApproverMap.isEmpty())
        {
            for(Group grp :[SELECT id,Name FROM Group 
                            where Name in : devIdWithMAApproverMap.values() 
                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                grpNameIdMap.put(grp.Name, grp.id); }      
            if( !grpNameIdMap.isEmpty())
            {
                for(GroupMember grpMember : [SELECT GroupId,UserOrGroupId FROM GroupMember 
                                             WHERE GroupId =: grpNameIdMap.values()
                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
                {
                    if(!grpIdWithMemberMap.containsKey(grpMember.GroupId)) 
                    {
                        grpIdWithMemberMap.put(grpMember.GroupId, new Set<id>());
                    }
                    grpIdWithMemberMap.get(grpMember.GroupId).add(grpMember.UserOrGroupId);
                }
                for(Id devId : devIdWithMAApproverMap.keySet())
                {                
                    if(grpIdWithMemberMap.isEmpty() || 
                       !grpIdWithMemberMap.get(grpNameIdMap.get(devIdWithMAApproverMap.get(devId))).contains(UserInfo.getUserId())) {
                        newDeviationsMap.get(devId).addError(GlobalConstants.error3); }
                }            
            }
        }
    }catch(Exception e){
        EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                   GlobalConstants.restrictEditOfBAFields, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        
    }}
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 19-08-2020
* @param: newDeviationsList, oldDeviationsMap
* @description: U-1928 - Post to Chatter on Deviation Record Page when Approver 1 = Approved or Approved with Condition and 
Approver 2 = Pending
*****************************************************************/
    public static void postToChatter(List<DeviationTypeGroup__c> newDeviationsList,
                                     Map<ID, DeviationTypeGroup__c> oldDeviationsMap) {
        try {         
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();                  
            for(DeviationTypeGroup__c devType : newDeviationsList) {
                if((devType.MAStatus__c != oldDeviationsMap.get(devType.Id).MAStatus__c && 
                    (devType.MAStatus__c == GlobalConstants.APPROVED ||
                     devType.MAStatus__c == GlobalConstants.APPROVEDWITHCONDITIONS)) 
                   && devType.BAStatus__c == GlobalConstants.Pending) {
                       
                       set<String> grupNameSet = new Set<String>();
            			set<id> chatterGrupIdSet = new Set<Id>();

                       Proposal__c prop = [select Id, Name, Overall_EBD_Approval_Status__c, Version__c, 
                                           Opportunity__c, Proposal_Id__c, Requestor__c 
                                           from Proposal__c 
                                           where Id =: devType.Proposal__c LIMIT 1];
                       
                       Opportunity opp = [select Id, Name, AccountId, Customer_Tier__c, Customer_Unit__c, OpportunityNumber__c
                                          from Opportunity where Id =: prop.Opportunity__c LIMIT 1];
                       
                       if(devType.BA_Approver__c != null && devType.MarketArea__c != null) {
                           String chatterGroupName = GlobalConstants.BLANK;
                           if(devType.BA_Approver__c == GlobalConstants.MELA_DS_CM_Head_n_Head_of_Price_Mgmt)
                           {
                               chatterGroupName = GlobalConstants.EBD + GlobalConstants.SPACE + devType.BA_Approver__c;
                           }
                           else if(devType.BA_Approver__c == GlobalConstants.MELA_Head_of_DS_n_MELA_DS_CM_Head)
                           {
                               chatterGroupName = GlobalConstants.MELA_Head_of_DS_n_MELA_DS_CM_Head;
                           }
                           else if(devType.BA_Approver__c == GlobalConstants.BNEW_SPOCs || 
                                   devType.BA_Approver__c == GlobalConstants.BDGS_SPOCs ||
                                   devType.BA_Approver__c == GlobalConstants.BMAS_SA_Head || 
                                   devType.BA_Approver__c == GlobalConstants.BMAS_SPOCs)
                           {
                               chatterGroupName = devType.BA_Approver__c + GlobalConstants.SPACE +
                                   GlobalConstants.DASH + GlobalConstants.SPACE + devType.MarketArea__c;						
                           }
                           grupNameSet.add(chatterGroupName);
                       }
                       
                       for(CollaborationGroup chatterGroup1 : [select Id, Name from CollaborationGroup where Name IN :grupNameSet
                                                               Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
                                                                   chatterGrupIdSet.add(chatterGroup1.Id);
                                                               }
                       
                       if(!chatterGrupIdSet.isEmpty())
                       {
                           Account acc = [select Id, Name from Account where Id =: opp.AccountId LIMIT 1];
                           User ur = [Select Id, Name from User where id =: prop.Requestor__c LIMIT 1];
                           
                           ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
                           ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
                           ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
                           
                           messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
                           
                           for(Id idSet : chatterGrupIdSet){
                               mentionSegmentInput.id = Idset;
                               messageBodyInput.messageSegments.add(mentionSegmentInput);
                           }
                           if(newDeviationsList[0].Questions__c != NULL && (newDeviationsList[0].BADeviationType__c == GlobalConstants.BMAS_EBD_TnC || newDeviationsList[0].BADeviationType__c == GlobalConstants.EBD_TnC ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BNEW_Non_Delegated || newDeviationsList[0].BADeviationType__c == GlobalConstants.BDGS_Non_Delegated ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BMAS_Non_Delegated || newDeviationsList[0].BADeviationType__c == GlobalConstants.BNEW_New_and_Complex_Technologies ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BDGS_New_and_Complex_Technologies || newDeviationsList[0].BADeviationType__c == GlobalConstants.BNEW_Non_Delegated_Commercial_Aspects ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BDGS_Non_Delegated_Commercial_Aspects || newDeviationsList[0].BADeviationType__c == GlobalConstants.BMAS_Non_Delegated_Commercial_Aspects)) {
                               textSegmentInput.text = '\n\n Hi,\n\n There are pending deviations that require your attention. \n ' +
									'\n Deviation Type : ' + newDeviationsList[0].BADeviationType__c +
                                   '\n Account : ' + acc.Name + '\n Customer Tier : ' + opp.Customer_Tier__c + '\n CU : ' + opp.Customer_Unit__c +
                                   '\n Opportunity Name : ' + opp.Name + '\n Opportunity Number : ' +opp.OpportunityNumber__c+ '\n Proposal : ' + prop.Name +
                                   '\n Proposal Id : ' + prop.Proposal_Id__c + '\n Proposal Version : ' + prop.Version__c + '\n Requester : ' + ur.Name +
								   '\n Questions : ' + newDeviationsList[0].Questions__c + 
                                   '\n\n Review your deviations in the Proposal - \n' + GlobalConstants.ORGANIZATION_URL + prop.Id + '\n Deviation List - \n'
                                   + GlobalConstants.ORGANIZATION_URL + 'lightning/o/DeviationTypeGroup__c/list' + '\n\n Regards,\n Salesforce';
                           }
                          else if(newDeviationsList[0].Questions__c == NULL && (newDeviationsList[0].BADeviationType__c == GlobalConstants.BMAS_EBD_TnC || newDeviationsList[0].BADeviationType__c == GlobalConstants.EBD_TnC ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BNEW_Non_Delegated || newDeviationsList[0].BADeviationType__c == GlobalConstants.BDGS_Non_Delegated ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BMAS_Non_Delegated || newDeviationsList[0].BADeviationType__c == GlobalConstants.BNEW_New_and_Complex_Technologies ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BDGS_New_and_Complex_Technologies || newDeviationsList[0].BADeviationType__c == GlobalConstants.BNEW_Non_Delegated_Commercial_Aspects ||
                             newDeviationsList[0].BADeviationType__c == GlobalConstants.BDGS_Non_Delegated_Commercial_Aspects || newDeviationsList[0].BADeviationType__c == GlobalConstants.BMAS_Non_Delegated_Commercial_Aspects)) {
                               textSegmentInput.text = '\n\n Hi,\n\n There are pending deviations that require your attention. \n ' +
									'\n Deviation Type : ' + newDeviationsList[0].BADeviationType__c +
                                   '\n Account : ' + acc.Name + '\n Customer Tier : ' + opp.Customer_Tier__c + '\n CU : ' + opp.Customer_Unit__c +
                                   '\n Opportunity Name : ' + opp.Name + '\n Opportunity Number : ' +opp.OpportunityNumber__c+ '\n Proposal : ' + prop.Name +
                                   '\n Proposal Id : ' + prop.Proposal_Id__c + '\n Proposal Version : ' + prop.Version__c + '\n Requester : ' + ur.Name +
								   '\n Questions : ' + GlobalConstants.BLANK + 
                                   '\n\n Review your deviations in the Proposal - \n' + GlobalConstants.ORGANIZATION_URL + prop.Id + '\n Deviation List - \n'
                                   + GlobalConstants.ORGANIZATION_URL + 'lightning/o/DeviationTypeGroup__c/list' + '\n\n Regards,\n Salesforce';
                           }
                           
                           else if(newDeviationsList[0].ProductGroup__c != NULL){ 
                               textSegmentInput.text = '\n\n Hi,\n\n There are pending deviations that require your attention. \n ' +
							    '\n Deviation Type : ' + newDeviationsList[0].BADeviationType__c +
                                   '\n Account : ' + acc.Name + '\n Customer Tier : ' + opp.Customer_Tier__c + '\n CU : ' + opp.Customer_Unit__c +
                                   '\n Opportunity Name : ' + opp.Name + '\n Opportunity Number : ' +opp.OpportunityNumber__c+ '\n Proposal : ' + prop.Name +
                                   '\n Proposal Id : ' + prop.Proposal_Id__c + '\n Proposal Version : ' + prop.Version__c + '\n Requester : ' + ur.Name +
                                   '\n Product Groups of Deviation : '+ newDeviationsList[0].ProductGroup__c + '\n\n Review your deviations in the Proposal - \n'
                                   + GlobalConstants.ORGANIZATION_URL + prop.Id + '\n Deviation List - \n'
                                   + GlobalConstants.ORGANIZATION_URL + 'lightning/o/DeviationTypeGroup__c/list' + '\n\n Regards,\n Salesforce';
                           }else if(newDeviationsList[0].ProductGroup__c == NULL){
                                textSegmentInput.text = '\n\n Hi,\n\n There are pending deviations that require your attention. \n ' +
							    '\n Deviation Type : ' + newDeviationsList[0].BADeviationType__c +
                                   '\n Account : ' + acc.Name + '\n Customer Tier : ' + opp.Customer_Tier__c + '\n CU : ' + opp.Customer_Unit__c +
                                   '\n Opportunity Name : ' + opp.Name + '\n Opportunity Number : ' +opp.OpportunityNumber__c+ '\n Proposal : ' + prop.Name +
                                   '\n Proposal Id : ' + prop.Proposal_Id__c + '\n Proposal Version : ' + prop.Version__c + '\n Requester : ' + ur.Name +
                                   '\n Product Groups of Deviation : '+ GlobalConstants.BLANK+ '\n\n Review your deviations in the Proposal - \n'
                                   + GlobalConstants.ORGANIZATION_URL + prop.Id + '\n Deviation List - \n'
                                   + GlobalConstants.ORGANIZATION_URL + 'lightning/o/DeviationTypeGroup__c/list' + '\n\n Regards,\n Salesforce';
                           }else {
                               
                           }
                           
                           messageBodyInput.messageSegments.add(textSegmentInput);
                           
                           feedItemInput.body = messageBodyInput ;
                           feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
                           
                           feedItemInput.subjectId = devType.Id;
                           
                           ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
                       }
                   }
            }
            
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                  GlobalConstants.postToChatter, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)); }
    }
	  /****************************************************************
* @author: Biswajit Sahoo
* @date: 25-08-2020
* @param: newDeviationsList
* @description: U-1982 - Over All EBD Status on Proposal get updated only if there are approvers requied on Deviations
*****************************************************************/
    
    public static void updateProposalEBDStatus1(List<DeviationTypeGroup__c> newDeviationsList )
    {
        try{
			List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
			Integer countDeviationApporvalStatus = 0;
            Set<Id> propIdSet = new Set<Id>();
            List<Proposal__c> propList = new List<Proposal__c>();
            system.debug('ENter After INsert');
            for(DeviationTypeGroup__c devType : newDeviationsList)
            {
               if(devType.DeviationApprovalStatus__c != NULL)
               {
                   propIdSet.add(devType.Proposal__c);
                   countDeviationApporvalStatus = countDeviationApporvalStatus+1;
               }else if(devType.DeviationApprovalStatus__c == NULL)
			   propIdSet.add(devType.Proposal__c);
			   }
             for(Proposal__c prop : [SELECT Id From Proposal__c 
                                                      WHERE Id IN: propIdSet
													  Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                if(countDeviationApporvalStatus >= 1){
                 	prop.Overall_EBD_Approval_Status__c = GlobalConstants.TOBEREQUESTED;}
                 else
                {
                    prop.Overall_EBD_Approval_Status__c = GlobalConstants.BLANK;}
                propList.add(prop);
            }
            
			for(Sales_Decision_Record__c sdr : [SELECT ID, Overall_EBD_Approval_Status__c 
                                            FROM Sales_Decision_Record__c 
                                            WHERE Primary_Proposal__c=: propIdSet 
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                 if(countDeviationApporvalStatus >= 1)
                 {
                     sdr.Overall_EBD_Approval_Status__c = GlobalConstants.TOBEREQUESTED;}
                 
            else
                {
                    sdr.Overall_EBD_Approval_Status__c = GlobalConstants.BLANK;}
                sdrList.add(sdr);
            }
            if(!propList.isEmpty())
            {
                Database.update(propList);
            }
			if(!sdrList.isEmpty())
            {
                Database.update(sdrList);
            } 
        }catch(Exception e)
        {
           EventLog.createLog(new EventLog.Error(GlobalConstants.DeviationTypeGroupHelper, 
                                                  GlobalConstants.updateProposalEBDStatus1, GlobalConstants.DeviationTypeGroupHelper, true, e)); }
     
    }
	 /****************************************************************
* @author: Biswajit Sahoo
* @date: 19-01-2021
* @param: U-2291
* @description: This method will update concatinated List of Product group 
				and Questions on Proposal
***********************************************************************/
    public static void updateQuesProdGroupsOnProposal(List<DeviationTypeGroup__c> newDeviationsList)
    {
		try{
             List<Proposal__c> updatePropList = new List<Proposal__c>();
             Set<Id> devUpdatedSet = new Set<Id>(); 
             for( DeviationTypeGroup__c devType : newDeviationsList)
            {
                if(devType.ProductGroup__c != NULL || devType.Questions__c != NULL)
                {
                    devUpdatedSet.add(devType.Proposal__c);
                }
            }
    		String listofDeviatingPGBDGS = GlobalConstants.BLANK;
            String listofDeviatingPGBNEW = GlobalConstants.BLANK;
            String listofDeviatingPGBMAS = GlobalConstants.BLANK;
    		String listOfDeviatingQuestions = GlobalConstants.BLANK;
              If(devUpdatedSet != NULL){
                  for(Proposal__c prop : [SELECT Id,ListofDeviationProductGroups__c,ListofDeviatingQuestions__c,
                                             (SELECT Id,ProductGroup__c,BusinessArea__c, ApprovingUnit__c,BADeviationType__c,Questions__c FROM DeviationToProposal__r)
                                          FROM  Proposal__c
                                         WHERE Id IN:devUpdatedSet
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                                                  ])
                  {
                      for(DeviationTypeGroup__c devType : prop.DeviationToProposal__r){
                       If(devType.ProductGroup__c != NULL ){
                          if(devTYpe.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BDGS))
                          listofDeviatingPGBDGS += devType.BADeviationType__c + GlobalConstants.COLON +  GlobalConstants.leftSqaureBracket+ devType.ProductGroup__c  + GlobalConstants.rightSqaureBracket + GlobalConstants.newLine1;
                     		if(devTYpe.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BNEW))
                                listofDeviatingPGBNEW += devType.BADeviationType__c + GlobalConstants.COLON + GlobalConstants.leftSqaureBracket+ devType.ProductGroup__c  + GlobalConstants.rightSqaureBracket+ GlobalConstants.newLine1;
                     		if(devTYpe.BusinessArea__c.equalsIgnoreCase(GlobalConstants.BMAS))
                                listofDeviatingPGBMAS += devType.BADeviationType__c + GlobalConstants.COLON +  GlobalConstants.leftSqaureBracket+ devType.ProductGroup__c  +GlobalConstants.rightSqaureBracket+ GlobalConstants.newLine1;
                     		
                       }else{
                          listofDeviatingPGBDGS =listofDeviatingPGBDGS;
                             listofDeviatingPGBMAS =listofDeviatingPGBMAS;
                             listofDeviatingPGBNEW =listofDeviatingPGBNEW;
                      }
                          if(devType.Questions__c != NULL && !devType.ApprovingUnit__c.equalsIgnoreCase(GlobalConstants.Ref_Sales_Directive)){
                           listOfDeviatingQuestions +=  devType.BADeviationType__c +  GlobalConstants.COLON +  '['+devType.Questions__c +']' + GlobalConstants.newLine1;
                          }else{
                              listOfDeviatingQuestions = listOfDeviatingQuestions;
                          }
                      }
                      prop.ListofDeviationProductGroups__c = listofDeviatingPGBDGS + listofDeviatingPGBNEW + listofDeviatingPGBMAS ;
                      prop.ListofDeviatingQuestions__c = listOfDeviatingQuestions;
                      updatePropList.add(prop);
                  }
             
                  if(!updatePropList.isEmpty()){
                      Database.update(updatePropList);
                  }
             
              }   
         }catch(Exception ex) {
             EventLog.createLog(new EventLog.Error(GlobalConstants.DeviationTypeGroupHelper, 
                                                  GlobalConstants.updateQuesProdGroupsOnProposal, GlobalConstants.DeviationTypeGroupHelper, true, ex)); }
     
         
}
}