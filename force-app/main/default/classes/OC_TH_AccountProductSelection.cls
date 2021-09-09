/**
* @File Name          : OC_TH_AccountProductSelection
* @Description        : Ticket Handling: This is the controller class for OC_TH_AccountProductSelectionCmp
                        to Multi select Accounts and Products for Routing Rules                        
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 01 July 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-01                 IBM                  Initial Version
**/
public class OC_TH_AccountProductSelection {   
    /**********************************************************************
* @Description : This method returns record type of Product2.  
* @Return      : Map of product2 recordType's product Id and Name.
*****************************************************************************/
    @AuraEnabled
    public static Map<String,String> getProductRecordTypes(){   
        
        Map<String,String> recordTypeMap = new Map<String,String>();
        /*Fetch Product2 Record types*/
        try{
        for(RecordType rec : [SELECT Id,  Name, DeveloperName, Description FROM RecordType 
                              WHERE SobjectType =: OC_TH_Constants.getProduct2 
                              AND DeveloperName !=: OC_TH_Constants.NotServiceElementRecordType]){
                                  recordTypeMap.put(rec.Id, rec.Name);
                              }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_getProductRecordTypes,null, false, e));
        }
        return recordTypeMap;
        
    }
    /********************************************************************************
* @Description : This method returns list of Account Name from Routing Rule object.
* @Param       : routingRuleId - Passing routing rule Id to fetch account name.
* @Returns     : Returns list of Account Name.
***********************************************************************************/
    @AuraEnabled
    public static List <Account> fetchSelectedAccountsOnly(String routingRuleId) {
        
        Set<String> accIdset = new Set<String>();
        List<Account> accList = new List<Account>();
        try{
        /*Fetch Service-To-Party Id and return associated account Names*/
        OC_TH_Routing_Rules__c fetchSelectedValFromRule = [SELECT Id, Tech_OC_TH_Service_To_Party_ID__c 
                                                           FROM OC_TH_Routing_Rules__c 
                                                           WHERE ID =: routingRuleId];
        if(fetchSelectedValFromRule.Tech_OC_TH_Service_To_Party_ID__c != Null ){
            String [] splitIdText = fetchSelectedValFromRule.Tech_OC_TH_Service_To_Party_ID__c.split(OC_TH_Constants.getHashTagDelimiter);
            accIdset.addAll(splitIdText);
        }
        accList= [SELECT Name FROM Account WHERE Id In: accIdset ORDER BY Name ASC];
       
            }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_fetchSelectedAccountsOnly,null, false, e));
        }
        return accList;
    }
    /**********************************************************************************
* @Description : This method handles routing rule Service To Party logical operator
                 selected by Customers.
* @Returns     : Returns Map of logical picklist values.
***********************************************************************************/
    @AuraEnabled 
    public static Map<String, String> getLogicalOpeartorCustomerValues(){
        
        Map<String, String> options = new Map<String, String>();  
        try{
        /*Get logical operator*/
        Schema.DescribeFieldResult fieldResult = OC_TH_Routing_Rules__c.OC_TH_Logic_Operator_Customer__c.getDescribe();       
        List<Schema.PicklistEntry> pValues = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pValues) {
            options.put(p.getValue(), p.getLabel());
        }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_getLogicalOpeartorCustomerValues,null, false, e));
        }
        return options;
    }
    /**********************************************************************************
* @Description : This method passes the service to party logical operator to 
                 lightning component UI.
* @Params      : RoutingId - Pass routing rule Id.
* @Returns     : Returns logical picklist values.
***********************************************************************************/
    @AuraEnabled 
    public static OC_TH_Routing_Rules__c getRoutingRuleLogicalOperator(String RoutingId){
        OC_TH_Routing_Rules__c fetchRoutingLogicalOperator = new OC_TH_Routing_Rules__c();
        try{
        /*Fetch logical operator selected by user from detail page and return the value to Component UI */
         fetchRoutingLogicalOperator = [SELECT OC_TH_Logic_Operator_Customer__c FROM OC_TH_Routing_Rules__c 
                                                              WHERE ID =: RoutingId];
         
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_getRoutingRuleLogicalOperator,null, false, e));
        }
         return fetchRoutingLogicalOperator;
    }
    /**********************************************************************************
* @Description : This method prints the value selected from Lightning Component UI
to custom field.
* @Params      : RoutingId - Pass routing rule Id.
* @Params      : selectedOperator - Pass selected operator by BDA users.
* @Returns     : Returns logical picklist values.
***********************************************************************************/       
    @AuraEnabled 
    public static String associateLogicalOperatorToRoutingRule(String RoutingId,String selectedOperator){
         String message;
         //New code
         OC_TH_Routing_Rules__c ruleValues= [Select Id, OC_TH_Logic_Operator_Customer__c,OC_TH_ServiceToParty__c from OC_TH_Routing_Rules__c where Id=:RoutingId];
     try{
        /*Stamp logical operator to custom field*/ 
          OC_TH_Routing_Rules__c routingRule = new OC_TH_Routing_Rules__c();
         if(String.isNotBlank(selectedOperator)){         
            routingRule.Id = RoutingId;
            routingRule.OC_TH_Logic_Operator_Customer__c = selectedOperator;
          //  system.debug(' associateLogicalOperatorToRoutingRule routingRule>>>>' +routingRule);
            update routingRule;
            message= OC_TH_Constants.getSuccess;
         } else if(String.isBlank(selectedOperator) && String.isBlank(ruleValues.OC_TH_ServiceToParty__c)){
            routingRule.Id = RoutingId;
            routingRule.OC_TH_Logic_Operator_Customer__c = selectedOperator;
           // system.debug(' associateLogicalOperatorToRoutingRule routingRule else if>>>>' +routingRule);
            update routingRule;
            message= OC_TH_Constants.getSuccess;            
         }else{
            message= OC_TH_Constants.getError;
         }             
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_associateLogicalOperatorToRoutingRule,null, false, e));
        }
       // system.debug('message>>>' +message);
    	return message;
        
    }
    /*****************************************************************************************
* @Description : This method handles to print selected Product2 Names in custom component
* @Params      : routingId - Pass routing rule Id.
* @Returns     : Returns list of Produtc2 names.
*****************************************************************************************/      
    @AuraEnabled
    public static List<Product2> getProductName(String routingId){
        
        List<String> product2Name = new List<String>();
        List<Product2> product2List = new List<Product2>();
        try{
        /*Fetch node type ,node compoent and Solution values */
        OC_TH_Routing_Rules__c fetchRoutingProductName = [SELECT Id,OC_TH_NodeTypeProduct__c,OC_TH_NodeComponentProduct__c,OC_TH_SolutionProduct__c 
                                                          FROM OC_TH_Routing_Rules__c 
                                                          WHERE Id =: routingId];
        /*Split delimiter and add values to Set */
        if(fetchRoutingProductName.OC_TH_NodeTypeProduct__c != Null){
            String[] nodeTypeSplit = fetchRoutingProductName.OC_TH_NodeTypeProduct__c.split(OC_TH_Constants.getHashTagDelimiter);
            product2Name.addAll(nodeTypeSplit);
        }
        if(fetchRoutingProductName.OC_TH_NodeComponentProduct__c != Null){
            String[] nodeComponentSplit = fetchRoutingProductName.OC_TH_NodeComponentProduct__c.split(OC_TH_Constants.getHashTagDelimiter);
            product2Name.addAll(nodeComponentSplit);
        }
        if(fetchRoutingProductName.OC_TH_SolutionProduct__c != Null){
            String[] solutionSplit = fetchRoutingProductName.OC_TH_SolutionProduct__c.split(OC_TH_Constants.getHashTagDelimiter);
            product2Name.addAll(solutionSplit);
        }
        system.debug('product2Name>>' +product2Name);
        /*Fetch Product2 Name*/
        //new code
        if(product2Name.size()>0){
        product2List = [SELECT Name,RecordType.Name,RecordTypeId FROM Product2 
                                       WHERE Name =: product2Name AND RecordTypeId != '' AND isActive = True AND Name != Null ]; 
        }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_getProductName,null, false, e));
        }
        system.debug('product2List>>>' +product2List);
        return product2List;
    }
    /*********************************************************************************
* @Description : This method is used to deserialize the Account details.
* @Params      : jsonInput - Passing Account details in JSON format.
* @Params      : routingId - Passing routing rule Id.
**********************************************************************************/   
   
    @AuraEnabled
    public Static String submitAccountDetails(String jsonInput,Id routingId, String logicalOpCustmer){
        system.debug('logicalOpCustmer>>>' +logicalOpCustmer);        
        String returnMessage;
        Boolean errorMessage= false;
      /*DeSerialize jsonInput and map the values */
        Map <String, Object> records   = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        Map<String, Object> selectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getSelectedStatus);
        Map<String, Object> deSelectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getDeSelectedStatus);
        system.debug('selectedRecord size>>' +selectedRecord);
        system.debug('deSelectedRecord size>>' +deSelectedRecord);
 
        try{
            if(String.isNotBlank(logicalOpCustmer) || (String.isBlank(logicalOpCustmer) && selectedRecord.isEmpty())){
                system.debug('%%%%%%%%%');
                for(String accountId: selectedRecord.keySet())
                {
                    system.debug('inside loop 1');                
                    Map<String, Object> individualRecords = (Map<String, Object>) selectedRecord.get(accountId);
                    String accId = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonRecordId));
                    String accName = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonRecordName));
                    String selectedState = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonSelectedRecordStatus));
                    /*Passing Checked/Selected accId,accName and selectedState to Helper class along with routing Id*/
                    OC_TH_AccountProductSelectionHelper.checkSelectedState(accId,accName,selectedState, routingId, logicalOpCustmer);  
                }
                //When no records are selected or user deselect all the accountsbut logical operator is selected
                //Uesr should receive error to select atlease one account, deselect will not happen
                if(selectedRecord.isEmpty() && String.isNotBlank(logicalOpCustmer)){
                    errorMessage= true;              
                }
                else{
                    //Do the deselect only when atleast one account is selected & 
                    //logical operator is not blank
                     for(String deSelectedAccountId: deSelectedRecord.keySet())
                {
                    system.debug('inside loop 2');
                    Map<String, Object> getSingleRec = (Map<String, Object>) deSelectedRecord.get(deSelectedAccountId);
                    String accId = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonRecordId));
                    String accName = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonRecordName));
                    String deSelectedState = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonSelectedRecordStatus));
                    /*Passing UnChecked/De-Selected accId,accName and deSelectedState to Helper class along with routing Id */
                    OC_TH_AccountProductSelectionHelper.checkSelectedState(accId,accName,deSelectedState, routingId, logicalOpCustmer);                    
                }  
                }
                             
                if(errorMessage==false){
                    // When service to party is not blank in database and user only try to update LOC
                    OC_TH_Routing_Rules__c rountingRuleAfterUpdate= returnRoutingRuleData(routingId);
                    if((String.isNotBlank(rountingRuleAfterUpdate.OC_TH_ServiceToParty__c)) || (rountingRuleAfterUpdate.OC_TH_ServiceToParty__c!='')){
                      OC_TH_AccountProductSelection.associateLogicalOperatorToRoutingRule(routingId, logicalOpCustmer);
                    }
                     returnMessage= OC_TH_Constants.getSuccess;                  
                }
                else{
                    returnMessage= OC_TH_Constants.getErrorMessage;  
                }
               
           }
            else{
                 system.debug('$$$$$$$$$$$');
                returnMessage= OC_TH_Constants.getError;  
            }
            
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_submitAccountDetails,null, false, e));
        }
       
        return returnMessage;
    } 
    /***************************************************************************
* @Description : Generic method to return data from Routing rule
* @Params      : jsonInput - Passing Account details in JSON format.
* @Params      : routingId - Passing routing rule Id.
*******************************************************************************/
    public Static OC_TH_Routing_Rules__c returnRoutingRuleData(Id routingId){
         OC_TH_Routing_Rules__c rountingRule= [Select Id, OC_TH_Logic_Operator_Customer__c,OC_TH_ServiceToParty__c from OC_TH_Routing_Rules__c where Id=:routingId];
  	     return rountingRule;
        
    }
    
    /***************************************************************************
* @Description : This method is used to deserialize the Product details.
* @Params      : jsonInput - Passing Account details in JSON format.
* @Params      : routingId - Passing routing rule Id.
*******************************************************************************/
    @AuraEnabled
    public Static Void submitProduct2Details(String jsonInput,Id routingId){
        /*DeSerialize jsonInput and map the values */
        Map <String, Object> records   = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        Map<String, Object> selectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getSelectedStatus);
        Map<String, Object> deSelectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getDeSelectedStatus);
        try{
        for(String selectedProduct2Id: selectedRecord.keySet())
        {
            Map<String, Object> individualRecords = (Map<String, Object>) selectedRecord.get(selectedProduct2Id);
            String prodId = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonRecordId));
            String prodName = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonRecordName));
            String selectedState = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonSelectedRecordStatus));
            /*Passing Checked/Selected prodId,prodName and selectedState to Helper class along with routing Id*/
            OC_TH_AccountProductSelectionHelper.associateProductsToRoutingRule(prodId,prodName, selectedState, routingId);  
        }
        for(String deSelectedProduct2Id: deSelectedRecord.keySet())
        {
            Map<String, Object> getSingleRec = (Map<String, Object>) deSelectedRecord.get(deSelectedProduct2Id);
            String prodId = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonRecordId));
            String prodName = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonRecordName));
            String deSelectedState = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonSelectedRecordStatus));
            /*Passing UnChecked/De-Selected prodId,prodName and deSelectedState to Helper class along with routing Id */
            OC_TH_AccountProductSelectionHelper.associateProductsToRoutingRule(prodId,prodName, deSelectedState, routingId);  
        }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_submitProduct2Details,null, false, e));
        }
    }
    /****************************************************************************
* @Description : This method handles Scroll logics on Account selection model. 
* @Params      : wrapper - wrapper class is used to get;set Account Id and Name.
* @Returns     : Returns list of Account Wrapper.
******************************************************************************/
    @AuraEnabled
    public Static AccountListWrapper scrollAccountData(AccountProductSelectionWrapper wrapper){
        
        AccountListWrapper accListWrapper = new AccountListWrapper();
        accListWrapper.isCompleted = wrapper.isCompleted;
        Set<AccountWrapper> accs = new Set<AccountWrapper>();
        accListWrapper.accounts = accs;
        try{
        Id accountServiceRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(OC_TH_Constants.getAccountServiceRecordType).getRecordTypeId();
        List<Account> accountList = new List<Account> ();
        /*Get the count of service account*/
        AggregateResult ar = [SELECT count(Id) FROM Account 
                              WHERE Account_Type__c =: OC_TH_Constants.getAccountTypeService 
                              AND RecordTypeId =: accountServiceRecordType];
        Integer accountCount = Integer.valueOf(ar.get('expr0'));
        /*To handle infinity scroll in custom component*/
        if(wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < accountCount){
            accountList = [Select Id, Name From Account 
                           WHERE Account_Type__c =: OC_TH_Constants.getAccountTypeService 
                           AND RecordTypeId = :accountServiceRecordType  
                           ORDER BY Name ASC LIMIT 1000 OFFSET :wrapper.offsetCount];
        }
        else if(wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0)){
            accountList = [Select Id, Name From Account 
                           WHERE  Account_Type__c =: OC_TH_Constants.getAccountTypeService 
                           AND RecordTypeId = :accountServiceRecordType 
                           ORDER BY Name ASC LIMIT 1000];
        }
        else if(accountCount == wrapper.offsetCount){
            accListWrapper.isCompleted = true;
        }
        for(Account acc : accountList){
            AccountWrapper addAccount = new AccountWrapper();
            addAccount.Id = acc.Id;
            addAccount.Name = acc.Name; 
            accs.add(addAccount);
        }
        accListWrapper.accounts = accs;
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return accListWrapper;
    }
    /*********************************************************************************
* @Description : This method handles Scroll logics on Product2 selection model. 
* @Params      : wrapper - wrapper class is used to get;set Product2 Id and Name.
* @Returns     : Returns list of Product2 Wrapper.
**********************************************************************************/
    @AuraEnabled
    public static ProductListWrapper getProducts(ProductSelectionWrapper wrapper){
        ProductListWrapper productsListWrapper = new ProductListWrapper();
        productsListWrapper.isCompleted = wrapper.isCompleted;
        Set<ProductWrapper> products = new Set<ProductWrapper>();
        productsListWrapper.products = products;
        productsListWrapper.RecordTypeId = wrapper.RecordType;
        
        Map<Id, OC_MD_ProductAttributes__c> productAttributesMap = new Map<Id, OC_MD_ProductAttributes__c>();
        Map<Id, Product2> productMap = new Map<Id, Product2>();
        Map<Id, Set<OC_MD_ProductAttributes__c>> releaseMap = new Map<Id, Set<OC_MD_ProductAttributes__c>>();
        Map<Id, Set<OC_MD_ProductAttributes__c>> versionMap = new Map<Id, Set<OC_MD_ProductAttributes__c>>();
        
        try{   
            /*Get the record type ID's */
            String[] productRecordType = new String[]{OC_TH_Constants.getNodeTypeRecordTypeId,OC_TH_Constants.getNodeComponentRecordTypeId,OC_TH_Constants.getSolutionRecordTypeId}; 
                List<Product2> productsListGrid = new List<Product2> ();
            /*Get the count of Node type,node component and Solution Product2 Records*/
            AggregateResult ar = [SELECT count(Id) FROM Product2 WHERE Id != null AND RecordTypeId =: productRecordType];           
            Integer productCount = Integer.valueOf(ar.get('expr0'));
            /*To handle infinity scroll in custom component*/
            if(wrapper.offsetCount != null && wrapper.offsetCount > 0 && wrapper.offsetCount < productCount)
                productsListGrid = [Select Id, Name,RecordTypeId,isActive From Product2 
                                    WHERE Id != null AND RecordTypeId = : wrapper.RecordType AND RecordTypeId != Null AND isActive = True AND Name != Null
                                    ORDER BY Name ASC LIMIT 1000 OFFSET :wrapper.offsetCount];
            else if(wrapper.offsetCount == null || (wrapper.offsetCount != null && wrapper.offsetCount == 0))
                productsListGrid = [Select Id, Name,RecordTypeId,isActive From Product2 
                                    WHERE Id != null AND RecordTypeId = :wrapper.RecordType AND RecordTypeId != Null AND isActive = True AND Name != Null
                                    ORDER BY Name ASC LIMIT 1000];
            else if(productCount == wrapper.offsetCount){
                productsListWrapper.isCompleted = true;
            }
            
            for(Product2 p : productsListGrid){
                System.debug('Product details :--'+p);
                ProductWrapper addProd = new ProductWrapper();
                addProd.Id = p.Id;
                addProd.Name = p.Name; 
                products.add(addProd);
            }
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        productsListWrapper.products = products;
        return productsListWrapper;
    }
    /****************************************************************************
* @Description : This method handles when Non-BDA Users tries to Edit 
                 the lightning Custom Account/Product button and 
                 logical operator Picklist values
* @Returns     : Returns error message for Non-BDA users.
******************************************************************************/
    @AuraEnabled
    Public static Boolean showErrorMessage(){ 
        
        Boolean errorMessage = True;
        Set<String> setPermissionSetId = new Set<String>();
         Set<Id> psAssigneeId = new Set<Id>();
        try{
        /*Get User Id and profile ID*/
        Id getUserId = userinfo.getUserId();
        Id profileId = userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;

        /*Fetch Assignee's from BDA permissionSet and add to SET*/
        for(PermissionSetAssignment psaId : [SELECT Id,PermissionSet.Name,PermissionSetId,AssigneeId FROM PermissionSetAssignment 
                                             WHERE PermissionSet.Name =: OC_TH_Constants.getBDAPermissionSet]){
                                                 psAssigneeId.add(psaId.AssigneeId);
                                             }
        /*Check whether logged in User is an assignee in BDA PermissionSet and User is assigned 'Ericsson Service' Profile*/
        if(!psAssigneeId.isEmpty() && getUserId != Null  && !psAssigneeId.contains(getUserId) && String.isNotBlank(profileName) && profileName.contains(OC_TH_Constants.getEricssonServiceProfile)){
            errorMessage = False;  
        }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_showErrorMessage,null, false, e));
        }
        return errorMessage;
    }
    /****************************************************************************
* @Description : This method handles to show error message 
when Text field exceeds the limit(255 character). 
* @Params      : jsonInput - Passing JSON format.
* @Params      : routingId - Passing routing rule Id.
******************************************************************************/        
    @AuraEnabled
    public static Boolean validationForLength(String jsonInput,Id routingId){
        system.debug('String jsonInput>>>' +jsonInput);
        Boolean limitExceeded;
        try{
        /*DeSerialize jsonInput and Map the values */
        Map <String, Object> records   = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        Map<String, Object> selectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getSelectedStatus);
        Map<String, Object> deSelectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getDeSelectedStatus);
        
        List<String> selectedAccName= new List<String>();
        for(String accountId: selectedRecord.keySet())
        {
            Map<String, Object> individualRecords = (Map<String, Object>) selectedRecord.get(accountId);         
            String accName = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonRecordName));
            selectedAccName.add(accName);
        }
            /*Check length of technical Service to Party ID and Service To Party*/
        String cumulativeLength='';
        String cumulativeLengthForName='';
        String delimiter = OC_TH_Constants.getHashTagDelimiter;
            /* Store technical service to party ID and Check the lenght after adding delimiter*/             
        for(String str:selectedRecord.keySet()){
            if(str!= null && str !='0' && str!=''){
                cumulativeLength += str+delimiter;
            }            
        }
            /* Store technical service to party Name and Check the lenght after adding delimiter*/
        for(String str:selectedAccName){
            if(str!= null && str !='0' && str!=''){
                cumulativeLengthForName += str+delimiter;
            }            
        }
        /*If Text field exceeds more than 255char, Show Error message to Users*/
        if(((cumulativeLength.length()-1)>255) || ((cumulativeLengthForName.length()-1)>255)){
            limitExceeded= True;
        }else{
            limitExceeded= false;
        }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_validationForLength,null, false, e));
        }
        return limitExceeded;       
    }
    /*****************************************************************
* @Description :  Wrapper Class for Account and Products selection
**********************************************************************/ 
    /*Account Wrapper Class*/
    public class AccountProductSelectionWrapper{
        @AuraEnabled 
        public Boolean isCompleted{public get;public set;}
        @AuraEnabled 
        public Integer offsetCount{public get;public set;}
        @AuraEnabled
        public Set<Id> account{public get;public set;}
    }
    public class AccountListWrapper{
        @AuraEnabled
        public Set<AccountWrapper> accounts{public get;public set;}
        @AuraEnabled 
        public Boolean isCompleted{public get;public set;}   
    }
    public class AccountWrapper{
        @AuraEnabled
        public String Name{public get;public set;}
        @AuraEnabled
        public String Id{public get;public set;} 
    }
    /* Product Wrapper Class*/
    public class ProductSelectionWrapper{
        @AuraEnabled 
        public Boolean isCompleted{public get;public set;}
        @AuraEnabled 
        public Integer offsetCount{public get;public set;}
        @AuraEnabled
        public Set<Id> product{public get;public set;}
        @AuraEnabled
        public String RecordType{public get;public set;}
    }
    public class ProductListWrapper{
        @AuraEnabled
        public Set<ProductWrapper> products{public get;public set;}  
        @AuraEnabled 
        public Boolean isCompleted{public get;public set;} 
        @AuraEnabled
        public String RecordTypeId{public get;public set;}
    }
    public class ProductWrapper{
        @AuraEnabled
        public String Name{public get;public set;}
        @AuraEnabled
        public String Id{public get;public set;}
    }  
}