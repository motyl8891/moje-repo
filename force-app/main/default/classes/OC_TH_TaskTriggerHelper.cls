/* Class Name : OC_TH_TaskTriggerHelper
* Description : This class handles all the trigger events for Task object. 
* Author      : IBM.
* @Group              : OmniChannel - Service
* @Created Date       : 19 Aug 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-19                 Aayush Sachdeva                   Initial Version
**/ 
public with sharing class OC_TH_TaskTriggerHelper {
    
    //Update partial view through task status
    public static void updateCaseStatus(Set<Id> licsrCaseId){
        
        //List<Task> tskRec = [SELECT id,Status,WhatId FROM Task Where WhatId =: licsrCaseId];
    }
    
/**************************************************************************************
* @Description  This method will send an email notification to a contact when activity 
RFI-C,Answer or Remedy is updated to 'Requested' or 'Answered status respectively.                                  
* @Param        Id taskId and String emailAlert
**************************************************************************************/       
    public static void sendEmailNotifications(Id taskId, String emailAlert) { 
        List <Messaging.SingleEmailMessage> mails = new List <Messaging.SingleEmailMessage> ();
        /* Creating a set of required email templates*/
        Set<String> setOfTemplates = new Set<String>{OC_TH_Constants.getEmailTemplateRFIC,OC_TH_Constants.getEmailTemplateRemedy,OC_TH_Constants.getEmailTemplateFormalAnswer};
        List<EmailTemplate> emp = [select id,DeveloperName from EmailTemplate where DeveloperName IN :setOfTemplates]; 
        Map<String,Id> emailTempMap = new Map<String,Id>();
        try{
            for(EmailTemplate empTemp : emp){
                /* Adding the email templates name and Id in a map */
                emailTempMap.put(empTemp.DeveloperName,empTemp.Id);
            }
            system.debug('Map of Templates'+emailTempMap);
            /* Fetching the task record */
            List<Task> tskRec = [SELECT id,WhoId,WhatId,Description FROM Task Where Id =: taskId limit 1];
            /* Fetching the related contact record */
            List<Contact> con = [Select Id,Email,OC_TH_Ticket_Notifications__c FROM Contact where id =:tskRec[0].WhoId limit 1];
            Map<String,String> emailBody = new Map<String,String>();
            String htmlBody;
            String plainBody;
            String subject;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setWhatId(tskRec[0].WhatId);
            String[] toAddress = new String[]{};
                if(!con.isEmpty()){
                    /* Setting target object id as the contact Id*/
                    mail.setTargetObjectId(con[0].Id);
                    toAddress.add(con[0].Email);
                }
            /* Setting to address as the contact email*/
            mail.setToAddresses(toAddress);
            /* Checking the email alert to be fired*/
            if(String.isNotEmpty(emailAlert) && String.isNotEmpty(con[0].OC_TH_Ticket_Notifications__c)){
                if(emailAlert.equals(OC_TH_Constants.getRFICRequested)){
                    /* Checking if the contact has this type of email notification enabled*/
                    if(con[0].OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getRFICRequested)&& con[0].OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getEmailNotificationsEnabled)){
                        /* Getting the email body for this email notification with the merge fields*/
                        emailBody = returnEmailTemplateBody(tskRec[0].id,emailTempMap.get(OC_TH_Constants.getEmailTemplateRFIC));
                        htmlBody = emailBody.get(OC_TH_Constants.gethtmlBody);
                        plainBody = emailBody.get(OC_TH_Constants.getplainBody);
                        subject = emailBody.get(OC_TH_Constants.getsubject);
                        system.debug('Subject--' +subject);
                        mail.setHtmlBody(htmlBody);
                        mail.setPlainTextBody(plainBody);
                        mail.setSubject(subject);
                        mails.add(mail);
                        if(!Test.isRunningTest()){
                            Messaging.sendEmail(mails); 
                        }
                    }
                }     
                /* Checking the email alert to be fired*/
                if(emailAlert.equals(OC_TH_Constants.getRemedyProvided)){
                    /* Checking if the contact has this type of email notification enabled*/
                    if(con[0].OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getRemedyProvided)&& con[0].OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getEmailNotificationsEnabled)){
                        /* Getting the email body for this email notification with the merge fields*/
                        emailBody = returnEmailTemplateBody(tskRec[0].id,emailTempMap.get(OC_TH_Constants.getEmailTemplateRemedy));
                        htmlBody = emailBody.get(OC_TH_Constants.gethtmlBody);
                        plainBody = emailBody.get(OC_TH_Constants.getplainBody);
                        subject = emailBody.get(OC_TH_Constants.getsubject);
                        mail.setHtmlBody(htmlBody);
                        mail.setPlainTextBody(plainBody);
                        mail.setSubject(subject);
                        mails.add(mail);
                        if(!Test.isRunningTest()){
                            Messaging.sendEmail(mails); 
                        }
                    }
                }
                /* Checking the email alert to be fired*/
                if(emailAlert.equals(OC_TH_Constants.getAnswerProvided)){
                    /* Checking if the contact has this type of email notification enabled*/
                    if(con[0].OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getAnswerProvided)&& con[0].OC_TH_Ticket_Notifications__c.contains(OC_TH_Constants.getEmailNotificationsEnabled)){
                        /* Getting the email body for this email notification with the merge fields*/
                        emailBody = returnEmailTemplateBody(tskRec[0].id,emailTempMap.get(OC_TH_Constants.getEmailTemplateFormalAnswer));
                        htmlBody = emailBody.get(OC_TH_Constants.gethtmlBody);
                        plainBody = emailBody.get(OC_TH_Constants.getplainBody);
                        subject = emailBody.get(OC_TH_Constants.getsubject);
                        mail.setHtmlBody(htmlBody);
                        mail.setPlainTextBody(plainBody);
                        mail.setSubject(subject);
                        mails.add(mail);
                        if(!Test.isRunningTest()){
                            Messaging.sendEmail(mails); 
                        }
                    }
                }
            }
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_TaskTriggerHelper,OC_TH_Constants.method_sendEmailNotifications,null, false, e));
        }  
    }
