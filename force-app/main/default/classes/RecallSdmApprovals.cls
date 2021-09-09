/****************************************************************
* @author: Pallavi Patil
* @date: 21-04-2020
* @param: U-1716
* @description: This class will recalls all SDM-approval request within the Sales Decision Record 
*****************************************************************/
public without sharing class RecallSdmApprovals {
    @AuraEnabled
    public static boolean SendEmailForRecall(Id value) {
        Boolean sendEmailFlag = false; 
        List<Sales_Decision_Maker__c> sdmList;
        List<ProcessInstanceWorkItem> approvals;
        try{
            sdmList = [Select Id, Approval_Status__c,Actual_Approver__c,Conditions_Notes__c,Sales_Decision_Record__c,Sales_Decision_Record__r.Sales_Decision_Approval_Status__c from Sales_Decision_Maker__c
                       where Sales_Decision_Record__c = :value 
                       AND(Sales_Decision_Record__r.Sales_Decision_Approval_Status__c=: GlobalConstants.APPROVALSONGOING 
                           OR Sales_Decision_Record__r.Sales_Decision_Approval_Status__c=: GlobalConstants.In_Progress)
                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            approvals = [SELECT Id, ProcessInstance.TargetObjectId, CreatedById
                         FROM ProcessInstanceWorkitem 
                         WHERE ProcessInstance.TargetObjectId =: sdmList 
                         Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(!approvals.isempty()){
                Id profileId = UserInfo.getProfileId();
				String profileName = [SELECT Name FROM Profile WHERE Id =: profileId
                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())].Name;
                for(ProcessInstanceWorkItem approval : approvals){
                    if(approval.CreatedById != UserInfo.getUserId()  && profileName == GlobalConstants.Ericsson_Sales_Operations
                      ){
                          sendEmailFlag = true;
                          break;
                      } 
                }
            } 
            if(sendEmailFlag)  {
                EmailServicesFunction emailFunction = [SELECT Id FROM EmailServicesFunction WHERE FunctionName=: GlobalConstants.RecallSDRApproval];
				EmailServicesAddress emailServicesAddress = [SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress WHERE FunctionId = :emailFunction.Id];
				//System.debug('Email Service Address: ' + emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName);
                String emailAddress = emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName;
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(emailAddress);
                mail.setToAddresses(sendTo);    
                //mail.setReplyTo('amit.ojha@ericsson.com');
               // mail.setSenderDisplayName('Ericsson_Amit');
                mail.setSubject('RecallSDR');
                String body = value;
                mail.setPlainTextBody(body);
                mails.add(mail);
                Messaging.sendEmail(mails);
              //  Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
             /*   System.debug('******************* Inside send Mail - End ' + results );
                for (Messaging.SendEmailResult mr : results) 
                {
                    if (mr.isSuccess()) {
                        System.debug('******************* Inside send Mail - End ' + mr.isSuccess() );
                        //Do something for success
                    }  else {
                        // Operation failed, so get all errors                
                        for(Messaging.SendEmailError err : mr.getErrors()) {
                        }
                    }
                } */
            }else{
                recallAllSdmApprovalstwo(sdmList, approvals);
            }
        }
        catch(Exception e) {
            System.debug('Exception  : '+e);
        }
        
        return true;
    }
    
    public static boolean recallAllSdmApprovalstwo(List<Sales_Decision_Maker__c> sdmList,List<ProcessInstanceWorkItem> approvals ) {
        Boolean flag; 
        try{  
            List<Sales_Decision_Maker__c> sdmUpdateList = new List<Sales_Decision_Maker__c>();
            List<Sales_Decision_Record__c> sdrListToUpdate = new List<Sales_Decision_Record__c>();
            Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
                if(!approvals.isempty() && !sdmList.isempty()){
                    for(Sales_Decision_Maker__c sdm : sdmList){
                        for(ProcessInstanceWorkItem approval : approvals){
                            if(approval.ProcessInstance.TargetObjectId == sdm.Id){
                                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                                pwr.setAction('Removed');
                                pwr.setComments('Recalled');
                                pwr.setWorkItemId(approval.id);  
                                prWkItems.add(pwr);                                
                            }
                        }
                        if(sdm.Approval_Status__c != GlobalConstants.TOBEREQUESTED){
                            sdm.Approval_Status__c = GlobalConstants.TOBEREQUESTED;
                            Approval.UnlockResult unlockedRersult = Approval.unlock(sdm);
                            sdm.sdm_flag__c=false;
                            sdm.Conditions_Notes__c = '';
                            sdmUpdateList.add(sdm);
                        }
                    }
                    if(!prWkItems.isEmpty()){
                        System.debug('prWkItems:'+prWkItems);
                        Approval.ProcessResult[] appResult = Approval.process(prWkItems);
                    }
                }
            else
            {  
                if(!sdmList.isempty()){
                    for(Sales_Decision_Maker__c sdm : sdmList)
                    {
                        if(sdm.Approval_Status__c != GlobalConstants.TOBEREQUESTED || sdm.Conditions_Notes__c != ''){
                            sdm.Approval_Status__c = GlobalConstants.TOBEREQUESTED;
                            //U-1853 - Start
                            sdm.Actual_Approver__c = null;
                            //U-1853 - End
                            sdm.sdm_flag__c=false;
                            sdm.Conditions_Notes__c = '';
                            sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
                            sdmUpdateList.add(sdm);
                            if(!sdrListToUpdate.contains(sdm.Sales_Decision_Record__r))
                                sdrListToUpdate.add(sdm.Sales_Decision_Record__r);
                        }
                    }
                }
            }
            if(!sdmUpdateList.isEmpty()){                                
                update sdmUpdateList;
                update sdrListToUpdate;
                flag = true;
            } 
            else
                flag = false;
        }
        catch(Exception e) {
            flag = false;
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, GlobalConstants.resetSDMs, GlobalConstants.SalesDecisonMakerHelper, true, e)));
        }
        return flag;        
    }
    
    /* 
public static boolean recallAllSdmApprovals(Id value) {
System.debug('In recallAllSdmApprovals value:'+value);
String sendIdinEmail = '';
Boolean flag; 
try{            
List<Sales_Decision_Maker__c> sdmList = [Select Id, Approval_Status__c,Actual_Approver__c,Conditions_Notes__c,Sales_Decision_Record__c,Sales_Decision_Record__r.Sales_Decision_Approval_Status__c from Sales_Decision_Maker__c
where Sales_Decision_Record__c = :value 
AND(Sales_Decision_Record__r.Sales_Decision_Approval_Status__c=: GlobalConstants.APPROVALSONGOING 
OR Sales_Decision_Record__r.Sales_Decision_Approval_Status__c=: GlobalConstants.In_Progress)
Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
List<Sales_Decision_Maker__c> sdmUpdateList = new List<Sales_Decision_Maker__c>();
List<Sales_Decision_Record__c> sdrListToUpdate = new List<Sales_Decision_Record__c>();
List<ProcessInstanceWorkItem> approvals = [SELECT Id, ProcessInstance.TargetObjectId, CreatedById
FROM ProcessInstanceWorkitem 
WHERE ProcessInstance.TargetObjectId =: sdmList 
Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
Approval.ProcessWorkitemRequest[] prWkItems = New Approval.ProcessWorkItemRequest[]{};
if(!approvals.isempty() && !sdmList.isempty()){
for(Sales_Decision_Maker__c sdm : sdmList){
for(ProcessInstanceWorkItem approval : approvals){
if(approval.ProcessInstance.TargetObjectId == sdm.Id){
if(approval.CreatedById != UserInfo.getUserId() && userinfo.getProfileId() == '00e0Y000001VuiH'){
// Send email 
sendIdinEmail = sendIdinEmail + approval.id;
}
else{
// Existing code
Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
pwr.setAction('Removed');
pwr.setComments('Recalled');
pwr.setWorkItemId(approval.id);  
prWkItems.add(pwr);
}

}
}
if(sdm.Approval_Status__c != GlobalConstants.TOBEREQUESTED){
sdm.Approval_Status__c = GlobalConstants.TOBEREQUESTED;
sdm.sdm_flag__c=false;
sdm.Conditions_Notes__c = '';
sdmUpdateList.add(sdm);
}
}
if(!prWkItems.isEmpty()){
System.debug('prWkItems:'+prWkItems);
Approval.ProcessResult[] appResult = Approval.process(prWkItems);
}
}
else
{  
if(!sdmList.isempty()){
for(Sales_Decision_Maker__c sdm : sdmList)
{
if(sdm.Approval_Status__c != GlobalConstants.TOBEREQUESTED || sdm.Conditions_Notes__c != ''){
sdm.Approval_Status__c = GlobalConstants.TOBEREQUESTED;
//U-1853 - Start
sdm.Actual_Approver__c = null;
//U-1853 - End
sdm.sdm_flag__c=false;
sdm.Conditions_Notes__c = '';
sdm.Sales_Decision_Record__r.Sales_Decision_Approval_Status__c = GlobalConstants.INPROGRESS;
sdmUpdateList.add(sdm);
if(!sdrListToUpdate.contains(sdm.Sales_Decision_Record__r))
sdrListToUpdate.add(sdm.Sales_Decision_Record__r);
}
}
}
}
if(!sdmUpdateList.isEmpty()){                                
update sdmUpdateList;
update sdrListToUpdate;
flag = true;
} 
else
flag = false;
}
catch(Exception e) {
flag = false;
EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SalesDecisonMakerHelper, GlobalConstants.resetSDMs, GlobalConstants.SalesDecisonMakerHelper, true, e)));
}
return flag;        
} */
}