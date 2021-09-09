/****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description:
*****************************************************************/
public without sharing class ProposalUtils {
 	
    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description: 
*****************************************************************/
    public static Map<Proposal__c, List<Product__c>> createVersionZero(String oppId) { 
        try {
            List<Opportunity> oppWithProdsList = [SELECT Id, OpportunityNumber__c, Estimated_Delivery_Start_Date__c, Estimated_Delivery_End_Date__c, Legacy_Estimated_Deal_Value__c,
                                                  (Select Id, Product_Code_Number__c, Commodity__c, Business_Area__c,
                                                   Product_Area__c, Estimated_Margin__c, UnitPrice, Unadjusted_Margin_After_Risk__c
                                                   FROM OpportunityLineItems)
                                                  FROM Opportunity
                                                  WHERE Id = : oppId];

            if (oppWithProdsList.size() == 0 || oppWithProdsList[0].OpportunityLineItems.size() == 0) {
                return null; 
            }

            String ppRecordTypeID = GlobalConstants.ppRecordTypeID1;
            Proposal__c prop = new Proposal__c(Proposal_Id__c = oppWithProdsList[0].OpportunityNumber__c + GlobalConstants.V0,
                                               Proposal_Unique_Id__c = oppWithProdsList[0].OpportunityNumber__c + GlobalConstants.V0,
                                               Version__c = GlobalConstants.ZERO_STRING,
                                               RecordTypeId = ppRecordTypeID,
                                               Opportunity__c = oppWithProdsList[0].Id,
                                               Delivery_Start_Date__c = oppWithProdsList[0].Estimated_Delivery_Start_Date__c,
                                               Delivery_End_Date__c = oppWithProdsList[0].Estimated_Delivery_End_Date__c,
                                               Effective_Net_Price__c = oppWithProdsList[0].Legacy_Estimated_Deal_Value__c);
            Database.insert(prop);

            Decimal umarSum = 0;
            List<Product__c> prodcList = new List<Product__c>();
            for (OpportunityLineItem oppLine : oppWithProdsList[0].OpportunityLineItems) {
                prodcList.add(new Product__c(
                                  UMAR__c = oppLine.Unadjusted_Margin_After_Risk__c,
                                  //UMAR_Percent__c = oppLine.Estimated_Margin__c,
                                  Commodity_Value__c = oppLine.UnitPrice,
                                  Product_Code__c = oppLine.Product_Code_Number__c,
                                  Name = oppLine.Product_Area__c,
                                  Commodity__c = oppLine.Commodity__c,
                                  Business_Area__c = oppLine.Business_Area__c,
                                  Proposal__c = prop.Id
                              ));
                if(oppLine.Unadjusted_Margin_After_Risk__c != null){ umarSum+=oppLine.Unadjusted_Margin_After_Risk__c; }
            }
            Database.insert(prodcList);

            prop.UMAR__c = umarSum;
            Database.update(prop);

            Map<Proposal__c, List<Product__c>> propProdcMap = new Map<Proposal__c, List<Product__c>>();
            propProdcMap.put(prop, prodcList);

            return propProdcMap;
        } catch (DmlException de) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalUtils, GlobalConstants.createVersionZero, GlobalConstants.ProposalUtils_createVersionZero, true, de)));
            throw de;
        }
    }

    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description: private because it is planned to be launched through helper method with pre-query
