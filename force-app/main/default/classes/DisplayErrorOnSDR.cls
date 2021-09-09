public without sharing class DisplayErrorOnSDR {
    @AuraEnabled
    public static String updateApprovalStatusOfSDR(id sdrId){
        String message;
        try{
            //list<Sales_Decision_Record__c> SDR_list = new list<Sales_Decision_Record__c>(); 
            List<Sales_Decision_Record__c> SDRList = [select id,SDRInSyncWithOpportunity__c, Opportunity__c,Opportunity_Stage__c,Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c,Opportunity__r.Not_Deviating_from_Parent__c,Opportunity__r.StageName,Sales_Decision_Approval_Status__c,Opportunity__r.Is_ready_for_progression__c,
                                                      Opportunity__r.MarketArea__c,Opportunity__r.High_Impact_Deal__c,Opportunity__r.Opportunity_Progression_Type__c,
                                                      Opportunity__r.Opportunity_Tier__c,Opportunity__r.Customer_Unit__c,Opportunity__r.Approved_SDP_Stage__c,Opportunity__r.LatestApprovedSDR__c,
                                                      Sales_Decision_Type__c,Locked__c,(SELECT ID,Notification__c,Approver_Role__c FROM Sales_Decision_Makers__r WHERE Approver_Name__c!=null)
                                                      from Sales_Decision_Record__c where id =: sdrId Limit 1];
            Sales_Decision_Record__c SDR = SDRList[0];
            // Boolean isPilotGrp = SDR.Opportunity__r.Is_Pilot_Group__c;
            if(!SDR.Opportunity__r.Not_Deviating_from_Parent__c && GlobalConstants.oppStage1.equalsIgnoreCase(SDR.Opportunity__r.StageName) && !SDR.Sales_Decision_Type__c.contains('SDP0')
               && SDR.Opportunity__r.MarketArea__c != GlobalConstants.MELA) 
                message = 'You can only progress by completed SDP0 (optional) or by clicking mark stage as complete. Not possible to progress with an SDR of any other type than SDP0 ';
            else if(SDR.Sales_Decision_Approval_Status__c != GlobalConstants.APPROVED)
                message = 'You cannot save and lock a Sales Decision Record unless it is in Approved status';
            else if(GlobalConstants.APPROVED.equalsIgnoreCase(SDR.Sales_Decision_Approval_Status__c)) {
                boolean bus = SalesDecisionRecordUtility.readyForNextStage(SDR.Opportunity__r.High_Impact_Deal__c, SDR.Opportunity__r.Opportunity_Progression_Type__c,SDR.Opportunity__r.Opportunity_Tier__c, SDR.Opportunity__r.Not_Deviating_from_Parent__c, SDR.Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c, SDR, sdr.Sales_Decision_Makers__r);
                
                if(SDR.SDRInSyncWithOpportunity__c && GlobalConstants.YES.equalsIgnoreCase(SDR.Opportunity__r.Is_ready_for_progression__c) && SalesDecisionRecordUtility.readyForNextStage(SDR.Opportunity__r.High_Impact_Deal__c, SDR.Opportunity__r.Opportunity_Progression_Type__c,SDR.Opportunity__r.Opportunity_Tier__c, SDR.Opportunity__r.Not_Deviating_from_Parent__c, SDR.Opportunity__r.Deal_Value_Compared_To_CU_Value_Limits__c, SDR, sdr.Sales_Decision_Makers__r)) 
                {
                    //U-1737 & U-1733 by Ankit Jain
                    if('obsolete'.equalsIgnoreCase(SDR.Opportunity__r.Approved_SDP_Stage__c) && ('1. Qualify Opportunity'.equalsIgnoreCase(SDR.Opportunity__r.StageName)||'2. Define Customer Value'.equalsIgnoreCase(SDR.Opportunity__r.StageName)||'3. Create Proposal'.equalsIgnoreCase(SDR.Opportunity__r.StageName))){
                        message = 'There have been changes to the opportunity that makes the latest Sales Decision Record obsolete. Please create a new Sales Decision Record and get it approved to proceed to the next Sales Stage.';
                    }
                   else if('obsolete'.equalsIgnoreCase(SDR.Opportunity__r.Approved_SDP_Stage__c) && ('4. Negotiate and Close'.equalsIgnoreCase(SDR.Opportunity__r.StageName))){
                        message = 'There have been changes to the opportunity that makes the latest Sales Decision Record obsolete. Please create a new Sales Decision Record and get it approved to close the opportunity as "Won" .';
                    }
                    else if(SDR.id!=SDR.Opportunity__r.LatestApprovedSDR__c&&SDR.Sales_Decision_Type__c.equalsIgnoreCase(SDR.Opportunity__r.Approved_SDP_Stage__c)){
                        message = 'This is not the latest approved Sales Decision Record. Please "Progress Sales Stage" from the latest Approved Sales Decision Record or by clicking “Mark Stage as Complete” on the opportunity.';
                    }
                }
                else if(!GlobalConstants.YES.equalsIgnoreCase(SDR.Opportunity__r.Is_ready_for_progression__c))
                {
                    message = 'Please complete all mandatory fields in the opportunity before progressing to next stage. You can check which ones are missing to complete in the section "What is missing to get opportunity ready for approval.';                   
                }else {
                    /*SDR.SDR_Completed__c = 'No';
update SDR;*/
                    message = 'Please create a new Sales Decision Record to make sure that the Sales Decision is taken by the correct Sales Decision Makers on the correct Sales Decision Base';   
                }
            }
            /* else if(SDR.Sales_Decision_Type__c.contains('SDP2') && GlobalConstants.MELA.equalsIgnoreCase(SDR.Opportunity__r.MarketArea__c) && SDR.Opportunity__r.High_Impact_Deal__c ) {
if(SDR.Opportunity__r.Count_of_orb__c == 0)
message = 'You need to complete an ORB Sales Decision before completing a Sales Decision Record of Sales Decision type SDP2';
else if(SDR.Opportunity__r.Count_of_orb__c > 0)
{ List<Sales_Decision_Record__c>  sdrList1 = new List<Sales_Decision_Record__c>([select id, Sales_Decision_Approval_Status__c, Sales_Decision_Type__c from Sales_Decision_Record__c where Opportunity__c =: SDR.Opportunity__c and Sales_Decision_Type__c = 'ORB' and 
(Sales_Decision_Approval_Status__c = 'Approved' OR Locked__c = True) Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]);
if(sdrList1.size() == 0)
message = 'You need to complete an ORB Sales Decision before completing a Sales Decision Record of Sales Decision type SDP2';
}
}*/
            if(message == null) {
                 message=saveAndLockRecord(SDRList, SDR.Opportunity__c, SDR.Opportunity__r.StageName);
                if(message!=null && message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') && message.contains('[]')) {
                    message = message.substring(message.lastIndexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION'), message.indexOf('[]'));
                }
            }
        }
        catch(Exception e) {EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.OppController,GlobalConstants.getAllOLI, GlobalConstants.OppController, true, e)));}
        return message;
    }
    
    public static String saveAndLockRecord(List<Sales_Decision_Record__c> sdrList, Id oppId, String stage) {
        try{
            List<Sales_Decision_Maker__c> makerList = new List<Sales_Decision_Maker__c>();
            //SalesDecisionRecordTriggerHelper.setDataSnapshotFields(sdrList);
            Savepoint sp = Database.setSavepoint();
            // sdrList[0].Locked__c = true;
            for(Sales_Decision_Maker__c sdm : sdrList[0].Sales_Decision_Makers__r) {
                sdm.Notification__c = true;
                makerList.add(sdm);
            }
            /* if(isPilotGrp) {
sdrList[0].SDR_Completed__c=GlobalConstants.YES;
}*/
            Opportunity oppty = new Opportunity(id=oppId);
            // oppty.Approved_SDP_Stage__c = sdrList[0].Sales_Decision_Type__c;
            if(sdrList[0].Sales_Decision_Type__c.equalsIgnoreCase(Globalconstants.SDP3SignContract)
               || sdrList[0].Sales_Decision_Type__c.equalsIgnoreCase(Globalconstants.ConfirmGCUChild))
            {
              //  oppty.Approved_Stage__c = '4. Negotiate and Close';
              //  oppty.Approved_for_closed_won__c = true;
            }
            
            Opportunity opp;            
            if(stage!=Globalconstants.Negotiate_and_Close && sdrList[0].Sales_Decision_Type__c!=Globalconstants.SDP3SignContract) {
                opp = updateOppStage(oppty, stage);
            }
            //Commented as part of D-2741 - SDR should not be updated after locked
            /*if(opp!=null) {
                sdrList[0].Opportunity_Stage__c=opp.StageName;
            }
            update sdrList[0];*/
            try{
                if(opp!=null) {
                    update opp; 
                }
                else if(oppty!= null)
                {
                    update oppty;
                }
                if(stage!=Globalconstants.Negotiate_and_Close && sdrList[0].Sales_Decision_Type__c!=Globalconstants.SDP3SignContract) {
             	   //update makerList;
            	}
             
            }catch(Exception e) {Database.RollBack(sp); return e.getMessage();}
        }catch(Exception e) {return e.getMessage();}
        return null;
    }
    
    private static Opportunity updateOppStage(Opportunity oppty, String StageName) {
        //Opportunity opp=new Opportunity(id=oppId);
        if(Globalconstants.Qualify_Opportunity.equalsIgnoreCase(StageName)) {
            oppty.StageName=Globalconstants.Define_CustomerValue;
        }
        if(Globalconstants.Define_CustomerValue.equalsIgnoreCase(StageName)) {
            oppty.StageName=Globalconstants.Create_Proposal;
        }
        if(Globalconstants.Create_Proposal.equalsIgnoreCase(StageName)) {
            oppty.StageName=Globalconstants.Negotiate_and_Close;
        }
        return oppty;
    }
    
    
}