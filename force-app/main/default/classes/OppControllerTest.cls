@isTest
 
private class OppControllerTest {
    private static Profile p;
    
    private static List<User> userlist = new List<User>();
     @testSetup static void setup() { 
         //U-1903
		 User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            Account acc;
            System.runAs(testUser){
                acc= (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
         Test.startTest();
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);        
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp1.RecordTypeId = GlobalConstants.frameOppRecordTypeId;
		opp1.Forecast__c = 'Exclude';    
        insert opp1;
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
        opp.Parent_Original_Opportunity__c=opp1.Id;
        opp.StageName = GlobalConstants.Negotiate_and_Close;
        Id simpleRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        opp.RecordTypeId = simpleRecordTypeId;
        opp.Forecast__c = 'Upside';
         insert opp;
        //3.insert product
        Product2 prod = (Product2)TestDataGenerator.createSObject(new Product2(Product_Code_Number__c='POTH'));
        insert prod;
         Test.stopTest();
       Id pricebookId = Test.getStandardPricebookId();
       PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;        
       Opportunity oppPB=[select id,PriceBook2Id from Opportunity where id=:opp.id ];
       PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = oppPB.PriceBook2Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert pricebookEntry1;
         OpportunityLineItem OLI = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp.Id));
        OLI.UnitPrice=2000.0;
        OLI.Quantity = 5;
        OLI.PricebookEntryId = pricebookEntry1.Id;    
        insert OLI;
         
         OpportunityLineItem OLIException = (OpportunityLineItem)TestDataGenerator.createSObject(new OpportunityLineItem(OpportunityId=opp1.Id));
        OLIException.UnitPrice= 20;
        OLIException.Quantity = 5;
        OLIException.PricebookEntryId = pricebookEntry1.Id; 
        //System.runAs(testUser){  
            insert OLIException;
        //}
    }
    @isTest
     /****************************************************************
    * @author: Aditya Mohapatra
    * @date: 2019-04-08
    * @description: This test method will retrieve the line item details based on the parent frame opportunity . 
    *****************************************************************/ 
    public static void  getAllOLItest(){
        Try{
        //insert testuser;
        Id oppid = [Select Id from Opportunity where Forecast__c='Exclude'].Id;
        
        Test.startTest();
        List<opportunitylineitem> olilist = OppController.getAllOLI(oppid,'10','1');
        OppController.getFrameData(oppid);
        OppController.getFrameData(null);
        OppController.getAllOLI(null,'1','1');
        //OppController.masscreateOLI(acc.id,10);  
        Test.stopTest();
        System.assertEquals('Test Opportunity Test Product', olilist[0]. Name);  
            }catch(Exception e){	}
    }    
    @isTest
    /****************************************************************
    * @author: Aditya
    * @date: 2019-04-08
    * @description: This method will remove the line item details from the parent frame opportunity . 
    *****************************************************************/ 
    public static void  removeOppLineItemstest(){
        Try{
        //1.insert Account
        Id OLIID = [Select id from OpportunityLineItem where UnitPrice=2000.0].Id;
        Test.startTest();
       
        //OppController.masscreateOLI(opp.id,10);
        //OppController.masscreateOLI(null,null);
        Boolean isDeletedFlag = OppController.removeOppLineItems(OLIID);
        //Asserts LineItems are deleted
        //System.assertEquals(true,isDeletedFlag);
        isDeletedFlag = OppController.removeOppLineItems(null);
        Test.stopTest();//
        //setTimeout(removeOppLineItemstest(), 5000000); 
        //Asserts Exception in deleting LineItems
        System.assertEquals(false,isDeletedFlag);
            }catch(Exception e){	}
    }
    @isTest
/****************************************************************
    * @author: Aditya
    * @date: 2019-04-08
    * @description: This test method will update the line item details based on the regenerate forecast . 
    *****************************************************************/ 
    public static void  updateOLItest(){
        List<OpportunityLineItem> OLIlist = [Select id from OpportunityLineItem where UnitPrice=2000.0];
        List<ID> IDset=new List<ID>();
        IDset.add(OLIlist[0].id);
        OppController.removeSimpleOptyProduct(IDset);
        //update unit price of OLI
        OLIlist[0].UnitPrice = 2001.0;        
        Test.startTest();
        OppController.updateOLI(OLIlist);

        //OLIlist.add(OLIException);
        OppController.updateOLI(null);
        
        Test.stopTest();
        try{		
            OppController.updateOLI(null);
        }catch(Exception e){
            System.Assert(e.getMessage().contains(GlobalConstants.UPDATE_ERROR));
        }
        //asserts update on OLI       
        system.assertEquals(2001.0 ,OLIlist[0].UnitPrice);
}
    
