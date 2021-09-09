public class SdrSubmitForApprovalCtrl {
    @AuraEnabled
    public static void sendApprovaRequest(String sdrId,String SDRCompleted, String SalesDecisionType) {
        try{
            List<Sales_Decision_Maker__c> SdmList=[select id,Approver_Name__c,Approver_Role__c from Sales_Decision_Maker__c where Sales_Decision_Record__c =:sdrId];
            Boolean flag=false;
            if(SDRCompleted.equals(GlobalConstants.NoSdr)&& !SalesDecisionType.equals(GlobalConstants.OtherSdr)){
                AuraHandledException ex = new AuraHandledException(GlobalConstants.restrictApprovalForSdrNotComplete);
                ex.setMessage(GlobalConstants.restrictApprovalForSdrNotComplete);
                throw ex;
            }
            For(Sales_Decision_Maker__c sdm:SdmList){
                if(sdm.Approver_Name__c==null || sdm.Approver_Role__c==null){
                    flag=true;
                }
            }
            if(flag){
                AuraHandledException ex = new AuraHandledException(GlobalConstants.restrictApprovalForNameRole);
                ex.setMessage(GlobalConstants.restrictApprovalForNameRole);
                throw ex;
            }
            else{
                Sales_Decision_Record__c sdr=new Sales_Decision_Record__c(Id=sdrId);
                sdr.SDR_Flag__c=true;
                update sdr;
            }
        }
        catch(Exception e){
			EventLog.createLogFuture(Json.serialize(new EventLog.Error(GlobalConstants.SdrSubmitForApprovalCtrl, 
                                                                       GlobalConstants.sendApprovaRequest, GlobalConstants.SdrSubmitForApprovalCtrl, true, e)));
            if(e.getTypeName().equals(GlobalConstants.AuraException)){
                throw e;
            }
        }
    }
}