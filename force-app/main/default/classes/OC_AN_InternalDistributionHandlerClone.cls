/**
* @File Name          : OC_AN_InternalDistributionHandler(Controller class for lwc component oc_an_internalDistributionSelection)
* @Description        : This will display the all the public groups related to Alerts and Notifications
* 				        and will associate the selected public groups to the bulletin
*
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 10th April
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-04-10                 IBM               Initial Version
**/

public with sharing class OC_AN_InternalDistributionHandlerClone {
    
    private static final string SEMICOLON = ';';
    
    /**************************************************************************************************
* @Description : This method will return the count of public groups related to Alerts and Notifications.
* @Return      : Count of Public Group Records.
****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    Public Static Integer getCountOfGroups(){
        return ([SELECT count() FROM OC_AN_Public_Group__c
                 LIMIT 50000]);
    }
    
    /**************************************************************************************************
* @Description : This method will return public groups based on pagenumber,pageSize and search string.
* @Param       : pageNumber - This will represent the pagenumber for the public group records
* @Param       : pageSize - This will represnt the number of public group records to be displayed per page.
* @Param       : searchString - This will be used to search particular public group from the list.
* @Return      : List of public group records to display.
****************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<OC_AN_Public_Group__c> getPublicGroups(Integer pageNumber, Integer pageSize, String searchString){
        
        List<OC_AN_Public_Group__c> groupsToReturn = new List<OC_AN_Public_Group__c>() ;
        
        if(searchString != '' && searchString != null){
            searchString = '%'+searchString+'%';
            groupsToReturn = [SELECT Id,Name From OC_AN_Public_Group__c Where Name Like :searchString 
                              ORDER BY Id 
                              LIMIT:pageSize ]; 
                              //OFFSET:((pageNumber-1)*pageSize)];
        }else if(searchString == ''){
            groupsToReturn =   [SELECT Id,Name From OC_AN_Public_Group__c
                                ORDER BY Id 
                                LIMIT:pageSize ];
                               // OFFSET:((pageNumber-1)*pageSize)];
            
        }
        
        return groupsToReturn;
    }
    
    
     @AuraEnabled
    public static List<OC_AN_Public_Group__c> getMorePublicGroupData(Integer pageNumber, Integer pageSize, Id lastId) {
            system.debug('lastId===>'+lastId);
        system.debug('pageNumber===>'+pageNumber);
        system.debug('pageSize===>'+pageSize);
            return [
            SELECT Name
            FROM OC_AN_Public_Group__c
            WHERE Id > :lastId
            ORDER BY Id
            LIMIT : pageSize
        ];   
    }
    
    
      @AuraEnabled
    public static List<OC_AN_Public_Group__c> getPrevPublicGroupData(Integer pageNumber, Integer pageSize, Id firstId) {
            system.debug('firstId===>'+firstId);
        system.debug('pageNumber===>'+pageNumber);
        system.debug('pageSize===>'+pageSize);
            return [
            SELECT Name
            FROM OC_AN_Public_Group__c
            WHERE Id < :firstId
            ORDER BY Id
            LIMIT : pageSize
        ];   
    }
    
    
    @AuraEnabled
    public static void associateInternalDistributionToBulletin(List<Id> listOFPublicGroupIds,Id bulletinId){
        List<OC_AN_Bulletin_Account_Product__c> groupstoAssociatewithBulletin = new List<OC_AN_Bulletin_Account_Product__c>();
        
        for(OC_AN_Public_Group__c pg : [SELECT Id,Name FROM OC_AN_Public_Group__c
                                        WHERE Id IN :listOFPublicGroupIds ]){
                                            
                                            OC_AN_Bulletin_Account_Product__c groupToAssociate = new OC_AN_Bulletin_Account_Product__c();
                                            groupToAssociate.RecordTypeId = OC_AN_Constants.recTypeId_PublicGroup;
                                            groupToAssociate.OC_AN_GroupId__c = pg.Id;
                                            groupToAssociate.OC_AN_Public_Group_Name__c = pg.Name;
                                            groupToAssociate.OC_AN_Bulletin__c = bulletinId;
                                            groupToAssociate.OC_AN_IsPublicGroup__c = true;
                                            groupToAssociate.OC_AN_BulletinAccProductAttrKey__c = pg.Id + '' + bulletinId;
                                            groupstoAssociatewithBulletin.add(groupToAssociate);                                            
                                        }
        upsert groupstoAssociatewithBulletin OC_AN_BulletinAccProductAttrKey__c;     
        
        markIsInternalAsTrue(bulletinId);
        
        
    }
    
    /**************************************************************************************************
* @Description : This will mark the internal checkbox as true whenever an account is successfully 
associated to bulletin.
* @Param       : bulletinId - Id of the bulletin to mark the checbox as true
****************************************************************************************************/
    
    public static void markIsInternalAsTrue(Id bulletinId){
        
        List<OC_AN_Bulletin__c> bulletinToUpdate = new List<OC_AN_Bulletin__c>();
        
        for(OC_AN_Bulletin__c oc : [SELECT Id,OC_AN_IsInternal__c,OC_AN_Current_Status__c FROM
                                    OC_AN_Bulletin__c Where Id =:bulletinId ]){
                                        if(oc.OC_AN_IsInternal__c == false && oc.OC_AN_Current_Status__c == OC_AN_Constants.DRAFT){
                                            oc.OC_AN_IsInternal__c = true;  
                                            bulletinToUpdate.add(oc);
                                        }
                                    }
        if(!bulletinToUpdate.isEmpty()){
            try{
                update bulletinToUpdate;
            }
            catch(Exception e){
                EventLog.createLog(new EventLog.Error(OC_AN_Constants.OC_AN_InternalDistributionHandler,OC_AN_Constants.markIsInternalAsTrue,null, false, e)); 
            }
        }
    }
    
}