*****************************************************************/
    public static Boolean replaceProducts(List<Proposal__c> propList) {
        try {
            //putting all the proposals into map with Proposal Id - Opportunity Id
            Map<String, String> propOppMap = new Map<String, String>();
            for (Proposal__c prop : propList) {
                propOppMap.put(prop.Id, prop.Opportunity__c);
            }
            //querying for Opp Line Items to be deleted (they will be replaced)
            List<OpportunityLineItem> oppProdsToDeleteList = [SELECT Id
                                      FROM OpportunityLineItem
                                      WHERE OpportunityId IN: propOppMap.values()];
            //D-1669 - Update to bypass validation rules no delete
            List<OpportunityLineItem> updateBeforeDelete = new List<OpportunityLineItem>();
            for(OpportunityLineItem oppItem : oppProdsToDeleteList){
                oppItem.bypass_deletion_validation__c = true;
                updateBeforeDelete.add(oppItem);
            }
            Database.update(updateBeforeDelete);

            //creating set will all the product codes from Product__c records to find all related product2 records
            Set<String> prodCodeSet = new Set<String>();
            for (Proposal__c prop : propList) {
                for (Product__c prodc : prop.Product__r) {
                    prodCodeSet.add(prodc.Product_Code__c);
                }
            }

            
            //querying for all Product2 records using Product Codes we have found on Product__c records.
            //Putting into map Product2 ProductCode - Product2Id
            Map<String, String> prodCodeProdIdMap = new Map<String, String>();
//NS
            for (Product2 prod2 : [SELECT Id, Name, Product_Code_Number__c FROM Product2 WHERE Product_Code_Number__c IN:prodCodeSet]) {
                //prodCodeProdIdMap.put(prod2.Name, prod2.Id);
                prodCodeProdIdMap.put(prod2.Product_Code_Number__c, prod2.Id);
            }


            //using prodCodeProdIdMap searching for all the related PriceBookEntries
            //putting all the found PriceBookEntries into the map with key:CurrencyCode;PriceBook2Id;Product2Id and value PriceBookEntryId
            Map<String, String> prodCurPBIdToPBEIdMap = new Map<String, String>();
//NS
            for (PriceBookEntry pbe :  [SELECT Id, CurrencyIsoCode, Pricebook2Id, Product2Id
                                        FROM PriceBookEntry
                                        WHERE Product2Id IN: prodCodeProdIdMap.values()]) {
                prodCurPBIdToPBEIdMap.put(pbe.CurrencyIsoCode + GlobalConstants.SEMICOLON + pbe.Pricebook2Id + GlobalConstants.SEMICOLON + pbe.Product2Id, pbe.Id);
            }

            //creating OpportunityLineItems records
            List<OpportunityLineItem> oppProdsToInsertList = new List<OpportunityLineItem>();
            for (Proposal__c prop : propList) {
                for (Product__c prodc : prop.Product__r) {
                    //checking if Product2Id is exist in our map prodCodeProdIdMap using Product__c Product Code
                    String product2Id = GlobalConstants.BLANK;
                    if (prodCodeProdIdMap.containsKey(prodc.Product_Code__c)) {
                        product2Id = prodCodeProdIdMap.get(prodc.Product_Code__c);
                    } else {
                        throw new UtilException(GlobalConstants.Custom_Exception_Prodcode + prodc.Product_Code__c);
                    }

                    //getting Price Book Entry Id using our key(CurrencyCode;PriceBook2Id;Product2Id)
                    String pbeId = GlobalConstants.BLANK;
                    if (prodCurPBIdToPBEIdMap.containsKey(prop.Opportunity__r.CurrencyIsoCode + GlobalConstants.SEMICOLON + prop.Opportunity__r.Pricebook2Id + GlobalConstants.SEMICOLON + product2Id)) {
                        pbeId = prodCurPBIdToPBEIdMap.get(prop.Opportunity__r.CurrencyIsoCode + GlobalConstants.SEMICOLON + prop.Opportunity__r.Pricebook2Id + GlobalConstants.SEMICOLON + product2Id);
                    } else {
                        throw new UtilException( GlobalConstants.Custom_Exception + prop.Opportunity__r.CurrencyIsoCode + GlobalConstants.SEMICOLON + prop.Opportunity__r.Pricebook2Id + GlobalConstants.SEMICOLON + product2Id);
                    }

                    //creating new object record
                    oppProdsToInsertList.add(new OpportunityLineItem(
                        						Bypass_Validation_Rules__c = TRUE,
                                                 Business_Area__c = prodc.Business_Area__c,
                                                 Commodity__c = prodc.Commodity__c,
                                                 Product_Area__c = prodc.Name,
                                                 Estimated_Margin__c = prodc.UMAR_Percent__c,
                                                 UnitPrice = prodc.Commodity_Value__c,
                                                 Product2Id =  product2Id,
                                                 OpportunityId = propOppMap.get(prodc.Proposal__c),
                                                 PricebookEntryId = pbeId
                                             ));
                }
            }

            

            //DML
            Database.delete(oppProdsToDeleteList);
            Database.insert(oppProdsToInsertList);

            return true;

        } catch (DmlException de) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalUtils, GlobalConstants.replaceProducts, GlobalConstants.ProposalUtils_replaceProducts, true, de)));
            throw de;
        } catch (NullPointerException ne) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalUtils, GlobalConstants.replaceProducts, GlobalConstants.ProposalUtils_replaceProducts, true, ne)));
            throw ne;
        } catch (UtilException ue) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.ProposalUtils, GlobalConstants.replaceProducts, GlobalConstants.ProposalUtils_replaceProducts, true, ue)));
            throw ue;
        }
    }

    /****************************************************************
* @author: 
* @date: 
* @User Story: 
* @description: 
*****************************************************************/
    public static Boolean replaceProducts_queryProductsFirst(List<Proposal__c> propList) {
        //putting all the Proposal ids into set for query
        Set<String> propIdsSet = new Set<String>();
        for (Proposal__c prop : propList) {
            propIdsSet.add(prop.Id);
        }
        //querying Proposals with all the details we need
        Boolean result = false;
        if(!propIdsSet.isEmpty()){
            List<Proposal__c> propQueryList = [SELECT Id, Opportunity__c, Opportunity__r.Pricebook2Id, Opportunity__r.CurrencyIsoCode,
                                               (Select Id, Name, Business_Area__c, UMAR__c,
                                                Commodity__c, Commodity_Value__c, Product_Code__c,
                                                Product_Description__c, Product_Family__c,
                                                Proposal__c, UMAR_Percent__c, UMBR__c
                                                From Product__r)
                                               FROM Proposal__c WHERE Id IN:propIdsSet];    
            
            if (propQueryList.size() > 0) {
                //starting main method with all the query results we had found
                result = replaceProducts(propQueryList);
            }
        }
        return result;
    }
}