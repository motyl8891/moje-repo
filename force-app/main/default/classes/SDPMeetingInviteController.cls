/******************************************************************************************
@author       : Richa Gupta
@date         : 21/01/2021
@UserStroy    : U-2129 (Invite correct SDP members to ACRs SDP meetings by clicking a button on the SDR page)
@description  : This class is used as a controller for SDPMeetingInvite Component
@testClass    : SDPMeetingInviteControllerTest
*******************************************************************************************/
public Without Sharing class SDPMeetingInviteController  {
   @AuraEnabled
    public static String sendInviteURL(Id SDRID){
        String toEmail;
        String subject='SDP Meeting Invitation';
        String emailBody;
        String inviteUrl;
        String GCUName;
        String KAMName;
        String ACRName;
        Sales_Decision_Record__c SDRList;
        try{
            SDRList=[select id, Name,Sales_Decision_Type__c,Opportunity__c,Opportunity__r.name,MA_Sales_Authority_Matrix__c ,ACR__r.Name,
                     Opportunity__r.KAM__r.Name,Opportunity__r.GCU_Commercial_Director__r.Name from Sales_Decision_Record__c where id=:SDRID Limit 1];
          toEmail=getSalesTeamEmails(SDRList.Opportunity__c);
            if(SDRList.Sales_Decision_Type__c.equals('SDP0 Qualify')){
                subject='SDP0 Meeting Invite';
            } if(SDRList.Sales_Decision_Type__c.equals('SDP1 Invest to Win')){
                subject='SDP1 Meeting Invite';
            } if(SDRList.Sales_Decision_Type__c.equals('SDP2 Submit Proposal')){
                subject='SDP2 Meeting Invite';
            }if(SDRList.Sales_Decision_Type__c.equals('SDP3 Sign Contract')){
                subject='SDP3 Meeting Invite';
            } if(SDRList.Sales_Decision_Type__c.equals('Other')){
                subject='SDP Meeting Invite';
            } if(SDRList.Sales_Decision_Type__c.equals('OQB')){
                subject='OQB Meeting Invite';
            } if(SDRList.Sales_Decision_Type__c.equals('Qualify GCU Child')){
                subject='Qualify GCU Child Meeting Invite';
            } if(SDRList.Sales_Decision_Type__c.equals('Confirm GCU Child')){
                subject='Confirm GCU Child Meeting Invite';
            }if(SDRList.Opportunity__r.GCU_Commercial_Director__r.Name==null){
                GCUName='';
            }else{
                GCUName=SDRList.Opportunity__r.GCU_Commercial_Director__r.Name;
            }if(SDRList.Opportunity__r.KAM__r.Name==null){
                KAMName='';
            }else{
                KAMName=SDRList.Opportunity__r.KAM__r.Name;
            }if(SDRList.ACR__r.Name==null){
                ACRName='';
            }else{
                ACRName=SDRList.ACR__r.Name;
            }
           //  String invalidURL=SDRList.MA_Sales_Authority_Matrix__c;
           //  String validURL=invalidURL.replace('&amp;','%26');
            List<Sales_Decision_Maker__c> SdmList=[Select Approver_Name__r.Email from Sales_Decision_Maker__c where Sales_Decision_Record__c=:SDRID and 
                             Approver_Name__r.Email!=null Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];
            for(Sales_Decision_Maker__c str:SdmList){
            if(toEmail==null){
              toEmail=str.Approver_Name__r.Email;
            }else if(!toEmail.contains(str.Approver_Name__r.Email)){
              toEmail=toEmail +';'+str.Approver_Name__r.Email ;   
            }
        }
           emailBody='<HTML>Hi,<p>You are invited to an <a href="'+Label.Org_base_URL+'/'+SDRList.id+'"> '+SDRList.Name+' </a> Meeting for Opportunity <a href="'+Label.Org_base_URL+'/'+SDRList.Opportunity__c+'"> '+SDRList.Opportunity__r.Name+'</a></p><br><p>To prepare for your SDP decision, you may refer to supporting documentation available On  <a href="'+Label.Org_base_URL+'/'+SDRList.Opportunity__c+'"> Opportunity Page </a> under Sales Decision tab.</p><br><p>Alignment with KAM<i> '+KAMName+'</i> and Commercial Manager <i>'+GCUName+'</i> is strictly required before forwarding this invitation to any other stakeholders.</p><br><br><p>Kind regards,<br>'+ACRName+'</p></body></HTML>';            
           inviteUrl='https://outlook.office.com/owa/?path=/calendar/action/compose&to='+toEmail+'&subject='+subject+'&body='+emailBody+'';
        }
        catch(exception e){
         EventLog.createLog(new EventLog.Error(GlobalConstants.SDPMeetingInviteController, 
                                 GlobalConstants.sendInviteURL, GlobalConstants.SDPMeetingInviteController, true, e));   
        }return inviteUrl;
    }
    public static String getSalesTeamEmails(Id OppId){
        string email;
        try{
       List< Opportunity_Sales_Team__c> salesTeam=[Select id,Employee__r.Email__c from Opportunity_Sales_Team__c where Opportunity__c=:OppId and Role__c in ('ACR','CFR','CSR') 
                                          and Employee__r.Email__c!=null Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
         for(Opportunity_Sales_Team__c steam:salesTeam){
            if(email==null){
              email=steam.Employee__r.Email__c;
            }else if(!email.contains(steam.Employee__r.Email__c)){
              email=email +';'+steam.Employee__r.Email__c ;   
            }
         }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(GlobalConstants.SDPMeetingInviteController, 
               GlobalConstants.getSalesTeamEmails, GlobalConstants.SDPMeetingInviteController, true, e));
        }
        return email;
    }
}