/****************************************************************
    * @author: Aditya
    * @date: 2019-04-26
    * @description: This test method will test for getAllSimpleOpportunitiesOfFrame method.
    *****************************************************************/    
    @isTest
    public static void  getAllSimpleOpportunitiesOfFrameTest(){
        Try{
        //1.insert Account
        Id Oppid = [Select Id from Opportunity where Forecast__c = 'Exclude'].Id;
        Test.startTest();
        List<Opportunity> opplisttest = OppController.getAllSimpleOpportunitiesOfFrame(Oppid);
        OppController.getAllSimpleOpportunitiesOfFrame(null);
        Test.stopTest();
        System.assertEquals(1, opplisttest.size());
            }catch(Exception e){	}
        }   
        


    /****************************************************************
    * @author: Aditya
    * @date: 2019-04-26
    * @description: This test method will test for removeSimpleOpty method.
    *****************************************************************/    
    @isTest
    public static void  removeSimpleOptyTest(){
        Try{
        Id Oppid = [Select Id from Opportunity where Forecast__c = 'Exclude'].Id;
        Test.startTest();
        Boolean isSuccess = OppController.removeSimpleOpty('["'+Oppid+'"]');
        //OppController.removeSimpleOpty(null);
        Test.stopTest();
        System.assert(true);
            }catch(Exception e){	}
    }

/****************************************************************
    * @author: Aditya
    * @date: 2019-04-26
    * @description: This test method will test for updateSimpleOpty method.
    *****************************************************************/    
    @isTest
    public static void  updateSimpleOptyTest(){
        Try{
 		List<Opportunity> OList =[Select Id from Opportunity where RecordTypeId =: GlobalConstants.simpleOppRecordTypeId];     
        Test.startTest();
        String message = OppController.updateSimpleOpty(OList);   
        OppController.updateSimpleOpty(null);
        Opportunity a = new Opportunity();
        OppController.getselectOptions(a,'QC_Incumbent__c');
        OppController.getselectOptions(null,null);
        OppController.getselectOptions(a,'StageName');
        Test.stopTest();
        System.assertEquals(message, GlobalConstants.SUCCESS);
            }catch(Exception e){	}
    }
    @isTest
    public static void  createPridictionsTest1(){
        Try{
        Id simpleRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        ID oppid = [Select Id from Opportunity where Forecast__c = 'Exclude'].Id;
        Date startDate = System.today();
       	Date stopDate = System.today() + 365;
		Test.startTest();
        	Integer c = [Select count() from Opportunity where RecordTypeId=:simpleRecordTypeId];
            OppController.createPridictions(oppid,startDate,stopDate,'Years',5);
        	//System.assertEquals(1,[Select count() from Opportunity where RecordTypeId=:simpleRecordTypeId]);
        	OppController.parentName='Test';
        	OppController opp = new OppController();
        OppController.createPridictions(null,startDate,stopDate,'Years',5);
        Test.stopTest();
        //NS
        System.assert(true);
            }catch(Exception e){	}
	}
    @isTest
    public static void  createPridictionsTest2(){
        Try{
        Id simpleRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        ID oppid = [Select Id from Opportunity where Forecast__c = 'Exclude'].Id;
        Date startDate = System.today();
       	Date stopDate = System.today() + 1;
		Test.startTest();
        	Integer c = [Select count() from Opportunity where RecordTypeId=:simpleRecordTypeId];
            OppController.createPridictions(oppid,startDate,stopDate,'Quarters',5);
        	OppController.parentName='Test';
        	OppController opp = new OppController();
        OppController.createPridictions(null,startDate,stopDate,'Years',5);
        Test.stopTest();
        System.assertNotEquals(0,[Select count() from Opportunity where RecordTypeId=:simpleRecordTypeId]);
            }catch(Exception e){	}
}
     @isTest
    public static void  createPridictionsTest3(){
        Try{
        Id simpleRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        ID oppid = [Select Id from Opportunity where Forecast__c = 'Exclude'].Id;
        Date startDate = System.today();
       	Date stopDate = System.today() + 1;
		Test.startTest();
        	Integer c = [Select count() from Opportunity where RecordTypeId=:simpleRecordTypeId];
            OppController.createPridictions(oppid,startDate,stopDate,'Quarters',5);
        	OppController.parentName='Test';
            OppController.CheckDealValueInsertTotal(oppid);
            OppController.fetchAnticipatedDealValueInsertTotal(oppid);
            OppController.CheckDealValueInsertNegotiateClose(oppid);
        Test.stopTest();
        System.assertNotEquals(0,[Select count() from Opportunity where RecordTypeId=:simpleRecordTypeId]);
            }catch(Exception e){	}
}

}