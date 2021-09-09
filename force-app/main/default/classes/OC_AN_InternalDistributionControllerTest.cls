/**
* @File Name          : OC_AN_ProductSelectionControllerTest
* @Description        : Test Class for
*						OC_AN_InternalDistributionController
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 06 Aug 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-06              	IBM               Initial Version
**/
@IsTest
public  class OC_AN_InternalDistributionControllerTest {
    /**
   * @Description : Data setup for test class.
   **/
    @testsetup 
    static void setup(){
        Id migrationProfileId = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'Migration User Profile'
            ].Id; 

        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationProfileId;
        testuser.IsActive = true;  
        insert testuser;

        List<OC_AN_Public_Group__c> publicGroupList = new List<OC_AN_Public_Group__c>();
        List<OC_AN_Group_Member__c> publicGroupmemberList = new List<OC_AN_Group_Member__c>();
        Set<Id> childGroupId = new Set<Id>();

        System.runAs(testUser){ 
        OC_AN_Bulletin_Template__c bTemplate = new OC_AN_Bulletin_Template__c(
            OC_AN_Delay_In_Hours__c = 5
            , OC_AN_Internal_Text__c = 'Internal Text'
            , OC_AN_Template__c = 'Template'
            , OC_AN_Type__c = 'Emergency Problem'
        ); 
        insert bTemplate;

        OC_AN_Bulletin__c bulletinRec = new OC_AN_Bulletin__c(
            Name = 'Test Bulletin' 
        );
        bulletinRec.OC_AN_Bulletin_Template__c = bTemplate.Id;      
        insert bulletinRec;

        OC_AN_Public_Group__c pgToInsert = (OC_AN_Public_Group__c)OC_TestDataGenerator.createSObject(new OC_AN_Public_Group__c());
            pgToInsert.Name = 'All Internal Groups';
            publicGroupList.add(pgToInsert);
        OC_AN_Public_Group__c pgToInsert1 = (OC_AN_Public_Group__c)OC_TestDataGenerator.createSObject(new OC_AN_Public_Group__c());
            pgToInsert1.Name = 'Mena';
            publicGroupList.add(pgToInsert1);
        OC_AN_Public_Group__c pgToInsert2 = (OC_AN_Public_Group__c)OC_TestDataGenerator.createSObject(new OC_AN_Public_Group__c());
            pgToInsert2.Name = 'Mela';
            publicGroupList.add(pgToInsert2);
        insert publicGroupList;

        OC_AN_Group_Member__c pgmemToInsert = (OC_AN_Group_Member__c)OC_TestDataGenerator.createSObject(new OC_AN_Group_Member__c());
            pgmemToInsert.OC_AN_Parent_Group__c=pgToInsert.id;
            pgmemToInsert.OC_AN_Child_Group__c=pgToInsert1.id;
            childGroupId.add(pgmemToInsert.OC_AN_Child_Group__c);
            publicGroupmemberList.add(pgmemToInsert);
        OC_AN_Group_Member__c pgmemToInsert1 = (OC_AN_Group_Member__c)OC_TestDataGenerator.createSObject(new OC_AN_Group_Member__c());
            pgmemToInsert1.OC_AN_Parent_Group__c=pgToInsert.id;
            pgmemToInsert1.OC_AN_Child_Group__c=pgToInsert1.id;
            childGroupId.add(pgmemToInsert1.OC_AN_Child_Group__c);
            publicGroupmemberList.add(pgmemToInsert1);
        OC_AN_Group_Member__c pgmemToInsert2 = (OC_AN_Group_Member__c)OC_TestDataGenerator.createSObject(new OC_AN_Group_Member__c());
            pgmemToInsert2.OC_AN_Parent_Group__c=pgToInsert1.id;
            pgmemToInsert2.OC_AN_Child_Group__c=pgToInsert2.id;
            publicGroupmemberList.add(pgmemToInsert2);
        insert publicGroupmemberList;
            
        OC_AN_Public_Group__c groupRec1 = [SELECT Id,Name From OC_AN_Public_Group__c  where ID IN : childGroupId Order By Name ASC LIMIT 1];    
        }
    }
    
    @isTest
    static void testmethod1(){
        Test.startTest();   
        OC_AN_InternalDistributionController.PublicGroupWrapper pgwrapper = new OC_AN_InternalDistributionController.PublicGroupWrapper();
            pgwrapper.Name='test parent';
        OC_AN_InternalDistributionController.GroupSelectionWrapper wrapper= new OC_AN_InternalDistributionController.GroupSelectionWrapper();
           
            wrapper.isCompleted = false;
            wrapper.offsetCount = 0; 
        OC_AN_InternalDistributionController.getPublicGroupsHierarchy(wrapper);
            wrapper.offsetCount = 1;
        OC_AN_InternalDistributionController.getPublicGroupsHierarchy(wrapper);
            wrapper.offsetCount = 2;
        OC_AN_InternalDistributionController.getPublicGroupsHierarchy(wrapper);
            wrapper.offsetCount = 4;
        OC_AN_InternalDistributionController.getPublicGroupsHierarchy(wrapper);
            wrapper.offsetCount = 400;
        OC_AN_InternalDistributionController.getPublicGroupsHierarchy(wrapper);
            wrapper.offsetCount=null;
            wrapper.isCompleted=null;
    
        OC_AN_Bulletin__c bulletinRecord = [SELECT Id,OC_AN_IsInternal__c ,OC_AN_Current_Status__c FROM OC_AN_Bulletin__c WHERE Id != null LIMIT 1];
        OC_AN_Public_Group__c selectedgroupRec = [SELECT Id,Name From OC_AN_Public_Group__c Order By Name ASC LIMIT 1];
        OC_AN_Public_Group__c delgroupRec = [SELECT Id,Name From OC_AN_Public_Group__c Order By Name ASC LIMIT 1];

        List<String> userRoleList = new List<String>();
        userRoleList.add('Author');
        userRoleList.add('SDM');

        List<String> userRoleList1 = new List<String>();

        List<String> recRolesList;

        List<String> rolevalues = new List<String>();
        rolevalues.add('Editorial Reviewer');
        rolevalues.add('Technical Reviewer');
        rolevalues.add('Approver');
        rolevalues.add('Local Publisher');
        rolevalues.add('SDM');
        rolevalues.add('Author');
         
     
        String inputJson = '{"selected":{}, "deselected":{}}';
        inputJson = '{"selected":{"'+selectedgroupRec.Id+'":{"Id":"'+selectedgroupRec.Id+'","Name":"'+selectedgroupRec.Name+'", "selectedState":"checked" } },"deselected":{"'+delgroupRec.Id+'":{"Id":"'+delgroupRec.Id+'","Name":"'+delgroupRec.Name+'", "selectedState":"unchecked" }} }';
       
        OC_AN_InternalDistributionController.saveGroupSelection(inputJson,bulletinRecord.Id,userRoleList);
        System.assertEquals(OC_AN_InternalDistributionController.saveGroupSelection(inputJson,bulletinRecord.Id,userRoleList), 'success');
        System.assertEquals(OC_AN_InternalDistributionController.saveGroupSelection(inputJson,bulletinRecord.Id,userRoleList1), 'success');
        OC_AN_InternalDistributionController.getCurrentBulletinProductsGroups(bulletinRecord.Id);
        
        recRolesList= OC_AN_InternalDistributionController.getRolesForAN();
        System.assertEquals(recRolesList, rolevalues);

        bulletinRecord.OC_AN_Current_Status__c=OC_AN_Constants.DRAFT;
        OC_AN_InternalDistributionController.markIsInternalAsTrue(bulletinRecord.Id);
        System.assertEquals(  OC_AN_InternalDistributionController.markIsInternalAsTrue(bulletinRecord.Id),'success');

        OC_AN_InternalDistributionController.getselectOptions(OC_AN_Constants.OC_AN_Bulletin_Account_Product,OC_AN_Constants.OC_AN_RoleForA_N);
        System.assertEquals(OC_AN_InternalDistributionController.getselectOptions(OC_AN_Constants.OC_AN_Bulletin_Account_Product,OC_AN_Constants.OC_AN_RoleForA_N),rolevalues);
        Test.stopTest();
    }
}