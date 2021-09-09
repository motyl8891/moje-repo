@isTest
public class SDPMeetingInviteControllerTest {
    
@isTest
  public static void sendInviteURLTest(){
    Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        User testUser1 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson00077@test.com'+System.currentTimeMillis()),true);
      User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson977@test.com'+System.currentTimeMillis()),true);
      System.runAs(testUser){ 
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
        } 
      List<Opportunity> oppList= New List<Opportunity>();
      List<Sales_Decision_Record__c> sdrList =new List<Sales_Decision_Record__c>();
        Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.frameOppRecordTypeId, Anticipated_Deal_Value__c = 500,GCU_Commercial_Director__c=testUser.id,Kam__c=testUser1.id));   
        Opportunity opp1 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.frameOppRecordTypeId, Anticipated_Deal_Value__c = 500));  
      Opportunity opp2 = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = GlobalConstants.frameOppRecordTypeId, Anticipated_Deal_Value__c = 500,GCU_Commercial_Director__c=testUser.id,Kam__c=testUser1.id));   
        oppList.add(opp);
       oppList.add(opp1);
      oppList.add(opp2);
      insert oppList;
      Sales_Decision_Record__c sdr1= new Sales_Decision_Record__c(Name='SDR',Opportunity__c=opp.id,Sales_Decision_Type__c='SDP0 Qualify' );
      Sales_Decision_Record__c sdr2= new Sales_Decision_Record__c(Name='SDR',Opportunity__c=opp1.id,Sales_Decision_Type__c='SDP1 Invest to Win' );
      sdrList.add(sdr1);
      sdrList.add(sdr2);
      insert sdrList;
      Sales_Decision_Maker__c sdm1 = new Sales_Decision_Maker__c(Sales_Decision_Record__c=sdr1.id,Approver_Name__c=testUser.id,Approver_Role__c='KAM');
      insert sdm1;
      Sales_Decision_Maker__c sdm2 = new Sales_Decision_Maker__c(Sales_Decision_Record__c=sdr1.id,Approver_Name__c=testUser1.id,Approver_Role__c='KAM');
      insert sdm2;
       Employee__c emp1 = new Employee__c(Name='test', Email__c=testUser.Email,   Signum__c = 'test', Status__c = 'Active' );
         insert emp1;
      Employee__c emp2 = new Employee__c(Name='test', Email__c=testUser2.Email,   Signum__c = 'testing', Status__c = 'Active' );
         insert emp2;
       Opportunity_Sales_Team__c ST1 =(Opportunity_Sales_team__c)TestDataGenerator.createSObject(new Opportunity_Sales_team__c(Opportunity__c= Opp.Id, Employee__c=emp1.id, Role__c=GlobalConstants.ACR,CurrencyIsoCode='INR'));
          insert ST1;
      Opportunity_Sales_Team__c ST2 =(Opportunity_Sales_team__c)TestDataGenerator.createSObject(new Opportunity_Sales_team__c(Opportunity__c= Opp.Id, Employee__c=emp2.id, Role__c=GlobalConstants.ACR,CurrencyIsoCode='INR'));
          insert ST2;
      SDPMeetingInviteController.sendInviteURL(sdr1.id);
      SDPMeetingInviteController.sendInviteURL(sdr2.id);
      SDPMeetingInviteController.sendInviteURL(null);
      SDPMeetingInviteController.getSalesTeamEmails(opp2.id);
          }    

}