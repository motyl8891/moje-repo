/* Class Name : OC_TR_ValidationsUtility
* Description : This class validates the timespent of an agent based on the supplied OC_TR_TimeRecord__c list. 
*/
public Without Sharing class OC_TR_ValidationsUtility {
    
/**************************************************************************************
* @Description  This method verfies the total timespent of an agent based on the posting date
				for the supplied OC_TR_TimeRecord__c list.
* @Param		List - OC_TR_TimeRecord__c List.  
* @Example     
* OC_TR_ValidationsUtility.ValidateAgentTimeSpentOnTimeRecord(timeRecordList).
**************************************************************************************/
        Public Static Void ValidateAgentTimeSpentOnTimeRecord(List<OC_TR_TimeRecord__c> timeRecordsList){
        
        Set<String> employeeNumPostingDateSet = new Set<String>();
            
        Map<Id,OC_TR_TimeRecord__c> mapTimerecIdToTimeRec = new map<Id,OC_TR_TimeRecord__c>();
            
        Map<String,Decimal> mapEmpNoPostdateToTimeSpentRecList = new Map<String,Decimal>();
            try{
        for(OC_TR_TimeRecord__c timeRec : timeRecordsList){
            String formattedPostingDate;
            if(String.isNotBlank(timeRec.OC_TR_Employee_Number__c) && timeRec.OC_TR_PostingDate__c!=null){
                formattedPostingDate = GenerateDateInYYYMMDDFormat(timeRec.OC_TR_PostingDate__c);
                employeeNumPostingDateSet.add(timeRec.OC_TR_Employee_Number__c+formattedPostingDate);
                if(timeRec.Id!=null){
                    mapTimerecIdToTimeRec.put(timeRec.Id,timeRec);
                }
            }
        }          
            for(OC_TR_TimeRecord__c timeRec : [SELECT Id,OC_TR_Employee_Number__c,OC_TR_TimeSpent__c,
                                               OC_Tech_TR_ConcatenateEmpNoPostDate__c,OC_TR_Active__c 
                                           FROM OC_TR_TimeRecord__c
                                           WHERE OC_Tech_TR_ConcatenateEmpNoPostDate__c in:employeeNumPostingDateSet
                                           AND OC_TR_TimeSpent__c!=null AND OC_TR_PostingDate__c!=null    
                                           AND Id NOT IN: mapTimerecIdToTimeRec.keySet()
                                           AND OC_TR_Active__c = true
                                           AND OC_TR_Status__c =:OC_TR_Constants.Submitted
                                           ]){
                                               system.debug('timeRec ==>'+timeRec);
                                               Decimal timeSpentByAgent;                                      
                                               if(mapEmpNoPostdateToTimeSpentRecList !=null && !mapEmpNoPostdateToTimeSpentRecList.isEmpty() &&
                                                  mapEmpNoPostdateToTimeSpentRecList.containsKey(timeRec.OC_Tech_TR_ConcatenateEmpNoPostDate__c)){
                                                      timeSpentByAgent = mapEmpNoPostdateToTimeSpentRecList.get(timeRec.OC_Tech_TR_ConcatenateEmpNoPostDate__c) + 
                                                          Math.abs(Decimal.ValueOf(timeRec.OC_TR_TimeSpent__c));
                                                      mapEmpNoPostdateToTimeSpentRecList.put(timeRec.OC_Tech_TR_ConcatenateEmpNoPostDate__c,timeSpentByAgent);
                                                  }else{
                                                      mapEmpNoPostdateToTimeSpentRecList.put(timeRec.OC_Tech_TR_ConcatenateEmpNoPostDate__c,
                                                                                             Math.abs(Decimal.ValueOf(timeRec.OC_TR_TimeSpent__c))); 
                                                  }
                                           }
        
        for(OC_TR_TimeRecord__c timeRec : timeRecordsList){
            String postingDate;
            String empNoPostingDate;
            Decimal totalTimeSpentPerDay;
            
            try{   
            String tr = String.valueof(Math.abs(Decimal.Valueof(timeRec.OC_TR_TimeSpent__c)));
            } catch (Exception e){
                return;
            }    
            if(String.isNotBlank(timeRec.OC_TR_Employee_Number__c) && timeRec.OC_TR_PostingDate__c!=null){
                postingDate = GenerateDateInYYYMMDDFormat(timeRec.OC_TR_PostingDate__c);              
                empNoPostingDate = timeRec.OC_TR_Employee_Number__c + postingDate;
            }
            if(mapEmpNoPostdateToTimeSpentRecList!=null && !mapEmpNoPostdateToTimeSpentRecList.isEmpty() &&
               mapEmpNoPostdateToTimeSpentRecList.containsKey(empNoPostingDate) && 
               mapEmpNoPostdateToTimeSpentRecList.get(empNoPostingDate)!=null ){
                   totalTimeSpentPerDay = mapEmpNoPostdateToTimeSpentRecList.get(empNoPostingDate) +
                                          Math.abs(Decimal.ValueOf(timeRec.OC_TR_TimeSpent__c));                 
                   if(totalTimeSpentPerDay > 24){
                       timeRec.addError(Label.OC_TR_ErrorMsgWhenAgentTimeSpentGTAllowedHrs);
                   }else{
                       mapEmpNoPostdateToTimeSpentRecList.put(empNoPostingDate,totalTimeSpentPerDay);
                   }                              
                   
               } else if (Math.abs(Decimal.ValueOf(timeRec.OC_TR_TimeSpent__c)) > 24){
                   
                       timeRec.addError(Label.OC_TR_ErrorMsgWhenAgentTimeSpentGTAllowedHrs);
               }else{
                       mapEmpNoPostdateToTimeSpentRecList.put(empNoPostingDate,Math.abs(Decimal.ValueOf(timeRec.OC_TR_TimeSpent__c)));
               }
               
        }
            } catch(Exception e){
            	EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_VALIDATIONSUTILITY,OC_TR_Constants.VALIDATEAGENTTIMESPENTONTIMERECORD,null, false, e));
            }     
    }
    
/**************************************************************************************
* @Description  This method returns the Date in String format 
* @Param		Date - Date date.  
* @Return       String - YYYYMMDD
**************************************************************************************/
    Public Static String GenerateDateInYYYMMDDFormat(Date DateToFormat){
        String month;
        String day;
        String formattedDate;
        try{
        month =  ( DateToFormat.Month() > 9 ) ? String.valueOf(DateToFormat.Month()) :
        '0'+ DateToFormat.Month() ;
        day =  ( DateToFormat.Day() > 9 ) ? String.valueOf(DateToFormat.Day() ):
        '0'+ DateToFormat.Day() ;
        formattedDate = DateToFormat.year()+month + day;
        }catch(Exception e){
           EventLog.createLog(new EventLog.Error(OC_TR_Constants.OC_TR_VALIDATIONSUTILITY,OC_TR_Constants.method_GenerateDateInYYYMMDDFormat,null, false, e));
        }    
        return formattedDate;
    }
}