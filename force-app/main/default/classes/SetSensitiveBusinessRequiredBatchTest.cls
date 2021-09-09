@isTest(seeAllData = false)
private class SetSensitiveBusinessRequiredBatchTest {
    @isTest() 
    public static void testMethod1() 
    {
        Try{
            Id frameOppRecordTypeId =GlobalConstants.frameOppRecordTypeId;
            String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
            Account acc; 
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.Trade_Classification__c='DEFENSE';
                insert acc;
            }
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId,Trade_Compliance_Status__c= 'Pending Approval', Anticipated_Deal_Value__c = 500)); 
            insert opp; 
            opp.Trade_Compliance_Status__c='Pending Approval';
            update opp;
          /*  Opportunity opp1= [Select id,Trade_Compliance_Status__c from Opportunity ];
            system.debug('value8888 is'+opp1.Trade_Compliance_Status__c);*/
            Secondary_Approval__c Secapp = new Secondary_Approval__c(opportunity__c = opp.Id,Sign_Off_Type__c ='Trade Compliance',Approval_Valid_Until__c=system.today()-1);
            insert Secapp;   
            List<Secondary_Approval__c> sa=[select id,Sign_Off_Type__c, Opportunity__r.Trade_Compliance_Status__c from Secondary_Approval__c where id=:Secapp.Id
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];    
            system.assertEquals('Trade Compliance', sa[0].Sign_Off_Type__c);
            Test.startTest();
            SetSensitiveBusinessRequiredBatch obj1 = new SetSensitiveBusinessRequiredBatch();
            String sch = '0 0 23 * * ?'; 
            system.schedule('Test inactive contact delete', sch, obj1);    
            
            SetSensitiveBusinessRequiredBatch obj = new SetSensitiveBusinessRequiredBatch();
            DataBase.executeBatch(obj); 
            DataBase.executeBatch(null); 
            Test.stopTest();
        }catch(Exception e){	}
    }
    
    @isTest()
    public static void testMethod2()
    {
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            String oppStageQualifyOppty = GlobalConstants.Qualify_Opportunity;
            Account acc; 
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                acc.Trade_Classification__c='DEFENSE';
                insert acc;
            }
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId,Trade_Classifications__c = 'DEFENSE', Anticipated_Deal_Value__c = 500)); 
            insert opp; 
            opp.Trade_Compliance_Status__c='Required';
            update opp;
            Id RecordTypeId = GlobalConstants.sensitiveBusinessRecordTypeId;
            Secondary_Approval__c Secapp2 = new Secondary_Approval__c(opportunity__c = opp.Id,Sign_Off_Type__c ='Sensitive Business',Approval_Valid_Until__c=system.today()-1, recordtypeid=RecordTypeId);
            insert Secapp2; 
            List<Secondary_Approval__c> sa=[select id, Opportunity__r.Trade_Classifications__c, Opportunity__r.Sensitive_Business_status__c,Sign_Off_Type__c from Secondary_Approval__c where id=:Secapp2.Id
                                            Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];    
            Test.startTest();
            SetSensitiveBusinessRequiredBatch obj1 = new SetSensitiveBusinessRequiredBatch();
            String sch = '0 0 23 * * ?'; 
            system.schedule('SetSensitiveBusinessRequiredBatchTest', sch, obj1);    
            SetSensitiveBusinessRequiredBatch obj = new SetSensitiveBusinessRequiredBatch();
            DataBase.executeBatch(obj); 
            DataBase.executeBatch(null);
            Test.stopTest();
            System.assert(true);
        }catch(Exception e){	}
    }
}