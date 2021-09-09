/**
* @File Name          : OC_TH_CommunityCaseCreationHandler
* @Description        : Provide controllers for component c:omnichannelthemeContentSubContainerTicketCreate to create a case
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 20th July 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-07-20                 IBM                   Initial Version
* 2.0        2020-09-18                 IBM                   Main_Asset_Type_Fix
* 3.0        2020-12-16                 IBM                   Removed custom file related variables
* 4.0   	 2021-03-22					IBM					  Removed Case Priority Picklist Values (Critical,Non-Critical) And Added assest Validation for "Ericsson Basic Product Support"
* 5.0        2021-06-09					IBM					  Removed Case Assignment Rules option check in Case Creation and Added 'Standard CSR Assignment Check' to be 'true' while saving a case.
* 6.0        2021-06-21                 IBM                   Added filter condtion for Account List 
**/
public without sharing class OC_TH_CommunityCaseCreationHandler {
    
    @AuraEnabled 
    public static Case saveCase(Case ca,Id assetId){
        system.debug('inside savecase>>>>>' +ca);
        
        List<String> allowedCaseType = System.Label.OC_Config_CustomerCaseType.split(';');
        if(!allowedCaseType.contains(ca.Type)){
            throw new AuraHandledException(Label.OC_Generic_Exception_Message);
        }
        
        if(ca.AssetId == null){
            ca.AssetId = assetId;
        }
        
        //2020-09-18 IBM Main_Asset_Type_Fix - Missing filter added to SOQL query
        Asset selectedAsset =  [SELECT Id, Name, RecordType.Name FROM Asset where Id = :ca.AssetId Limit 1];
        if(selectedAsset != NULL){
            ca.OC_TH_Main_Asset_Type__c = selectedAsset.RecordType.Name;
        }
        
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Standard CSR').getRecordTypeId();
        ca.Origin = 'Portal';  
        /*2021-06-04 || U-2773|| Aayush Sachdeva || Setting Case Assignment flag to true for Community users*/
        ca.OC_TH_Standard_CSR_Assignment_Check__c = true; 
        
        try{
            insert ca;
            ca = [select Id,CaseNumber,OC_TH_Case_Number__c from Case where id=:ca.Id];
        }
        catch(Exception e){
            throw new AuraHandledException(Label.OC_Generic_Exception_Message);
        }
        
        return ca;
    }
     // fetch permission set of LICSR	
    @AuraEnabled	
    public static Boolean getLICSRPermissionSet(){	
        String strEricssonLiCommunityUserPermissionSet = OC_TH_Constants.getEricssonLiCommunityUserPermissionSet;
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId	
                                                                FROM PermissionSetAssignment	
                                                                WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name =: strEricssonLiCommunityUserPermissionSet];	
        if(!lstcurrentUserPerSet.isEmpty()){
            return true;
        }
        return false;	
    }
    // Priyank added Checks for Erricsion Basic support and Removal of Case Priority Picklist Values (Critical,Non-Critical) Code Start 
    @AuraEnabled
    public static Boolean getServiceContractValidation(Id assetIds){
       
        Boolean validation = OC_SystemUtility.AssetValidationcheckforwithoutsharing( assetIds);
        return  validation;   
        
    }
    @AuraEnabled(cacheable=true) //get Case Priority Picklist Values
    public static Map<String, String> getPriority(){
        Map<String, String> options = new Map<String, String>();
        //get Case Priority Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Priority.getDescribe();
        //get Case Priority Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            
            
            if(p.getValue() == 'Non-Critical' || p.getValue() == 'Critical' || p.getValue() == '1'){}
            else{options.put(p.getValue(), p.getLabel());}
            
            
        }
        
        return options;
    }  
    // Priyank added Checks for Erricsion Basic support and Removal of Case Priority Picklist Values (Critical,Non-Critical) Code End   
    
    @AuraEnabled(cacheable=true) //get Case Type Picklist Values
    public static Map<String, String> getType(){
        Map<String, String> options = new Map<String, String>();
        List<String> allowedCaseType = System.Label.OC_Config_CustomerCaseType.split(';');
        //get Case Type Field Describe
        Schema.DescribeFieldResult fieldResult = Case.Type.getDescribe();
        //get Case Type Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            if(allowedCaseType.contains(p.getValue())){
                options.put(p.getValue(), p.getLabel());
            }
        }
        return options;
    }
    
    @AuraEnabled //get Accounts as list
    public static List<Account> getAccounts(){
        
        String accountType = 'Service';
        
        Set<Id> set_accessibleAccounts = new Set<Id>();
        
        User loggedInUser = [SELECT Id,Contact.AccountId,ContactId FROM User where id =: UserInfo.getUserId()];
        set_accessibleAccounts.add(loggedInUser.Contact.AccountId);
        Set<Id> accountIdSet = new Set<Id>();
        for(AccountContactRelation acr : [SELECT AccountId FROM 
                                          AccountContactRelation 
                                          WHERE ContactId =: loggedInUser.ContactId]){
                                              accountIdSet.add(acr.AccountId);
                                          }
        set_accessibleAccounts.addAll(accountIdSet);
        List<Account> listOfAccounts = new List<Account>([select id, Name from Account WHERE Id IN :set_accessibleAccounts AND CNS_Queue__c !=null AND Account_Type__c =:accountType order by createdDate]);
        system.debug('inside getAccounts>>>>' +listOfAccounts);
        return listOfAccounts;
    }
    
    @AuraEnabled //get Assets as list
    public static List<Asset> getAssets(){
        Set<Id> set_accessibleAccounts = new Set<Id>();
        
        User loggedInUser = [SELECT Id,Contact.AccountId,ContactId FROM User where id =: UserInfo.getUserId()];
        set_accessibleAccounts.add(loggedInUser.Contact.AccountId);
        Set<Id> accountIdSet = new Set<Id>();
        for(AccountContactRelation acr : [SELECT AccountId FROM 
                                          AccountContactRelation 
                                          WHERE ContactId =: loggedInUser.ContactId]){
                                              accountIdSet.add(acr.AccountId);
                                          }
        set_accessibleAccounts.addAll(accountIdSet);
        List<Asset> listOfAssets = new List<Asset>([select id, Name from Asset WHERE AccountId IN :set_accessibleAccounts order by createdDate]);
        return listOfAssets;
    }    
}