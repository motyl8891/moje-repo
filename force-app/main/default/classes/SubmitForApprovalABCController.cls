/****************************************************************
* @author: Aditya Mohapatra
* @date: 14-05-2020
* @User Story: 1745
* @description: This class will update a flag on ABC that are submitted for approval.
------------------------------------------------------------------------------------------------
            Developer           User story            Date        	Sprint	        Description
------------------------------------------------------------------------------------------------
            Aditya              1745                14/05/2020    		20 06       Original Version
*****************************************************************/   
public class SubmitForApprovalABCController {
 /****************************************************************
* @author: Aditya Mohapatra
* @date: 14-05-2020
* @User Story: 1475
* @description: This method will update a flag on ABC that are submitted for approval.
*****************************************************************/   
    @AuraEnabled
    public static boolean updateSubmitForApprovalFlagABC(String parentId)
        {
             Boolean isUpdated = false;
            try{
       		AntiBriberyCorruption__c abc = [Select Id,SubmitForApproval__c from AntiBriberyCorruption__c
                                                where Id =: parentId Limit 1];       
         abc.SubmitForApproval__c = true;
         database.update(abc,false); 
         isUpdated = true;
   		}catch(Exception e) {
            EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.UpdateDeviationTypeGroupsController, 
                                                                       GlobalConstants.updateSubmitForApprovalFlag, GlobalConstants.UpdateDeviationTypeGroupsController, true, e)));
        }return isUpdated;
        } 
}