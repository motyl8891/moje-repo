import { LightningElement, api } from "lwc";
import getPublicGroups from "@salesforce/apex/OC_AN_InternalDistributionHandler.getPublicGroups";
import getCountOfGroups from "@salesforce/apex/OC_AN_InternalDistributionHandler.getCountOfGroups";
import associateInternalDistributionToBulletin from "@salesforce/apex/OC_AN_InternalDistributionHandler.associateInternalDistributionToBulletin";
import getRolesForAN from "@salesforce/apex/OC_AN_InternalDistributionHandler.getRolesForAN";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {allConstants, labels } from "./labels";

const START_PAGE_NUMBER = 1;
const PAGINATION_SIZE = 10;

export default class oc_an_internalDistributionSelection extends LightningElement {
  @api recordId;
  label = labels;
  constants = allConstants;

  searchString = "";

  isModalOpen = false;

  isLoading = false;

  selectedRoles = [];

  options = [];

  publicGroupDataWithPagination = [];
  preSelectedRows = [];
  toSetPreSelectedRows = [];

  numberOfPublicGroups;
  currentPageNumber;
  isDataRetrieved = false;
  publicGroupColoumns = [
    {
      label: this.label.oc_an_columnname_internaldistribution,
      fieldName: this.label.oc_an_columns_field_name,
      type: "text"
    }
  ];

  connectedCallback() {
    console.log('inside internal distribution selection');
    this.currentPageNumber = START_PAGE_NUMBER;
    this.getCountOfGroups();
    this.getPublicGroupData(
      START_PAGE_NUMBER,
      PAGINATION_SIZE,
      this.searchString
    );
  }

  getCountOfGroups() {
    getCountOfGroups()
      .then((result) => {
        this.numberOfPublicGroups = result;
      })
      .catch((error) => {
        this.error = error;
      });
  }

  handlePagination(event) {
    let currentPgNo = event.detail.pageNumber;
    let pageSize = event.detail.pageSize;
    this.getPublicGroupData(currentPgNo, pageSize, this.searchString);
  }

  getPublicGroupData(currentPageNum, numofRecperPage, ssearchString) {
    getPublicGroups({
      pageNumber: currentPageNum,
      pageSize: numofRecperPage,
      searchString: ssearchString
    })
      .then((result) => {
        this.publicGroupDataWithPagination = result;
        this.isDataRetrieved = true;
        this.preSelectedRows = this.toSetPreSelectedRows;
        this.template.querySelector(
          '[data-id="datarow"]'
        ).selectedRows = this.preSelectedRows;
      })
      .catch((error) => {
      
        this.error = error;
      });
  }

  getRolesForAlertsAndNotifications() {
    this.isLoading = true;
    getRolesForAN()
      .then((result) => {
        let roleOptions = [];
        for (let i = 0; i < result.length; i++) {
          roleOptions.push({
            label: result[i],
            value: result[i]
          });
        }
        this.options = roleOptions;
        this.isLoading = false;
      })
      .catch((error) => {
        this.error = error;
        this.isLoading = false;
      });
  }

  getSelectedIds(event) {
    let selectedRows = event.detail.selectedRows;
    // First step remove everything from this.toSetPreSelectedRows that is shown on this page
    for (let i = 0; i < this.publicGroupDataWithPagination.length; i++) {
      if (
        this.toSetPreSelectedRows.includes(
          this.publicGroupDataWithPagination[i].Id
        )
      ) {
        const indexToRemove = this.toSetPreSelectedRows.indexOf(
          this.publicGroupDataWithPagination[i].Id
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
  }

  handleSelectedValues(event) {
    this.selectedRoles = event.detail.value;
  }
  
  handleAddInternaldistribution() {
    associateInternalDistributionToBulletin({
      listOFPublicGroupIds: this.toSetPreSelectedRows,
      bulletinId: this.recordId,
      selectedRole: this.selectedRoles
    })
      .then((result) => {
        this.showToastMessage(
          this.constants.toast_Variant_Success,
          this.constants.toast_Variant_Success,
          this.label.AssociatedInternalDistributionToBulletinSuccessFullyToastMsg,
          2000
        );
      })
      .catch((error) => {
        
        this.showToastMessage(
          this.constants.toast_Variant_Error,
          this.constants.toast_Variant_Error,
          this.label.FailedToAssociateInternalDistributionToBulletinToastMsg,
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

  handleOpenModal() {
    this.isModalOpen = true;
    this.getRolesForAlertsAndNotifications();
  }
  closeModal() {
    this.isModalOpen = false;
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

  searchDataTable(event) {
    this.searchString = event.detail.toLowerCase();
    this.getPublicGroupData(
      START_PAGE_NUMBER,
      PAGINATION_SIZE,
      this.searchString
    );
  }
}