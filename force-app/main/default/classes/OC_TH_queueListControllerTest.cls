/**
 * @File Name      :OC_TH_queueListControllerTest
 * @Author         :IBM
 * @Group          :OmniChannel - Service
 * @Created Date   :05th Aug 2021
 * ========================================================================================
 * Ver             Date             Author         Modification
 * ========================================================================================
 * 1.0           2021-08-05         IBM            Initial Version
**/
@isTest
public class OC_TH_queueListControllerTest {
    @testsetup
    public static void setup()
    {
       Id serviceprofileId = [SELECT Id FROM Profile WHERE Name =: 'Ericsson Service'].Id;
        User testuser=(User)TestDataGenerator.createSObject(new User());
        testuser.Username='ericsson@test.com';
        testuser.ProfileId=serviceprofileId;
        insert testuser;
        
        List<GroupMember> groupMemeberistToInsert=new List<GroupMember>();
        List<Group> listOfPublicGroup=new List<group>();
        
        Group publicGroupToInsert=(Group)TestDataGenerator.createSObject(new Group());
        publicGroupToInsert.Name = 'A&N - Test Group';
        publicGroupToInsert.Type='Queue';
        listOfPublicGroup.add(publicGroupToInsert);
        
        if(!listOfPublicGroup.isEmpty()){
            insert listOfPublicGroup;
        }
        
        GroupMember groupMemberToInsert=(GroupMember)TestDataGenerator.createSObject(new GroupMember() );
        groupMemberToInsert.GroupId=listOfPublicGroup[0].id;
        groupMemberToInsert.UserOrGroupId=testuser.id;
        
        groupMemeberistToInsert.add(groupMemberToInsert);
        
        if(!groupMemeberistToInsert.isEmpty())
        {
            insert groupMemeberistToInsert;
        }
        
    }
    
    @isTest
    static void queueListControllerTest()
    {
        List<User>UserList=[Select id,Name,isActive from User where isActive=True Limit 1];
        Test.startTest();
        try{
            System.runAs(UserList[0]){
            OC_TH_queueListController.getfetchQueueRecords(UserList[0].id);
            }
        }
        catch(Exception e)
        {
           EventLog.createLog(new EventLog.Error(OC_TH_Constants.OC_TH_QUEUELISTCONTROLLER,OC_TH_Constants.GETFETCHRECORDS,null, false, e));  
        }
        Test.stopTest();
        }
    }