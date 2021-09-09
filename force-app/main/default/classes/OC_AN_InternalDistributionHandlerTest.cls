/**
* @File Name          : OC_AN_InternalDistributionHandlerTest
* @Description        : Test Class for
*						OC_AN_InternalDistributionHandler
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April 2021
* @Modification Log   : Updated as a part of US-2900
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10              	IBM               Initial Version
* 1.1        2021-05-29                 IBM				  US-2900
**/

@isTest
public class OC_AN_InternalDistributionHandlerTest {
    
    @testsetup 
    static void setup(){
        
        List<User> userListToInsert = new List<User>();
        List<OC_AN_Public_Group__c> publicGroupList = new List<OC_AN_Public_Group__c>();
 
        
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        
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
            
            
            OC_AN_Public_Group__c pgToInsert = (OC_AN_Public_Group__c)OC_TestDataGenerator.createSObject(new OC_AN_Public_Group__c());
            pgToInsert.Name = 'Public Group 1';
            publicGroupList.add(pgToInsert);
            
            if(!publicGroupList.isEmpty()){
                insert publicGroupList;
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
        
        List<Id> groupIdList = new List<Id>();
        
        for(OC_AN_Public_Group__c gp : [SELECT Id, Name FROM OC_AN_Public_Group__c
                        WHERE Name = 'Public Group 1']){
                            groupIdList.add(gp.id);
                        }
        
        
        List<String> userRoleList = new List<String>();
        userRoleList.add('Author');
        userRoleList.add('SDM');
        
        List<OC_AN_Public_Group__c> recGroupList;
        List<OC_AN_Public_Group__c> recGroupListWithSeach;
        List<String> recRolesList;
        Integer groupsCount;
        
        Test.startTest();
        System.runAs(userList[0]){
            groupsCount = OC_AN_InternalDistributionHandler.getCountOfGroups();
            recGroupList = OC_AN_InternalDistributionHandler.getPublicGroups(1,1,'');
            recGroupListWithSeach = OC_AN_InternalDistributionHandler.getPublicGroups(1,1,'Public');
            recRolesList= OC_AN_InternalDistributionHandler.getRolesForAN();
            OC_AN_InternalDistributionHandler.associateInternalDistributionToBulletin(groupIdList,recbulletinRecord.Id,null);
            OC_AN_InternalDistributionHandler.associateInternalDistributionToBulletin(groupIdList,recbulletinRecord.Id,userRoleList);
            
        }
        Test.stopTest();
        system.assertEquals(groupsCount, 1);
        system.assert(!recGroupList.isEmpty());
        system.assert(!recGroupListWithSeach.isEmpty());
        system.assert(!recRolesList.isEmpty());
        
    }
    
}