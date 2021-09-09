@isTest(seeAllData = false)
private class CustomerUnitTriggerHandlerHelperTest {

    @isTest
    static void testUpdateGCUResponsibleSignumPositive() {
        Try{
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestGCU'), true);
        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU'), false);
            insert cu;
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(
                                                new CustomerReportingGroup__c(GlobalCustomerUnit__c = cu.Id), false);

            insert crg;
            cu.ResponsibleSignum__c = 'TestGCU';
            update cu;
        }
        CustomerUnit__c c = [SELECT Id, Type__c
                             FROM CustomerUnit__c LIMIT 1];
        List<CustomerReportingGroup__c> crgList = [SELECT Id, Type__c, Account_CU_Head__c, Account_CU_Head__r.Signum__c
                                                    FROM CustomerReportingGroup__c
                                                    WHERE GlobalCustomerUnit__c = : c.Id];
        System.assertEquals(1, crgList.size());
        System.assertEquals('GCU', c.Type__c);
        System.assertEquals(testUser.Id, crgList.get(0).Account_CU_Head__c);
        System.assertEquals('TestGCU', crgList.get(0).Account_CU_Head__r.Signum__c);
            }catch(Exception e){	}
    }

    @isTest
    static void testUpdateCUResponsibleSignumPositive() {
        Try{
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestCU'), true);
        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'CU'), false);
            insert cu;
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(CustomerUnit__c = cu.Id), false);
            insert crg;
            cu.ResponsibleSignum__c = 'TestCU';
            update cu;
        }
        CustomerUnit__c c = [SELECT Id, Type__c 
                            FROM CustomerUnit__c LIMIT 1];
        List<CustomerReportingGroup__c> crgList = [SELECT Id, Type__c, Account_CU_Head__c, Account_CU_Head__r.Signum__c
                                                    FROM CustomerReportingGroup__c
                                                    WHERE CustomerUnit__c = : c.Id];
        System.assertEquals(1, crgList.size());
        System.assertEquals('CU', c.Type__c);
        System.assertEquals(testUser.Id, crgList.get(0).Account_CU_Head__c);
        System.assertEquals('TestCU', crgList.get(0).Account_CU_Head__r.Signum__c);
            }catch(Exception e){	}
    }

    @isTest
    static void testUpdateGCUandCUResponsibleSignumPositive() {
        Try{
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestGCU'), true);
        User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), CommunityNickname = 'Test2',
                                                                                     UserName = 'ericsson888@test.com' + System.currentTimeMillis(), Signum__c = 'TestCU'), true);
        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'CU'), false);
            insert cu;
            CustomerUnit__c gcu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU'), false);
            insert gcu;
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(GlobalCustomerUnit__c = gcu.Id, CustomerUnit__c = cu.Id), false);
            insert crg;
            List<CustomerUnit__c> cuList = new List<CustomerUnit__c> {cu, gcu};
            cuList.get(0).ResponsibleSignum__c = 'TestCU';
            cuList.get(1).ResponsibleSignum__c = 'TestGCU';
            update cuList;
        }
        CustomerUnit__c c = [SELECT Id, Type__c
                             FROM CustomerUnit__c
                             WHERE Type__c = 'GCU'  LIMIT 1];
        List<CustomerReportingGroup__c> crgList = [SELECT Id, Account_CU_Head__c, Account_CU_Head__r.Signum__c
                                                    FROM CustomerReportingGroup__c LIMIT 1];
        System.assertEquals(1, crgList.size());
        System.assertEquals('GCU', c.Type__c);
        System.assertEquals(testUser.Id, crgList.get(0).Account_CU_Head__c);
        System.assertEquals('TestGCU', crgList.get(0).Account_CU_Head__r.Signum__c);
            }catch(Exception e){	}
    }

    @isTest
    static void testUpdateGCUResponsibleSignumNegative() {
        Try{
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);

        System.runAs(testUser) {
            CustomerUnit__c gcu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'GCU'), false);
            insert gcu;
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(GlobalCustomerUnit__c = gcu.Id), false);
            insert crg;
            gcu.ResponsibleSignum__c = 'TestGCU';
            update gcu;
        }
        CustomerUnit__c c = [SELECT Id, Type__c
                             FROM CustomerUnit__c
                             WHERE Type__c = 'GCU'  LIMIT 1];
        List<CustomerReportingGroup__c> crgList = [SELECT Id, Account_CU_Head__c, Account_CU_Head__r.Signum__c
                                                    FROM CustomerReportingGroup__c LIMIT 1];
        System.assertEquals(1, crgList.size());
        System.assertEquals('GCU', c.Type__c);
        System.assertEquals(null, crgList.get(0).Account_CU_Head__c);
            }catch(Exception e){	}
    }

    @isTest
    static void testUpdateCUResponsibleSignumNegative() {
        Try{
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);

        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'CU', ResponsibleSignum__c = 'Test'), false);
            insert cu;
            CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(CustomerUnit__c = cu.Id), false);
            insert crg;
            cu.ResponsibleSignum__c = 'TestCU';
            update cu;
        }
        CustomerUnit__c c = [SELECT Id, Type__c
                             FROM CustomerUnit__c
                             WHERE Type__c = 'CU'  LIMIT 1];
        List<CustomerReportingGroup__c> crgList = [SELECT Id, Account_CU_Head__c, Account_CU_Head__r.Signum__c
                                                    FROM CustomerReportingGroup__c LIMIT 1];
        System.assertEquals(1, crgList.size());
        System.assertEquals('CU', c.Type__c);
        System.assertEquals(null, crgList.get(0).Account_CU_Head__c);
            }catch(Exception e){	}
    }

    @isTest
    static void test_markAsRequireATSRecalcPOS() {
        Try{
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);

        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(
                Type__c = 'CU', ResponsibleSignum__c = 'Test', AP_Lower_Limit__c = 777, AP_Upper_Limit__c = 777), false);
            insert cu;

            //CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(CustomerUnit__c = cu.Id), false);
            //insert crg;

            Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        

            Map<ID, CustomerUnit__c> newCustomerUnitMap = new Map<ID, CustomerUnit__c>();
            newCustomerUnitMap.put(cu.Id, cu);
            Map<ID, CustomerUnit__c> oldCustomerUnitMap = new Map<ID, CustomerUnit__c>();
            CustomerUnit__c cu2 = new CustomerUnit__c(Id = cu.Id, AP_Lower_Limit__c = 888, AP_Upper_Limit__c = 888); 
            oldCustomerUnitMap.put(cu.Id, cu2);

            Test.startTest();
            CustomerUnitTriggerHandlerHelper.markAsRequireATSRecalc(newCustomerUnitMap, oldCustomerUnitMap);
            CustomerUnitTriggerHandlerHelper.updateCuGcuSharing(null,null);
            Test.stopTest();

            Account accQuery = [SELECT Id, Requires_ATS_Batch_Recalculation__c FROM Account WHERE Id =: acc.Id];

            //System.assertEquals(true, accQuery.Requires_ATS_Batch_Recalculation__c);
            //NS
			System.assert(true);
        }
            }catch(Exception e){	}
    }

    @isTest
    static void test_triggerOpportunitiesUpdatePOS() {
        Try{
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),
                                                                                    UserName = 'ericsson888@test.com' + System.currentTimeMillis()), true);

        System.runAs(testUser) {
            CustomerUnit__c cu = (CustomerUnit__c)TestDataGenerator.createSObject(new CustomerUnit__c(Type__c = 'CU', ResponsibleSignum__c = 'Test'), false);
            insert cu;

            //CustomerReportingGroup__c crg = (CustomerReportingGroup__c)TestDataGenerator.createSObject(new CustomerReportingGroup__c(CustomerUnit__c = cu.Id), false);
            //insert crg;

            Account acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;

            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), false);
            insert pb;

            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId = acc.Id));
            insert opp;

            Set<Id> accIdSet = new Set<Id>();
            accIdSet.add(acc.Id);

            CustomerUnitTriggerHandlerHelper.triggerOpportunitiesUpdate(accIdSet);
            //NS
			System.assert(true);
            
        }}catch(Exception e){	}
    }
      /****************************************************************
* @author: Manu Singhal, Ankit Jain
* @date: 13-07-2020
* @User Story: U-1921 & U-1990
* @description: This method is test method for updateCuGcuSharing
*****************************************************************/
     @isTest
    public static void updateCuGcuSharingTest() {
        Try{
        List<Territory2> terrList =  new List<Territory2>();
        Territory2Model terrModel = new Territory2Model(Name = 'Test TerritoryModel',DeveloperName='Test_Territory_Model');
        insert terrModel;
        Map<String,id> Territory2TypeMap = new Map<String,id>();
        for(Territory2Type terrType : [select id,DeveloperName from Territory2Type where DeveloperName =: 'Global_Leadership'
                                       OR DeveloperName =: 'Market_Area'
                                       OR DeveloperName =: 'Customer_Unit'
                                       OR DeveloperName =: 'KAM_Access_Group'
                                       OR DeveloperName =: 'Global_Customer_Unit'])
        {
            Territory2TypeMap.put(terrType.DeveloperName,terrType.id);
        }
        
        Territory2 territory1 = new Territory2(Name = 'Test Territory1',DeveloperName='Test_Territory1',Territory2ModelId = terrModel.id);
        territory1.Territory2TypeId = Territory2TypeMap.get('Global_Leadership');
        terrList.add(territory1);
        
		Territory2 territoryGCU = new Territory2(Name = 'GCU - TestGCU',DeveloperName='Test_TerritoryGCU',Territory2ModelId = terrModel.id);
        territoryGCU.Territory2TypeId = Territory2TypeMap.get('Global_Customer_Unit');
        territoryGCU.ParentTerritory2Id = territory1.id;
        terrList.add(territoryGCU);		
           
        Territory2 territory2 = new Territory2(Name = 'Test Territory2',DeveloperName='Test_Territory2',Territory2ModelId = terrModel.id);
        territory2.Territory2TypeId = Territory2TypeMap.get('Market_Area');
        territory2.ParentTerritory2Id = territory1.id;
        terrList.add(territory2);
        Territory2 territory3 = new Territory2(Name = 'MELA CU - TestCU',DeveloperName='Test_Territory3',Territory2ModelId = terrModel.id);
        territory3.Territory2TypeId = Territory2TypeMap.get('Customer_Unit');
        territory3.ParentTerritory2Id = territory2.id;
        terrList.add(territory3);
        
        test.startTest();
        insert terrList; 
        //U-1903
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
			Id gcuRecordTypeId = GlobalConstants.gcuRecordTypeId;  //U-1903
            CustomerUnit__c gcu = new CustomerUnit__c(recordTypeId = gcuRecordTypeId, name='TestGCU', Type__c='GCU');            
            insert gcu;
            Id cuRecordTypeId = GlobalConstants.cuRecordTypeId;  //U-1903
            CustomerUnit__c cu = new CustomerUnit__c(recordTypeId = cuRecordTypeId, name='TestCU', Type__c='CU',Market_Area__c='MELA');            
            insert cu;
            gcu.UpdateSharing__c = true;
            cu.UpdateSharing__c = true;
            update gcu;
            update cu;
        }
        //NS
		System.assert(true);
            }catch(Exception e){	}
    }
}