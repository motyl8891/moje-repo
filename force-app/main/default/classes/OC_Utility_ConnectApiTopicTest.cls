/* Class Name : OC_Utility_ConnectApiTopicTest
* Description : This class handles the test for getNavigationTopics method in OC_Utility class
* Author      : IBM.
*
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0      2021-04-16                  IBM       Initial Version as part of U-1977
*/

@Istest(SeeAllData=true)
public class OC_Utility_ConnectApiTopicTest {
    
    @isTest
    static void getNavigationTopicstest(){
        
        test.startTest(); 
        List<Topic> topicrec = [SELECT Id,ManagedTopicType,Name,NetworkId FROM Topic WHERE  ManagedTopicType LIKE '%navigational%' AND ManagedTopicType != 'Featured' AND NetworkId != null limit 1];
        System.assertEquals(1,topicrec.size());
        OC_Utility.getNavigationTopics(topicrec[0].id);
        test.stopTest();      
        
    }    
}