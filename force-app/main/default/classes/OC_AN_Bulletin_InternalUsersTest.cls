@isTest
public class OC_AN_Bulletin_InternalUsersTest {
    
     @testsetup 
    static void setup(){
        
        List<User> userListToInsert = new List<User>();
        List<GroupMember> groupMemberListToInsert = new List<GroupMember>();
        List<Group> listOfPublicGroup = new List<Group>();
        List<OC_AN_Bulletin_Template__c> listOfBulletinTemplate = new List<OC_AN_Bulletin_Template__c>();
        List<OC_AN_Bulletin__c> listOfBulletin = new List<OC_AN_Bulletin__c>();
        List<OC_AN_Bulletin_Account_Product__c> listOfGroupsAssociatewithBulletin = new List<OC_AN_Bulletin_Account_Product__c>();
        
        
        Id migrationUserProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id;
        
        User testuser = (User)OC_TestDataGenerator.createSObject(new User());
        testuser.UserName = 'ericsson@test.com'+System.currentTimeMillis();
        testuser.ProfileId = migrationUserProfileId;
        testuser.IsActive = true;
        
        insert testuser;
        
        System.runAs(testUser){
            Id serviceProfileId = [SELECT Id FROM Profile WHERE Name = 'Ericsson Service'].Id;
            
            User serviceUser = (User)OC_TestDataGenerator.createSObject(new User());
            serviceUser.ProfileId = serviceProfileId;
            serviceUser.IsActive = true;
            userListToInsert.add(serviceUser);
            if(!userListToInsert.isEmpty()){
                insert userListToInsert;
            }
            
            Group publicGroupToInsert = (Group)OC_TestDataGenerator.createSobject(new Group());
            publicGroupToInsert.Name = 'A&N - Test Group';
            listOfPublicGroup.add(publicGroupToInsert);
            if(!listOfPublicGroup.isEmpty()){
                insert listOfPublicGroup;
            }
            
            GroupMember groupMemberToInsert = (GroupMember)OC_TestDataGenerator.createSobject(new GroupMember());
            groupMemberToInsert.GroupId = listOfPublicGroup[0].Id;
            groupMemberToInsert.UserOrGroupId = userListToInsert[0].Id;
            groupMemberListToInsert.add(groupMemberToInsert);
            if(!groupMemberListToInsert.isEmpty()){
                insert groupMemberListToInsert;
            }
            
            OC_AN_Bulletin_Template__c bulletinTemplateToInsert = (OC_AN_Bulletin_Template__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin_Template__c());
            listOfBulletinTemplate.add(bulletinTemplateToInsert);
            if(!listOfBulletinTemplate.isEmpty()){
                insert listOfBulletinTemplate;
            }
            
            OC_AN_Bulletin__c bulletinToInsert = (OC_AN_Bulletin__c) OC_TestDataGenerator.createSobject(new OC_AN_Bulletin__c());
            bulletinToInsert.OC_AN_Bulletin_Template__c = listOfBulletinTemplate[0].Id;
            listOfBulletin.add(bulletinToInsert);
            if(!listOfBulletin.isEmpty()){
                insert listOfBulletin ;
            }
            
            OC_AN_Bulletin_Account_Product__c groupToInsert = new OC_AN_Bulletin_Account_Product__c();
            groupToInsert.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
            groupToInsert.OC_AN_GroupId__c = listOfPublicGroup[0].Id;
            groupToInsert.OC_AN_Public_Group_Name__c = listOfPublicGroup[0].Name;
            groupToInsert.OC_AN_Bulletin__c = listOfBulletin[0].Id;
            listOfGroupsAssociatewithBulletin.add(groupToInsert);
            
            if(!listOfGroupsAssociatewithBulletin.isEmpty()){
                insert listOfGroupsAssociatewithBulletin;
            }
           
   }  
    
  }
    
    @isTest
    static void getBulletinIdsFromGroupTest(){
        
        List<OC_AN_Bulletin__c> recBulletin = [SELECT id,(SELECT OC_AN_GroupId__c From Bulletin_Account_Products__r) FROM OC_AN_Bulletin__c];
        
        system.debug('recBulletin===>'+recBulletin[0].Bulletin_Account_Products__r);
        
        Test.startTest();
        List<User> returnedUserList = OC_AN_Bulletin_InternalUsers.getBulletinIdsFromGroup(recBulletin[0].Id);
        Test.stopTest();
    }
        
    }