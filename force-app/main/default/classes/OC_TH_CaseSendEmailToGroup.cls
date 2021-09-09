public without sharing class OC_TH_CaseSendEmailToGroup {
 /****************************************************************************************
@ Description : This method handles to Case Billing Country and send email to public group.
***************************************************************************************/

    public static void sendEmailtoPublicGroup(Map<Id, SObject> newItems){
        Map<Id,Case> mapCaseIdAndBillingCountry = new Map<Id,Case>();
        Set<String> setCaseCountry = new Set<String>();
        Set<String> setGroupDeveloperName = new Set<String>();
        set<String> queueName = new set<String>();
        set<id> setGroupId = new set<id>();
        set<id> setGroupQueueId = new set<id>();
        Id accountServiceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAccountServiceRecordType).getRecordTypeId();
        try{
            List<Case> csList = [SELECT Id,CaseNumber,Account.Name, Account.BillingCountry, Owner.Name,OwnerId, OC_TH_LI_CSR__c,OC_TH_Latest_Queue_Name__c FROM Case 
                                 WHERE OC_TH_LI_CSR__c = True 
                                 AND Account.RecordType.Id =: accountServiceRecordType 
                                 AND Id =: newItems.keyset()]; 
            for(Case caselist : csList){      
                /*Set to store case country*/
                setCaseCountry.add(caselist.Account.BillingCountry);
                mapCaseIdAndBillingCountry.put(caselist.Id,caselist);
                if(caselist.OC_TH_Latest_Queue_Name__c != null){
                    queueName.add(caselist.OC_TH_Latest_Queue_Name__c);
                }
            }
            if(queueName.size() > 0){
                //use contast class
               list<Group> lstGroup =  [Select Id from Group where type='Queue' and Name=: queueName];
               for(Group objGroup : lstGroup){
                   setGroupId.add(objGroup.id);
               }
            }
            
            if(setGroupId.size() > 0){
                for(GroupMember groupMeb : [Select UserOrGroupId From GroupMember where GroupId =:setGroupId]){
                    setGroupQueueId.add(groupMeb.UserOrGroupId);
                }
            }
            
            Map<String,String> mapBillingCountryAndGroup = new Map<String,String>();
            for(OC_TH_LICSR_Country__mdt licsrMdt : [SELECT Id,DeveloperName, OC_TH_User_Country__c, OC_TH_Public_Group_Country__c,OC_TH_Accout_Billing_Country__c FROM OC_TH_LICSR_Country__mdt 
                                                     WHERE OC_TH_Accout_Billing_Country__c =: setCaseCountry
                                                     AND OC_TH_Public_Group_Country__c != null]){
                                                         mapBillingCountryAndGroup.put(licsrMdt.OC_TH_Accout_Billing_Country__c,licsrMdt.OC_TH_Public_Group_Country__c);
                                                         setGroupDeveloperName.add(licsrMdt.OC_TH_Public_Group_Country__c);
                                                     }
            
            set<id> setUserId = new set<id>();
            map<String,id> mailToAddresses = new map<String,id>(); 
            for(Group grp : [Select Id,Type,DeveloperName, Name,(SELECT UserOrGroupId FROM GroupMembers) from Group where DeveloperName =: setGroupDeveloperName]){
                for (GroupMember gm : grp.GroupMembers) {
                    if(setGroupQueueId.contains(gm.UserOrGroupId)){
                        setUserId.add(gm.UserOrGroupId);
                    }
                }
            }
            
            List<User> userList = [SELECT id,Email FROM User WHERE Id IN :setUserId];
            for(User u : userList) {
                system.debug('email===' + u.email);
                if(u.email != null){
                    mailToAddresses.put(u.email,u.id);
                }
            }
            
            if(!mailToAddresses.isEmpty()){
                sendMail(mailToAddresses);      
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_caseSendEmailToGroup,OC_TH_Constants.method_sendEmailtoPublicGroup,null, false, e));
        }  
    }
    
    //Send Email
    public static void sendMail(map<String,id> mailToAddresses) {
        
        List < Messaging.SingleEmailMessage > mails = new List < Messaging.SingleEmailMessage > ();
        EmailTemplate emp = [select id from EmailTemplate where DeveloperName='LI_CSR_Temp' limit 1]; 
        for(string strEmail : mailToAddresses.keyset()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(emp.id);
            mail.setTargetObjectId(mailToAddresses.get(strEmail));
            mail.setToAddresses(new List<String>{strEmail});
            mail.setSaveAsActivity(false);
            mails.add(mail);
        }
        if(!Test.isRunningTest()){
            Messaging.sendEmail(mails); 
        }
    }
}