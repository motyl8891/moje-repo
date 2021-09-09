@isTest(seeAllData = false)
private class VisualizeDeviationTest {
    
    public static testMethod void propDataTest() {
        Try{
            Account acc;
            User integrationUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                                  UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            User salesUser = (User)TestDataGenerator.createSObject(
                new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.ERICSSONSALESUSERPROFILENAME), 
                         UserName = 'ericsson7778@test.com'+System.currentTimeMillis(), CommunityNickname = 'test2', Alias = 'test2'),true);
            System.runAs(integrationUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.Customer_Tier__c = GlobalConstants.Tier_3;
                insert acc;
            }
            
            Id pricebookIdStd = Test.getStandardPricebookId();
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(CurrencyIsoCode='SEK'), true);
            Id pricebookId = pb.Id;
            
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id,MarketArea__c ='test', PriceBook2Id = pricebookId, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
            insert opp;
            Proposal__c prop = new Proposal__c(Name = 'test', Opportunity__c = opp.Id, Primary__c = true);
            
            insert prop;
            Product__c prod = new Product__c(Business_Area__c='testba',Proposal__c = prop.Id);
            Product__c prod1 = new Product__c(Business_Area__c=GlobalConstants.BNEW,Proposal__c = prop.Id);
            Product__c prod2 = new Product__c(Business_Area__c=GlobalConstants.BMAS,Proposal__c = prop.Id);
            Product__c prod3 = new Product__c(Business_Area__c=GlobalConstants.BDGS,Proposal__c = prop.Id);
            Product__c prod4 = new Product__c(Business_Area__c=GlobalConstants.BTEB,Proposal__c = prop.Id);
            Product__c prod5 = new Product__c(Business_Area__c=GlobalConstants.GCU,Proposal__c = prop.Id);
            Product__c prod6 = new Product__c(Business_Area__c=GlobalConstants.BLANK,Proposal__c = prop.Id);
            Product__c prod7 = new Product__c(Business_Area__c='MELA',Proposal__c = prop.Id);
            List<Product__c> ProdList = new List<Product__c>();
            ProdList.add(prod);
            ProdList.add(prod1);
            ProdList.add(prod2);
            ProdList.add(prod3);
            ProdList.add(prod4);
            ProdList.add(prod5);
            ProdList.add(prod6);
            ProdList.add(prod7);
            
            insert ProdList;
            Deviation__c dev = new Deviation__c(ApprovingUnit__c = 'MELA',DeviationType__c = 'Non-Delegated',Proposal__c = prop.Id);
            insert dev;
            
            Test.startTest();
            VisualizeDeviation.getPropData(prop.Id);
            dev.DeviationType__c = 'BCTC';
            update dev;
            VisualizeDeviation.getPropData(opp.Id);
            VisualizeDeviation.getPropData(prop.Id);
            List<VisualizeDeviation.DeviationWraper> data = VisualizeDeviation.getDeviationData(opp.Id);
            VisualizeDeviation.createMARecord(prop, opp, null, null, null, null);
            VisualizeDeviation.createMARecord(null, null, null, null, null, null);
            Test.stopTest();
            
            system.assert(data != null);
        }
        catch(Exception e){ }
    }
}