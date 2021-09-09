/* Class Name : OC_TH_CaseTeamMemberComponentController
* Description : This class help to get the related case teamMember for the case.
* Author      : IBM.
*/


public with sharing class OC_TH_CaseTeamMemberComponentController
{
/****************************************************************************************
@ Description : This method fetches the related caseteamMember record of the case
* @author: Bharath
* @date: 2021-03-18
* @param: Case Id from lightning component
***************************************************************************************/
    @AuraEnabled
    public static list<CaseTeamMember> getRelatedList(Id recordId)
    {        
        List<CaseTeamMember> CTMlist = [Select id, Member.Name, TeamRole.Name, LastModifiedDate from CaseTeamMember where ParentId=: recordId order by LastModifiedDate desc];
        List<CaseTeamMember> CTMList1 = new List<CaseTeamMember>();
        
          for(CaseTeamMember CTM:CTMlist){
            if (CTM.TeamRole.Name == 'Investigation Leader'){
                CTMList1.add(CTM);
           }}
         for(CaseTeamMember CTM:CTMlist){
            if(CTM.TeamRole.Name == 'Team Member'){
                CTMList1.add(CTM);
            }}
        for(CaseTeamMember CTM:CTMlist) {
            if(CTM.TeamRole.Name == 'Former Investigation Leader'){
                CTMList1.add(CTM);
            }}
         for(CaseTeamMember CTM:CTMlist) {
            if (CTM.TeamRole.Name == 'Former Team Member'){
                CTMList1.add(CTM);
            }}
         return CTMlist1;
    }
}