/**
* @File Name          : OC_TR_HelperUtil
* @Description        : Utility Class for Time recording
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 11th November 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-11-11                 IBM                   Initial Version

**/ 
public Without Sharing class OC_TR_HelperUtil {
    
    /**************************************************************************************
    * @Description  This method determines the engineers with atleast one unsibmitted time 
    *               record in the last 7 days.
    * @Param        List - user List. 
    * @Return       List - User List
    **************************************************************************************/
    Public Static List<User> CheckIfTimeRecordsAreCreatedByEngineers(List<User> serviceUserList){
        
        Map<Id,User> mapUserIdToUsrRec = new  Map<Id,User> ();
        Map<Id,User> mapSendEmailUserIdToUsrRec = new  Map<Id,User> ();
        Integer numberOfDays;
        String soqlTimeRecords;
        Set<Id> timeRecUserIdSet = new Set<Id> ();
       
        try{
            OC_TR_TimeRecording__mdt timeRecordMdt = [SELECT Id, DeveloperName, OC_TR_Value1__c 
                                                      FROM OC_TR_TimeRecording__mdt
                                                      WHERE DeveloperName =: OC_TR_Constants.durationToTREmailReminders ];
            numberOfDays = Integer.ValueOf(timeRecordMdt.OC_TR_Value1__c);     
            for(User servUser : serviceUserList){
                mapUserIdToUsrRec.put(servUser.Id,servUser);
            }
            
            
            timeRecUserIdSet.addAll(mapUserIdToUsrRec.Keyset());
            soqlTimeRecords = 'SELECT Id,OwnerId,OC_TR_PostingDate__c,OC_TR_Active__c,CreatedDate,LastModifiedDate FROM OC_TR_TimeRecord__c'+
                ' WHERE (OC_TR_PostingDate__c = LAST_N_DAYS:'+numberOfDays+
                ' OR LastModifiedDate = LAST_N_DAYS:'+numberOfDays+' )'+
                ' AND OwnerId in:timeRecUserIdSet'+
                ' AND OC_TR_Status__c ='+'\''+OC_TR_Constants.NotSubmitted+'\''+
                ' AND OC_TR_Active__c = true';
            
            
            for(OC_TR_TimeRecord__c  timeRec : database.query(soqlTimeRecords)){
                mapSendEmailUserIdToUsrRec.put(timeRec.OwnerId,mapUserIdToUsrRec.get(timeRec.OwnerId));
            }
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.ApexCls_OC_TR_HelperUtil,OC_TR_Constants.method_CheckIfTimeRecordsAreCreatedByEngineers,null, false, e));
        }    
        return mapSendEmailUserIdToUsrRec.Values() ;
    }
    
    /**************************************************************************************
    * @Description  This method sends email to a list of users with the provided email template, 
    *               from email address.
    * @Param        user List,Api name of email template,From Email address
    * @Return       Void - Nothing.
    **************************************************************************************/
    Public Static Void SendEmailToUsers (List<user> userList,String emailTemplateDevName,String orgWideEmailAddr){
        EmailTemplate emailTemp;
        OrgWideEmailAddress orgWideEmailAddress;
        List<Messaging.SingleEmailMessage> sendEmailMsgsList= new List<Messaging.SingleEmailMessage>();
        try{
            if(userList!=null && !userList.isEmpty() ){
                
                if(String.isNotBlank(emailTemplateDevName)){
                    emailTemp = [SELECT Id,Body,DeveloperName,HtmlValue,IsActive,Subject
                                 FROM  EmailTemplate 
                                 WHERE DeveloperName = :emailTemplateDevName
                                 AND IsActive = true];
                }
                if(String.isNotBlank(orgWideEmailAddr)){
                    orgWideEmailAddress = [SELECT Id FROM OrgWideEmailAddress 
                                           WHERE Address =:orgWideEmailAddr];
                }
                for(User usr : userList){
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(orgWideEmailAddress!=null){
                        mail.setOrgWideEmailAddressId(orgWideEmailAddress.Id);
                    }
                    if(emailTemp!=null){
                        mail.setTemplateId(emailTemp.Id);
                    }
                    mail.setSaveAsActivity(false);
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setTargetObjectId(usr.Id);
                    sendEmailMsgsList.add(mail);
                    
                }
                
                Messaging.sendEmail(sendEmailMsgsList);
            }
            
        } catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.ApexCls_OC_TR_HelperUtil,OC_TR_Constants.method_SendEmailToUsers,null, false, e));
        } 
    }
     /**************************************************************************************
    * @Description  This method queries the metadata for legal form to customer company code
    *               mapping.
    * @Return       Map<String,String> - Key : Legal Form<+Case Type> Value :CustomerCompanyCode
    **************************************************************************************/
    Public Static Map <String,String> getLegalFormToCustomerCompCodeMapping (){
        Map <String,String>  legalFormToCompCodeMap  = new Map <String,String>  ();
        
        for( OC_TR_OrganizationMapping__mdt orgMdt : [SELECT OC_TR_LegalForm__c,OC_TR_Customer_Company_Code__c 
                                                      FROM OC_TR_OrganizationMapping__mdt
                                                      WHERE OC_TR_LegalForm__c!=null 
                                                      AND OC_TR_Customer_Company_Code__c!=null ]){
                                                          legalFormToCompCodeMap.put(formatLegalForm(orgMdt.OC_TR_LegalForm__c),orgMdt.OC_TR_Customer_Company_Code__c);
                                                      }
        /*Added for TR-Manual TH --Begin */
        for(OC_TR_Customer_Company_Code__mdt compCodeDervMdt : [SELECT OC_TR_Legal_Form__c,OC_TR_CSR_Type__c,OC_TR_Customer_Company_Code__c
                                                                FROM OC_TR_Customer_Company_Code__mdt
                                                                WHERE OC_TR_Legal_Form__c!=null
                                                                AND   OC_TR_CSR_Type__c!=null 
                                                                AND   OC_TR_Customer_Company_Code__c!=null  ]){
                                                                    legalFormToCompCodeMap.put(formatLegalForm(compCodeDervMdt.OC_TR_Legal_Form__c)+'+'+compCodeDervMdt.OC_TR_CSR_Type__c,compCodeDervMdt.OC_TR_Customer_Company_Code__c);
                                                                }
        system.debug('legalFormToCompCodeMap ==>'+legalFormToCompCodeMap);
        /*Added for TR-Manual TH --End */
        return legalFormToCompCodeMap;
    }   
    /**************************************************************************************
    * @Description  This method determines the customer company code for time records based
    *               on the metadata and record type of time records.
    * @param        Time Records List              
    * @Return       Void - Nothing
    **************************************************************************************/
    Public Static Void SetCustomerCompCode (List<OC_TR_TimeRecord__c> timeRecList){
        Id ticketHandlingRtId = Schema.SObjectType.OC_TR_TimeRecord__c.getRecordTypeInfosByDeveloperName().get(Label.OC_TR_RecordType_TicketHandling).getRecordTypeId(); //Added for TR-Manual TH
        Map <String,String>  legalFormToCompCodeMap  = new Map <String,String>();//Added for TR-Manual TH
        try{
            legalFormToCompCodeMap =getLegalFormToCustomerCompCodeMapping();
            if(legalFormToCompCodeMap!=null && !legalFormToCompCodeMap.isEmpty()){
                /*Added/Modfied for TR-Manual TH --Begin */
                for(OC_TR_TimeRecord__c timeRec : timeRecList){
                    timeRec.OC_TR_LegalForm__c = OC_TR_HelperUtil.formatLegalForm(timeRec.OC_TR_LegalForm__c);
                    if(timeRec.RecordTypeId.equals(ticketHandlingRtId)){
                        if(legalFormToCompCodeMap.containsKey(timeRec.OC_TR_LegalForm__c+'+'+timeRec.OC_TR_Case_Type__c)){
                            timeRec.OC_TR_Customer_CC__c = legalFormToCompCodeMap.get(timeRec.OC_TR_LegalForm__c+'+'+timeRec.OC_TR_Case_Type__c);
                        }else{
                            timeRec.OC_TR_Customer_CC__c = null;
                        }
                    } else if(legalFormToCompCodeMap.containsKey(timeRec.OC_TR_LegalForm__c)){
                        timeRec.OC_TR_Customer_CC__c = legalFormToCompCodeMap.get(timeRec.OC_TR_LegalForm__c);
                    } else{
                        timeRec.OC_TR_Customer_CC__c = Label.OC_TR_DefaultCustomerCompanyCode;
                    }
                    
                }
                 /*Added/Modfied for TR-Manual TH --End */
            }
        } Catch(Exception excp){
            EventLog.createLog(new EventLog.Error(OC_TR_Constants.ApexCls_OC_TR_HelperUtil,OC_TR_Constants.method_SetCustomerCompCode,null, false, excp));
        } 
    }
    /**************************************************************************************
    * @Description  This method prefills the Service contract,Service to account on time record  
    *               with the Service contract,Service to account linked to associated case.
    * @param        Time Records List              
    * @Return       Void - Nothing
    **************************************************************************************/
    /*Added for TR-Manual TH --Begin */
    Public Static Void prefillAccContractOnTimeRecord (List<OC_TR_TimeRecord__c> timeRecList){
        Set<Id> caseIdSet = new Set<Id> ();
        Map<Id,Case> mapCaseIdTocaseRec = new Map<Id,Case> ();
        Map<Id,OC_TR_TimeRecord__c> mapTimeRecIdToTimeRec = new Map<Id,OC_TR_TimeRecord__c> ();
        
        for(OC_TR_TimeRecord__c timeRec : timeRecList){
            if(timeRec.OC_TR_Case__c != null){
                caseIdSet.add(timeRec.OC_TR_Case__c);
                mapTimeRecIdToTimeRec.put(timeRec.Id,timeRec);
            }
        }
        if(!caseIdSet.isEmpty()){
            mapCaseIdTocaseRec = new Map<Id,Case> ([SELECT Id,OC_TH_Service_Contract__c,AccountId
                                  FROM Case
                                  WHERE Id in:caseIdSet
                                  AND OC_TH_Service_Contract__c!=null
                                  AND AccountId!=null]);
            if(!mapCaseIdTocaseRec.isEmpty()){
                for(OC_TR_TimeRecord__c timeRec : mapTimeRecIdToTimeRec.Values()){
                    if(mapCaseIdTocaseRec.containsKey(timeRec.OC_TR_Case__c)){
                        timeRec.OC_TR_ObjectIdCon__c = mapCaseIdTocaseRec.get(timeRec.OC_TR_Case__c).OC_TH_Service_Contract__c;
                        timeRec.OC_TR_ServiceToAccount__c = mapCaseIdTocaseRec.get(timeRec.OC_TR_Case__c).AccountId;
                    }
                }
            }
            
        }
        
        
    }
    /*Added for TR-Manual TH --End */
    /**************************************************************************************
* @Description  This method prefixes '0' at the beginning to legal form if legal form 
*               is a single digit value.  
* @param        String - Legal Form Value               
* @Return       String - Formatted Legal Form Value
**************************************************************************************/
    /*Added for TR-Manual TH --Begin */
    Public Static String formatLegalForm (String legalFormVal){
        String legalFormFormattedVal = ( legalFormVal.length() == 1 ?'0'+legalFormVal : legalFormVal);
        return legalFormFormattedVal;
    }
    /*Added for TR-Manual TH --End */    
}