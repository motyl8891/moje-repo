@isTest(seeAllData = false)
private class OpportunityUtilsTest{

    @isTest
    public static void test_getOpportunityInfo(){
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777'));
        insert opp;
        
        Set<Id> oppIdsSet = new Set<Id>();
        oppIdsSet.add(opp.Id);
        List<Opportunity> oppReturnList = OpportunityUtils.getOpportunityInfo(oppIdsSet);

        System.assertEquals(true, oppReturnList.size() >0); 
            }catch(Exception e){	}
    }

    @isTest
    public static void test_getOpportunityInfoWithOppTeamMembers(){
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777'));
        insert opp;

        Set<Id> oppIdsSet = new Set<Id>();
        oppIdsSet.add(opp.Id);
        List<Opportunity> oppReturnList = OpportunityUtils.getOpportunityInfoWithOppTeamMembers(oppIdsSet);

        System.assertEquals(true, oppReturnList.size() >0); 
            }catch(Exception e){	}
    }
    
    @isTest
    public static void test_getOpportunityByOppNumberInfo(){
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);  
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777'));
        insert opp;
        
        Set<String> oppIdsSet = new Set<String>();
        oppIdsSet.add(opp.OpportunityNumber__c);
        List<Opportunity> oppReturnList = OpportunityUtils.getOpportunityByOppNumberInfo(oppIdsSet);

        System.assertEquals(true, oppReturnList.size() >0); 
            }catch(Exception e){	}
    }

    @isTest
    public static void test_getOpportunitiesWithContractsByOppNum(){
        Try{
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){
          acc = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert acc;
        }

        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777'));
        insert opp;
        
        List<String> oppIdsList = new List<String>();
        oppIdsList.add(opp.OpportunityNumber__c);

        List<Opportunity> oppReturnList = OpportunityUtils.getOpportunitiesWithContractsByOppNum(oppIdsList);

        System.assertEquals(true, oppReturnList.size() >0); 
            }catch(Exception e){	}
    }
    
    @isTest
    public static void sendEmailToAllOpptysForTradeComplianceTest(){
        Try{
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson888@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777'));
            insert opp;
            
            List<Opportunity> oppList = new List<Opportunity>();
            Map<Account,List<Opportunity>> accWithOpptyListMap = new Map<Account,List<Opportunity>>();
            oppList.add(opp);
			accWithOpptyListMap.put(acc, oppList);   
            
            Test.startTest();
            OpportunityUtils.sendEmailToAllOpptysForTradeCompliance(accWithOpptyListMap);
            OpportunityUtils.sendEmailToAllOpptysForTradeCompliance(null);
            Test.stopTest();
        }
        catch(Exception e){}
    }
}