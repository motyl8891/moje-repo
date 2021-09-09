/*********************************************************************************
* @Description  This class contains the methods to prevent recursion in triggers 
***********************************************************************************/
public Without Sharing class OC_TR_checkRecursive {
    
    Public Static Boolean runAgentTimeSpentValidationCheck = true;
    
    public static Boolean runAgentTimeSpentPerDayValidationOnce(){
        if(runAgentTimeSpentValidationCheck){
         runAgentTimeSpentValidationCheck=false;
         return true;
        }else{
            return runAgentTimeSpentValidationCheck;
        }
    }

}