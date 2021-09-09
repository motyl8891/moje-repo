public with sharing class LeadConvertController
{
   
   public ApexPages.StandardSetController standardSetController;
   public List<ID> recordIds { get; private set; }
   
    public LeadConvertController(ApexPages.StandardSetController standardSetController)
    {   
        this.recordIds = new List<ID>();
       string pname= [select id,profile.name from user where id=:UserInfo.getUserId()].profile.name;
        for (SObject obj : standardSetController.getSelected() ) {
            recordIds.add(obj.id);
        }
     }
 @AuraEnabled
 public static List <account> fetchAccounts(String searchKeyWord) {
  String searchKey = searchKeyWord + '%';
  List <Account> lstOfAccount = [select id, Name,MDM_Customer_Id__c from account
                                   where Name LIKE: searchKey];
  
  return lstOfAccount;
   }
 
 @AuraEnabled
 Public static void selectedleads(list<id> leadIds,id accId){
     Try{
  string dupEmail;
  string mandateld;
 list<contact> conlist = new list<contact>();
 list<lead> dellds = new list<lead>();
 list<lead> ldslist = new list<lead>(); 
 list<string> lderrors = new list<string>();
 list<contact> conEmails = new list<contact>();
 set<string> ldEmails = new set<string>();
 if(leadIds.size() > 0) 
  ldslist= [select id,name,firstname,lastname,email,phone,country,status,mkto71_Acquisition_Date__c,
                     mkto71_Acquisition_Program__c,Converted_From_Lead__c,Department_Function__c,mkto_si__Priority__c,
                     mkto_si__Last_Interesting_Moment_Date__c,mkto_si__Last_Interesting_Moment_Desc__c,mkto_si__Last_Interesting_Moment_Source__c,mkto_si__Last_Interesting_Moment_Type__c,
                     Lead_Status_Formula__c,Rejected_Reason__c,Reject_Reason_Explanation__c,mkto_si__Relative_Score_Value__c,
                     RelativeUrgency__c,Sales_Inquiry__c,mkto71_Lead_Score__c,mkto_si__Urgency_Value__c from lead where id in: leadIds];
  for(lead ld: ldslist){
   contact con = new contact(
   firstname= ld.firstname,
   lastname= ld.lastname,
   email = ld.email,
   phone=ld.phone,
   Accountid= accId,
   MailingCountry = ld.country,
   mkto71_Acquisition_Date__c = ld.mkto71_Acquisition_Date__c,
   mkto71_Acquisition_Program__c = ld.mkto71_Acquisition_Program__c,
   ConvertedFromLead__c=ld.Converted_From_Lead__c,
   Department__c = ld.Department_Function__c,
   mkto_si__Priority__c = ld.mkto_si__Priority__c,
   mkto_si__Last_Interesting_Moment_Date__c = ld.mkto_si__Last_Interesting_Moment_Date__c,
   mkto_si__Last_Interesting_Moment_Desc__c = ld.mkto_si__Last_Interesting_Moment_Desc__c,
   mkto_si__Last_Interesting_Moment_Source__c = ld.mkto_si__Last_Interesting_Moment_Source__c,
   mkto_si__Last_Interesting_Moment_Type__c = ld.mkto_si__Last_Interesting_Moment_Type__c,
   Marketing_Status__c = ld.Lead_Status_Formula__c,
   Rejected_Reason__c = ld.Rejected_Reason__c,
   Rejection_Reason_Explanation__c = ld.Reject_Reason_Explanation__c,
   mkto_si__Relative_Score_Value__c = ld.mkto_si__Relative_Score_Value__c,
   RelativeUrgency__c = ld.RelativeUrgency__c,
   Sales_Inquiry__c = ld.Sales_Inquiry__c,
   mkto71_Lead_Score__c = ld.mkto71_Lead_Score__c,
   mkto_si__Urgency_Value__c = ld.mkto_si__Urgency_Value__c
   );
   ld.status='Converted';
   ldEmails.add(ld.Email);
   conlist.add(con);
   dellds.add(ld);
   if(ld.email == null && ld.phone == null){
     mandateld = 'EmailPhone';
     validateLeads();
   }
  }
 
 if(ldEmails.size()>0 || ldEmails.size() != null){
  conEmails = [select id,email from contact where email in : ldEmails and email != null];
  if(conEmails.size()>0 || conEmails.size() != null){
     dupEmail = 'Email';
     validateLeads();
  }}
   
    update ldslist;
    delete dellds;
    insert conlist;
   }catch(Exception e){	}
  }
 
 @AuraEnabled
 
 public static string validateLeads(){
  string mandateld = 'EmailPhone';
  return mandateld;
 }
 
  }