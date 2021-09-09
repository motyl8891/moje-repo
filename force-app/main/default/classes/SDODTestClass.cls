/**
 * @File Name          : SDODTestClass.cls
 * @Description        : 
 * @Author             : Ananth Chilapally
 * @Group              : 
 * @Last Modified By   : Ananth Chilapally
 * @Last Modified On   : 2019-12-05 23:33:16
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    2019-08-02 15:34:20   Ananth Chilapally     Initial Version
**/
@isTest(seeAllData = false)
private without sharing class SDODTestClass {
    
    private static testmethod void callClass()
    {       
        List<SDOD_Lead__c> sdodLst=new List<SDOD_Lead__c>();
        SDOD_Lead__c sdod =new SDOD_Lead__c();
        SDOD_Lead__c sdodNoLHR=new SDOD_Lead__c();
        SDOD_Lead__c sdodNoLHRMNEA = new SDOD_Lead__c();
        
        Recorder__c r;
        List<User> users = new List<User>();
        String pid = [Select id from Profile where Name='SDOD Salesforce Profile'].Id;
        
        for(integer i=1; i<=1; i++)
        { 
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId  + randomInt + i;
            User tuser = new User(  firstname = 'test',
                                  lastName = 'Testing',
                                  email = uniqueName + '@test' + orgId + '.org',
                            	  Username = uniqueName + '@test' + orgId + '.org',
                                  EmailEncodingKey = 'ISO-8859-1',
                                  Alias = uniqueName.substring(uniqueName.length()-5, uniqueName.length()),
                                  CommunityNickname=randomInt+'_'+i,
                                  TimeZoneSidKey = 'America/Los_Angeles',
                                  LocaleSidKey = 'en_US',
                                  LanguageLocaleKey = 'en_US',
                                  SDOD_Organization_Type__c = 'SDOD-LHR-EA',
                                  ProfileId = pid);
            
            users.add(tuser);
        }
        
        Test.startTest();
        insert users;
        
        //Create Parent Group
        Group grp = new Group();
        grp.name = 'SDOD-LHR';
        grp.Type = 'Regular'; 
        Insert grp; 
        
        //Create Group Member
        GroupMember grpMem1 = new GroupMember();
        grpMem1.UserOrGroupId = users[0].Id;
        grpMem1.GroupId = grp.Id;
        Insert grpMem1;
        
        Group g1 = new Group(Name='group name', type='Queue');
        insert g1;
        QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'SDOD_Lead__c');
        insert q1;
        
        Test.stopTest();
        
        System.runAs(users[0])
        {
            
            CustomerUnit__c cus=new CustomerUnit__c(Name='AT&T', Type__c = 'CU', ID__c = '100095');
            insert cus;
            CustomerReportingGroup__c cusRep=new CustomerReportingGroup__c();
            cusRep.CustomerUnit__c=cus.id;
            insert cusRep;

            CustomerUnit__c cusMNEA=new CustomerUnit__c(Name='AT&T BMAS', Type__c = 'CU', ID__c = '100025');
            insert cusMNEA;
            CustomerReportingGroup__c cusRepMNEA=new CustomerReportingGroup__c();
            cusRepMNEA.CustomerUnit__c=cusMNEA.id;
            insert cusRepMNEA;

            Id RecordTypeIdSOG = GlobalConstants.sogRecordTypeId;
            sdod.recordTypeId= RecordTypeIdSOG;
            sdod.Title__c='test';
            sdod.How_to_identify__c='Discussion with CU';
            //sdod.Additional_Recorders__c=Users[0].Email + ',' + Users[0].Email + ','+Users[0].Email + ',' +Users[0].Email + ',' + Users[0].Email+ ',' + Users[0].Email +'.eu' + ',' + Users[0].Email+'.eu';//'geetha.muthukuru@tcs.com,efg';
            sdod.Additional_Recorders__c=Users[0].Email + '.eu';//'geetha.muthukuru@tcs.com,efg';
            sdod.MarketArea__c='MMEA';
            sdod.Customer_Reporting_Group__c=cusRep.id;
            sdod.Business_Area__c='BTEB';
            sdod.Commodity__c='Software (SW)';
            sdod.Creator_Email__c=Users[0].Email;
            sdod.LHR__c=Users[0].id;
            sdod.Stage__c='D - Recorded';
            sdod.Approved_by_LHR__c = true;
            
            
            sdodLst.add(sdod);

            sdodNoLHR.recordTypeId= RecordTypeIdSOG;
            sdodNoLHR.Title__c='test';
            sdodNoLHR.How_to_identify__c='Discussion with CU';
            //sdodNoLHR.Additional_Recorders__c=Users[0].Email + ',' + Users[0].Email + ','+Users[0].Email + ',' +Users[0].Email + ',' + Users[0].Email+ ',' + Users[0].Email +'.eu' + ',' + Users[0].Email+'.eu';//'geetha.muthukuru@tcs.com,efg';
            sdodNoLHR.Additional_Recorders__c=Users[0].Email +'.eu';//'geetha.muthukuru@tcs.com,efg';
            sdodNoLHR.MarketArea__c='MMEA';
            sdodNoLHR.Customer_Reporting_Group__c=cusRep.id;
            sdodNoLHR.Business_Area__c='BTEB';
            sdodNoLHR.Commodity__c='Software (SW)';
            sdodNoLHR.Creator_Email__c=Users[0].Email;
            sdodNoLHR.Stage__c='D - Recorded';
            sdodNoLHR.Approved_by_LHR__c = true;
            
            
            sdodLst.add(sdodNoLHR);            

            sdodNoLHRMNEA.recordTypeId= RecordTypeIdSOG;// '0120Q0000008g1RQAQ';
            sdodNoLHRMNEA.Title__c='test';
            sdodNoLHRMNEA.How_to_identify__c='Discussion with CU';
            //sdodNoLHRMNEA.Additional_Recorders__c=Users[0].Email + ',' + Users[0].Email + ','+Users[0].Email + ',' +Users[0].Email + ',' + Users[0].Email+ ',' + Users[0].Email +'.eu' + ',' + Users[0].Email+'.eu';//'geetha.muthukuru@tcs.com,efg';
            sdodNoLHRMNEA.Additional_Recorders__c=Users[0].Email ;//'geetha.muthukuru@tcs.com,efg';
            sdodNoLHRMNEA.MarketArea__c='MNEA';
            sdodNoLHRMNEA.Customer_Reporting_Group__c=cusRepMNEA.id;
            sdodNoLHRMNEA.Business_Area__c='BMAS';
            sdodNoLHRMNEA.Commodity__c='Software (SW)';
            sdodNoLHRMNEA.Creator_Email__c=Users[0].Email;
            sdodNoLHRMNEA.Stage__c='D - Recorded';
            sdodNoLHRMNEA.Approved_by_LHR__c = true;
            
            
            sdodLst.add(sdodNoLHRMNEA);              

            //Test.startTest();
            insert sdodLst;
            // Test.stopTest();
                
            Employee__c emp = new Employee__c(Name='test', Email__c=Users[0].Email,	Signum__c = 'test', Status__c = 'Active' );
            insert emp;
            
            r = new Recorder__c(SDOD_Lead__c = sdodLst[0].id);
            r.Recorder_A_Z_del__c='A';
            r.Recorder_Employee_Name__c= emp.id;
            insert r;
     String msg;
       /*     try{ insert r;}
        catch(Exception e)
        {
            msg = e.getMessage();
        }
        test.startTest();
            
        System.assertEquals(true,msg.contains('Contibution should not be greater than 100') );*/
            
        
            
            Opportunity op=new Opportunity();
            //op.SDOD_Lead__c=sdodLst[0].id;
            //insert op;
            //SDODLeadTriggerHandler.AddAdditionalRecorders(sdodLst);
            SDODLeadTriggerHandler.contributionValidtaion(new List<SDOD_Lead__c>{sdodLst[0]});
            SDODLeadTriggerHandler.contributionValidtaion(sdodLst);
            SDODLeadTriggerHandler.AccessToRecord(sdodLst);
            //SDODLeadTriggerHandler.updateFirstRecorder(sdodLst);
            SDODLeadTriggerHandler.AddAdditionalRecorder(sdodLst);
            SDODLeadTriggerHandler.AssigntoQueue(sdodLst);
            SDODLeadTriggerHandler.contributionValidtaion(sdodLst);
            SDODLeadTriggerHandler.AddAdditionalRecorder(sdodLst);
            SDODLeadTriggerHandler.AddAdditionalRecorder(null);            
            SDODLeadTriggerHandler.AssignToSales(sdodLst,sdodLst);
            SDODLHRAssignedLeadsClass.getAssignedLeads();
            SDODNewLeadController.UpdateCreatedBy(sdodLst[0].id,String.ValueOf(sdodLst[0].Creator_Email__c));
            SDODNewLeadController.getFilteredLeads(String.ValueOf(sdodLst[0].Creator_Email__c));
            SDODNewLeadController.getHitsAcc(String.ValueOf(sdodLst[0].CustomerUnit__c),String.ValueOf(sdodLst[0].Country__c));
            SDODNewLeadController.getHitsAcr(Users[0].name);
            SDODNewLeadController.getHitsLHR(Users[0].name);
            SDODNewLeadController.getCU(cusRep.id); 
            //SDODLeadTrigger.contributionValidtaion(new List<SDOD_Lead__c>{sdodLst[0]});
            //SDODLeadTrigger.contributionValidtaion(sdodLst);
            //SDODLeadTrigger.AccessToRecord(sdodLst);
            //SDODLeadTriggerHandler.updateFirstRecorder(sdodLst);
            //SDODLeadTrigger.AddAdditionalRecorder(sdodLst);
            //SDODLeadTrigger.AddAdditionalRecorder(null);
            //SDODLeadTrigger.AssigntoQueue(sdodLst);
            List<Employee__c> emplIst =SDODNewLeadController.getEmployees('test');
            system.assertEquals(1, emplIst.size());
            
            SDODNewLeadController.updateRecord(sdod);
            SDODNewLeadController.updateRecord(null);
           SDODNewLeadController.getRecordInformation(sdodLst[0].id);
           SDODNewLeadController.getRecordInformation(null);
            SDODNewLeadController.getCU(null);
            SDODNewLeadController.UpdateCreatedBy(null,null);            
        }
    }
}