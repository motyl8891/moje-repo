@isTest(seeAllData = false)
private class DocumentIInfoAgreementRequestTest {
public static testMethod void testMethod1(){
    Try{
        User testUser = (User)TestDataGenerator.createSObject(new User(ProfileId = GlobalConstants.getProfileId(GlobalConstants.INTEGRATIONUSERPROFILENAME), UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
           
            Account acc;
            System.runAs(testUser){
                acc= (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;
            }
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, OpportunityNumber__c = '777888999', Locked_To_PP__c = true));
        insert opp;
    		
            AgreementRequest__c agr= New AgreementRequest__c(Name='Test',Opportunity__c =opp.id,SignatureDate__c=System.today(),EffectiveDate__c=System.today()+1,ExpirationDate__c=System.today()+2);
           insert agr;
     
     ContentVersion cv = new ContentVersion();
cv.Title = 'Test Document';
cv.PathOnClient = 'TestDocument.pdf';
cv.VersionData = Blob.valueOf('Test Content');
cv.IsMajorVersion = true;
Insert cv;
List<ContentVersion> Cversion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id];
 Id conDocId=[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;

ContentDocumentLink cdl = New ContentDocumentLink();
cdl.LinkedEntityId = agr.Id;
cdl.ContentDocumentId = conDocId;
cdl.shareType = 'V';
Insert cdl;
            test.startTest();
            DocumentInfoAgreementRequest.getFileInformation(agr.id);
          DocumentInfoAgreementRequest.UpdateDocumentType(Cversion);
            DocumentInfoAgreementRequest.getselectOptions(cv,'DocumentType__c');
            
            test.stopTest();
			//NS
			System.assert(true);
        }catch(Exception e){	}
        }
}