/**
* @File Name          : OC_TH_CustomLookUpControllerCommunity
* @Description        : Provide data to lookup component(c:omnichannelthemeElementLookupCommunity) in lightning
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 02 th July 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-02                 IBM                   Initial Version

**/
public with sharing class OC_TH_CustomLookUpControllerCommunity {
    @AuraEnabled
    public static List < sObject > fetchLookUpValuesTH (String searchKeyWord, String ObjectName,String contextIdentifier,Boolean isExtendedLookup, String lookupFields) {
      	
         
         
        
        if(searchKeyWord != '' && searchKeyWord != null){
            searchKeyWord = searchKeyWord.trim();
            searchKeyWord = '%' + searchKeyWord;
        }
        String searchKey = searchKeyWord + '%';
        String sQuery;
        String accountType = 'Service';
        List < sObject > returnList = new List < sObject > ();
        Set<Id> set_accessibleAccounts = new Set<Id>();
        Set<String> recordTypeSet = new Set<String> {OC_IB_Constants.serviceAccRTdevName,OC_IB_Constants.partnerAccRecType}; 
        
        if(UserInfo.getUserType() == 'PowerPartner' || UserInfo.getUserType() == 'CustomerSuccess' || UserInfo.getUserType() == 'PowerCustomerSuccess'){
            User loggedInUser = [SELECT Id,Contact.AccountId,ContactId FROM User where id =: UserInfo.getUserId()];
            set_accessibleAccounts.add(loggedInUser.Contact.AccountId);
            Set<Id> accountIdSet = new Set<Id>();
            for(AccountContactRelation acr : [SELECT AccountId FROM 
                                              AccountContactRelation 
                                              WHERE ContactId =: loggedInUser.ContactId]){
                                                  accountIdSet.add(acr.AccountId);
                                              }
            set_accessibleAccounts.addAll(accountIdSet);
            System.debug('list ofAccounts ' +accountIdSet);
        }
        else if(String.isNotBlank(contextIdentifier)){
            
            if(contextIdentifier.equalsIgnoreCase('Sfdc_Ebip_Ibase_OutApi') && ObjectName.equalsIgnoreCase(OC_IB_Constants.objectAccount)){ 
                set_accessibleAccounts.addAll((new map<Id,Account>([
                    Select Id from Account where 
                    Recordtype.developername=:OC_IB_Constants.serviceAccRTdevName and SAP_S2P_ID_Number__c!=null and Parent.SAP_S2P_ID_Number__c!=null and Parent.Recordtype.developername NOT IN:recordTypeSet])).keyset());
            }
       }
        
        else{
            set_accessibleAccounts.addAll((new map<Id,Account>([Select Id from Account])).keyset());
        }
       
          //2020-08-21 Building Standard/Extended Lookup Query.
        sQuery = 'Select ';
        
        if(isExtendedLookup && String.isBlank(contextIdentifier)){
            String [] fields = lookupFields.split(';');
            for(Integer i=0; i < fields.size(); i++){
                sQuery += fields[i];
                if(i < fields.size() - 1){
                    sQuery += ',';         
                }
                sQuery += ' ';
            }
        }
        //Adding squery for integration
        else if(String.isNotBlank(contextIdentifier) && contextIdentifier.equalsIgnoreCase('Sfdc_Ebip_Ibase_OutApi')){
            sQuery +=  ' id,name,SAP_S2P_ID_Number__c,Parent.SAP_S2P_ID_Number__c ';  
        }
        else{
            sQuery +=  'Id, Name ';             
        }
        
        sQuery +=  ' from ' +ObjectName + ' where ';
        
        if(isExtendedLookup){
            String [] fields = lookupFields.split(';');
            sQuery += ' ( ';
            for(Integer i=0; i < fields.size(); i++){
                sQuery += fields[i];
                sQuery += ' LIKE :searchKey';
                if(i < fields.size() - 1){
                    sQuery += ' OR ';         
                }
            }
            sQuery += ' ) ';
        }
        else{
            sQuery +=  ' Name LIKE :searchKey ';             
        }

         if(ObjectName == 'Account'){
            sQuery +=  ' AND Id IN :set_accessibleAccounts AND Account_Type__c =:accountType AND CNS_Queue__c !=null  order by createdDate DESC';
             System.debug('Check for sQuery ' +sQuery);
        }else if (ObjectName == 'Asset'){
            sQuery +=  ' AND AccountId IN :set_accessibleAccounts order by createdDate DESC';
        }else{
            sQuery +=  ' order by createdDate DESC';  
        }
        
        sQuery +=  ' Limit ';
        
        if(isExtendedLookup){
            if(OC_Org_Defaults__c.getOrgDefaults().OC_Extended_Lookup_Limit__c != null){
                sQuery +=  Integer.valueOf(OC_Org_Defaults__c.getOrgDefaults().OC_Extended_Lookup_Limit__c);
            }
            else{
                sQuery += '100';
            }
        }
        else{
            if(OC_Org_Defaults__c.getOrgDefaults().OC_Standard_Lookup_Limit__c != null){
                sQuery +=  Integer.valueOf(OC_Org_Defaults__c.getOrgDefaults().OC_Standard_Lookup_Limit__c);
            }
            else{
                sQuery += '5';
            }            
        }
        List < sObject > lstOfRecords = Database.query(sQuery);   
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        
       
        return returnList;
    }    
}