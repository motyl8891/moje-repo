/*******************************************************************
* @author: Manu Singhal
* @date: 2019-03-12
* @description: U-1339

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

********************************************************************/
global class SendEmailForInactiveContactBatch implements Database.Batchable<sObject>, Schedulable{
    /****************************************************************
* @author: Manu Singhal
* @date: 2019-03-12
* @param: SchedulableContext ctx
* @description: Execute Method of Scheduler
*****************************************************************/
    global void execute(SchedulableContext ctx){
        database.executeBatch(new SendEmailForInactiveContactBatch(), 50);
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 2019-03-12
* @param: Database.BatchableContext
* @description: Start Method of Batch
*****************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date emailDate = system.today().addMonths(-11);
        //Date deleteDate = system.today().addMonths(-12);
		String query='SELECT Id,Inactive__c,InactiveDate__c,Owner.Email,Name FROM Contact WHERE Inactive__c = true  and InactiveDate__c =:emailDate ';
        return Database.getQueryLocator(query);
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 2019-03-12
* @param: Database.BatchableContext, List<Contact> contactList
* @description: Execute Method of Batch
*               1. Send email to contact owner
*****************************************************************/
    global void execute(Database.BatchableContext BC, List<Contact> contactList) 
    {
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
        List<Messaging.SingleEmailMessage> emailMsgList = new List<Messaging.SingleEmailMessage>(); 
        EmailTemplate emailTemplate = [select Id, Body from EmailTemplate where DeveloperName = :GlobalConstants.InactiveContactEmailToOwner Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        for(Contact con : (List<Contact>)contactList) {
            Messaging.SingleEmailMessage Emailmessage = new Messaging.SingleEmailMessage();
            Emailmessage.setSaveAsActivity(false);
            Emailmessage.setOrgWideEmailAddressId(owa.id);
            Emailmessage.setToAddresses(new String[] {con.Owner.Email});
            Emailmessage.setTargetObjectId(con.id);
            Emailmessage.setTemplateId(emailTemplate.Id);
            emailMsgList.add(Emailmessage);
            if(emailMsgList.size() > 0){
                Messaging.sendEmail(emailMsgList);
            }          
        }
    }
    /****************************************************************
* @author: Manu Singhal
* @date: 2019-03-12
* @param: Database.BatchableContext
* @description: Finish Method of Batch
*****************************************************************/
    global void finish(Database.BatchableContext BC){}    
}