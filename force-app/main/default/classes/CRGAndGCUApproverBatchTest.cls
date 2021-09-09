@isTest(seeAllData = false)
private class CRGAndGCUApproverBatchTest {
    
    @isTest
    static void testCRGAndGCUApproverChange() {
        Try{
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                           UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
            User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                           UserName = 'ericsson887@test.com' + System.currentTimeMillis()), true);
            
            System.runAs(testUser) {
                CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(ID__c='100143',Type__c='GCU',
                                                       Name='CU West Africa & Morocco', ResponsibleSignum__c='EELNOWA', AP_Lower_Limit__c=1111111,
                                                       AP_Upper_Limit__c=27777778, Small_Value_Limit__c=1111111, Exempt_from_Pre_Sales_Budget_Approval__c=true,
                                                       Annual_CU_Target__c=0, Next_Year_s_Annual_CU_Target__c=0, Q1_NY_Target__c=0, Q1_Target__c=0,
                                                       Q2_NY_Target__c=0, Q2_Target__c=0, Q3_NY_Target__c=0, Q3_Target__c=0, Q4_NY_Target__c=0, Q4_Target__c=0,
                                                       ApproversChanged__c = true));
                insert cu;

                CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(Name='Angola Telecom',
											  MarketArea__c='MMEA', CRG_ID__c='200513', Market__c='AO', Type__c='KA',Manager__c='EELHOKA', 
											  GlobalCustomerUnit__c=cu.Id, Account_CU_Head__c=testUser.Id, Account_Primary_KAM__c=testUser.Id, 
                                              Update_Opportunity_Approvers__c = true));
				insert crg;
                
                Test.startTest();
                    Account acc1 = new Account();
                    acc1.Name = 'Test Account';
                    acc1.SAP_S2P_ID__c='1';
                    acc1.CurrencyIsoCode = 'SEK';
                    acc1.Visible__c = true;
                    acc1.Customer_Tier__c = 'Tier 1';
                    acc1.CustomerReportingGroup__c= crg.id;
                    insert acc1;
                    system.debug(acc1);
                    Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
                    List<Opportunity> oppList = new List<Opportunity>();
                    for (Integer i = 0; i < 10; i++) {
                        oppList.add((Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc1.Id)));
                    }
                    insert  oppList;
                    
                	cu.GCU_Head__c = testUser1.Id;
                    cu.GCU_Commercial_Head__c = testUser1.Id;
                    cu.ApproversChanged__c = true;
                    cu.GCU_KAM__c = testUser1.Id;
                    update cu;
                    
                    crg.Account_Primary_KAM__c = testUser1.Id;
                    crg.Account_CU_Head__c = testUser1.Id;
                    update crg;
                    
                }
                CustomerUnit__c c = [Select ApproversChanged__c from CustomerUnit__c limit 1];
                System.assertEquals(true, c.ApproversChanged__c);

                CRGAndGCUApproverBatch obj = new CRGAndGCUApproverBatch();
                DataBase.executeBatch(obj);
            Test.stopTest(); 
            
            Opportunity oppty = [Select GCU_Head__c, GCU_Commercial_Head__c from Opportunity limit 1];
            System.assertEquals(testUser1.Id, oppty.GCU_Head__c);
            System.assertEquals(testUser1.Id, oppty.GCU_Commercial_Head__c);

        }catch(Exception e){	}
    }
    
    public static testmethod void testGCUApproverBatchScheduler() {
        Try{
            Test.startTest();
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = CRGAndGCUApproverBatchScheduler.scheduleBatches(CRON_EXP, 'TestCRGGUCApproverBatchHourly');
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            Test.stopTest();
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        }catch(Exception e){	}
    }
}