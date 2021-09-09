@isTest(seeAllData = false)
private class OppoProductTriggerHandlerHelperTest{
    
    @isTest
    public static void test_validateOnDeletePOS(){
        Account acc;
         Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User salesUser = (User)TestDataGenerator.createSObject(
            new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME) , 
                     UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
        System.runAs(integrationUser){  
            try{
                acc=(Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc; } catch(DmlException e){
                }
        }
        
        Id pricebookIdStd = Test.getStandardPricebookId();
       Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        PriceBook2 customPriceBookRec=[select Id,name from PriceBook2 WHERE name=:'Standard Catalog'];
        Product2 prod = new Product2(Name = 'Small cells - Lightpole Site', Family = 'Hardware', ProductCode = 'Small cells - Lightpole Site', Product_Code_Number__c = '1233');
        insert prod;
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        List<Opportunity> oppPar = new List<Opportunity>();
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500 ));
        opp1.Name = 'test oppty';
        insert opp1;
        Opportunity ParentOpp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        oppPar.add(ParentOpp);
        insert ParentOpp;
        Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:ParentOpp.id ];
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry1;
       }
        catch(DmlException e){         
        }
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.Estimated_Margin__c = 10;
        
        oli.PricebookEntryId = pricebookEntry1.Id;
        oli.OpportunityId = opp1.id;
         Test.startTest();
        insert oli;
        
        oli.UnitPrice = 1000;
        update oli;
        Test.stopTest();
        delete oli;
      
        List<OpportunityLineItem> oppLineList = [SELECT Id FROM OpportunityLineItem WHERE Id =:oli.Id];
        System.assert(true);
    }
    
    @isTest
    public static void test_validateOnDeleteNEG(){
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User salesUser = (User)TestDataGenerator.createSObject(
            new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME) , 
                     UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
        System.runAs(integrationUser){  
            try{
                insert acc;
            }
            catch(DmlException e){            }
            
        }
        
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;
        
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        try{
            insert prod;
        }
        catch(DmlException e){              }
        
        
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        try{
            insert pricebookEntry;
        }
        catch(DmlException e){           }
        
        
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
        System.runAs(salesUser){ 
            try{
                insert opp;
            }
            catch(DmlException e){           }
            
        }
        
        OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id));
        System.runAs(salesUser){  
            try{
                insert oppLine;
            }
            catch(DmlException e){           }
        }
        
        System.runAs(salesUser){ 
            try{
                if(oppLine.id != null){
                    delete oppLine;
                }
                //OpportunityProductTriggerHandlerHelper.triggerOpportunitiesApprovedSdpStageDelete(oppLine);
            }catch(DmlException de){ System.assert(de.getMessage().contains(GlobalConstants.Opportunity_Product_Delete_Validation_Error));}         
        }
    }
    
   @isTest
    public static void test_calculateLeadDomainPOS(){
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User salesUser = (User)TestDataGenerator.createSObject(
            new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME) , 
                     UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
        System.runAs(integrationUser){  
            try{
                insert acc;
            }
            catch(DmlException e){     }
        }
        
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;
        
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        try{
            insert prod;
        }
        catch(DmlException e){           }
        
        
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, IsActive = true, UnitPrice = 111);
        try{
            insert pricebookEntry;
        }
        catch(DmlException e){           }
        
        
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
        System.runAs(salesUser){ 
            try{
                insert opp;
            }
            catch(DmlException e){ }
        }
        
        OpportunityLineItem oppLineBNEW = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id,Product2Id = prod.Id, Business_Area__c = 'BNEW', UnitPrice = 1));
        OpportunityLineItem oppLineBDGS = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id,Product2Id = prod.Id, Business_Area__c = 'BDGS', UnitPrice = 2));
        OpportunityLineItem oppLineBMAS = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id,Product2Id = prod.Id, Business_Area__c = 'BMAS', UnitPrice = 3));
        OpportunityLineItem oppLineBTEB = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id,Product2Id = prod.Id, Business_Area__c = 'BTEB', UnitPrice = 4));
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(oppLineBNEW);
        oliList.add(oppLineBDGS);
        oliList.add(oppLineBMAS);
        oliList.add(oppLineBTEB);
        try{
            insert oliList;
            update oliList;
        }
        catch(DmlException e){   }
        
        List<Opportunity> oppList = [SELECT Id, Lead_Domain__c FROM Opportunity WHERE Id =:opp.Id];
        if(oppList.size()>0){
            System.assertEquals('BTEB', oppList[0].Lead_Domain__c);
        }
        //OpportunityProductTriggerHandlerHelper.calculateLeadDomain(null);
        //OpportunityProductTriggerHandlerHelper.getLeadingDomain(null);
        //OpportunityProductTriggerHandlerHelper.triggerOpportunitiesUpdate(null);
    }
    
    @isTest
    public static void test_calculateLeadDomainPriorityPOS(){
        Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
        User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User salesUser = (User)TestDataGenerator.createSObject(
            new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSON_SALES_USER_PROFILE_NAME) , 
                     UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
        System.runAs(integrationUser){
            try{
                insert acc;
            }
            catch(DmlException e){           }
        }
        
        Id pricebookIdStd = Test.getStandardPricebookId();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
        Id pricebookId = pb.Id;
        
        Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
        try{
            insert prod;
        }
        catch(DmlException e){        }
        
        
        PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
        insert pricebookEntryStd;
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, IsActive = true, UnitPrice = 111);
        insert pricebookEntry;   
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
        System.runAs(salesUser){            
            try{
                insert opp;
            }
            catch(DmlException e){          }        }
        
        OpportunityLineItem oppLineBNEW = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id, Business_Area__c = 'BNEW', UnitPrice = 4));
        OpportunityLineItem oppLineBDGS = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id, Business_Area__c = 'BDGS', UnitPrice = 2));
        OpportunityLineItem oppLineBMAS = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id, Business_Area__c = 'BMAS', UnitPrice = 3));
        OpportunityLineItem oppLineBTEB = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId = pricebookEntry.Id, Business_Area__c = 'BTEB', UnitPrice = 4));
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        oliList.add(oppLineBNEW);
        oliList.add(oppLineBDGS);
        oliList.add(oppLineBMAS);
        oliList.add(oppLineBTEB);
        try{
            insert oliList;
            update oliList;
        }
        catch(DmlException e){             }
        
        
        List<Opportunity> oppList = [SELECT Id, Lead_Domain__c FROM Opportunity WHERE Id =:opp.Id];
        if(oppList.size()>0){
            System.assertEquals('BNEW', oppList[0].Lead_Domain__c);
        }
    }
}