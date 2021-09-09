@isTest
public class OC_AN_FetchExternalDistributionLIstTest {

    
  /*  
    @testSetup
    static void setup(){
        List<Account> accList = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList = new List<Contact> ();
        List<OC_AN_Bulletin_Template__c> bulletinTemplatelist = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> bulletinListToInsert = new List<OC_AN_Bulletin__c>();
        Id migrationProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationProfileId;
        testuser.IsActive = true;
        insert testuser;
        System.runAs(testUser){   
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
            bulletinTemplatelist.add(bulletinTemplateToInsert);
            if(!bulletinTemplatelist.isEmpty()){
                insert bulletinTemplatelist;
            }
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.OC_AN_Bulletin_Template__c = bulletinTemplatelist[0].Id;
            bulletinListToInsert.add(bulletinToInsert);
            if(!bulletinListToInsert.isEmpty()){
                insert bulletinListToInsert ;
                
                
            }   
            OC_AN_Bulletin_Account_Product__c AccountProductRecord = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            AccountProductRecord.OC_AN_Account__c =accList[0].Id;
            AccountProductRecord.OC_AN_Status__c ='Hold';
            AccountProductRecord.OC_AN_Sub_Status__c ='Message Applicable, but I want to modify';
            AccountProductRecord.OC_AN_Comments__c ='Test';
            AccountProductRecord.OC_AN_Bulletin__c =  bulletinListToInsert[0].Id;
            system.debug('AccountProductRecord >>'+ AccountProductRecord);
            insert AccountProductRecord;
            
            OC_AN_Group_Member__c localPublisherForAccount = new OC_AN_Group_Member__c();
            localPublisherForAccount.RecordTypeId = Schema.SObjectType.OC_AN_Group_Member__c.getRecordTypeInfosByDeveloperName().get('Local_Publisher').getRecordTypeId();
            localPublisherForAccount.Account__c = accList[0].Id;
            localPublisherForAccount.User__c = testUser.Id;
            localPublisherForAccount.Local_Publisher__c = true;
            
            insert localPublisherForAccount;
            
            
        }
        
    }
    
    @isTest
    static void FetchExtDisListTest1(){
        
        List<User> recUserList = [SELECT Id,Name From User
                                 WHERE UserName Like 'ericsson@test.com%'];
        
        system.debug('recUserList===>'+recUserList);
        
        List<OC_AN_Bulletin__C> recBulletinList = [Select Id FROM OC_AN_Bulletin__C];
        
        system.runAs(recUserList[0]){
            List<OC_AN_Bulletin_Account_Product__c> recBAPRecords = OC_AN_FetchExtenalDistributionList.FetchExtDisList(recBulletinList[0].Id);
            system.assert(!recBAPRecords.isEmpty());
        }
        
        
    }*/
    
}