/**
 * @File Name          : OC_AN_MultipleAccSelectionHandlerClone (Controller class for lwc component oc_an_accountSelectionTreeGrid)
 * @Description        : This class will display all the service accounts and will
 * 				 		associate the selected service accounts to the bulletin
 *
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Created Date       : 10th April
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-04-10                 IBM               Initial Version
 * 2.0        2021-07-12                 IBM               Updated as part of user story U-2981
 * 3.0        2021-08-23                 IBM               Updated as part of U-2867
 **/

public with sharing class OC_AN_MultipleAccSelectionHandlerClone {
  private static final String MARKET_AREA_ID = 'MA';
  private static final String CUSTOMER_UNIT_ID = 'CU';

  /**************************************************************************************************
   * @Description : This method will return the current bulletin details.
   * @Return      : Bulletin record.
   ****************************************************************************************************/
  @AuraEnabled(cacheable=true)
  public static OC_AN_Bulletin__c getBulletin(String bulletinId) {
    return ([
      SELECT Id, OC_AN_Parent_Bulletin__c, RecordType.DeveloperName
      FROM OC_AN_Bulletin__c
      WHERE Id = :bulletinId
      LIMIT 1
    ]);
  }

  /**************************************************************************************************
	 * @Description : This method will return the count of accounts based on Service account type and
   * RecordType.
	 * @Return      : Count of Account Records.
	****************************************************************************************************/
  @AuraEnabled(cacheable=true)
  public static Integer getCountOfAccounts() {
    return ([
      SELECT COUNT()
      FROM Account
      WHERE
        Account_Type__c = :OC_AN_Constants.service
        AND RecordTypeId = :OC_AN_Constants.recTypeId_forServiceAccount
    ]);
  }

  /**************************************************************************************************
	 * @Description : This method will return the count of accounts related to the parent Bulletin
   * based on Service account type and RecordType which are either assigned to the Local bulletin or
   * has OC_An_Local_Bulletin value as blank.
	 * @Param       : parentBulletinId - Id of the Parent bulletin
	 * @Param       : bulletinId - Id of the Local bulletin
	 * @Return      : Count of Account Records.
	****************************************************************************************************/
  @AuraEnabled
  public static Integer getCountOfAccountsLocalBulletin(String parentBulletinId, String bulletinId) {
    Set<Id> bapAccountSet = new Set<Id>();
    Set<Id> bapAccForLocalBulletinSet = new Set<Id>();
    for(OC_AN_Bulletin_Account_Product__c bapRecord : [
      SELECT Id, OC_AN_Account__c
      FROM OC_AN_Bulletin_Account_Product__c
      WHERE
        OC_AN_Bulletin__c = :parentBulletinId
        AND (OC_AN_Local_Bulletin__c = ''
        OR OC_AN_Local_Bulletin__c = :bulletinId)
        AND OC_AN_Account__r.Account_Type__c = :OC_AN_Constants.service
        AND OC_AN_Account__r.RecordTypeId = :OC_AN_Constants.recTypeId_forServiceAccount
    ]){
        bapAccountSet.add(bapRecord.OC_AN_Account__c);
    }
 
    //Validate if User is marked as Local Publisher for the related Accounts.
    for (OC_AN_Group_Member__c groupMemberRecord : [
      SELECT
        id,
        OC_AN_Account__c,
        OC_AN_Account__r.Name,
        OC_AN_Account__r.MarketArea__c,
        OC_AN_Account__r.CustomerUnit__c
      FROM OC_AN_Group_Member__c
      WHERE
        OC_AN_Local_Publisher__c = TRUE
        AND RecordTypeId = :OC_AN_Constants.recordTypeId_LocalPublisher
        AND OC_AN_User__c = :UserInfo.getUserId()
        AND OC_AN_Account__c IN :bapAccountSet
    ]) {
      bapAccForLocalBulletinSet.add(groupMemberRecord.OC_AN_Account__c);
    }
      return bapAccForLocalBulletinSet.size();
  }

  /**************************************************************************************************
   * @Description : This method will return accounts based on offset count.
   * @Param       : offsetCount - This will be used to determine the number of records to be skipped
   * before returning the accounts list.
   * @Param       : marketAreaId - Id of the initial/Last Market Area displayed.
   * @Param       : customerUnitId - Id of the initial/Last Customer Unit displayed. 
   * @Return      : Account details wrapper.
   ****************************************************************************************************/
  @AuraEnabled
  public static AccGridDataListWrapper getAccountsToDisplay(
    Integer offsetCount,
    Integer marketAreaId,
    Integer customerUnitId
  ) {
    Map<Id, Account> serviceAccountMap = new Map<Id, Account>();
    for (Account accRecord : [
      SELECT Id, Name, MarketArea__c, CustomerUnit__c
      FROM Account
      WHERE
        Account_Type__c = :OC_AN_Constants.service
        AND RecordTypeId = :OC_AN_Constants.recTypeId_forServiceAccount
      ORDER BY MarketArea__c NULLS LAST, CustomerUnit__c NULLS LAST, Name
      LIMIT 10
      OFFSET :offsetCount
    ]) {
      serviceAccountMap.put(accRecord.Id, accRecord);
    }
    return createAccountWrapper(serviceAccountMap, marketAreaId, customerUnitId);
  }

  /**************************************************************************************************
	 * @Description : This method will return Parent bulletin accounts not associated with Local
   * Bulletin based on offsetCount.
	 * @Param       : offsetCount - This will be used to determine the number of records to be skipped
   * before returning the accounts list.
   * @Param       : marketAreaId - Id of the initial/Last Market Area displayed.
   * @Param       : customerUnitId - Id of the initial/Last Customer Unit displayed.
	 * @Param       : parentBulletinId - Id of the Parent bulletin.
	 * @Param       : bulletinId - Id of the Local bulletin
	 * @Return      : Account details wrapper.
	****************************************************************************************************/
  @AuraEnabled
  public static AccGridDataListWrapper getAccountsForLocalBuletin(
    Integer offsetCount,
    Integer marketAreaId,
    Integer customerUnitId,
    String parentBulletinId,
    String bulletinId
  ) {
    Set<Id> bapAccountSet = new Set<Id>();
    for (OC_AN_Bulletin_Account_Product__c bapRecord : [
      SELECT Id, OC_AN_Account__c
      FROM OC_AN_Bulletin_Account_Product__c
      WHERE
        OC_AN_Bulletin__c = :parentBulletinId
        AND (OC_AN_Local_Bulletin__c = ''
        OR OC_AN_Local_Bulletin__c = :bulletinId)
        AND OC_AN_Account__r.Account_Type__c = :OC_AN_Constants.service
        AND OC_AN_Account__r.RecordTypeId = :OC_AN_Constants.recTypeId_forServiceAccount
      ORDER BY
        OC_AN_Account__r.MarketArea__c NULLS LAST,
        OC_AN_Account__r.CustomerUnit__c NULLS LAST,
        OC_AN_Account__r.Name
      LIMIT 10
      OFFSET :offsetCount
    ]) {
      bapAccountSet.add(bapRecord.OC_AN_Account__c);
    }

    Map<Id, Account> serviceAccountMap = new Map<Id, Account>();
    //Validate if User is marked as Local Publisher for the related Accounts.
    for (OC_AN_Group_Member__c groupMemberRecord : [
      SELECT
        id,
        OC_AN_Account__c,
        OC_AN_Account__r.Name,
        OC_AN_Account__r.MarketArea__c,
        OC_AN_Account__r.CustomerUnit__c
      FROM OC_AN_Group_Member__c
      WHERE
        OC_AN_Local_Publisher__c = TRUE
        AND RecordTypeId = :OC_AN_Constants.recordTypeId_LocalPublisher
        AND OC_AN_User__c = :UserInfo.getUserId()
        AND OC_AN_Account__c IN :bapAccountSet
    ]) {
      serviceAccountMap.put(groupMemberRecord.OC_AN_Account__c, groupMemberRecord.OC_AN_Account__r);
    }
    return createAccountWrapper(serviceAccountMap, marketAreaId, customerUnitId);
  }

  /**************************************************************************************************
   * @Description : This method will return the existing Accounts mapped to current bulletin.
   * @Param       : offsetCount - This will be used to determine the number of records to be skipped
   * before returning the accounts list.
   * @Param       : bulletinId - Id of the bulletin.
   * @Return      : List of Account Ids.
   ****************************************************************************************************/
  @AuraEnabled(cacheable=true)
  public static List<Id> getExistingBulletinAccountRecords(Id bulletinId) {
    List<Id> existingAccountList = new List<Id>();
    for (OC_AN_Bulletin_Account_Product__c bapRecord : [
      SELECT Id, OC_AN_Account__c
      FROM OC_AN_Bulletin_Account_Product__c
      WHERE
        OC_AN_Bulletin__c = :bulletinId
        AND OC_AN_Local_Bulletin__c = ''
        AND OC_AN_Account__r.Account_Type__c = :OC_AN_Constants.service
        AND OC_AN_Account__r.RecordTypeId = :OC_AN_Constants.recTypeId_forServiceAccount
    ]) {
      existingAccountList.add(bapRecord.OC_AN_Account__c);
    }
    return existingAccountList;
  }

  /**************************************************************************************************
   * @Description : This method will create the Account data wrapper to be displayed.
   * @Param       : serviceAccountMap - Map of Service Accounts.
   * @Param       : marketAreaId - Start Id/Last Id of Account tree grid parent.
   * @Param       : customerUnitId - Start Id/Last Id of Account tree grid child.
   * @Return      : Account details wrapper.
   ****************************************************************************************************/
  private static AccGridDataListWrapper createAccountWrapper(
    Map<Id, Account> serviceAccountMap,
    Integer marketAreaId,
    Integer customerUnitId
  ) {
    Map<String, Set<String>> treeGridChildByParentMap = new Map<String, Set<String>>();
    Map<String, Set<Account>> accByCustUnitMap = new Map<String, Set<Account>>();
    AccGridDataListWrapper accListWrapper = new AccGridDataListWrapper();
    Boolean isMarketArea = false;
    accListWrapper.offsetCount = serviceAccountMap.size();
    for (Account accountRecord : serviceAccountMap.values()) {
      String customerUnitValue = accountRecord.CustomerUnit__c.stripHtmlTags();
      Set<String> customerUnitSet = treeGridChildByParentMap.get(accountRecord.MarketArea__c) != null
        ? treeGridChildByParentMap.get(accountRecord.MarketArea__c)
        : new Set<String>();
      Set<Account> serviceAccountSet = accByCustUnitMap.get(customerUnitValue) != null
        ? accByCustUnitMap.get(customerUnitValue)
        : new Set<Account>();
      if (accountRecord.MarketArea__c != null && String.isNotBlank(customerUnitValue)) {
        customerUnitSet.add(customerUnitValue);
        treeGridChildByParentMap.put(accountRecord.MarketArea__c, customerUnitSet);
        serviceAccountSet.add(accountRecord);
        accByCustUnitMap.put(customerUnitValue, serviceAccountSet);
      } else if (accountRecord.MarketArea__c == null && String.isBlank(customerUnitValue)) {
        treeGridChildByParentMap.put(accountRecord.Id, null);
      } else if (accountRecord.MarketArea__c == null || String.isBlank(customerUnitValue)) {
        String accTreeParentValue = String.isNotBlank(customerUnitValue)
          ? customerUnitValue
          : accountRecord.MarketArea__c;
        isMarketArea = (accountRecord.MarketArea__c != null);
        treeGridChildByParentMap.put(accTreeParentValue, null);
        serviceAccountSet.add(accountRecord);
        accByCustUnitMap.put(accTreeParentValue, serviceAccountSet);
      }
    }

    //Prepare wrapper structure to be displayed in tree grid
    List<AccountParentWrapper> accountWrapperList = new List<AccountParentWrapper>();
    for (String marketAreaValue : treeGridChildByParentMap.keySet()) {
      AccountParentWrapper parentWrapper = new AccountParentWrapper();
      Set<AccountChildWrapper> childWrapperSet = new Set<AccountChildWrapper>();
      if (treeGridChildByParentMap.get(marketAreaValue) != null) {
        parentWrapper.Name = marketAreaValue;
        parentWrapper.Id = MARKET_AREA_ID + marketAreaId;
        marketAreaId++;
      } else if (accByCustUnitMap.containsKey(marketAreaValue)) {
        parentWrapper.Name = marketAreaValue;
        if (isMarketArea) {
          parentWrapper.Id = MARKET_AREA_ID + marketAreaId;
          marketAreaId++;
        } else {
          parentWrapper.Id = CUSTOMER_UNIT_ID + customerUnitId;
          customerUnitId++;
        }
        for (Account customerUnitAccRecord : accByCustUnitMap.get(marketAreaValue)) {
          AccountChildWrapper childWrapper = new AccountChildWrapper();
          childWrapper.Name = customerUnitAccRecord.Name;
          childWrapper.Id = customerUnitAccRecord.Id;
          childWrapperSet.add(childWrapper);
        }
        parentWrapper.children = childWrapperSet;
      } else {
        parentWrapper.Name = serviceAccountMap.get(marketAreaValue).Name;
        parentWrapper.Id = marketAreaValue;
      }
      if (treeGridChildByParentMap.get(marketAreaValue) != null) {
        for (String custUnitValue : treeGridChildByParentMap.get(marketAreaValue)) {
          AccountChildWrapper childWrapper = new AccountChildWrapper();
          childWrapper.Name = custUnitValue;
          childWrapper.Id = CUSTOMER_UNIT_ID + customerUnitId;
          childWrapper.children = accByCustUnitMap.get(custUnitValue);
          childWrapperSet.add(childWrapper);
          customerUnitId++;
        }
        parentWrapper.children = childWrapperSet;
      }
      accountWrapperList.add(parentWrapper);
    }
    accListWrapper.lastMarketAreaId = marketAreaId;
    accListWrapper.lastCustomerUnitId = customerUnitId;
    accListWrapper.accsByMarketAreaList = accountWrapperList;
    return accListWrapper;
  }

  /**************************************************************************************************
   * @Description : This will be used to associate the selected accounts to the bulletin
   * @Param       : selectedAccsJson - JSON string with selected and deselected accounts to be
   * associated to and deleted from the Bulletin.
   * @Param       : isLocalVersion - Boolean value indicating if the record is Local Bulletin.
   * @Return      : Boolean value to show/hide the confirmation dialog.
   ****************************************************************************************************/
  @AuraEnabled
  public static Boolean showDeleteConfirmation(
    String selectedAccsJson,
    Boolean isLocalVersion
  ) {
    Map<String, Object> records = (Map<String, Object>) json.deserializeUntyped(selectedAccsJson);
    Map<String, Object> selectedRecords = getAccountRecordsFromMap(
      (Map<String, Object>) records.get('selected')
    );
    return (isLocalVersion && selectedRecords.size() == 0);
  }

  /**************************************************************************************************
   * @Description : This will be used to associate the selected accounts to the bulletin
   * @Param       : selectedAccsJson - JSON string with selected and deselected accounts to be
   * associated to and deleted from the Bulletin.
   * @Param       : bulletinId - Id of the bulletin.
   * @Param       : parentBulletinId - Id of the Parent bulletin.
   * @Param       : shouldDeleteBulletin - Boolean value to specify if Local Bulletin should be deleted.
   ****************************************************************************************************/
  @AuraEnabled
  public static void upsertAccountToBulletin(
    String selectedAccsJson,
    String bulletinId,
    String parentBulletinId,
    Boolean shouldDeleteBulletin
  ) {
    String upsertAccountToBulletinMethod = 'upsertAccountToBulletin';
    Map<String, Object> records = (Map<String, Object>) json.deserializeUntyped(selectedAccsJson);
    Map<String, Object> selectedRecords = getAccountRecordsFromMap(
      (Map<String, Object>) records.get('selected')
    );
    Map<String, Object> deSelectedRecords = getAccountRecordsFromMap(
      (Map<String, Object>) records.get('deselected')
    );
    List<OC_AN_Bulletin_Account_Product__c> bulletinAccountsToBeUpsertedList = new List<OC_AN_Bulletin_Account_Product__c>();
    List<OC_AN_Bulletin_Account_Product__c> bapToBeDeletedList = new List<OC_AN_Bulletin_Account_Product__c>();

    try {
      // query existing bap records for this bulletin for the selected/deselected Accounts
      List<Id> existingBapAccountList = new List<Id>();
      for (OC_AN_Bulletin_Account_Product__c bapRecord : [
        SELECT OC_AN_Account__c
        FROM OC_AN_Bulletin_Account_Product__c
        WHERE
          OC_AN_Bulletin__c = :bulletinId
          AND OC_AN_Account__c IN :selectedRecords.keySet()
      ]) {
        existingBapAccountList.add(bapRecord.OC_AN_Account__c);
      }

      //Logic for removing Local bulletin value from parent once child record is deleted
      for (OC_AN_Bulletin_Account_Product__c bapRecord : [
        SELECT 
          Id,
          OC_AN_Local_Bulletin__c,
          OC_AN_BulletinAccProductAttrKey__c
        FROM
          OC_AN_Bulletin_Account_Product__c
        WHERE
          (OC_AN_Bulletin__c = :bulletinId
          OR OC_AN_Local_Bulletin__c = :bulletinId)
          AND OC_AN_Account__c IN :deSelectedRecords.keySet()
      ]) {
        if (bapRecord.OC_AN_Local_Bulletin__c == bulletinId) {
          bapRecord.OC_AN_Local_Bulletin__c = null;
          bulletinAccountsToBeUpsertedList.add(bapRecord);
        } else {
          bapToBeDeletedList.add(bapRecord);
        }
      }

      for (Id accountId : selectedRecords.keySet()) {
        if (!existingBapAccountList.contains(accountId)) {
          OC_AN_Bulletin_Account_Product__c accountToassociate = new OC_AN_Bulletin_Account_Product__c();
          accountToassociate.RecordTypeId = OC_AN_Constants.recTypeId_Account;
          accountToassociate.OC_AN_Account__c = accountId;
          accountToassociate.OC_AN_Bulletin__c = String.valueOf(bulletinId);
          accountToassociate.OC_AN_BulletinAccProductAttrKey__c =
            accountId + '' + bulletinId;
          if (String.isNotBlank(parentBulletinId)) {
            accountToassociate.OC_AN_Status__c = OC_AN_Constants.STATUS_SEND;
          }
          bulletinAccountsToBeUpsertedList.add(accountToassociate);
          if (String.isNotBlank(parentBulletinId)) {
            parentBulletinId = parentBulletinId.left(15);
            OC_AN_Bulletin_Account_Product__c accountToassociateParentUpdate =
              new OC_AN_Bulletin_Account_Product__c();
            accountToassociateParentUpdate.OC_AN_BulletinAccProductAttrKey__c =
              accountId + '' + parentBulletinId;
            accountToassociateParentUpdate.OC_AN_Local_Bulletin__c = bulletinId;
            bulletinAccountsToBeUpsertedList.add(accountToassociateParentUpdate);
          }
        }
      }

      if (bulletinAccountsToBeUpsertedList != null && bulletinAccountsToBeUpsertedList.size() > 0) {
        upsert bulletinAccountsToBeUpsertedList OC_AN_BulletinAccProductAttrKey__c;
        markIsExternalAsTrue(bulletinId);
      }
      if (bapToBeDeletedList != null && bapToBeDeletedList.size() > 0) {
        delete bapToBeDeletedList;
        if (shouldDeleteBulletin) {
          OC_AN_Bulletin__c bulletinTodelete = getBulletin(bulletinId);
          delete bulletinTodelete;
        }
      }
    } catch (Exception e) {
      EventLog.createLog(
        new EventLog.Error(OC_AN_Constants.OC_AN_MultipleAccountSelectionHandler,
          upsertAccountToBulletinMethod, null, false, e)
      );
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**************************************************************************************************
   * @Description : Method to retrieve Account records from JSON sent from LWC.
   * @Param       : updatedRecords - Map of selecetd/deselected records.
   * @Return      : Map of selected/deselected Account records.
   ****************************************************************************************************/
  private static Map<String, Object> getAccountRecordsFromMap(
    Map<String, Object> updatedRecords
  ) {
    Map<String, Object> updatedAccountsMap = new Map<String, Object>();
    for (String accId : updatedRecords.keyset()) {
      if (accId.startsWith('001')) {
        updatedAccountsMap.put(accId, updatedRecords.get(accId));
      }
    }
    return updatedAccountsMap;
  }

  /**************************************************************************************************
		* @Description : This will mark the external checkbox as true whenever an account is successfully 
							 associated to bulletin.
		* @Param       : bulletinId - Id of the bulletin to mark the checbox as true
	****************************************************************************************************/
  public static void markIsExternalAsTrue(Id bulletinId) {
    List<OC_AN_Bulletin__c> bulletinToUpdate = new List<OC_AN_Bulletin__c>();
    for (OC_AN_Bulletin__c oc : [
      SELECT Id, OC_AN_IsExternal__c, OC_AN_Current_Status__c
      FROM OC_AN_Bulletin__c
      WHERE Id = :bulletinId
    ]) {
      if (oc.OC_AN_IsExternal__c == false && oc.OC_AN_Current_Status__c == OC_AN_Constants.DRAFT) {
        oc.OC_AN_IsExternal__c = true;
        bulletinToUpdate.add(oc);
      }
    }
    if (!bulletinToUpdate.isEmpty()) {
      try {
        update bulletinToUpdate;
      } catch (Exception e) {
        EventLog.createLog(
          new EventLog.Error(OC_AN_Constants.OC_AN_MultipleAccountSelectionHandler,
            OC_AN_Constants.markIsExternalAsTrue, null, false, e)
        );
      }
    }
  }

  /**************************************************************************************************
   * @Description : Wrapper Class to return offset, Id details and Account data to be displayed.
   ****************************************************************************************************/
  public class AccGridDataListWrapper {
    @AuraEnabled
    public Integer offsetCount { get; set; }
    @AuraEnabled
    public Integer lastMarketAreaId { get; set; }
    @AuraEnabled
    public Integer lastCustomerUnitId { get; set; }
    @AuraEnabled
    public List<AccountParentWrapper> accsByMarketAreaList { get; set; }
  }

  /**************************************************************************************************
   * @Description : Wrapper Class to store Parent node details for the Account tree grid.
   ****************************************************************************************************/
  public class AccountParentWrapper {
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public Set<AccountChildWrapper> children { get; set; }
  }

  /**************************************************************************************************
   * @Description : Wrapper Class to store child node details for the Account tree grid.
   ****************************************************************************************************/
  public class AccountChildWrapper {
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public Set<Account> children { get; set; }
  }
}