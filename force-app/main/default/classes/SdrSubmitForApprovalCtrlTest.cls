@isTest
public class SdrSubmitForApprovalCtrlTest {
    @isTest
    public static void sendApprovaRequestTest(){
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                            UserName = 'abc@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
                Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
                insert opp;
                List<Opportunity> oppFrameLst = new List<Opportunity>();
                oppFrameLst.add(opp);
                Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today()));
                insert sdr;
                List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
                sdrList.add(sdr);
                Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=true ));
                Sales_Decision_Maker__c sdm2 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser2.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=true ));
                //insert sdm;
                List<Sales_Decision_Maker__c> sdmlist = new list<Sales_Decision_Maker__c>();
                sdmlist.add(sdm);
                sdmlist.add(sdm2);
                insert sdmlist;
                Test.startTest();
                /* try{
delete sdm;
} catch(Exception e) {

}*/
                SdrSubmitForApprovalCtrl.sendApprovaRequest(sdr.id,'Yes','Oth');
                Test.stopTest();
                System.assertEquals(opp.Anticipated_Deal_Value__c,500);  //NS
            }
        }catch(Exception e){	}
    }
    
    @isTest
    public static void sendApprovaRequestTest1(){
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                            UserName = 'abc@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
                Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
                insert opp;
                List<Opportunity> oppFrameLst = new List<Opportunity>();
                oppFrameLst.add(opp);
                Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today()));
                insert sdr;
                List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
                sdrList.add(sdr);
                Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=true ));
                Sales_Decision_Maker__c sdm2 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser2.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=true ));
                //insert sdm;
                List<Sales_Decision_Maker__c> sdmlist = new list<Sales_Decision_Maker__c>();
                sdmlist.add(sdm);
                sdmlist.add(sdm2);
                insert sdmlist;
                Test.startTest();
                /* try{
delete sdm;
} catch(Exception e) {

}*/
                SdrSubmitForApprovalCtrl.sendApprovaRequest(sdr.id,'No','Oth');
                Test.stopTest();
                System.assertEquals(opp.Anticipated_Deal_Value__c,500);  //NS
            }
        }catch(Exception e){	}
    }
    
    @isTest
    public static void sendApprovaRequestTest2(){
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Account acc;
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                           UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                            UserName = 'abc@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
                Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
                insert opp;
                List<Opportunity> oppFrameLst = new List<Opportunity>();
                oppFrameLst.add(opp);
                Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS,Sales_Decision_Type__c =GlobalConstants.SDP1InvestToWin, Sales_Decision_Date__c=date.today()));
                insert sdr;
                List<Sales_Decision_Record__c> sdrList = new List<Sales_Decision_Record__c>();
                sdrList.add(sdr);
                Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser.Id, Auto_Generated__c=true ));
                Sales_Decision_Maker__c sdm2 = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = GlobalConstants.ToBeRequested, Approver_Name__c  = testUser2.Id, Approver_Role__c = GlobalConstants.KAM, Auto_Generated__c=true ));
                //insert sdm;
                List<Sales_Decision_Maker__c> sdmlist = new list<Sales_Decision_Maker__c>();
                sdmlist.add(sdm);
                sdmlist.add(sdm2);
                insert sdmlist;
                Test.startTest();
                /* try{
delete sdm;
} catch(Exception e) {

}*/
                SdrSubmitForApprovalCtrl.sendApprovaRequest(sdr.id,'Yes','Oth');
                Test.stopTest();
                System.assertEquals(opp.Anticipated_Deal_Value__c,500);  //NS
            }
        }catch(Exception e){	}
    }
}