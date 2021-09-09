/******************************************************************* 
* @author: Linda Pavare 
* @date: 2017-10-17 
* @description: This is Utility class for Opportunities.
********************************************************************/
public with sharing class OpportunityUtils {

/****************************************************************
* @author: Linda Pavare
* @date: 2017-10-17
* @param: opp
* @return: oppList
* @description: This method queries Opportunity information by given Opportunity Ids
*****************************************************************/    
    public static List<Opportunity> getOpportunityInfo(Set<Id> oppIds){          
            List<Opportunity> oppList = [SELECT Id, 
                                         Amount, 
                                         CloseDate, 
                                         EmbargoCountryFlag__c,
                                         Name, 
                                         Probability, 
                                         StageName, 
                                         isDeleted, 
                                         CurrencyIsoCode, 
                                         OpportunityAutoNumber__c,
                                         OpportunityNumber__c,
                                         AccountId, 
                                         Account.SAP_S2P_ID__c,
                                         Account.SAP_S2P_ID_Number__c,
                                         Account.MarketArea__c,
                                         Account.MDM_Customer_Id__c,
                                         Account.PrimaryMarketCountry__c,
                                         Account.Trade_Classification__c,
                                         Trade_Classifications__c,
                                         MDM_Customer_Id__c,
                                         Description,
                                         Sequence__c,
                                         Parent_Contract__c,
                                         Legacy_Estimated_Deal_Value__c,
                                         Legacy_Status_Of_Business__c,
                                         Legacy_Sales_Process_Stage__c,
                                         Legacy_Process_Track_Text__c,
                                         CFR_Signum__c,
                                         CSR_Signum__c,
                                         Contract_Manager_Signum__c,
                                         Parent_Original_Opportunity__r.OpportunityNumber__c,
                                         Parent_Original_Opportunity__r.Amount,
                                         Parent_Original_Opportunity__r.CloseDate,
                                         Parent_Original_Opportunity__r.Probability,
                                         Parent_Original_Opportunity__r.CurrencyIsoCode
                                         FROM Opportunity WHERE Id IN : oppIds];
            return oppList;
    }

    /****************************************************************
* @author: Nikolajs Jurickis
* @date: 2018-03-02
* @param: opp
* @return: oppList
* @description: This method queries Opportunity information including Oportunity Team Members by given Opportunity Ids
*****************************************************************/    
    public static List<Opportunity> getOpportunityInfoWithOppTeamMembers(Set<Id> oppIds){
            //Set<Id> oppIds = new Set<Id>();
            //for(Id i: opp){oppIds.add(i);}
            List<Opportunity> oppList = [SELECT Id, 
                                         Amount, 
                                         CloseDate,
                                         EmbargoCountryFlag__c,
                                         Name, 
                                         Probability, 
                                         StageName, 
                                         isDeleted, 
                                         CurrencyIsoCode, 
                                         OpportunityAutoNumber__c,
                                         OpportunityNumber__c,
                                         AccountId, 
                                         Account.SAP_S2P_ID__c,
                                         Account.SAP_S2P_ID_Number__c,
                                         Account.MarketArea__c,
                                         Account.MDM_Customer_Id__c,
                                         Account.PrimaryMarketCountry__c,
                                         Account.Trade_Classification__c,
                                         Trade_Classifications__c,
                                         MDM_Customer_Id__c,
                                         Managed_Services_Governance__c,
                                         //Owner.FederationIdentifier,
                                         ACR_Signum__c,
                                         //KAM__r.FederationIdentifier,
                                         KAM_Signum__c,
                                         Description,
                                         Sequence__c,
                                         Parent_Contract__c,
                                         EngagementType__c,
                                         Legacy_Estimated_Deal_Value__c,
                                         Legacy_Status_Of_Business__c,
                                         Legacy_Sales_Process_Stage__c,
                                         Legacy_Process_Track_Text__c,
                                         Legacy_SDP_Status__c,
                                         Legacy_SDP_Value__c,
                                         Legacy_Contract_Classification__c,
                                         CFR_Signum__c,
                                         CSR_Signum__c,
                                         Contract_Manager_Signum__c,
                                         Parent_Original_Opportunity__r.OpportunityNumber__c,
                                         Parent_Original_Opportunity__r.Amount,
                                         Parent_Original_Opportunity__r.CloseDate,
                                         Parent_Original_Opportunity__r.Probability,
                                         Parent_Original_Opportunity__r.CurrencyIsoCode,
                                         (
                                            Select User.FederationIdentifier, TeamMemberRole From OpportunityTeamMembers
                                         )                                         
                                         FROM Opportunity WHERE Id IN : oppIds];
            return oppList;      
    }

/****************************************************************
* @author: Linda Pavare
* @date: 2018-02-07
* @param: oppNumbers
* @return: oppList
* @description: This method queries Opportunity information by given list of Opportunity_Number__c 
*****************************************************************/      
    public static List<Opportunity> getOpportunityByOppNumberInfo(Set<String> oppNums){        
            List<Opportunity> oppList = [SELECT Id, 
                                         Amount, 
                                         CloseDate, 
                                         Name,
                                         EmbargoCountryFlag__c,
                                         Probability, 
                                         StageName, 
                                         isDeleted, 
                                         CurrencyIsoCode, 
                                         OpportunityAutoNumber__c,
                                         OpportunityNumber__c,
                                         AccountId, 
                                         Account.SAP_S2P_ID__c,
                                         Account.MDM_Customer_Id__c,
                                         Account.SAP_S2P_ID_Number__c,
                                         Account.PrimaryMarketCountry__c,
                                         Account.Trade_Classification__c,
                                         Trade_Classifications__c,
                                         MDM_Customer_Id__c,
                                         Description,
                                         Sequence__c,
                                         Parent_Contract__c,
                                         Legacy_Estimated_Deal_Value__c,
                                         Legacy_Status_Of_Business__c,
                                         Legacy_Sales_Process_Stage__c,
                                         Legacy_Process_Track_Text__c,
                                         CFR_Signum__c,
                                         CSR_Signum__c,
                                         Contract_Manager_Signum__c,
                                         Parent_Original_Opportunity__r.OpportunityNumber__c, 
                                         Parent_Original_Opportunity__r.Amount,
                                         Parent_Original_Opportunity__r.CloseDate,
                                         Parent_Original_Opportunity__r.Probability,
                                         Parent_Original_Opportunity__r.CurrencyIsoCode
                                         FROM Opportunity 
                                         WHERE OpportunityNumber__c IN : oppNums];
            return oppList;
    }

/****************************************************************
* @author: Linda Pavare
* @date: 2017-10-17
* @param: oppId
* @return: oppList
* @description: This method queries and returns Opportunities and related Contracts' information by given Opportunity Ids
*****************************************************************/     
    public static List<Opportunity> getOpportunitiesWithContractsByOppNum(List<String> oppId){
        Set<String> oppIds = new Set<String>();
        for(String i: oppId){oppIds.add(i);}
        List<Opportunity> oppList = [SELECT Id, OpportunityNumber__c, OpportunityAutoNumber__c, AccountId, (SELECT Id, Contract_ID__c,Parent_Contract__c,Parent_Contract__r.Contract_ID__c FROM Contracts__r) FROM Opportunity WHERE OpportunityNumber__c IN : oppIds];
        return oppList;
    }
    /****************************************************************
* @author: Manu Singhal  
* @date: 4-10-2019
* @param: accWithOpptyListMap
* @description: This method will send an email to trade compliance mailbox(U-0913)
*****************************************************************/
    public static void sendEmailToAllOpptysForTradeCompliance(Map<Account,List<Opportunity>> accWithOpptyListMap)
    {	Try{
        OrgWideEmailAddress owa = [select id, DisplayName, Address from OrgWideEmailAddress limit 1];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        String subject;
        String str;
        String str1;
        String str2;
        for(Account acc : accWithOpptyListMap.keyset())
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owa.id);
            mail.setToAddresses(new String[] {GlobalConstants.EmailAddressForTradeCompliance});
            mail.setTargetObjectId(userInfo.getUserId());
            subject = 'Trade Compliance Notification for Opportunities related to Account '+ acc.Name;
            str = '<html><body><p> Hi, this is a Trade Compliance notification for an update on Account <a href="'+GlobalConstants.OrgbaseURL +'/'+acc.id+'">'+ acc.Name +
                '</a> with Billing Country '+ acc.BillingCountry + ' and Trade Classification '+ acc.Trade_Classification__c +
                '. You can find more information on the Opportunities that are associated with this Account below: </p><p>Opportunity Details:</p><table border ="1"><th>Opportunity Name</th><th>Opportunity Owner</th><th>Stage</th>';
            str1 = '';
            for(Opportunity opp: accWithOpptyListMap.get(acc))
            {
                str1 = str1 + '<tr><td><a href="'+GlobalConstants.OrgbaseURL+'/'+opp.id+'">'+ opp.Name +'</a></td><td>'+ opp.owner.Name +'</td><td>'+opp.StageName+'</td></tr>';
            }
            str2 = '</table><p>Best Regards,<br>Salesforce CRM</p></body></html>';
            String body = str + str1 + str2;
            mail.setHtmlBody(body);
            mail.setSubject(subject);
            allmsg.add(mail);
        } 
        Messaging.SendEmailResult[] results;
        results = Messaging.sendEmail(allmsg);
        if (results[0].success) {
           
        } else {
  
        } 
        }catch(Exception e){	}
    }   
    /****************************************************************
* @author: 
* @date: 22-01-2021
* @param: campainMemberList
* @description: U-1839, This method will return Map(ContactID, CampaignID)
*****************************************************************/
    public static Map<ID,ID> contactID2CampaignIDMap (List<CampaignMember> newCampaignMembers)
    {
        Map<Id,Map<Id,Datetime>> conCmpMap=new Map<Id,Map<Id,Datetime>>();
        Map<Id,Id> conIdCmpIdMap=new Map<Id,Id>();
        try{  
            for(CampaignMember cmp: newCampaignMembers) {                
               // if(conCmpMap!=null){
                    if(conCmpMap.containsKey(cmp.ContactId)){
                        Map<Id,Datetime> cmpMap=conCmpMap.get(cmp.ContactId);
                        cmpMap.put(cmp.CampaignId,cmp.LastModifiedDate);
                        conCmpMap.put(cmp.ContactId,cmpMap);    
                    }
                    else{
                        Map<Id,Datetime> cmpMap=new Map<Id,Datetime>();
                        cmpMap.put(cmp.CampaignId,cmp.LastModifiedDate);
                        conCmpMap.put(cmp.ContactId,cmpMap);    
                    }
                /*}
                else{
                    Map<Id,Datetime> cmpMap=new Map<Id,Datetime>();
                    cmpMap.put(cmp.CampaignId,cmp.LastModifiedDate);
                    conCmpMap.put(cmp.ContactId,cmpMap);    
                }*/
            }
			//System.debug('conCmpMap : '+conCmpMap);
            
            for(Id conId : conCmpMap.keySet()){
               // System.debug('conId : '+conId);
                Map<Id,Datetime> cmpMap=conCmpMap.get(conId);
                Datetime flag;
                Id cmpIdFlag;
                for(Id cmpId: cmpMap.keySet()){
                    DateTime cmpDate=cmpMap.get(cmpId);
                    if(flag==null){
                        flag=cmpDate;
                        cmpIdFlag=cmpId;
                    }
                    else{
                        if(flag<cmpDate){
                            flag=cmpDate;
                            cmpIdFlag=cmpId;
                        }
                    }
                }
              //  System.debug('flag: '+flag);
             //   System.debug('cmpIdFlag: '+cmpIdFlag);
                conIdCmpIdMap.put(conId,cmpIdFlag);
            }
            //System.debug('conIdCmpIdMap: '+conIdCmpIdMap);
            
            return conIdCmpIdMap;
        }catch (Exception e) {
            return null;
        }
    }  	
}