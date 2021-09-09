/**
* @File Name          : OC_IB_Utility
* @Description        : Class containing the generic re-utilizable  methods
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Release            : R2010
* @Created Date       : 1Oth September 2020
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2020-09-10                 IBM                   Initial Version
* 1.2        2021-05-10                 IBM                   U-2816 Product MR change
**/
public class OC_IB_Utility {  
    @TestVisible public static String httpMethod;
    public static final OC_Org_Defaults__c ocOrgDefaults = OC_Org_Defaults__c.getOrgDefaults();
    /**************************************************************************************************
* @Method Name : ParseDeserializedData 
* @Description : parses the deserialized payload based on data type of field  
*                deserializes the request payload
* @Param       : sObjRec - Instance of sobject record
* @Param       : extField - external field name
* @Param       : fieldApiName - Api name of object field
* @Param       : dataType - Data type of field
* @Param       : fieldValue - Value of object field
* @Param       : mdtfieldValue - Value of metadata  field
* @Return      : Map<Sobject,List<String>> - Key:Instance of sobject record,
*                Value:List of values sent in array of strings format for the field
****************************************************************************************************/
    Public Static Map<Sobject,List<String>> ParseDeserializedData(Sobject sObjRec,String extField,String fieldApiName,String dataType,String fieldValue,String mdtfieldValue, Map<String,Id> mapSobjRecnameToId){
        List<String> arrayvalueList;
        Map<Sobject,List<String>> mapSobjRecToArrayVal = new  Map<Sobject,List<String>> ();
        
        if(dataType.equalsIgnorecase(OC_IB_Constants.textDataType) || dataType.equalsIgnorecase(OC_IB_Constants.pickListDataType) || dataType.equalsIgnorecase(OC_IB_Constants.multiSelectPickListDataType)){
            sObjRec.put(fieldApiName,fieldValue); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.ArrayOfStrings) && String.isNotEmpty(fieldValue) && String.isNotBlank(fieldValue) && fieldValue.length() > 2) {
            List<String> recIdentiferList = fieldValue.Split(',');
            arrayvalueList = new List<String> ();
            
            for(String recIdentifier : recIdentiferList){
                arrayvalueList.add(recIdentifier.replaceAll('[^a-zA-Z0-9\\s+]', '').deleteWhiteSpace());
            }
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.booleanDataType)){
            sObjRec.put(fieldApiName,Boolean.valueOf(fieldValue)); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.integerDataType)){
            sObjRec.put(fieldApiName,Integer.valueOf(fieldValue)); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.decimalDataType)){
            sObjRec.put(fieldApiName,Decimal.valueOf(fieldValue)); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.dateDataType)){
            sObjRec.put(fieldApiName,Date.Parse(fieldValue)); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.dateDataTimeType)){
            sObjRec.put(fieldApiName,DateTime.Parse(fieldValue)); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.lookUpDataType) && !mapSobjRecnameToId.isEmpty() && mapSobjRecnameToId.containsKey(fieldValue)){
            sObjRec.put(fieldApiName,mapSobjRecnameToId.get(fieldValue)); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.EpochToDateDataType)){
            sObjRec.put(fieldApiName,Date.ValueOf(datetime.newInstance(Long.valueOf(fieldValue)))); 
        }
        else if(dataType.equalsIgnorecase(OC_IB_Constants.EpochToDateTimeDataType)){
            sObjRec.put(fieldApiName,datetime.newInstance(Long.valueOf(fieldValue))); 
        }
        
        
        if(arrayvalueList!=null && !arrayvalueList.isEmpty()){
            mapSobjRecToArrayVal.put(sObjRec,arrayvalueList);
        }else{
            mapSobjRecToArrayVal.put(sObjRec,null);
        }
        
        return  mapSobjRecToArrayVal;  
    }
    
    /**************************************************************************************************
* @Method Name : DataMapping
* @Description : Performs the data mapping from staging object field to actual object field 
*  @Param      : mdtRec - Metadata record containing the field data type info
* @Param       : sobjRec - Instance of Sobject record
* @Param       : FieldName - Actual object field name
* @Param       : stagedRec - Staged record
* @Param       : mapStagingFieldValueToSfIdNotEmpty - Boolean value specifying whether Lookup map is Empty or not
* @Param       : mapStagingFieldValueToSfId - Key : Staging record text value,value : Salesforce record id
* @Return      : Sobject -  updated instance of Sobject 
****************************************************************************************************/
    public Static Sobject DataMapping (OC_IB_InboundIntegrationFieldMapping__mdt mdtRec,Sobject sobjRec,String fieldName,OC_IB_IntegrationSobjectRecords__c stagedRec,Boolean mapStagingFieldValueToSfIdNotEmpty, Map<String,Id> mapStagingFieldValueToSfId){
        if(!(mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.lookUpDataType) || mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.EpochToDateDataType) || mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.EpochToDateTimeDataType)|| mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.dateDataType) || mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.relatedDataType)) ){
            if(ocOrgDefaults.OC_IB_TechStdTransformation_FieldName__c.equalsIgnorecase(fieldName)){
                sObjRec.Put(fieldName,formatPicklist(processTechnologyStds(String.valueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c)))));
            }
            else{
                sObjRec.Put(fieldName,stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c));
            }
        }
        else if(mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.lookUpDataType) && mapStagingFieldValueToSfIdNotEmpty){
            if(String.isNotBlank(mdtRec.OC_IB_StagingObjectMappingField__c) && mapStagingFieldValueToSfId.containsKey(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectMappingField__c)))){
                sObjRec.Put(fieldName,mapStagingFieldValueToSfId.get(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectMappingField__c))));
            }
            else if( mapStagingFieldValueToSfId.containsKey(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c)))){
                sObjRec.Put(fieldName,mapStagingFieldValueToSfId.get(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c))));
            }
            else if(String.isBlank(mdtRec.OC_IB_IgnoreStagingValue__c)||(string.isNotBlank(mdtRec.OC_IB_IgnoreStagingValue__c) && !mdtRec.OC_IB_IgnoreStagingValue__c.containsIgnoreCase(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c))))){
                sObjRec.Put(FieldName,String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c)));
            }
        }
        else if(mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.EpochToDateDataType)){
            sObjRec.Put(fieldName,Date.ValueOf(datetime.newInstance(Long.valueOf(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c))))));       
        }
        else if(mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.EpochToDateTimeDataType)){
            sObjRec.Put(fieldName,datetime.newInstance(Long.valueOf(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c)))));       
        }
        else if(mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.dateDataType)){
            sObjRec.Put(FieldName,Date.ValueOf(String.ValueOf(stagedRec.get(mdtRec.OC_IB_StagingObjectFieldApiName__c))));       
        }
        return sObjRec;
    }
    
    
    /**************************************************************************************************
* @Method Name : getProductNameToProductIdMapping
* @Description : Queries the product records based on input criteria and returns a map with key as product name and 
*                Value as Product Id.
* @Param       : searchLookupNameSet - Set of product names which needs to be queries.
* @Return      : Map<String,Id> - Key: product name,Value:Product Id
****************************************************************************************************/
    Public Static Map<String,Id> getProductNameToProductIdMapping (Set<String> searchLookupNameSet){
        Map<String,Id> mapPrdNameToPrdId = new Map<String,Id> ();
        String soqlStr = 'SELECT Id,Name  FROM Product2';
        if(searchLookupNameSet!=null && !searchLookupNameSet.isEmpty()){
            soqlStr = soqlStr + ' WHERE Name in:searchLookupNameSet';
        }
        for(Product2 prd : Database.query(soqlStr)){
            mapPrdNameToPrdId.put(prd.Name,prd.Id);
        }
        return mapPrdNameToPrdId;
    }
    
    
    /**************************************************************************************************
* @Method Name : getActualobjFieldToMdtRecMapping
* @Description : Forms the Actual object field name to repective metada record mapping 
* @Param       : inboundFieldMappingMdtRecordList - List of field mapping metadata records
* @Return      :  Map<String,OC_IB_InboundIntegrationFieldMapping__mdt>
*                 Key :  Actual object field name , value : Mdt record
****************************************************************************************************/
    Public Static  Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> getActualobjFieldToMdtRecMapping(List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList){
        Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapobjFieldToMdtRec = new Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> ();
        
        for(OC_IB_InboundIntegrationFieldMapping__mdt mdtrec :inboundFieldMappingMdtRecordList ){
            if(mdtRec.OC_IB_SfdcFieldApiName__c!=null && String.isNotBlank(mdtRec.OC_IB_SfdcFieldApiName__c)){
                mapobjFieldToMdtRec.put(mdtRec.OC_IB_SfdcFieldApiName__c,mdtrec);
            }
        }
        return mapobjFieldToMdtRec;
    }
