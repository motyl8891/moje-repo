/**
* @File Name          : SDODNewLeadController.cls
* @Description        : 
* @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
* @Group              : 
* @Last Modified By   : Ananth Chilapally
* @Last Modified On   : 2019-12-19 14:59:28
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author      		      Modification
*==============================================================================
* 1.0    2019-7-3 16:02:32   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
  1.1	 2020-22-7				Shubham Jagatap                     U-1903 - Replaced Hard coded values by global constants
**/
public without sharing class SDODNewLeadController {
    @AuraEnabled
    public static List<CustomerReportingGroup__c> getHitsAcc(string srchstring, string countryfilter) {
        
        string s = '%' + srchstring + '%';
        list<CustomerReportingGroup__c> a = [select Customer_Unit_Text__c , customerunit__r.Name, Market__c,Name,customerunit__c , id from CustomerReportingGroup__c where (name like :s or CustomerUnit__r.Name like :s) and market__c =:countryfilter 
                                             and customerunit__c!=null and DeletionFlag__c = false Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        return a;
    }
   
    @AuraEnabled
    public static List<Employee__c> getEmployees(string srchstring) {
        list<Employee__c> emp =new list<Employee__c>();
        try{
        string str = '%' + srchstring + '%';
        emp = [SELECT Id, First_Name__c, Last_Name__c, Email__c FROM Employee__c 
                                             WHERE (First_Name__c like :str or Last_Name__c like :str or Email__c like :str  
                                                    or Signum__c like :str or Name like :str) and Status__c != :GlobalConstants.INACTIVE Limit 20];    //U-1903
       }Catch(exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.getEmployees, GlobalConstants.SDODNewLeadController , true, e)));
			} return emp;
    }
    
    @AuraEnabled
    public static List<User> getHitsAcr(string srchstring) {
        list<user> a = new list<user>();
        Try{
        string s = '%' + srchstring + '%';
            //U-1903
        a = [select id,name from user where name like :s and SDOD_Organization_Type__c like :GlobalConstants.SDOD_ORGANIZATION_TYPE_EA
                       							 Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
       }Catch(exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.getHitsAcr, GlobalConstants.SDODNewLeadController , true, e)));
			} return a;
    }
    
    @AuraEnabled
    public static List<SDOD_Lead__c> getFilteredLeads(string srchstring) {
        list<Id> recordTypeIds=new list<Id>();
        list<SDOD_Lead__c> sdod=new list<SDOD_Lead__c>();
        list<SDOD_Lead__c> finalsdod=new list<SDOD_Lead__c>();
        try{
        sdod=[select RecordType.name,Id,Name,Creator_Email__c,Stage__c,how_to_identify__c,What_is_the_original_project_scope__c,
              MarketArea__c,Country__c,Business_Area__c,CommercialValue__c, Additional_Recorders__c,CreatedDate,Comment__c,Commodity__c,
              CreatedBy.FirstName,Created_by__c,RecordTypeId,Title__c,CustomerUnit__c,Customer_Reporting_Group__r.Name,
              Product_Or_Service_Area__c,CurrencyIsoCode,LHR__r.Name,EA__r.Name,LHR_Comments__c, Status_of_Business__c, How_was_it_sold_to_Customer__c from SDOD_Lead__c where 
              Id IN (select SDOD_Lead__c from Recorder__c where Recorder_Email__c =:srchstring) order by CreatedDate desc
             		Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())] ;
         }Catch(exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.getFilteredLeads, GlobalConstants.SDODNewLeadController , true, e)));
			}
        return sdod;       
    } 
  /****************************************************************
* @author: Manu Singhal  
* @date: 15-02-2020
* @param: sdodLis
* @description: This method will update SDOD leads(U-1259)
*****************************************************************/  
 /*   @AuraEnabled
    public static String updateLeads(list<SDOD_Lead__c> sdodList) {
        String message;
        List<SDOD_Lead__c> listToUpdate = new List<SDOD_Lead__c>();
        Map<id,SDOD_Lead__c> sdodLeadMap = new Map<id,SDOD_Lead__c>();
        try{
            for(SDOD_Lead__c sdodLead : sdodList)
                sdodLeadMap.put(sdodLead.id,sdodLead); 
            for(SDOD_Lead__c sdodLead : [select RecordType.name,Id,Stage__c 
                                         from SDOD_Lead__c 
                                         where id in : sdodLeadMap.keySet()
                                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())])
            {
                if(sdodLead.Stage__c == GlobalConstants.DRecorded)
                {
                    if(sdodLeadMap.get(sdodLead.id).What_is_the_original_project_scope__c != null && sdodLead.RecordType.name != GlobalConstants.AoS)
                        message = GlobalConstants.ErrorForSOG;
                    else
                        listToUpdate.add(sdodLead);    
                }
            }
            if(!listToUpdate.isEmpty() && String.isBlank(message))
            {
                database.update(sdodList);
                message = GlobalConstants.SUCCESS;
            }       
        }
        catch(Exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, 
                                                                                      GlobalConstants.updateLeads, GlobalConstants.SDODNewLeadController , true, e)));                                         
                          }
        return message;                           
    }  */
    
    @AuraEnabled
    public static List<User> getHitsLHR(string srchstring) {
        string s = '%' + srchstring + '%';
        list<user> a = [select id,name from user where name like :s and SDOD_Organization_Type__c like 'SDOD%LHR%'
                       							 Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        return a;
    }
    
    
    @AuraEnabled
    public static string getCU(string srchstring) {
        String s;
        try{
        list<CustomerReportingGroup__c> a = [select name,customerunit__c , id from CustomerReportingGroup__c where id=:srchstring limit 1];
        s = a[0].customerunit__c;
          }Catch(exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.getCU, GlobalConstants.SDODNewLeadController , true, e)));
			}return s;
    }
    
    /*@AuraEnabled
public static List<Product2> getHitsProd(string srchstring) {
string s = srchstring + '%';
list<Product2> a = [select name, id from Product2 where name like :s];
return a;
}

@AuraEnabled
public static list<contract> getContracts(string accid) {
list<contract> contracts = [select Id, StartDate, ContractNumber from contract where accountid =:accid limit 50];
return contracts;
}
@AuraEnabled
public static list<Opportunity> getOpportunity(string accid) {
list<Opportunity> opps = [select Id, Name, CloseDate, StageName, Amount from opportunity where accountid =:accid limit 50];
return opps;
}  
@AuraEnabled
public static Account getchosenAccountapex(string accid) {
Account a = [select Id, Name from Account where id =:accid limit 1];
return a;
}
@AuraEnabled
public static string getRealProdName(string pid) {
product2 p = [select name from product2 where id=:pid limit 1];
return p.name;
}
@AuraEnabled
public static string getUserDetailsApex() {
Id userId = UserInfo.getUserId();
return [SELECT SDOD_Organization_Type__c FROM User WHERE Id = :userId].SDOD_Organization_Type__c;
}
@AuraEnabled
public static string insertLeadapex(SDOD_Lead__c sdod) {
insert sdod;
return sdod.id;
}

@AuraEnabled
public static void insertProds(list<SDOD_Product__c> lp, string l) {
list<SDOD_Product__c> listtoinsert = new list<SDOD_Product__c>();
for(SDOD_Product__c p: lp){p.SDOD_Lead__c = l;listtoinsert.add(p);}
insert listtoinsert;
}
@AuraEnabled
public static void insertProdapex(list<string> sh, string parent) {
list<SDOD_Product__c> listtoinsert = new list<SDOD_Product__c>();
for(string s:sh){
List<String> parts = s.split('\\|');
SDOD_Product__c Sprod = new SDOD_Product__c(Product__c = parts[1], Number__c=decimal.valueof(parts[0]), SDOD_Lead__c = parent);
listtoinsert.add(Sprod);}
insert listtoinsert;
}

@AuraEnabled
public static opportunity getOpportunityID(string sdod) {
return [SELECT id,name,closedate,amount ,currencyisocode FROM Opportunity WHERE SDOD_Lead__c = :sdod limit 1];
}*/
    
    @AuraEnabled
    Public static string UpdateCreatedBy(id createdBy,string creatoremail){
        string LeadName;
        TRY{
        list<sdod_lead__c> slead = new list<sdod_lead__c>();
            //NS
        for(sdod_lead__c sd: [select id,Creator_Email__c,Name from sdod_lead__c where id =: createdBy Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]){
            sd.Creator_Email__c = creatoremail;
            slead.add(sd);
            LeadName=sd.Name;
        }
        update slead;
            }Catch(exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.UpdateCreatedBy, GlobalConstants.SDODNewLeadController , true, e)));
}
        return LeadName;
    }
      /****************************************************************
* @author: Richa Gupta  
* @date: 08-06-2020
* @param: Sdodid
* @description: This method will get SDOD leads Information (U-1695)
*****************************************************************/  

    @AuraEnabled
    Public static SDOD_Lead__c getRecordInformation(id recordId){
        SDOD_Lead__c sdod;
        try{
     sdod =[select RecordType.name,Id,Name,Stage__c,how_to_identify__c,What_is_the_original_project_scope__c,How_was_it_sold_to_Customer__c,
              MarketArea__c,Country__c,Business_Area__c,CommercialValue__c,RecordTypeId,Title__c,CustomerUnit__c,Customer_Reporting_Group__r.Name,Commodity__c,
                          Product_Or_Service_Area__c,CurrencyIsoCode,LHR__r.Name,EA__r.Name,LHR_Comments__c, Status_of_Business__c from SDOD_Lead__c where id=:recordId
                                         Limit 1];
       
        }Catch(exception e){EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.getRecordInformation, GlobalConstants.SDODNewLeadController , true, e)));}
      return sdod;
    }
    /****************************************************************
* @author: Richa Gupta  
* @date: 10-06-2020
* @param: Sdodid
* @description: This method will Update SDOD lead (U-1695)
*****************************************************************/  
    @AuraEnabled
    public static String updateRecord(SDOD_Lead__c recSdod) {
        String message;
        try{
            update recSdod;
         	message = GlobalConstants.SUCCESS;
        }catch(exception e){
            if(e.getMessage().contains(GlobalConstants.SDORERRORINFO)) {
                message =GlobalConstants.SDORERRORINFO;
            }else {
                message = GlobalConstants.SDODERROR;
            }
   			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SDODNewLeadController, GlobalConstants.updateRecord, GlobalConstants.SDODNewLeadController , true, e)));
		}
        return message;
    }
    
}