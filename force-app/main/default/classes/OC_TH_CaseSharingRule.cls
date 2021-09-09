/* Class Name : OC_TH_CaseSharingRule
* Description : This class handles CaseMilestone logic.
* Author      : IBM.
*/
public without sharing class OC_TH_CaseSharingRule {
     /****************************************************************************************
@ Description : This method handles to Share LICSR(cases) with respective country public groups
***************************************************************************************/
    public static void shareCaseWithPublicGroup(set<Id> caseSharingID){

        Map<Id,Case> mapCaseIdAndBillingCountry = new Map<Id,Case>();
        Set<String> setCaseCountry = new Set<String>();
        Set<String> setGroupDeveloperName = new Set<String>();
        
        //Id accountServiceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAccountServiceRecordType).getRecordTypeId();
        try{
            List<Case> csList = [SELECT Id,CaseNumber,Account.Name, Account.BillingCountry, Owner.Name,OwnerId, OC_TH_LI_CSR__c FROM Case 
                                 WHERE OC_TH_LI_CSR__c = True 
                                  
                                 AND Id =: caseSharingID];//AND Account.RecordType.Id =: accountServiceRecordType
            for(Case caselist : csList){      
                /*Set to store case country*/
                setCaseCountry.add(caselist.Account.BillingCountry);
                mapCaseIdAndBillingCountry.put(caselist.Id,caselist);
            }
            
            Map<String,String> mapBillingCountryAndGroup = new Map<String,String>();
            for(OC_TH_LICSR_Country__mdt licsrMdt : [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                     WHERE OC_TH_Accout_Billing_Country__c =: setCaseCountry
                                                     AND OC_TH_Public_Group_Country__c != null]){
                                                         mapBillingCountryAndGroup.put(licsrMdt.OC_TH_Accout_Billing_Country__c,licsrMdt.OC_TH_Public_Group_Country__c);
                                                         setGroupDeveloperName.add(licsrMdt.OC_TH_Public_Group_Country__c);
                                                     }
            
            Map<String,Id> mapIdAndDeveloperName = new Map<String,Id>();
            for(Group grp : [Select Id,Type,DeveloperName, Name from Group where DeveloperName =: setGroupDeveloperName]){
                mapIdAndDeveloperName.put(grp.DeveloperName,grp.ID);
            }
            
            List<caseShare> csShareList = new List<caseShare>();
            if(mapCaseIdAndBillingCountry != null){
                for(Case cs : mapCaseIdAndBillingCountry.values()){
                    String caseAccountBillingCountry = cs.Account.BillingCountry;
                    if(!mapBillingCountryAndGroup.isEmpty() && mapBillingCountryAndGroup.containsKey(caseAccountBillingCountry)){
                        String accbill =  mapBillingCountryAndGroup.get(caseAccountBillingCountry);
                        if(!mapIdAndDeveloperName.isEmpty() && mapIdAndDeveloperName.containsKey(accbill)){
                            Id grpId = mapIdAndDeveloperName.get(accbill);
                            caseShare csShare = new caseShare();
                            csShare.CaseId = cs.Id;
                            csShare.CaseAccessLevel = 'Edit';
                            csShare.UserOrGroupId = grpId;
                            csShareList.add(csShare);
                        }
                    }
                }  
            }
            if(csShareList.size()>0){   
                DataBase.upsert(csShareList);
            } 
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_CaseSharingRule,OC_TH_Constants.method_shareCaseWithPublicGroup,null, false, e));
        }   
    }  
}