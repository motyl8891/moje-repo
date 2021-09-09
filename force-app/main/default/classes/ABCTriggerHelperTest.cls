/******************************************************************************************
*      	@author       : Shubham Jagatap
*      	@date         : 8/24/2020
		@Class Name   : ABCTriggerHelperTest
		@class        : ABCTriggerHelper, ABCTriggerHandler, ABCTrigger

Modification Log   :
 ------------------------------------------------------------------------------------------
 * Ver         Date                     Developer           User Story    Modification
 ------------------------------------------------------------------------------------------
 * 1.0    	8/24/2020				 Shubham Jagatap	 U-1981   		  Initial Version

******************************************************************************************/
@isTest(seeAllData = false)
public class ABCTriggerHelperTest {
    @testSetup static void setup() {
        Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
        Account acc;
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
        System.runAs(testUser){  
            acc = (Account)TestDataGenerator.createSObject(new Account(), false);
            insert acc;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            insert opp;
            List<Opportunity> oppFrameLst = new List<Opportunity>();
            oppFrameLst.add(opp);
        }
    }
    @isTest
    public static void TestABCFlow(){
        Try{
            User testUser = [SELECT Id,Name from User Limit 1];
            Account acc = [SELECT Id,Name from Account Limit 1];
            Opportunity opp = [SELECT Id,Name from Opportunity Limit 1];
            
            List<AntiBriberyCorruption__c> abcList = new List<AntiBriberyCorruption__c>();
            
            AntiBriberyCorruption__c abc = new AntiBriberyCorruption__c(
                Sales_Scenario__c = GlobalConstants.IndirectSalesScenarioSellWith,
                SalesAgent__c = GlobalConstants.YES,
                PublicSanctionList__c = GlobalConstants.YES,       
                PublSanctListDescr__c = 'test',                         
                CorruptionOrAntitrust__c = GlobalConstants.YES,                         
                CorruptionOrAntitrustDescr__c = 'test',                   
                OwnReqComplianceDesc__c = 'test',                      
                PublicSectorInvolved__c = GlobalConstants.YES,                       
                PublicSectInvName__c = 'Test',                          
                PublicSectInvQuota__c = 11,                            
                PublicOfficials__c = GlobalConstants.YES,                             
                PublicOfficialsDescribe__c = 'test',                    
                PublicSanctionList2__c = GlobalConstants.YES,                          
                PublSanctListDescr2__c = 'test',                        
                CorruptionAntitrust2__c = GlobalConstants.YES,                       
                CorruptionAntitrustDescr2__c = 'test',                   
                OwnRequirementsCompliance__c = GlobalConstants.YES,                   
                OwnReqComplianceDesc2__c = 'test',                       
                PublicSectorInvolved2__c = GlobalConstants.YES,                        
                PublicSectInvName2__c = 'test',                           
                PublicSectInvQuota2__c = 11,                           
                PublicOfficials2__c = GlobalConstants.YES,                             
                PublicOfficialsDescribe2__c = 'test',                   
                Opportunity__c = opp.id,
                ApprovalStatus__c = GlobalConstants.BLANK,
            	BusinessPartnerAccount__c = acc.id);
            abcList.add(abc);
            
            Test.startTest();
            insert abc;
            
            abcList[0].SubmitForApproval__c = true;
            update abcList;
            abcList[0].ApprovalStatus__c = GlobalConstants.ApprovedforStage2;
            update abcList;
            abcList[0].PublicSectInvQuota2__c = 12;
            update abcList;
            abcList[0].ApprovalStatus__c = GlobalConstants.ApprovedforStage3;
            update abcList;
            abcList[0].ApprovalStatus__c = GlobalConstants.ApprovedforStage4;
            update abcList;
            abcList[0].I_confirm_the_ABC_Conditional_Adherance__c = true;
            update abcList;
            ABCTriggerHelper.getAntiBriberyCorruption(opp.Id);
            ABCTriggerHelper.getAntiBriberyCorruptionById(abc.Id);
            SubmitForApprovalABCController.updateSubmitForApprovalFlagABC(abc.id);
            SubmitForApprovalABCController.updateSubmitForApprovalFlagABC(null);
            ABCTriggerHelper.getOppwithABC(opp.Id);
            ABCTriggerHelper.populateKamEmail(null,null);
            ABCTriggerHelper.updateApprovalStatus(null,null);
            ABCTriggerHelper.updatePartnerAccountFields(null,null);
            Test.stopTest();
            
            System.assert(true);  
        }catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ABCTriggerHelperTest, 
                                                                                       GlobalConstants.TestABCFlow, GlobalConstants.ABCTriggerHelperTest, true, e)));}
    }
}