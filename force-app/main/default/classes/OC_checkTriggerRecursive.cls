/*********************************************************************************
* Class Name          : OC_checkTriggerRecursive
* Description         : This class contains the methods to prevent recursion in triggers. 
* Author              : IBM. 
* @Group              : OmniChannel - Service
* @Created Date       : 19 Jan 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-01-19                 IBM                   Initial Version
* 1.1        2021-02-16                 IBM                   U-2416 - Added recursive condition Milestone automation.
* 1.2        2021-04-14                 IBM                   U-2692 - Added recursive condition for FeedItem object.
* 1.3		 2021-08-16					IBM					  D-4256 - Added recursive condition for TraskTriggerHandler
***********************************************************************************/
public with sharing class OC_checkTriggerRecursive {
    
    Public Static Boolean runAgentTimeSpentValidationCheck = true;
    Public Static Boolean ticketHandlingAfterUpdateValidationCheck = true;
    Public Static Boolean ticketHandlingFeedItemBeforeInsertCheck = true;
    Public Static Boolean ticketHandlingFeedCommentBeforeInsertCheck = true;
    Public Static Boolean toCheckStandardOwnerForPVC = true;
    Public Static Boolean runTaskTriggerValidationCheck = true;
    
    public static Boolean runAgentTimeSpentPerDayValidationOnce(){
        
        if(runAgentTimeSpentValidationCheck){ 
            runAgentTimeSpentValidationCheck=false;
            System.debug('check:--');
            return true;
        }else{
            return runAgentTimeSpentValidationCheck;
        }
    }
    
    public static Boolean runTicketHandlingAfterUpdateTask(){
        
        if(ticketHandlingAfterUpdateValidationCheck){ 
            ticketHandlingAfterUpdateValidationCheck=false;
            return true;
        }else{
            return ticketHandlingAfterUpdateValidationCheck;
        }
    }
    /*This method is used in OC_TH_FeedItemTriggerHandler class */ 
    public static Boolean runTicketHandlingFeedItemBeforeInsert(){
        
        if(ticketHandlingFeedItemBeforeInsertCheck){ 
            ticketHandlingFeedItemBeforeInsertCheck=false;
            return true;
        }else{
            return ticketHandlingFeedItemBeforeInsertCheck;
        }
    }
    /*This method is used in OC_TH_FeedCommentTriggerHandler class */ 
    public static Boolean runTicketHandlingFeedCommentBeforeInsert(){
        
        if(ticketHandlingFeedCommentBeforeInsertCheck){ 
            ticketHandlingFeedCommentBeforeInsertCheck=false;
            return true;
        }else{
            return ticketHandlingFeedCommentBeforeInsertCheck;
        }
    }
    public static Boolean ownerForPVC(){
        
        if(toCheckStandardOwnerForPVC){ 
            toCheckStandardOwnerForPVC=false;
            return true;
        }else{
            return toCheckStandardOwnerForPVC;
        }
    }
    /*D-4256 - This Method is used in TraskTriggerHandler*/
    public static Boolean runTaskTriggerValidationOnce(){
        
        if(runTaskTriggerValidationCheck){ 
            runTaskTriggerValidationCheck=false;
            return true;
        }else{
            return runTaskTriggerValidationCheck;
        }
    }
}