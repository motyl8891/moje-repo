/******************************************************************* 
* @author: Linda Pavare 
* @date: 2017-11-13 
* @description: This (Queueable Apex)class is used as a helper class for ContractFromOpportunityContractHelper class
when when upserting Contracts. Update is done asynchronously to avoid hitting SF governor limits 

Modification Log:
------------------------------------------------------------------------------------------
Developer                   Date                Description
------------------------------------------------------------------------------------------   
-						-						Original Version
Shubham Jagatap			22-07-2020				U-1903 - Replaced Hard coded values by global constants

********************************************************************/
public without sharing class OpportunityContractsAsyncUpsert implements Queueable{
    
    List<Opportunity> upsertOpps;
    Map<String,OpportunityContractInbound__c> oppIdToOppContractMap;
    List<Contract> parentContractList;
    Map<String,List<Opportunity>> oppContrInbToReferringOpps;
    Map<String,List<OpportunityContractVLE__c>> oppContrInbToVLEsMap;
    
    /****************************************************************
* @author: Linda Pavare
* @date: 2017-11-13
* @param: upsertOpps
* @param: oppIdToOppContractMap
* @param: parentContractList
* @param: oppContrInbToReferringOpps
* @return: none
* @description: This is a constuctor for this class.
*****************************************************************/    
    public OpportunityContractsAsyncUpsert(List<Opportunity>upsertOpps,Map<String,OpportunityContractInbound__c> oppIdToOppContractMap,List<Contract> parentContractList,
                                             Map<String,List<Opportunity>> oppContrInbToReferringOpps, Map<String,List<OpportunityContractVLE__c>> oppContrInbToVLEsMap){
                                                 this.upsertOpps = upsertOpps;
                                                 this.oppIdToOppContractMap = oppIdToOppContractMap;
                                                 this.parentContractList = parentContractList;
                                                 this.oppContrInbToReferringOpps = oppContrInbToReferringOpps; 
                                                 this.oppContrInbToVLEsMap = oppContrInbToVLEsMap;
                                             }
    
    /****************************************************************
* @author: Linda Pavare
* @date: 2017-11-13
* @param: 
* @return: none
* @description: This method handles the main logic of this class. Upserts the Contracts
*****************************************************************/
    public void execute(QueueableContext context) {
        //Map for Parent Contracts for determining if Parent Contract for Contract exists in SF 
        Map<String,Contract> contrExtIdToCotractRecordMap = new Map<String,Contract>();
        for(Contract tmpContr: parentContractList){
            contrExtIdToCotractRecordMap.put(tmpContr.Contract_ID__c, tmpContr);
        }
        //Loop through Parent Opportunities and handle all the logic for Contract upserting and relationship creation between Opportunities(Parent and Referring) and Contract, 
        //and relationship between Contract and Account(VLE/Contract Valid For Legal Entities)
        for(Opportunity o: upsertOpps){
            Savepoint sp = Database.setSavepoint();
            Boolean contractExists = false;
            boolean validParentContract = true;
            Boolean contractUpdatedOrInserted = false;
            Boolean canContinue = false;
            Id contractId;
            Boolean canInsertContract = true; //????
            OpportunityContractInbound__c oppcontr = oppIdToOppContractMap.get(o.OpportunityNumber__c);
            List<Opportunity> referringOpps = oppContrInbToReferringOpps.get(oppcontr.Id);
            //U-1903
            if((oppcontr.External_Id__c != null) && (oppcontr.External_Id__c != GlobalConstants.framelocation)){
                Contract newContract = new Contract(AccountId = o.AccountId, 
                                                    OpportunityID__c = o.Id, ///??????  used Process Bilder: Contract_Active_Counting AND Update_Contract_Current_Opportunity                                            
                                                    Status = oppcontr.Status_Of_Business__c, 
                                                    Contract_Stage__c = oppcontr.Contract_Stage__c,
                                                    Name = oppcontr.Contract_Name__c,
                                                    Contract_Classification__c = oppcontr.Classification__c,
                                                    Contract_ID__c = oppcontr.External_Id__c,
                                                    Description = oppcontr.Contract_Url__c
                                                   );
                //Check if Parent Contract exists in SF								
                //U-1903
                if(((oppcontr.Parent_Contract_Id__c ==null) ||(oppcontr.Parent_Contract_Id__c == GlobalConstants.framelocation)) ||(contrExtIdToCotractRecordMap.containsKey(oppcontr.Parent_Contract_Id__c))){
                    if(contrExtIdToCotractRecordMap.containsKey(oppcontr.Parent_Contract_Id__c)){
                        Contract c = contrExtIdToCotractRecordMap.get(oppcontr.Parent_Contract_Id__c);
                        //if it exists link it to this contract
                        newContract.Parent_Contract__c = c.Id;}}
                        
              //D-1383 removed validation
              /*  else if((oppcontr.Parent_Contract_Id__c !=null)&&(oppcontr.Parent_Contract_Id__c !='')){
                    oppcontr.isError__c = true;
                    oppcontr.Error_Msg__c = 'Given Parent Contract doesn\'t exist in Salesforce';
                    update oppcontr;
                    canInsertContract = false;
                    
                }*/
                //If Contract can be upserted ... TODO comments
                if(canInsertContract){
                    try{
                        contractId = newContract.Id;  
                        Database.UpsertResult upsRes = Database.upsert(newContract,Contract.Fields.Contract_ID__c);
                        contractUpdatedOrInserted = true;
                        contractId = newContract.ID;
                        if(upsRes.isCreated()){
                            contractExists = false;}
                        else{
                            contractExists = true;
                        }
                    }
                    catch(Exception e){
                        oppcontr.isError__c = true;
                        oppcontr.Error_Msg__c = GlobalConstants.UPSERT_CONTRACT_ERROR+e.getMessage();
                        update oppcontr;
                    } 
                }
                if(contractUpdatedOrInserted){
                    List<OpportunityContract__c> relationshipUpsertList = new List<OpportunityContract__c>();
                    String contractUniqueId = oppcontr.External_Id__c;
                    String contrStatus = oppcontr.Status_Of_Business__c;
                    Contract contractReference = new Contract(Contract_ID__c = contractUniqueId);
                    Opportunity oppReference = new Opportunity(OpportunityNumber__c = o.OpportunityNumber__c);
                    OpportunityContract__c parentOppRel = new OpportunityContract__c(Unique_ID__c=o.OpportunityNumber__c+contractUniqueId, Opportunity__r=oppReference, 
                                                                                     Contract__r=contractReference, Contract_Status__c=contrStatus);
                    relationshipUpsertList.add(parentOppRel);
                    //Relate Referring Opportunities
                    for(Opportunity opp: referringOpps){
                        Opportunity refOppReference = new Opportunity(OpportunityNumber__c = opp.OpportunityNumber__c);
                        OpportunityContract__c refOppRel = new OpportunityContract__c(Unique_ID__c=opp.OpportunityNumber__c+contractUniqueId, 
                                                                                      Opportunity__r=refOppReference, Contract__r=contractReference,
                                                                                     Contract_Status__c = contrStatus);
                        relationshipUpsertList.add(refOppRel);
                        //Set Inbound Contract as Parent Contract for Referring Opportunities //is this functionality still needed?
                        opp.Parent_Contract__c = contractId;	
                    }
                    
                    try{
                        upsert relationshipUpsertList Unique_ID__c;
                        canContinue = true;
                    }
                    catch(Exception e){
                        Database.rollback(sp);
                        oppcontr.isError__c = true;
                        //U-1903
                        oppcontr.Error_Msg__c = GlobalConstants.INSERT_CONTRACT_ERROR + e.getMessage();
                        update oppcontr; 
                    }
                    if(canContinue){
                        //Update referring Opportunities with Parent Contract
                        try{
                            update referringOpps;
                            canContinue = true;
                        }
                        catch(Exception e){
                            Database.rollback(sp);
                            oppcontr.isError__c = true;
                            canContinue = false;
                            //U-1903
                            oppcontr.Error_Msg__c = GlobalConstants.UPDATE_REFFERING_OPP_ERROR + e.getMessage();
                            update oppcontr;
                        }
                        
                    }
                }
                //Process VLE's and create Contract Valid For Legal Enities record(s)
                if(canContinue){
                    //get related VLEs for Inbound Contract
                    List<OpportunityContractVLE__c> contractVLEs = oppContrInbToVLEsMap.get(oppcontr.Id);       
                    List<ContractValidForLegalEntity__c> contrValidForLElist = new List<ContractValidForLegalEntity__c>();
                    //if Contract is inserted just create the records
                    if(!contractExists){
                        for(OpportunityContractVLE__c tmp: contractVLEs){
                            
                            if (!String.isBlank(tmp.SoldToParty_Local_Id__c)){
                                ContractValidForLegalEntity__c newContrVLE = new ContractValidForLegalEntity__c(Contract__c = contractId,
                                                                                                                Company_Code__c = tmp.Ericsson_Company_Code__c,
                                                                                                                Status__c = tmp.SoldToParty_Status__c);
                                Account accountreference = new Account(SAP_S2P_ID_Number__c = decimal.valueof(tmp.SoldToParty_Local_Id__c));
                                newContrVLE.Sold_To_Party__r = accountreference; 
                                contrValidForLElist.add(newContrVLE);}
                            else{}
                        }
                        try{
                            upsert contrValidForLElist;
                        }
                        catch(Exception e){
                            Database.rollback(sp);
                            oppcontr.isError__c = true;
                            //U-1903
                            oppcontr.Error_Msg__c = GlobalConstants.INSERTCONTRACTVALID_ERROR + e.getMessage();
                            update oppcontr;
                        }
                    }
                    //else(if Contract already exists) check if there is a record in ContractValidForLegalEntity__c with this contract and account for each VLE
                    // if yes then update if no then create
                    else{
                        //NS
                        /*List<ContractValidForLegalEntity__c> existingContrValidForRec = [SELECT Company_Code__c, Contract__c, Sold_To_Party__r.SAP_S2P_ID_Number__c, Status__c 
                                                                                         FROM ContractValidForLegalEntity__c 
                                                                                         WHERE Contract__c =: contractId];*/
                        List<ContractValidForLegalEntity__c> listForUpsert = new List<ContractValidForLegalEntity__c>();
                        for(OpportunityContractVLE__c tmp: contractVLEs) {
                            if (!String.isBlank(tmp.SoldToParty_Local_Id__c)){
                                Boolean recordNotExists = true;
                                //Unique Identifier for OpportunityContractVLE__c: SoldToParty_Local_Id__c + Ericsson_Company_Code__c
                                String uniqueIdForVLE = tmp.SoldToParty_Local_Id__c + tmp.Ericsson_Company_Code__c;
                                for(ContractValidForLegalEntity__c tmpcvfle:[SELECT Company_Code__c, Contract__c, Sold_To_Party__r.SAP_S2P_ID_Number__c, Status__c 
                                                                            FROM ContractValidForLegalEntity__c 
                                                                            WHERE Contract__c =: contractId] ){
                                    //Unique value for ContractValidForLegalEntity__c: Sold_To_Party__r.SAP_S2P_ID_Number__c + Company_Code__c
                                    String uniqueIdForExistingCVFLE = String.valueOf(tmpcvfle.Sold_To_Party__r.SAP_S2P_ID_Number__c) + String.valueOf(tmpcvfle.Company_Code__c);
                                    if(uniqueIdForVLE == uniqueIdForExistingCVFLE){
                                        //tmpcvfle.Company_Code__c = tmp.Ericsson_Company_Code__c; 
                                        tmpcvfle.Status__c = tmp.SoldToParty_Status__c;
                                        listForUpsert.add(tmpcvfle);
                                        recordNotExists = false;  
                                        break;
                                    }
                                    
                                }
                                if(recordNotExists){
                                    ContractValidForLegalEntity__c newRecord = new ContractValidForLegalEntity__c(Contract__c = contractId,
                                                                                                                  Company_Code__c = tmp.Ericsson_Company_Code__c,
                                                                                                                  Status__c = tmp.SoldToParty_Status__c);
                                    Account accountreference = new Account(SAP_S2P_ID_Number__c = decimal.valueof(tmp.SoldToParty_Local_Id__c));
                                    newRecord.Sold_To_Party__r = accountreference;
                                    listForUpsert.add(newRecord);
                                }  
                            }
                        }
                        try{
                            upsert listForUpsert;
                        }
                        catch(Exception e){
                            Database.rollback(sp);
                            oppcontr.isError__c = true;
                            //U-1903
                            oppcontr.Error_Msg__c = GlobalConstants.UPSERT_CONTRACT_VALID_FOR_LEGAL_ENTITY_ERROR+e.getMessage();
                            update oppcontr;
                        }
                        
                        
                        
                        
                    }
                }
                
                
                
            }
            
            
            
        }
    }
}