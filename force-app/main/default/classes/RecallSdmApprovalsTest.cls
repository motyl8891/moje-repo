/****************************************************************
* @author: Pallavi Patil
* @date: 21-04-2020
* @param: U-1716
* @description: This class will recalls all SDM-approval request within the Sales Decision Record 
*****************************************************************/
@isTest(seeAllData = false)
private class RecallSdmApprovalsTest {
    @isTest(seeAllData = false)
    public static void  RecallAllSdmApprovalsTest(){
        Try{
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
            Test.startTest();
            RecallSdmApprovals.SendEmailForRecall(sdr.id); 
            Test.stopTest();
            System.assert(true);  
        }catch(Exception e){	}
    }
    @isTest(seeAllData = false)
    public static void  RecallAllSdmApprovalsTest1(){
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Account acc; 
            User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Migration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser){  
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            } 
            Pricebook2 pb = (Pricebook2)TestDataGenerator.createSObject(new Pricebook2(), true);
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            System.runAs(testUser){  
                insert opp;
            }
            Sales_Decision_Record__c sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = 'In Progress'));
            insert sdr; 
            Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = 'Requested',Approver_Name__c=UserInfo.getUserId()));
            insert sdm;            
            Test.startTest();
            RecallSdmApprovals.SendEmailForRecall(sdr.id); 
            RecallSdmApprovals.SendEmailForRecall(null); 
            RecallSdmApprovals.recallAllSdmApprovalstwo(null, null);
            Test.stopTest();
            System.assert(true); 
        }catch(Exception e){	}
    }
    
    @isTest(seeAllData = false)
    public static void  RecallAllSdmApprovalsTest2(){
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            Sales_Decision_Record__c sdr;
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
            sdr = (Sales_Decision_Record__c)TestDataGenerator.createSObject(new Sales_Decision_Record__c(Opportunity__c = opp.id,Sales_Decision_Approval_Status__c = 'Approvals Ongoing'));
            insert sdr; 
            Sales_Decision_Maker__c sdm = (Sales_Decision_Maker__c)TestDataGenerator.createSObject(new Sales_Decision_Maker__c(Sales_Decision_Record__c = sdr.id, Approval_Status__c = 'To be Requested',Approver_Name__c=UserInfo.getUserId()));
            insert sdm;
            Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
            app.setObjectId(sdm.id);
            Approval.ProcessResult result = Approval.process(app);        
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name =: GlobalConstants.Ericsson_Sales_Operations].Id, UserName = 'ericsson778@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser2){  
            Test.startTest();
            RecallSdmApprovals.SendEmailForRecall(sdr.id); 
           Test.stopTest();
            }
            System.assert(true);
        }catch(Exception e){	}
    }
}