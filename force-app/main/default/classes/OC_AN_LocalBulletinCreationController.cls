/**
* @File Name          : OC_AN_LocalBulletinCreationController
* @Description        : U-2832 Alerts & Notification: Creation of local bulletins.
*                       Controller class to create local bulletin.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 31 May 2021
* @Modification Log   :
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-05-31                IBM                   Initial Version
**/

public with sharing class OC_AN_LocalBulletinCreationController {
    
    
    /**************************************************************************************************
* @Description : This method will return list of external distribution list for which local bulletin is not created.
* @Param       : parentbulletinId - Id of the bulletin for which the accounts to fetch.
* @Return      : List of external distribution list.
****************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<OC_AN_Bulletin_Account_Product__c> getExternalDistributionList(String parentbulletinId) {
        try{
            List<OC_AN_Bulletin_Account_Product__c> externalDistributionList=new List<OC_AN_Bulletin_Account_Product__c>();
            externalDistributionList=OC_AN_FetchExtenalDistributionList.fetchExtDisList(parentbulletinId);
            return externalDistributionList;
        } 
        catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
    /**************************************************************************************************
* @Description : This method is called from component on create local bulletin button click.
* @Param       : bulletinId - Id of the bulletin for which the accounts to associate.
* @Param       : bulletinRecordsFromJS - String in the format of json(AccountWrapper).
* @Return      : String - Success meesge or Error discription. 
****************************************************************************************************/
    
    @AuraEnabled
    public static string createLocalBulletin (String bulletinRecordsFromJS, String bulletinId){
        try{
            List<AccountWrapper> returnedResponse = (List<AccountWrapper>) JSON.deserialize(bulletinRecordsFromJS, List<AccountWrapper>.class);
            String localBuletinId = processRecords(returnedResponse,bulletinId);
            system.debug('Response:'+localBuletinId);
            return localBuletinId;
        }
        catch(Exception ex){
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
        
    }
    
    
    
    /**************************************************************************************************
* @Description : 1.This method processes account wrapperlist to create local bulletin for selected account.
2.Creates internal distribution list,external distribution list and product lists and associates with 
created intenal bulletin record.
3.Updates status of external distribution list.
* @Param       : accountWrapperList - List for AccountWrapper.
* @Param	   : bulletinId - Bulletin record id.

****************************************************************************************************/

    public static String processRecords(List<AccountWrapper> accountWrapperList, String bulletinId){
        map<id,id> accountProductIdvrsAccId=new map<id,id>();
        //OC_AN_Bulletin__c parentBulletinRecord;
        id localBulletinId;
        
        List<OC_AN_Bulletin_Account_Product__c> accProductBullentinListToCreate=new List<OC_AN_Bulletin_Account_Product__c>();
        map<Id,OC_AN_Bulletin_Account_Product__c> externalDistributionListToUpdate=new map <id,OC_AN_Bulletin_Account_Product__c>();
        map<id,OC_AN_Bulletin_Account_Product__c> externalDistributionList=new map<id,OC_AN_Bulletin_Account_Product__c>();
        list<OC_AN_Bulletin_Account_Product__c> internalDistributionAndProductList=new List<OC_AN_Bulletin_Account_Product__c>();
        
        //Savepoint to rolleback entire transction if any error occured while creating/updating bulletin records and its related records.
        Savepoint savePointContext = Database.setSavepoint();
        
        try{
            for(AccountWrapper recordInContext:accountWrapperList){
                
                if(String.isNotBlank(recordInContext.Status) && recordInContext.Status.equalsIgnoreCase(OC_AN_Constants.OC_AN_External_Distribution_List_Status)){ 
                    accountProductIdvrsAccId.put(recordInContext.RecordId,recordInContext.accountID);
                }
            }
            for(OC_AN_Bulletin__c parentBulletinRecord : [SELECT id,Name,OC_AN_Bulletin_Template__c,OC_AN_Body_Of_Bulletin__c,OC_AN_Internal_Body_Of_Bulletin__c,
                                                          OC_AN_Issue__c,OC_AN_Delay__c,OC_AN_Type__c,OC_AN_Organization__c , 
                                                          (SELECT id, OC_AN_RoleForA_N__c, recordtypeId, OC_AN_Product__c, OC_AN_Release__c, OC_AN_Verison__c, 
                                                           OC_AN_GroupId__c, OC_AN_Public_Group_Name__c, OC_AN_Status__c, OC_AN_Sub_Status__c, OC_AN_Comments__c 
                                                           FROM Bulletin_Account_Products__r) 
                                                          FROM OC_AN_Bulletin__c WHERE id=:bulletinId] )
            {
                try
                {
                    for(OC_AN_Bulletin_Account_Product__c accountProductRecord  :parentBulletinRecord.Bulletin_Account_Products__r){
                        
                        if(accountProductRecord.recordtypeId != null && accountProductRecord.recordtypeId == OC_AN_Constants.recTypeId_Account)
                            externalDistributionList.put(accountProductRecord.id,accountProductRecord);
                        else if(accountProductRecord.recordtypeId != null 
                                && 
                                (  accountProductRecord.recordtypeId == OC_AN_Constants.recTypeId_PublicGroup 
                                 || accountProductRecord.recordtypeId == OC_AN_Constants.recTypeId_AccPrdForBulletin_Product
                                ) 
                               )
                            internalDistributionAndProductList.add(accountProductRecord);
                        
                    }
                }catch( QueryException e )
                {
                    Database.rollback(savePointContext);
                    AuraHandledException auraException = new AuraHandledException(e.getMessage());
                    auraException.setMessage(e.getMessage());
                    throw auraException;
                }
                //create local bullentin record, internal distribution,external distribution and product list creation.
                if(!accountProductIdvrsAccId.isEmpty()){
                    localBulletinId=createLocalBulletinRecord(parentBulletinRecord);
                    accProductBullentinListToCreate=createExternalDistributionList(localBulletinId,accountProductIdvrsAccId.values());
                    if(! internalDistributionAndProductList.isEmpty() && internalDistributionAndProductList.size() > 0){
                        List<OC_AN_Bulletin_Account_Product__c> listToCreate= createProductAndInternalDistributionList(localBulletinId,internalDistributionAndProductList);
                        if(listToCreate!= null &&  ! listToCreate.isEmpty() )
                            accProductBullentinListToCreate.addAll(listToCreate);
                    }
                    //update local bulletin field.
                    externalDistributionListToUpdate=  updateLocalBulletinField(localBulletinId,accountProductIdvrsAccId.keySet());
                }
                //update status,substaus and comments on external distribution list.
                externalDistributionListToUpdate=updateParentExternalDistributionList(accountWrapperList,externalDistributionListToUpdate,externalDistributionList) ;
                
                //save account product records into database.
                if(! accProductBullentinListToCreate.isEmpty())
                    insert accProductBullentinListToCreate;
                
                //update account product record into database.
                if(! externalDistributionListToUpdate.isEmpty())
                    update externalDistributionListToUpdate.values();
            }
            return localBulletinId;
            
        }
        catch(Exception ex){  
            //Transction is rolled back as exception occured while creating/updating bulletin records or its related records.
            Database.rollback(savePointContext);
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
    }
    
    
    /**************************************************************************************************
* @Description : This method creates local bulletin record.
* @Param       : parentBulletinRecord - Bulletin record for which local bulletin to be created.
* @Param	   : Id of created local bulletin record.
****************************************************************************************************/
    
    public static id createLocalBulletinRecord(OC_AN_Bulletin__c parentBulletinRecord){
        
        try{
            OC_AN_Bulletin__c localBullentinToCreate=new OC_AN_Bulletin__c();
            localBullentinToCreate.OC_AN_Bulletin_Template__c=parentBulletinRecord.OC_AN_Bulletin_Template__c;
            localBullentinToCreate.OC_AN_Delay__c=parentBulletinRecord.OC_AN_Delay__c;
            localBullentinToCreate.OC_AN_Type__c=parentBulletinRecord.OC_AN_Type__c;
            localBullentinToCreate.OC_AN_Organization__c=parentBulletinRecord.OC_AN_Organization__c;
            localBullentinToCreate.OC_AN_Body_Of_Bulletin__c=parentBulletinRecord.OC_AN_Body_Of_Bulletin__c;
            localBullentinToCreate.OC_AN_Internal_Body_Of_Bulletin__c=parentBulletinRecord.OC_AN_Internal_Body_Of_Bulletin__c;
            localBullentinToCreate.Name=parentBulletinRecord.Name;
            localBullentinToCreate.OC_AN_Current_Status__c=OC_AN_Constants.DRAFT;
            localBullentinToCreate.RecordTypeId =OC_AN_Constants.OC_AN_RecordTypeId_Local_Bulletin;
            localBullentinToCreate.OC_AN_IsInternal__c =true;
            localBullentinToCreate.OC_AN_Parent_Bulletin__c =parentBulletinRecord.id;
            insert localBullentinToCreate;
            return localBullentinToCreate.id;
        }
        catch(Exception ex){
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
            
        }
        
    }
    
    
    /**************************************************************************************************
* @Description : This method creates external disctribution list for local bulletin.
* @Param       : localBullentinId - id of bulletin record for which internal distribition list and product list need to be created.
* @Param       : accountIdList - list of account ids for which external distribution list to be created.
* @Return	   : List of OC_AN_Bulletin_Account_Product__c
****************************************************************************************************/
    
    public static List<OC_AN_Bulletin_Account_Product__c> createExternalDistributionList(id localBullentinId, list<id> accountIdList){
        List<OC_AN_Bulletin_Account_Product__c> accountProductListToCreate=new List<OC_AN_Bulletin_Account_Product__c>();
        try{
            for(Id accId:accountIdList){
                OC_AN_Bulletin_Account_Product__c accountProductRecord=new OC_AN_Bulletin_Account_Product__c();
                accountProductRecord.OC_AN_Account__c=accId;
                accountProductRecord.OC_AN_Bulletin__c=localBullentinId;
                accountProductRecord.OC_AN_Status__c = OC_AN_Constants.SEND;
                accountProductRecord.OC_AN_Sub_Status__c = OC_AN_Constants.SEND;
                accountProductRecord.RecordtypeId=OC_AN_Constants.recTypeId_Account;
                accountProductListToCreate.add(accountProductRecord);
            }
            return accountProductListToCreate;
        }
        catch(Exception ex){
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
    }
    
    /**************************************************************************************************
* @Description :	This method creates product & internal disctribution list for local bulletin. 
* @Param       : 	localBullentinId - id of bulletin record for which internal distribition list and product list need to be created.
* @Param       :    internalDistributionAndProductList -  List of OC_AN_Bulletin_Account_Product__c which need to be cloned.
* @Return      :    List of OC_AN_Bulletin_Account_Product__c records.
****************************************************************************************************/
    
    public static List<OC_AN_Bulletin_Account_Product__c> createProductAndInternalDistributionList(id localBullentinId, List<OC_AN_Bulletin_Account_Product__c> internalDistributionAndProductList){
        List<OC_AN_Bulletin_Account_Product__c> accountProductListToCreate=new List<OC_AN_Bulletin_Account_Product__c>();
        
        id accountRecordTypeId=OC_AN_Constants.recTypeId_Account;
        id publicGroupRecordTypeId=OC_AN_Constants.recTypeId_PublicGroup;
        id productRecordTypeId=OC_AN_Constants.recTypeId_AccPrdForBulletin_Product;
        try{
            for( OC_AN_Bulletin_Account_Product__c accountProductRecordInContext: internalDistributionAndProductList){
                //create product record list
                if(accountProductRecordInContext.recordtypeId == productRecordTypeId){
                    OC_AN_Bulletin_Account_Product__c accountProductRecord=new OC_AN_Bulletin_Account_Product__c();
                    accountProductRecord.OC_AN_Product__c=accountProductRecordInContext.OC_AN_Product__c;
                    accountProductRecord.OC_AN_Release__c=accountProductRecordInContext.OC_AN_Release__c;
                    accountProductRecord.OC_AN_Verison__c=accountProductRecordInContext.OC_AN_Verison__c;
                    accountProductRecord.OC_AN_Bulletin__c=localBullentinId;
                    accountProductRecord.RecordtypeId=productRecordTypeId;
                    accountProductListToCreate.add(accountProductRecord);
                }
                else if(accountProductRecordInContext.recordtypeId==publicGroupRecordTypeId){
                    //creates internal distribution list
                    OC_AN_Bulletin_Account_Product__c accountProductRecord=new OC_AN_Bulletin_Account_Product__c();
                    accountProductRecord.OC_AN_GroupId__c=accountProductRecordInContext.OC_AN_GroupId__c;
                    accountProductRecord.OC_AN_Public_Group_Name__c=accountProductRecordInContext.OC_AN_Public_Group_Name__c;
                    accountProductRecord.OC_AN_Bulletin__c=localBullentinId;
                    accountProductRecord.OC_AN_RoleForA_N__c=accountProductRecordInContext.OC_AN_RoleForA_N__c;
                    accountProductRecord.RecordtypeId=publicGroupRecordTypeId;
                    accountProductRecord.OC_AN_IsPublicGroup__c=true;
                    accountProductListToCreate.add(accountProductRecord);
                }
                
            }
            return accountProductListToCreate;
        }
        catch(Exception ex){
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
    }
    
    
    
    /**************************************************************************************************
* @Description : This method updates oc_AN_Local_Bulletin field on external distribution list, for which new local bullention has created.
* @Param       : localBullentinId -  Id of the bulletin which need to associate with external distribution list.
* @Param       : externalDistributionIdSet - set of external distribution record id's for which local bulletin need to be updated.
* @Return      : map of id vrs OC_AN_Bulletin_Account_Product__c records.
****************************************************************************************************/
    
    
    public static map<Id,OC_AN_Bulletin_Account_Product__c> updateLocalBulletinField(id localBullentinId,set<id> externalDistributionIdSet){
        map<Id,OC_AN_Bulletin_Account_Product__c> accountProductListToUpdate=new map<Id,OC_AN_Bulletin_Account_Product__c>();
        try{
            for(Id recordIdInContext:externalDistributionIdSet){
                OC_AN_Bulletin_Account_Product__c accountProductRecord=new OC_AN_Bulletin_Account_Product__c();
                accountProductRecord.id=recordIdInContext;
                accountProductRecord.OC_AN_Local_Bulletin__c=localBullentinId;
                accountProductListToUpdate.put(recordIdInContext,accountProductRecord);
            }
            return accountProductListToUpdate;
        }
        catch(Exception ex){
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
    }
    
    
    /**************************************************************************************************
* @Description : This method updates status, substatus and comment fields on external distribution list, for which new local bullention has created.
* @Param       : externalDistributionListToUpdate - List of OC_AN_Bulletin_Account_Product__c that need to be updated.
* @Param	   : externalDistributionList - List of OC_AN_Bulletin_Account_Product__c old data from database
* @Return      : map of id vrs OC_AN_Bulletin_Account_Product__c records.
****************************************************************************************************/
    
    public static map<Id,OC_AN_Bulletin_Account_Product__c> updateParentExternalDistributionList( List<AccountWrapper> accWrapperList,map<Id,OC_AN_Bulletin_Account_Product__c> externalDistributionListToUpdate, map<id,OC_AN_Bulletin_Account_Product__c> externalDistributionList){
        OC_AN_Bulletin_Account_Product__c recordToUpdate;
        OC_AN_Bulletin_Account_Product__c accountProductRecordOld;
        try{
            for(AccountWrapper recordIdInContext:accWrapperList){
                
                //check if record is present in externalDistributionListToUpdate else create new record instance.
                if(! externalDistributionListToUpdate.isEmpty() && externalDistributionListToUpdate.containskey(recordIdInContext.RecordId))
                    recordToUpdate=externalDistributionListToUpdate.get(recordIdInContext.RecordId);
                else 
                    recordToUpdate= new OC_AN_Bulletin_Account_Product__c();
                
                //get old data to compare 
                if(! externalDistributionList.isEmpty() && externalDistributionList.containsKey(recordIdInContext.RecordId))
                    accountProductRecordOld=externalDistributionList.get(recordIdInContext.RecordId);
                
                //check if status is not blank and changed.
                if(String.isNotBlank(recordIdInContext.Status)){
                    if(! recordIdInContext.Status.equals(accountProductRecordOld.OC_AN_Status__c)){
                        recordToUpdate.id=recordIdInContext.RecordId;
                        recordToUpdate.OC_AN_Status__c=recordIdInContext.Status;
                    }
                    //check if substatus is not blank and changed.
                    if(String.isNotBlank(recordIdInContext.SUBSTATUS) 
                       && ! recordIdInContext.SUBSTATUS.equals(accountProductRecordOld.OC_AN_Sub_Status__c)){
                           recordToUpdate.id=recordIdInContext.RecordId;
                           recordToUpdate.OC_AN_Sub_Status__c=recordIdInContext.SUBSTATUS;
                       }
                }
                //check if comment is not blank and changed.
                if(String.isNotBlank(recordIdInContext.textBoxValue) 
                   &&! recordIdInContext.textBoxValue.equals(accountProductRecordOld.OC_AN_Comments__c)){
                       recordToUpdate.OC_AN_Comments__c=recordIdInContext.textBoxValue;
                       recordToUpdate.id=recordIdInContext.RecordId;
                   }
                if(String.isNotBlank(recordToUpdate.id)){
                    externalDistributionListToUpdate.put(recordIdInContext.RecordId,recordToUpdate);
                }
                
                
            }
            
            return externalDistributionListToUpdate;
        }
        catch(Exception ex){
            AuraHandledException auraException = new AuraHandledException(ex.getMessage());
            auraException.setMessage(ex.getMessage());
            throw auraException;
        }
    }
    
    
    
    /**************************************************************************************************
* @Description : //Wrapper class to get lsit of updated external distribution list from component.  
****************************************************************************************************/
    
    
    public class AccountWrapper {
        
        public String Status;
        public String RecordId;
        public String SUBSTATUS;
        public String textBoxValue;
        public String accountID;
        public String accountName;
        public String createLBForAccountFlag;
        
        
    }
    
    
}