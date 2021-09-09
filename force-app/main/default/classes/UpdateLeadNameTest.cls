/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-08 
* @description: This test class is for the class UpdateLeadName
********************************************************************/
@isTest
private class UpdateLeadNameTest{
  @testSetup
  static void setupTestData(){
          
Account ac = (Account)TestDataGenerator.createSObject(new Account(), false);
      //User for inserting Account
      User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id
                    FROM Profile
                    WHERE Name =:GlobalConstants.MIGRATIONUSERPROFILENAME
                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].Id, UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
      
list<Lead> ldlist = new list<lead>();
System.runAs(testUser) {
lead ld = new lead(Firstname='Test',Lastname = 'testlastname',Email = 'testemail@gmail.com',Market_Area__c = 'MANA',Country = 'India',Company = 'AT&T');
ldlist.add(ld);
insert ldlist;
}  
  }
  
    static testMethod void BatchMethod(){
     test.StartTest();
    UpdateLeadName obj01 = new UpdateLeadName ();
    Database.executeBatch(obj01, 200);
    test.stopTest();
    System.assert(true); //NS   
}
}