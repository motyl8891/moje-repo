/**
 * @File Name          : SDODLHRAssignedLeadsClass.cls
 * @Description        : 
 * @Author             : Ananth Chilapally
 * @Group              : 
 * @Last Modified By   : Ananth Chilapally
 * @Last Modified On   : 2019-12-06 00:29:15
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    2019-12-06   Ananth Chilapally     Initial Version
**/
public class SDODLHRAssignedLeadsClass {
    @AuraEnabled
    public static List<SDOD_Lead__c> getAssignedLeads()
    {
        List<ID> idList=new List<ID>();
        List<SDOD_Lead__c> sdod=new List<SDOD_Lead__c>();
        Try{
        for(GroupMember gm:[select group.id,group.name,userorgroupid from groupmember where group.name Like 'SDOD%'
                                      and  userorgroupid=:userinfo.getUserId()])
			{
				idList.add(gm.group.id);
			}
			sdod=[select id,ownerid,Name,Created_by__c, CreatedDate, Stage__c, Title__c,toLabel(RecordType.name),MarketArea__c,CustomerUnit__c, Customer_Reporting_Group__r.Name, Business_Area__c,CurrencyIsoCode, Product_Or_Service_Area__c,LHR__r.Name, EA__r.Name, Status_of_Business__c
				  from SDOD_Lead__c where ownerid in :idList OR LHR__c=:userinfo.getUserId() order by CreatedDate desc];
            }catch(Exception e){	}
        return sdod;
               
    }
}