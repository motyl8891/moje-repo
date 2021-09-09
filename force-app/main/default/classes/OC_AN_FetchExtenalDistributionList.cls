/**
* @File Name          : OC_AN_FetchExtenalDistributionList(Controller class for lwc component oc_an_localBulletinCreationLWC)
* @Description        : This class will fetch the accounts of the logged in user with role as Local Publisher
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 29th May 2021
* @Modification Log   : Updated as a part of US-2900
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-29                 IBM               Initial Version
*/


public with sharing class OC_AN_FetchExtenalDistributionList
{
    
    
    /**************************************************************************************************
	* @Description : This method will return list of external distribution list for which local bulletin is not created.
	* @Param       : recordId - Id of the bulletin for which the accounts to fetch.
    * @Return      : List of external distribution list.
	****************************************************************************************************/
    
    public Static List<OC_AN_Bulletin_Account_Product__c> fetchExtDisList(Id recordId)
    { 
        Set<id> accountIdOfBulletin = new Set<id>();
        Set<Id> accountIdOfLocalPublisher = new Set<Id>();
        for(OC_AN_Bulletin_Account_Product__c idOfAcc:[SELECT OC_AN_Account__c from OC_AN_Bulletin_Account_Product__c
                                       where OC_AN_Bulletin__c =: recordId])
                                       
          {
            accountIdOfBulletin.add(idOfAcc.OC_AN_Account__c);
        }
               
        for(OC_AN_Group_Member__c gm : [SELECT id,OC_AN_Account__c FROM OC_AN_Group_Member__c 
                                        WHERE OC_AN_Local_Publisher__c = true 
                                        AND RecordTypeId=:OC_AN_Constants.recordTypeId_LocalPublisher
                                        AND OC_AN_User__c =: UserInfo.getUserId() AND 
                                       OC_AN_Account__c IN : accountIdOfBulletin]){
                                            accountIdOfLocalPublisher.add(gm.OC_AN_Account__c);
                                        } 
        
        List<OC_AN_Bulletin_Account_Product__c> AccProdList =[SELECT Id,OC_AN_Account__r.Name,OC_AN_Account__c,OC_AN_Status__c,
                                                              OC_AN_Sub_Status__c,OC_AN_Comments__c from
                                                              OC_AN_Bulletin_Account_Product__c
                                                              where (OC_AN_Local_Bulletin__c ='' OR (OC_AN_Local_Bulletin__c != '' AND OC_AN_Local_Bulletin__r.OC_AN_Mark_as_Invalid_obsolete__c=true) )AND 
                                                              OC_AN_Bulletin__c =: recordId AND RecordTypeId=: OC_AN_Constants.recTypeId_Account 
                                                              AND OC_AN_Account__c IN: accountIdOfLocalPublisher ];
        
        return AccProdList;
    }
}