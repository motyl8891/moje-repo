/**
* @File Name          :     
* @Description        : Collection of Utility Methods in System Context
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 21st Aug 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-07-20                 IBM                   Initial Version
* 2.0        2020-09-18                 IBM                   Class temporarily created while discussion on a Salesforce ticket was in progress.
Customer was not able to update the task from community and was getting the exception of Insufficient Cross reference Id.
As confirmed on Salesforce ticket - 27400238, Customer profile must be given Write permission on Account via Sharing set to be able to update a task.
Hence, updating the task in with sharing context in class "OC_ContentControllerTicketHandling" and giving Write access to "Customer Community Plus Custom User" profile in Sharing Set.
*3.0         2021-03-23                 IBM                   Assets Validation for Erricsion Basic Support
*4.0         2021-03-31                 IBM                   'Ericsson Basic Product Support' value is replaced by System.Label.OC_TH_BasicProductSupport
*5.0         2021-06-14                 IBM                   Adding 'GetRoutingRulesList' method to fetch all the active initial routing rules for Case Queue Assignment
*6.0 		 2021-08-26					IBM                   u-2964 display case milestone in partialView and Collaboration CSR.
*/
public without sharing class OC_SystemUtility {
    
    /**************************************************************************************
* @Description  This method updates the Task record in system mode
* @Param        Task record
* @Return       None
**************************************************************************************/ 
    /*Public Static void updateRecord(Task taskRecord) {
try {
Database.update (taskRecord,false);
}catch (StringException e){
throw new AuraHandledException('You do not have permission to perform this action. Please contact you administrator.');
}       
}*/
    
    /**************************************************************************************
* @Description  This method Check for the asset Validation in system mode
* @Param        Asset record
* @Return       None
**************************************************************************************/ 
    
    Public Static Boolean AssetValidationcheckforwithoutsharing(Id assetId) {
        Boolean checkValidation=false;
        for(OC_MD_Installed_Base_Item__c ibt:[select id,OC_MD_Service_Contract__r.OC_CSM_Contract_Type__c,OC_MD_Service_Contract__r.status 
                                              from OC_MD_Installed_Base_Item__c where OC_MD_Asset__c=:assetId ]){
                                                  if(ibt.OC_MD_Service_Contract__r.status == 'Active'){
                                                      if(ibt.OC_MD_Service_Contract__r.OC_CSM_Contract_Type__c== System.Label.OC_TH_BasicProductSupport){
                                                          checkValidation=true;
                                                      } else{
                                                          return checkValidation=false;
                                                      }
                                                  } 
                                              }
        return checkValidation;
    }
    /**************************************************************************************
* @Description : method to fetch all the active initial routing rules for Case Queue Assignment
**************************************************************************************/ 
    public static List<OC_TH_Routing_Rules__c> GetRoutingRulesList(){
        List<OC_TH_Routing_Rules__c> routingRuleList = [select id,Name,OC_TH_Customer_Market_Area__c,OC_TH_Customer_CU__c,
                                                        OC_TH_Customer_Country__c,OC_TH_CSR_Priority_txt__c,OC_TH_NodeTypeProduct__c,
                                                        OC_TH_NodeComponentProduct__c,OC_TH_SolutionProduct__c,OC_TH_Contract_Type__c,
                                                        Tech_OC_TH_Service_To_Party_ID__c,OC_TH_Selected_Queue_Text__c,
                                                        OC_TH_Active__c,OC_TH_Total_Relevance_Point__c,OC_TH_Logic_Operator_Customer__c,
                                                        OC_TH_Logic_Operator_Country__c,OC_TH_Queue__c,OC_TH_Queue__r.name 
                                                        from OC_TH_Routing_Rules__c where OC_TH_Selected_Queue_Text__c 
                                                        LIKE '%Initial Routing%' AND OC_TH_Active__c = true 
                                                        order by OC_TH_Total_Relevance_Point__c DESC];        
        return routingRuleList;   
        
    }
    /****************************************************************************************
@ Description : This method handles to Share LICSR(cases) with respective country public groups
***************************************************************************************/
    public static void shareCaseWithPublicGroup(set<Id> caseSharingID){
        Map<Id,Case> mapCaseIdAndBillingCountry = new Map<Id,Case>();
        Set<String> setCaseCountry = new Set<String>();
        Set<String> setGroupDeveloperName = new Set<String>();
        Map<String,String> mapBillingCountryAndGroup = new Map<String,String>();
        Map<String,Id> mapIdAndDeveloperName = new Map<String,Id>();
        List<caseShare> csShareList = new List<caseShare>();
        Map<Id,caseShare> caseSharingMap = new Map<Id,caseShare>();
        try{
            List<Case> csList = [SELECT Id,CaseNumber,Account.Name, Account.BillingCountry, Owner.Name,OwnerId, OC_TH_LI_CSR__c FROM Case 
                                 WHERE OC_TH_LI_CSR__c = True 
                                 AND Account.RecordType.Id =: OC_TH_Constants.getAccountServiceRecordTypeId
                                 AND Id =: caseSharingID];
            System.debug('cse:--'+csList);
            for(Case caselist : csList){      
                setCaseCountry.add(caselist.Account.BillingCountry);
                mapCaseIdAndBillingCountry.put(caselist.Id,caselist);
            }
            for(OC_TH_LICSR_Country__mdt licsrMdt : [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                     WHERE OC_TH_Accout_Billing_Country__c =: setCaseCountry
                                                     AND OC_TH_Public_Group_Country__c != null]){
                                                         mapBillingCountryAndGroup.put(licsrMdt.OC_TH_Accout_Billing_Country__c,licsrMdt.OC_TH_Public_Group_Country__c);
                                                         System.debug('metadata country n grp:--'+mapBillingCountryAndGroup);
                                                         setGroupDeveloperName.add(licsrMdt.OC_TH_Public_Group_Country__c);
                                                     }
            for(Group grp : [Select Id,Type,DeveloperName, Name from Group where DeveloperName =: setGroupDeveloperName]){
                mapIdAndDeveloperName.put(grp.DeveloperName,grp.ID);
                System.debug('get grp name:--'+mapIdAndDeveloperName);
            }
            if(!mapCaseIdAndBillingCountry.values().isEmpty()){
                for(Case cs : mapCaseIdAndBillingCountry.values()){
                    Id caseId = cs.Id;
                    String caseAccountBillingCountry = cs.Account.BillingCountry;
                    if(!mapBillingCountryAndGroup.isEmpty() && mapBillingCountryAndGroup.containsKey(caseAccountBillingCountry)){
                        String accbill =  mapBillingCountryAndGroup.get(caseAccountBillingCountry);
                         System.debug('accbill :--'+accbill);
                        if(!mapIdAndDeveloperName.isEmpty() && mapIdAndDeveloperName.containsKey(accbill)){
                            Id grpId = mapIdAndDeveloperName.get(accbill);
                            System.debug('grp id :--'+grpId);
                            caseShare csShare = new caseShare();
                            csShare.CaseId = caseId;
                            csShare.CaseAccessLevel = OC_TH_Constants.getEdit;
                            csShare.UserOrGroupId = grpId;
                            csShareList.add(csShare);
                            caseSharingMap.putAll(csShareList);
                        }
                    }
                }  
            }
            
            if(caseSharingMap.size()>0){   
                System.debug('Case sharing details :--'+caseSharingMap);
                upsert(caseSharingMap.values());
                System.debug('share LICSR:--'+caseSharingMap);
            } 
        }catch(Exception e){
            System.debug('exception:--'+e);
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_SystemUtility,OC_TH_Constants.method_shareCaseWithPublicGroup,null, false, e));
        }   
    }    
    /****************************************************************************************
@ Description : This method use to query LICSR(cases) with respective Account record type
***************************************************************************************/
    public static List<Case> licsrCases(Map<Id,SObject> newItems){
        Map<Id,Case> mapIdToNewCase = (Map<Id,Case>) newItems;
        List<Case> caseList = [SELECT Id,CaseNumber,Account.Name, Account.BillingCountry, Owner.Name,OwnerId, OC_TH_LI_CSR__c,OC_TH_Latest_Queue_Name__c FROM Case 
                               WHERE OC_TH_LI_CSR__c = True 
                               AND Account.RecordType.Id =: OC_TH_Constants.getAccountServiceRecordTypeId 
                               AND Id =: mapIdToNewCase.keyset()];
        return caseList;
    }
    /***********************************************************
@ Description : This method use to query Users with Email
************************************************************/
    public static List<user> licsrFetchUser(set<Id> setUserId){
        return [SELECT id,Email FROM User WHERE Id IN :setUserId AND Email != null];
    }
    /***********************************************************
@ Description : This method use to query CustomNotificationType with type
************************************************************/
    public static List<CustomNotificationType> licsrFetchCustomNotificationType(String developerName){
        return [SELECT Id,DeveloperName FROM CustomNotificationType WHERE DeveloperName =: developerName];
    }
    /***********************************************************************************************************
@ Description : This method use to sending mail to respective queue member matching with public group
************************************************************************************************************/
    public static void sendMail(map<String,id> mailToAddresses,String strDeveloperName) { 
        OrgWideEmailAddress[] orgWideEmailAddress = [select Id from OrgWideEmailAddress where Address =: OC_TH_Constants.orgWideDefaultAddress];
        List < Messaging.SingleEmailMessage > mails = new List < Messaging.SingleEmailMessage > ();
        EmailTemplate emp = [select id from EmailTemplate where DeveloperName =: strDeveloperName limit 1]; 
        for(string strEmail : mailToAddresses.keyset()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(emp.id);
            mail.setTargetObjectId(mailToAddresses.get(strEmail));
            mail.setToAddresses(new List<String>{strEmail});
            mail.setSaveAsActivity(false);
            if ( orgWideEmailAddress.size() > 0 ) {
                mail.setOrgWideEmailAddressId(orgWideEmailAddress.get(0).Id);
            }
            mails.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(mails); 
        }
    }
    /***********************************************************************************************************
@ Description : This method use to sending custom notification to respective queue member matching with public group
************************************************************************************************************/
    public static void sendCustomNotification(map<String,id> mailToAddresses,id customNotId,String strBody,String setTitle,id caseId) { 
        for(string strEmail : mailToAddresses.keyset()){
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setBody(strBody);
            notification.setTitle(setTitle);
            notification.setSenderId(mailToAddresses.get(strEmail));
            notification.setNotificationTypeId(customNotId);
            notification.setTargetId(caseId); // target object id
            notification.send(new Set<String> { mailToAddresses.get(strEmail) });
        }
        
    }
    /************************************************************************************************************
@ Description : This method use to fetch records of Partial view CSR based on the the Standard CSR caseID set 
*************************************************************************************************************/
    public static List<Case> getPartiaViewCaseList(Set<Id> setParentCaseId,String caseQuery){
        List<Case> CaseList = database.query(CaseQuery);        
        return CaseList;   
    }
    /****************************************************************************************************
@ Description : This method use to Update records of Partial view CSR as Mirrored from Standard LICSR 
****************************************************************************************************/
    public static void updatePartiaViewCaseList(List<Case> partialViewCaseList){
        Database.update(partialViewCaseList, false);
    }
    
    /***********************************************************************************************
@Description : US-2964 This method returns Standard CaseMilestone details in Partial view CSR
and collaboration CSR to class OC_TH_CsrServiceMilestone.getMilestoneDataFromParentID.
@Param       : Set of case Id and Milestone Names
@Return      : returns List of caseMilestone records.
*****************************************************************************************************/
    public static List<CaseMilestone> getCaseMilestoneDetails(Set<Id> setCaseId , String[] milestoneName){
        List<CaseMilestone> milestoneList = new List<CAseMilestone>();
        for(CaseMilestone csMil : [SELECT ID,caseId,MilestoneType.Name,MilestoneTypeId,IsCompleted,IsViolated,TimeRemainingInMins,TimeSinceTargetInMins FROM CaseMilestone 
                                   where CaseId =: setCaseId AND MilestoneType.Name =: milestoneName]){
                                       if(csMil != null){
                                           if(csMil.IsCompleted == false){
                                               milestoneList.add(csMil);
                                           }
                                           else{
                                               milestoneList.add(csMil);
                                           }
                                           if(csMil.IsViolated == false){
                                               milestoneList.add(csMil);
                                           }
                                           else{
                                               milestoneList.add(csMil);
                                           }
                                           if(csMil.TimeSinceTargetInMins != null && csMil.IsViolated && csMil.IsCompleted){
                                               milestoneList.add(csMil);
                                           }
                                       }
                                   }
        return milestoneList;
    }
    /***********************************************************************************************
@Description : US-2964 This method returns message when there is no Standard CaseMilestone 
to class OC_TH_CsrServiceMilestone.noMilestoneMessage
@Param       : Set of case Id and MilestoneNames.
@Return      : returns string.
*****************************************************************************************************/ 
    public static String noCaseMilestone(Set<Id> setCaseId , String[] milestoneName){
        String noMilestoneString = '';
        List<CaseMilestone> csMil = [SELECT ID,caseId,MilestoneType.Name,MilestoneTypeId,IsCompleted,IsViolated,TimeRemainingInMins,TimeSinceTargetInMins FROM CaseMilestone 
                                     where CaseId =: setCaseId AND MilestoneType.Name =: milestoneName];
        /*If there is no milestone for standard csr then child csr will display message.*/
        if(csMil.isEmpty()){          
            noMilestoneString = System.Label.OC_TH_CsrServiceMilestoneLabel;
        }
        return noMilestoneString;
    }
}