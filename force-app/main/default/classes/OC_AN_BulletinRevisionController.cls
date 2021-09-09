/**
* @File Name          : OC_AN_BulletinRevisionController
* @Description        : U- Alerts & Notification: Creation of Revision Bulletins.
*                       Controller class to create Revsion bulletin and its related records.
* @Author             : IBM
* @Group              : OmniChannel - Service
* @Created Date       : 2nd August 2021
* @Modification Log   : 
*==============================================================================
* Ver         Date                     Author                Modification
*==============================================================================
* 1.0        2021-08-02              	IBM               Initial Version
**/
public with sharing class OC_AN_BulletinRevisionController {

  /**************************************************************************************************
   * @Description : This method is used to create a new Revision bulletin and its related records by
   * replicating the existing Intenally/Externally published bulletin.
   * @Param       : bulletinId - Id of the Main/Revision Bulletin to create new Revision bulletin.
   * @Return      : Revision record Id.
   ****************************************************************************************************/
  @AuraEnabled
  public static Id processRecords(String bulletinId) {
    Id revisionBulletinId;
    List<OC_AN_Bulletin_Account_Product__c> bulletinAccProductsList = new List<OC_AN_Bulletin_Account_Product__c>();

    OC_AN_Bulletin__c parentBulletinRecord = [
      SELECT
        Id,
        Name,
        OC_AN_Bulletin_Template__c,
        OC_AN_Body_Of_Bulletin__c,
        OC_AN_Internal_Body_Of_Bulletin__c,
        OC_AN_Issue__c,
        OC_AN_Approver__c,
        OC_AN_Delay__c,
        OC_AN_Type__c,
        OC_AN_Organization__c,
        OC_AN_Parent_Bulletin__c
      FROM OC_AN_Bulletin__c
      WHERE id = :bulletinId
    ];
    for (OC_AN_Bulletin_Account_Product__c bapChildRecords : getBulletinAccountProducts(parentBulletinRecord.Id)) {
      bulletinAccProductsList.add(bapChildRecords);
    }
    revisionBulletinId = createRevisionBulletinRecord(parentBulletinRecord);
    createBulletinAccoutProductRecords(revisionBulletinId, bulletinAccProductsList);
    updateBulletinStatus(bulletinId);
    return revisionBulletinId;
  }
    
    private static List<OC_AN_Bulletin_Account_Product__c> getBulletinAccountProducts(Id bulletinId){
        return [
            SELECT
            Id,
            OC_AN_RoleForA_N__c,
            recordtypeId,
            OC_AN_Product__c,
            OC_AN_Release__c,
            OC_AN_Verison__c,
            OC_AN_GroupId__c,
            OC_AN_Account__c,
            OC_AN_Public_Group_Name__c,
            OC_AN_Status__c,
            OC_AN_Sub_Status__c,
            OC_AN_Comments__c
          FROM OC_AN_Bulletin_Account_Product__c
          WHERE OC_AN_Bulletin__c =  :bulletinId];
    }

  /**************************************************************************************************
   * @Description : Method to create Revision Bulletin record with details from existing Bulletin.
   * @Param       : parentBulletinRecord - Existing Main/Revision Bulletin record to be cloned.
   * @Return      : Revision record Id.
   ****************************************************************************************************/
  private static id createRevisionBulletinRecord(OC_AN_Bulletin__c parentBulletinRecord) {
    try {
      OC_AN_Bulletin__c revisionBullentinToCreate = parentBulletinRecord.clone(false, true);
      revisionBullentinToCreate.OC_AN_Current_Status__c = OC_AN_Constants.DRAFT;
      revisionBullentinToCreate.RecordTypeId =
          Schema.SObjectType.OC_AN_Bulletin__c.getRecordTypeInfosByDeveloperName()
            .get('OC_AN_Revision')
            .getRecordTypeId();
      revisionBullentinToCreate.OC_AN_Approver__c = null;
      revisionBullentinToCreate.OC_AN_IsInternal__c = true;
      revisionBullentinToCreate.OC_AN_Issue__c = '';
      if (parentBulletinRecord.OC_AN_Parent_Bulletin__c != null) {
        revisionBullentinToCreate.OC_AN_Parent_Bulletin__c = parentBulletinRecord.OC_AN_Parent_Bulletin__c;
      } else {
        revisionBullentinToCreate.OC_AN_Parent_Bulletin__c = parentBulletinRecord.Id;
      }
      insert revisionBullentinToCreate;
      return revisionBullentinToCreate.id;
    } catch (Exception ex) {
      AuraHandledException auraException = new AuraHandledException(ex.getMessage());
      auraException.setMessage(ex.getMessage());
      throw auraException;
    }
  }

  
  /**************************************************************************************************
   * @Description : Method to create Bulletin Account product records for the New Revision Bulletin
   * similar to the ones present for Existing Main/Revision Bulletin.
   * @Param       : revisionBullentinId - Id of the new Revision record.
   * @Param       : existingBapRecordsList - Bulletin Account Products List from the existing
   * Main/Revision Bulletin record to be cloned.
   ****************************************************************************************************/
  private static void createBulletinAccoutProductRecords(Id revisionBullentinId,
    List<OC_AN_Bulletin_Account_Product__c> existingBapRecordsList) {
    List<OC_AN_Bulletin_Account_Product__c> bapRecordsToInsertList = new List<OC_AN_Bulletin_Account_Product__c>();
    for (OC_AN_Bulletin_Account_Product__c bapRecord : existingBapRecordsList) {
      OC_AN_Bulletin_Account_Product__c newBapRecord = bapRecord.clone(false, true);
      newBapRecord.OC_AN_Bulletin__c = revisionBullentinId;
      if (newBapRecord.RecordTypeId == OC_AN_Constants.recTypeId_PublicGroup) {
        newBapRecord.OC_AN_IsPublicGroup__c = true;
      } else if (
        newBapRecord.RecordTypeId == OC_AN_Constants.recTypeId_Account
      ) {
        newBapRecord.OC_AN_Status__c = OC_AN_Constants.SEND;
      }
      bapRecordsToInsertList.add(newBapRecord);
    }
        if(!bapRecordsToInsertList.isEmpty()){
    insert bapRecordsToInsertList;
        }
  }

  
  /**************************************************************************************************
   * @Description : Method to update the existing Main/Revision Bulletin record status to Invalid
   * after created of new Revision Bulletin.
   * @Param       : bulletinId - Id of the Bulletin record which was used to create new Revision bulletin.
   ****************************************************************************************************/
  private static void updateBulletinStatus(String bulletinId) {
    List<OC_AN_Bulletin__c> bulletinUpdateList = new List<OC_AN_Bulletin__c>();
    for (OC_AN_Bulletin__c bulletinToBeUpdated : [
      SELECT
        Id,
        OC_AN_Mark_as_Invalid_obsolete__c
      FROM
        OC_AN_Bulletin__c
      WHERE
        Id = :bulletinId
    ]) {
      if (bulletinToBeUpdated != null) {
        bulletinToBeUpdated.OC_AN_Mark_as_Invalid_obsolete__c = true;
      }
      bulletinUpdateList.add(bulletinToBeUpdated);
    }
      if(!bulletinUpdateList.isEmpty()){
    update bulletinUpdateList;
      }
  }
}