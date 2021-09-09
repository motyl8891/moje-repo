@isTest
public class OC_AN_DistributionSummaryControllerTest {


    @testsetup 
    static void setup(){

        List<Account> accList = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<OC_AN_Bulletin_Template__c> bulletinTemplatelist = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> bulletinListToInsert = new List<OC_AN_Bulletin__c>();
        List<Contact> conList = new List<Contact> ();

        Id migrationProfileId = [SELECT Id FROM Profile WHERE Name ='Migration User Profile'].Id;
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.FirstName=OC_AN_Constants.FirstName;
        testuser.ProfileId = migrationProfileId;
        testuser.IsActive = true;
        insert testuser;

        System.runAs(testUser){   
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
                insert bulletinListToInsert;
            }   


            OC_AN_Bulletin_Account_Product__c AccountProductRecord = (OC_AN_Bulletin_Account_Product__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Account_Product__c());
            AccountProductRecord.OC_AN_Account__c = accList[0].Id;
            AccountProductRecord.OC_AN_Status__c = OC_AN_Constants.OC_AN_External_Distribution_List_Status;
            //AccountProductRecord.OC_AN_Sub_Status__c = OC_AN_Constants.SUBSTATUS_VALUE;
            AccountProductRecord.OC_AN_Comments__c = OC_AN_Constants.comments;
            AccountProductRecord.OC_AN_Bulletin__c =  bulletinListToInsert[0].Id;
            system.debug('AccountProductRecord >>'+ AccountProductRecord);
            insert AccountProductRecord;

        }
    }


    @isTest
    static void getDistributionSummaryDataTest() {
        User u = [Select id,Name from user where FirstName=:OC_AN_Constants.FirstName LIMIT 1 ];

        List<OC_AN_Bulletin__c> bulletinRec=[Select id from OC_AN_Bulletin__c];
        
        System.runAs(u)
        { 
            Test.startTest();
            //String bulletinId, Boolean isExternal
            List<OC_AN_UserAndContactsWrapper> actual = OC_AN_DistributionSummaryController.getDistributionSummaryData(bulletinRec[0].id, true);
            OC_AN_DistributionSummaryController.getDistributionSummaryData(bulletinRec[0].id, false);

            System.debug(actual);

            Test.stopTest();
            
            System.assertEquals('Test Account 0', actual[0].accName, 'Success');
        }
        
    }
}