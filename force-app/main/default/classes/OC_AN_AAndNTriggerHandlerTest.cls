/**
* @File Name          : OC_AN_AAndNTriggerHandlerTest
* @Description        : Test Class for
*						OC_AN_AAndNTriggerHandler
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10              	IBM               Initial Version
**/

@isTest
public class OC_AN_AAndNTriggerHandlerTest {
    
    @testsetup 
    static void setup(){
        
        List<User> userListToInsert = new List<User>();
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<Group> listOfpublicGroup = new List<Group>();
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        List<OC_AN_Bulletin_Account_Product__c> listOfBullAccPrd = new List<OC_AN_Bulletin_Account_Product__c>();
        
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
            
             Group publicGroupToInsert = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert.Name = 'A&N - Test Group';
            listOfPublicGroup.add(publicGroupToInsert);
            if(!listOfPublicGroup.isEmpty()){
                insert listOfPublicGroup;
            }
            
            GroupMember groupMemberToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            groupMemberToInsert.GroupId = listOfPublicGroup[0].Id;
            groupMemberToInsert.UserOrGroupId = userListToInsert[0].Id;
            groupMemberListToInsert.add(groupMemberToInsert);
            if(!groupMemberListToInsert.isEmpty()){
                insert groupMemberListToInsert;
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
            
            OC_AN_Bulletin_Account_Product__c internalRecToInsert = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            internalRecToInsert.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
            internalRecToInsert.OC_AN_GroupId__c = listOfpublicGroup[0].Id;
            internalRecToInsert.OC_AN_Public_Group_Name__c = listOfpublicGroup[0].Name;
            internalRecToInsert.OC_AN_Bulletin__c = listOfBulletin[0].Id;
            listOfBullAccPrd.add(internalRecToInsert);
            if(!listOfBullAccPrd.isEmpty()){
                insert listOfBullAccPrd;
            }
        }
    }
    
    @isTest
    static void AAndNTriggerHandlerTestForDelete(){
        
        Test.startTest();
        List<OC_AN_Bulletin_Account_Product__c> listOfRectoDelete = [SELECT Id,OC_AN_Bulletin__r.OC_AN_Current_Status__C From OC_AN_Bulletin_Account_Product__c
                                                                     WHERE RecordTypeId =: OC_AN_Constants.recTypeId_PublicGroup
                                                                     AND OC_AN_Public_Group_Name__c = 'A&N - Test Group' LIMIT 1];
        
        
        Database.DeleteResult[] deleteList = Database.delete(listOfRectoDelete);
        Test.stopTest();
        for(Database.DeleteResult dr : deleteList){
            system.assert(dr.isSuccess());
        }
        
    }
    
    @isTest
    static void AAndNTriggerHandlerDeleteNotAllowed(){
        
        Test.startTest();
        List<Group> retreievedGroups = [SELECT Id,Name From Group];
        
        List<OC_AN_Bulletin__c> listToUpdate = new List<OC_AN_Bulletin__c>();
        for(OC_AN_Bulletin__c bulletin : [SELECT Id,OC_AN_Current_Status__c 
                                          FROM OC_AN_Bulletin__C WHERE Name Like '%Test%']){
                                              bulletin.OC_AN_Current_Status__c = 'Internally Published';
                                              listToUpdate.add(bulletin);
                                          }
        update listToUpdate; 
        
        OC_AN_Bulletin_Account_Product__c internalRecToInsert1 = new OC_AN_Bulletin_Account_Product__c();
        internalRecToInsert1.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
        internalRecToInsert1.OC_AN_GroupId__c = retreievedGroups[0].Id;
        internalRecToInsert1.OC_AN_Public_Group_Name__c = retreievedGroups[0].Name + 'App';
        internalRecToInsert1.OC_AN_Bulletin__c = listToUpdate[0].Id;
        insert internalRecToInsert1;
        
        
        
        List<OC_AN_Bulletin_Account_Product__c> listOfRectoDelete1 = [SELECT Id,OC_AN_Bulletin__r.OC_AN_Current_Status__C From OC_AN_Bulletin_Account_Product__c
                                                                      WHERE RecordTypeId =: OC_AN_Constants.recTypeId_PublicGroup
                                                                      AND OC_AN_Public_Group_Name__c Like '%App%' LIMIT 1];
        
       Exception expectedException;
        
        try{
            delete listOfRectoDelete1; 
        }catch(Exception e){
         expectedException = e;
        }
        Test.stopTest();

        system.assert(expectedException != null);
    }
}