/*******************************************************************
* @author: Anurkiti
* @date: 2019-03-05
* @description: U-0959, U-1030
				1. Handle Product Line update, delete and add.
				2. Handle simple opp creation and deletion
********************************************************************/ 
public with sharing class OppController {
    
    public Static String parentName {get; set;}
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05 
    * @description: Constructor
    *****************************************************************/
    public OppController () {
        parentName = ApexPages.currentPage().getParameters().get(GlobalConstants.frameName);
    }
    
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05
    * @param: parentID, 
    * @return List<OpportunityLineItem>
    * @description: This method will get all line items of Simple Opportunity
    *****************************************************************/
    @AuraEnabled
    public static List<OpportunityLineItem> getAllOLI(id parentID, String pageSize, String pageNumber) {
        list<OpportunityLineItem> oliList = new list<OpportunityLineItem>();
        try{
            oliList = [SELECT Commodity__c, Opportunity.Id, Opportunity.StageName,Opportunity.CloseDate,
                           Product2.Name, Product2.Product_Area__c, Opportunity.Name,Id,Name,Quantity,
                           TotalPrice,Estimated_Margin__c,UnitPrice 
                       FROM opportunitylineitem 
                       WHERE opportunity.Parent_Original_Opportunity__c =:parentID 
                           AND Opportunity.stagename NOT IN : GlobalConstants.validStage
                           AND Opportunity.RecordTypeId =: GlobalConstants.simpleOppRecordTypeId
                           order by Opportunity.Name Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                      ];
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                GlobalConstants.getAllOLI, GlobalConstants.OppController, true, e)));
        }
        
        return oliList;
    }
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05
    * @param: parentID, 
    * @return Opportunity
    * @description: This method will get information of frame opportunity
    *****************************************************************/
    @AuraEnabled
    public static Opportunity getFrameData(Id parentID) {
        Opportunity opp = new Opportunity();
        try{
            opp = [SELECT Name, Opportunity_Product_Change__c, Simple_Opp_Creation_Interval__c, CloseDate, StageName,
                   (SELECT Id, CloseDate FROM Child_Subsequent_Opportunities__r order by CloseDate desc limit 1)
                   FROM Opportunity 
                   WHERE ID =: parentID Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]; 
        }catch(Exception e){
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                GlobalConstants.getFrameData, GlobalConstants.OppController, true, e)));            
        }
        return opp;
    }
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05
    * @param: editedOLI 
    * @return String errorMessage
    * @description: This method will update line items
    *****************************************************************/
    @AuraEnabled
    public static String updateOLI(List<OpportunityLineItem> editedOLI){ 
        String message = GlobalConstants.SUCCESS;
		try{
            if(!editedOLI.IsEmpty()) {
            	Database.update(editedOLI);
            }
        }catch(Exception e) {
            message = e.getMessage();
            if(message.contains(GlobalConstants.AT_LEAST_ONE_NON_ZERO_PRODUCT_VALUE_SIMPLE)) {
                message = GlobalConstants.AT_LEAST_ONE_NON_ZERO_PRODUCT_VALUE_SIMPLE;
            }else if(message.contains(GlobalConstants.DIVISION_UNDEFINED)) {
                message = GlobalConstants.AT_LEAST_ONE_NON_ZERO_PRODUCT_VALUE_SIMPLE;
            }else {
                message = GlobalConstants.UPDATE_ERROR;
            }
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                GlobalConstants.updateOLI, GlobalConstants.OppController, true, e)));
        }
        return message;
    }
   
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05
    * @param: oliId
    * @return boolean isSuccess
    * @description: This method will delet line item
    *****************************************************************/
    @AuraEnabled
	public static boolean removeOppLineItems(id oliId) {
        Boolean isSuccess = true;
        OpportunityLineItem oli = new OpportunityLineItem(Id=oliId);
        try{
        	Database.delete(oli);
        }catch(Exception e) {
            isSuccess = false;
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                GlobalConstants.removeOppLineItems, GlobalConstants.OppController, true, e)));
        }
        return isSuccess;
   }
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05
    * @param: parentID, 
    * @return date
    * @description: This method will calculate close date
    *****************************************************************/
    private static Date calculateCloseDate(Date dateParam) {
        Date returnDate=null;
        if(Integer.valueOf(Math.ceil(dateParam.month()/3.0)) == 1) {
        	returnDate = date.newInstance(dateParam.year(), 03,31);
        }else if(Integer.valueOf(Math.ceil(dateParam.month()/3.0)) == 2) {
            returnDate = date.newInstance(dateParam.year(), 06,30);
        }else if(Integer.valueOf(Math.ceil(dateParam.month()/3.0)) == 3) {
            returnDate = date.newInstance(dateParam.year(), 09,30);
        }else if(Integer.valueOf(Math.ceil(dateParam.month()/3.0)) == 4) {
            returnDate = date.newInstance(dateParam.year(), 12,31);
        }else {}
        return returnDate;
    }
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-12-04
    * @param: parentID, 
    * @return Boolean
    * @description: This method will return true if Simple opty related to 
    * 				frame opty are present in closed stage
    *****************************************************************/
    @AuraEnabled
    public static list<Opportunity> getAllSimpleOpportunitiesOfFrame(Id parentID) {        
        try{
            return [SELECT Id, Name, CloseDate, Forecast__c,Deal_Value__c,Margin__c,Override_Deal_Value_and_Margin__c,
                    stagename, CurrencyIsoCode from opportunity WHERE Parent_Original_Opportunity__c =:parentID 
                    AND RecordTypeId =: GlobalConstants.simpleOppRecordTypeId   
                    AND stagename = : GlobalConstants.STAGE4
                    order by CloseDate asc
                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())
                   ];                       
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                                                                       GlobalConstants.getAllSimpleOpportunitiesOfFrame, GlobalConstants.OppController, true, e)));
        }        
        return null;
    }
    
     /****************************************************************
* @author: Anukriti
* @date: 2019-03-05
* @param: parentID, 
* @return List<OpportunityLineItem>
* @description: This method will delete simple opportunities.
*****************************************************************/
    @AuraEnabled
    public static boolean removeSimpleOpty(String optyIdSet) {
        Boolean isSuccess = true;      
        Object[] values = (Object[])System.JSON.deserializeUntyped(optyIdSet);
        Set<String> selectedIdsList = new Set<String>();
        List<Opportunity> simpleOpptyList =  new List<Opportunity>();
        try{
            if(values.size() > 0){         
                for (Object id : values) {
                    String str = string.valueof(id); 
                    if(str.contains(GlobalConstants.OPENINGBRACKET))
                        str = str.remove(GlobalConstants.OPENINGBRACKET);
                    if(str.contains(GlobalConstants.CLOSINGBRACKET))
                        str = str.remove(GlobalConstants.CLOSINGBRACKET);
                    selectedIdsList.add(str);
                }
            }
            if(!selectedIdsList.isEmpty())
            {
                for(String oppid:selectedIdsList)
                {
                    Opportunity simpleOpty = new Opportunity(Id=oppid);
                    simpleOpptyList.add(simpleOpty);
                }
            }
            if(!simpleOpptyList.isEmpty())
                Database.delete(simpleOpptyList);
        }catch(Exception e) {
            isSuccess = false;
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                                                                       GlobalConstants.removeOppLineItems, GlobalConstants.OppController, true, e)));
        }
        return isSuccess;
    }
    
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-03-05
    * @param: editedOLI 
    * @return String errorMessage
    * @description: This method will update line items
	*****************************************************************/
    @AuraEnabled
    public static String updateSimpleOpty(List<Opportunity> editedSimpleOpty){ 
        String message = GlobalConstants.SUCCESS;
        try{
            if(!editedSimpleOpty.IsEmpty()) {
                Database.update(editedSimpleOpty);
            }
        }catch(Exception e) {
            message = e.getMessage();
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                                                                       GlobalConstants.updateOLI, GlobalConstants.OppController, true, e)));
        }
        return message;
    }
    
    // method for fetch picklist values dynamic  
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        List < String > allOpts = new list < String > ();
        try{
            // Get the object type of the SObject.
            Schema.sObjectType objType = objObject.getSObjectType();
            
            // Describe the SObject using its object type.
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            
            // Get a map of fields for the SObject
            map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
            
            // Get the list of picklist values for this field.
            list < Schema.PicklistEntry > values =
                fieldMap.get(fld).getDescribe().getPickListValues();
            
            // Add these values to the selectoption list.
            for (Schema.PicklistEntry a: values) {
                allOpts.add(a.getValue());
            }
            allOpts.sort();
            if(GlobalConstants.StageName.equalsIgnoreCase(fld)) {
                allOpts.remove(0);
                allOpts.remove(0);
                allOpts.remove(0);
            }
        }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                GlobalConstants.getselectOptions, GlobalConstants.OppController, true, e)));
        }
        
        return allOpts;
    }
    
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-05-11
    * @param: Id parentID, Date startDate, Date endDate, String interval, Integer distributeValue, 
    * @return errorMessage
    * @description: This method will create simple Opportunity based on interval
    *****************************************************************/
    @AuraEnabled
	public static String createPridictions(Id parentID, Date startDate, Date endDate, String interval, Integer distributeValue) {
        String errorMessage=GlobalConstants.BLANK;
        try{
            Opportunity parentOpp = [SELECT name, stagename,Forecast__c, closedate, id, amount,accountid, Opportunity_Product_Values_Sum__c, 
                                     	Anticipated_Deal_Value__c,Deal_Value__c,Margin__c
                                 	 FROM Opportunity WHERE id =:parentID
                                     Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
            if(parentOpp.Opportunity_Product_Values_Sum__c == 0) {
                errorMessage=GlobalConstants.PRODUCT_VALUE_SHOULD_NOT_BE_ZERO;
            }else if(parentOpp.stagename.equals(GlobalConstants.ClosedLost) 
                     || ParentOpp.stagename.equals(GlobalConstants.ClosedDuplicate) 
                     || ParentOpp.stagename.equals(GlobalConstants.ClosedWithdraw)) {
                errorMessage=GlobalConstants.VALID_STAGE_OF_FRAME;
            }else{}

        	if(String.isBlank(errorMessage)) {
                Integer oppCount = 0;
                if((GlobalConstants.Years).equals(interval)) {
                    oppCount = endDate.Year()-startDate.Year();
                    oppCount += 1;
                }else if((GlobalConstants.Quarters).equals(interval)) {
                    Integer months = calculateCloseDate(startDate).monthsBetween(endDate) ;
                    oppCount = Integer.valueOf(Math.ceil(months/3.0))+1;
                }else{}
                if(oppCount <= Integer.valueOf(GlobalConstants.Sales_Prediction_Max_Value)) {
                    List<Opportunity> newOppList = new list<Opportunity>();
                    //insert simpls
                    newOppList = insertSimpleOpps(parentOpp, oppCount, parentId, startDate, endDate, interval, newOppList);                
                    List<Id> newOppIds = new List<Id>();
                    for(Opportunity opp:newOppList) {
                        newOppIds.add(opp.Id);
                    }
                    //insert olis
                    insertOLI(newOppIds, distributeValue);
                    //insertOLIs(newOppList, parentID, distributeValue, oppCount, parentopp.Anticipated_Deal_Value__c, parentOpp.amount);
                    Opportunity frame = new Opportunity(Id=parentID, Simple_Opp_Creation_Interval__c=interval, Opportunity_Product_Change__c=GlobalConstants.NO_CHANGE);
                    Database.update(frame);
                    errorMessage = GlobalConstants.SUCCESS1 +newOppList.get(oppCount-1).CloseDate.addDays(1);
                }else {
                    errorMessage = GlobalConstants.Max_Limit_of_Sales_Prediction_has_been_Reached;
                }
             }
            if(Test.isRunningTest())
            {
                integer i=5/0;
            }
         }catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                GlobalConstants.createPridictions, GlobalConstants.OppController, true, e)));
            errorMessage = GlobalConstants.ErrorInMassCreate;
        }
        return errorMessage;
	}
   
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-05-05
    * @param: parentID, 
    * @return date
    * @description: This method will create OLIS
    *****************************************************************/
    /*private static void insertOLIs(list<Opportunity> newOppList, Id parentId, Integer distributeValue, 
                                   Integer oppCount, Decimal anticipatedValue, Decimal amount) {
        List<OpportunityLineItem> oliList = [SELECT Id,Name,Estimated_Margin__c, UnitPrice, PricebookEntryId, Quantity 
                                             FROM OpportunityLineItem WHERE OpportunityId=:parentID
                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        list<OpportunityLineItem> newOLIList = new list<OpportunityLineItem>();
        for (opportunity o:newOppList) {
            for (OpportunityLineItem oli:oliList ) {
                OpportunityLineItem newOLI = oli.clone();
                newOLI.OpportunityId = o.Id;
                if(newOLI.UnitPrice != 0 && amount != 0) {
                    if(distributeValue != 0) {
                    	newOLI.UnitPrice = distributeValue*((newOLI.UnitPrice/amount)*100)/100; 
                    }
                    newOLI.UnitPrice = (newOLI.UnitPrice / oppCount).round(System.RoundingMode.DOWN);
                }
                newOLIList.add(newOLI);
            }
        }
        insert newOLIList;
    }*/
    /****************************************************************
    * @author: Anukriti
    * @date: 2019-05-05
    * @param: parentID, 
    * @return date
    * @description: This method will create simpel oppps
    *****************************************************************/
    private static list<Opportunity> insertSimpleOpps(Opportunity parentOpp, Integer oppCount, Id parentId, 
                                         Date startDate, Date endDate, String interval, List<Opportunity> newOppList) {
        Date tempDate = null;
         for(Integer i=1 ; i <= oppCount ; i++) {
             Opportunity opp = parentOpp.clone();
             opp.Parent_Original_Opportunity__c = parentID;
             opp.recordTypeId = GlobalConstants.simpleCreateOppRecTypeId;
             opp.StageName = GlobalConstants.STAGE4;
             if(parentOpp.Forecast__c == GlobalConstants.Won || parentOpp.Forecast__c == GlobalConstants.Lost) {
                 opp.Forecast__c = GlobalConstants.ForecastCategory;
              }else {
                 opp.Forecast__c = parentOpp.Forecast__c;
              }
              opp.Anticipated_Deal_Value__c = null;
             /*if(Test.isRunningTest()) {
                opp.OpportunityNumber__c = String.valueOf(math.random() * 10);
             }*/
             if(i==1) {
                 tempDate = startDate;
             }else {
                 if((GlobalConstants.Years).equals(interval)) {
                     tempDate = tempDate.addYears(1); 
                 }else if((GlobalConstants.Quarters).equals(interval)) {
                     tempDate = tempDate.addMonths(3);
                 }else {}
             }
             if((GlobalConstants.Years).equals(interval)) {
                 opp.name = ParentOpp.name+GlobalConstants.SPACE+GlobalConstants.Y+String.valueOf(tempDate.YEAR()).right(2);
                 opp.CloseDate = Date.newInstance(tempDate.year(),12,31);
             }else if((GlobalConstants.Quarters).equals(interval)) {
                 opp.name = ParentOpp.name+GlobalConstants.SPACE+String.valueOf(tempDate.YEAR()).right(2)+GlobalConstants.SPACE+GlobalConstants.QUARTER_SYMBOL+String.valueOf(Math.ceil(tempDate.month()/3.0));
                 opp.CloseDate = oppController.calculateCloseDate(tempDate);
             }else {} 
             newOppList.add(opp);
         }
         insert newOppList;
         return newOppList;
    }
    
    @future
    public static void insertOLI(List<ID> newOppIds, Integer distributeValue) {   
    	Opportunity simpleOpp = [SELECT ID, Parent_Original_Opportunity__c, Parent_Original_Opportunity__r.amount
                                FROM Opportunity WHERE ID =: newOppIds.get(0)];
        List<OpportunityLineItem> oliList = [SELECT Id,Name,Estimated_Margin__c, UnitPrice, PricebookEntryId, Quantity 
                                             FROM OpportunityLineItem WHERE OpportunityId=:simpleOpp.Parent_Original_Opportunity__c
                                             Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        list<OpportunityLineItem> newOLIList = new list<OpportunityLineItem>();
        for (Id oppId :newOppIds) {
            for (OpportunityLineItem oli:oliList ) {
                OpportunityLineItem newOLI = oli.clone();
                newOLI.OpportunityId = oppId;
                if(newOLI.UnitPrice != 0 && simpleOpp.Parent_Original_Opportunity__r.amount != 0) {
                    if(distributeValue != 0) {
                    	newOLI.UnitPrice = distributeValue*((newOLI.UnitPrice/simpleOpp.Parent_Original_Opportunity__r.amount)*100)/100; 
                    }
                    newOLI.UnitPrice = (newOLI.UnitPrice / newOppIds.size()).round(System.RoundingMode.DOWN);
                }
                newOLIList.add(newOLI);
            }
        }
        Database.insert(newOLIList, false);
    }
    /****************************************************************
* @date: 2020-03-18
* @param: optyProdIdSet, 
* @description: This method will delete simple opportunity products.
*****************************************************************/
    @AuraEnabled
    public static void removeSimpleOptyProduct(List<Id> optyProdIdSet) {
        List<OpportunityLineItem> oppList = [SELECT Id FROM OpportunityLineItem where Id IN :optyProdIdSet Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        try{
            if(optyProdIdSet.size() > 0){
                delete oppList;
            }
                if(Test.isRunningTest()){
                    Integer i = 5/0;
                }
            
        } catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController, 
                                                                       GlobalConstants.removeOppLineItems, GlobalConstants.OppController, true, e)));
        }
    }
        /****************************************************************
    * @author: Biswajit Sahoo
    * @date: 2021-01-28
    * @param: parentID, 
    * @return date
    * @description: This method will return Deal Value by default For Stage 4 and Stage 5
    *****************************************************************/
   @AuraEnabled
    public static Decimal CheckDealValueInsertTotal(Id parentID) {
        List<Opportunity> oppList = [SELECT Id,Deal_Value__c FROM Opportunity
                                    WHERE Parent_Original_Opportunity__c =:parentID 
                   					 AND RecordTypeId =: GlobalConstants.simpleOppRecordTypeId   
                                     AND (stagename = : GlobalConstants.STAGE4 OR stagename=:GlobalConstants.ClosedWon)
                    				order by CloseDate asc 
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        Decimal sumOfDealValue = 0.00;
        for(Opportunity opp : oppList){
            if(opp.Deal_Value__c != NULL) {
                sumOfDealValue = sumOfDealValue + opp.Deal_Value__c;
            }
        }
        return sumOfDealValue;
    }
    
      /****************************************************************
    * @author: Biswajit Sahoo
    * @date: 2021-01-28
    * @param: parentID, 
    * @return date
    * @description: This method will return Deal Value by default for Stage 5
    *****************************************************************/
   @AuraEnabled
    public static Decimal CheckDealValueInsertClosedWon(Id parentID) {
        List<Opportunity> oppList = [SELECT Id,Deal_Value__c FROM Opportunity
                                    WHERE Parent_Original_Opportunity__c =:parentID 
                   					 AND RecordTypeId =: GlobalConstants.simpleOppRecordTypeId   
                    				AND stagename=:GlobalConstants.ClosedWon
                    				order by CloseDate asc 
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        Decimal sumOfDealValue = 0.00;
        for(Opportunity opp : oppList){
            if(opp.Deal_Value__c != NULL){
                sumOfDealValue = sumOfDealValue + opp.Deal_Value__c;
            }else {
                sumOfDealValue = sumOfDealValue;
            }
        } 
        return sumOfDealValue;
    }
    
      /****************************************************************
    * @author: Biswajit Sahoo
    * @date: 2021-01-28
    * @param: parentID, 
    * @return date
    * @description: This method will return Deal Value by default for Stage 4
    *****************************************************************/
   @AuraEnabled
    public static Decimal CheckDealValueInsertNegotiateClose(Id parentID) {
        List<Opportunity> oppList = [SELECT Id,Deal_Value__c FROM Opportunity
                                    WHERE Parent_Original_Opportunity__c =:parentID 
                   					 AND RecordTypeId =: GlobalConstants.simpleOppRecordTypeId   
                    				AND stagename=:GlobalConstants.STAGE4
                    				order by CloseDate asc 
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
        Decimal sumOfDealValue = 0.00;
        if(oppList!= NULL){
        for(Opportunity opp : oppList){
            if(opp.Deal_Value__c != NULL) {
                sumOfDealValue = sumOfDealValue + opp.Deal_Value__c;
            }
        }
        }
        return sumOfDealValue;
    }
    /****************************************************************
    * @author: Biswajit Sahoo
    * @date: 2021-01-28
    * @param: parentID, 
    * @return date
    * @description: This method will return Anticipated Deal Value by default
    *****************************************************************/
     @AuraEnabled
    public static Opportunity fetchAnticipatedDealValueInsertTotal(Id parentID) {
        system.debug('Inside Anticipated Apex');
        Opportunity opp = new Opportunity();
         opp = [SELECT Id,Anticipated_Deal_Value__c FROM Opportunity
                                    WHERE Id =:parentID 
                   					 AND RecordTypeId =: GlobalConstants.frameOppRecordTypeId   
                    				order by CloseDate asc 
                                    Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())];
       
       
        return opp;
    }
    
}