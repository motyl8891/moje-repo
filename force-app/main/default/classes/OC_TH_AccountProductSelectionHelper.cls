/**
* @File Name          : OC_TH_AccountProductSelectionHelper
* @Description        : Ticket Handling: Multi select Accounts and Products for Routing Rules
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 01 July 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-07-01                 IBM                   Initial Version
**/
public class OC_TH_AccountProductSelectionHelper {
    
    /**************************************************************************************************
* @Description : This method prints the Account ID to service-to-party technical fields. 
* Params       : accId - pass Account ID from OC_TH_AccountProductSelection.printAccountName handler class
* Params       : accName - pass Account Name from OC_TH_AccountProductSelection.printAccountName handler class
* Params       : selectedState - pass selected status from OC_TH_AccountProductSelection.printAccountName handler class
* Params       : routingId - pass routing rule ID from OC_TH_AccountProductSelection.printAccountName handler class
*******************************************************************************************************/
    Public static void checkSelectedState(String accId, string accName, String selectedState,Id routingId,String logicalOpCustmer){
        system.debug('inside checkSelectedState');
        //String message;
        String delimiter = OC_TH_Constants.getHashTagDelimiter;
        String accIdVal = '';
        String accNameVal = OC_TH_Constants.getHashTagDelimiter;
        String addAccId = '';
        String accountName = OC_TH_Constants.getHashTagDelimiter;
        Set<String> accIdSet = new Set<String>();
        Set<String> accNameSet = new Set<String>();
        map<String,String> routinAccIdAndAccName = new Map<String,String>();
        Map<String,String> mapIdToAccName = new Map<String,String>();
        try{
            OC_TH_Routing_Rules__c fetchRule = [SELECT Id,Tech_OC_TH_Service_To_Party_ID__c,OC_TH_ServiceToParty__c FROM OC_TH_Routing_Rules__c
                                                WHERE ID =: routingId];
            system.debug('condition--'+(fetchRule.Tech_OC_TH_Service_To_Party_ID__c != Null));
            /*Split the service Id from text field and add it to Set */
            if(fetchRule.Tech_OC_TH_Service_To_Party_ID__c != Null ){
                accIdVal =  fetchRule.Tech_OC_TH_Service_To_Party_ID__c;
                String [] splitIdText = fetchRule.Tech_OC_TH_Service_To_Party_ID__c.split(OC_TH_Constants.getHashTagDelimiter);
                accIdSet.addAll(splitIdText);    
            }
            if(fetchRule.OC_TH_ServiceToParty__c != Null ){   
                accNameVal = fetchRule.OC_TH_ServiceToParty__c;
                String [] splitNameText = fetchRule.OC_TH_ServiceToParty__c.split(OC_TH_Constants.getHashTagDelimiter);
                accNameSet.addAll(splitNameText);
            }
            /*Fetch Account values and add to Map to hold Account Id and Account Name */
            for(Account acc : [SELECT Id,Name FROM Account WHERE Id =: accId]){
                mapIdToAccName.put(acc.Id,acc.Name);
            }
            /*If Status is "Checked" then pass an Account Id and Name with delimiter to Custom fields */
            if(String.isNotBlank(selectedState) && selectedState.equals(OC_TH_Constants.getChecked) && !mapIdToAccName.isEmpty()){
                system.debug('1111111111111');
                for(String mapAccId : mapIdToAccName.KeySet()){
                    if(!accIdSet.contains(mapAccId)){
                        system.debug('22222222222');
                        String getAccName = mapIdToAccName.get(mapAccId);
                        accIdVal =  mapAccId + delimiter + accIdVal;
                        String accountId = accIdVal.removeEnd(OC_TH_Constants.getHashTagDelimiter);
                        accNameVal = delimiter + getAccName + accNameVal;
                        accountInsertion(fetchRule.Id,accountId,accNameVal, logicalOpCustmer);
                    }
                }
            }
            /*If Status is "UnChecked" then remove an Account Id and Name from Custom fields */
            if(String.isNotBlank(selectedState) && selectedState.equals( OC_TH_Constants.getUnchecked) && !accIdSet.isEmpty() && !mapIdToAccName.isEmpty()){
               system.debug('3333333333');
                for(String serviceId : mapIdToAccName.KeySet()){
                    String getServiceName = mapIdToAccName.get(serviceId);
                    accIdSet.remove(serviceId);
                    accNameSet.remove(getServiceName);    
                } 
                /*Add remaining Account Id that are in accIdSet */
                if(!accIdSet.isEmpty() && !accIdSet.contains(accId)){
                    for(String sendAccId : accIdSet){
                        addAccId =  sendAccId + delimiter + addAccId;
                        String accountId = addAccId.removeEnd(OC_TH_Constants.getHashTagDelimiter);
                        accountInsertion(fetchRule.Id,accountId,null, logicalOpCustmer);
                    }
                }
                else{
                    accountInsertion(fetchRule.Id,null,null, logicalOpCustmer);
                }
                /*Add remaining Account Name that are in accNameSet */
                if(!accNameSet.isEmpty() && !accNameSet.contains(accName)){
                    for(String sendAccName : accNameSet){
                        if(String.isNotBlank(sendAccName)){
                            accountName = delimiter + sendAccName + accountName;
                            accountInsertion(fetchRule.Id,null,accountName, logicalOpCustmer);
                        }
                    }
                }
                else {
                    accountInsertion(fetchRule.Id,null,null, logicalOpCustmer);
                }
            }  
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_checkSelectedState,null, false,e));
        }
        //system.debug('checkSelectedState message>>>>' +message);
        //return message; 
    }
    /**************************************************************************************************
* @Description : This method handles Account insertion and deletion of field update.
* @Params       : AccountId - pass Account ID from "checkSelectedState" method to Insert record
* @Params       : AccountName - pass Account Name from "checkSelectedState" method to Insert record
* @Params       : routingId - pass routing rule ID 
* @Return       : return sucess status once Account is inserted or Removed
*******************************************************************************************************/
    public static String accountInsertion(String routingId,String AccountId,String AccountName, String logicalOpCustmer){
        system.debug('AccountName>>>' +AccountName);
        system.debug('AccountId>>>' +AccountId);
        system.debug('logicalOpCustmer>>>' +logicalOpCustmer);
        List<OC_TH_Routing_Rules__c> routingRuleList = new List<OC_TH_Routing_Rules__c>();
        map<id,OC_TH_Routing_Rules__c> mapRouting = new map<id,OC_TH_Routing_Rules__c>();
        map<id,OC_TH_Routing_Rules__c> mapAccNameRouting = new map<id,OC_TH_Routing_Rules__c>();  
        //String messageReturned;
        try{ /*Print accountId and accountName Value in custom field */                 
                    if(String.isNotBlank(AccountId) && String.isNotBlank(AccountName)){
                        system.debug('1@@@@');
                        OC_TH_Routing_Rules__c routingAccount = new OC_TH_Routing_Rules__c();
                        routingAccount.Id = routingId;
                        routingAccount.Tech_OC_TH_Service_To_Party_ID__c = AccountId;
                        routingAccount.OC_TH_ServiceToParty__c = AccountName;
                        routingRuleList.add(routingAccount);
                        mapRouting.putAll(routingRuleList);              
                    }
                    /*Print accountId in custom field */
                    if(String.isNotBlank(AccountId) && String.isBlank(AccountName)){
                         system.debug('2@@@@');
                        OC_TH_Routing_Rules__c routingServiceToPartyId = new OC_TH_Routing_Rules__c();
                        routingServiceToPartyId.Id = routingId;
                        routingServiceToPartyId.Tech_OC_TH_Service_To_Party_ID__c = AccountId;
                        routingRuleList.add(routingServiceToPartyId);
                        mapRouting.putAll(routingRuleList);
                    }
                    /*Print AccountName in custom field */
                    if(String.isNotBlank(AccountName) && String.isBlank(AccountId)){
                        system.debug('3@@@@');
                        OC_TH_Routing_Rules__c routingServiceToPartyName = new OC_TH_Routing_Rules__c();
                        routingServiceToPartyName.Id = routingId;
                        routingServiceToPartyName.OC_TH_ServiceToParty__c = AccountName;
                        routingRuleList.add(routingServiceToPartyName);
                        mapRouting.putAll(routingRuleList);
                    } 
                    /*Reset custom field when AccountId and AccountName are Null or Empty */
                    else if(String.isBlank(AccountId) && String.isBlank(AccountName)){
                         system.debug('4@@@@');
                        OC_TH_Routing_Rules__c routingServiceToPartyName = new OC_TH_Routing_Rules__c();
                        routingServiceToPartyName.Id = routingId;
                        routingServiceToPartyName.Tech_OC_TH_Service_To_Party_ID__c = '';
                        routingServiceToPartyName.OC_TH_ServiceToParty__c = '';
                        routingRuleList.add(routingServiceToPartyName);
                        mapAccNameRouting.putAll(routingRuleList); 
                    } 
            		//First update logical operator to bypass custom validation
            		//Custom validation does not allow to update service to party if LOC is blank
            		if(String.isNotBlank(logicalOpCustmer) && ((mapRouting.size()>0) || (mapAccNameRouting.size()>0)) ){           
                		OC_TH_AccountProductSelection.associateLogicalOperatorToRoutingRule(routingId, logicalOpCustmer);
					}
                    if(mapRouting.size()>0){
                        System.debug('mapRouting :--'+mapRouting);
                        System.debug('mapRouting :--'+mapRouting.values());
                        Database.update(mapRouting.values());     
                    }
                    if(mapAccNameRouting.size()>0){
                         System.debug('mapAccNameRouting :--'+mapAccNameRouting);
                        Database.update(mapAccNameRouting.values());
                    }
    }
        catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_AccountInsertion,null, false, e));
        }
         return OC_TH_Constants.getSuccess;
        
    }
    /**************************************************************************************************
* @Description : This method prints the Product2 ID to Node Type,Node Component and Solution technical fields. 
* Params       : prodId - pass Product2 ID from OC_TH_AccountProductSelection.printProduct2Name handler class
* Params       : prodName - pass Product2 Name from OC_TH_AccountProductSelection.printProduct2Name handler class
* Params       : selectedState - pass selected status from OC_TH_AccountProductSelection.printProduct2Name handler class
* Params       : routingId - pass routing rule ID from OC_TH_AccountProductSelection.printProduct2Name handler class
*******************************************************************************************************/
    Public static void associateProductsToRoutingRule(String prodId,String prodName, String selectedState,Id routingId){ 
        
        String delimiter = OC_TH_Constants.getHashTagDelimiter;
        String prodNodeTypIdVal = OC_TH_Constants.getHashTagDelimiter; 
        String prodCmpIdVal = OC_TH_Constants.getHashTagDelimiter;
        String prodSolIdVal = OC_TH_Constants.getHashTagDelimiter;
        String productName = OC_TH_Constants.getHashTagDelimiter;
        Set<String> addNodeTypeName = new Set<String>();
        Set<String> addCmpName = new Set<String>();
        Set<String> addSolutionName = new Set<String>();
        Set<String> setNodeName = new Set<String>();
        Set<String> setNodeComponentName = new Set<String>();
        Set<String> setSolutionName = new Set<String>();
        try{
            OC_TH_Routing_Rules__c getRoutingRule = [SELECT Id,OC_TH_NodeTypeProduct__c,OC_TH_NodeComponentProduct__c,OC_TH_SolutionProduct__c FROM OC_TH_Routing_Rules__c 
                                                     WHERE ID =: routingId];
            /*Split the NodeType ,Node Component and Solutions from text field and add it to Sets */
            if(getRoutingRule.OC_TH_NodeTypeProduct__c != Null){
                prodNodeTypIdVal = getRoutingRule.OC_TH_NodeTypeProduct__c;
                String[] nodeTypeSplit = getRoutingRule.OC_TH_NodeTypeProduct__c.split(OC_TH_Constants.getHashTagDelimiter);
                addNodeTypeName.addAll(nodeTypeSplit);
            }
            if(getRoutingRule.OC_TH_NodeComponentProduct__c != Null){
                prodCmpIdVal = getRoutingRule.OC_TH_NodeComponentProduct__c;
                String[] componentSplit = getRoutingRule.OC_TH_NodeComponentProduct__c.split(OC_TH_Constants.getHashTagDelimiter);
                addCmpName.addAll(componentSplit); 
            }
            if(getRoutingRule.OC_TH_SolutionProduct__c != Null){
                prodSolIdVal = getRoutingRule.OC_TH_SolutionProduct__c;
                String[] solutionSplit = getRoutingRule.OC_TH_SolutionProduct__c.split(OC_TH_Constants.getHashTagDelimiter);
                addSolutionName.addAll(solutionSplit);
            }
            /*Fetch Product details based on record type Id and add those Products to respective Sets*/
            for(Product2 pId : [SELECT Id,RecordTypeId,Name FROM Product2 WHERE Id =:prodId AND Name =: prodName]){
                If(pId.RecordTypeId == OC_TH_Constants.getNodeTypeRecordTypeId){
                    setNodeName.add(pId.Name);
                }
                if(pId.RecordTypeId == OC_TH_Constants.getNodeComponentRecordTypeId){
                    setNodeComponentName.add(pId.Name);
                }
                if(pId.RecordTypeId == OC_TH_Constants.getSolutionRecordTypeId){
                    setSolutionName.add(pId.Name);
                }
            }
            /*If status is "Checked" insert selected product values to respective methods*/
            if(String.isNotBlank(selectedState) && selectedState.equals(OC_TH_Constants.getChecked)){
                if(!setNodeName.isEmpty() && setNodeName.contains(prodName) && !addNodeTypeName.contains(prodName)){
                    prodNodeTypIdVal = delimiter + prodName + prodNodeTypIdVal;
                    productNodeType(getRoutingRule.Id,prodNodeTypIdVal);
                }
                else if(!setNodeComponentName.isEmpty() && setNodeComponentName.contains(prodName) && !addCmpName.contains(prodName)){
                    prodCmpIdVal = delimiter + prodName + prodCmpIdVal;
                    productNodeComponent(getRoutingRule.Id,prodCmpIdVal);
                }
                else if(!setSolutionName.isEmpty() && setSolutionName.contains(prodName) && !addSolutionName.contains(prodName)){
                    prodSolIdVal = delimiter + prodName + prodSolIdVal;
                    productSolution(getRoutingRule.Id, prodSolIdVal);
                }
            }
            /*If status is "UnChecked" remove selected product values and add remaining products to respective methods*/
            if(String.isNotBlank(selectedState) && selectedState.equals(OC_TH_Constants.getUnchecked)){
                if(addNodeTypeName.contains(prodName)){
                    /* Remove de-Selected Node type product from Set*/
                    addNodeTypeName.remove(prodName);
                    if(!addNodeTypeName.isEmpty()){
                        for(String nodeName : addNodeTypeName){
                            if(String.isNotBlank(nodeName) && !nodeName.contains(prodName)){  
                                productName = delimiter + nodeName + productName;
                                productNodeType(getRoutingRule.Id,productName);
                            }
                            else if(String.isBlank(nodeName)){
                                productNodeType(getRoutingRule.Id,null);
                            }
                        }
                    }
                }
                if(addCmpName.contains(prodName)){
                    /* Remove de-Selected Node Component product from Set*/
                    addCmpName.remove(prodName);
                    if(!addCmpName.isEmpty()){
                        for(String cmpName : addCmpName){
                            if(String.isNotBlank(cmpName) && !cmpName.contains(prodName)){  
                                productName = delimiter + cmpName + productName;
                                productNodeComponent(getRoutingRule.Id,productName);
                            } 
                            if(String.isBlank(cmpName)){
                                productNodeComponent(getRoutingRule.Id,null);
                            }
                        }
                    }
                }
                if(addSolutionName.contains(prodName)){
                    /* Remove de-Selected Solution product from Set*/
                    addSolutionName.remove(prodName);
                    if(!addSolutionName.isEmpty()){
                        for(String solName : addSolutionName){
                            if(String.isNotBlank(solName) && !solName.contains(prodName)){  
                                productName = delimiter + solName + productName;
                                productSolution(getRoutingRule.Id,productName);
                            } 
                            if(String.isBlank(solName)){
                                productSolution(getRoutingRule.Id,null);
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_associateProductsToRoutingRule,null, false, e));
        }
    }
    /**************************************************************************************************
* @Description :- This method handles product2 node type insertion and deletion of field update.                
- This method supports extension of multiple product selection functionality(Release,Version)
* @Params      : NodeType - pass Product nodeType Name from "associateProductsToRoutingRule" 
method to Insert record.
* @Params      : routingId - pass routing rule ID 
* @Return      : return sucess status once Node type product2 is inserted or Removed.
*******************************************************************************************************/
    public static String productNodeType(String routingId,String NodeType){
        List<OC_TH_Routing_Rules__c> routingProductList = new List<OC_TH_Routing_Rules__c>();
        Map<Id,OC_TH_Routing_Rules__c> mapIdValueToUpdate = new Map<Id,OC_TH_Routing_Rules__c>();
        try{
            if(String.isNotBlank(NodeType)){
                OC_TH_Routing_Rules__c nodeTypeId = new OC_TH_Routing_Rules__c();
                nodeTypeId.Id = routingId;
                nodeTypeId.OC_TH_NodeTypeProduct__c = NodeType;
                routingProductList.add(nodeTypeId); 
                mapIdValueToUpdate.putAll(routingProductList);  
            }
            else{
                OC_TH_Routing_Rules__c nodeTypeIdNull = new OC_TH_Routing_Rules__c();
                nodeTypeIdNull.Id = routingId;
                nodeTypeIdNull.OC_TH_NodeTypeProduct__c ='';
                routingProductList.add(nodeTypeIdNull); 
                mapIdValueToUpdate.putAll(routingProductList);  
            }
            if(mapIdValueToUpdate.size()>0){
                database.update(mapIdValueToUpdate.values());
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_productNodeType,null, false, e));
        }
        return OC_TH_Constants.getSuccess;
    }
    /**************************************************************************************************
* @Description :-This method handles product2 node Component insertion and deletion of field update.
- This method supports extension of multiple product selection functionality(Release,Version)
* @Params      : NodeComponent - pass Product Node Component Name from "associateProductsToRoutingRule" 
method to Insert record
* @Params      : routingId - pass routing rule ID 
* @Return      : return sucess status once Node Component product2 is inserted or Removed.
*******************************************************************************************************/
    public static String productNodeComponent(String routingId,String NodeComponent){
        List<OC_TH_Routing_Rules__c> routingProductList = new List<OC_TH_Routing_Rules__c>();
        Map<Id,OC_TH_Routing_Rules__c> mapIdValueToUpdate = new Map<Id,OC_TH_Routing_Rules__c>();
        try{
            if(String.isNotBlank(NodeComponent)){
                OC_TH_Routing_Rules__c nodeCmpId = new OC_TH_Routing_Rules__c();
                nodeCmpId.Id = routingId;
                nodeCmpId.OC_TH_NodeComponentProduct__c =  NodeComponent;
                routingProductList.add(nodeCmpId); 
                mapIdValueToUpdate.putAll(routingProductList); 
            }
            else{
                OC_TH_Routing_Rules__c nodeCmpIdNull = new OC_TH_Routing_Rules__c();
                nodeCmpIdNull.Id = routingId;
                nodeCmpIdNull.OC_TH_NodeComponentProduct__c ='';
                routingProductList.add(nodeCmpIdNull); 
                mapIdValueToUpdate.putAll(routingProductList); 
            }        
            if(mapIdValueToUpdate.size()>0){
                database.update(mapIdValueToUpdate.values());
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_productNodeComponent,null, false, e));
        }
        return OC_TH_Constants.getSuccess;
    }  
    /**************************************************************************************************
* @Description :- This method handles product2 Solution insertion and deletion of field update.
- This method supports extension of multiple product selection functionality(Release,Version)
* @Params      : Solution - pass Product Solution Name from "associateProductsToRoutingRule" 
method to Insert record
* @Params      : routingId - pass routing rule ID 
* @Return      : return sucess status once Solution product2 is inserted or Removed.
*******************************************************************************************************/
    public static String productSolution(String routingId,String Solution){
        List<OC_TH_Routing_Rules__c> routingProductList = new List<OC_TH_Routing_Rules__c>();
        Map<Id,OC_TH_Routing_Rules__c> mapIdValueToUpdate = new Map<Id,OC_TH_Routing_Rules__c>();
        try{
            if(String.isNotBlank(Solution)){
                OC_TH_Routing_Rules__c solutionId = new OC_TH_Routing_Rules__c();
                solutionId.Id = routingId;
                solutionId.OC_TH_SolutionProduct__c =  Solution;
                routingProductList.add(solutionId); 
                mapIdValueToUpdate.putAll(routingProductList); 
            }       
            else{
                OC_TH_Routing_Rules__c nodeSoluIdNull = new OC_TH_Routing_Rules__c();
                nodeSoluIdNull.Id = routingId;
                nodeSoluIdNull.OC_TH_SolutionProduct__c ='';
                routingProductList.add(nodeSoluIdNull); 
                mapIdValueToUpdate.putAll(routingProductList); 
            }
            if(mapIdValueToUpdate.size()>0){
                database.update(mapIdValueToUpdate.values());
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_AccountProductSelectionHelper,OC_TH_Constants.method_productSolution,null, false, e));
        }
        return OC_TH_Constants.getSuccess;
    }   
}