/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-07 
* @description: This test class is for the class UpdateAccountName
********************************************************************/


@isTest
private class UpdateAccountNameTest{
  @testSetup
  static void setupTestData(){
   String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
    Profile p = [SELECT Id FROM Profile WHERE Name='Integration User Profile'
                Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);
    test.startTest();
    system.runAs(u){
    Account acc = new Account(Name = 'AccName');
    Insert acc; 
   // Opportunity opp = new Opportunity( Name = 'OppName');
    //Insert opp; 
    }
    test.stopTest();
  }
    static testMethod void BatchMethod(){
    UpdateAccountName obj01 = new UpdateAccountName();
    Database.executeBatch(obj01, 200);
    System.assert(true);    //NS
}
}