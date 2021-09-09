@isTest
public class OC_AN_ExtDistributionSummaryListTest {

    
	@testsetup 
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
        
        System.runAs(testUser)
        {   
            
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
            
            OC_AN_Bulletin__c localBulletin = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            localBulletin.OC_AN_Parent_Bulletin__c = bulletinListToInsert[0].Id;
            localBulletin.Name = 'Test Local Bulletin';
            localBulletin.OC_AN_Bulletin_Template__c = bulletinTemplatelist[0].Id;
            insert localBulletin;
           
        }
    }
    
    @isTest
    public static void testgetExternalDistributionListSummary1(){
        List<OC_An_Bulletin__c> bulletinList = [SELECT Id From OC_AN_Bulletin__c Where 
                                               Name = 'Test Local Bulletin'];
        
        List<Contact> contactList = new List<Contact>();
        
        if(!bulletinList.isEmpty()){
            Test.startTest();
            contactList = OC_AN_ExtlDistributionSummaryListCtr.getExternalDistributionListSummary(bulletinList[0].Id);
            Test.stopTest();
        }
        
        system.assert(contactList.isEmpty());
        
    }
    
    
}