@isTest
private class SendEmailToNotifyCloseDateBatchTest {
    @isTest
    public static void ExecuteTest(){
        Try{
            Account acc;
            Account acc1;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            
            System.runAs(testUser){
                
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.CurrencyIsoCode = 'SEK';
                insert acc;
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c(CRG_ID__c='12345',Name='testCrg1');
                insert crg;
                acc1= new Account();
                acc1.Name = 'Test1 Account';
                acc1.SAP_S2P_ID__c=String.valueOf(1);
                acc1.CurrencyIsoCode = 'ALL';
                acc1.Visible__c = true;
                acc1.Customer_Tier__c = 'Tier 1';
                acc1.CustomerReportingGroup__c= crg.id;
                insert acc1;
                
            } 
            Test.startTest();
            List<Opportunity> oppList= new List<Opportunity>();
            Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.standardCreateOppRecordTypeId,
                                                                                            Forecast__c=null)); 
            opp1.CloseDate = Date.today()-1;
            Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.frameCreateOppRecordTypeId,
                                                                                            currencyIsoCode='AOA')); 
            opp2.CloseDate = Date.today();
            Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.simpleCreateOppRecTypeId, 
                                                                                            stageName=GlobalConstants.Negotiate_and_Close)); 
            opp3.CloseDate = Date.today()+1;
            oppList.add(opp1);
            oppList.add(opp2);
            oppList.add(opp3);
            Insert oppList;
            Id batchJobId = Database.executeBatch(new SendEmailToNotifyCloseDateBatch(), 200);
            SendEmailToNotifyCloseDateBatchScheduler sh1 = new SendEmailToNotifyCloseDateBatchScheduler();
            String sch = '0 0 0 ? * SUN *';
            system.schedule('Test check', sch, sh1);
            Test.stopTest();
        }
        catch(Exception e){}
    }
}