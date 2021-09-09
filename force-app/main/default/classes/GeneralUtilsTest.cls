@isTest(seeAllData = false)
private class GeneralUtilsTest {
        
   @isTest
    static void testAmpersandEscape(){ 
        
        String testString = 'Negotiate & Close';
        String result = GeneralUtils.escapeSpecialXMLChararcters(testString);
        
        System.assertEquals('Negotiate &amp; Close', result);
        
    }
    
    @isTest
    static void testGreaterThanEscape(){ 
        
        String testString = 'Negotiate > Close';
        String result = GeneralUtils.escapeSpecialXMLChararcters(testString);
        
        System.assertEquals('Negotiate &gt; Close', result);
        
    }
    
    @isTest
    static void testLessThanEscape(){ 
        
        String testString = 'Negotiate < Close';
        String result = GeneralUtils.escapeSpecialXMLChararcters(testString);
        
        System.assertEquals('Negotiate &lt; Close', result);
        
    }
    
    @isTest
    static void testAposEscape(){ 
        
        String testString = 'Negotiate \' Close';
        String result = GeneralUtils.escapeSpecialXMLChararcters(testString);
        
        System.assertEquals('Negotiate &apos; Close', result);
        
    }
    
    @isTest
    static void testQuotesEscape(){ 
        
        String testString = 'Negotiate \" Close';
        String result = GeneralUtils.escapeSpecialXMLChararcters(testString);
        
        System.assertEquals('Negotiate &quot; Close', result);
        
    }

    @isTest 
    static void testgenerateRandomString(){
        
        String result = GeneralUtils.generateRandomString(15);
        System.assertEquals(15, result.length());

    }

    @isTest
    static void testgetIsoCodeAndConvRateMap(){
        CurrencyType currType = [SELECT ConversionRate, IsoCode from CurrencyType Where IsoCode ='SEK'];
        Map<String,Double> isoCodeToConvRate = GeneralUtils.getIsoCodeAndConvRateMap();
        Double checkValue = isoCodeToConvRate.get('SEK');
        System.assertEquals(currType.ConversionRate,checkValue);
    }

    @isTest
    static void testgetContractInfoByExternalID(){
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),                                                             
                                                                       UserName = 'ericsson@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){

        List<Account> testAcc = new List<Account>();
        for(Integer i=1; i<=5;i++){
          //  Account a = (Account)TestDataGenerator.createSObject(new Account(Name='Test Account'+i, SAP_S2P_ID__c=String.valueOf(i)),false);
           // testAcc.add(a);
            CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
            crg.MarketArea__c = GlobalConstants.MELA;
            crg.CRG_ID__c='HW1234'+i;
            crg.Name='testCRG'+i;
            insert crg;
           
			Account a = new Account();
            a.Name = 'Test Account'+i;
            a.SAP_S2P_ID__c=String.valueOf(i);
            a.CurrencyIsoCode = 'SEK';
            a.Visible__c = true;
            a.Customer_Tier__c = 'Tier 1';
            a.CustomerReportingGroup__c= crg.id;
            insert a;
            
        }
        //insert testAcc;
        
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        List<Opportunity> oppList = new List<Opportunity>();
        List<Contract> contrList = new List<Contract>();
        Integer i = 1;
        for(SObject acc: testAcc){
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id));
            oppList.add(opp);
            Contract contr = (Contract)TestDataGenerator.createSObject(new Contract(AccountId=acc.Id, Contract_ID__c = '234'+i, Status='Draft', OpportunityID__c=opp.OpportunityNumber__c));
            contrList.add(contr);
            i++;
        }
        insert oppList;
        insert contrList;
        }
        List<Contract> contrList = [SELECT Id, Contract_ID__c FROM Contract];
        List<String> contrIds = new List<String>();
        for(Contract c: contrList){
            contrIds.add(c.Contract_ID__c);
        }
        List<Contract> testContractsList = GeneralUtils.getContractInfoByExternalID(contrIds);
        System.assertEquals(contrList.size(), testContractsList.size());
    }

    @isTest
    static void testoutboundOppXMLresposeBod(){
        String body = GeneralUtils.outboundOppXMLresposeBody();
        System.assertEquals(true, body.contains('<soapenv:Body><ser-root:OpportunityUpdateResponse xmlns:ser-root="http://webservice.oasis.ericsson.com/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><tns:OpportunityUpdateResult xmlns:tns="http://webservice.oasis.ericsson.com/">true</tns:OpportunityUpdateResult></ser-root:OpportunityUpdateResponse>'));
    }
   

	@isTest
    static void testNormalcheckInputString(){
        String test1='test1';
        String test2='';
        
        test2 = GeneralUtils.checkInputString(test1, 255);
        System.assertEquals(test1, test2);
    }  
    
    @isTest
    static void testNoEqualcheckInputString(){
        String test1='Contrary to popular belief,Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia,			 looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" ((The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.';
        String test2='';
        
        test2 = GeneralUtils.checkInputString(test1, 255);
        System.assertEquals(254, test2.length());
    }
    
    
    @isTest
    static void testcreateException(){
        Exception__c exctest = new Exception__c();
        String exctestname = 'TestClass';
        String UID = UserInfo.getUserId();       
        
        
        exctest =GeneralUtils.createException('TestClass', 
                                            'TestCode', 
                                            'TestMessage',
                                            'TestMethod',
                                            'TestObj',
                                             UID);	
               
        System.assertEquals(exctestname, exctest.Class__c);
    }    
    
    @isTest
    static void testNullcheckFieldMsg(){
        
        CheckResult chResTest = new CheckResult();
        
        String TestRes= '';
        
        String fld=null;
        String fldname='TestName'; 
        Integer fldLength=255;
        String  className='TestClass';
        String  fnName='TestFunc';
        
        chResTest=GeneralUtils.checkFieldMsg(fld,fldname,fldLength,className,fnName);
        System.assertEquals(TestRes, chResTest.getokResult());
        
    }   
    
     @isTest
    static void testNormalcheckFieldMsg(){
        
        CheckResult chResTest = new CheckResult();
        
        String TestRes= 'Test';
        
        String fld='Test';
        String fldname='TestName'; 
        Integer fldLength=255;
        String  className='TestClass';
        String  fnName='TestFunc';
        
        chResTest=GeneralUtils.checkFieldMsg(fld,fldname,fldLength,className,fnName);
        System.assertEquals(TestRes, chResTest.getokResult());
        
    }
    
    
    @isTest
    static void testLongStrcheckFieldMsg(){
        
        CheckResult chResTest = new CheckResult();
        
        String fld = 'Contrary to popular belief,Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia,			 looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" ((The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.';
        String TestResOK = '';
        
        
        String fldname='TestName'; 
        Integer fldLength=255;
        String  className='TestClass';
        String  fnName='TestFunc';
        
        chResTest=GeneralUtils.checkFieldMsg(fld,fldname,fldLength,className,fnName);
        TestResOK=chResTest.getokResult();
        System.assertEquals(254, TestResOK.length());
        
    }
}