/****************************************************************
* @author: Richa Gupta
* @date: 11-09-2020
* @User Story: 1999
* @description: This class is a test class for UserTriggerHelper
*****************************************************************/
@isTest
public class UserTriggerHelperTest {
    static testMethod void mapUserToEmployeeTest() {
        Profile pf = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.SYSTEMADMINPROFILENAME];
        String orgId = UserInfo.getOrganizationId();
        UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString + randomInt;
        String uniqueName1 = dateString + orgId + randomInt;
        Employee__c emp= new Employee__c(Name='John',Signum__c=uniqueName);
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        system.runAs(testUser) {
            insert emp;
        }
        
        User tuser = new User(  firstname = 'fName',lastName = 'lName',
                              Signum__c=uniqueName,
                              email = uniqueName + '@test' + orgId + '.org',
                              Username = uniqueName + '@test' + orgId + '.org',
                              EmailEncodingKey = 'ISO-8859-1',
                              Alias = uniqueName.substring(18, 23),
                              TimeZoneSidKey = 'America/Los_Angeles',
                              LocaleSidKey = 'en_US',
                              LanguageLocaleKey = 'en_US',
                              ProfileId = pf.Id,
                             UserRoleId = ur.Id);
        test.startTest();
        insert tuser ;
        User u=[Select id,firstName from User where firstname = 'fName'];
        system.assertEquals(u.firstName, 'fName');
        Employee__c e=[Select id,Salesforce_User__c,name from Employee__c where name='John'];
      /* system.assertEquals( u.id,emp.Salesforce_User__c); */
        UserTriggerHelper.mapUserToEmployee(Null, Null, False);
        tuser.signum__c=uniqueName1;
        update tuser;
       		
		        //U-2275
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
        Territory2 territory2 = new Territory2(Name = 'Test Territory2',DeveloperName='Test_Territory2',Territory2ModelId = terrModel.id);
            territory2.Territory2TypeId = Territory2TypeMap.get('Global_Leadership');
            terrList.add(territory1);
        terrList.add(territory2);
        insert terrList; 
        
        List<UserTerritory2Association> objUserTerritory2Associationlist = new list<UserTerritory2Association>();
        UserTerritory2Association objUserTerritory2Association1 = new UserTerritory2Association(Territory2Id= territory1.Id, UserId= tuser.Id);
        UserTerritory2Association objUserTerritory2Association2 = new UserTerritory2Association(Territory2Id= territory2.Id, UserId= tuser.Id);
        objUserTerritory2Associationlist.add(objUserTerritory2Association1);
        objUserTerritory2Associationlist.add(objUserTerritory2Association2);
        insert objUserTerritory2Associationlist;
        tuser.IsActive = false;
        update tuser;
        tuser.IsActive = true;
        update tuser;
        UserTriggerHelper.upadteAssociatedTerritories(null,null);
		UserTriggerHelper.updateUserNickName(null);
        test.stopTest();
    }
}