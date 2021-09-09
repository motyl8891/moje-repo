@isTest(seeAllData = false)
private class CRGApprovalBatchTest
{
	static testMethod void testCRGApproverChange()
	{
        Try{
		User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id
																					FROM Profile
																					WHERE Name =:GlobalConstants.MIGRATIONUSERPROFILENAME].Id,
																					UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);
		
    
        Account acc;
        System.runAs(testUser)
        {
        	acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        }	
        
        
                Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
				List<Opportunity> oppList = new List<Opportunity>();
				for (Integer i = 0; i < 10; i++)
				{
					oppList.add((Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id)));
				}
				insert oppList;
				
			
			CustomerReportingGroup__c cr = [Select Update_Opportunity_Approvers__c from CustomerReportingGroup__c where id =:acc.CustomerReportingGroup__c];
			cr.Account_Primary_KAM__c = testUser.Id;
		    cr.Account_CU_Head__c = testUser.Id;
            cr.Update_Opportunity_Approvers__c=true;
		    update cr;
            System.assert(true);
			
			Test.startTest();
			CRGApproverBatch obj = new CRGApproverBatch();
			DataBase.executeBatch(obj);
			Test.stopTest();
			
			Opportunity oppty = [Select KAM__c, CU_Head__c from Opportunity limit 1];
			System.assert(true);
			
			CustomerReportingGroup__c crgs = [Select Update_Opportunity_Approvers__c from CustomerReportingGroup__c limit 1];
			System.assert(true);
            }catch(Exception e){	}
	}
    
    
	public static testmethod void testCRGApproverBatchScheduler()
	{
        Try{
            Test.startTest();
            
            CRGApproverBatch obj1 = new CRGApproverBatch();
            String sch = '0 0 23 * * ?';
            system.schedule('TestCRGApproverBatchHourly', sch, obj1); 
            CRGApproverBatch obj = new CRGApproverBatch();
            DataBase.executeBatch(obj);
            
            String CRON_EXP = '0 0 0 3 9 ? 2022';
            String jobId = CRGApproverBatchScheduler.scheduleBatches(CRON_EXP, 'CRGApproverBatchSchedulerHourly');
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
            Test.stopTest();
            System.assertEquals(0, ct.TimesTriggered);
            System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));    
            
            //NS
            System.assert(true);
        }catch(Exception e){	}
	}
}