/**************************************************************************************************
* @Method Name : fetchIntegrationOutBoundObjectPicklist
* @Description : Get the Integration object picklistValue from mtd
* @Return      : List < OC_IB_OutboundIntegration_ObjectPicklist__mdt > - List of mtd/objectValues
****************************************************************************************************/
   public static List < OC_IB_OutboundIntegration_ObjectPicklist__mdt > fetchIntegrationOutBoundObjectPicklist() {
       List<OC_IB_OutboundIntegration_ObjectPicklist__mdt> objectPickListValues=new List<OC_IB_OutboundIntegration_ObjectPicklist__mdt>();
       objectPickListValues=[ SELECT Label,DeveloperName,Active__c
                             FROM OC_IB_OutboundIntegration_ObjectPicklist__mdt 
                             WHERE Active__c = :OC_IB_Constants.outbondIntegrationobjectactive];
       return objectPickListValues;
   }
    
    /**************************************************************************************************
* @Method Name : getInboundIntegrationFieldMappingMdtRecords
* @Description : Fetches the active metadatarecords from OC_IB_InboundIntegrationFieldMapping__mdt based on the
*                provided integrationIdentifier string.
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Return      : List of metadata records - (List<OC_IB_InboundIntegrationFieldMapping__mdt>)
****************************************************************************************************/
    Public Static List<OC_IB_InboundIntegrationFieldMapping__mdt> getInboundIntegrationFieldMappingMdtRecords (String integrationIdentifier){
        
        String soql;
        
        soql = 'SELECT OC_IB_Active__c,OC_IB_InboundIntegrationIdentifier__c,'+
            'OC_IB_SfdcFieldApiName__c,OC_IB_SfdcObjectApiName__c,OC_IB_InboundIntegrationIdentifier__r.developername,'+
            'OC_IB_ActualObjectFieldDataType__c,OC_IB_External_System_Field_Name__c,OC_IB_StagingObjectApiName__c,OC_IB_StagingObjectFieldApiName__c,' +
            'OC_IB_StagingObjectFieldDataType__c,OC_IB_StagingObjectMappingField__c,OC_IB_IgnoreStagingValue__c' +
            ' FROM ' + 'OC_IB_InboundIntegrationFieldMapping__mdt' + 
            ' WHERE ' + 'OC_IB_InboundIntegrationIdentifier__r.developername ='+'\''+integrationIdentifier + '\'' + ' AND ' +
            'OC_IB_Active__c = true';
        
        return Database.query(soql);
    }
    
    /**************************************************************************************************
* @Method Name : getInboundIntegrationIdentifierMdtRecords
* @Description : Fetches the active metadatarecord from OC_IB_InboundIntegrationIdentifier__mdt based on the
*                provided integrationIdentifier string. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Return      : List of metadata records - (List<OC_IB_InboundIntegrationIdentifier__mdt>)
****************************************************************************************************/
    Public Static List<OC_IB_InboundIntegrationIdentifier__mdt> getInboundIntegrationIdentifierMdtRecords (String integrationIdentifier){
        
        String soql;
        
        soql = 'SELECT OC_IB_Active__c,OC_IB_IsStagingRequiredInSF__c,Developername'+
            ' FROM ' + 'OC_IB_InboundIntegrationIdentifier__mdt' + 
            ' WHERE ' + 'Developername ='+'\''+integrationIdentifier + '\'' + ' AND ' +
            'OC_IB_Active__c = true';
        
        return Database.query(soql);
    }
    
    /**************************************************************************************************
* @Method Name : getInboundIntegrationFieldMapping
* @Description : Fetches the mapping with Key as External System field name and value as respective 
*                metadata record.
* @Param       : inboundFieldMappingMdtRecordList - List<OC_IB_InboundIntegrationFieldMapping__mdt>
* @Return      : Map<String,OC_IB_InboundIntegrationFieldMapping__mdt>
*                Key : External System field name
*                Value : Respective metadata record
****************************************************************************************************/
    Public Static Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> getInboundIntegrationFieldMapping (List<OC_IB_InboundIntegrationFieldMapping__mdt> inboundFieldMappingMdtRecordList){
        
        Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapExtFieldToSfField = new Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> ();
        
        for(OC_IB_InboundIntegrationFieldMapping__mdt mdtrec :inboundFieldMappingMdtRecordList ){
            if(String.isNotBlank(mdtrec.OC_IB_External_System_Field_Name__c)){
                mapExtFieldToSfField.put(mdtRec.OC_IB_External_System_Field_Name__c,mdtRec);
            }
        }
        
        return mapExtFieldToSfField;
    }
    
    /**************************************************************************************************
* @Method Name : getServiceAccS2PIdToAccIdMapping
* @Description : Fetches all the service accounts.
* @Return      :  Map<String,Id> 
*                 Key : SAP_S2P_ID_Number__c of account
*                 Value : Account Id
****************************************************************************************************/
    Public Static Map<String,Id> getServiceAccS2PIdToAccIdMapping (){
        Map<String,Id> mapS2pIdToAccId = new Map<String,Id> ();
        for(Account acc : [SELECT Id,SAP_S2P_ID_Number__c,Account_Type__c,Recordtype.developername
                           FROM Account 
                           WHERE SAP_S2P_ID_Number__c!=null 
                          ]){
                              mapS2pIdToAccId.put(String.valueOf(acc.SAP_S2P_ID_Number__c),acc.Id);
                          }
        return mapS2pIdToAccId;
    }
    
    /**************************************************************************************************
* @Method Name : PrepareJsonPayload
* @Description : Creates the request payload in JSON structure
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : sobjectRecordsList - List of Sobject records
* @Param       : integrationIdentifierMdtRecordList - List of integration identifier metadata records
* @Param       : fieldMappingMdtRecordList - List of integration identifier field mappingmetadata records
* @Return      : String - (Request JSON payload)
****************************************************************************************************/
    Public static String PrepareJsonPayload(String integrationIdentifier,List<Sobject> sobjectRecordsList,List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList,List<OC_IB_OutboundIntegrationFieldMapping__mdt> fieldMappingMdtRecordList,Map<String,String> mapFieldNameToUISelValue) {
        
        String jsonRequest;
        
        JSONGenerator JsonreqGen = JSON.createGenerator(true);
        JsonreqGen.writeStartObject();     
        JsonreqGen.writeFieldName(integrationIdentifierMdtRecordList[0].OC_IB_StaticRequestKey__c);
        JsonreqGen.writeStartArray();
        
        // U-2815 & U-2816 Added for Product MR Change start
        If((mapFieldNameToUISelValue != null 
            &&  !mapFieldNameToUISelValue.isEmpty() 
            &&  String.valueof(mapFieldNameToUISelValue.get(OC_IB_Constants.objectName)).equalsIgnoreCase(OC_IB_Constants.objectProduct)) || (sobjectRecordsList == null && integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi))) {
                
                JsonreqGen.writeStartObject();
                Sobject sobjRec ;
                for(OC_IB_OutboundIntegrationFieldMapping__mdt mdtRec : fieldMappingMdtRecordList){
                    if( String.IsBlank(mdtRec.OC_IB_SendOnlyIfThisFieldValIsNull__c)){
                        JsonreqGen = prepareJSONForField(mdtRec,JsonreqGen,sobjRec,mapFieldNameToUISelValue);
                    }
                }
                JsonreqGen.writeEndObject();
                
            }  else {
                for(Sobject sobjRec :sobjectRecordsList){
                    JsonreqGen.writeStartObject();
                    for(OC_IB_OutboundIntegrationFieldMapping__mdt mdtRec : fieldMappingMdtRecordList){
                        if( String.IsBlank(mdtRec.OC_IB_SendOnlyIfThisFieldValIsNull__c)){
                            JsonreqGen = prepareJSONForField(mdtRec,JsonreqGen,sobjRec,mapFieldNameToUISelValue);
                        }
                        else if(String.IsBlank(String.ValueOf(sobjRec.get(mdtRec.OC_IB_SendOnlyIfThisFieldValIsNull__c)))) {
                            JsonreqGen = prepareJSONForField(mdtRec,JsonreqGen,sobjRec,mapFieldNameToUISelValue); 
                        }
                    }
                    JsonreqGen.writeEndObject();
                }
            }
        //U-2815 & U-2816 Added for Product MR Change endp
        JsonreqGen.writeEndArray();
        JsonreqGen.writeEndObject();
        jsonRequest = JsonreqGen.getAsString();
        
        return jsonRequest;
    }
    
    /**************************************************************************************************
* @Method Name : getIntegrationIdentifierMdtRecords
* @Description : Fetches the active metadatarecord from OC_IB_OutboundIntegrationIdentifier__mdt based on the
*                provided integrationIdentifier string. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Return      : List of metadata records - (List<OC_IB_OutboundIntegrationIdentifier__mdt>)
****************************************************************************************************/
    Public Static List<OC_IB_OutboundIntegrationIdentifier__mdt> getIntegrationIdentifierMdtRecords (String integrationIdentifier){
        
        String soql;
        
        soql = 'SELECT '+ 
            'Developername,OC_IB_Active__c,OC_IB_NamedCredentialApiName__c,OC_IB_Isrequestkeystatic__c,'+
            'OC_IB_StaticRequestKey__c,OC_IB_EndPointUrl__c,OC_IB_RequestType__c,OC_IB_ClientCertificateName__c,OC_IB_RequiresDynamicAccessToken__c'+
            ' FROM ' + 'OC_IB_OutboundIntegrationIdentifier__mdt' + 
            ' WHERE ' + 'developername ='+'\''+integrationIdentifier + '\'' + ' AND ' +
            'OC_IB_Active__c = true'; 
        
        return Database.query(soql);
    }
    
    /**************************************************************************************************
* @Method Name : getIntegrationFieldMappingMdtRecords
* @Description : Fetches the active metadatarecords from OC_IB_OutboundIntegrationFieldMapping__mdt based on the
*                provided integrationIdentifier string. 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Return      : List of metadata records - (List<OC_IB_OutboundIntegrationFieldMapping__mdt>)
****************************************************************************************************/
    Public Static List<OC_IB_OutboundIntegrationFieldMapping__mdt> getIntegrationFieldMappingMdtRecords (String integrationIdentifier){
        
        String soql;
        
        soql = 'SELECT OC_IB_Active__c,OC_IB_IntegrationIdentifier__c,'+
            'OC_IB_SfdcFieldApiName__c,OC_IB_SfdcObjectApiName__c,OC_IB_IntegrationIdentifier__r.developername,'+
            'OC_IB_DefaultValue__c,OC_IB_CustomKeyName__c,OC_IB_DiscardFieldWhenNoValue__c,OC_IB_CustomKeyStaticValue__c,' +
            'OC_IB_DoNotRepeatInRequest__c,OC_IB_Sequence__c,OC_IB_SendOnlyIfThisFieldValIsNull__c' +  
            ' FROM ' + 'OC_IB_OutboundIntegrationFieldMapping__mdt' + 
            ' WHERE ' + 'OC_IB_IntegrationIdentifier__r.developername ='+'\''+integrationIdentifier + '\'' + ' AND ' +
            'OC_IB_Active__c = true'+
            ' ORDER BY OC_IB_Sequence__c ASC' ;
        
        return Database.query(soql);
    }
    
    /**************************************************************************************************
* @Method Name : setFieldvalue
* @Description : sets a field value based on custom logic 
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : fieldName - name of the field
* @Return      : String - calculated field value 
****************************************************************************************************/
     Public Static String setFieldvalue(String integrationIdentifier,String fieldName){
        string fieldvalue;
        string formatteddt;
        if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi)){
            if(fieldName.equalsIgnoreCase(OC_IB_Constants.FromDateTime) && OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered != null){
                if(OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered > 1){
                 Date currentDate = date.today();
                 Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day()-1, 05, 00, 00);
                 fieldvalue = String.valueof(myDate.getTime());
                }
                else if(OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered == 1){
                    Date currentDate = date.today();
                    Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day() - 30, 05, 00, 00);
                    fieldvalue = String.valueof(myDate.getTime());                
                }   
            }else if (fieldName.equalsIgnoreCase(OC_IB_Constants.ToDateTime)){
                Date currentDate = date.today();
                Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 05, 00, 00);
                fieldvalue = String.valueof(myDate.getTime());               
            }
        }
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi) ){
            if(fieldName.equalsIgnoreCase(OC_IB_Constants.FromDateTime)  && OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered != null){
               if(OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered > 1){
                  Date currentDate = date.today();
                Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day()-1, 05, 00, 00);
                fieldvalue = String.valueof(myDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
                }
                else if(OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered == 1){
                    Date currentDate = date.today();
                    Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day() - 30, 05, 00, 00);
                    fieldvalue = String.valueof(myDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));                
                }
            }
            else if (fieldName.equalsIgnoreCase(OC_IB_Constants.ToDateTime)){
                Date currentDate = date.today();
                Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 05, 00, 00);
                fieldvalue = String.valueof(myDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
            }
        }
        else if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_PRD_OutApi)){
           if(fieldName.equalsIgnoreCase(OC_IB_Constants.FromDateTime) && OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered != null){
        /*if(OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered > 1){
                Date currentDate = date.today();
                Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day()-1, 05, 00, 00);
                formatteddt = String.valueof(myDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
                fieldvalue= formatteddt.substringBefore('T');
               } */
               // else if(OC_IB_RequestGenerationHandler.NoOfTimesJobTriggered == 1){
                    Date currentDate = date.today();
                    Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day() - 30, 05, 00, 00);
                    formatteddt = String.valueof(myDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss')); 
           fieldvalue= formatteddt.substringBefore('T');
               // }
            }
            else if (fieldName.equalsIgnoreCase(OC_IB_Constants.ToDateTime)){
                Date currentDate = date.today();
                Datetime myDate = Datetime.newInstance(currentDate.year(), currentDate.month(), currentDate.day(), 05, 00, 00);
                formatteddt = String.valueof(myDate.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss'));
                fieldvalue= formatteddt.substringBefore('T');
            } 
            
        }
        return fieldvalue;   
    }
    
    /**************************************************************************************************
* @Method Name : PrepareURLPayload
* @Description : Creates the request body in String format which can be appended in endpoint URL
*                while making a GET request to external system  
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : sobjectRecordsList - List of Sobject records
* @Param       : integrationIdentifierMdtRecordList - List of integration identifier metadata records
* @Param       : fieldMappingMdtRecordList - List of integration identifier field mappingmetadata records
* @Return      : String - request body
****************************************************************************************************/
    Public static String PrepareURLPayload(String integrationIdentifier,List<Sobject> sobjectRecordsList,List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList,List<OC_IB_OutboundIntegrationFieldMapping__mdt> fieldMappingMdtRecordList) {
        String request;
        
        for(Sobject sobjRec :sobjectRecordsList){
            
            for(integer i=0;i<fieldMappingMdtRecordList.size();i++){
                if( String.IsBlank(fieldMappingMdtRecordList[i].OC_IB_SendOnlyIfThisFieldValIsNull__c)){
                    request = addFieldInURLPayload(fieldMappingMdtRecordList[i],request,sobjRec);
                }
                else if(String.IsBlank(String.ValueOf(sobjRec.get(fieldMappingMdtRecordList[i].OC_IB_SendOnlyIfThisFieldValIsNull__c)))) {
                    request = addFieldInURLPayload(fieldMappingMdtRecordList[i],request,sobjRec); 
                }
                if(fieldMappingMdtRecordList[i].OC_IB_DoNotRepeatInRequest__c){
                    fieldMappingMdtRecordList.remove(i);
                    i = i-1;
                }
            }    
        }
        if(request.contains('&&')){
            request = request.replaceAll('&&', '&');
        }
        if(request.startsWithIgnoreCase('null&')){
            request = request.removeStartIgnoreCase('null&');
        }
        return request;
    }
    
    /**************************************************************************************************
* @Method Name : prepareJSONForField
* @Description : Creates the request payload in JSON structure for a field
* @Param       : mdtRec - OutboundFieldMapping metada record
* @Param       : JsonreqGen - Instance of JSONGenerator
* @Param       : sobjRec - Instance of Sobject Record 
* @Param       : mapFieldNameToUISelValue - Map of field and respective selected values by user on Integration Request 
*                tab UI.
* @Return      : JSONGenerator - Instance of JSONGenerator containing the input field and its value in JSON structure
****************************************************************************************************/
    Public Static JSONGenerator prepareJSONForField(OC_IB_OutboundIntegrationFieldMapping__mdt mdtRec,JSONGenerator JsonreqGen,Sobject sobjRec,Map<String,String> mapFieldNameToUISelValue){
        String defaultValue = (String.IsNotBlank(mdtRec.OC_IB_DefaultValue__c) ) ? mdtRec.OC_IB_DefaultValue__c : '' ;
        
        if(String.isBlank(mdtRec.OC_IB_CustomKeyStaticValue__c) && mapFieldNameToUISelValue!=null && !mapFieldNameToUISelValue.isEmpty() && (mapFieldNameToUISelValue.containsKey(mdtRec.OC_IB_CustomKeyName__c) || mapFieldNameToUISelValue.containsKey(mdtRec.OC_IB_SfdcFieldApiName__c)) ){
            if(mapFieldNameToUISelValue.containsKey(mdtRec.OC_IB_CustomKeyName__c) ){
                JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,mapFieldNameToUISelValue.get(mdtRec.OC_IB_CustomKeyName__c));
            }
            else if(mapFieldNameToUISelValue.containsKey(mdtRec.OC_IB_SfdcFieldApiName__c) ){
                JsonreqGen.writeStringField(mdtRec.OC_IB_SfdcFieldApiName__c,mapFieldNameToUISelValue.get(mdtRec.OC_IB_SfdcFieldApiName__c));
            }       
        }
        else if( String.IsBlank (mdtRec.OC_IB_CustomKeyName__c) && String.IsNotBlank (mdtRec.OC_IB_SfdcFieldApiName__c) ) {
            if(String.IsNotBlank(String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c)))){
                JsonreqGen.writeStringField(mdtRec.OC_IB_SfdcFieldApiName__c,String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c))); 
            }
            else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c) {
                JsonreqGen.writeStringField(mdtRec.OC_IB_SfdcFieldApiName__c,defaultValue);
            }
        }
        else if( String.IsNotBlank (mdtRec.OC_IB_CustomKeyName__c)) {
            if(String.IsNotBlank(mdtRec.OC_IB_CustomKeyStaticValue__c)){
                JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,mdtRec.OC_IB_CustomKeyStaticValue__c);
            }
            else if(String.IsNotBlank (mdtRec.OC_IB_SfdcObjectApiName__c) && String.IsNotBlank (mdtRec.OC_IB_SfdcFieldApiName__c)){
                if(String.IsNotBlank(String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c))) && String.IsNotBlank(String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c).get(mdtRec.OC_IB_SfdcFieldApiName__c)))) {
                    JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c).get(mdtRec.OC_IB_SfdcFieldApiName__c))); 
                }
                else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c){
                    JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,defaultValue);
                }
            }
            else if(String.IsNotBlank (mdtRec.OC_IB_SfdcFieldApiName__c)){
                if(String.IsNotBlank(String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c)))){
                    JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c))); 
                }
                else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c){
                    JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,defaultValue);
                }
            }
            else {
                String fieldvalue = setFieldvalue(mdtRec.OC_IB_IntegrationIdentifier__r.developername,mdtRec.OC_IB_CustomKeyName__c);
                if(String.IsNotBlank(fieldvalue)){
                    JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,fieldvalue);
                }
                else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c){
                    JsonreqGen.writeStringField(mdtRec.OC_IB_CustomKeyName__c,defaultValue);
                }
            }
        }
        return JsonreqGen;
    }
    
    /**************************************************************************************************
* @Method Name : addFieldInURLPayload
* @Description : Appends an input parameter and its value in a string format which can be appended in endpoint URL
*                while making a GET request to external system
* @Param       : mdtRec - OutboundFieldMapping metada record
* @Param       : request - request string
* @Param       : sobjRec - Instance of sobject record
* @Return      : String - A string with appended parameter and its value
****************************************************************************************************/
    Public Static String addFieldInURLPayload(OC_IB_OutboundIntegrationFieldMapping__mdt mdtRec,String request,Sobject sobjRec){
        
        String defaultValue = (String.IsNotBlank(mdtRec.OC_IB_DefaultValue__c) ) ? 
            mdtRec.OC_IB_DefaultValue__c : '' ;
        
        if( String.IsBlank (mdtRec.OC_IB_CustomKeyName__c) && String.IsNotBlank (mdtRec.OC_IB_SfdcFieldApiName__c) ) {
            if(String.IsNotBlank(String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c)))){
                request = request + '&' + mdtRec.OC_IB_SfdcFieldApiName__c + '=' +
                    String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c));
            }
            else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c) {
                request = request + '&' + mdtRec.OC_IB_SfdcFieldApiName__c + '=' + 
                    defaultValue;
            }
        }
        else if( String.IsNotBlank (mdtRec.OC_IB_CustomKeyName__c)) {
            if(String.IsNotBlank(mdtRec.OC_IB_CustomKeyStaticValue__c)){
                request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + 
                    mdtRec.OC_IB_CustomKeyStaticValue__c;
            }
            else if(String.IsNotBlank (mdtRec.OC_IB_SfdcObjectApiName__c) && String.IsNotBlank (mdtRec.OC_IB_SfdcFieldApiName__c)){
                if(String.IsNotBlank(String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c))) && String.IsNotBlank(String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c).get(mdtRec.OC_IB_SfdcFieldApiName__c)))) {
                    request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c).get(mdtRec.OC_IB_SfdcFieldApiName__c));
                    String.ValueOf(sobjRec.getSobject(mdtRec.OC_IB_SfdcObjectApiName__c).get(mdtRec.OC_IB_SfdcFieldApiName__c));
                }
                else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c){
                    request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + defaultValue;
                }
            }
            else if(String.IsNotBlank (mdtRec.OC_IB_SfdcFieldApiName__c)){
                if(String.IsNotBlank(String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c)))){
                    request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + String.ValueOf(sobjRec.get(mdtRec.OC_IB_SfdcFieldApiName__c));
                }
                else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c){
                    request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + defaultValue;
                }
            }
            else {
                String fieldvalue = setFieldvalue(mdtRec.OC_IB_IntegrationIdentifier__r.developername,mdtRec.OC_IB_CustomKeyName__c);
                if(String.IsNotBlank(fieldvalue)){
                    request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + fieldvalue;
                }
                else if(!mdtRec.OC_IB_DiscardFieldWhenNoValue__c){
                    request = request + '&' + mdtRec.OC_IB_CustomKeyName__c + '=' + defaultValue;
                }
            }
        }
        return request;
    }
    
    /**************************************************************************************************
* @Method Name : GenerateRequest
* @Description : Generates the request payload in JSON structure
* @Param       : integrationIdentifier - unique string to identify the integration context
* @Param       : sobjectRecordsList - List of sobject records
* @Return      : String - request JSON payload 
****************************************************************************************************/
    Public static String GenerateOutboundReqBody(String integrationIdentifier,List<Sobject> sobjectRecordsList,List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordsList,Map<String,String> mapFieldNameToUISelValue){
        List<OC_IB_OutboundIntegrationFieldMapping__mdt> fieldMappingMdtRecordList = OC_IB_Utility.getIntegrationFieldMappingMdtRecords(integrationIdentifier);
        String requestBody = '';
        string method = integrationIdentifierMdtRecordsList[0].OC_IB_RequestType__c;
        if(Test.isRunningTest()){
            if(string.isNotBlank(httpMethod)){
                method=(string.isNotBlank(httpMethod))?httpMethod:method;
            }
        }
        
        if(fieldMappingMdtRecordList!=null && !fieldMappingMdtRecordList.isEmpty() ){
            
            if(method.equalsIgnoreCase(OC_IB_Constants.httpMethodGET)){
                requestBody = OC_IB_Utility.PrepareURLPayload (integrationIdentifier,sobjectRecordsList,integrationIdentifierMdtRecordsList,fieldMappingMdtRecordList);
            }
            else{
                if(integrationIdentifierMdtRecordsList[0].OC_IB_Isrequestkeystatic__c){
                    requestBody = OC_IB_Utility.PrepareJsonPayload (integrationIdentifier,sobjectRecordsList,integrationIdentifierMdtRecordsList,fieldMappingMdtRecordList,mapFieldNameToUISelValue);
                }
            }
        }
        return requestBody;
    }
    
    /**************************************************************************************************
* @Method Name : prepareHTTPRequest
* @Description : Prepares the HTTP request based on the metadat record and request body
* @Param       : List<integrationIdentifierMdtRecordList> - Metadata record containing the details info
End point url,named credential,request type and ClientCertificateName
* @Return      : HTTPRequest 
****************************************************************************************************/
    Public Static HTTPRequest prepareHTTPRequest(List<OC_IB_OutboundIntegrationIdentifier__mdt> integrationIdentifierMdtRecordList,string reqBody){
        
        HTTPRequest request = new HTTPRequest();
        string endpoint= (String.isNotBlank(integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c)) ?
            integrationIdentifierMdtRecordList[0].OC_IB_EndPointUrl__c :
        integrationIdentifierMdtRecordList[0].OC_IB_NamedCredentialApiName__c;
        string method = integrationIdentifierMdtRecordList[0].OC_IB_RequestType__c;
        string certificateName = integrationIdentifierMdtRecordList[0].OC_IB_ClientCertificateName__c;
        if(Test.isRunningTest()){
            if(string.isNotBlank(httpMethod)){
                method=(string.isNotBlank(httpMethod))?httpMethod:method;
            }
        }
        request.setMethod(method);
        if(method.equalsIgnoreCase(OC_IB_Constants.httpMethodGET)){
            if(string.isNotBlank(reqBody)){
                request.setEndpoint(endpoint+'?'+reqBody);
            }
            else{
                request.setEndpoint(endpoint);
            }    
        }
        else{
            request.setEndpoint(endpoint);
            request.setHeader('content-type','application/json');
        }
        if(string.isNotBlank(certificateName)){
            request.setClientCertificateName(certificateName);
        }
        if(string.isNotBlank(reqBody)){
            request.setBody(reqBody);
        }
        request.setTimeOut(120000);
        
        return request;
    }
    
    /**************************************************************************************************
* @Method Name : getNoOfTimesJobTriggered
* @Description : Returns the number of times an apex job has run
* @Param       : jobName 
* @Return      : Integer - the number of times an apex job has run
****************************************************************************************************/
    public static integer getNoOfTimesJobTriggered(String jobName){
        Integer NoOfTimesJobTriggered;
        List<CronTrigger> jobDetails = [SELECT Id,State,PreviousFireTime,TimesTriggered,Cronjobdetail.Name 
                                        FROM CronTrigger 
                                        WHERE Cronjobdetail.Name =:jobName];
         NoOfTimesJobTriggered = (jobDetails!=null && !jobDetails.isEmpty()) ? jobDetails[0].TimesTriggered : null;
                return NoOfTimesJobTriggered;
    }
    
    /**************************************************************************************
* @Description  Frames SOQL (Without WHERE clause) based on the input parameters.
* @Param        ObjectName - Object Name for which SOQL needs to generated
* @Param        fieldsList - List of fields which needs to queried from object
* @Return       SOQL with fieldnames to be queried from an object
*******************************************************************/
    Public Static String generateSOQL(String ObjectName,List<String> fieldsList){
        String query;
        String fieldToquery;
        
        for(integer i=0;i<fieldsList.size();i++){
            if( fieldsList[i]!=null){
                
                if(i == 0 || i == (fieldsList.size() -1) || fieldsList[i+1] == null){
                    if(string.isNotBlank(fieldToquery)){
                        fieldToquery =  fieldToquery + ','+ fieldsList[i];
                    }
                    else{
                        fieldToquery = fieldsList[i];
                    }
                    
                }
                else{
                    fieldToquery = fieldToquery + ',' + fieldsList[i] + ',';
                }  
            }
        }   
        
        query = 'SELECT ' + fieldToquery +' FROM ' + ObjectName;
        if(query.contains(',,')){
            query = query.replaceAll(',,', ',');
        }
        return query;
    }
    
    Public Static String generateSOQLFromMdtRecord(String integrationIdentifier,Boolean OutboundIdentifier,String mdtDeveloperName){
        string mdtsoql;
        string objSoql;
        List<OC_IB_QueryObjectRecords__mdt> objRecordsToQueryMdt;
        List<String> fieldsToQueryList;
        
        mdtsoql = 'SELECT OC_IB_ObjectName__c,developerName,OC_IB_IntegrationIdentifier__c,'+
            'OC_IB_ApiNamesOfFields1__c,OC_IB_ApiNamesOfFields2__c,'+
            'OC_IB_ApiNamesOfFields3__c,OC_IB_ApiNamesOfFields4__c,'+
            'OC_IB_ApiNamesOfFields5__c'+
            ' FROM OC_IB_QueryObjectRecords__mdt' ;
        if (String.isNotBlank(mdtDeveloperName))    {
            mdtsoql = mdtsoql + ' WHERE developerName='+'\''+mdtDeveloperName+'\'';
        }
        else if(String.isNotBlank(integrationIdentifier)){
            if(OutboundIdentifier){
                mdtsoql = mdtsoql + ' WHERE OC_IB_IntegrationIdentifier__r.developerName='+'\''+integrationIdentifier+'\'';
            }
            else {
                mdtsoql = mdtsoql + ' WHERE OC_IB_InboundIntegrationIdentifier__r.developerName='+'\''+integrationIdentifier+'\'';
            }
        }
        
        objRecordsToQueryMdt = database.query(mdtsoql);
        if(objRecordsToQueryMdt!=null && !objRecordsToQueryMdt.isEmpty()) {
            fieldsToQueryList = new List<String>();
            fieldsToQueryList.add(objRecordsToQueryMdt[0].OC_IB_ApiNamesOfFields1__c);
            fieldsToQueryList.add(objRecordsToQueryMdt[0].OC_IB_ApiNamesOfFields2__c);
            fieldsToQueryList.add(objRecordsToQueryMdt[0].OC_IB_ApiNamesOfFields3__c);
            fieldsToQueryList.add(objRecordsToQueryMdt[0].OC_IB_ApiNamesOfFields4__c);
            fieldsToQueryList.add(objRecordsToQueryMdt[0].OC_IB_ApiNamesOfFields5__c);
            objSoql = OC_IB_Utility.generateSOQL(objRecordsToQueryMdt[0].OC_IB_ObjectName__c,fieldsToQueryList);
        }
        
        return objSoql;                                                    
    } 
    
    Public Static Map<String,Id> getProductRelatedMapping (Set<String> searchLookupNameSet,String recordType){
        Map<String,Id> mapPrdAttributeToId = new Map<String,Id> ();
        String soqlStr = 'SELECT Id,Name,Recordtype.developername,OC_IB_ProductRelease__c,OC_IB_ReleaseVersion__c  FROM OC_MD_ProductAttributes__c';
        if(searchLookupNameSet!=null && !searchLookupNameSet.isEmpty()  ){
            if(recordType.equalsIgnoreCase(OC_IB_Constants.REC_TYPE_PRODUCTATTRIBUTE_RELEASE)){
                soqlStr = soqlStr + ' WHERE  Recordtype.developername='+'\''+recordType+'\'' + ' AND OC_IB_ProductRelease__c in:searchLookupNameSet';
                for(OC_MD_ProductAttributes__c proAttributes: Database.query(soqlStr)){
                    mapPrdAttributeToId.put(proAttributes.OC_IB_ProductRelease__c,proAttributes.id);
                }
            }
            else if(recordType.equalsIgnoreCase(OC_IB_Constants.REC_TYPE_PRODUCTATTRIBUTE_VERSION)){
                soqlStr = soqlStr + ' WHERE  Recordtype.developername='+'\''+recordType+'\'' + ' AND OC_IB_ReleaseVersion__c in:searchLookupNameSet';
                for(OC_MD_ProductAttributes__c proAttributes: Database.query(soqlStr)){
                    mapPrdAttributeToId.put(proAttributes.OC_IB_ReleaseVersion__c,proAttributes.id);
                }
            }
            
        }
        
        return mapPrdAttributeToId;
    }
    
    Public Static Map<String,Id> getLookupRecordToId(String integrationIdentifier,List<OC_IB_IntegrationSobjectRecords__c> stagedRecList,Map<String,OC_IB_InboundIntegrationFieldMapping__mdt> mapActualobjFieldToMdtRec){
        Set<String> lookUpRecNameSet = new Set<String> ();
        Map<String,Id> mapRecNameToId = new Map<String,Id> (); 
        for(OC_IB_IntegrationSobjectRecords__c stagedRec : stagedRecList){
            for(OC_IB_InboundIntegrationFieldMapping__mdt mdtRec : mapActualobjFieldToMdtRec.Values()){
                String releaseValue = String.ValueOf(stagedRec.get('OC_IB_Asset_ProductRelease__c'));
                String versionValue = String.ValueOf(stagedRec.get('OC_IB_Asset_ReleaseVersion__c'));
                String productName = String.ValueOf(stagedRec.get('OC_IB_Asset_Product2__c'));
                if(mdtRec.OC_IB_ActualObjectFieldDataType__c.equalsIgnorecase(OC_IB_Constants.lookUpDataType)){ 
                    if(String.isNotBlank(releaseValue)){
                        lookUpRecNameSet.add(releaseValue);
                    }
                    if(String.isNotBlank(versionValue)){
                        lookUpRecNameSet.add(versionValue);
                    }
                    if(String.isNotBlank(productName)){
                        lookUpRecNameSet.add(productName);
                    }
                    
                }   
            }    
        }
        if(!lookUpRecNameSet.isEmpty()){
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_InApi)){
                mapRecNameToId = getServiceAccS2PIdToAccIdMapping();
                mapRecNameToId.putAll(getProductNameToProductIdMapping(lookUpRecNameSet));
                mapRecNameToId.putAll(getProductRelatedMapping(lookUpRecNameSet, OC_IB_Constants.REC_TYPE_PRODUCTATTRIBUTE_RELEASE));
                mapRecNameToId.putAll(getProductRelatedMapping(lookUpRecNameSet, OC_IB_Constants.REC_TYPE_PRODUCTATTRIBUTE_VERSION));
            }
        }
        return mapRecNameToId;
    }
    
    /*Format recived value of technology stanadards to field specific*/
    private static Set<String> processTechnologyStds(String rawTechStds){
        Set<String> setTechStds = new Set<String>();
        if(!String.isBlank(rawTechStds) != NULL){
            for(String temp :rawTechStds.split(OC_IB_Constants.DELIMITER)){
                setTechStds.addAll(temp.trim().split(''));
            }
        }
        return setTechStds;
    }
    
    /* Generate String separated by ; for multipicklists and Service Model */ 
    private static String formatPicklist(Set<String> setStr){
        String returnStr = '';
        if(setStr != null){
            for(String s: setStr)
            {
                if(s != null && !String.isEmpty(s) && !String.isBlank(s) && !String.isEmpty(returnStr) && !String.isBlank(returnStr)){
                    returnStr = returnStr + OC_IB_Constants.DELIMITER + s;
                }
                else if(s != null && !String.isEmpty(s) && !String.isBlank(s)){
                    returnStr = s;
                }
            }
        }
        return (returnStr != null && !String.isEmpty(returnStr) && !String.isBlank(returnStr))? returnStr: '';
    }
    
    
    /**************************************************************************************************
* @Method Name : getIntegrationIdentifierMdtRecordvalues
* @Description : Fetches the active metadatarecord from getIntegrationIdentifierMdtRecordvalues based on set of integrationIdentifier.
* @Param       : Set<String> integrationIdentifier - set of unique strings to identify the integration context
* @Return      : Map of metadata records - (Map<String,OC_IB_OutboundIntegrationIdentifier__mdt>)
****************************************************************************************************/
    Public Static Map<String,OC_IB_OutboundIntegrationIdentifier__mdt> getIntegrationIdentifierMdtRecordvalues(Set<String> integrationIdentifier){
        String soql;
        soql = 'SELECT ' + 
            'Developername,OC_IB_Active__c,OC_IB_NamedCredentialApiName__c,OC_IB_Isrequestkeystatic__c,' + 
            'OC_IB_StaticRequestKey__c,OC_IB_EndPointUrl__c,OC_IB_RequestType__c,OC_IB_ClientCertificateName__c,OC_IB_RequiresDynamicAccessToken__c' + 
            ' FROM ' + 'OC_IB_OutboundIntegrationIdentifier__mdt' + 
            ' WHERE ' + 'developername IN:integrationIdentifier'+' AND ' + 
            'OC_IB_Active__c = true';
        
        List<OC_IB_OutboundIntegrationIdentifier__mdt> metadatalist = Database.query(soql);
        Map<String, OC_IB_OutboundIntegrationIdentifier__mdt> metadataIdentifierMap = new Map<String, OC_IB_OutboundIntegrationIdentifier__mdt>();
        for(OC_IB_OutboundIntegrationIdentifier__mdt oc: metadatalist){
            metadataIdentifierMap.put(oc.Developername,oc);
        }
        return metadataIdentifierMap;
    }
}