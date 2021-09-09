/**
* @File Name          : OC_TH_CsrServiceMilestone
* @Description        : Ticket Handling: This is the controller class for OC_TH_CsrServiceMilestoneLwc
to display parent case milestone on related collaboration and PVC Csr.                        
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 09 Aug 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-09                 IBM                  Initial Version
**/
public with sharing class OC_TH_CsrServiceMilestone {
    
    public static String[] milestoneName =  new String[] {OC_TH_Constants.getCallback1Milestone,OC_TH_Constants.getRemedy1Milestone,OC_TH_Constants.getSolution1Milestone};            
        /***************************************************************************
* @Description : This method handles to show Message when there is no milestone.  
* @Params      : childCaseRecId - Pass collaboration or PVCsr Id.
* @Returns     : returns string.
*******************************************************************************/
        @AuraEnabled(cacheable=true)
        public static string noMilestoneMessage(Id childCaseRecId){
            String showMessage = '';
            List<CaseMilestone> caseMilestoneList = new List<CaseMilestone>();
            Map<Id,Id> mapCasePVCRec = new Map<Id,Id>();
            Set<Id> setStandardCaseId =  new Set<Id>();
            Set<Id> setCollabParentId =  new Set<Id>();
            try{ 
                Case getCaseParentId = [SELECT Id,ParentId,recordTypeId,Isclosed from Case where Id =: childCaseRecId];
                    /*Add partial view csr records to set*/
                    if(getCaseParentId.recordTypeId == OC_TH_Constants.recordType_PartialCSR){
                        setStandardCaseId.add(getCaseParentId.ParentId);
                    }/*Add collaboration csr records to Map*/
                    if(getCaseParentId.recordTypeId == OC_TH_Constants.recordType_CollaborationCSR){ 
                        setStandardCaseId.add(getCaseParentId.ParentId);
                        setCollabParentId.add(getCaseParentId.ParentId);
                    }
                if(!setCollabParentId.isEmpty()){
                    /*If Collaboration CSR parentId is partial view csr then fetch partial view csr's parent Id(Standatd CSR) and add it to set*/
                    Case getPvcCollaborationParentId = [SELECT Id,ParentId FROM Case where Id =: setCollabParentId];
                        if(getPvcCollaborationParentId.ParentId != null){
                            setStandardCaseId.add(getPvcCollaborationParentId.ParentId);
                    }
                }
                if(!setStandardCaseId.isEmpty()){
                    showMessage = OC_SystemUtility.noCaseMilestone(setStandardCaseId,milestoneName);
                }}catch(Exception e){
                    EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_OC_TH_CsrServiceMilestone,OC_TH_Constants.method_noMilestoneMessage,null, false, e));       
                }
            return showMessage;    
        }
    /*******************************************************************************
* @Description : This methos handles to fectch Parent(Standard)CSR Milestone details.
* @Params      : recId - Pass collaboration or PVCsr Id.
* @Return      : returns list of CaseMilestone records.
************************************************************************************/     
    @AuraEnabled(cacheable=true)
    public static List<CaseMilestone> getMilestoneDataFromParentID(Id recId){
        
        List<CaseMilestone> caseMilestoneList = new List<CaseMilestone>();
        Set<Id> setStandardCaseId =  new Set<Id>();
        Set<Id> setCollabParentId = new Set<Id>();
        try{
            Case getCaseParentId = [SELECT Id,ParentId,recordTypeId,Isclosed from Case where Id =: recId];
                /*Add partial view csr records to set*/
                if(getCaseParentId.recordTypeId == OC_TH_Constants.recordType_PartialCSR){
                    setStandardCaseId.add(getCaseParentId.ParentId);
                    System.debug('Partial view case:--'+setStandardCaseId);
                }/*Add collaboration csr records to Map*/
                if(getCaseParentId.recordTypeId == OC_TH_Constants.recordType_CollaborationCSR){
                    setStandardCaseId.add(getCaseParentId.ParentId);
                    setCollabParentId.add(getCaseParentId.ParentId);
                }
      
            if(!setCollabParentId.isEmpty()){
                /*If Collaboration CSR parentId is partial view csr then fetch partial view csr's parent Id(Standatd CSR) and add it to set*/
                Case getPvcCollaborationParentId = [SELECT Id,ParentId FROM Case where Id =: setCollabParentId];
                if(getPvcCollaborationParentId.ParentId != null){
                    setStandardCaseId.add(getPvcCollaborationParentId.ParentId);
                }
            }
            if(!setStandardCaseId.isEmpty()){
                caseMilestoneList = OC_SystemUtility.getCaseMilestoneDetails(setStandardCaseId, milestoneName);
            }
        }catch(Exception e){
            EventLog.createLog(new EventLog.Error(OC_TH_Constants.Apxcls_OC_TH_CsrServiceMilestone,OC_TH_Constants.method_getMilestoneDataFromParentID,null, false, e));       
        } 
        return caseMilestoneList;
    }
}