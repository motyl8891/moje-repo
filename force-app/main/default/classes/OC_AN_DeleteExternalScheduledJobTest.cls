/**
 * @File Name          : OC_AN_DeleteExternalScheduledJobTest
 * @Description        : Abort the scheduled job when bulletin is marked as invalid
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 8th Jun 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-06-07                 IBM                   Initial Version
 **/

@isTest
public class OC_AN_DeleteExternalScheduledJobTest {
    
    @testsetup 
    static void setup(){
        List<User> userListToInsert = new List<User>();
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<Group> listOfPublicGroup = new List<Group>();
        
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        
        System.runAs(testUser){
            
            OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
            listOfBulletinTemplate.add(bulletinTemplateToInsert);
            if(!listOfBulletinTemplate.isEmpty()){
                insert listOfBulletinTemplate;
            }
            
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            bulletinToInsert.OC_AN_Delay__c = 1 ;
            listOfBulletin.add(bulletinToInsert);
            if(!listOfBulletin.isEmpty()){
                insert listOfBulletin ;
            }   
            
        } 
        
    }
    
    
    @isTest
    static void deleteScheduledTest1(){
        
        List<Id> bulletinIdList = new List<Id>();
        Map<String,String> argumentsMap = new Map<String,String>();
        
        for(OC_AN_Bulletin__c oc : [SELECT Id FROM OC_AN_Bulletin__c]){
            bulletinIdList.add(oc.Id);
        }
        
        argumentsMap.put(OC_AN_HandleCalloutWhenBulletinApproved.BULLETIN_ID,bulletinIdList[0]);
        
        Test.startTest();
        OC_AN_ExternalAutomationScheduler sh1 = new OC_AN_ExternalAutomationScheduler(argumentsMap);
        
        String cronExpression = '0 0 23 * * ?'; 
        
        system.schedule('OC_AN_Ex'+bulletinIdList[0], cronExpression, sh1); 
        OC_AN_DeleteExternalScheduledJob.deleteScheduled(bulletinIdList);
        Test.stopTest();
    }

}