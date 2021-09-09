@isTest(seeAllData = false) 
private class PartnerAccountControllerTest {
    
    static testmethod void getPartnerAccounttest(){
         List<Account> accounts = new List<Account>();
        List<Partnership__c> accountPartners = new List<Partnership__c>();
 for (Integer count = 0; count < 50; count++) {
        accounts.add(new Account (Name = 'Jack'+count,Is_Partner__c=TRUE));
     accountPartners.add(new Partnership__c (Name = 'Test Jack Patner',Ericsson_Organization_Ownership__c = 'BA Networks'));
    }
    User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
         //acc.CurrencyIsoCode ='USD';
         System.runAs(testUser){  
             
            insert accounts;
             insert accountPartners;
        }
         Test.startTest();
      PartnerAccountController.getPartnerAccount();
        PartnerAccountController.getPartnership(accounts[0]);
    Test.stopTest();
    Account acc = [select Account_Type__c,Is_Partner__c from Account LIMIT 1];
       System.assertEquals(acc.Is_Partner__c,TRUE);
        
        Partnership__c accPartners = [select Ericsson_Organization_Ownership__c from Partnership__c LIMIT 1];
       System.assertEquals(accPartners.Ericsson_Organization_Ownership__c,'BA Networks');

    }

}