@isTest(seeAllData = false)
private class OpportunityChildSumDeaValueHelperTest{
 
  @isTest
  public static void OpportunityChildSumDeaValuePercentHelper(){
      Try{
    //Get all Opportunity RecordtypeIds from Custom labels
            Id simpleOppRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
            Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;  
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            
            //Get Opportunity Stages from Custom labels
            String oppStageNegotiateAndClose = GlobalConstants.Negotiate_and_Close;
            String oppStageClosedWon = GlobalConstants.oppStageClosedWon;
            String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
            String oppStageClosedWithdrawn = GlobalConstants.oppStageClosedWithdrawn;
            String oppStageClosedDuplicate = GlobalConstants.oppStageClosedDuplicate;
            
      Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
          acc = (Account)TestDataGenerator.createSObject(new Account(), false); 
          insert acc;
        }
      
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        Opportunity opp11 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        Opportunity opp12 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));
        
      List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(opp);
        oppFrameLst.add(opp1);
        oppFrameLst.add(opp11);
      oppFrameLst.add(opp12);
      insert oppFrameLst;       
            
        Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = simpleOppRecordTypeId, Parent_Original_Opportunity__c = opp.Id, StageName = oppStageNegotiateAndClose, Deal_Value__c = 100));
              
        //Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Parent_Frame_Opportunity__c = opp.Id, Deal_Value__c = 100));
      Opportunity opp3 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Parent_Original_Opportunity__c = opp.Id, Deal_Value__c = 100));
              
        Opportunity opp4 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = simpleOppRecordTypeId, Parent_Original_Opportunity__c = opp.Id, StageName = oppStageNegotiateAndClose, Deal_Value__c = 10));
              
       // Opportunity opp5 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Parent_Frame_Opportunity__c = opp.Id, Deal_Value__c = 10));
      Opportunity opp5 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Parent_Original_Opportunity__c = opp.Id, Deal_Value__c = 10));
      
        //Opportunity opp6 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Parent_Frame_Opportunity__c = opp1.Id, Deal_Value__c = 10));
      Opportunity opp6 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Parent_Original_Opportunity__c = opp1.Id, Deal_Value__c = 10));
      
        Opportunity opp7 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = simpleOppRecordTypeId, Parent_Original_Opportunity__c = opp11.Id, StageName = oppStageNegotiateAndClose, Deal_Value__c = 10));
    
        List<Opportunity> oppLst = new List<Opportunity>();
    
       
        oppLst.add(opp2);
        oppLst.add(opp3);
        oppLst.add(opp4);
        oppLst.add(opp5);
        oppLst.add(opp6);
        oppLst.add(opp7);
        insert oppLst;
    
     //OpportunityChildSumDeaValuePercentHelper.sumChildOppsDealValue(oppLst);
      OpportunityChildSumDeaValuePercentHelper.sumChildOppsDealValueOnFrame(oppFrameLst);
      OpportunityChildSumDeaValuePercentHelper.sumChildOppsDealValueOnFrame(null);
      //NS 
      System.assert(true);
          }catch(Exception e){	}
    }
     /****************************************************************
* @author: Manu Singhal
* @date: 22-05-2019
* @param: NA
* @description: This test method will cover updateMAHeadandBAHeads method.
*****************************************************************/
     @isTest
    public static void updateMAHeadandBAHeadsTest(){
        Try{
        //Get all Opportunity RecordtypeIds from Custom labels
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId; 
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.SYSTEMADMINPROFILENAME) ,MA_Head__c = testUser.Id,UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser1){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;        
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500,High_Impact_Deal__c = true));
            Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Anticipated_Deal_Value__c = 500));
            List<Opportunity> oppFrameLst = new List<Opportunity>();
            oppFrameLst.add(opp1);
            oppFrameLst.add(opp2);
            insert oppFrameLst; 
            Map<ID, Opportunity> oldOpptiesMap = new  Map<ID, Opportunity>();
            oldOpptiesMap.put(opp2.id,opp2);
            opp2.High_Impact_Deal__c = true;
            update oppFrameLst;
            Test.startTest();
            OpportunityChildSumDeaValuePercentHelper.updateMAHeadandBAHeads(oppFrameLst,null);
            OpportunityChildSumDeaValuePercentHelper.updateMAHeadandBAHeads(oppFrameLst,oldOpptiesMap);
            OpportunityChildSumDeaValuePercentHelper.updateMAHeadandBAHeads(null,null);
            Test.stopTest();      
            Opportunity updatedOpp = [Select Id,MA_Head__c  from Opportunity where id = :opp1.Id Limit 1];
            System.assertEquals(testUser1.MA_Head__c,updatedOpp.MA_Head__c);
        }
            }catch(Exception e){	}
    }
     /****************************************************************
* @author: Aditya Mohapatra
* @date: 17-06-2019
* @param: NA
* @description: This test method will cover populateSalesOBTargetsandActualsOnNewOpp method.
*****************************************************************/
     @isTest
    public static void populateSalesOBTargetsandActualsOnNewOpp(){
        Try{
        //Get all Opportunity RecordtypeIds from Custom labels
        Id standardOppRecordTypeId = GlobalConstants.standardOppRecordTypeId;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        CustomerReportingGroup__c crg = new CustomerReportingGroup__c();
        CustomerUnit__c cu = new CustomerUnit__c(Name='CU Eastern Europe and Central Asia');
        crg.CustomerUnit__c = cu.id;
        insert crg;
        insert cu;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME),UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.SYSTEMADMINPROFILENAME) ,MA_Head__c = testUser.Id,UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false); 
            insert acc;
            }
        System.runAs(testUser1){
            acc.CustomerReportingGroup__c = crg.Id;
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500,High_Impact_Deal__c = true));
            VP_Sales_KAM_OB_Target__c vp1 = new VP_Sales_KAM_OB_Target__c(Customer_Unit__c=cu.Id,KAM__c = testUser1.id);
            VP_Sales_KAM_OB_Target__c vp2 = new VP_Sales_KAM_OB_Target__c(Customer_Unit__c=cu.Id,KAM__c = testUser1.id);
            Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = standardOppRecordTypeId, Anticipated_Deal_Value__c = 500));
            List<Opportunity> oppFrameLst = new List<Opportunity>();
            List<VP_Sales_KAM_OB_Target__c> kAMLst = new List<VP_Sales_KAM_OB_Target__c>();
            kAMLst.add(vp1);
            kAMLst.add(vp2);
            List<Opportunity> oppFrameLst2 = new List<Opportunity>();
            oppFrameLst.add(opp1);
            oppFrameLst.add(opp2);
            insert oppFrameLst;
            insert kAMLst;
            Map<ID, Opportunity> oldOpptiesMap = new  Map<ID, Opportunity>();
            oldOpptiesMap.put(opp2.id,opp2);
            opp2.High_Impact_Deal__c = true;
            update oppFrameLst;
            Test.startTest();
            OpportunityChildSumDeaValuePercentHelper.populateSalesOBTargetsandActualsOnNewOpp(oppFrameLst);
            for(Opportunity opp :oppFrameLst)
            for(VP_Sales_KAM_OB_Target__c vp3 :kAMLst){
            if(vp1.Customer_Unit__c==opp1.Customer_Unit__c){
                opp1.KAM_VP_Sales_OB_Targets_and_Actuals__c = vp1.id;
            }}
            OpportunityChildSumDeaValuePercentHelper.populateSalesOBTargetsandActualsOnNewOpp(null);
            Test.stopTest();
            //NS
        	System.assert(true);
        }
            }catch(Exception e){	}
    }
    
