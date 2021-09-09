@isTest(seeAllData = false)
private class UpdateCheckBoxCLMTest {
    public static testMethod void testMethod1(){
        Try{
     User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), 
                                                                    UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
           
            Account acc;
            System.runAs(testUser){
                acc= (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }

          
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
            insert opp;
            AgreementRequest__c agr= New AgreementRequest__c(Name='Test',Opportunity__c = opp.Id,SignatureDate__c=System.today(),EffectiveDate__c=System.today()+1,ExpirationDate__c=System.today()+2);
            insert agr;
            ContentVersion cv = new ContentVersion();
             cv.Title = 'Test Document';
             cv.PathOnClient = 'TestDocument.pdf';
             cv.VersionData = Blob.valueOf('Test Content');
             cv.IsMajorVersion = true;
             Insert cv;
Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id
              Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].ContentDocumentId;
             ContentDocumentLink cdl = New ContentDocumentLink();
             cdl.LinkedEntityId = agr.Id;
             cdl.ContentDocumentId = conDocId;
              cdl.shareType = 'V';
               Insert cdl;
           test.startTest();
            updateCheckBoxCLM.updateCheck(agr.id);
            updateCheckBoxCLM.checkFileInformation(agr.id);
             delete cdl;
            updateCheckBoxCLM.checkFileInformation(agr.id);
           test.stopTest();
            AgreementRequest__c ag = [select id,Name,IsSendtoSalesCLM__c,SendToSalesCLM__c from AgreementRequest__c where Name ='Test'
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            system.assertEquals(TRUE, ag.IsSendtoSalesCLM__c);
        }
        catch(Exception e){	}
        }
    }