/**
* @File Name          : OC_AN_BulletinTriggerHandlerTest
* @Description        : Test Class for 
*			            OC_AN_BulletinTriggerHandler
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 03rd May 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-03              	IBM               Initial Version
**/

@isTest
public class OC_AN_BulletinTriggerHandlerTest 
{
    @testsetup 
    static void setup(){
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        
    }    
    @isTest
    static void BulletinTriggerHandlerTestt1(){
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        Test.startTest();
        OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
        listOfBulletinTemplate.add(bulletinTemplateToInsert);
        if(!listOfBulletinTemplate.isEmpty()){
            insert listOfBulletinTemplate;            
        }
        
        OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
        bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
        listOfBulletin.add(bulletinToInsert);
        
        OC_AN_Bulletin__c bulletinToInsert2 = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
        bulletinToInsert2.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
        listOfBulletin.add(bulletinToInsert2);
        
        
        Id BulletinrecTypeId = Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Bulletin').getRecordTypeId();
        OC_AN_Bulletin_Template__c BullTemp = new OC_AN_Bulletin_Template__c();
        BullTemp.Name='Test Template';
        insert BullTemp;
        
        OC_AN_Bulletin__c BullRecord = new OC_AN_Bulletin__c();
        BullRecord.Name='TestDemonstrate';
        BullRecord.OC_AN_Bulletin_Template__c= BullTemp.Id;
        BullRecord.recordTypeId =BulletinrecTypeId;
        system.debug('BullRecord >>'+ BullRecord);
        insert BullRecord;
        
        Id LocalBulletinrecTypeId = Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName().get('OC_AN_Local_Bulletin').getRecordTypeId();
        OC_AN_Bulletin__c LocalBullRecord = new OC_AN_Bulletin__c();
        LocalBullRecord.Name='TestDemonstrate';
        LocalBullRecord.OC_AN_Bulletin_Template__c= BullTemp.Id;
        LocalBullRecord.recordTypeId =LocalBulletinrecTypeId;
        LocalBullRecord.OC_AN_Parent_Bulletin__c = BullRecord.Id;
        system.debug('LocalBullRecord >>'+ LocalBullRecord);
        insert LocalBullRecord;
        
        
        
        if(!listOfBulletin.isEmpty()){
            Database.SaveResult[] srList = database.insert(listOfBulletin) ;
            for(Database.SaveResult sr : srList){
                system.assert(sr.isSuccess());
            }
        } 
        Test.stopTest();
        
        
    }
    @isTest
    static void BulletinTriggerHandlerTest2(){
        Map<Id,OC_AN_Bulletin__c> newItems = new Map<Id,OC_AN_Bulletin__c>();
        Map<Id,OC_AN_Bulletin__c> oldItems =  new Map<Id,OC_AN_Bulletin__c>();
        OC_AN_BulletinTriggerHandler emptyMethodTest = new OC_AN_BulletinTriggerHandler();
        emptyMethodTest.BeforeDelete(oldItems);
        emptyMethodTest.AfterDelete(oldItems);
        emptyMethodTest.AfterUnDelete(oldItems);
        emptyMethodTest.BeforeUpdate(newItems,oldItems);
        emptyMethodTest.AfterUpdate(newItems,oldItems);
    }
    
}