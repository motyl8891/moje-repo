/**
* @File Name          : OC_AN_LocalBulletinCreationCtrTest
* @Description        : Test Class for OC_AN_LocalBulletinCreationController
*                       U-2832 Alerts & Notification: Creation of local bulletins.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 9th June 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-09              	IBM               Initial Version
**/


@isTest
public with sharing class OC_AN_LocalBulletinCreationCtrTest {
    //create test data.
    @testsetup 
    static void testDataSetup(){
        
        List<User> userListToInsert = new List<User>();
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<Group> listOfPublicGroup = new List<Group>();

        List<Account> accList = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList = new List<Contact> ();

        List<OC_AN_Bulletin_Account_Product__c> accProductList=new List<OC_AN_Bulletin_Account_Product__c>();
        
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        //create test user.
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericssonTestLocalPublisher@test.com';
        testuser.FirstName='Test Local Publisher';
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        
        System.runAs(testUser){
            Id serviceProfileId = [SELECT Id FROM Profile WHERE Name = 'Ericsson Service'].Id;
            //create service user
            User serviceUser = (User)OC_TestDataGenerator.createSObject(new User());
            serviceUser.ProfileId = serviceProfileId;
            serviceUser.IsActive = true;
            userListToInsert.add(serviceUser);
            if(!userListToInsert.isEmpty()){
                insert userListToInsert;
            }
            
            
             
            //create public group
            Group publicGroupToInsert = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert.Name = 'A&N - Test Group';
            listOfPublicGroup.add(publicGroupToInsert);
            if(!listOfPublicGroup.isEmpty()){
                insert listOfPublicGroup;
            }
            
            //create group memebers.
            GroupMember groupMemberToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            groupMemberToInsert.GroupId = listOfPublicGroup[0].Id;
            groupMemberToInsert.UserOrGroupId = userListToInsert[0].Id;
            groupMemberListToInsert.add(groupMemberToInsert);
            if(!groupMemberListToInsert.isEmpty()){
                insert groupMemberListToInsert;
            }
            
            //create bulletin template.
            OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
            listOfBulletinTemplate.add(bulletinTemplateToInsert);
            if(!listOfBulletinTemplate.isEmpty()){
                insert listOfBulletinTemplate;
            }
            
            //create bulletin record.
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.Name = 'LocalBulletinTestClass';
            bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            listOfBulletin.add(bulletinToInsert);
            if(!listOfBulletin.isEmpty()){
                insert listOfBulletin ;
            }   

            //create account and contact.
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            accSales.RecordTypeId = OC_AN_Constants.recTypeId_forSalesAccount;
            accSales.Account_Type__c = OC_AN_Constants.sales;
            insert accSales;
            Account acc = (Account)OC_TestDataGenerator.createSObject(new Account());
            acc.Account_Type__c = OC_AN_Constants.service;
            acc.ParentId = accSales.Id;
            acc.RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
            insert acc;
            accList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accList[0].Account_Type__c = OC_AN_Constants.subDivision;
            accList[0].RecordTypeId = OC_AN_Constants.recTypeId_forServiceAccount;
            accList[0].ParentID = acc.Id;
            insert accList;
            conList = OC_TestDataGenerator.createSObjectList(new Contact(),2);
            if(accList!=null && !accList.isEmpty() && conList!=null && !accList.isEmpty() ){
                conList[0].AccountId = accList[0].Id;
                conList[1].AccountId = acc.Id;
                updateaccList.add(accList[0]);
                insert conList;
                update updateaccList; 
            }

            //create external distribution list associated to bulletin.
            OC_AN_Bulletin_Account_Product__c AccountProductRecord = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            AccountProductRecord.OC_AN_Account__c =accList[0].Id;
            AccountProductRecord.OC_AN_Status__c =OC_AN_Constants.OC_AN_External_Distribution_List_Status;
            AccountProductRecord.OC_AN_Sub_Status__c =OC_AN_Constants.OC_AN_External_Distribution_List_Substatus;
            AccountProductRecord.OC_AN_Comments__c ='Test';
            AccountProductRecord.RecordTypeId= OC_AN_Constants.recTypeId_Account;
            AccountProductRecord.OC_AN_Bulletin__c =  listOfBulletin[0].Id;
            
            accProductList.add(AccountProductRecord);
            
            //create local publisher for account.
            OC_AN_Group_Member__c localPublisherForAccount = new OC_AN_Group_Member__c();
            localPublisherForAccount.OC_AN_Account__c = accList[0].Id;
            localPublisherForAccount.OC_AN_User__c = testUser.Id;
            localPublisherForAccount.RecordTypeId=OC_AN_Constants.recordTypeId_LocalPublisher;
            localPublisherForAccount.OC_AN_Local_Publisher__c = true;
            
            insert localPublisherForAccount;
            
            //create internal distribution list associated to bulletin.
            String rolesToBackend='Author;SDM';
            OC_AN_Bulletin_Account_Product__c groupToAssociate = new OC_AN_Bulletin_Account_Product__c();
                groupToAssociate.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
                groupToAssociate.OC_AN_GroupId__c = listOfPublicGroup[0].Id;
                groupToAssociate.OC_AN_Public_Group_Name__c = listOfPublicGroup[0].Name;
                groupToAssociate.OC_AN_IsPublicGroup__c = true;
                groupToAssociate.OC_AN_RoleForA_N__c = rolesToBackend;
                groupToAssociate.OC_AN_Bulletin__c = listOfBulletin[0].Id;
                groupToAssociate.OC_AN_BulletinAccProductAttrKey__c = listOfPublicGroup[0].Id + '' + listOfBulletin[0].Id;
                accProductList.add(groupToAssociate);
           
                //create product record.
                Product2 product = (Product2) OC_TestDataGenerator.createSObject(new Product2());
                product.OC_MD_Product_type__c = OC_AN_Constants.PRODUCT_TYPE;
                product.Product_Code_Number__c = 'P1';
                product.Name = 'Test 1';
                insert product;

                //create product release record.
                OC_MD_ProductAttributes__c releaseRecord = new OC_MD_ProductAttributes__c();
                releaseRecord.RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release;
                releaseRecord.Name = 'Release 1';
                releaseRecord.OC_MD_Product__c = product.Id;
                insert releaseRecord;

                //create product version record.
                OC_MD_ProductAttributes__c versionRecord = new OC_MD_ProductAttributes__c();
                versionRecord.RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Version;
                versionRecord.Name = 'Version 1';
                versionRecord.OC_MD_Parent__c = releaseRecord.Id;
                insert versionRecord;

                //crate product list associated to bulletin.
                OC_AN_Bulletin_Account_Product__c accountProductRecord1=new OC_AN_Bulletin_Account_Product__c();
                accountProductRecord1.OC_AN_Product__c=product.id;
                accountProductRecord1.OC_AN_Release__c=releaseRecord.Id;
                accountProductRecord1.OC_AN_Verison__c=versionRecord.id;
                accountProductRecord1.OC_AN_Bulletin__c= listOfBulletin[0].Id;
                accountProductRecord1.RecordtypeId=OC_AN_Constants.recTypeId_AccPrdForBulletin_Product;
            
               accProductList.add(accountProductRecord1);

               insert accProductList;
        } 
    }

    /*This method is used to test positive scnenario of getExternalDistributionList() method.
      Expected outcome is list of external distribution list  for which local bulletin is not present.
    */
    static testMethod void  getExternalDistributionListPositiveTest(){
        User u = [Select id,Name,UserName from user where userName='ericssonTestLocalPublisher@test.com' LIMIT 1 ];
        
        OC_AN_Bulletin__c recbulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c 
                                               WHERE Name = 'LocalBulletinTestClass' LIMIT 1 ];
      
        System.runAs(u)
        {
            List<OC_AN_Bulletin_Account_Product__c> externalDistributionList=new List<OC_AN_Bulletin_Account_Product__c>();
            Test.startTest();
            externalDistributionList=OC_AN_LocalBulletinCreationController.getExternalDistributionList(recbulletinRecord.id);
            Test.stopTest();
            system.assertEquals(1,externalDistributionList.size());
        }
    }

    /*This method is used to test negative scnenario of getExternalDistributionList() method.
      Expected outcome is null records. 
    */
    static testMethod void  getExternalDistributionListNegativeTest(){
        User u = [Select id,Name,UserName from user where userName='ericssonTestLocalPublisher@test.com' LIMIT 1 ];
        
        System.runAs(u)
        {
            List<OC_AN_Bulletin_Account_Product__c> externalDistributionList=new List<OC_AN_Bulletin_Account_Product__c>();
            Test.startTest();
            externalDistributionList=OC_AN_LocalBulletinCreationController.getExternalDistributionList(null);
            Test.stopTest();
            system.assertEquals(0,externalDistributionList.size());
        }
    }

    
    /*This method is used to test positive scnenario of createLocalBulletin() method.
      Expected outcome is creation of local bulletin record and  and related intenal distribution, external distribution and product lists.
    */
    static testMethod void  createLocalBulletinPositiveTest(){
        User u = [Select id,Name,UserName from user where userName='ericssonTestLocalPublisher@test.com' LIMIT 1 ];
       
        OC_AN_Bulletin__c recbulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c 
                                               WHERE Name = 'LocalBulletinTestClass' LIMIT 1 ];
       
        OC_AN_Bulletin_Account_Product__c externalDistribution=[SELECT Id,OC_AN_Account__r.Name,OC_AN_Account__c,OC_AN_Status__c,
                                                              OC_AN_Sub_Status__c,OC_AN_Comments__c from
                                                              OC_AN_Bulletin_Account_Product__c
                                                              where OC_AN_Local_Bulletin__c ='' AND 
                                                              OC_AN_Bulletin__c =: recbulletinRecord.id AND RecordTypeId=: OC_AN_Constants.recTypeId_Account 
                                                              limit 1];
        string jsonResponse ='[{"Status":"'+ externalDistribution.OC_AN_Status__c+'","SUBSTATUS":"'+ externalDistribution.OC_AN_Sub_Status__c +'","textBoxValue":"' + externalDistribution.OC_AN_Comments__c+'","accountName":"' + externalDistribution.OC_AN_Account__r.Name+'","accountID":"' + externalDistribution.OC_AN_Account__c+'","RecordId":"' +externalDistribution.id+'","createLBForAccountFlag":"True"}]';                                        
        System.runAs(u)
        {

            Test.startTest();
             OC_AN_LocalBulletinCreationController.createLocalBulletin(jsonResponse,recbulletinRecord.id);
            Test.stopTest();
            List<OC_AN_Bulletin__c> localBulletin=[SELECT id FROM OC_AN_Bulletin__c WHERE OC_AN_Parent_Bulletin__c=:recbulletinRecord.id];
            
            system.assertEquals(1, localBulletin.size());
        }
    }

     /*This method is used to test negative scnenario of createLocalBulletin() method.
      Expected outcome is No creation of local bulletin record and related intenal distribution, external distribution and product lists.
    */
    static testMethod void  createLocalBulletinNegativeTest(){
        User u = [Select id,Name,UserName from user where userName='ericssonTestLocalPublisher@test.com' LIMIT 1 ];
        OC_AN_Bulletin__c recbulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c WHERE Name = 'LocalBulletinTestClass' LIMIT 1 ];
        System.runAs(u)
        {
            string message;
            Test.startTest();
            try{
                message= OC_AN_LocalBulletinCreationController.createLocalBulletin(null,null);}
            catch(Exception ex){
                message='error';
            }
            Test.stopTest();
            List<OC_AN_Bulletin__c> localBulletin=[SELECT id FROM OC_AN_Bulletin__c WHERE OC_AN_Parent_Bulletin__c=:recbulletinRecord.id];
           
            system.assertEquals(0, localBulletin.size());
            system.assertEquals('error',message);
        }
    }

    /*This method is used to test positive scnenario of updateParentExternalDistributionList() method.
      Expected outcome is updation of status, substatus and comment fields on external distribution list.
    */
    static testMethod void  updateStatusPositiveTest(){
        User u = [Select id,Name,UserName from user where userName='ericssonTestLocalPublisher@test.com' LIMIT 1 ];
      
        string updatedComment='test updated comment';
        
        OC_AN_Bulletin__c recbulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c 
                                               WHERE Name = 'LocalBulletinTestClass' LIMIT 1 ];
        recbulletinRecord.OC_AN_Current_Status__c = OC_AN_Constants.Internally_Published_Status;
        update recbulletinRecord;
        
        OC_AN_Bulletin_Account_Product__c externalDistribution=[SELECT Id,OC_AN_Account__r.Name,OC_AN_Account__c,OC_AN_Status__c,
                                                              OC_AN_Sub_Status__c,OC_AN_Comments__c from
                                                              OC_AN_Bulletin_Account_Product__c
                                                              where OC_AN_Local_Bulletin__c ='' AND 
                                                              OC_AN_Bulletin__c =: recbulletinRecord.id AND RecordTypeId=: OC_AN_Constants.recTypeId_Account 
                                                              limit 1];
        
        string jsonResponse ='[{"Status":"'+ OC_AN_Constants.Under_Analysis_Status+'","SUBSTATUS":"'+OC_AN_Constants.Under_Analysis_SubStatus +'","textBoxValue":"' + updatedComment+'","accountName":"' + externalDistribution.OC_AN_Account__r.Name+'","accountID":"' + externalDistribution.OC_AN_Account__c+'","RecordId":"' +externalDistribution.id+'","createLBForAccountFlag":"false"}]';                                        
        
        System.runAs(u)
        {
            
            Test.startTest();
           	OC_AN_LocalBulletinCreationController.createLocalBulletin(jsonResponse,recbulletinRecord.id);
            Test.stopTest();
            OC_AN_Bulletin_Account_Product__c updatedRecord=[SELECT id,OC_AN_Status__c,OC_AN_Sub_Status__c,OC_AN_Comments__c FROM OC_AN_Bulletin_Account_Product__c WHERE id=:externalDistribution.id];
            system.assertEquals(OC_AN_Constants.Under_Analysis_Status, updatedRecord.OC_AN_Status__c);
            system.assertEquals(OC_AN_Constants.Under_Analysis_SubStatus , updatedRecord.OC_AN_Sub_Status__c);
            system.assertEquals(updatedComment, updatedRecord.OC_AN_Comments__c);
        }
    }

    /*This method is used to test negative scnenario of updateParentExternalDistributionList() method.
      Expected outcome is no updation of status, substatus and comment fields on external distribution list.
    */
    static testMethod void updateStatusNegativeTest(){
        User u = [Select id,Name,UserName from user where userName='ericssonTestLocalPublisher@test.com' LIMIT 1 ];
       
        string updatedComment='test updated comment';
        
        OC_AN_Bulletin__c recbulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c 
                                               WHERE Name = 'LocalBulletinTestClass' LIMIT 1 ];
        
        OC_AN_Bulletin_Account_Product__c externalDistribution=[SELECT Id,OC_AN_Account__r.Name,OC_AN_Account__c,OC_AN_Status__c,
                                                              OC_AN_Sub_Status__c,OC_AN_Comments__c from
                                                              OC_AN_Bulletin_Account_Product__c
                                                              where OC_AN_Local_Bulletin__c ='' AND 
                                                              OC_AN_Bulletin__c =: recbulletinRecord.id AND RecordTypeId=: OC_AN_Constants.recTypeId_Account 
                                                              limit 1];
        string jsonResponse ='[{"Status":"'+ OC_AN_Constants.Under_Analysis_Status+'","SUBSTATUS":"'+OC_AN_Constants.Under_Analysis_SubStatus +'","textBoxValue":"' + updatedComment+'","accountName":"' + externalDistribution.OC_AN_Account__r.Name+'","accountID":"' + externalDistribution.OC_AN_Account__c+'","RecordId":"' +externalDistribution.id+'","createLBForAccountFlag":"false"}]';                                        
        
        System.runAs(u)
        {
            string message;
            Test.startTest();
            try{
                message= OC_AN_LocalBulletinCreationController.createLocalBulletin(jsonResponse,recbulletinRecord.id);
            }catch(Exception ex){
                message='Error';
            }
            Test.stopTest();
            OC_AN_Bulletin_Account_Product__c updatedRecord=[SELECT id,OC_AN_Status__c,OC_AN_Sub_Status__c,OC_AN_Comments__c FROM OC_AN_Bulletin_Account_Product__c WHERE id=:externalDistribution.id];
            system.assertEquals('Error',message);
            system.assertNotEquals(OC_AN_Constants.Under_Analysis_Status, updatedRecord.OC_AN_Status__c);
            system.assertNotEquals(OC_AN_Constants.Under_Analysis_SubStatus , updatedRecord.OC_AN_Sub_Status__c);
            system.assertNotEquals(updatedComment, updatedRecord.OC_AN_Comments__c);
        }
    }
}