public class OC_TH_CreateCustomMetadataHandler {
public static void createcustommetadata(){
        Map<String,Custom_Metadata_Queue__c> custommetadatadetails = OC_TH_CreateCustommetadataHelper.detailsretriever(OC_TH_CreateCustomMetadataConstants.status);
    	Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        for(String key:custommetadatadetails.keyset()){
            Metadata.CustomMetadata newoctrorganizationmappingdata =  new Metadata.CustomMetadata();                                   
            newoctrorganizationmappingdata.fullName = OC_TH_CreateCustomMetadataConstants.metadataname+OC_TH_CreateCustomMetadataConstants.labelappend+String.valueof(Custommetadatadetails.get(key).developername__c);
            String recordDevelopername = String.valueof(custommetadatadetails.get(key).name);
            recordDevelopername = recordDevelopername.replace(' ','_');
            newoctrorganizationmappingdata.label = OC_TH_CreateCustomMetadataConstants.labelappend+recorddevelopername;
            Metadata.CustomMetadataValue customField1 = new Metadata.CustomMetadataValue();
            customField1.field = OC_TH_CreateCustomMetadataConstants.customercompanycode; 
            customField1.value = String.valueof(custommetadatadetails.get(key).customer_company_code__c);
            newoctrorganizationmappingdata.values.add(customField1);
            Metadata.CustomMetadataValue customField2= new Metadata.CustomMetadataValue();
            customField2.field = OC_TH_CreateCustomMetadataConstants.legalform;
            customField2.value = custommetadatadetails.get(key).Legal_form__c;
            newoctrorganizationmappingdata.values.add(customField2);
            Metadata.CustomMetadataValue customField3 = new Metadata.CustomMetadataValue();
            customfield3.field = OC_TH_CreateCustomMetadataConstants.organizationid;
            customfield3.value = custommetadatadetails.get(key).organization_id__c;
            newoctrorganizationmappingdata.values.add(customField3);
            Metadata.CustomMetadataValue customField4 = new Metadata.CustomMetadataValue();
            customfield4.field = OC_TH_CreateCustomMetadataConstants.queuename;
            customfield4.value = recordDevelopername;
            newoctrorganizationmappingdata.values.add(customField4);
            mdContainer.addMetadata(newoctrorganizationmappingdata);
        }
    OC_TH_CustomMetadataDeployCallback callback = new OC_TH_CustomMetadataDeployCallback();
    Id jobid = Metadata.Operations.enqueueDeployment(mdContainer,callback);
}
}