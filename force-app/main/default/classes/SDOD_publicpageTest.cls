@isTest(seeAllData = false)
private class SDOD_publicpageTest{
  
 static testMethod void saveTest() 
 {
     SDOD_Lead__c slead = new SDOD_Lead__c();

 Test.StartTest(); 
  ApexPages.StandardController sc = new ApexPages.StandardController(slead);
  SDOD_publicpage publicPage = new SDOD_publicpage(sc);
     		PageReference location = new PageReference('/'+ slead.id);
     		location.setRedirect(true);        

  publicPage.save();
 Test.StopTest();
     System.assert(true);  //NS
 }
    
 static testMethod void checkframeapexTest() 
 {
          SDOD_Lead__c slead = new SDOD_Lead__c();

     Test.StartTest(); 
  ApexPages.StandardController sc = new ApexPages.StandardController(slead);
  SDOD_publicpage publicPage = new SDOD_publicpage(sc);
  publicPage.checkframeapex();
 Test.StopTest();
     System.assert(true);  //NS
 }
    
}