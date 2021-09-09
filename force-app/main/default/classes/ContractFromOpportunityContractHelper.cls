/******************************************************************* 
* @author: Linda Pavare 
* @date: 2017-11-08 
* @description: This is a helper class for OpportunityContractInboundTrigger
********************************************************************/
public with sharing class ContractFromOpportunityContractHelper {
 
    /****************************************************************
* @author: Linda Pavare
* @date: 2017-11-08
* @param: newValues
* @param: oldvalues
* @return: none
* @description: This method will update or create Contracts for Opportunities 
                from Opportunity Contract Inbound records
*****************************************************************/   
    public static void updateCreateContractFromOppContract(Map<Id,OpportunityContractInbound__c> newValues, Map<Id,OpportunityContractInbound__c> oldvalues){
        Try{
        Set<Id> ocIdsSet = new Set<Id>(); //Set for Opportunity Contract Ids, used later for Map creation 
        List<OpportunityContractInbound__c> ocList = newValues.values();
        List<OpportunityContractInbound__c> oppContractList = new List<OpportunityContractInbound__c>();
        Boolean needtolaunch = false;
        
        //goes through the list of all Opportunity Contract records that fired the trigger, checks if specified criteria are met(isProcessed field's value is changed from unchecked to checked)
        //if true, then adds the record to a list for further processing
        for(OpportunityContractInbound__c oc: ocList){
            OpportunityContractInbound__c oldoc = oldvalues.get(oc.Id);           
            if(oc.isProcessed__c == true &&(oldoc.isProcessed__c != oc.isProcessed__c))
            {           
                oppContractList.add(oc);
                ocIdsSet.add(oc.Id);
            }            
        }
        
        if(oppContractList.size()>0) {needtolaunch=true;}
        //Opportunity Contract Inbound conversion to Contract object           
        //for now it is assumed that Opportunity Contract Inbound field Parent_Opportunity_Id__c stores Opportunity Id(length: 18) to which Contract is related to
        if(needtolaunch){
            
            Map<String,List<Opportunity>> oppContrInbToReferringOpps = new Map<String,List<Opportunity>>();
            //1. check if Opportunity Id(Parent_Opportunity_Id__c value) is a valid Id
            //if yes: add this id to List(used in step 2), also map Opportunity Id(Parent_Opportunity_Id__c) with Opportunity Contract Inbound record
            //if not: add Error message
            //2. go through this List and get Opportunity Contract Inbound from Map by Opportunity Id
            //then check if this Opportunity's related list contains this Contract Id. If yes, update, if not, insert
            
            List<String> validOppIdsList = new List<String>();
            List<OpportunityContractInbound__c> validOcRecords = new List<OpportunityContractInbound__c>();            
            Map<String,OpportunityContractInbound__c> oppIdToOppContractMap = new Map<String,OpportunityContractInbound__c>();
            
            Map<String,List<OpportunityContractVLE__c>> oppContrInbToVLEsMap = new Map<String,List<OpportunityContractVLE__c>>();
            //query for VLEs information
            //NS
            /*List<OpportunityContractInbound__c> oppContractsListWithVLEs = [SELECT Id, 
                                                                              Agreement_Stage__c,
                                                                              isProcessed__c,
                                                                              Error_Msg__c,
                                                                              External_Id__c,
                                                                              isError__c,
                                                                              Parent_Opportunity_Id__c,
                                                                              Classification__c,
                                                                              Status_Of_Business__c,
                                                                              Contract_Stage__c,
                                                                              Contract_Name__c,
                                                                              Contract_Url__c,
                                                                              Referring_Opportunity_Ids__c,
                                                                              Parent_Contract_Id__c,
                                                                              (SELECT SoldToParty_Local_Id__c,Ericsson_Company_Code__c,SoldToParty_Status__c
                                                                    FROM Opportunity_Contract_VLEs__r) FROM OpportunityContractInbound__c WHERE Id IN : ocIdsSet];*/
            
            
            //get all VLE SoldToParty_Local_Id__c values in one Set and then use it to search if such Accounts with external Id(SAP_S2P_ID_Number__c) exists in SF
            Set<Decimal> vleAccountExtIdValues = new Set<Decimal>();
            for(OpportunityContractInbound__c tmpocinb: [SELECT Id, Agreement_Stage__c, isProcessed__c, Error_Msg__c,External_Id__c, isError__c,
                                                        Parent_Opportunity_Id__c, Classification__c, Status_Of_Business__c, Contract_Stage__c,
                                                        Contract_Name__c, Contract_Url__c, Referring_Opportunity_Ids__c, Parent_Contract_Id__c,
                                                        (SELECT SoldToParty_Local_Id__c,Ericsson_Company_Code__c,SoldToParty_Status__c
                                                        FROM Opportunity_Contract_VLEs__r) 
                                                        FROM OpportunityContractInbound__c WHERE Id IN : ocIdsSet]){
                for(OpportunityContractVLE__c tmpVLE: tmpocinb.Opportunity_Contract_VLEs__r){
                    if(!String.isBlank(tmpVLE.SoldToParty_Local_Id__c)){
                        vleAccountExtIdValues.add(decimal.valueof(tmpVLE.SoldToParty_Local_Id__c));}
                }
                oppContrInbToVLEsMap.put(tmpocinb.Id,tmpocinb.Opportunity_Contract_VLEs__r);
            }
            //get all existing Accounts whose External Ids(SAP_S2P_ID_Number__c) are in the previously created Set for VLE SoldToParty_Local_Id__c values
            List<Account> existingAccounts = AccountUtils.getAccountInfoBySAPid(vleAccountExtIdValues);
            //put existing Accounts SAP_S2P_ID_Number__c values in a set (later used for checking if prvided SoldToParty_Local_Id__c exists in SF)
            Set<Decimal> existingS2PExtIds = new Set<Decimal>();
            for(Account tmpAccnt: existingAccounts){
                existingS2PExtIds.add(tmpAccnt.SAP_S2P_ID_Number__c);
            }
            
            for(OpportunityContractInbound__c oc: oppContractList){
                String refOppIds = '';
                list<Opportunity> referringOpportunities = new List<Opportunity>();
                List<String> refOppIdsList = new List<String>();
                if(oc.Referring_Opportunity_Ids__c != null && !string.isBlank(oc.Referring_Opportunity_Ids__c)){
                    refOppIds = oc.Referring_Opportunity_Ids__c;
                    refOppIdsList = refOppIds.split(' ');
                    Set<String> findOppsSet = new Set<String>();
                    for(String s:refOppIdsList){
                        findOppsSet.add(s);
                    }
                    referringOpportunities = OpportunityUtils.getOpportunityByOppNumberInfo(findOppsSet);}
                //1.
                Boolean validIds = true;
                
                 if ((oc.Parent_Opportunity_Id__c == null) || (string.isBlank(oc.Parent_Opportunity_Id__c)))
                {
                    oc.Error_Msg__c = 'Parent Opportunity Id is empty';
                    oc.isError__c = true;
                    validIds = false;
                }
               
                else if( (oc.External_Id__c== null) || (string.isBlank(oc.External_Id__c)))
                {
                    oc.Error_Msg__c = 'Given Contract Id is empty';
                    oc.isError__c = true;
                    validIds = false; 
                }
                //check if Reffering Opportunity Ids are valid
               /* else{
                    Set<String> refOppNumSet = new Set<String>();
                    for(Opportunity opport: referringOpportunities){
                        refOppNumSet.add(opport.OpportunityNumber__c);
                    }
                    String nonExistingReferringOpps = '';
                    for(String str: refOppIdsList){
                        if(!refOppNumSet.contains(str)){
                        
                    		nonExistingReferringOpps +=+' '+ str;
                        }
                    }
                    if(!String.isBlank(nonExistingReferringOpps)){
                        oc.Error_Msg__c = 'One or more Reffering Opportunities doesn\'t exist in Salesforce:'+nonExistingReferringOpps;
                    	oc.isError__c = true;
                    	validIds = false; 
                    } 
                } */
                
                 if(validIds){
                        String errorMessage = '';
                        Boolean isErr = false;
                        //check if related lists' SoldToParty_Local_Id__c values exists if not then write an Error
                        //get related list from the map
                        List<OpportunityContractVLE__c> vlesList = oppContrInbToVLEsMap.get(oc.Id);
                        for(OpportunityContractVLE__c checkVLE: vlesList){
                            if(!String.isBlank(checkVLE.SoldToParty_Local_Id__c)){
                            if(!existingS2PExtIds.contains(decimal.valueof(checkVLE.SoldToParty_Local_Id__c))){
                                errorMessage += 'Account with SAP S2P ID(SoldToParty Local Id): '+checkVLE.SoldToParty_Local_Id__c+ ' doesn\'t exist in SF. See the related Opportunity Contract VLE record: '+ GlobalConstants.ORGANIZATION_URL + checkVLE.Id;
                                isErr = true;
                            }
                            }
                        }
                        if(isErr){
                           oc.Error_Msg__c = errorMessage;
                    		oc.isError__c = true;
                    		validIds = false; 
                        }
                    }
                //
                if(validIds){
                    validOppIdsList.add(oc.Parent_Opportunity_Id__c);
                    validOcRecords.add(oc);
                    //Map OpportinityId(Parent_Opportunity_Id__c) with Opportunity Contract Inbound
                    oppIdToOppContractMap.put(oc.Parent_Opportunity_Id__c,oc);
                    //Map Opportunity Contract Inbound to Referring Opportunities list
                     oppContrInbToReferringOpps.put(oc.Id,referringOpportunities);
                }                
            }
            
            //2.
            List<Opportunity> existingOppWithContracts = OpportunityUtils.getOpportunitiesWithContractsByOppNum(validOppIdsList);
            
            //create a set with existing Opportunies Ids
            Set<String> existingOppIds = new Set<String>();
            for(Opportunity tmpOpp: existingOppWithContracts){
                existingOppIds.add(tmpOpp.OpportunityNumber__c);
            }
            
            //create a list for Parent Contract Ids
            List<String> parentContractIds = new List<String>();
            //find the Opportunity Contract Inbound records with (valid)Opportunity Ids which are not found in the SF and write an Error message
            for(OpportunityContractInbound__c tmpOC:validOcRecords){
                boolean addToContrIds = true;
                if(!existingOppIds.contains(tmpOC.Parent_Opportunity_Id__c)){
                    tmpOC.isError__c = true;
                    tmpOC.Error_Msg__c = 'Provided Opportunity Id(Parent Opportunity Id) doesn\'t exist in SF';
                    addToContrIds = false;
                }
                if(addToContrIds){
                    if(tmpOC.Parent_Contract_Id__c!=null && !string.isBlank(tmpOC.Parent_Contract_Id__c)){
                        parentContractIds.add(tmpOC.Parent_Contract_Id__c);} 
                }
            }
            
            //Contracts list which contains all the Contracts which are Parent Contracts for valid Opportunity Contract Inbound records
            List<Contract> parentContractList = GeneralUtils.getContractInfoByExternalID(parentContractIds);
            
            Integer currentcount = 0;
            Integer listSize = existingOppWithContracts.size();
            Integer transactionLimit = 50;
            
            while(currentcount<listsize){
                List<Opportunity> forAsycUpdate = new List<Opportunity>();
                for(Integer i=0;i<transactionLimit;i++){
                    if(currentcount<listsize){
                        forAsycUpdate.add(existingOppWithContracts[currentcount]);
                        currentcount++;
                    }
                    else{break;}
                }
                OpportunityContractsAsyncUpsert updateJob = new OpportunityContractsAsyncUpsert(forAsycUpdate,oppIdToOppContractMap,parentContractList,oppContrInbToReferringOpps,oppContrInbToVLEsMap);
                
                ID jobID = System.enqueueJob(updateJob);
            }
        }
            }catch(Exception e){	}
    }       
}