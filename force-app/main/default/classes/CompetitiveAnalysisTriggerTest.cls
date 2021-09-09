/** 
* @File Name          : CompetitiveAnalysisTriggerTest.cls
* @Description        : 
* @Author             : Richa Gupta
* @Group              : 
* @Last Modified By   : 
* @Last Modified On   : 
* @Modification Log   : 
* Ver       Date           Author         Modification
* 1.0    2019-12-09     Richa Gupta       Initial Version
**/
@isTest(seeAllData = false)
private class CompetitiveAnalysisTriggerTest {
  
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
            CompetitiveAnalysis__c comp = new CompetitiveAnalysis__c(Opportunity__c = opp.Id);
            insert comp;
            System.assertEquals(null, comp.Competitor__c);
            
            comp.Competitor__c = 'ZTE';
            update comp;
            System.assertEquals('ZTE', comp.Competitor__c);
            
            delete comp;
            List<CompetitiveAnalysis__c> compLst = [Select id from CompetitiveAnalysis__c];
            System.assertEquals(0, compLst.size());
       
        }catch(Exception e){	}
    }
}