/**************************************************************************************
* @Description  This method will return the email notification body to sendEmailNotifications
method, based on the email template Id and task Id .                                  
* @Param        Id taskId and Id emailTemplateName
**************************************************************************************/           
    public static Map<String,String> returnEmailTemplateBody(Id taskId, Id emailTemplateName){
        /* Fetching the task and related records */
        Task tskRec = [SELECT id,WhoId,WhatId,Description FROM Task Where Id =: taskId limit 1];
        EmailTemplate emp = [select id,DeveloperName,HtmlValue,Body,Subject from EmailTemplate where Id =:emailTemplateName limit 1];
        Case caseRec = [Select Id,Subject,OC_TH_Case_Number__c,OC_TH_Ext_Reference__c,Type,AssetId,Asset.Name,Priority,Status,OwnerId,Owner.FirstName,Owner.LastName from Case where id =:tskRec.WhatId limit 1];
        Contact conRec = [Select Id,FirstName,LastName from Contact where id=:tskRec.WhoId limit 1];
        Map<String,String> emailBody = new Map<String,String>();
        String subject = emp.Subject;
        /* Passing the merge field data in Subject */
        try{
            if(subject.contains('{!Case.Subject}')){
                subject = subject.replace('{!Case.Subject}', caseRec.Subject);
                subject = subject.replace('{!Case.OC_TH_Case_Number__c}', caseRec.OC_TH_Case_Number__c);
                
            }
            String htmlBody = emp.HtmlValue;
            String plainBody = emp.Body;  
            String emailAlertUrl = System.Label.OC_TH_Email_alert_to_Customer;
            /* Getting the email body based on task Id and email template*/
            htmlBody = returnEmailBody(htmlBody,emailTemplateName,tskRec.id);
            plainBody = returnEmailBody(plainBody,emailTemplateName,tskRec.id);
            emailBody.put(OC_TH_Constants.getsubject,subject);
            emailBody.put(OC_TH_Constants.gethtmlBody,htmlBody);
            emailBody.put(OC_TH_Constants.getplainBody,plainBody);
            system.debug('Email Body Map'+emailBody);
            
        }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_TaskTriggerHelper,OC_TH_Constants.method_returnEmailTemplateBody,null, false, e));
        }
        return emailBody;
    }
