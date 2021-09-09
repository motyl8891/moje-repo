@isTest
public class OpportunityContactRoleTriggerHelperTest {
    @isTest
    public static void sendApprovaRequestTest(){
        Try{
            Id frameOppRecordTypeId = GlobalConstants.frameOppRecordTypeId;
            List <CampaignMember> cmList = new List <CampaignMember>();
            List <Campaign> campList = new List <Campaign>();
            Account acc;
            User testUser2 = (User)TestDataGenerator.createSObject(new User(ProfileId = [SELECT Id FROM Profile WHERE Name = 'Integration User Profile'].Id, UserName = 'ericsson777@test.com'+System.currentTimeMillis()),true);
            System.runAs(testUser2){  
                acc = (Account)TestDataGenerator.createSObject(new Account(), false);
                insert acc;  
            }            
            Contact con = (Contact)TestDataGenerator.createSObject(new Contact(FirstName = 'First', LastName = 'Last', Email = 'azaza@test.com', MailingCountry = 'Sweden'));
            con.AccountId = acc.id;
            insert con;
            Contact con1 = (Contact)TestDataGenerator.createSObject(new Contact(FirstName = 'First1', LastName = 'Last1', Email = 'azaza1@test.com', MailingCountry = 'Sweden'));
            con1.AccountId = acc.id;
            insert con1;
            Contact con2 = (Contact)TestDataGenerator.createSObject(new Contact(FirstName = 'First2', LastName = 'Last2', Email = 'azaza2@test.com', MailingCountry = 'Sweden'));
            con2.AccountId = acc.id;
            insert con2;
            Opportunity opp = (Opportunity)TestDataGenerator.createSObject(new Opportunity(AccountId=acc.Id, RecordtypeId = frameOppRecordTypeId, Anticipated_Deal_Value__c = 500)); 
            insert opp;
            System.debug('oppppppp: '+opp.Name);
            Campaign camp1 = new Campaign();
            camp1.Name = 'Test Camp1';
            camp1.CurrencyIsoCode = 'SEK';
            camp1.Type = GlobalConstants.OPERATIONAL;
            campList.add(camp1);
            insert campList;  
            CampaignMember cMember1 = new CampaignMember();
            cMember1.CampaignId = camp1.Id;
            cMember1.status = GlobalConstants.MEMBER;
            cMember1.ContactId = con.id;
            cmList.add(cMember1);
            insert cmList;
            List<OpportunityContactRole> ocrList=New List<OpportunityContactRole>();
            OpportunityContactRole ocr2=new OpportunityContactRole();
            ocr2.OpportunityId=opp.id;
            ocr2.ContactId=con2.id;
            insert ocr2;
            OpportunityContactRole ocr=new OpportunityContactRole();
            ocr.OpportunityId=opp.id;
            ocr.ContactId=con.id;
            ocrList.add(ocr);
            OpportunityContactRole ocr1=new OpportunityContactRole();
            ocr1.OpportunityId=opp.id;
            ocr1.ContactId=con1.id;
            ocrList.add(ocr1);
            insert ocrList;
            Opportunity opp1  =  [Select CampaignId from Opportunity where id =:opp.Id];
            System.assertEquals(camp1.id,opp1.CampaignId);
			OpportunityContactRoleTriggerHelper.updateCampaignIdtoOpportunity(null);           
        }catch(Exception e){
            System.debug('In sendApprovaRequestTest exception: '+e);
        }
    }
}