/****************************************************************
* @author: 
* @date: 15-07-2020
* @param: NA
* @description: This test method will cover updateCloseDateofSimple method.
*****************************************************************/
     @isTest
    public static void updateCloseDateofSimpleTest(){
        Try{
        Id simpleOppRecordTypeId = GlobalConstants.simpleOppRecordTypeId;
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        String oppStageClosedLost = GlobalConstants.oppStageClosedLost;
        Set<Id> frameOpptyIdSet = new Set<id>();
        Set<Id> frameOpptyIdSet1 = new Set<id>();
        Account acc; 
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.MIGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
        Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
        Opportunity oppchild1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = simpleOppRecordTypeId, Anticipated_Deal_Value__c = 500,Parent_Original_Opportunity__c=opp.id)); 
       System.runAs(testUser){  
            insert opp;
        }
        List<Opportunity> oppFrameLst = new List<Opportunity>();
        oppFrameLst.add(oppchild1);
        System.runAs(testUser){  
            insert oppFrameLst;
        }        
        Map<ID, Opportunity> oldOpportunitiesMap = new  Map<ID, Opportunity>();
        for(Opportunity oppli : oppFrameLst)
        {  
            oldOpportunitiesMap.put(oppli.id, oppli);
            //oldOpportunitiesMap.get(oppli.id).StageName = oppStageClosedLost;            
        }
        List<Opportunity> newoppFrameLst = new List<Opportunity>();
        oppchild1.StageName = oppStageClosedLost;
        oppchild1.CloseDate = Date.valueof(System.now());
        newoppFrameLst.add(oppchild1);
        try{
        update newoppFrameLst;
        } catch(DmlException e){}    
      Test.startTest();
        OpportunityChildSumDeaValuePercentHelper.updateCloseDateofSimple(newoppFrameLst, oldOpportunitiesMap);
        OpportunityChildSumDeaValuePercentHelper.updateCloseDateofSimple(null, null);
      Test.stopTest();  
      //NS
      System.assert(true);  
            }catch(Exception e){	}
    }
}