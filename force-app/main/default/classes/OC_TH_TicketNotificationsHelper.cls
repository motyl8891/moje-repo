public without sharing class OC_TH_TicketNotificationsHelper {
    /*********************************************************************************
* @Description : This method is used to deserialize the Account details.
* @Params      : jsonInput - Passing Account details in JSON format.
* @Params      : routingId - Passing routing rule Id.
**********************************************************************************/        
    @AuraEnabled
    public Static Void submitAccountDetails(String jsonInput,Id routingId){
        /*DeSerialize jsonInput and map the values */
        Map <String, Object> records   = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
        System.debug('Account Records:--'+records);
        Map<String, Object> selectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getSelectedStatus);
        System.debug('Selected Account Records:--'+selectedRecord);
        Map<String, Object> deSelectedRecord = (Map<String, Object>) records.get(OC_TH_Constants.getDeSelectedStatus);
        System.debug('De-Selected Account Records:--'+deSelectedRecord);
        try{
            for(String accountId: selectedRecord.keySet())
            {
                Map<String, Object> individualRecords = (Map<String, Object>) selectedRecord.get(accountId);
                String accId = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonRecordId));
                String selectedState = String.valueOf(individualRecords.get(OC_TH_Constants.getJsonSelectedRecordStatus));
                /*Passing Checked/Selected accId,accName and selectedState to Helper class along with routing Id*/
                checkSelectedState(accId,selectedState, routingId);  
            }
            for(String deSelectedAccountId: deSelectedRecord.keySet())
            {
                Map<String, Object> getSingleRec = (Map<String, Object>) deSelectedRecord.get(deSelectedAccountId);
                String accId = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonRecordId));
                String deSelectedState = String.valueOf(getSingleRec.get(OC_TH_Constants.getJsonSelectedRecordStatus));
                /*Passing UnChecked/De-Selected accId,accName and deSelectedState to Helper class along with routing Id */
                checkSelectedState(accId,deSelectedState, routingId);  
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelection,OC_TH_Constants.method_submitAccountDetails,null, false, e));
        }
    }
    /**************************************************************************************************
* @Description : This method prints the Account ID to service-to-party technical fields. 
* Params       : accId - pass Account ID from OC_TH_AccountProductSelection.printAccountName handler class
* Params       : accName - pass Account Name from OC_TH_AccountProductSelection.printAccountName handler class
* Params       : selectedState - pass selected status from OC_TH_AccountProductSelection.printAccountName handler class
* Params       : routingId - pass routing rule ID from OC_TH_AccountProductSelection.printAccountName handler class
*******************************************************************************************************/
  	@AuraEnabled(cacheable=true)
    Public static void checkSelectedState(String accId, String selectedState,Id routingId){
        
        String delimiter = '#';
        String accIdVal = '';
        String addAccId = '';
        Set<String> accIdSet = new Set<String>();
        Map<String,String> mapIdToAccName = new Map<String,String>();
        Contact fetchRule = [SELECT Id,OC_TH_Ticket_Notifications__c From Contact Where ID =: routingId];
        system.debug('condition--'+(fetchRule.OC_TH_Ticket_Notifications__c != Null));
        
        /*Split the service Id from text field and add it to Set */
        if(fetchRule.OC_TH_Ticket_Notifications__c != Null ){
            accIdVal =  fetchRule.OC_TH_Ticket_Notifications__c;
            String [] splitIdText = fetchRule.OC_TH_Ticket_Notifications__c.split('#');
            accIdSet.addAll(splitIdText);    
            system.debug('accIdSet' + accIdSet);
        }
        
        
        /*If Status is "Checked" then pass an Account Id and Name with delimiter to Custom fields */
        if(selectedState != Null && selectedState == 'checked' && accIdSet != Null){
            accIdVal =  accId + delimiter + accIdVal;
            system.debug('accIdVal' + accIdVal);
            String accountId = accIdVal.removeEnd('#');
            system.debug('accountId' + accountId);
            system.debug('fetchRuleID' + fetchRule.Id);
            accountInsertion(fetchRule.Id,accountId);
            
        }
        /*If Status is "UnChecked" then remove an Account Id and Name from Custom fields */
        if(selectedState != Null && selectedState == 'unchecked' && accIdSet != Null){
            accIdSet.remove(accId);
            system.debug('accIdSet' + accIdSet);                    
            
            /*Add remaining Account Id that are in accIdSet */
            if(!accIdSet.isEmpty() && !accIdSet.contains(accId)){
                for(String sendAccId : accIdSet){
                    addAccId =  sendAccId + delimiter + addAccId;
                    String accountId = addAccId.removeEnd('#');
                    accountInsertion(fetchRule.Id,accountId);
                }
            }
            else{
                accountInsertion(fetchRule.Id,null);
            }
        }
        /*Add remaining Account Name that are in accNameSet */
    }   
    /**************************************************************************************************
* @Description : This method handles Account insertion and deletion of field update.
* @Params       : AccountId - pass Account ID from "checkSelectedState" method to Insert record
* @Params       : AccountName - pass Account Name from "checkSelectedState" method to Insert record
* @Params       : routingId - pass routing rule ID 
* @Return       : return sucess status once Account is inserted or Removed
*******************************************************************************************************/
    public static String accountInsertion(String routingId,String AccountId){
        
        List<Contact> routingRuleList = new List<Contact>();
        map<id,Contact> mapRouting = new map<id,Contact>();
        map<id,Contact> mapAccNameRouting = new map<id,Contact>();  
        
        try{ /*Print accountId and accountName Value in custom field */
            if(String.isNotBlank(AccountId)){
                Contact routingAccount = new Contact();
                routingAccount.Id = routingId;
                routingAccount.OC_TH_Ticket_Notifications__c = AccountId;
                routingRuleList.add(routingAccount);
                mapRouting.putAll(routingRuleList);
            }
            /*Reset custom field when AccountId and AccountName are Null or Empty */
            else if(String.isBlank(AccountId)){
                Contact routingServiceToPartyName = new Contact();
                routingServiceToPartyName.Id = routingId;
                routingServiceToPartyName.OC_TH_Ticket_Notifications__c = '';
                routingRuleList.add(routingServiceToPartyName);
                mapAccNameRouting.putAll(routingRuleList); 
            }
            if(mapRouting.size()>0){
                Database.update(mapRouting.values());
            }
            if(mapAccNameRouting.size()>0){
                Database.update(mapAccNameRouting.values());
            }
        }catch(Exception e){
            //EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_AccountInsertion,null, false, e));
        }
        return OC_TH_Constants.getSuccess;
    }
    
    
}