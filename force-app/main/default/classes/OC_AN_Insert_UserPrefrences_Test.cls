/**
* @File Name          : OC_AN_Insert_UserPrefrences_Test
* @Description        : Test Class for OC_AN_Insert_UserPrefrences_Test
*                       U-2758 Alerts & Notification: Creation of User Prefrences.
* @Author             : IBM
* @Group              : 
* @Created Date       : 11th June 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-06-11             	IBM               Initial Version
*/


@isTest
public class OC_AN_Insert_UserPrefrences_Test {
    
    @testsetup 
    static void setup(){
        
        List<Account> accList       = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList       = new List<Contact> ();
        List<String> ProdList       = new List<String>();
        OC_MD_ProductAttributes__c release1 = new OC_MD_ProductAttributes__c ();
        OC_MD_ProductAttributes__c release2 = new OC_MD_ProductAttributes__c ();
        OC_MD_ProductAttributes__c version1 = new OC_MD_ProductAttributes__c ();
        OC_MD_ProductAttributes__c version2 = new OC_MD_ProductAttributes__c ();
        
        
        Id migrationProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericssontestuserpreferences@test.com';
        testuser.ProfileId = migrationProfileId;
        testuser.IsActive = true;
        insert testuser;
        
        Id productNodeRTId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('OC_MD_Node_Type').getRecordTypeId();
        
        
        System.runAs(testuser){
            
            ContentVersion contentVersion_1 = new ContentVersion(
                Title = Label.OC_AN_UserPrefrencesSampleFile,
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content')
            );
            insert contentVersion_1;
            
            Product2 productRec = (Product2) OC_TestDataGenerator.createSObject(
                new Product2(IsActive = true,Name = 'Test Product 00001',RecordTypeId = productNodeRTId));  
            insert productRec;
            
            Product2 productRec2 = (Product2) OC_TestDataGenerator.createSObject(
                new Product2(IsActive = true,Name = 'Test Product 00002',RecordTypeId = productNodeRTId));       
            insert productRec2;
            
            release1 = new OC_MD_ProductAttributes__c(OC_MD_Product__c = productRec.Id,Name = 'Release 1', 
                                                      RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release);
            insert release1;
            release2 = new OC_MD_ProductAttributes__c(OC_MD_Product__c = productRec2.Id,Name = 'Release 2', 
                                                      RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release);
            version1 = new OC_MD_ProductAttributes__c(OC_MD_Parent__c = release1.Id,Name = 'Version 1', 
                                                      RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Release);  
            insert version1;
            version2 = new OC_MD_ProductAttributes__c(OC_MD_Parent__c = release2.Id,Name = 'Version 2', 
                                                      RecordTypeId = OC_AN_Constants.recTypeId_PrdAttribute_Version);
            
            ProdList.add(productRec.Name);
            
            
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            accSales.Account_Type__c = OC_AN_Constants.sales;
            accSales.RecordTypeId = OC_AN_Constants.recTypeId_forSalesAccount;
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
        }
        
    }
    
