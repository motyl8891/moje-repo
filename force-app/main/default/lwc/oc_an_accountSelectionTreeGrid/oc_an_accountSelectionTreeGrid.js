import { LightningElement, api, wire, track } from "lwc";
import getAccountsToDisplay from "@salesforce/apex/OC_AN_MultipleAccountSelectionHandler.getAccountsToDisplay";
import getCountOfAccounts from "@salesforce/apex/OC_AN_MultipleAccountSelectionHandler.getCountOfAccounts";
import associateAccountToBulletin from "@salesforce/apex/OC_AN_MultipleAccountSelectionHandler.associateAccountToBulletin";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { allConstants, labels } from "./labels";

import getBulletin from "@salesforce/apex/OC_AN_MultipleAccountSelectionHandler.getBulletin";
import getAccountsForLocalBuletin from "@salesforce/apex/OC_AN_MultipleAccountSelectionHandler.getAccountsForLocalBuletin";
import getCountOfAccountsLocalBulletin from "@salesforce/apex/OC_AN_MultipleAccountSelectionHandler.getCountOfAccountsLocalBulletin";

const OFFSET_SIZE = 10;

export default class Oc_an_accountSelectionTreeGrid extends LightningElement {
  constants = allConstants;

  @api recordId;
  label = labels;
  record;

  accountsData = [];

  // Internal
  offsetCount;
  isDataRetrieved = false;
  accountColumns = [
    {
      label: this.label.oc_an_columns_name,
      fieldName: this.label.oc_an_columns_field_name,
      type: "text"
    }
  ];

  connectedCallback() {
    this.getBulletinData();
  }
  getBulletinData() {
    getBulletin({ bulletinId: this.recordId })
      .then((result) => {
        console.log(result);
        this.record = result;

        this.getAccountsCount();
        this.getAccountData(
          OFFSET_SIZE
        );
      })
      .catch((error) => {
        this.error = error;
      });
  }
  getAccountsCount() {
    if (this.record.RecordType.DeveloperName.includes("Local")) {
      getCountOfAccountsLocalBulletin({
        parentBulletinId: this.record.OC_AN_Parent_Bulletin__c
      })
        .then((result) => {
          this.numberOfAccounts = result;
          if (result == 0) {
            this.showToastMessage(
              this.constants.toast_Variant_Warning,
              this.constants.toast_Variant_Warning,
              this.label.NoAccountsFound,
              2000
            );
          }
        })
        .catch((error) => {
          this.error = error;
        });
    } else {
      getCountOfAccounts()
        .then((result) => {
          this.numberOfAccounts = result;
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }

  /*handlePagination(event) {
    let currentPgNo = event.detail.pageNumber;
    let pageSize = event.detail.pageSize;
    this.currentPageNumber = currentPgNo;
    this.getAccountData(currentPgNo, pageSize, this.searchString);
  }*/

  getAccountData(numOfRecords) {
    if (this.record.RecordType.DeveloperName.includes("Local")) {
      getAccountsForLocalBuletin({
        offsetCount: numOfRecords,
        parentBulletinId: this.record.OC_AN_Parent_Bulletin__c
      })
        .then((result) => {
          this.accountsData = result;
          this.isDataRetrieved = true;
        })
        .catch((error) => {
          this.error = error;
        });
    } else {
      getAccountsToDisplay({
        offsetCount: numOfRecords
      })
        .then((result) => {
          this.accountsData = result;
          this.isDataRetrieved = true;
        })
        .catch((error) => {
          this.error = error;
        });
    }
  }

  /*getSelectedAccountIds(event) {
    let selectedRows = event.detail.selectedRows;
    // First step remove everything from this.toSetPreSelectedRows that is shown on this page
    for (let i = 0; i < this.accountsData.length; i++) {
      if (
        this.toSetPreSelectedRows.includes(this.accountsData[i].Id)
      ) {
        const indexToRemove = this.toSetPreSelectedRows.indexOf(
          this.accountsData[i].Id
        );
        if (indexToRemove > -1) {
          this.toSetPreSelectedRows.splice(indexToRemove, 1);
        }
      }
    }
    // Secondly add all the Id's that should be there...
    for (let i = 0; i < selectedRows.length; i++) {
      if (!this.toSetPreSelectedRows.includes(selectedRows[i].Id)) {
        this.toSetPreSelectedRows.push(selectedRows[i].Id);
      }
    }
  }*/

  handleAddAccount() {
    associateAccountToBulletin({
      //listOfAccountId: this.toSetPreSelectedRows,
      bulletinId: this.recordId,
      parentBulletinId: this.record.OC_AN_Parent_Bulletin__c
    })
      .then((result) => {
        this.showToastMessage(
          this.constants.toast_Variant_Success,
          this.constants.toast_Variant_Success,
          this.label
            .AssociatedExternalDistributionToBulletinSuccessFullyToastMsg,
          2000
        );
      })
      .catch((error) => {
        this.showToastMessage(
          this.constants.toast_Variant_Error,
          this.constants.toast_Variant_Error,
          this.label.FailedToAssociateExternalDistributionToBulletin,
          2000
        );
        this.dispatchEvent(
          new CustomEvent("handleafterfailed", {
            bubbles: true,
            composed: true
          })
        );
      });
  }

  showToastMessage(toastTitle, toastVariant, toastMessage, pageReloadDelay) {
    const event = new ShowToastEvent({
      title: toastTitle,
      variant: toastVariant,
      message: toastMessage
    });
    this.dispatchEvent(event);
    if (pageReloadDelay) {
      this.dispatchEvent(
        new CustomEvent("handleaftersave", { bubbles: true, composed: true })
      );
    }
  }

  /*searchDataTable(event) {
    this.searchString = event.detail.toLowerCase();
    this.getAccountData(START_PAGE_NUMBER, PAGINATION_SIZE, this.searchString);
  }*/
}