/**************************************************************************************
* @Description  This method will return the email notification body in html and plain 
formats to returnEmailTemplateBody method, based on the email template Id and task Id .                                  
* @Param        String body, Id taskId and Id emailTemplateName
**************************************************************************************/           
    public static String returnEmailBody(String body, Id emailTemplateName,Id taskId){
        /* Fetching the task and related records */
        Task tskRec = [SELECT id,WhoId,WhatId,Description FROM Task Where Id =: taskId];
        EmailTemplate emp = [select id,DeveloperName,HtmlValue,Body,Subject from EmailTemplate where Id =:emailTemplateName];
        Case caseRec = [Select Id,Subject,OC_TH_Case_Number__c,OC_TH_Ext_Reference__c,Type,AssetId,Asset.Name,Priority,OC_TH_CSR_Priority__c,Status,OwnerId,Owner.FirstName,Owner.LastName from Case where id =:tskRec.WhatId];
        Contact conRec = [Select Id,FirstName,LastName from Contact where id=:tskRec.WhoId];
        Map<String,String> caseType = OC_Utility.getObjectPicklistValuesReverse(OC_TH_Constants.caseLiteral,OC_TH_Constants.caseType);

        /* Passing the merge field data in Body */
        try{
            if(String.isNotEmpty(body)){
                /* Checking the merge fields in body of the email template and replacing it with the values*/
                if(body.contains('{!$Label.OC_TH_Email_alert_to_Customer}')){
                    body = body.replace('{!$Label.OC_TH_Email_alert_to_Customer}',System.Label.OC_TH_Email_alert_to_Customer);
                }
                if(body.contains('{!Case.Id}')){
                    body = body.replace('{!Case.Id}', caseRec.Id);
                }
                if(body.contains('{!Task.Description}')){
                    body = body.replace('{!Task.Description}', tskRec.Description);
                }
                if(body.contains('{!Contact.FirstName}')){
                    body = body.replace('{!Contact.FirstName}', conRec.FirstName);
                }
                if(body.contains('{!Contact.LastName}')){
                    body = body.replace('{!Contact.LastName}', conRec.LastName);
                }
                if(body.contains('{!Case.OC_TH_Case_Number__c}')){
                    body = body.replace('{!Case.OC_TH_Case_Number__c}', caseRec.OC_TH_Case_Number__c);
                }
                if(body.contains('{!Case.OC_TH_Ext_Reference__c}')){
                    if(String.isNotEmpty(caseRec.OC_TH_Ext_Reference__c))
                    {
                        body = body.replace('{!Case.OC_TH_Ext_Reference__c}', caseRec.OC_TH_Ext_Reference__c);
                    }
                    else{
                        body = body.replace('{!Case.OC_TH_Ext_Reference__c}', ' ');
                    }
                }
                if(body.contains('{!Case.Subject}')){
                    body = body.replace('{!Case.Subject}', caseRec.Subject);
                }
                if(body.contains('{!Case.Type}')){
                    body = body.replace('{!Case.Type}',caseType.get(caseRec.Type));
                }
                if(body.contains('{!Case.Asset}')){
                    body = body.replace('{!Case.Asset}', caseRec.Asset.Name);
                }
               	if(body.contains('{!Case.Priority}')){
                    body = body.replace('{!Case.Priority}', caseRec.OC_TH_CSR_Priority__c);
                }
                if(body.contains('{!Case.Status}')){
                    body = body.replace('{!Case.Status}', caseRec.Status);
                }
                if(body.contains('{!Case.OwnerFirstName}')){
                    body = body.replace('{!Case.OwnerFirstName}', caseRec.Owner.FirstName);
                }
                if(body.contains('{!Case.OwnerLastName}')){
                    body = body.replace('{!Case.OwnerLastName}', caseRec.Owner.LastName);
                }
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_TaskTriggerHelper,OC_TH_Constants.method_returnEmailBody,null, false, e));
        }
        return body;
    }
    
}