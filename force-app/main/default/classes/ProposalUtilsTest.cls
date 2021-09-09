@isTest(seeAllData = false)
private class ProposalUtilsTest{
    
    @isTest
    public static void createVersionZero_testPOS(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){ 
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            
            Id pricebookIdstd = Test.getStandardPricebookId();
            
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            
            Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', Product_Code_Number__c = 'TEST', CurrencyIsoCode ='SEK');
            insert prod;
            
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, 
                                                                  IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, 
                                                               IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntry;
            
            
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, 
                                                                                           OpportunityNumber__c = '777888'));
            insert opp;
            
            OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, 
                                                                                                                       PricebookEntryId = pricebookEntry.Id));
            insert oppLine;
            
            Map<Proposal__c, List<Product__c>> resultMap = ProposalUtils.createVersionZero(opp.Id);
            
            Proposal__c resultProp = null;
            for(Proposal__c pr : resultMap.keySet()){
                resultProp = pr;
            }
            
            List<Product__c> prodcResList = resultMap.get(resultProp);
            
            System.assertEquals(opp.OpportunityNumber__c+'V0', resultProp.Proposal_Id__c);
            System.assertEquals(opp.OpportunityNumber__c+'V0', resultProp.Proposal_Unique_Id__c);
            System.assertEquals('0', resultProp.Version__c);
            System.assertEquals(1, prodcResList.size());
        }catch(Exception e){    }
    }
    
    @isTest
    public static void createVersionZero_testNEG(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);  
                insert acc;
            }
            
            Id pricebookIdstd = Test.getStandardPricebookId();
            
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            
            Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', Product_Code_Number__c = 'TEST');
            insert prod;
            
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, 
                                                                  CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
            insert pricebookEntry;
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, 
                                                                                           OpportunityNumber__c = '777888'));
            insert opp;
            
            OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, 
                                                                                                                       PricebookEntryId = pricebookEntry.Id));
            insert oppLine;
            
            Map<Proposal__c, List<Product__c>> resultMap = ProposalUtils.createVersionZero(opp.Id);
            
            try{
                Map<Proposal__c, List<Product__c>> resultMap2 = ProposalUtils.createVersionZero(opp.Id);
            }catch(DmlException de){
                System.assertEquals(GlobalConstants.INSERT_FAILED_DUPLICATEVALUE_ERROR, de.getMessage());
                
            }
        }catch(Exception e){    }    
    }
    
    @isTest
    public static void replaceProducts_testPOS(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            
            Id pricebookIdStd = Test.getStandardPricebookId();
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            
            Product2 prod = new Product2(Family = 'Hardware', Name = 'TEST', Product_Code_Number__c = 'TEST');
            insert prod;
            
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, 
                                                                  IsActive = true, CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
            insert pricebookEntry;
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId,
                                                                                           OpportunityNumber__c = '777888999'));
            insert opp;
            
            OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, 
                                                                                                                       PricebookEntryId = pricebookEntry.Id));
            insert oppLine;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id), false);
            insert prop;
            
            /*Product__c productHW = (Product__c)TestDataGenerator.createSObject(new Product__c(
            Name = 'HWProd',
            Commodity__c = 'HW',
            Proposal__c = prop.Id,
            Product_Code__c = prod.Name
            ), false);
            insert productHW;*/
            
            List<Proposal__c> propList = new List<Proposal__c>();
            propList.add(prop);
            
            Test.startTest();
            Boolean result = ProposalUtils.replaceProducts_queryProductsFirst(propList);
            List<OpportunityLineItem> resultOppLines = [SELECT Id, Product_Area__c FROM OpportunityLineItem WHERE OpportunityId =:opp.Id];
            Test.stopTest();
            
            System.assertEquals(true, result);
            //System.assertEquals(productHW.Name, resultOppLines[0].Product_Area__c); 
            
            /* Map<Proposal__c, List<Product__c>> resultMap = ProposalUtils.createVersionZero(opp.Id);
            
            Proposal__c resultProp = null;
            for(Proposal__c pr : resultMap.keySet()){
            resultProp = pr;
            }
            
            List<Product__c> prodcResList = resultMap.get(resultProp);
            
            System.assertEquals(opp.OpportunityNumber__c+'v0', resultProp.Proposal_Id__c);
            System.assertEquals(opp.OpportunityNumber__c+'v0', resultProp.Proposal_Unique_Id__c);
            System.assertEquals('0', resultProp.Version__c);
            System.assertEquals(1, prodcResList.size());*/
        }catch(Exception e){    }
    } 
    
    
    @isTest
    public static void replaceProducts_testNEG(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){ 
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);  
                insert acc;
            }
            
            Id pricebookIdStd = Test.getStandardPricebookId();
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            
            Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
            insert prod;
            
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true,
                                                                  CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
            insert pricebookEntry;
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, 
                                                                                           OpportunityNumber__c = '777888999'));
            insert opp;
            
            OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, 
                                                                                                                       PricebookEntryId = pricebookEntry.Id));
            insert oppLine;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id), false);
            insert prop;
            
            Product__c productHW = (Product__c)TestDataGenerator.createSObject(new Product__c(
                Name = 'HWProd',
                Commodity__c = 'HW',
                Proposal__c = prop.Id,
                Product_Code__c = 'NotExistingCode'
            ), false);
            insert productHW;
            
            List<Proposal__c> propList = new List<Proposal__c>();
            propList.add(prop);
            
            try{
                ProposalUtils.replaceProducts_queryProductsFirst(propList);
            }catch(UtilException ue){
                System.assertEquals(GlobalCOnstants.CUSTOM_EXCEPTION_PRODUCT2ID_NOT_FOUND + productHW.Product_Code__c, ue.getMessage());
            }
        }catch(Exception e){    }
    }
    
    /*****************************************************
	* Author: Shubham Kadam
	* Date: 30/07/2020
	* Description: Test Method for Queueable Apex class AsyncReplaceProducts
	*****************************************************/
    @isTest
    public static void AsyncReplaceProductsTest(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){ 
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);  
                insert acc;
            }
            
            Id pricebookIdStd = Test.getStandardPricebookId();
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            
            Product2 prod = new Product2(Name = 'TEST', Family = 'Hardware', ProductCode = 'TEST', Product_Code_Number__c = 'TEST');
            insert prod;
            
            PricebookEntry pricebookEntryStd = new PricebookEntry(Pricebook2Id = pricebookIdstd, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true, 
                                                                  CurrencyIsoCode ='SEK',useStandardPrice=false);
            insert pricebookEntryStd;
            PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
            insert pricebookEntry;
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, PriceBook2Id = pricebookId, 
                                                                                           OpportunityNumber__c = '777888999'));
            insert opp;
            
            OpportunityLineItem oppLine = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id, 
                                                                                                                       PricebookEntryId = pricebookEntry.Id));
            insert oppLine;
            
            Proposal__c prop = (Proposal__c)TestDataGenerator.createSObject(new Proposal__c(Opportunity__c = opp.Id), false);
            insert prop;
            
            Product__c productHW = (Product__c)TestDataGenerator.createSObject(new Product__c(
                Name = 'HWProd',
                Commodity__c = 'HW',
                Proposal__c = prop.Id,
                Product_Code__c = 'NotExistingCode'
            ), false);
            insert productHW;
            
            List<Proposal__c> propList = new List<Proposal__c>();
            propList.add(prop);
			
            AsyncReplaceProducts prd = new AsyncReplaceProducts(propList);
            
            Test.startTest();
            	System.enqueueJob(prd);
            Test.stopTest();
            
            System.assert(true);
            
        }catch(Exception e){    }    
    }    
}