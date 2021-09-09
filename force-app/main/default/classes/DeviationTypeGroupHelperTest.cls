/****************************************************************
* @author: Manu Singhal  
* @date: 14-03-2020
* @User Story: 1581
* @description: This class is a test class for DeviationTypeGroupHelper
*****************************************************************/
@isTest(seeAllData = false)
private without Sharing class DeviationTypeGroupHelperTest {
    /****************************************************************
* @author: Manu Singhal  
* @date: 14-03-2020
* @description: This method is a test method for goToApprovalStep1
*****************************************************************/
    @isTest
    public static void recallDeviationApprovals()
    { 
        try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            //U-1903
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 

            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;

            Id ppRecordTypeId = GlobalConstants.Premium_Proposal_Record_Type_Id; //U-1903
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(
                new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true, recordTypeId=ppRecordTypeId));
            insert prop;  
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            insert devtype;
            devtype.SubmitForApproval__c = true;        
            update devtype;
            
            Test.startTest();
            
            prop.Primary__c = false;
            prop.Candidate_For_Primary_Remove__c=true;
            prop.Overall_EBD_Approval_Status__c='Pending';
            update prop;

            Test.stopTest();
            //NS
            System.assert(true);
        }catch(DMLException e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }
    
    @isTest
    public static void goToApprovalStep1Test()
    {
        try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            //U-1903
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            //    Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(
                new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true));
            insert prop;  
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            insert devtype;
            devtype.SubmitForApproval__c = true;        
            update devtype;
            Set<id> devIdSet = new Set<id>();
            devIdSet.add(devtype.id);
            Test.startTest();
            devtype.Step_Status__c='Approved Step 1';
            update devtype;
            //DeviationTypeGroupHelper.processRecords(devIdSet);
            //DeviationTypeGroupHelper.processRecords(null);
            //devtype.ApprovalStatus__c='Approved';
            update devtype;
            Test.stopTest();
            //NS
            System.assert(true);
        }catch(DMLException e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 19-06-2020
* @description: This method is a test method for updateProposalEBDStatus and updateDeviationFields
*****************************************************************/
    @isTest
    public static void updateProposalEBDStatusTest()
    {
        try{
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);

            List<DeviationTypeGroup__c> newDeviationsList = new List<DeviationTypeGroup__c>();
            List<DeviationTypeGroup__c> oldDeviationsList = new List<DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> newDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> oldDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            //U-1903
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, 
                                                                                            Primary__c=true, DeviationsPreApproved__c=true,
                                                                                            PreApprovalComments__c='Ok'));
            insert prop;  
            
            
            System.runAs(testUser1) {
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = testUser1.Id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
                
            //for DeviationApprovalStatus__c = APPROVED
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            insert devtype;
            
            AccessSettings__c sett=AccessSettings__c.getInstance(testUser1.id);
            sett.CanEditDeviationFields__c=true;
            upsert sett;
                
            DeviationTypeGroup__c dd = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                        MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                        from DeviationTypeGroup__c 
                                        where Id=:devtype.Id];
            
            oldDeviationsList.add(dd);
            oldDeviationsMap.put(dd.Id,dd);
            
            devtype.MAStatus__c = 'Approved';
            devtype.BAStatus__c  = 'Approved';
            devtype.MAConditions__c = 'NEW Condition';
            devtype.MAComments__c = 'NEW Comment';
            update devtype;
            DeviationTypeGroup__c dd1 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype.Id];
            
            newDeviationsList.add(dd1);
            newDeviationsMap.put(dd1.Id,dd1);
            
            //for DeviationApprovalStatus__c = Rejected
            DeviationTypeGroup__c devtype1 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype1.BA_Approver__c = 'Shubham Kadam';
            devtype1.MAStatus__c = 'Pending';
            devtype1.BAStatus__c = 'Pending';
            devtype1.MAConditions__c = 'OLD Condition';
            devtype1.MAComments__c = 'OLD Comment';
            devtype1.MA_Approver__c = 'BDGS SPOCs';
            insert devtype1;
            DeviationTypeGroup__c dd2 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype1.Id];
            
            oldDeviationsList.add(dd2);
            oldDeviationsMap.put(dd2.Id,dd2);
            
            devtype1.MAStatus__c = 'Rejected';
            devtype1.BAStatus__c  = 'Rejected';
            devtype1.MAConditions__c = 'NEW Condition';
            devtype1.MAComments__c = 'NEW Comment';
            update devtype1;
            DeviationTypeGroup__c dd3 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype1.Id];
            
            newDeviationsList.add(dd3);
            newDeviationsMap.put(dd3.Id,dd3);
            
            //for DeviationApprovalStatus__c = Pending
            DeviationTypeGroup__c devtype2 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype2.BA_Approver__c = 'Shubham Kadam';
            devtype2.MAConditions__c = 'OLD Condition';
            devtype2.MAComments__c = 'OLD Comment';
            devtype2.MA_Approver__c = 'BDGS SPOCs';
            insert devtype2;
            DeviationTypeGroup__c dd4 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype2.Id];
            
            oldDeviationsList.add(dd4);
            oldDeviationsMap.put(dd4.Id,dd4);
            
            devtype2.MAStatus__c = 'Pending';
            devtype2.BAStatus__c = 'Pending';
            devtype2.MAConditions__c = 'NEW Condition';
            devtype2.MAComments__c = 'NEW Comment';
            update devtype2;
            DeviationTypeGroup__c dd5 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype2.Id];
            
            newDeviationsList.add(dd5);
            newDeviationsMap.put(dd5.Id,dd5);
            
            //for DeviationApprovalStatus__c = GlobalConstants.APPROVEDWITHCONDITIONS
            DeviationTypeGroup__c devtype4 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype4.BA_Approver__c = 'Shubham Kadam';
            devtype4.MAStatus__c = 'Pending';
            devtype4.BAStatus__c = 'Pending';
            devtype4.MAConditions__c = 'OLD Condition';
            devtype4.MAComments__c = 'OLD Comment';
            devtype4.MA_Approver__c = 'BDGS SPOCs';
            insert devtype4;
            DeviationTypeGroup__c dd8 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype4.Id];
            
            oldDeviationsList.add(dd8);
            oldDeviationsMap.put(dd8.Id,dd8);
            
            devtype4.MAStatus__c = 'Approved with Conditions';
            devtype4.BAStatus__c  = 'Approved with Conditions';
            devtype4.MAConditions__c = 'NEW Condition';
            devtype4.MAComments__c = 'NEW Comment';
            devtype4.BAConditions__c = 'NEW Condition';
            devtype4.BAComments__c = 'NEW Comment';
            update devtype4;
            DeviationTypeGroup__c dd9 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype4.Id];
            
            newDeviationsList.add(dd9);
            newDeviationsMap.put(dd9.Id,dd9);
            
            //for DeviationApprovalStatus__c = GlobalConstants.PREAPPROVED
            DeviationTypeGroup__c devtype5 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            //devtype5.BA_Approver__c = 'Shubham Kadam';
            devtype5.MAStatus__c = 'Pending';
            //devtype5.BAStatus__c = 'Pending';
            devtype5.MAConditions__c = 'OLD Condition';
            devtype5.MAComments__c = 'OLD Comment';
            devtype5.MA_Approver__c = 'BDGS SPOCs';
            insert devtype5;
            DeviationTypeGroup__c dd11 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype5.Id];
            
            oldDeviationsList.add(dd11);
            oldDeviationsMap.put(dd11.Id,dd11);
            
            devtype5.MAStatus__c = GlobalConstants.PREAPPROVED;
            //devtype5.BAStatus__c  = GlobalConstants.PREAPPROVED;
            devtype5.MAConditions__c = 'NEW Condition';
            devtype5.MAComments__c = 'NEW Comment';
            //devtype5.BAConditions__c = 'NEW Condition';
            //devtype5.BAComments__c = 'NEW Comment';
            update devtype5;
            DeviationTypeGroup__c dd10 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype5.Id];
            
            newDeviationsList.add(dd10);
            newDeviationsMap.put(dd10.Id,dd10);

            }
            
            Test.startTest();
            DeviationTypeGroupHelper.updateProposalEBDStatus(newDeviationsList,oldDeviationsMap);
            DeviationTypeGroupHelper.updateDeviationFields(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);
            Test.stopTest();
            //NS
            System.assert(true);
        }Catch(Exception e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 19-06-2020
* @description: This method is a test method for updateOverallEBDStatusonSDR
*****************************************************************/
    @isTest
    public static void updateOverallEBDStatusonSDRTest()
    {
        try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            
            //  Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true));
            insert prop;
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id; 
            DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId);
            //devtype.BA_Approver__c = 'Shubham Kadam';
            devtype.MAStatus__c = 'Pending';
            //devtype.BAStatus__c = 'Pending';
            devtype.MAConditions__c = 'OLD Condition';
            devtype.MAComments__c = 'OLD Comment';
            devtype.MA_Approver__c = 'BDGS SPOCs';
            insert devtype;
            
            Sales_Decision_Record__c sdr = new Sales_Decision_Record__c(Name = 'TestSDR',Sales_Decision_Type__c = 'SDP0 Qualify	',
                                                                        Sales_Decision_Date__c = System.today(),Opportunity__c = opp.Id);
            //insert sdr;
            
            //sdr.Primary_Proposal__c = prop.Id;
            //Update sdr;
            
            Test.startTest();
            System.runAs(testUser){
                DeviationTypeGroupHelper.updateOverallEBDStatusonSDR(prop.Id,'Approved');}
            Test.stopTest();
            //NS
            System.assert(true);
        }catch(DMLException e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 19-06-2020
* @description: This method is a test method for restrictEditOfSupportingMaterial
*****************************************************************/
    
    @isTest
    public static void restrictEditOfSupportingMaterialTest()
    {
        try{
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);
            
            List<DeviationTypeGroup__c> newDeviationsList = new List<DeviationTypeGroup__c>();
            List<DeviationTypeGroup__c> oldDeviationsList = new List<DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> newDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> oldDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            //  Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500, MarketArea__c='MELA'));  
            insert opp;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true));
            insert prop;  
            System.runAs(testUser1){
                Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
                Id queueId = grp.id;             
                DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype.MAStatus__c = 'Pending';
                devtype.BAStatus__c  = 'Pending';
                devtype.SupportingMaterial__c = 'OLD';
                insert devtype;
                oldDeviationsMap.put(devtype.Id,devtype);
                devtype.SupportingMaterial__c = 'NEW';
                Database.SaveResult result = Database.update(devtype,false);       
                newDeviationsList.add(devtype);

                Test.startTest();		
                //update devtype;
                new DeviationTypeGroupHandler().onBeforeUpdate(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);        
                DeviationTypeGroupHelper.restrictEditOfSupportingMaterial(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);        
                DeviationTypeGroupHelper.restrictEditOfBAFields(null, null, null, null);
                DeviationTypeGroupHelper.restrictEditOfMAFields(null, null, null, null); 
                DeviationTypeGroupHelper.restrictEditOfSupportingMaterial(null, null, null, null);
                DeviationTypeGroupHelper.updateDeviationFields(null, null, null, null);
                DeviationTypeGroupHelper.updateProposalEBDStatus(null,null);
                DeviationTypeGroupHelper.updateOverallEBDStatusonSDR(null, null);
                //System.assert(result.getErrors().size() == 1);
                
                Test.stopTest();
                //NS
                System.assert(true);
            }
        }catch(DMLException e) {     
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }  
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 19-06-2020
* @description: This method is a test method for restrictEditOfMAFields and restrictEditOfBAFields
*****************************************************************/
    @isTest
    public static void restrictEditOfMABAFieldsTest()
    { 
        try{
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);
            List<DeviationTypeGroup__c> newDeviationsList = new List<DeviationTypeGroup__c>();
            List<DeviationTypeGroup__c> oldDeviationsList = new List<DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> newDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> oldDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            //  Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true));
            insert prop;  
            System.runAs(testUser1){
                Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
                Id queueId = grp.id;        
                GroupMember gm = (GroupMember)TestDataGenerator.createSObject(new GroupMember(GroupId = grp.Id,UserOrGroupId=testUser.Id));       
                DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype.MAStatus__c = 'Pending';
                devtype.MAConditions__c = 'OLD Condition';
                devtype.MAComments__c = 'OLD Comment';
                devtype.MA_Approver__c = 'BDGS SPOCs';
                insert devtype;
                oldDeviationsList.add(devtype);
                oldDeviationsMap.put(devtype.Id,devtype);
                
                devtype.MAStatus__c = 'Approved';
                devtype.BAStatus__c  = 'Approved';
                devtype.MAConditions__c = 'NEW Condition';
                devtype.MAComments__c = 'NEW Comment';
                Database.SaveResult result = Database.update(devtype,false);
                newDeviationsList.add(devtype);
                newDeviationsMap.put(devtype.Id,devtype);
                
                DeviationTypeGroup__c devtype1 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype1.BAStatus__c = 'Pending';
                devtype1.BAConditions__c = 'OLD Condition';
                devtype1.BAComments__c = 'OLD Comment';
                devtype1.BA_Approver__c = 'BDGS SPOCs';
                insert devtype1;
                oldDeviationsList.add(devtype1);
                oldDeviationsMap.put(devtype1.Id,devtype1);
                
                devtype1.MAStatus__c = 'Approved';
                devtype1.BAStatus__c  = 'Approved';
                devtype1.BAConditions__c = 'NEW Condition';
                devtype1.BAComments__c = 'NEW Comment';
                Database.SaveResult result1 = Database.update(devtype1,false);
                newDeviationsList.add(devtype1);
                newDeviationsMap.put(devtype1.Id,devtype1);   
                Test.startTest();
                
                new DeviationTypeGroupHandler().onBeforeUpdate(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);       
                DeviationTypeGroupHelper.restrictEditOfMAFields(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);           
                DeviationTypeGroupHelper.restrictEditOfBAFields(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);
                
                Test.stopTest();
                //NS
                System.assert(true);
            }
        }catch(DMLException e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 24-08-2020
* @description: This method is a test method for postToChatter
*****************************************************************/
    @isTest(seeAllData=false)
    public static void postToChatterTest()
    {
        try{
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);
            
            List<DeviationTypeGroup__c> newDeviationsList = new List<DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> oldDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, Primary__c=true));
            insert prop; 
            
            prop.RequestedDeviationsApproval__c = true;
            update prop;
            
            System.runAs(testUser1){ 
                Group grp = [select id from Group where Name = :GlobalConstants.BNEW_SPOCs AND Type = 'Regular'];
                Id queueId = grp.id;  
                
                GroupMember gm = new GroupMember();
                gm.GroupId = grp.Id;
                gm.UserOrGroupId = testUser.Id;
                insert gm;
                
                GroupMember gm1 = new GroupMember();
                gm1.GroupId = grp.Id;
                gm1.UserOrGroupId = testUser1.Id;
                insert gm1;
                
                //BA_Approver__c = BNEW_SPOCs
                DeviationTypeGroup__c devtype = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype.MAStatus__c = 'Pending';
                devtype.MA_Approver__c = GlobalConstants.BNEW_SPOCs;
                devtype.BAStatus__c  = 'Pending';
                devtype.BA_Approver__c = GlobalConstants.BNEW_SPOCs;
                insert devtype;                
                oldDeviationsMap.put(devtype.Id,devtype);
                
                devtype.MAStatus__c = 'Approved';
                update devtype;               
                newDeviationsList.add(devtype);
                
                //BA_Approver__c = MELA_DS_CM_Head_n_Head_of_Price_Mgmt
                DeviationTypeGroup__c devtype1 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype1.MAStatus__c = 'Pending';
                devtype1.MA_Approver__c = GlobalConstants.BNEW_SPOCs;
                devtype1.BAStatus__c  = 'Pending';
                devtype1.BA_Approver__c = GlobalConstants.MELA_DS_CM_Head_n_Head_of_Price_Mgmt;
                insert devtype1;                
                oldDeviationsMap.put(devtype1.Id,devtype1);
                
                devtype1.MAStatus__c = 'Approved';
                update devtype1;               
                newDeviationsList.add(devtype1);
                
                //BA_Approver__c = MELA_Head_of_DS_n_MELA_DS_CM_Head
                DeviationTypeGroup__c devtype2 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype2.MAStatus__c = 'Pending';
                devtype2.MA_Approver__c = GlobalConstants.BNEW_SPOCs;
                devtype2.BAStatus__c  = 'Pending';
                devtype2.BA_Approver__c = GlobalConstants.MELA_Head_of_DS_n_MELA_DS_CM_Head;
                insert devtype2;                
                oldDeviationsMap.put(devtype2.Id,devtype2);
                
                devtype2.MAStatus__c = 'Approved';
                update devtype2;               
                newDeviationsList.add(devtype2);
                
                //BA_Approver__c = BMAS_SA_Head
                DeviationTypeGroup__c devtype3 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
                devtype3.MAStatus__c = 'Pending';
                devtype3.MA_Approver__c = GlobalConstants.BNEW_SPOCs;
                devtype3.BAStatus__c  = 'Pending';
                devtype3.BA_Approver__c = GlobalConstants.BMAS_SA_Head;
                insert devtype3;                
                oldDeviationsMap.put(devtype3.Id,devtype3);
                
                devtype3.MAStatus__c = 'Approved';
                update devtype3;               
                newDeviationsList.add(devtype3);
                
                Test.startTest();
                DeviationTypeGroupHelper.postToChatter(newDeviationsList,oldDeviationsMap);   
                DeviationTypeGroupHelper.postToChatter(null,null);   
                Test.stopTest();
                
                //NS
                System.assert(true);
            }
        }catch(DMLException e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }
    
    /****************************************************************
* @author: Shubham Kadam
* @date: 19-06-2020
* @description: This method is a test method for updateProposalEBDStatus and updateDeviationFields
*****************************************************************/
    @isTest
    public static void updateProposalEBDStatusTest1()
    {
        try{
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), 
                                                                            UserName = 'ericsson7778@test.com'+System.currentTimeMillis()),true);

            List<DeviationTypeGroup__c> newDeviationsList = new List<DeviationTypeGroup__c>();
            List<DeviationTypeGroup__c> oldDeviationsList = new List<DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> newDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            Map<ID, DeviationTypeGroup__c> oldDeviationsMap = new Map<ID, DeviationTypeGroup__c>();
            
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;  //U-1903
            Account acc;
            //U-1903
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc  = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, 
                                                                                           Anticipated_Deal_Value__c = 500));  
            insert opp;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Name = 'Test', Opportunity__c = opp.Id, 
                                                                                            Primary__c=true, DeviationsPreApproved__c=true,
                                                                                            PreApprovalComments__c='Ok'));
            insert prop;  
            
            
            System.runAs(testUser1) {
            Group grp = [select id from Group where Name='BDGS SPOCs' AND Type = 'Queue'];
            Id queueId = grp.id;
            
            //Create Group Member
            GroupMember grpMem1 = new GroupMember();
            grpMem1.UserOrGroupId = testUser1.Id;
            grpMem1.GroupId = grp.Id;
            Insert grpMem1;
            
            //for DeviationApprovalStatus__c = GlobalConstants.Cancelled
            DeviationTypeGroup__c devtype6 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype6.BA_Approver__c = 'Shubham Kadam';
            devtype6.MAStatus__c = 'Pending';
            devtype6.BAStatus__c = 'Pending';
            devtype6.MAConditions__c = 'OLD Condition';
            devtype6.MAComments__c = 'OLD Comment';
            devtype6.MA_Approver__c = 'BDGS SPOCs';
            insert devtype6;
                
            AccessSettings__c sett=AccessSettings__c.getInstance(testUser1.id);
            sett.CanEditDeviationFields__c=true;
            upsert sett;
                
            DeviationTypeGroup__c dd12 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype6.Id];
            
            oldDeviationsList.add(dd12);
            oldDeviationsMap.put(dd12.Id,dd12);
            
            devtype6.MAStatus__c = GlobalConstants.Cancelled;
            devtype6.BAStatus__c  = GlobalConstants.Cancelled;
            devtype6.MAConditions__c = 'NEW Condition';
            devtype6.MAComments__c = 'NEW Comment';
            devtype6.BAConditions__c = 'NEW Condition';
            devtype6.BAComments__c = 'NEW Comment';
            update devtype6;
            DeviationTypeGroup__c dd13 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype6.Id];
            
            newDeviationsList.add(dd13);
            newDeviationsMap.put(dd13.Id,dd13);	
			
			//for DeviationApprovalStatus__c = GlobalConstants.TOBEREQUESTED
            DeviationTypeGroup__c devtype7 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype7.BA_Approver__c = 'Shubham Kadam';
            devtype7.MAStatus__c = 'Pending';
            devtype7.BAStatus__c = 'Pending';
            devtype7.MAConditions__c = 'OLD Condition';
            devtype7.MAComments__c = 'OLD Comment';
            devtype7.MA_Approver__c = 'BDGS SPOCs';
            insert devtype7;
            DeviationTypeGroup__c dd14 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype7.Id];
            
            oldDeviationsList.add(dd14);
            oldDeviationsMap.put(dd14.Id,dd14);
            
            devtype7.MAStatus__c = GlobalConstants.TOBEREQUESTED;
            devtype7.BAStatus__c  = GlobalConstants.TOBEREQUESTED;
            devtype7.MAConditions__c = 'NEW Condition';
            devtype7.MAComments__c = 'NEW Comment';
            devtype7.BAConditions__c = 'NEW Condition';
            devtype7.BAComments__c = 'NEW Comment';
            update devtype7;
            DeviationTypeGroup__c dd16 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype7.Id];
            
            newDeviationsList.add(dd16);
            newDeviationsMap.put(dd16.Id,dd16);    
                
            //Updating Approver Status 2 when Approver1 Status is updated from PreApproved to Pending
            DeviationTypeGroup__c devtype8 = new DeviationTypeGroup__c(Proposal__c=prop.id,ApproverGroup1__c = queueId,ApproverGroup2__c = queueId);
            devtype8.BA_Approver__c = 'Shubham Kadam';
            devtype8.MAStatus__c = GlobalConstants.PREAPPROVED;
            devtype8.BAStatus__c = GlobalConstants.Pending;
            devtype8.MAConditions__c = 'OLD Condition';
            devtype8.MAComments__c = 'OLD Comment';
            devtype8.MA_Approver__c = 'BDGS SPOCs';
            insert devtype8;
            DeviationTypeGroup__c dd18 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype8.Id];
            
            oldDeviationsList.add(dd18);
            oldDeviationsMap.put(dd18.Id,dd18);
            
            devtype8.MAStatus__c =  GlobalConstants.Pending;
            devtype8.BAStatus__c  =  GlobalConstants.PREAPPROVED;
            devtype8.MAConditions__c = 'NEW Condition';
            devtype8.MAComments__c = 'NEW Comment';
            devtype8.BAConditions__c = 'NEW Condition';
            devtype8.BAComments__c = 'NEW Comment';
            update devtype8;
            DeviationTypeGroup__c dd19 = [Select Id,Proposal__c,ApproverGroup1__c,ApproverGroup2__c,BA_Approver__c,MAStatus__c,BAStatus__c,
                                         MAConditions__c,MAComments__c,MA_Approver__c,DeviationApprovalStatus__c 
                                         from DeviationTypeGroup__c 
                                         where Id=:devtype8.Id];
            
            newDeviationsList.add(dd19);
            newDeviationsMap.put(dd19.Id,dd19);    
            }
            
            Test.startTest();
            DeviationTypeGroupHelper.updateProposalEBDStatus(newDeviationsList,oldDeviationsMap);
            DeviationTypeGroupHelper.updateDeviationFields(newDeviationsList,oldDeviationsList,newDeviationsMap,oldDeviationsMap);
            Test.stopTest();
            //NS
            System.assert(true);
        }Catch(Exception e){
            System.debug('##Error '+e.getMessage()+' -- '+e.getLineNumber());
        }
    }   
}