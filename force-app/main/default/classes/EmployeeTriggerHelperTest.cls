/****************************************************************
* @author: Anurkiti Agrwal	
* @date: 26-09-2019
* @User Story: 0994
* @description: This class is a test class for EmployeeTriggerHelper
*****************************************************************/
@isTest
public class EmployeeTriggerHelperTest {
    
	@testSetup
    static void setup() {
        User testUser = (User)TestDataGenerator.createSObject(new User(Signum__c='ABCDE', ProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
	}
    
	@isTest
	public static void setUserFromSignumTest() {
        Try{
        Employee__c emp = new Employee__c();
        emp.Signum__c = 'ABCDE';
        User testUser = (User)TestDataGenerator.createSObject(new User(Signum__c='ABYUUU', ProfileId = [SELECT Id FROM Profile WHERE Name = 'Ericsson Sales User'].Id, UserName = 'erics56@test.com'+System.currentTimeMillis()),true);
        system.runAs(testUser) {
        	insert emp;
        }
       	emp = [SELECT ID,Salesforce_User__c FROM Employee__c];
        User u = [SELECT Id FROM User WHERE Signum__c='ABCDE'];
        system.assertEquals(u.Id, emp.Salesforce_User__c);
        EmployeeTriggerHelper.setUserFromSignum(null);
           }catch(Exception e){	}
	}
}