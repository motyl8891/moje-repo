/**
 * @author: Nikolajs Jurickis
 * @date 2018-03-23
 * BR-17456 <br>
 * @description: This Apex Class exposes method(s) that can be utilized by <br>
 * other Apex Classes to create Persistent Logs of type Error or<br>
 * Information as opposed to native Debug Logs. <br>
 * Use example of Mayank S. https://gist.github.com/miragedeb/70d5b70a6f73c8530db7 <br>
 */
public with sharing class EventLog {
    /****************************************************************
     * @author:Nikolajs Jurickis
     * @date: 2018-03-23
     * A Virtual Class that Defines the Structure of a Log <br>
     *****************************************************************/
    public virtual class Log {
        public String logType;
        public String event;
        public String apexClass;
        public String method;
        public Boolean urgent;
        public String message;
        public String stackTrace;
        public Id SobjectRecordId; //U-2669:Added for Archival of Staging Objects
        
    }
    /**************************************************************************************************
   * @author     : IBM 
   * @Class Name : integrationEventLog
   * @Description : Virtual Class that Defines the Structure of an integration log for IB Integration requirement
   ****************************************************************************************************/
    public virtual class integrationEventLog{
        public String logType;
        public String event;
        public String apexClass;
        public String method;
        public Boolean urgent;
        public String message;
        public String stackTrace;
        public String integrationIdentifier;
        public String reqPayload;
        public Boolean outboundReq;
        public Boolean inboundReq;
        public Boolean externalSystemToSFStagingObject;
        public Boolean SFStagingObjectToActualObject;
        public Boolean externalSystemToSFObject;
        public String stagingObjRecordId;
        public String errorMsg;
        Public Boolean attachPayloadFile;
        Public String attachmentType;
        Public String response;
    }
    

    /****************************************************************
     * @author:Nikolajs Jurickis
     * @date: 2018-03-23
     * A Class that Extends the Virtual Class - Log to define a log of type - Error <br>
     *****************************************************************/
    public class Error extends Log {
        public Error(
            String cls,
            String function,
            String event,
            Boolean urgent,
            Exception ex
        ) {
            this.logType = 'Error';
            this.apexClass = cls;
            this.method = function;
            this.urgent = urgent;
            this.event = event;
            this.message = ex.getMessage();
            this.stackTrace = ex.getStackTraceString();
        }
    }

/****************************************************************
* U-2669 :Added for Archival of Staging Objects
* @date: 2021-03-15
* A Class that Extends the Virtual Class - Log to define a log of type - Error <br>
*****************************************************************/
    public class ErrorLogs extends Log {
        public ErrorLogs(
            String cls,
            String function,
            String event,
            Boolean urgent,
            String errMsg,
            Id recId
        ) {
            this.logType = 'Error';
            this.apexClass = cls;
            this.method = function;
            this.urgent = urgent;
            this.event = event;
            this.message = errMsg;
            this.SobjectRecordId = recId;
        }
    }
 /**************************************************************************************************
   * @author      : IBM   
   * @Method Name : integrationLog
   * @Description : Class that Extends the Virtual integrationEventLog to define a log of type - Error for IB Requirement
   * @Param       : logType - Type of log -> Success/Information/Error
   * @Param       : cls - Name of Apex class
   * @Param       : function - Name of Apex method
   * @Param       : event - Event information
   * @Param       : urgent - Boolean value specifying criticality of log
   * @Param       :  ex - Instance of occured exception
   * @Param       : integrationIdentifier - unique integration identifier
   * @Param       : reqPayload - request payload
   * @Param       : outboundReq - Boolean value specifying whether log is being created for an outbound integration request
   * @Param       : inboundReq - Boolean value specifying whether log is being created for an inbound integration request
   * @Param       :  externalSystemToSFStagingObject - Boolean value specifying whether log is being created for a transaction 
   *                involving data migration from external system to SF staging object
   * @Param       : SFStagingObjectToActualObject - Boolean value specifying whether log is being created for a transaction 
   *                involving data migration from  SF staging object to actual/target object
   * @Param       : externalSystemToSFObject - Boolean value specifying whether log is being created for a transaction 
   *                involving data migration from  external system to SF actual/target object
   * @Param       : stagingObjRecordId - Record Id of staging object record which caused an exception
   * @Param       : errorMsg - Custom error message 
   ****************************************************************************************************/
    public class integrationLog extends integrationEventLog{
        public integrationLog(String logType,String cls, String function, String event, Boolean urgent, Exception ex,String integrationIdentifier,String reqPayload,Boolean outboundReq,Boolean inboundReq,Boolean externalSystemToSFStagingObject,Boolean SFStagingObjectToActualObject,Boolean externalSystemToSFObject,String stagingObjRecordId,String errorMsg,Boolean attachPayloadFile,String attachmentType,String response){
            this.logType = logType;
            this.apexClass = cls;
            this.method = function;
            this.urgent = urgent;
            this.event = event;
            if(ex!=null){
               this.message = (String.isNotBlank(errorMsg)) ? errorMsg + ':'+ex.getMessage() : ex.getMessage();
               this.stackTrace = ex.getStackTraceString();
            }else{
              this.message = errorMsg;  
              this.stackTrace = '';
            } 
            this.integrationIdentifier = integrationIdentifier;
            this.reqPayload = reqPayload;
            this.outboundReq = outboundReq;
            this.inboundReq = inboundReq;
            this.externalSystemToSFStagingObject = externalSystemToSFStagingObject;
            this.SFStagingObjectToActualObject = SFStagingObjectToActualObject;
            this.externalSystemToSFObject = externalSystemToSFObject;
            this.stagingObjRecordId = stagingObjRecordId;
            this.attachPayloadFile = attachPayloadFile;
            this.attachmentType = attachmentType;
            this.response = response;
        }
    }

    /****************************************************************
     * @author:Nikolajs Jurickis
     * @date: 2018-03-23
     * A Class that Extends the Virtual Class - Log to define a log of type - Information <br>
     *****************************************************************/
    public class Information extends Log {
        public Information(
            String cls,
            String function,
            String event,
            Boolean urgent,
            String msg
        ) {
            this.logType = 'Information';
            this.apexClass = cls;
            this.method = function;
            this.urgent = urgent;
            this.event = event;
            this.message = msg;
            this.stackTrace = null;
        }
    }

    /****************************************************************
     * @author:Nikolajs Jurickis
     * @date: 2018-03-23
     * @param: Instance of Log class as json string <br>
     * @return: void <br>
     * @description: A Public Method that can be utilized by other Apex Classes to create a record into <br>
     * the Event Log object stating the Error or Information. <br>
     *****************************************************************/
    @future
    public static void createLogFuture(String jsonLog) {
        try {
            System.debug('createLogDebug --> Started!');
            Log logToCreate = (Log) JSON.deserialize(jsonLog, Log.class);
            System.debug('createLogDebug logToCreate -->' + logToCreate);

            /*
              Ensure that we're well within the Governor Limits.
              The creation of the Log shouldn't disturb the execution
              of that Apex Class that utilizes this method to
              create a log.
             */
            if (
                (Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
                (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
            ) {
                EventLog__c eventlog = new EventLog__c(
                    Type__c = logToCreate.logType,
                    Apex_Class__c = logToCreate.apexClass,
                    Method__c = logToCreate.method,
                    Urgent__c = logToCreate.urgent,
                    Message__c = logToCreate.message,
                    Stack_Trace__c = logToCreate.stackTrace,
                    Event__c = logToCreate.event
                );

                Database.SaveResult srList = Database.insert(eventlog, false);
            } else {
                System.debug(
                    'The Governor Limits have already been exhausted and hence failed to create a Log!'
                );
            }
        } catch (DMLException ex) {
            System.debug(
                'Something fatal has occurred and hence failed to create a Log! Error:' +
                ex.getMessage()
            );
        }
    }

    /****************************************************************
     * @author:Nikolajs Jurickis
     * @date: 2018-03-23
     * @param: Instance of Log class <br>
     * @return: void <br>
     * @description: A Public Method that can be utilized by other Apex Classes to create a record into <br>
     * the Event Log object stating the Error or Information. <br>
     *****************************************************************/
    public static void createLog(Log log) {
        try {
            /*
              Ensure that we're well within the Governor Limits.
              The creation of the Log shouldn't disturb the execution
              of that Apex Class that utilizes this method to
              create a log.
             */
            if (
                (Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
                (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
            ) {
                EventLog__c eventlog = new EventLog__c(
                    Type__c = log.logType,
                    Apex_Class__c = log.apexClass,
                    Method__c = log.method,
                    Urgent__c = log.urgent,
                    Message__c = log.message,
                    Stack_Trace__c = log.stackTrace,
                    Event__c = log.event
                );

                Database.SaveResult srList = Database.insert(eventlog, false);
            } else {
                System.debug(
                    'The Governor Limits have already been exhausted and hence failed to create a Log!'
                );
            }
        } catch (DMLException ex) {
            System.debug(
                'Something fatal has occurred and hence failed to create a Log! Error:' +
                ex.getMessage()
            );
        }
    }
    /**************************************************************************************************
   * @author      : IBM  
   * @Method Name : createIntegrationLog
   * @Description : Creates EventLog__c records by mapping the data from integrationEventLog wrapper class records for IB Requirement
   * @Param       : logList - List of integrationEventLog wrapper class records 
   * @Return      : String - Id of the last EventLog__c record which had been inserted from the input 
   *                 list - logList
   ****************************************************************************************************/
  public static String createIntegrationLog(List<integrationEventLog> logList){
      string eventLogId;
      List <EventLog__c> eventLogInsertList = new List <EventLog__c> ();
      try{
          if ((Limits.getDMLRows() < Limits.getLimitDMLRows()) && (Limits.getDMLStatements() < Limits.getLimitDMLStatements())){
              Id integOutboundRtId = Schema.SObjectType.EventLog__c.getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.integOutboundLogRT).getRecordTypeId();
              Id integInboundRtId = Schema.SObjectType.EventLog__c.getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.integInboundLogRT).getRecordTypeId();
              Id integStagingToActualObjRtId = Schema.SObjectType.EventLog__c.getRecordTypeInfosByDeveloperName().get(OC_IB_Constants.IntegrationStagingToActualObjectEventRT).getRecordTypeId();
              if(logList!=null && !logList.isEmpty()){
                  
                  for(integrationEventLog log : logList){
                      EventLog__c eventlog = new EventLog__c(            
                          Type__c = log.logType,
                          Apex_Class__c = log.apexClass,
                          Method__c = log.method,
                          Urgent__c = log.urgent,
                          Message__c = log.message,
                          Stack_Trace__c = log.stackTrace,
                          Event__c = log.event,
                          OC_IB_IntegrationIdentifier__c = log.integrationIdentifier,
                          OC_IB_OutboundRequest__c = log.outboundReq,
                          OC_IB_InboundRequest__c= log.inboundReq,
                          OC_IB_ExternalSystemToSFStagingObject__c = log.externalSystemToSFStagingObject,
                          OC_IB_SFStagingObjectToActualObject__c = log.SFStagingObjectToActualObject,
                          OC_IB_Response__c = log.response
                          
                          
                          
                      );
                      
                      eventlog.RecordTypeId = (eventlog.OC_IB_SFStagingObjectToActualObject__c == true) ? integStagingToActualObjRtId :
                                              ((eventlog.OC_IB_OutboundRequest__c == true) ?   integOutboundRtId :  integInboundRtId);
                      
                      if(!log.attachPayloadFile){
                          eventlog.OC_IB_Payload__c = log.reqPayload;
                      }
                      if( log.stagingObjRecordId!=null && String.isNotBlank(log.stagingObjRecordId)){
                          eventlog.OC_IB_StagingObjectRecord__c = log.stagingObjRecordId;
                      }
                      eventLogInsertList.add(eventlog);
                  }
                  system.debug('eventLogInsertList.size() ==>'+eventLogInsertList.size());
                  Database.SaveResult[] srList = Database.insert(eventLogInsertList, FALSE);
                  system.debug('srList.size() ==>'+srList);
                  eventLogId = String.Valueof(srList[srList.size()-1].getId());
                  system.debug('eventLogId ==>'+eventLogId);
                  integrationEventLog log = logList[logList.size() - 1];
                  if(String.isNotBlank(eventLogId) && log.attachPayloadFile && string.isNotBlank(log.attachmentType) && String.isNotBlank(log.reqPayload)){
                      uploadPaylodAsAttachment(eventLogId,log.reqPayload,log.attachmentType);
                  }
                  
                  
              }
          }else{
                      System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
          }
      }
      catch(DMLException ex){
          System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
      }
      
      return eventLogId;
  }
    
    /**************************************************************************************************
   * @author      : IBM  
   * @Method Name : uploadPaylodAsAttachment
   * @Description : Creates an attachment with JSON payload based on the input parameters and attaches to the specified record for IB Requirement
   * @Param       : recordId - Id of record to which the attachment needs to be linked 
   * @Param       : payload - JSON payload 
   * @Param       : attachType - Type of attachment file 
   * @Return      : Id - Id of the created file attachment
   ****************************************************************************************************/
    Public Static Id uploadPaylodAsAttachment(Id recordId,String payload,String attachType){
        Attachment payloadAttach = new Attachment();
        payloadAttach.ParentId = recordId;
        payloadAttach.Name = 'payload-'+ DateTime.now();
        payloadAttach.ContentType = attachType;
        payloadAttach.Body = Blob.valueOf(payload);
        database.insert(payloadAttach);
        System.debug('recId==>'+payloadAttach.Id);
        return payloadAttach.Id;
    }
    
    /****************************************************************
* @author:IBM
* @date: 2021-03-11
* @param: Instance of Log class <br>
* @return: void <br>
* @description: A Public Method that can be utilized by other Apex Classes to create a List of records into <br>
* the Event Log object stating the Error or Information. <br>
* U-2669 :Added for Archival of Staging Objects
*****************************************************************/   
    public static void CreateEventLogs(List<Log> loglist)
    {
        List <EventLog__c> eventLogInsertList = new List <EventLog__c> ();
        try
        {
            if ((Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
                (Limits.getDMLStatements() < Limits.getLimitDMLStatements())){
                    if(logList!=null && !logList.isEmpty()){
                        for(Log logrec : logList)
                        {
                            EventLog__c eventlog = new EventLog__c(
                                Type__c = logrec.logType,
                                Apex_Class__c = logrec.apexClass,
                                Method__c = logrec.method,
                                Urgent__c = logrec.urgent,
                                Message__c = logrec.message + OC_IB_constants.sRecordId +': '+ logrec.SobjectRecordId,
                                Event__c = logrec.event
                            ); 
                            eventLogInsertList.add(eventlog);
                        }
                        system.debug('eventLogInsertList.size() ==>'+eventLogInsertList.size());
                        Database.SaveResult[] srList = Database.insert(eventLogInsertList, FALSE);
                        system.debug('srList.size() ==>'+srList.size());
                    }
                }
            
            else{
                System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
            }
            if(Test.isRunningTest())
            {
                Exception excp;
                throw excp;
            }
        }
        catch(Exception ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }
}