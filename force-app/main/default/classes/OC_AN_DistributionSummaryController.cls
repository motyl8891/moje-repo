/**
 * @File Name          : OC_AN_DistributionSummaryController
 * @Description        : Controller class for DistributionSummary LWC
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 12.07.2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-07-12                 IBM                   Initial Version
 **/
public with sharing class OC_AN_DistributionSummaryController {

     /**************************************************************************************************
	 * @Method Name : getDistributionSummaryData
	 * @Description : Returns List of contacts 
	 * @Param       : bulletinId,IsExternal
	 * @Return      : List Contacts Wrapper
	 ****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<OC_AN_UserAndContactsWrapper> getDistributionSummaryData(String bulletinId, Boolean isExternal){
        try {
            if(isExternal){
                return getExternalContactsForBulletin(bulletinId);
            }else{
                return OC_AN_FetchUsersFromPG.getInternalUsersForBulletin(bulletinId);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<OC_AN_UserAndContactsWrapper> getExternalContactsForBulletin(string bulletinId){
                
        set<Id> allContactIds = new Set<Id>();
        
        List<OC_AN_UserAndContactsWrapper> userAndContactsWrapper = new List<OC_AN_UserAndContactsWrapper>();
        Set<Id> accountIdSet = new Set<Id>();

        for(OC_AN_Bulletin_Account_Product__c oc : 
            [SELECT OC_AN_Account__c
            FROM OC_AN_Bulletin_Account_Product__c
            WHERE OC_AN_Bulletin__c =: bulletinId
            AND RecordTypeId =: OC_AN_Constants.recTypeId_Account]){
                accountIdSet.add(oc.OC_AN_Account__c);
            }
        
        system.debug('accountIdSet====>'+accountIdSet);

        for(Contact cont :[SELECT Id, Name, FirstName, LastName,Email, Account.Name
                            FROM Contact 
                            WHERE AccountId IN:accountIdSet
                            AND Email != '' 
                            ORDER BY Account.Name]){
            //String firstName , String lastName, String Id, String name, String email
            OC_AN_UserAndContactsWrapper userValue = new OC_AN_UserAndContactsWrapper(
                cont.FirstName,
                cont.LastName,
                cont.Id,
                cont.Name,
                cont.Email
            );
            userValue.accName = cont.Account.Name; // set the accont name  
            userAndContactsWrapper.add(userValue);
        }
        system.debug('userAndContactsWrapper:' + userAndContactsWrapper);
        return userAndContactsWrapper;
    }
}