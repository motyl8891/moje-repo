/* Class Name : OC_TR_Utility
* Description : Contains the generic methods which can be re-utilized
*/
public Without Sharing class OC_TR_Utility {
    
     /**************************************************************************************
    * @Description  Frames SOQL (Without WHERE clause) based on the input parameters.
    * @Param        ObjectName - Object Name for which SOQL needs to generated
    * @Param        fieldsList - List of fields which needs to queried from object
    * @Return       SOQL with fieldnames to be queried from an object
    *******************************************************************/
    Public Static String generateSOQL(String ObjectName,List<String> fieldsList){
        String query;
        
        String fieldToquery;
        
        if(fieldsList != null && ObjectName != null && fieldsList.size()>0){
        
        for(integer i=0;i<fieldsList.size();i++){
            
            if( fieldsList[i]!=null){
                
                if(i == 0 || i == (fieldsList.size() -1) || fieldsList[i+1] == null){
                    if(string.isNotBlank(fieldToquery)){
                        fieldToquery =  fieldToquery + ','+ fieldsList[i];
                    }else{
                        fieldToquery = fieldsList[i];
                    }
                    
                }else{
                    fieldToquery = fieldToquery + ',' + fieldsList[i] + ',';
                }  
            }
        }
        }   
        
        query = 'SELECT ' + fieldToquery +' FROM ' + ObjectName;
        if(query.contains(',,')){
            query = query.replaceAll(',,', ',');
        }
        return query;
    }
    /**************************************************************************************
    * @Description  Converts a date in GMT timezone to User time zone
    * @Param        inpDate - Date in GMT 
    * @Param        TimeZone - Timezone of user
    * @Return       DateTime in user timezone
    *******************************************************************/
    Public Static DateTime convertUserTimeZoneDateToGMT(Date inpDate,TimeZone tz){
        DateTime gmtDateTime;
        Integer offSetTime;
        
        if(inpDate !=null && tz!=null){
            offSetTime = tz.getOffset(inpDate)/1000;
            if(offSetTime > 0){
                gmtDateTime = DateTime.newInstanceGMT(inpDate.Year(),inpDate.MONTH(),inpDate.Day()-1, 24, 0, 0).addSeconds(-(offSetTime));
            }else {
                gmtDateTime = DateTime.newInstanceGMT(inpDate.Year(),inpDate.MONTH(),inpDate.Day(), 0, 0, 0).addSeconds(math.abs(offSetTime));
            }   
            
        }
        return gmtDateTime;
    }
}