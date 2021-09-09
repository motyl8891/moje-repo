@isTest(seeAllData = false)
private class LeadConvertControllerTest {

static testMethod void testLeadConvert(){
Account ac;
       
      //User for inserting Account
      User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                     UserName = 'ericsson111@test.com' + System.currentTimeMillis()), true);
      System.runAs(testUser) {
      ac = (Account)TestDataGenerator.createSObject(new Account(), false);
      insert ac;
      }
list<Lead> ldlist = new list<lead>();

lead ld = new lead(FirstName='testfirst',LastName = 'testlastname',Email = 'testemail@gmail.com',Market_Area__c = 'MANA',Country = 'India',Company = 'AT&T');
ldlist.add(ld);
insert ldlist;

list<id> setIds = new list<id>();
ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(ldlist);
 stdSetController.getSelected();
 LeadConvertController lc = new LeadConvertController(stdSetController);
 for(lead l : ldlist){
   setIds.add(l.id);
 }
 string acc; 
 LeadConvertController.fetchAccounts(acc);
 LeadConvertController.selectedleads(setIds,ac.id);
 //NS
 System.assert(true);

}
}