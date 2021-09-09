public class OC_TH_CreateCustomMetadataHelper {
Public static Map<String,Custom_Metadata_Queue__c> Custommetadatamap = new Map<String,Custom_Metadata_Queue__c>();
  public static Map<String,Custom_Metadata_Queue__c> detailsretriever(String Status){
        for(List<Custom_Metadata_Queue__c> details:[Select id, name,legal_form__c,developername__c,customer_company_code__c,organization_id__c,Status__c FROM Custom_Metadata_Queue__c where status__c=:oc_th_createcustommetadataconstants.status]){
              Custommetadatamap  = new Map<String,Custom_Metadata_Queue__c>(details);
}
        return Custommetadatamap;
}
  @future
    public static void updatestatus(List<String>statuschange){
         List<Custom_Metadata_Queue__c> statusupdatelist = new list<Custom_Metadata_Queue__c>();
        List<Custom_Metadata_Queue__c> statusupdate = new list<Custom_Metadata_Queue__c>();
        
        for(List<Custom_Metadata_Queue__c> statustobechanged:[select id,name,status__c,developername__c from Custom_Metadata_Queue__c where developername__c in :statuschange]){
                   statusupdatelist = statustobechanged;  
}
        if(statusupdatelist.size()>0){
        for(Custom_Metadata_Queue__c iteratestatus:statusupdatelist){
                iteratestatus.status__c = oc_th_CreateCustomMetadataConstants.created;
                statusupdate.add(iteratestatus);
}
}
           
        Database.SaveResult[] sr = Database.update(statusupdate, false);
for (Database.SaveResult s : sr) {
            if (s.isSuccess()) {
                System.debug('Status Updated Successfully.');
            }
            else {
        for(Database.Error err : s.getErrors()) {
            system.debug('err'+err);
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug('fields that affected this error: ' + err.getFields());
}
}       
}
}
}