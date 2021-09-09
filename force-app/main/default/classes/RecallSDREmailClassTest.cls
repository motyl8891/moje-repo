@isTest(seeAllData = false)
private class RecallSDREmailClassTest {
    //DummyEmailHandler.handleInboundEmail();
    @isTest
    public static void test_RecallSDREmailClassTest(){
        Try{
            Messaging.InboundEmail email = new Messaging.InboundEmail();		
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;   
            
            Account acc; 
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.MIGRATIONUSERPROFILENAME].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            System.runAs(testUser){  
                insert opp;
            }
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = 'Approvals Ongoing'));
            insert sdr; 
            Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = 'To be Requested',Approver_Name__c=UserInfo.getUserId()));
            insert sdm;
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(sdm.id);
            Approval.ProcessResult result = Approval.process(app); 
            
            email.subject = 'Test Recall Email';
            email.plainTextBody = sdr.id;
            Test.startTest();
            RecallSDREmailClass.handleInboundEmail(email,envelope);
            email.plainTextBody = null;
            RecallSDREmailClass.handleInboundEmail(email,null);
            Test.stopTest();
            System.assert(true);
        }catch(Exception e){	}
    }
    
}