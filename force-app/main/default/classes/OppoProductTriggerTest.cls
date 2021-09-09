@isTest(seeAllData = false)
private class OppoProductTriggerTest{

    @isTest
    public static void test_validateOnDeletePOS(){
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User salesUser = (User)TestDataGenerator.createSObject(
            new User(ProfileId  = GlobalConstants.getProfileId(GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME), 
                UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
        System.runAs(integrationUser){
            try{
              insert acc;
            }
            catch(DmlException e){          
            }          
        }

        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;

        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        try{
          insert prod;
        }
        catch(DmlException e){          
        }
        

        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
         insert pricebookEntry;
        }
        catch(DmlException e){          
        }
        

        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
        System.runAs(salesUser){ 
            try{
                insert opp;
            }
            catch(DmlException e){          
            }
            
        }

        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id));
        try{
            insert oppLine;
        
            delete oppLine;
        }
        catch(DmlException e){          
        }
        
        
        List<OpportunityLineItem> oppLineList = [SELECT Id FROM OpportunityLineItem WHERE Id =:oppLine.Id];
        System.assertEquals(0, oppLineList.size());
    }

    @isTest
    public static void test_validateOnDeleteNEG(){
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User salesUser = (User)TestDataGenerator.createSObject(
            new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME), 
                UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
        System.runAs(integrationUser){  
            try{
                insert acc;
            }
            catch(DmlException e){          
            }
          
        }

        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;

        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        try{
            insert prod;
        }
        catch(DmlException e){          
        }
        

        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry;
        }
        catch(DmlException e){          
        }
        

        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
        System.runAs(salesUser){ 
            
            try{
                insert opp;
            }
            catch(DmlException e){          
            }
        }

        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id));
        System.runAs(salesUser){  
            try{
                insert oppLine;
            }
            catch(DmlException e){          
            }
            
        }

        System.runAs(salesUser){ 
            try{
                if(oppLine.id != null){
                    delete oppLine;
                }
            }catch(DmlException de){
                System.assert(de.getMessage().contains(GlobalConstants.Opportunity_Product_Delete_Validation_Error));
            }         
        }
    }
}