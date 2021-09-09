/**
* @File Name          : OC_AN_UtilityTest
* @Description        : Test Class for
*						OC_AN_Utility
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
public class OC_AN_UtilityTest {
    
    @testsetup 
    static void setup(){
        
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        
        Id systemAdminId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        User userWithTechRoleForAandN = (User)OC_TestDataGenerator.createSObject(new User());
        userWithTechRoleForAandN.UserName = 'techuserforAandN@test.com'+System.currentTimeMillis();
        userWithTechRoleForAandN.ProfileId = systemAdminId;
        userWithTechRoleForAandN.IsActive = true;
        userWithTechRoleForAandN.OC_AN_UserRoleForAlertsAndNotifications__c = 'Technical Reviewer';
        
        insert userWithTechRoleForAandN;
        
        Id systemAdmin2Id = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        
        User userWithEditorRoleForAandN = (User)OC_TestDataGenerator.createSObject(new User());
        userWithEditorRoleForAandN.UserName = 'editoruserforAandN@test.com'+System.currentTimeMillis();
        userWithEditorRoleForAandN.ProfileId = systemAdmin2Id;
        userWithEditorRoleForAandN.IsActive = true;
        userWithEditorRoleForAandN.OC_AN_UserRoleForAlertsAndNotifications__c = 'Editorial Reviewer';
        
        insert userWithEditorRoleForAandN;
        
        
        
        System.runAs(testUser){
            OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
            listOfBulletinTemplate.add(bulletinTemplateToInsert);
            if(!listOfBulletinTemplate.isEmpty()){
                insert listOfBulletinTemplate;
            }
            
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            
            OC_AN_Bulletin__c bulletinToInsert1 = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert1.Name = 'Test Technical Bulletin';
            bulletinToInsert1.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            bulletinToInsert1.OC_AN_Current_Status__c = OC_AN_Constants.INTECHNICALREVIEW;
            bulletinToInsert1.OC_AN_Technical_Reviewer__c = userWithTechRoleForAandN.Id;
            
            OC_AN_Bulletin__c bulletinToInsert2 = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert2.Name = 'Test Editorial Bulletin';
            bulletinToInsert2.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            bulletinToInsert2.OC_AN_Current_Status__c = OC_AN_Constants.INEDITORIALREVIEW;
            bulletinToInsert2.OC_AN_Editorial_Review__c = userWithEditorRoleForAandN.Id;
            
            listOfBulletin.add(bulletinToInsert);
            listOfBulletin.add(bulletinToInsert1);
            listOfBulletin.add(bulletinToInsert2);
            if(!listOfBulletin.isEmpty()){
                insert listOfBulletin ;
            }
        } 
   
    }
    
    @isTest
    static void utilityTest(){
        
        List<OC_AN_Bulletin__c> recBulletinList = [SELECT Id FROM OC_AN_Bulletin__c];
        
        List<User> techUserList = [SELECT id,Name,createddate,
                                   isActive
                                   FROM User WHERE isActive = true
                                   AND Username Like '%techuserforAandN@test.com%' 
                                   ORDER BY createddate LIMIT 1 ]; 
        
        
        List<User> editorUserList = [SELECT id,Name,createddate,
                                     isActive
                                     FROM User WHERE isActive = true
                                     AND Username Like '%editoruserforAandN@test.com%' 
                                     ORDER BY createddate LIMIT 1 ]; 
        
        String currentStatusAsDraft;
        
        Test.startTest();
        System.runAs(editorUserList[0]){
            currentStatusAsDraft = OC_AN_Utility.verifyBulletinStatusAndRecordEditability(recBulletinList[2].Id);
            system.assertEquals(currentStatusAsDraft, OC_AN_Constants.DRAFT);
        }
        
        System.runAs(techUserList[0]){
           currentStatusAsDraft =  OC_AN_Utility.verifyBulletinStatusAndRecordEditability(recBulletinList[0].Id);
            system.assertEquals(currentStatusAsDraft, OC_AN_Constants.DRAFT);
           currentStatusAsDraft =  OC_AN_Utility.verifyBulletinStatusAndRecordEditability(recBulletinList[1].Id);
            
        }
        Test.stopTest();
        system.assertEquals(currentStatusAsDraft, OC_AN_Constants.DRAFT);
    }
    
}