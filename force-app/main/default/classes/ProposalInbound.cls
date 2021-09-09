/*******************************************************************************
* @author:  Nikolajs Jurickis
* @date:    2018-03-27
* @description: This is the web-service class for Proposal Inbound integration.
********************************************************************************/
global class ProposalInbound{
    static private String successResponse = GlobalConstants.RESPONSE_SUCCESS_PROPOSAL_INBOUND;
    static private String errorResponse = GlobalConstants.RESPONSE_ERROR_PROPOSAL_INBOUND;
    static private String logNameRequest = GlobalConstants.LOG_NAME_REQUEST_PROPOSAL_INBOUND;
    static private String logNameResponse = GlobalConstants.LOG_NAME_RESPONSE_PROPOSAL_INBOUND;
    static private String logNameError = GlobalConstants.LOG_NAME_ERROR_PROPOSAL_INBOUND;

    global class Proposal{
        webservice String opportunityId;
        webservice String proposalId;
        webservice String proposalName;
        webservice String sdpValue;
        webservice String sdpStatus;
        webservice String pdProposalLink;
        webservice String opportunityCurrency;
        webservice String deliveryStartDate;
        webservice String deliveryEndDate;
        webservice String grossPrice;
        webservice String effectiveNetPrice;
        webservice String effectiveNetPriceIFRS15;
        webservice String umbr;
        webservice String umbrIFRS15;
        webservice String umar;
        webservice String umarIFRS15;
        webservice List<ProposalProduct> proposalProduct;
    }

    global class ProposalProduct{
        webservice String productArea;
        webservice String commodity;
        webservice String effectiveNetPrice;
        webservice String effectiveNetPriceIFRS15;
        webservice String umbr;
        webservice String umbrIFRS15;
        webservice String umar;
        webservice String umarIFRS15;
        
    }

    /****************************************************************
    * @author:  Nikolajs Jurickis
    * @date:    2018-03-27
    * @param:   inbProp 
    * @return   String
    * @description: This method is the main method for this webservice and is using to process inbound proposal requests.
    *****************************************************************/
    webservice static String upsertProposal(Proposal inbProp) { 
        try{
            String uniqueId = GeneralUtils.generateRandomString(30);
            logNameRequest+=GlobalConstants.SPACE+String.valueOf(uniqueId);
            EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal,logNameRequest, false, JSON.serialize(inbProp))));
            if(inbProp.sdpValue == GlobalConstants.SDP2 || inbProp.sdpValue == GlobalConstants.SDP3){ 
                
                // Create the parent opportunity, containing the external ID reference to OpportunityNumber 
                //Opportunity existingSFOpp = new Opportunity(OpportunityNumber__c = inbProp.opportunityId);
                Boolean isSFMasterForOpp = inbProp.opportunityId.substring(0, 2) == '35';
                Opportunity existingSFOpp = null;
                List<Opportunity> existingSFOppList = [SELECT Id, 
                                                              RecordType.Name, 
                                                              Locked_to_PP__c, 
                                                              Managed_Services_Governance__c,
                                                              Estimated_Delivery_Start_Date__c,
                                                              Estimated_Delivery_End_Date__c
                                                        FROM Opportunity 
                                                        WHERE OpportunityNumber__c =:inbProp.opportunityId];
                if(existingSFOppList.size()>0){
                    existingSFOpp = existingSFOppList[0];
                }else if(existingSFOppList.size() == 0 && !isSFMasterForOpp){
                    EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal,logNameResponse, false, successResponse)));            
                    return successResponse;
                }else if(existingSFOppList.size() == 0 && isSFMasterForOpp){
                    EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal,logNameResponse, false, errorResponse+GlobalConstants.SPACE+GlobalConstants.Opportunity_Not_Found_in_Salesforce))); 
                    return errorResponse+ GlobalConstants.SPACE +GlobalConstants.Opportunity_Not_Found_in_Salesforce;
                }

                if(existingSFOpp.Locked_to_PP__c){
                    EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal, logNameResponse, false, errorResponse + GlobalConstants.SPACE + GlobalConstants.Opportunity_Locked_to_PP)));
                    return errorResponse + GlobalConstants.SPACE + GlobalConstants.Opportunity_Locked_to_PP;
                }

                // Create the proposal, which populates the master-detail relationship
                // to Opportunity with the external ID reference to Opportunity Number
                Proposal__c proposal = new Proposal__c(Opportunity__c = existingSFOpp.Id);
                
                // Generate Proposal Unique ID using concatenation of Opportunity Number and SDP Value
                proposal.Proposal_Unique_Id__c = inbProp.opportunityId+GlobalConstants.UNDERSCORE+inbProp.sdpValue;
                
                // Populate other proposal fields
                if(inbProp.proposalName != null && inbProp.proposalName.length() > 80){inbProp.proposalName = inbProp.proposalName.subString(0,80);}
                Id recordTypeId_pd = GlobalConstants.recordTypeId_pd1;
                proposal.RecordTypeId = recordTypeId_pd;
                proposal.UMBR__c = Decimal.valueOf(inbProp.umbr);
                proposal.UMAR__c = Decimal.valueOf(inbProp.umar);
                proposal.SDP_Value__c = inbProp.sdpValue;
                proposal.SDP_Status__c = inbProp.sdpStatus;
                proposal.Proposal_Id__c = inbProp.proposalId; 
                proposal.Name = inbProp.proposalName;
                proposal.PD_Proposal_Link__c = inbProp.pdProposalLink;
                proposal.Gross_Price__c = Decimal.valueOf(inbProp.grossPrice);
                proposal.Effective_Net_Price__c = Decimal.valueOf(inbProp.effectiveNetPrice);
                if((existingSFOpp.Managed_Services_Governance__c == true) && (inbProp.proposalProduct == null)){                    
                    proposal.Delivery_Start_Date__c = null;
                    proposal.Delivery_End_Date__c = null;
                }else{
                proposal.Delivery_Start_Date__c = Date.valueOf(inbProp.deliveryStartDate);
                proposal.Delivery_End_Date__c = Date.valueOf(inbProp.deliveryEndDate);
                existingSFOpp.Estimated_Delivery_Start_Date__c = Date.valueOf(inbProp.deliveryStartDate);
                existingSFOpp.Estimated_Delivery_End_Date__c = Date.valueOf(inbProp.deliveryEndDate);                
                }
                proposal.CurrencyIsoCode = inbProp.opportunityCurrency;

                //Process products only if proposal opportunity is not Managed_Services_Governance__c or if it is in Managed Services Governance, 
                //only if products are existing in the message
                Boolean needToHandleProducts = false;
                // creating but not inserting the new list of products from inbound proposal message
                List<Product__c> pProdList = new List<Product__c>();
                if(existingSFOpp.Managed_Services_Governance__c == false || (existingSFOpp.Managed_Services_Governance__c == true && inbProp.proposalProduct != null)){ 
                    needToHandleProducts = true;
                
                //get correct record type Id and assign to the Product
                Id productRecordTypeId = GlobalConstants.productRecordTypeId1;
                
				//Boolean hasFinancialComplianceProductAreas = false;
                for(ProposalProduct pp: inbProp.proposalProduct){
                    Product__c product = new Product__c();
                    product.RecordTypeId = productRecordTypeId;
                    product.Name = pp.productArea;
                    product.UMBR__c = Decimal.valueOf(pp.umbr);
                    product.UMAR__c = Decimal.valueOf(pp.umar);
                    product.Commodity__c = pp.commodity;
                    product.Commodity_Value__c = Decimal.valueOf(pp.effectiveNetPrice);
                    product.CurrencyIsoCode = inbProp.opportunityCurrency; 
                    //adding products to list but not inserting yet
                    pProdList.add(product);

                   /* if(GlobalConstants.FINANC_COMPL_PROD_AREAS_SET.contains(pp.productArea)){
                        hasFinancialComplianceProductAreas = true;
                    }*/
                }
				/*if(hasFinancialComplianceProductAreas){
					existingSFOpp.Financial_Compliance_Product_Areas__c = true;
				}
				else{
					existingSFOpp.Financial_Compliance_Product_Areas__c = false;
				}*/

                //calculating proposal margins based on newly received products
                proposal = PDMarginsCalculation.calculateProposalPdMargins(proposal, pProdList);

            }
                upsert proposal Proposal_Unique_Id__c;

                if(needToHandleProducts){
                // If proposal already existed, delete any previous products associated to the proposal
                List<Product__c> prodDeleteList = [SELECT Id FROM Product__c WHERE Proposal__c =: proposal.Id];
                if(prodDeleteList.size() > 0){
                    delete prodDeleteList;
                }

                //updating list of new products with Proposal__c id
                for(Product__c ppc: pProdList){
                    ppc.Proposal__c = proposal.Id;
                }

                insert pProdList;
            }

                if(!existingSFOpp.Locked_to_PP__c){
                    if(GlobalConstants.FRAME_OPP_REC_TYPES_PP_SET.contains(existingSFOpp.RecordType.Name)){
                        Id recordTypeId = GlobalConstants.frameOppRecordTypeId;
                        existingSFOpp.RecordTypeId = recordTypeId;
                    }else if(GlobalConstants.STANDARD_OPP_REC_TYPES_PP_SET.contains(existingSFOpp.RecordType.Name)){
                        Id recordTypeId = GlobalConstants.recordTypeId_PD;
                        existingSFOpp.RecordTypeId = recordTypeId;
                    }
                }


                update existingSFOpp;
            }
            logNameResponse+= GlobalConstants.SPACE +String.valueOf(uniqueId);
            EventLog.createLogFuture(Json.serialize(new EventLog.Information(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal,logNameResponse, false, successResponse)));            
            return successResponse;            
        } catch(Exception e){         
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalInbound, GlobalConstants.upsertProposal,logNameError, true, e)));
            return errorResponse+GlobalConstants.SPACE+e.getMessage();           
        }
    }
}