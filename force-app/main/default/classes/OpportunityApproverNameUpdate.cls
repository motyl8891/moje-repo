/**********************************************************************
 Name:  OpportunityApproverNameUpdate
 Copyright © 2019  Ericsson.
======================================================
Req: 
U-0825 -- Visual Approval Process on the Opp
======================================================
Purpose:                                                            
Allows to capture the pending Approval Name in the opportunity
======================================================
History:                                                            
-------                                                            
VERSION     AUTHOR            DATE            DETAIL
   1.0 -    TCS               02/18/2019      Initial Development
***********************************************************************/

public class OpportunityApproverNameUpdate {
  @InvocableMethod(label='Update Approver Name' description='Updates the Approver name corresponding to the specified Opportunity IDs.')
  public static void updateApproverName(List<ID> ids) {
      Try{
    List<Opportunity> opportunities = [SELECT id,Pending_Approval_From__c from Opportunity where ID in:ids];
    List<Opportunity> opportunityUpdateList = new List<Opportunity>();
    String approverNames;
    List<ProcessInstance> processinstancedetails = [SELECT id,LastActor.Name,Status,(SELECT Id, StepStatus,Actor.Name FROM StepsAndWorkitems where StepStatus = 'Pending') FROM ProcessInstance where TargetObjectId in:ids and Status = 'Pending'];
    if(processinstancedetails.size()>0){
        approverNames = processinstancedetails[0].StepsAndWorkitems[0].Actor.Name;
        opportunities[0].Pending_Approval_From__c = approverNames;
        opportunityUpdateList.add(opportunities[0]);
    }else{
        opportunities[0].Pending_Approval_From__c = null;
        opportunityUpdateList.add(opportunities[0]);
    }
    if(opportunityUpdateList.size()>0){
        update opportunityUpdateList;       
    }
          }catch(Exception e){	}
  }
}