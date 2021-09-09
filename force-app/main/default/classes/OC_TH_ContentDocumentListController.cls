/**
 * @File Name      :OC_TH_ContentDocumentListController
 * @Description    :Provide ContentDocumentList data to component in Lightning
 * @Author         :IBM
 * @Group          :OmniChannel - Service
 * @Created Date   : __th September 2021
 * ========================================================================================
 * Ver             Date             Author         Modification
 * ========================================================================================
 * 1.0           2021-09-__          IBM          Initial Version
**/
public class OC_TH_ContentDocumentListController {
	@AuraEnabled
    public static Map<String, String> getContentDocumentRecords (String contentDocLinkIds, String editCaseRecordId)
    {
        Map<String,String> contentDocMap =new Map<String,String>();
        
        return contentDocMap;
    }
}