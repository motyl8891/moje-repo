@isTest
public class OC_TH_CommunityCaseCreationHandlerTest {
    
    @testsetup 
    static void setup(){
        List<Account> accList = new List<Account> ();
        List<Account> updateaccList = new List<Account> ();
        List<Contact> conList = new List<Contact> ();
        Asset asset = new Asset();
        Product2 product = new Product2();
        
        Id adminprofileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = adminprofileId;
        testuser.IsActive = true;
        insert testuser;
        
        System.runAs(testUser){   
            
            Account accSales = (Account)OC_TestDataGenerator.createSObject(new Account());
            
            accSales.Account_Type__c = 'Sales';
            accSales.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Account').getRecordTypeId();
            insert accSales;
            
            Account acc = (Account)OC_TestDataGenerator.createSObject(new Account());
            system.debug('here!!!!!');
       		 acc.Account_Type__c = 'Service';
             acc.ParentId = accSales.Id;
       		 acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Account').getRecordTypeId();
       		 insert acc;
            
            accList = OC_TestDataGenerator.createSObjectList(new Account(),1);
            accList[0].Account_Type__c = 'Subdivision';
            accList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Service Account').getRecordTypeId();
            accList[0].ParentID = acc.Id;
            conList = OC_TestDataGenerator.createSObjectList(new Contact(),2);
            asset = (Asset) OC_TestDataGenerator.createSObject(new Asset());
            asset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Node Type').getRecordTypeId();
            insert accList;
            product = (Product2) OC_TestDataGenerator.createSObject(new Product2());
            product.OC_MD_Product_type__c = 'Node Type';
            product.Product_Code_Number__c = 'Test';
            product.Name = 'Test';
            insert product;
            if(accList!=null && !accList.isEmpty() && conList!=null && !accList.isEmpty() && product!=null ){
                conList[0].AccountId = accList[0].Id;
                conList[1].AccountId = acc.Id;
                
                asset.AccountId = acc.Id;
                asset.Product2Id = product.Id;
                asset.name = 'Test Asset';
                updateaccList.add(accList[0]);
                // updateaccList.add(accList[1]);
                insert conList;
                insert asset;
                update updateaccList;
                system.assertEquals(conList.size(),2);
                system.assertEquals(accList.size(),1);
            } 
        }
    }
    
    @isTest 
    Static Void communityCaseCreationHandlerTest1(){
        List<User> userList = [SELECT id,Name,createddate,
                               isActive
                               FROM User WHERE isActive = true 
                               ORDER BY createddate LIMIT 1 ]; 
        
        List<Account> accountRecList = [ SELECT id,Name,ParentId,Visible__c FROM Account 
                                        WHERE Account_Type__c = 'Service'];
        List<Contact> ContactRecList = [ SELECT id,Name,AccountId FROM Contact ];
        List<Asset> assetRecList = [ SELECT id,Name,AccountId FROM Asset];
        
        Case caseToInsert = new Case();
        caseToInsert.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard CSR').getRecordTypeId();
        caseToInsert.AccountId = accountRecList[0].Id;
        caseToInsert.Priority = '9';
        caseToInsert.Subject = 'Test Class';
        caseToInsert.Type = '003';
        caseToInsert.ContactId = ContactRecList[0].Id;
        caseToInsert.OC_TH_Customer_Description__c = 'Test class Description';
        
        Test.startTest();
        
        system.runAs(userList[0]){
            OC_TH_CommunityCaseCreationHandler.saveCase(caseToInsert, assetRecList[0].Id);
            OC_TH_CommunityCaseCreationHandler.getAssets();
            OC_TH_CommunityCaseCreationHandler.getPriority();
            OC_TH_CommunityCaseCreationHandler.getType();
            OC_TH_CommunityCaseCreationHandler.getAccounts();
            OC_TH_CommunityCaseCreationHandler.getLICSRPermissionSet();
        } 
        Test.stopTest();
    } 
}