    @isTest()
    static void insertUserPreferenceTest1(){
        
        List<String> userNameList   = new List<String>();
        List<String> EmailNameList  = new List<String>();
        
        List<OC_AN_User_Preferences__c> UserPreList = new List<OC_AN_User_Preferences__c>();
        List<OC_AN_User_Preferences__c> UserPreList1 = new List<OC_AN_User_Preferences__c>();
        
        User recUser = [Select id,Name,UserName from user where userName='ericssontestuserpreferences@test.com' LIMIT 1 ];
        
        userNameList.add(recUser.UserName);
        
        
        List<Product2> recProdList = [SELECT Id FROM Product2 
                                      WHERE Name = 'Test Product 00001' 
                                      OR Name  = 'Test Product 00002'];
        
        List<OC_MD_ProductAttributes__c> recReleaseList = [SELECT Id FROM OC_MD_ProductAttributes__c
                                                           WHERE Name = 'Release 1' ];
        List<OC_MD_ProductAttributes__c> recVersionList = [SELECT Id FROM OC_MD_ProductAttributes__c
                                                           WHERE Name = 'Version 1' ];
        
        for(Contact con : [SELECT Id,Name,Email FROM Contact]){
            EmailNameList.add(con.Email);
        }
        
        OC_AN_User_Preferences__c UserPre = (OC_AN_User_Preferences__c)OC_TestDataGenerator.createSObject(new OC_AN_User_Preferences__c()); 
        UserPre.Name ='Bulletin 1';
        userPre.RecordTypeId = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Bulletin_Setting').getRecordTypeId();
        UserPre.OC_AN_Email__c= FALSE; 
        UserPre.OC_AN_Notification_Panel__c=FALSE;
        UserPre.OC_AN_User__c=recUser.Id;
        UserPreList.add(UserPre);
        
        OC_AN_User_Preferences__c UserPre1 = (OC_AN_User_Preferences__c)OC_TestDataGenerator.createSObject(new OC_AN_User_Preferences__c());
        UserPre1.Name ='Bulletin 123';
        UserPre1.RecordTypeId = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Bulletin_Setting').getRecordTypeId();
        UserPre1.OC_AN_Email__c= true; 
        UserPre1.OC_AN_Notification_Panel__c=FALSE;
        UserPre1.OC_AN_User__c=recUser.Id;
        UserPreList.add(UserPre1);
        
        OC_AN_User_Preferences__c UserPre2 = (OC_AN_User_Preferences__c)OC_TestDataGenerator.createSObject(new OC_AN_User_Preferences__c());
        UserPre2.Name ='Bulletin 123';
        UserPre2.RecordTypeId = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Bulletin_Setting').getRecordTypeId();
        UserPre2.OC_AN_Email__c= true; 
        UserPre2.OC_AN_Notification_Panel__c=FALSE;
        UserPre2.OC_AN_User__c=recUser.Id;
        UserPreList.add(UserPre2);
        
        OC_AN_User_Preferences__c UserPre3 = (OC_AN_User_Preferences__c)OC_TestDataGenerator.createSObject(new OC_AN_User_Preferences__c());
        UserPre3.Name ='Product 123';
        UserPre3.RecordTypeId = Schema.SObjectType.OC_AN_User_Preferences__c.getRecordTypeInfosByDeveloperName().get('Product_Setting').getRecordTypeId();
        UserPre3.OC_AN_Email__c= true; 
        UserPre3.OC_AN_Notification_Panel__c=FALSE;
        UserPre3.OC_AN_Product__c = recProdList[0].Id;  //Id.valueof
        UserPre3.OC_AN_Version__c = recVersionList[0].Id;
        UserPre3.OC_AN_ProductAttribute__c = recReleaseList[0].Id;
        UserPre3.OC_AN_User__c=recUser.Id;
        UserPreList1.add(UserPre3);
        UserPreList.add(UserPre3);
        
        if(!UserPreList.isEmpty()){
            Database.insert(UserPreList,false);
        }
        
        string header = 'Name , Email, Notification Panel, Preference Type  \n';
        string finalstr = header ;
        for(OC_AN_User_Preferences__c us: UserPreList)
        {
            string recordString = us.Name+','+us.OC_AN_Email__c+','+us.OC_AN_Notification_Panel__c +','+us.RecordType.Name+'\n';
            finalstr = finalstr +recordString;
            
        }
        
        String createPreference ;
        Map<String,String> recMetadata = new Map<String,String>();
        Map<String,String> recRecordTypeIds = new Map<String,String>();
        Map<String,String> recUserRecIds = new Map<String,String>();
        Map<String,String> recContactRecIds = new Map<String,String>();
        
        Test.startTest();
        createPreference = OC_AN_Insert_UserPrefrences.createUsrPrefRecord(UserPreList);
        recMetadata = OC_AN_Insert_UserPrefrences.get_MetaDataOfAN();
        recRecordTypeIds = OC_AN_Insert_UserPrefrences.get_RecordTypeIds();
        recUserRecIds = OC_AN_Insert_UserPrefrences.getUserIdsRecs(userNameList);
        recContactRecIds = OC_AN_Insert_UserPrefrences.getcontactIdsRecs(EmailNameList);
        OC_AN_Insert_UserPrefrences.sendEmailToController(finalstr);
        Test.stopTest();
        
        system.assert(createPreference != '' || createPreference != null);
        system.assert(!recMetadata.isEmpty());
        system.assert(!recUserRecIds.isEmpty());
        system.assert(!recRecordTypeIds.isEmpty());
        system.assert(!recContactRecIds.isEmpty());
        
        
    }
    
}