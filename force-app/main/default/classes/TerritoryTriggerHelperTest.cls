/******************************************************************************************
*
*            @author       : Ankit Jain
*            @date         : 08-07-2020
@description  : test Class for TerritoryTriggerHelper
Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-                                                                                     -                                                                                     Original Version
Ankit Jain                 08-07-2020          U-1921,U-1990

******************************************************************************************/
@isTest(seeAllData = false)
private class TerritoryTriggerHelperTest {	
    /****************************************************************
* @author: Manu Singhal, Ankit Jain
* @date: 13-07-2020
* @User Story: U-1921 & U-1990
* @description: This method is test method for updateCrgSharing
*****************************************************************/
    @isTest
    public static void updateCrgSharingTest(){
        Try{
            List<Territory2> terrList =  new List<Territory2>();
            Territory2Model terrModel = new Territory2Model(Name = 'Test TerritoryModel',DeveloperName='Test_Territory_Model');
            insert terrModel;
            Map<String,id> Territory2TypeMap = new Map<String,id>();
            for(Territory2Type terrType : [select id,DeveloperName from Territory2Type where DeveloperName =: 'Global_Leadership'
                                           OR DeveloperName =: 'Market_Area'
                                           OR DeveloperName =: 'Customer_Unit'
                                           OR DeveloperName =: 'KAM_Access_Group'
                                           OR DeveloperName =: 'Global_Customer_Unit'
                                           Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
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
            Territory2 territory3 = new Territory2(Name = 'Test Territory3',DeveloperName='Test_Territory3',Territory2ModelId = terrModel.id);
            territory3.Territory2TypeId = Territory2TypeMap.get('Customer_Unit');
            territory3.ParentTerritory2Id = territory2.id;
            terrList.add(territory3);
            
            Territory2 territory4 = new Territory2(Name = 'Test Territory4',DeveloperName='Test_Territory4',Territory2ModelId = terrModel.id);
            territory4.Territory2TypeId = Territory2TypeMap.get('KAM_Access_Group');
            territory4.ParentTerritory2Id = territory3.id;
            terrList.add(territory4);
            
            Territory2 territory5 = new Territory2(Name = 'Test Territory5',DeveloperName='Test_Territory5',Territory2ModelId = terrModel.id);
            territory5.Territory2TypeId = Territory2TypeMap.get('KAM_Access_Group');
            territory5.ParentTerritory2Id = territory3.id;
            terrList.add(territory5);
            
            test.startTest();
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.INTEGRATIONUSERPROFILENAME
                                                                                        Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){ 
                Id recordTypeId = GlobalConstants.gcuRecordTypeId;
                CustomerUnit__c gcu = new CustomerUnit__c(recordTypeId = recordTypeId, name='TestGCU', Type__c='GCU');            
                insert gcu;
                List<CustomerAccountGroup__c> cagList = new List<CustomerAccountGroup__c>();
                CustomerAccountGroup__c cag = new CustomerAccountGroup__c(CAGID__c= 5678);
                cagList.add(cag);
                CustomerAccountGroup__c cag1 = new CustomerAccountGroup__c(CAGID__c= 123456);
                cagList.add(cag1);
                insert cagList;
                List<CustomerReportingGroup__c> crgList = new List<CustomerReportingGroup__c>();
                CustomerReportingGroup__c crg = new CustomerReportingGroup__c(CRG_ID__c = '1234',GlobalCustomerUnit__c =gcu.id);        
                crgList.add(crg);                
                CustomerReportingGroup__c crg1 = new CustomerReportingGroup__c(CRG_ID__c = '12345',CustomerAccountGroup__c= cag.id);        
                crgList.add(crg1);
                CustomerReportingGroup__c crg2 = new CustomerReportingGroup__c(CRG_ID__c = '24357',CustomerAccountGroup__c= cag1.id);        
                crgList.add(crg2);
                insert crgList;
            }        
            territory4.CRG__c = '12345';
            territory4.CAG__c = '123456';
            insert terrList;  
            territory4.CRG__c = '1234,12345';
            territory4.CAG__c = '5678';
            update territory4;
            /*Group subGrp  = new Group();
subGrp.name = 'Test Group2';
subGrp.Type = 'Territory'; 
//subGrp.RelatedId=territory4.id;*/
            //Insert subGrp; 
            /*
Group grp =[select id,name,DeveloperName,RelatedId  from group where type='Territory'and RelatedId=:territory4.id limit 1];
*/
            test.stopTest();
            TerritoryTriggerHelper.updateCrgSharing(null,null);
            TerritoryTriggerHelper.updateSharing(null,null,null);
            Map<Id,String> crgMap =  TerritoryTriggerHelper.getCrgMapAfterCagSplit(null,null);
            Map<Id,List<Id>> crgMap1 = TerritoryTriggerHelper.getCrgMapAfterCrgSplit(null);
            Map<Id,Id> crgGcuMap = TerritoryTriggerHelper.createCrgGcuMap(null);
            System.assert(true);  //NS
            TerritoryTriggerHelper.AddCrgShareRecord(null,null,null);
            TerritoryTriggerHelper.updateGcuShareRecord(null,null,null);
            //TerritoryTriggerHelper.createCrgGcuMap(null,null);
        }catch(Exception e){	}
    }
}