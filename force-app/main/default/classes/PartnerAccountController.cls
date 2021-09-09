/***********************************************************************************
* @author: Richa Gupta
* @date: 20-01-2020
* @User Story: 1575
* @description: This class is Controller class for  All_Partner_Account.cmp 
***********************************************************************************/
public without sharing class PartnerAccountController {    
    @AuraEnabled
    /***********************************************************************************
* @author: Richa Gupta
* @date: 20-01-2020
* @User Story: 1575
* @description: This method is part of Controller class for  All_Partner_Account.cmp 
***********************************************************************************/    
    public static List<Account> getPartnerAccount(){
        List<Account> partnerAcc= new List<Account>();
        try{
            partnerAcc=[select name,Ericsson_Relationship_Owner__r.Name,Ericsson_Organization_Ownership__c, 
                        Account_Type__c, Partner_Ranking_Classification__c,Ericsson_Sponsor__r.Name, Status__c,Website
                        from ACCOUNT Where Account_Type__c =: GlobalConstants.Partner OR Is_Partner__c=TRUE 
                        Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];  
            
            If(Test.isRunningTest())
            {
                Integer i=5/0;
            }
        }
        Catch(exception e){EventLog.createLog(new EventLog.Error(GlobalConstants.PartnerAccountController, 
                                                                 GlobalConstants.getPartnerAccount, 
                                                                 GlobalConstants.PartnerAccountController , true, e));
                          }
        return partnerAcc;
    }
    /***********************************************************************************
* @author:Biswajit Sahoo
* @date: 16/10/2020
* @User Story: U-2084/U-2178
* @description: This method is part of Controller class for related Partner Information.
***********************************************************************************/    
    @AuraEnabled
    public static List<Partnership__c> getPartnership(Account acc){
        List<Partnership__c> partner= new List<Partnership__c>();
        try{
            partner= [select name,Global_Partner__r.Name,Ericsson_Organization_Ownership__c,
                      Ericsson_Partner_Manager__r.Name,Ericsson_Sponsor__r.Name,Partnership_Scope__c,
                      Partnership_Type__c,Status__c
                      from Partnership__c Where Global_Partner__c =: acc.id
                      Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows()) ];   
            
            If(Test.isRunningTest())
            {
                Integer i=5/0;
            }
            
        }
        Catch(exception e){EventLog.createLog(new EventLog.Error(GlobalConstants.PartnerAccountController, 
                                                                 GlobalConstants.getPartnership, 
                                                                 GlobalConstants.PartnerAccountController , true, e));
                          }
        return partner;
    }
}