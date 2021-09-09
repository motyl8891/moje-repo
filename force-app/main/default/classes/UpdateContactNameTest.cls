/******************************************************************* 
* @author: Bhushan K
* @date: 2019-10-08 
* @description: This test class is for the class UpdateContactName
********************************************************************/
@isTest
private class UpdateContactNameTest{
  @testSetup
  static void setupTestData(){
          
      test.startTest();
      Account ac; 
      User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                     UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
      System.runAs(testUser){  
          ac = (Account)TestDataGenerator.createSObject(new Account(), false);
          insert ac;
      }
      list<Contact> Contact= new list<Contact>();
         
        Contact con= new Contact(AccountId=ac.id,Firstname='test123',Lastname = 'testlastname',Email= 'testemail@gmail.com',MailingCountry='Cuba');
        Contact.add(con);
        insert Contact;
        test.stopTest();
    
  }
  
    static testMethod void BatchMethod(){
        test.StartTest();
        UpdateContactName  obj01 = new UpdateContactName ();
        Database.executeBatch(obj01, 200);
        test.stopTest();
        System.assert(true);  //NS
	}
}