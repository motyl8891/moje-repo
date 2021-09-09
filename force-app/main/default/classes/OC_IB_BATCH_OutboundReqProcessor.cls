/* Class Name : OC_IB_BATCH_OutboundReqProcessor
 * Description : Batch class to handle the sf-->EBIP outbound requests to fetch the asset/product data
*/
Global class OC_IB_BATCH_OutboundReqProcessor implements Database.Batchable <Sobject>,Database.AllowsCallouts {
    String integrationIdentifier;
    List<Sobject> sobjRecList = new List<Sobject> ();
    Set<String> recordTypeSet = new Set<String> {OC_IB_Constants.serviceAccRTdevName,OC_IB_Constants.partnerAccRecType};
    
    Global OC_IB_BATCH_OutboundReqProcessor (String integIdentifier){
        integrationIdentifier = integIdentifier;
    }
    
    Global Database.Querylocator start(Database.BatchableContext bc) {
        List<String> fieldsToQueryList;
        String soqlStr = '';
        
        if(String.isNotBlank(integrationIdentifier)){
            soqlStr = OC_IB_Utility.generateSOQLFromMdtRecord(integrationIdentifier,true,null);
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi)||integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi)){
                   soqlstr = soqlstr + ' WHERE Recordtype.developername='+'\''+OC_IB_Constants.serviceAccRTdevName + '\'' +
                                          ' AND ' + 'Parent.SAP_S2P_ID_Number__c!=null' +
                                          ' AND ' + 'Parent.Recordtype.developername NOT IN:recordTypeSet';
                    
            }
       } 
        return Database.getQueryLocator(soqlStr);
    }  
    
    Global Void execute(Database.BatchableContext bc, List<Sobject> sObjrecordsList) {
        
        if(sObjrecordsList!=null && !sObjrecordsList.isEmpty()){
            if(integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_Ibase_OutApi)||integrationIdentifier.equalsIgnoreCase(OC_IB_Constants.Sfdc_Ebip_CSM_OutApi)){
                List<Sobject> SoldToAccountsList;
                Set<String> SoldToAccIdSet = new  Set<String>();
                String soqlStr;
                
                for(Sobject sobjRec : sObjrecordsList){
                    SoldToAccIdSet.add(String.valueOf(sobjRec.get('ParentId')));
                }
                soqlStr = OC_IB_Utility.generateSOQLFromMdtRecord(null,false,OC_IB_Constants.soldToAccountQueryMdt);
                if(String.isNotBlank(soqlStr)){
                    soqlStr = soqlStr + ' WHERE Id in:SoldToAccIdSet';
                    SoldToAccountsList = Database.query(soqlStr);
                }
                if(SoldToAccountsList!=null && !SoldToAccountsList.isEmpty()){
                    OC_IB_IntegrationBaseClass.Authentication(integrationIdentifier,SoldToAccountsList,null);
                }
            }      
            }else{
                OC_IB_IntegrationBaseClass.Authentication(integrationIdentifier,sObjrecordsList,null);
            }
        }
    
    Global void finish(Database.BatchableContext bc) {
    
    }
}