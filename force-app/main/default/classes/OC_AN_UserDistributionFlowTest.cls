/**
* @File Name          : OC_AN_UserDistributionFlowTest
* @Description        : Test Class for
*						OC_AN_UserDistributionFlow
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 18th May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-18              	IBM               Initial Version
**/

@isTest
public class OC_AN_UserDistributionFlowTest {
    
    @testsetup 
    static void setup(){
        
        List<User> userListToInsert = new List<User>();
        List<Product2> productList = new List<Product2>();
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<Group> listOfPublicGroup = new List<Group>();
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        List<Account> accList = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList = new List<Contact> ();
        List<OC_AN_Bulletin_Account_Product__c> bulletinAccountProdcutList = new List<OC_AN_Bulletin_Account_Product__c>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        
        System.runAs(testUser){
            Id serviceProfileId = [SELECT Id FROM Profile WHERE Name = 'Ericsson Service'].Id;
            
            User serviceUser = (User)OC_TestDataGenerator.createSObject(new User());
            serviceUser.ProfileId = serviceProfileId;
            serviceUser.IsActive = true;
            userListToInsert.add(serviceUser);
            if(!userListToInsert.isEmpty()){
                insert userListToInsert;
            }
            
            for(Integer i=0;i<5;i++){
                Product2 product = (Product2) OC_TestDataGenerator.createSObject(new Product2());
                product.OC_MD_Product_type__c = OC_AN_Constants.PRODUCT_TYPE;
                product.Product_Code_Number__c = 'P'+i;
                product.Name = 'Test'+i;
                productList.add(product);  
            }
            insert productList;
            
            OC_MD_ProductAttributes__c releaseRecord = new OC_MD_ProductAttributes__c();
            releaseRecord.RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release;
            releaseRecord.Name = 'Release 1';
            releaseRecord.OC_MD_Product__c = productList[0].Id;
            insert releaseRecord;
            
            OC_MD_ProductAttributes__c versionRecord = new OC_MD_ProductAttributes__c();
            versionRecord.RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Version;
            versionRecord.Name = 'Version 1';
            versionRecord.OC_MD_Parent__c = releaseRecord.Id;
            insert versionRecord;
            
            Group publicGroupToInsert = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert.Name = 'A&N - Test Group';
            listOfPublicGroup.add(publicGroupToInsert);
            
            
            if(!listOfPublicGroup.isEmpty()){
                insert listOfPublicGroup;
            }            
            Group publicGroupToInsert2 = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert2.Name = 'A&N - Test Group2';
            insert publicGroupToInsert2;
            
            GroupMember groupMemberToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            groupMemberToInsert.GroupId = listOfPublicGroup[0].Id;
            groupMemberToInsert.UserOrGroupId = userListToInsert[0].Id;
            groupMemberListToInsert.add(groupMemberToInsert);
            
            GroupMember internalGroupToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            internalGroupToInsert.GroupId = listOfPublicGroup[0].Id;
            internalGroupToInsert.UserOrGroupId = publicGroupToInsert2.Id;
            groupMemberListToInsert.add(internalGroupToInsert);
            
            if(!groupMemberListToInsert.isEmpty()){
                insert groupMemberListToInsert;
            }
            
            
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
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
            
            
            OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
            listOfBulletinTemplate.add(bulletinTemplateToInsert);
            if(!listOfBulletinTemplate.isEmpty()){
                insert listOfBulletinTemplate;
            }
            
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            listOfBulletin.add(bulletinToInsert);
            if(!listOfBulletin.isEmpty()){
                insert listOfBulletin ;
            }
            
            
            OC_AN_Bulletin_Account_Product__c accountProduct = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            accountProduct.RecordTypeId = OC_AN_Constants.recTypeId_Account;
            accountProduct.OC_AN_Account__c = acc.Id;
            accountProduct.OC_AN_Bulletin__c = listOfBulletin[0].Id;
            bulletinAccountProdcutList.add(accountProduct);
            
            
            OC_AN_Bulletin_Account_Product__c publicGroupRecord = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            publicGroupRecord.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
            publicGroupRecord.OC_AN_Public_Group_Name__c = listOfPublicGroup[0].Name;
            publicGroupRecord.OC_AN_GroupId__c = listOfPublicGroup[0].Id;
            publicGroupRecord.OC_AN_Bulletin__c = listOfBulletin[0].Id;
            bulletinAccountProdcutList.add(publicGroupRecord);
            
            
            OC_AN_Bulletin_Account_Product__c productRecord = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            productRecord.RecordTypeId = OC_AN_Constants.recTypeId_AccPrdForBulletin_Product;
            productRecord.OC_AN_Product__c = productList[0].Id;
            productRecord.OC_AN_Release__c = releaseRecord.Id;
            productRecord.OC_AN_Verison__c = versionRecord.Id;
            productRecord.OC_AN_Bulletin__c = listOfBulletin[0].Id;
            bulletinAccountProdcutList.add(productRecord);
            
            if(!bulletinAccountProdcutList.isEmpty()){
                insert bulletinAccountProdcutList ;
            }
            
        } 
    }
    
    @isTest
    static void getCountOfGroupstest(){
        List<User> userList = [SELECT id,Name,createddate,
                               isActive
                               FROM User WHERE isActive = true
                               AND Profile.Name = 'Migration User Profile'
                               ORDER BY createddate LIMIT 1 ]; 
        
        OC_AN_Bulletin__c recbulletinRecord = [SELECT Id FROM OC_AN_Bulletin__c 
                                               WHERE Name = 'Test Bulletin' LIMIT 1 ];
        
        Test.startTest();
        System.runAs(userList[0]){
            
            OC_AN_UserDistributionFlow.getInternalUsersForBulletin(recbulletinRecord.Id);
            OC_AN_UserDistributionFlow.getExternalUsersForBulletin(recbulletinRecord.Id);
            OC_AN_MC_Callout_DataExt_Body.dataExtensionJson(recbulletinRecord.Id);
        }
        Test.stopTest();
        
    }
    
}